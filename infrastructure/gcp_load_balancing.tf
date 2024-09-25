locals {
  # An array of top-level domains mapped to this project
  top_level_domains = distinct(compact(["${terraform.workspace}.${var.domain_dev}", var.domain_prod]))

  # An exhaustive array of all full domains (incl. env-specific subdomains) associated with this project
  ssl_domains = distinct(flatten([
    for env in var.environments : [
      for domain in local.top_level_domains : env.subdomain == "" ? domain : "${env.subdomain}.${domain}"
    ]
  ]))

  # An array of environments with an associated array of their individual full domain arrays
  url_maps = [
    for env in var.environments: {
      env     = env
      domains = [for domain in local.top_level_domains : env.subdomain == "" ? domain : "${env.subdomain}.${domain}"]
    }
  ]
}

resource "google_compute_global_address" "lb_default" {
  project       = google_project.project.project_id
  name          = "global-ip"
  address_type  = "EXTERNAL"
  depends_on    = [google_project_service.services]
}

resource "google_compute_region_network_endpoint_group" "lb_default" {
  for_each              = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  provider              = google-beta
  project               = google_project.project.project_id
  name                  = "region-neg-${each.value.service.name}-${each.value.region}"
  network_endpoint_type = "SERVERLESS"
  region                = each.value.region

  cloud_run {
    service = "${each.value.service.name}-${each.value.region}"
  }
}

resource "google_compute_backend_service" "lb_default" {
  for_each                = var.environments
  provider                = google-beta
  project                 = google_project.project.project_id
  name                    = "lb-backend-${each.value.name}"
  load_balancing_scheme   = "EXTERNAL_MANAGED"
  enable_cdn              = each.value.enable_cdn
  custom_response_headers = [
    "X-Cache-Status: {cdn_cache_status}",
    "X-Cache-ID: {cdn_cache_id}"
  ]

  dynamic "backend" {
    for_each = each.value.regions

    content {
      group = google_compute_region_network_endpoint_group.lb_default["${each.value.name}.${backend.value}"].id
    }
  }

  depends_on = [google_project_service.services]
}

resource "google_compute_url_map" "lb_default" {
  provider        = google-beta
  project         = google_project.project.project_id
  name            = "lb-urlmap"
  default_service = google_compute_backend_service.lb_default[var.default_environment].id

  dynamic "host_rule" {
    for_each = local.url_maps

    content {
      hosts = host_rule.value.domains
      path_matcher = host_rule.value.env.name
    }
  }

  dynamic "path_matcher" {
    for_each = local.url_maps

    content {
      name            = path_matcher.value.env.name
      default_service = google_compute_backend_service.lb_default[path_matcher.value.env.name].id
      route_rules {
        priority = 1
        url_redirect {
          https_redirect         = true
          redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
        }
      }
    }
  }
}

resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "ssl-cert"

  managed {
    domains = local.ssl_domains
  }
}

resource "google_compute_target_https_proxy" "lb_default" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "https-proxy"
  url_map  = google_compute_url_map.lb_default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_default.name
  ]
  depends_on = [google_project_service.services]
}

resource "google_compute_global_forwarding_rule" "lb_default" {
  provider              = google-beta
  project               = google_project.project.project_id
  name                  = "lb-fr"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.lb_default.id
  ip_address            = google_compute_global_address.lb_default.id
  port_range            = "443"
}

# Outputs
output "global_ip" {
  value = google_compute_global_address.lb_default.address
}

output "top_level_domains" {
  value = local.top_level_domains
}

output "full_domains" {
  value = local.ssl_domains
}

provider "google" {
  region = var.gcp_region
}

provider "google-beta" {
  region = var.gcp_region
}

# Create a randomised project name
resource "random_id" "id" {
  byte_length = 2
  prefix      = "uxm-${replace(lower(terraform.workspace), "/\\s+/", "-")}-"
  keepers = {
    ami_id = terraform.workspace
  }
}

# Create GCP project
resource "google_project" "project" {
  name            = "${terraform.workspace}"
  project_id      = random_id.id.hex
  folder_id       = var.gcp_folder_id
  billing_account = var.gcp_billing_account
}

# Enable required services in the project, defined in the variables
resource "google_project_service" "services" {
  count   = length(var.google_project_services)
  project = google_project.project.project_id
  service = var.google_project_services[count.index]
  disable_on_destroy = true
}

# Flatten the services list to create
locals {
  gcr_services = distinct(flatten([
    for env in var.environments : [
      for region in env.regions : {
        service = env
        region  = region
      }
    ]
  ]))
}

# Create Google Cloud Run instances according to the config in vars
resource "google_cloud_run_v2_service" "services" {
  for_each            = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  project             = google_project.project.project_id
  name                = "${each.value.service.name}-${each.value.region}"
  location            = each.value.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources {
        limits = {
          cpu    = each.value.service.cpu
          memory = each.value.service.memory
        }
        cpu_idle          = each.value.service.cpu_idle
        startup_cpu_boost = each.value.service.cpu_boost
      }
    }
    scaling {
      min_instance_count = each.value.service.min_instances
      max_instance_count = each.value.service.max_instances
    }
    max_instance_request_concurrency = each.value.service.concurrency
  }

  depends_on = [google_project_service.services]
}

# # Set up public access to the Google Cloud Run services
# data "google_iam_policy" "noauth" {
#   binding {
#     role = "roles/run.invoker"
#     members = ["allUsers"]
#   }
# }

# resource "google_cloud_run_service_iam_policy" "noauth" {
#   for_each    = google_cloud_run_v2_service.services
#   location    = each.value.location
#   project     = each.value.project
#   service     = each.value.name
#   policy_data = data.google_iam_policy.noauth.policy_data
# }

# Load balancing
resource "google_compute_global_address" "default" {
  name          = "global-ip"
  project       = google_project.project.project_id
  address_type  = "EXTERNAL"
  depends_on    = [google_project_service.services]
}

locals {
  top_level_domains = distinct(compact([var.domain_dev, var.domain_prod]))
  ssl_domains = distinct(flatten([
    for env in var.environments : [
      for domain in local.top_level_domains : env.subdomain == "" ? "${terraform.workspace}.${domain}" : "${env.subdomain}.${terraform.workspace}.${domain}"
    ]
  ]))
}

resource "google_compute_region_network_endpoint_group" "lb_default" {
  for_each              = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  provider              = google-beta
  name                  = "region-neg-${each.value.service.name}-${each.value.region}"
  project               = google_project.project.project_id
  network_endpoint_type = "SERVERLESS"
  region                = each.value.region

  cloud_run {
    service = "${each.value.service.name}-${each.value.region}"
  }
}

resource "google_compute_backend_service" "lb_default" {
  for_each              = var.environments
  provider              = google-beta
  name                  = "lb-backend-${each.value.name}"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  dynamic "backend" {
    for_each = each.value.regions

    content {
      group = google_compute_region_network_endpoint_group.lb_default["${google_compute_backend_service.value.name}.${backend.value}"].id
    }
  }

  depends_on = [google_project_service.services]
}

resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "ssl-cert"
  project  = google_project.project.project_id

  managed {
    domains = local.ssl_domains
  }
}

# Outputs
output "gcp_project_name" {
  value = google_project.project.name
}

output "gcp_project_id" {
  value = google_project.project.project_id
}

output "global_ip" {
  value = google_compute_global_address.default.address
}

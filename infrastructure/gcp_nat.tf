locals {
  subnet_indices = [for entry in local.gcr_services: "${entry.service.name}.${entry.region}"]
  used_regions = distinct(flatten([
    for env in var.environments : [
      for region in env.regions : region
    ]
  ]))
}

resource "google_compute_network" "nat" {
  count    = var.gcp_use_nat_for_mongodb_atlas ? 1 : 0
  provider = google-beta
  project  = google_project.project.project_id
  name     = "vpc-egress-network"
  depends_on = [google_project_service.services]
}

resource "google_compute_subnetwork" "nat" {
  for_each      = { for region in (var.gcp_use_nat_for_mongodb_atlas ? local.used_regions : []): "${region}" => region }
  provider      = google-beta
  project       = google_project.project.project_id
  name          = "vpc-egress-subnetwork-${each.value}"
  ip_cidr_range = "10.${index(local.used_regions, each.value) + 20}.0.0/16"
  network       = google_compute_network.nat[0].id
  region        = each.value
}

resource "google_compute_router" "nat" {
  for_each = { for region in (var.gcp_use_nat_for_mongodb_atlas ? local.used_regions : []): "${region}" => region }
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-router-${each.value}"
  network  = google_compute_network.nat[0].name
  region   = google_compute_subnetwork.nat[each.value].region
}

resource "google_compute_address" "nat" {
  for_each = { for region in (var.gcp_use_nat_for_mongodb_atlas ? local.used_regions : []): "${region}" => region }
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-addr-${each.value}"
  region   = google_compute_subnetwork.nat[each.value].region

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router_nat" "nat" {
  for_each = { for region in (var.gcp_use_nat_for_mongodb_atlas ? local.used_regions : []): "${region}" => region }
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-nat-${each.value}"
  router   = google_compute_router.nat[each.value].name
  region   = google_compute_subnetwork.nat[each.value].region
  
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat[each.value].self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  
  subnetwork {
    name                    = google_compute_subnetwork.nat[each.value].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

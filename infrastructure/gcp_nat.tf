locals {
    subnet_indices = [for entry in local.gcr_services: "${entry.service.name}.${entry.region}"]
}

resource "google_compute_network" "nat" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-network"
}

resource "google_compute_subnetwork" "nat" {
  for_each      = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  provider      = google-beta
  project       = google_project.project.project_id
  name          = "static-egress-ip-${each.value.service.name}-${each.value.region}"
  ip_cidr_range = "10.${index(local.subnet_indices, "${each.value.service.name}.${each.value.region}")}.0.0/16"
  network       = google_compute_network.nat.id
  region        = each.value.region
}

resource "google_compute_router" "nat" {
  for_each = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-router-${each.value.service.name}-${each.value.region}"
  network  = google_compute_network.nat.name
  region   = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].region
}

resource "google_compute_address" "nat" {
  for_each = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-addr-${each.value.service.name}-${each.value.region}"
  region   = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].region
}

resource "google_compute_router_nat" "nat" {
  for_each = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-nat-${each.value.service.name}-${each.value.region}"
  router   = google_compute_router.nat["${each.value.service.name}.${each.value.region}"].name
  region   = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.nat["${each.value.service.name}.${each.value.region}"].self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

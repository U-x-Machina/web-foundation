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
  for_each      = { for region in local.used_regions: "${region}" => region }
  provider      = google-beta
  project       = google_project.project.project_id
  name          = "vpc-egress-subnet-${each.value}"
  ip_cidr_range = "10.85.${index(local.used_regions, each.value) + 1}.0/24"
  network       = google_compute_network.nat[0].id
  region        = each.value
}

resource "google_compute_router" "default" {
  for_each = { for region in local.used_regions: "${region}" => region }
  provider = google-beta
  name     = "static-ip-router-${each.value}"
  network  = google_compute_network.nat[0].name
  region   = google_compute_subnetwork.nat[each.value].region
}

# resource "google_compute_address" "nat" {
#   for_each = { for entry in (var.gcp_use_nat_for_mongodb_atlas ? local.gcr_services : []): "${entry.service.name}.${entry.region}" => entry }
#   provider = google-beta
#   project  = google_project.project.project_id
#   name     = "static-ip-addr-${each.value.service.name}-${each.value.region}"
#   region   = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].region
# }

# resource "google_compute_router_nat" "nat" {
#   for_each = { for entry in (var.gcp_use_nat_for_mongodb_atlas ? local.gcr_services : []): "${entry.service.name}.${entry.region}" => entry }
#   provider = google-beta
#   project  = google_project.project.project_id
#   name     = "static-nat-${each.value.service.name}-${each.value.region}"
#   router   = google_compute_router.nat["${each.value.service.name}.${each.value.region}"].name
#   region   = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].region

#   nat_ip_allocate_option = "MANUAL_ONLY"
#   nat_ips                = [google_compute_address.nat["${each.value.service.name}.${each.value.region}"].self_link]

#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   subnetwork {
#     name                    = google_compute_subnetwork.nat["${each.value.service.name}.${each.value.region}"].id
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }
# }

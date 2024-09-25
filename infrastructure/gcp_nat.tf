resource "google_compute_network" "nat" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-network"
}

resource "google_compute_subnetwork" "nat" {
  provider      = google-beta
  project       = google_project.project.project_id
  name          = "static-ip"
  ip_cidr_range = "10.124.0.0/28"
  network       = google_compute_network.nat.id
}

resource "google_compute_router" "nat" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-router"
  network  = google_compute_network.nat.name
  region   = google_compute_subnetwork.nat.region
}

resource "google_compute_address" "nat" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-ip-addr"
  region   = google_compute_subnetwork.nat.region
}

resource "google_compute_router_nat" "nat" {
  provider = google-beta
  project  = google_project.project.project_id
  name     = "static-nat"
  router   = google_compute_router.nat.name
  region   = google_compute_subnetwork.nat.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.nat.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.nat.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
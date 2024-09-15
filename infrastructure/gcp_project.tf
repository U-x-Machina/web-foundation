provider "google" {
  region = var.gcp_region
}

resource "random_id" "id" {
  byte_length = 2
  prefix      = "${replace(lower(var.gcp_project_name), "/\\s+/", "-")}-"
  keepers = {
    ami_id = var.gcp_project_name
  }
}

resource "google_project" "project" {
  name            = var.gcp_project_name
  project_id      = random_id.id.hex
  billing_account = var.gcp_billing_account
  org_id          = var.gcp_org_id
}

resource "google_project_service" "services" {
  count   = length(var.google_project_services)
  project = google_project.project.project_id
  service = var.google_project_services[count.index]
  disable_on_destroy = false
}

output "gcp_region" {
  value = var.gcp_region
}

output "gcp_project_id" {
  value = google_project.project.project_id
}

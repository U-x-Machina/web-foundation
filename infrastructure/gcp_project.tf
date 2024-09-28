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

# Outputs
output "gcp_project_name" {
  value = google_project.project.name
}

output "gcp_project_id" {
  value = google_project.project.project_id
}

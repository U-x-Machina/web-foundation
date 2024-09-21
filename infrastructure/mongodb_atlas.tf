provider "mongodbatlas" {}

# Create a Project
resource "mongodbatlas_project" "project" {
  org_id    = var.mongodb_atlas_org_id
  name      = google_project.project.name
}

# Create a Cluster
resource "mongodbatlas_serverless_instance" "instance" {
  for_each     = var.environments
  project_id   = mongodbatlas_project.project[each.value.name].id
  name         = each.value.name
  provider_settings_backing_provider_name   = "GCP"
  provider_settings_provider_name           = "SERVERLESS"
  provider_settings_region_name             = var.mongodb_atlas_gcp_serverless_region
}
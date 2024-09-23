provider "mongodbatlas" {}

# Create a Project
resource "mongodbatlas_project" "project" {
  org_id    = var.mongodb_atlas_org_id
  name      = google_project.project.name
}

# Create clusters for each env
resource "mongodbatlas_serverless_instance" "instances" {
  for_each     = var.environments
  project_id   = mongodbatlas_project.project.id
  name         = each.value.name
  provider_settings_backing_provider_name   = "GCP"
  provider_settings_provider_name           = "SERVERLESS"
  provider_settings_region_name             = var.mongodb_atlas_gcp_serverless_region
}

# Create database users for each cluster
resource "random_password" "db_password" {
  for_each         = var.environments
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "mongodbatlas_database_user" "db_user" {
  for_each            = var.environments
  username            = "admin-${each.value.name}"
  password            = random_password.db_password[each.key].result
  project_id          = mongodbatlas_project.project.id
  auth_database_name  = "admin"

  roles {
    role_name     = "readWrite"
    database_name = mongodbatlas_serverless_instance.instances[each.key].name
  }
}

###
# Outputs
###
output "mongodb_connection_strings" {
  value = flatten([
    for instance in mongodbatlas_serverless_instance.instances : {
      "${instance.name}" = instance.connection_strings_standard_srv
    }
  ])
}

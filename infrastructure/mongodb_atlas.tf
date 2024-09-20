provider "mongodbatlas" {}

# Create a Project
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.mongodb_atlas_org_id
  name = google_project.project.name
}
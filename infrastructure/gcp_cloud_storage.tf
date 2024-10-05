locals {
  envs_with_local = merge(
    var.environments,
    {
      "local" = {
        "name" = "local"
      }
    }
  )
}

# Create GCS bucket for uploads
resource "google_storage_bucket" "payload_uploads" {
  for_each      = local.envs_with_local
  project       = google_project.project.project_id
  name          = "${google_project.project.project_id}-uploads-${each.value.name}"
  location      = var.gcs_location
  force_destroy = true
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"

  cors {
    origin          = local.ssl_domains
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Assign the publicAccess tag to GCS to enable public access
resource "google_tags_location_tag_binding" "gcs_binding" {
  for_each   = local.envs_with_local
  parent     = "//storage.googleapis.com/projects/_/buckets/${google_storage_bucket.payload_uploads[each.key].name}"
  tag_value  = var.gcs_public_tag_value
  location   = google_storage_bucket.payload_uploads[each.key].location
  depends_on = [google_project_service.services]
}

# Allow public access to the bucket
resource "google_storage_bucket_iam_member" "all_users" {
  for_each   = local.envs_with_local
  bucket     = google_storage_bucket.payload_uploads[each.key].name
  role       = "roles/storage.objectViewer"
  member     = "allUsers"
  depends_on = [google_tags_location_tag_binding.gcs_binding]
}

# Add default compute Service Account permissions to upload to GCS
resource "google_project_iam_binding" "default_compute_gcs" {
  project = google_project.project.project_id
  role    = "roles/storage.objectAdmin"
  members = [
    "serviceAccount:${data.google_service_account.default_compute.email}"
  ]
}
# Create GCS bucket for uploads
resource "google_storage_bucket" "payload_uploads" {
  project       = google_project.project.project_id
  name          = "${google_project.project.project_id}-uploads"
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
  parent    = "//storage.googleapis.com/projects/${google_project.project.number}/buckets/${google_storage_bucket.payload_uploads.name}"
  tag_value = var.gcs_public_tag_value
  location  = google_storage_bucket.payload_uploads.location
}
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
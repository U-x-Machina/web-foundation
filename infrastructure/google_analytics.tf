# Currently it is not possible to provision a Google Analytics account via Terraform. It needs to be created manually.
# This script only copies the tracking ID from Terraform variables to Github Actions variables

resource "github_actions_variable" "google_analytics_tracking_id" {
  repository    = data.github_repository.repo.name
  variable_name = "GOOGLE_ANALYTICS_TRACKING_ID"
  value         = var.google_analytics_tracking_id
}
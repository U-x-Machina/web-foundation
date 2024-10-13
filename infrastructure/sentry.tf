provider "sentry" {}

# Create a team
resource "sentry_team" "project" {
  organization = var.sentry_org

  name = google_project.project.project_id
  slug = google_project.project.project_id
}

# Create a project
resource "sentry_project" "default" {
  organization = var.sentry_org

  teams = [var.sentry_default_team, sentry_team.project.name]
  name  = google_project.project.project_id
  slug  = google_project.project.project_id

  platform    = "javascript-nextjs"
  resolve_age = 720

  default_rules = true
}
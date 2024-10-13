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

# Create a key
resource "sentry_key" "default" {
  organization = var.sentry_org

  project = sentry_project.default.slug
  name    = "SDK key"
}

# Save variables
resource "github_actions_variable" "sentry_org" {
  repository    = data.github_repository.repo.name
  variable_name = "SENTRY_ORG"
  value         = var.sentry_org
}

resource "github_actions_variable" "sentry_project" {
  repository    = data.github_repository.repo.name
  variable_name = "SENTRY_PROJECT"
  value         = sentry_project.default.name
}

resource "github_actions_variable" "sentry_dsn" {
  repository    = data.github_repository.repo.name
  variable_name = "SENTRY_DSN"
  value         = sentry_key.default.dsn_public
}
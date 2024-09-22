provider "github" {}

data "github_repository" "repo" {
  full_name = "${var.github_org}/${var.github_repo == "" ? terraform.workspace : var.github_repo}"
}

resource "github_repository_environment" "environments" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
}

# Save MongoDB Atlas connection strings to env vars
resource "github_actions_environment_variable" "mondogb_connection_strings" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = github_repository_environment.environments[each.value.name]
  variable_name = "MONGODB_CONNECTION_STRING"
  value         = mongodbatlas_serverless_instance.instances[each.value.name].connection_strings_standard_srv
}
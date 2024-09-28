provider "github" {
  owner = var.github_org
}

data "github_repository" "repo" {
  full_name = "${var.github_org}/${var.github_repo == "" ? terraform.workspace : var.github_repo}"
}

# Create build environments
resource "github_repository_environment" "build" {
  for_each    = var.environments
  environment = "build-${each.value.name}"
  repository  = data.github_repository.repo.name
}

# Create deployment environments
resource "github_repository_environment" "deployment" {
  for_each          = var.environments
  environment       = each.value.name
  repository        = data.github_repository.repo.name
  can_admins_bypass = false

  deployment_branch_policy {
    custom_branch_policies = true
    protected_branches     = false
  }

  reviewers {
    teams = each.value.reviewers.teams
    users = each.value.reviewers.users
  }
}

locals {
  envs = distinct(flatten([
    for env in var.environments : [
      for type in ["build-", ""] : {
        env         = env
        environment = type == "build-" ? github_repository_environment.build[env.name].environment : github_repository_environment.deployment[env.name].environment
      }
    ]
  ]))
}

# Generate Payload secrets for each env
resource "random_password" "payload_secret" {
  for_each = var.environments
  length   = 24
  special  = true
}

resource "random_password" "draft_secret" {
  for_each = var.environments
  length   = 16
  special  = false
  lower    = true
}

resource "random_password" "revalidation_key" {
  for_each = var.environments
  length   = 16
  special  = false
  lower    = true
}

###
# Repository variables
###
resource "github_actions_variable" "gcp_project_id" {
  repository    = data.github_repository.repo.name
  variable_name = "GCP_PROJECT_ID"
  value         = google_project.project.project_id
}

resource "github_actions_variable" "mongodb_atlas_project_id" {
  repository    = data.github_repository.repo.name
  variable_name = "MONGODB_ATLAS_PROJECT_ID"
  value         = mongodbatlas_project.project.id
}

resource "github_actions_variable" "mongodb_atlas_public_api_key" {
  repository    = data.github_repository.repo.name
  variable_name = "MONGODB_ATLAS_PUBLIC_API_KEY"
  value         = mongodbatlas_project_api_key.project_key.public_key
}

###
# Repository secrets
###
resource "github_actions_secret" "mongodb_atlas_private_api_key" {
  repository      = data.github_repository.repo.name
  secret_name     = "MONGODB_ATLAS_PRIVATE_API_KEY"
  plaintext_value = mongodbatlas_project_api_key.project_key.private_key
}

###
# Environment variables
###
resource "github_actions_environment_variable" "gcp_service" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "GCP_SERVICE"
  value         = each.value.env.name
}

resource "github_actions_environment_variable" "gcp_regions" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "GCP_REGIONS"
  value         = jsonencode(each.value.env.regions)
}

resource "github_actions_environment_variable" "payload_public_server_url" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "PAYLOAD_PUBLIC_SERVER_URL"
  value         = each.value.env.name == "production" && var.domain_prod != "" ? "https://${var.domain_prod}" : "https://${each.value.env.subdomain == "" ? "" : "${each.value.env.subdomain}."}${terraform.workspace}.${var.domain_dev}"
}

resource "github_actions_environment_variable" "next_public_server_url" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "NEXT_PUBLIC_SERVER_URL"
  value         = each.value.env.name == "production" && var.domain_prod != "" ? "https://${var.domain_prod}" : "https://${each.value.env.subdomain == "" ? "" : "${each.value.env.subdomain}."}${terraform.workspace}.${var.domain_dev}"
}

resource "github_actions_environment_variable" "next_public_is_live" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "NEXT_PUBLIC_IS_LIVE"
  value         = each.value.env.name == "production" ? true : false
}

resource "github_actions_environment_variable" "payload_public_draft_secret" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "PAYLOAD_PUBLIC_DRAFT_SECRET"
  value         = random_password.draft_secret[each.value.env.name].result
}

resource "github_actions_environment_variable" "next_private_draft_secret" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "NEXT_PRIVATE_DRAFT_SECRET"
  value         = random_password.draft_secret[each.value.env.name].result
}

resource "github_actions_environment_variable" "revalidation_key" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "REVALIDATION_KEY"
  value         = random_password.revalidation_key[each.value.env.name].result
}

resource "github_actions_environment_variable" "next_private_revalidation_key" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "NEXT_PRIVATE_REVALIDATION_KEY"
  value         = random_password.revalidation_key[each.value.env.name].result
}

###
# Environment secrets
###
resource "github_actions_environment_secret" "database_uri" {
  for_each          = { for entry in local.envs: "${entry.environment}" => entry }
  repository        = data.github_repository.repo.name
  environment       = each.value.environment
  secret_name       = "DATABASE_URI"
  plaintext_value   = "mongodb+srv://${mongodbatlas_database_user.db_user[each.value.env.name].username}:${mongodbatlas_database_user.db_user[each.value.env.name].password}@${split("mongodb+srv://", mongodbatlas_serverless_instance.instances[each.value.env.name].connection_strings_standard_srv)[1]}"
}

resource "github_actions_environment_secret" "payload_secret" {
  for_each          = { for entry in local.envs: "${entry.environment}" => entry }
  repository        = data.github_repository.repo.name
  environment       = each.value.environment
  secret_name       = "PAYLOAD_SECRET"
  plaintext_value   = random_password.payload_secret[each.value.env.name].result
}

###
# Outputs
###
output "draft_secret" {
  value = flatten([
    for env in var.environments : {
      "${env.name}" = random_password.draft_secret[env.name].result
    }
  ])
  sensitive = true
}

output "revalidation_key" {
  value = flatten([
    for env in var.environments : {
      "${env.name}" = random_password.revalidation_key[env.name].result
    }
  ])
  sensitive = true
}
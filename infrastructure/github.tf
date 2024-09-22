provider "github" {
  owner = var.github_org
}

data "github_repository" "repo" {
  full_name = "${var.github_org}/${var.github_repo == "" ? terraform.workspace : var.github_repo}"
}

# Generate Payload secrets for each env
resource "random_password" "payload_secret" {
  for_each         = var.environments
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "draft_secret" {
  for_each  = var.environments
  length    = 16
  special   = false
  lower     = true
}

resource "random_password" "revalidation_key" {
  for_each  = var.environments
  length    = 16
  special   = false
  lower     = true
}

# Generate Payload secrets for each env
resource "random_password" "payload" {
  for_each         = var.environments
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

###
# Environment variables
###
resource "github_actions_environment_variable" "payload_public_server_url" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "PAYLOAD_PUBLIC_SERVER_URL"
  value         = "https://${each.value.subdomain == "" ? "" : "${each.value.subdomain}."}${each.key == "production" && var.domain_prod != "" ? var.domain_prod : var.domain_dev}"
}

resource "github_actions_environment_variable" "next_public_server_url" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "NEXT_PUBLIC_SERVER_URL"
  value         = "https://${each.value.subdomain == "" ? "" : "${each.value.subdomain}."}${each.key == "production" && var.domain_prod != "" ? var.domain_prod : var.domain_dev}"
}

resource "github_actions_environment_variable" "next_public_is_live" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "NEXT_PUBLIC_IS_LIVE"
  value         = each.key == "production" ? true : false
}

resource "github_actions_environment_variable" "database_uri" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "DATABASE_URI"
  value         = mongodbatlas_serverless_instance.instances[each.key].connection_strings_standard_srv
}

resource "github_actions_environment_variable" "payload_public_draft_secret" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "PAYLOAD_PUBLIC_DRAFT_SECRET"
  value         = random_password.draft_secret[each.key].result
}

resource "github_actions_environment_variable" "next_private_draft_secret" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "NEXT_PRIVATE_DRAFT_SECRET"
  value         = random_password.draft_secret[each.key].result
}

resource "github_actions_environment_variable" "revalidation_key" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "REVALIDATION_KEY"
  value         = random_password.revalidation_key[each.key].result
}

resource "github_actions_environment_variable" "next_private_revalidation_key" {
  for_each      = var.environments
  repository    = data.github_repository.repo.name
  environment   = each.value.name
  variable_name = "NEXT_PRIVATE_REVALIDATION_KEY"
  value         = random_password.revalidation_key[each.key].result
}

###
# Environment secrets
###
resource "github_actions_environment_secret" "payload_secret" {
  for_each          = var.environments
  repository        = data.github_repository.repo.name
  environment       = each.value.name
  secret_name       = "PAYLOAD_SECRET"
  plaintext_value   = random_password.payload_secret[each.key].result
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
}

output "revalidation_key" {
  value = flatten([
    for env in var.environments : {
      "${env.name}" = random_password.revalidation_key[env.name].result
    }
  ])
}
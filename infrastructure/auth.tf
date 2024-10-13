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

# Generate basic auth passwords for each env
resource "random_password" "basic_auth" {
  for_each = var.environments
  length   = 16
  special  = true
}

# Generate CMS auth passwords for each env
resource "random_password" "admin_password" {
  for_each = var.environments
  length   = 24
  special  = true
}

resource "github_actions_environment_variable" "basic_auth_enabled" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "BASIC_AUTH_ENABLED"
  value         = var.basic_auth[each.value.env.name].enabled
}

resource "github_actions_environment_variable" "basic_auth_user" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "BASIC_AUTH_USER"
  value         = var.basic_auth[each.value.env.name].user
}

resource "github_actions_environment_secret" "basic_auth_password" {
  for_each          = { for entry in local.envs: "${entry.environment}" => entry }
  repository        = data.github_repository.repo.name
  environment       = each.value.environment
  secret_name       = "BASIC_AUTH_PASSWORD"
  plaintext_value   = random_password.basic_auth[each.value.env.name].result
}

resource "github_actions_environment_variable" "admin_email" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "ADMIN_EMAIL"
  value         = var.admin_auth[each.value.env.name].email
}

resource "github_actions_environment_secret" "admin_password" {
  for_each          = { for entry in local.envs: "${entry.environment}" => entry }
  repository        = data.github_repository.repo.name
  environment       = each.value.environment
  secret_name       = "ADMIN_PASSWORD"
  plaintext_value   = random_password.admin_password[each.value.env.name].result
}

# Outputs
output "basic_auth" {
  value = flatten([
    for env in var.environments : {
      "${env.name}" = {
        "enabled"  = var.basic_auth[env.name].enabled
        "user"     = var.basic_auth[env.name].user
        "password" = random_password.basic_auth[env.name].result
      }
    }
  ])
  sensitive = true
}

output "cms_auth" {
  value = flatten([
    for env in var.environments : {
      "${env.name}" = {
        "email"    = var.admin_auth[env.name].email
        "password" = random_password.admin_password[env.name].result
      }
    }
  ])
  sensitive = true
}
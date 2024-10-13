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

resource "github_repository_environment_deployment_policy" "development" {
  repository        = data.github_repository.repo.name
  environment       = github_repository_environment.deployment["development"].environment
  branch_pattern    = "develop"
}

resource "github_repository_environment_deployment_policy" "test" {
  repository        = data.github_repository.repo.name
  environment       = github_repository_environment.deployment["test"].environment
  branch_pattern    = "release/*"
}

resource "github_repository_environment_deployment_policy" "staging" {
  repository        = data.github_repository.repo.name
  environment       = github_repository_environment.deployment["staging"].environment
  branch_pattern    = "main"
}

resource "github_repository_environment_deployment_policy" "production" {
  repository        = data.github_repository.repo.name
  environment       = github_repository_environment.deployment["production"].environment
  branch_pattern    = "main"
}

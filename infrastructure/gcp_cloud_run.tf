locals {
  # A flat array of all services, including regional "copies"
  gcr_services = distinct(flatten([
    for env in var.environments : [
      for region in env.regions : {
        service = env
        region  = region
      }
    ]
  ]))

  envs = distinct(flatten([
    for env in var.environments : [
      for type in ["build-", ""] : {
        env         = env
        environment = type == "build-" ? github_repository_environment.build[env.name].environment : github_repository_environment.deployment[env.name].environment
      }
    ]
  ]))
}

# Create Google Cloud Run instances according to the config in vars
resource "google_cloud_run_v2_service" "services" {
  for_each            = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  project             = google_project.project.project_id
  name                = "${each.value.service.name}-${each.value.region}"
  location            = each.value.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources {
        limits = {
          cpu    = each.value.service.cpu
          memory = each.value.service.memory
        }
        cpu_idle          = each.value.service.cpu_idle
        startup_cpu_boost = each.value.service.cpu_boost
      }
    }
    scaling {
      min_instance_count = each.value.service.min_instances
      max_instance_count = each.value.service.max_instances
    }
    dynamic "vpc_access" {
      for_each = var.gcp_use_nat_for_mongodb_atlas ? [1] : []

      content {
        network_interfaces {
          network    = google_compute_network.nat[0].id
          subnetwork = google_compute_subnetwork.nat[each.value.region].id
        }
        egress       = "ALL_TRAFFIC"
      }
    }
    max_instance_request_concurrency = each.value.service.concurrency
  }

  depends_on = [google_project_service.services]

  lifecycle {
    ignore_changes = [template[0].containers[0].image]
  }
}

# Assign the allUsersIngress tag to Cloud Run Services to enable public access
resource "google_tags_location_tag_binding" "binding" {
  for_each  = { for entry in local.gcr_services: "${entry.service.name}.${entry.region}" => entry }
  parent    = "//run.googleapis.com/projects/${google_project.project.number}/locations/${each.value.region}/services/${google_cloud_run_v2_service.services["${each.value.service.name}.${each.value.region}"].name}"
  tag_value = var.gcp_all_users_ingress_tag_value_id
  location  = each.value.region
}

# Set up public access to the Google Cloud Run services
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
  depends_on = [google_cloud_run_v2_service.services]
}

# Create a delay before applying the IAM policy, otherwise it will fail
resource "time_sleep" "gcr_iam_delay" {
  depends_on = [
    google_tags_location_tag_binding.binding,
    google_cloud_run_v2_service.services
  ]

  create_duration = "120s"
}

# Apply the IAM policy, at a delay
resource "google_cloud_run_service_iam_policy" "noauth" {
  for_each    = google_cloud_run_v2_service.services
  location    = each.value.location
  project     = each.value.project
  service     = each.value.name
  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on  = [time_sleep.gcr_iam_delay]
}

# Add required permissions to default Compute Service Account for future deployments
data "google_service_account" "default_compute" {
  account_id = "${google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_cloud_run_v2_service.services]
}

resource "google_service_account_iam_binding" "default_compute" {
  service_account_id = data.google_service_account.default_compute.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.github_actions_deployer_service_account}",
  ]

  depends_on = [
    google_project_service.services,
    google_cloud_run_v2_service.services
  ]
}

resource "google_artifact_registry_repository" "builds_repository" {
  project       = google_project.project.project_id
  location      = var.gar_location
  repository_id = var.gar_repository
  description   = "Builds repository"
  format        = "DOCKER"
  depends_on = [google_project_service.services]
}

# Save variables
resource "github_actions_environment_variable" "environment" {
  for_each      = { for entry in local.envs: "${entry.environment}" => entry }
  repository    = data.github_repository.repo.name
  environment   = each.value.environment
  variable_name = "ENVIRONMENT"
  value         = each.value.env.name
}

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

resource "github_actions_environment_secret" "payload_secret" {
  for_each          = { for entry in local.envs: "${entry.environment}" => entry }
  repository        = data.github_repository.repo.name
  environment       = each.value.environment
  secret_name       = "PAYLOAD_SECRET"
  plaintext_value   = random_password.payload_secret[each.value.env.name].result
}
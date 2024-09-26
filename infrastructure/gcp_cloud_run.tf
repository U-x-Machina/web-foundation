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
      }
    }
    max_instance_request_concurrency = each.value.service.concurrency
  }

  depends_on = [google_project_service.services]
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

  create_duration = "30s"
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
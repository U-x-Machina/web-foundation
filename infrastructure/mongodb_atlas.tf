provider "mongodbatlas" {}

# Create a Project
resource "mongodbatlas_project" "project" {
  org_id    = var.mongodb_atlas_org_id
  name      = google_project.project.project_id
}

# Create clusters for each env
resource "mongodbatlas_serverless_instance" "instances" {
  for_each     = var.environments
  project_id   = mongodbatlas_project.project.id
  name         = each.value.name
  provider_settings_backing_provider_name   = "GCP"
  provider_settings_provider_name           = "SERVERLESS"
  provider_settings_region_name             = var.mongodb_atlas_gcp_serverless_region
}

# Create database users for each cluster
resource "random_password" "db_password" {
  for_each         = var.environments
  length           = 24
  special          = false
}

resource "mongodbatlas_database_user" "db_user" {
  for_each            = var.environments
  username            = "admin-${each.value.name}"
  password            = random_password.db_password[each.key].result
  project_id          = mongodbatlas_project.project.id
  auth_database_name  = "admin"

  roles {
    role_name     = "dbAdminAnyDatabase"
    database_name = "admin"
  }

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  scopes {
    name = mongodbatlas_serverless_instance.instances[each.key].name
    type = "CLUSTER"
  }
}

# Create API key for the project (needed by Github Actions to whitelist its IP)
resource "mongodbatlas_project_api_key" "project_key" {
  description   = "Github Actions API key"
  project_assignment {
    project_id = mongodbatlas_project.project.id
    role_names = ["GROUP_OWNER"]
  }
}

# If using NAT, whitelist the reserved IP addresses
resource "mongodbatlas_project_ip_access_list" "nat" {
  for_each   = { for region in (var.gcp_use_nat_for_mongodb_atlas ? local.used_regions : []): "${region}" => region }
  project_id = mongodbatlas_project.project.id
  cidr_block = "${google_compute_address.nat[each.value].address}/32"
  comment    = "Allow access via Google Cloud NAT for ${each.value} region"
}

# If not using NAT, whitelist all IP addresses to be able to connect
resource "mongodbatlas_project_ip_access_list" "all_access" {
  count      = var.gcp_use_nat_for_mongodb_atlas ? 0 : 1
  project_id = mongodbatlas_project.project.id
  cidr_block = "0.0.0.0/0"
  comment    = "Allow public access due to GCP NAT not being used"
}

# Save variables
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

resource "github_actions_secret" "mongodb_atlas_private_api_key" {
  repository      = data.github_repository.repo.name
  secret_name     = "MONGODB_ATLAS_PRIVATE_API_KEY"
  plaintext_value = mongodbatlas_project_api_key.project_key.private_key
}

resource "github_actions_environment_secret" "database_uri" {
  for_each          = { for entry in local.envs: "${entry.environment}" => entry }
  repository        = data.github_repository.repo.name
  environment       = each.value.environment
  secret_name       = "DATABASE_URI"
  plaintext_value   = "mongodb+srv://${mongodbatlas_database_user.db_user[each.value.env.name].username}:${mongodbatlas_database_user.db_user[each.value.env.name].password}@${split("mongodb+srv://", mongodbatlas_serverless_instance.instances[each.value.env.name].connection_strings_standard_srv)[1]}"
}
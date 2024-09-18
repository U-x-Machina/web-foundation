variable "terraform_state_id" {
  type = string
  description = "Globally unique identifier of Terraform State"
  default = "1"
}

variable "gcp_region" {
  type = string
  description = "Main Google Cloud Project region"
  default = "europe-west1"
}

variable "gcp_state_bucket_id" {
  type = string
  description = "Google Cloud Storage bucket ID for Terraform state storage"
}

variable "gcp_folder_id" {
  type = string
  description = "Google Cloud folder ID for the project to be created within"
}

variable "gcp_billing_account" {
  type = string
  description = "Google Cloud Billing Account ID to be associated with the created project"
}

variable "google_project_services" {
  type = list(string)
  description = "Google Project Services to be enabled"
  default = [
    "run.googleapis.com",
    "compute.googleapis.com"
  ]
}

variable "environments" {
  description = "Environments configuration"
  default = {
    "development" = {
      "name"          = "development",
      "regions"       = ["europe-west1"],
      "cpu"           = 1,
      "memory"        = "512Mi",
      "cpu_boost"     = false,
      "cpu_idle"      = false,
      "concurrency"   = 80,
      "min_instances" = 0,
      "max_instances" = 1
    }
    "test" = {
      "name"          = "test",
      "regions"       = ["europe-west1"],
      "cpu"           = 1,
      "memory"        = "512Mi",
      "cpu_boost"     = false,
      "cpu_idle"      = false,
      "concurrency"   = 80,
      "min_instances" = 0,
      "max_instances" = 2
    }
    "staging" = {
      "name"          = "staging",
      "regions"       = ["europe-west1"],
      "cpu"           = 1,
      "memory"        = "1Gi",
      "cpu_boost"     = true,
      "cpu_idle"      = false,
      "concurrency"   = 80,
      "min_instances" = 0,
      "max_instances" = 3
    }
    "production" = {
      "name"          = "production",
      "regions"       = ["us-central1", "europe-west1", "asia-east1"]
      "cpu"           = 1,
      "memory"        = "1Gi",
      "cpu_boost"     = true,
      "cpu_idle"      = false,
      "concurrency"   = 80,
      "min_instances" = 0,
      "max_instances" = 10
    }
  }
}
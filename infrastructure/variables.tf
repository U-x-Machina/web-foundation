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
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "vpcaccess.googleapis.com"
  ]
}

variable "gcp_all_users_ingress_tag_value_id" {
  type = string
  description = "Google Cloud Tag value ID enabling allUsers ingress on Cloud Run services"
}

variable "environments" {
  description = "Environments configuration"
  default = {
    "development" = {
      "name"            = "development",
      "subdomain"       = "development",
      "regions"         = ["europe-west1"],
      "cpu"             = 1,
      "memory"          = "512Mi",
      "cpu_boost"       = false,
      "cpu_idle"        = false,
      "concurrency"     = 80,
      "min_instances"   = 0,
      "max_instances"   = 1,
      "enable_cdn"      = false,
      "reviewers"       = {
                            "teams": [],
                            "users": []
                          }
    }
    "test" = {
      "name"            = "test",
      "subdomain"       = "test",
      "regions"         = ["europe-west1"],
      "cpu"             = 1,
      "memory"          = "512Mi",
      "cpu_boost"       = false,
      "cpu_idle"        = false,
      "concurrency"     = 80,
      "min_instances"   = 0,
      "max_instances"   = 2,
      "enable_cdn"      = false,
      "reviewers"       = {
                            "teams": [11043647],
                            "users": []
                          }
    }
    "staging" = {
      "name"            = "staging",
      "subdomain"       = "staging",
      "regions"         = ["europe-west1"],
      "cpu"             = 1,
      "memory"          = "1Gi",
      "cpu_boost"       = true,
      "cpu_idle"        = false,
      "concurrency"     = 80,
      "min_instances"   = 0,
      "max_instances"   = 3,
      "enable_cdn"      = true,
      "reviewers"       = {
                            "teams": [11043647],
                            "users": []
                          }
    }
    "production" = {
      "name"            = "production",
      "subdomain"       = "",
      "regions"         = ["us-central1", "europe-west1", "asia-east1"]
      "cpu"             = 1,
      "memory"          = "1Gi",
      "cpu_boost"       = true,
      "cpu_idle"        = false,
      "concurrency"     = 80,
      "min_instances"   = 0,
      "max_instances"   = 10,
      "enable_cdn"      = true,
      "reviewers"       = {
                            "teams": [11043647],
                            "users": []
                          }
    }
  }
}

variable "basic_auth" {
  description = "Basic Auth configuration"
  default = {
    "development" = {
      "enabled" = true,
      "user"    = "uxm"
    }
    "test" = {
      "enabled" = true,
      "user"    = "uxm"
    }
    "staging" = {
      "enabled" = true,
      "user"    = "uxm"
    }
    "production" = {
      "enabled" = true,
      "user"    = "uxm"
    }
  }
}

variable "admin_auth" {
  description     = "Payload CMS admin auth configuration"
  default = {
    "development" = {
      "email"     = "admin@uxmachina.co"
    }
    "test"        = {
      "email"     = "admin@uxmachina.co"
    }
    "staging"     = {
      "email"     = "admin@uxmachina.co"
    }
    "production"  = {
      "email"     = "admin@uxmachina.co"
    }
  }
}

variable "gar_location" {
  type        = string
  description = "Google Artifact Registry location"
  default     = "europe"
}

variable "gar_repository" {
  type        = string
  description = "Google Artifact Registry repository name"
  default     = "builds"
}

variable "gcs_location" {
  type        = string
  description = "Google Cloud Storage location"
  default     = "EU"
}

variable "default_environment" {
  type        = string
  description = "Default environment to be used for Compute URL Map in case no host / URL is matched"
  default     = "production"
}

variable "domain_dev" {
  type        = string
  description = "Development domain to be used for all environments"
}

variable "domain_prod" {
  type        = string
  description = "Production domain"
  default     = ""
}

variable "mongodb_atlas_org_id" {
  type        = string
  description = "MongoDB Atlas Organization ID"
}

variable "mongodb_atlas_gcp_serverless_region" {
  type        = string
  description = "MongoDB Atlas Serverless Instance region name for the GCP provider"
}

variable "gcp_use_nat_for_mongodb_atlas" {
  type        = bool
  description = "Whether to use NAT and IP whitelisting for MongoDB Atlas. If false, all IPs (0.0.0.0) will be allowed (not recommended for production)."
  default     = true
}

variable "github_org" {
  type        = string
  description = "Your GitHub organisation or user owning the connected repository in slug format"
}

variable "github_repo" {
  type        = string
  description = "The name of the connected repository in slug format. If empty, Terraform workspace name will be used as an attempt."
  default     = ""
}

variable "github_actions_deployer_service_account" {
  type        = string
  description = "Email of the Google Cloud Platform Service Account used by Workload Identity Federation to deploy from Github Actions"
}
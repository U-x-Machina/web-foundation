variable "terraform_state_id" {
  type = string
  description = "Globally unique identifier of Terraform State"
  default = "1"
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

variable "gcp_region" {
  type = string
  description = "Each Cloud Run service or job resides in a region. Customer data associated with the service or job is stored in the selected region. Traffic can be served from multiple regions by configuring external HTTP(S) Load Balancing."
  default = "europe-west1"
}

variable "google_project_services" {
  type = list(string)
  description = "Google Project Services to be enabled"
  default = [
    "run.googleapis.com"
  ]
}

variable "environments" {
  description = "Environments configuration"
  default = [
    {
      "name" = "development",
      "traffic_split" = 0,
      "min_total_fe_instances" = 0,
      "max_total_fe_instances" = 1
    },
    {
      "name" = "test",
      "traffic_split" = 0,
      "min_total_fe_instances" = 0,
      "max_total_fe_instances" = 2
    },
    {
      "name" = "staging",
      "traffic_split" = 0,
      "min_total_fe_instances" = 0,
      "max_total_fe_instances" = 2
    },
    {
      "name" = "production",
      "traffic_split" = 1,
      "min_total_fe_instances" = 0,
      "max_total_fe_instances" = 50
    }
  ]
}
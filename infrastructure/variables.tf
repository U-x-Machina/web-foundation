variable "terraform_state_id" {
  type = string
  description = "Globally unique identifier of Terraform State"
  default = "1"
}

variable "gcp_org_id" {
  type = string
  description = "Google Cloud Organization ID for the project to be created within"
}

variable "gcp_billing_account" {
  type = string
  description = "Google Cloud Billing Account ID to be associated with the created project"
}

variable "gcp_project_name" {
  type = string
  description = "Name of the Google Cloud Platform Project to be created."
  validation {
    condition     = length(var.gcp_project_name) > 0 && length(var.gcp_project_name) < 26
    error_message = "Project name needs to be max. 25 characters long. There is a 5-character suffix being added automatically and GCP project names need to be at max. 30 chars long."
  }
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

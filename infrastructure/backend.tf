terraform {
  backend "gcs" {
    bucket = var.gcp_state_bucket_id
    prefix = "${terraform.project}/${terraform.workspace}/${var.terraform_state_id}"
  }
}

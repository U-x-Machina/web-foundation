terraform {
  backend "gcs" {
    bucket = "uxmachina-terraform-state"
    prefix = "${terraform.project}/${terraform.workspace}/${var.terraform_state_id}"
  }
}

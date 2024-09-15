provider "google" {
 alias = "impersonation"
 region = var.gcp_region
 scopes = [
   "https://www.googleapis.com/auth/cloud-platform",
   "https://www.googleapis.com/auth/userinfo.email",
 ]
}

data "google_service_account_access_token" "default" {
 provider               	= google.impersonation
 target_service_account 	= var.terraform_service_account
 scopes                 	= ["userinfo-email", "cloud-platform"]
 lifetime               	= "1200s"
}

provider "google" {
 access_token       = data.google_service_account_access_token.default.access_token
 request_timeout    = "60s"
}
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.20.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    sentry = {
      source = "jianyuan/sentry"
    }
  }
  required_version = ">= 1.9"
}

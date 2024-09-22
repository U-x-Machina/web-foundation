provider "git" {}
provider "github" {}

data "git_remote" "remote" {
  directory = "../"
  name      = "origin"
}
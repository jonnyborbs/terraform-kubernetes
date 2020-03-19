terraform {
  backend "remote" {
    organization = "runtriggers-k8s-demo"

    workspaces {
      name = "cluster"
    }
  }
}

provider "google" {
  version = "3.10.0"
  project = var.google_project
  region  = var.location.gcp
}

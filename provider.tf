terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.16.0"
    }
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.44"
    }
  }
}


provider "volterra" {
  api_p12_file = var.api_p12_file
  url          = var.api_url
}

provider "google" {
  project = var.project_id
  region  = var.region
}


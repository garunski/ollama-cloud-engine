terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project  # Uses gcloud default project when null
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project  # Uses gcloud default project when null
  region  = var.gcp_region
}

# Ensure required APIs are enabled
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}



// Placeholder root for GCP; to be implemented incrementally per CLOUD_SPLIT_PLAN.md

terraform {
  required_version = ">= 1.6.0"
}

locals {
  project = var.gcp_project
  region  = var.gcp_region
}

// TODO: networking, firewall, compute, disks, logging, outputs



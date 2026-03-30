
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = "pgsql-backup-dem0"
    prefix = "environments/prod"
  }
}


provider "google" {
  project = var.gcp_project_id 
  
}
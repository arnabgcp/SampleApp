
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.8.0"
    }
  }

  backend "gcs" {
    bucket = "pgsql-backup-dem0"
    prefix = "environments/prod"
  }
}


provider "google" {
  project = var.project 
  
}
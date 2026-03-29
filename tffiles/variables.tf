variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to deploy resources into."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region for the resources."
  default     = "me-central1"
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone for the GCE instance."
  default     = "me-central1-a"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network."
  default     = "app-vpc"
}

variable "git_repo_url" {
  type        = string
  description = "The URL of the Git repository to clone."
  # Example: "https://github.com/your-username/your-repo.git"
}

variable "db_user" {
  type        = string
  description = "The database user."
  sensitive   = true
}

variable "db_pass" {
  type        = string
  description = "The database password."
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "The database name."
}

variable "instance_connection_name" {
  type        = string
  description = "The Cloud SQL instance connection name."
}
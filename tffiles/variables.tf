variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to deploy resources into."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region for the resources."
  default     = "us-central1"
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone for the GCE instance."
  default     = "us-central1-a"
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
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


variable "instance_connection_name" {
  type        = string
  description = "The Cloud SQL instance connection name."
}

variable "instance" {
  type        = string
  description = "The Cloud SQL instance name."
  default     = "lib-instance"
}
variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to deploy resources into."
  default     = "geoshield-demo"
}

variable "gcp_region" {
  type        = string
  description = "The GCP region for the resources."
  default     = "asia-east1"
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone for the GCE instance."
  default     = "asia-east1-a"
}

variable "network_name" {
  type        = string
  description = "The name of the VPC network."
  default     = "app-vpc"
}

variable "instance" {
  type        = string
  description = "The Cloud SQL instance name."
  default     = "lib-instance"
}

resource "google_sql_database_instance" "mtr" {
  name             = var.instance
  database_version = "POSTGRES_17"
  region           = var.gcp_region

  # Removed quotes from the dependency reference
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"
    
    # tier and edition must be top-level within settings
    tier    = "db-custom-2-7680"
    edition = "ENTERPRISE"

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id
    }
  }

deletion_protection=false
}
  # NOTE: Explicitly set deletion_protection=false to allow Terraform to destroy the instance
   



resource "random_string" "rs" {
  length = 10
}

resource "google_sql_user" "users" {
  name     = "postgres"
  instance = google_sql_database_instance.mtr.name
  
  password = random_string.rs.id
}



# Grant the Cloud SQL instance's service account the Storage Object Admin role on the bucket
resource "google_storage_bucket_iam_member" "bucket_iam_binding" {
  bucket = "pgsql-backup-dem0"
  role   = "roles/storage.objectAdmin" 
  
  # Fixed the interpolation syntax: ${ ... }
  member = "serviceAccount:${google_sql_database_instance.mtr.service_account_email_address}" 
  
  # Note: depends_on is technically redundant here because 
  # referencing the .service_account_email_address attribute 
  # already creates an implicit dependency.
}

resource "google_sql_database" "database" {
  name     = "library_db"
  instance = google_sql_database_instance.mtr.name

provisioner "local-exec" {

command= "gcloud config set project ${var.gcp_project_id};gcloud sql import sql ${var.instance} gs://pgsql-backup-dem0/library.sql --database=library_db --user=postgres --quiet"

}

}

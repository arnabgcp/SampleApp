
resource "google_sql_database_instance" "mtr" {
  name             = var.instance
  database_version = "POSTGRES_15"
  region           = var.region

depends_on = ["google_service_networking_connection.private_vpc_connection"]
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.id
      
    }

  # NOTE: Explicitly set deletion_protection=false to allow Terraform to destroy the instance
  deletion_protection = false 
}


resource "random_string" "rs" {
  length = 10
}

resource "google_sql_user" "users" {
  name     = "postgres"
  instance = google_sql_database_instance.mtr.name
  
  password = random_string.rs.id
}

resource "google_sql_database" "database" {
  name     = "library_db"
  instance = google_sql_database_instance.mtr.name

provisioner "local-exec" {

command= "gcloud config set project ${var.project};gcloud sql import sql ${var.instance} gs://pgsql-backup-dem0/library.sql --database=library_db --user=postgres --quiet"

}

}

# Renamed from app_server to make its purpose clearer
resource "google_compute_instance" "app_server" {
  name         = "flask-app-server"
  machine_type = "e2-medium"
  zone         = var.gcp_zone
  tags         = ["web-app"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 100
    }
  }

  allow_stopping_for_update = true

  network_interface {
    # Connect the instance to our custom subnetwork
    subnetwork = google_compute_subnetwork.app_subnet.id
  }


  // The service account needs "Cloud SQL Client" role to connect to the database.
  // Ensure the default compute service account has this role in IAM.
  service_account {
    email  = "default"
    scopes = ["cloud-platform"]
  }

  // This startup script runs once when the VM is created.
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e
    
    # Install dependencies
    apt-get update
    apt-get install -y git python3-pip python3-venv

    # Clone the application repository
    git clone https://github.com/arnabgcp/SampleApp.git /app
    cd /app

    # Create the .env file from Terraform variables
    mkdir -p instance
    cat <<EOF > instance/.env
DB_USER="${google_sql_user.users.password}"
DB_PASS="${google_sql_user.users.id}"
DB_NAME="${google_sql_database.database.name}"
INSTANCE_CONNECTION_NAME="${google_sql_database_instance.mtr.connection_name}"
EOF
 
  lifecycle {
    create_before_destroy = true
  }


    # Make the run script executable and run it
    chmod +x run.sh
    ./run.sh
  EOT
}
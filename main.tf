terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

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

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
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
    git clone "${var.git_repo_url}" /app
    cd /app

    # Create the .env file from Terraform variables
    mkdir -p instance
    cat <<EOF > instance/.env
DB_USER="${var.db_user}"
DB_PASS="${var.db_pass}"
DB_NAME="${var.db_name}"
INSTANCE_CONNECTION_NAME="${var.instance_connection_name}"
EOF

    # Make the run script executable and run it
    chmod +x run.sh
    ./run.sh
  EOT
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-app-port-8081"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }
  source_ranges = ["0.0.0.0/0"] # Allows traffic from any IP
  target_tags   = ["web-app"]   # Applies rule to instances with this tag
}
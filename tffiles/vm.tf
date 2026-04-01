
data "google_compute_default_service_account" "default" {}

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
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  // This startup script runs once when the VM is created.
  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -e

    # 1. Install dependencies
    # We use -qq to keep the logs clean and non-interactive
    apt-get update
    apt-get install -y git python3-pip python3-venv

    # 2. Clone the application repository
    # If the directory already exists (on reboot), we skip cloning
    if [ ! -d "/app" ]; then
      git clone https://github.com/arnabgcp/SampleApp.git /app
    fi
    cd /app

    # 3. Create the .env file from Terraform variables
    mkdir -p instance
    cat <<EOF > /app/instance/.env
DB_USER="${google_sql_user.users.name}"
DB_PASS="${google_sql_user.users.password}"
DB_NAME="${google_sql_database.database.name}"
INSTANCE_CONNECTION_NAME="${google_sql_database_instance.mtr.connection_name}"
EOF

    # 4. Set permissions
    chmod +x /app/run.sh

    # 5. Create the systemd service unit
    # This ensures the app runs continuously and restarts on failure/reboot
    cat <<EOF > /etc/systemd/system/sample-app.service
[Unit]
Description=GCP Sample Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/app
# We use EnvironmentFile to load the variables created above
EnvironmentFile=/app/instance/.env
ExecStart=/bin/bash /app/run.sh
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # 6. Enable and start the service
    systemctl daemon-reload
    systemctl enable sample-app.service
    systemctl start sample-app.service

  EOT


   lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
    create_before_destroy = true
  }
}

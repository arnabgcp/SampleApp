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

# Create a custom VPC network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Create a subnet in the specified region
resource "google_compute_subnetwork" "app_subnet" {
  name          = "app-subnet"
  ip_cidr_range = "10.10.10.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
}

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

# --- Load Balancer Components ---

# Create an unmanaged instance group for the VM
resource "google_compute_instance_group" "app_instance_group" {
  name      = "app-instance-group"
  zone      = var.gcp_zone
  network   = google_compute_network.vpc_network.id
  instances = [google_compute_instance.app_server.id]
}

# Create a health check for the load balancer
resource "google_compute_health_check" "http_health_check" {
  name                = "app-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = "8081"
    request_path = "/" # Assumes the root path returns a 200 OK
  }
}

# Create the backend service
resource "google_compute_backend_service" "app_backend_service" {
  name                  = "app-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.http_health_check.id]

  backend {
    group = google_compute_instance_group.app_instance_group.id
  }
}

# Create the URL map to route all traffic to the backend service
resource "google_compute_url_map" "url_map" {
  name            = "app-url-map"
  default_service = google_compute_backend_service.app_backend_service.id
}

# Create the target HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "app-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

# Create the global forwarding rule (the frontend of the LB)
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "app-forwarding-rule"
  target                = google_compute_target_http_proxy.http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}

# Update firewall to allow LB and health checker traffic
resource "google_compute_firewall" "allow_lb_health_check" {
  name    = "allow-lb-and-health-check"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }
  # Google Cloud IP ranges for health checks and load balancers
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["web-app"]
}

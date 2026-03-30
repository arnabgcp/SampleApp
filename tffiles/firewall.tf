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


resource "google_compute_firewall" "allow-ssh-access" {
  name    = "allow-ssh-access"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # Google Cloud IP ranges for health checks and load balancers
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-app"]
}
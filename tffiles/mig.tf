resource "google_compute_instance_group" "app_instance_group" {
  name      = "app-instance-group"
  zone      = var.gcp_zone
  network   = google_compute_network.vpc_network.id
  instances = [google_compute_instance.app_server.id]

  named_port {
    name = "http-custom" # The port name referenced in the backend service
    port = 8081          # The actual custom port running on the instances
  }
}
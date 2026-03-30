# Create the backend service
resource "google_compute_backend_service" "app_backend_service" {
  name                  = "app-backend-service"
  protocol              = "HTTP"
  port_name             = "http-custom"
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
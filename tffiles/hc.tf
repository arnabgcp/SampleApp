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
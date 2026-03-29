output "load_balancer_ip" {
  description = "The public IP address of the external load balancer."
  value       = google_compute_global_forwarding_rule.forwarding_rule.ip_address
}

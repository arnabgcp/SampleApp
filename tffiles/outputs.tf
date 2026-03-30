output "lb" {
  
  value=google_compute_global_forwarding_rule.forwarding_rule.ip_address
}

output "sqlip" {

value = google_sql_database_instance.mtr.ip_address.0.ip_address

}
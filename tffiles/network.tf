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


resource "google_compute_global_address" "private_ip_address" {
    provider="google"
    name          = "${google_compute_network.vpc_network.name}"
    purpose       = "VPC_PEERING"
    address_type = "INTERNAL"
    prefix_length = 16
    network       = "${google_compute_network.vpc_network.name}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
    provider="google"
    network       = "${google_compute_network.vpc_network.self_link}"
    service       = "servicenetworking.googleapis.com"
    reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}
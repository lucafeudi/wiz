output "network_id" {
  description = "ID of the custom VPC network."
  value       = google_compute_network.custom_vpc.id
}

output "gke_subnet_id" {
  description = "ID of the subnet used by the GKE cluster."
  value       = google_compute_subnetwork.gke_subnet.id
}

output "db_subnet_id" {
  description = "ID of the subnet used by the database VM."
  value       = google_compute_subnetwork.db_subnet.id
}
resource "google_container_cluster" "primary" {
  name                     = var.cluster_name
  location                 = var.region
  network                  = var.network
  subnetwork               = var.subnetwork
  networking_mode          = "VPC_NATIVE"
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
  node_locations           = ["${var.region}-a"]

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_secondary_range
    services_secondary_range_name = var.services_secondary_range
  }
}

resource "google_container_node_pool" "primary" {
  name           = "demo-pool"
  location       = var.region
  cluster        = google_container_cluster.primary.name
  node_count     = 1
  node_locations = ["${var.region}-a"]

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "wiz-vpc"
  auto_create_subnetworks = false
}

# Public Subnet (for VM & NAT/Gateway if needed)
resource "google_compute_subnetwork" "public_subnet" {
  name          = "wiz-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Private Subnet (for GKE cluster)
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "wiz-private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.48.0.0/14"
  }
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.52.0.0/20"
  }
}

# Firewall: Allow SSH to public subnet (VM) from anywhere (0.0.0.0/0)
resource "google_compute_firewall" "allow_ssh" {
  name    = "wiz-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mongodb-vm"]
}

# Firewall: Allow GKE nodes to access MongoDB VM on port 27017
resource "google_compute_firewall" "allow_gke_to_mongo" {
  name    = "wiz-allow-gke-to-mongo"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
# Too wide source range
  source_ranges = ["10.0.2.0/24", "10.48.0.0/14"]
  target_tags   = ["mongodb-vm"]
}

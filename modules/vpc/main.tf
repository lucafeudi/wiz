resource "google_compute_network" "custom_vpc" {
  name                    = "wiz-exercise-vpc"
  auto_create_subnets     = false
  routing_mode            = "REGIONAL"
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  
  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.16.0.0/12"
  }
  
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.32.0.0/16"
  }
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.custom_vpc.id
}

# Cloud NAT is critical to allow private GKE nodes/pods to pull images/packages
resource "google_compute_router" "router" {
  name    = "wiz-nat-router"
  region  = var.region
  network = google_compute_network.custom_vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "wiz-nat-config"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall rule: Expose SSH on DB VM publicly (To generate high-severity Wiz finding)
resource "google_compute_firewall" "public_ssh" {
  name    = "allow-public-ssh"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public-ssh-vm"]
}

# Firewall rule: MongoDB restricted strictly to GKE cluster subnets
resource "google_compute_firewall" "gke_to_mongodb" {
  name    = "allow-gke-to-mongodb"
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = ["10.0.1.0/24", "10.16.0.0/12"]
  target_tags   = ["mongodb-tier"]
}

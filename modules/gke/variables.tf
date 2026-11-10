variable "cluster_name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the GKE cluster."
  type        = string
}

variable "network" {
  description = "VPC network ID for the GKE cluster."
  type        = string
}

variable "subnetwork" {
  description = "Subnet ID for the GKE cluster."
  type        = string
}

variable "pods_secondary_range" {
  description = "Name of the subnet secondary range used for GKE pods."
  type        = string
}

variable "services_secondary_range" {
  description = "Name of the subnet secondary range used for GKE services."
  type        = string
}
variable "project_id" {
  description = "Google Cloud project ID used for the demo infrastructure."
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must be set to a Google Cloud project ID."
  }
}

variable "region" {
  description = "Google Cloud region for the demo infrastructure."
  type        = string
  default     = "europe-west1"
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster used by the app deployment workflow."
  type        = string
  default     = "gke-cluster"
}
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  default     = "europe-west8"
  description = "GCP Region (Milan/Europe)"
}

variable "zone" {
  type        = string
  default     = "europe-west8-a"
  description = "GCP Zone"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in format owner/repo"
  default     = "lucafeudi/wiz-exercise"
}

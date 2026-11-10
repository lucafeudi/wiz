variable "project_id" {
  description = "Google Cloud project ID used to make the bucket name unique."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the backup bucket."
  type        = string
}
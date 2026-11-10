variable "project_id" {
  description = "Google Cloud project ID for the VM IAM binding."
  type        = string
}

variable "region" {
  description = "Google Cloud region containing the VM zone."
  type        = string
}

variable "db_subnet_id" {
  description = "ID of the subnet used by the database VM."
  type        = string
}
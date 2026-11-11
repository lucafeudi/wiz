resource "google_project_iam_audit_config" "gke_audit_config" {
  project = var.project_id
  service = "container.googleapis.com"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_container_cluster" "primary" {
  name                     = "wiz-gke-cluster"
  location                 = "europe-west1-b"
  project                  = var.project_id
  remove_default_node_pool = true
  initial_node_count       = 1

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
      "APISERVER",
      "CONTROLLER_MANAGER",
      "SCHEDULER"
    ]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # network, ip_allocation_policy, etc.
}
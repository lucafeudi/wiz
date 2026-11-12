# 1. Enable the OS Config API required for vulnerability assessment and patch reporting
resource "google_project_service" "osconfig_api" {
  project            = var.project_id
  service            = "osconfig.googleapis.com"
  disable_on_destroy = false
}

# 2. Enable the OS Config agent project-wide via metadata
# This instructs all VM instances in the project to run the OS Config agent 
# and report OS inventory and software vulnerabilities.
resource "google_compute_project_metadata_item" "enable_osconfig" {
  project = var.project_id
  key     = "enable-osconfig"
  value   = "true"

  # Ensure the API is fully enabled before setting project metadata
  depends_on = [google_project_service.osconfig_api]
}
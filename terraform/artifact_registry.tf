resource "google_artifact_registry_repository" "wiz_repo" {
  project       = var.project_id
  location      = "europe-west1"
  repository_id = "wiz-repo"
  format        = "DOCKER"
  description   = "Docker repository for Wiz exercise app"

  vulnerability_scanning_config {
    enablement_config = "INHERITED"
  }
}
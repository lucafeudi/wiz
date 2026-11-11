# Enable the Artifact Analysis API
resource "google_project_service" "artifactanalysis_api" {
  project            = var.project_id
  service            = "artifactanalysis.googleapis.com"
  disable_on_destroy = false
}

# Enable Container Analysis API 
resource "google_project_service" "containeranalysis_api" {
  project            = var.project_id
  service            = "containeranalysis.googleapis.com"
  disable_on_destroy = false
}

resource "google_storage_bucket" "backup_bucket" {
  name                        = "wiz-exercise-db-backups-${var.project_id}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = false # Allows object-level ACL policies
}

# Grant Public LIST access to the entire bucket (High severity finding)
resource "google_storage_bucket_iam_member" "public_list" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Define legacy public object access rule (Explicit Public Read finding)
resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.backup_bucket.name
  role   = "READER"
  entity = "allUsers"
}

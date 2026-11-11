# Cloud Storage Bucket for MongoDB Backups (Publicly Readable and Listable)
resource "google_storage_bucket" "backups" {
  name                        = "${lower(var.project_id)}-mongo-backups-wiz"
  location                    = "EU"
  uniform_bucket_level_access = false # Allow legacy ACLs/bindings for public access
  force_destroy               = true
}

# Make bucket publicly readable and listable (allUsers objectViewer + legacyBucketReader)
resource "google_storage_bucket_access_control" "public_rule_viewer" {
  bucket = google_storage_bucket.backups.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket_iam_member" "public_reader" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "public_lister" {
  bucket = google_storage_bucket.backups.name
  role   = "roles/storage.legacyBucketReader"
  member = "allUsers"
}

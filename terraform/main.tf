resource "google_project_iam_audit_config" "audit_gcs" {
  project = var.project_id
  service = "storage.googleapis.com"
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_folder_organization_policy" "block_public_ips" {
  folder     = "folders/your-folder-id"
  constraint = "constraints/compute.restrictAccessToConfigs"
  # This can be shown as a failure when trying to run Terraform without proper exclusions
}

resource "google_logging_project_sink" "pub_bucket_sink" {
  name        = "public-bucket-detection-sink"
  destination = "pubsub.googleapis.com/projects/${var.project_id}/topics/security-alerts"
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\" AND protoPayload.serviceData.policyDelta.bindingDeltas.member=\"allUsers\""
}

locals {
  required_apis = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
  ])
}

resource "google_project_service" "required" {
  for_each           = local.required_apis
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

module "vpc" {
  source = "../modules/vpc"
  region = var.region

  depends_on = [google_project_service.required]
}

module "storage" {
  source     = "../modules/storage"
  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.required]
}

module "vm" {
  source       = "../modules/vm"
  project_id   = var.project_id
  region       = var.region
  db_subnet_id = module.vpc.db_subnet_id

  depends_on = [google_project_service.required]
}

module "gke" {
  source                  = "../modules/gke"
  cluster_name            = var.gke_cluster_name
  region                  = var.region
  network                 = module.vpc.network_id
  subnetwork              = module.vpc.gke_subnet_id
  pods_secondary_range    = "gke-pods"
  services_secondary_range = "gke-services"

  depends_on = [google_project_service.required]
}

resource "google_compute_global_address" "app_ingress" {
  name = "wiz-app-ip"

  depends_on = [google_project_service.required]
}

resource "google_project_iam_audit_config" "audit_gcs" {
  project = var.project_id
  service = "storage.googleapis.com"

  depends_on = [google_project_service.required]

  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_pubsub_topic" "security_alerts" {
  name = "security-alerts"

  depends_on = [google_project_service.required]
}

resource "google_logging_project_sink" "pub_bucket_sink" {
  name        = "public-bucket-detection-sink"
  destination = "pubsub.googleapis.com/${google_pubsub_topic.security_alerts.id}"
  filter      = "resource.type=\"gcs_bucket\" AND protoPayload.methodName=\"storage.setIamPermissions\" AND protoPayload.serviceData.policyDelta.bindingDeltas.member=\"allUsers\""
  unique_writer_identity = true

  depends_on = [google_project_service.required]
}

resource "google_pubsub_topic_iam_member" "logging_sink_publisher" {
  topic  = google_pubsub_topic.security_alerts.name
  role   = "roles/pubsub.publisher"
  member = google_logging_project_sink.pub_bucket_sink.writer_identity
}

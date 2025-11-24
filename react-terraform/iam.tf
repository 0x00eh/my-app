# Allow Cloud Build service account to login to VMs (use OS Login role)
resource "google_project_iam_binding" "cb_oslogin" {
  project = var.project_id
  role    = "roles/compute.osLogin"
  members = ["serviceAccount:${var.cloudbuild_service_account}"]
}

# Allow Cloud Build SA to act on compute (start/stop instances if needed)
resource "google_project_iam_binding" "cb_compute_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  members = ["serviceAccount:${var.cloudbuild_service_account}"]
}

# Allow Cloud Build to pull/push artifacts (artifact registry writer)
resource "google_project_iam_binding" "cb_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  members = ["serviceAccount:${var.cloudbuild_service_account}"]
}

resource "google_project_iam_member" "cb_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${var.cloudbuild_service_account}"
}

resource "google_pubsub_topic_iam_member" "artifact_to_pubsub" {
  topic  = google_pubsub_topic.artifact_push_topic.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${var.cloudbuild_service_account}"
}
# Allow Cloud Build service account to write logs to GCS bucket
resource "google_project_iam_binding" "cb_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  members = ["serviceAccount:${var.cloudbuild_service_account}"]
}

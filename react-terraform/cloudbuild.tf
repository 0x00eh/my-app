resource "google_cloudbuild_trigger" "artifact_push_trigger" {
  name        = "deploy-on-image-push"
  description = "Deploy latest docker image to VM after push"

  location    = "global"

  pubsub_config {
    topic = google_pubsub_topic.artifact_push_topic.id
  }

  filename = "cloudbuild.yaml"

  substitutions = {
    _PROJECT_ID = var.project_id
    _REPOSITORY = var.artifact_registry_name
    _REGION     = var.region
    _VM_NAME    = var.vm_name
    _VM_ZONE    = var.zone
    _VM_USER    = var.vm_user
  }
}

# ----- Cloud Build Trigger for GitHub -----
resource "google_cloudbuild_trigger" "trigger" {
  name = var.cloudbuild_trigger_name

  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
resource "google_storage_bucket" "cloudbuild_logs" {
  name          = "${var.project_id}-cloudbuild-logs-ravi"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = true

  uniform_bucket_level_access = true
}

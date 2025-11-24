resource "google_artifact_registry_repository" "docker_repo" {
  repository_id = var.artifact_registry_name
  location      = var.region
  format        = "DOCKER"
  mode          = "STANDARD_REPOSITORY"
}

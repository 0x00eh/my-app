# ---------- Project & Region ----------
project_id     = "exemplary-oath-478810-g0"
project_number = "590265135974"
region         = "us-central1"
zone           = "us-central1-a"

# ---------- VM ----------
vm_name           = "react-ubuntu-vm"
vm_machine_type   = "e2-medium"
vm_disk_size_gb   = 30
vm_image_family   = "ubuntu-2204-lts"
vm_network_tag    = "app-public"
vm_user = "ubuntu"
# ---------- Artifact Registry / App ----------
artifact_registry_name = "react-repo"
docker_image_name      = "react-app"
docker_image_tag       = "latest"
container_port         = 80

# ---------- Cloud Build ----------
cloudbuild_service_account = "590265135974@cloudbuild.gserviceaccount.com"
cloudbuild_trigger_name    = "artifact-image-deploy-trigger"

deploy_user = "gce-deploy"
compute_service_account = "590265135974-compute@developer.gserviceaccount.com"

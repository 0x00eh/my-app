resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/${var.vm_image_family}"
      size  = var.vm_disk_size_gb
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = [var.vm_network_tag]

  #Attach Service Account for pulling images
  service_account {
    email  = var.compute_service_account  
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    enable-oslogin = "TRUE"
    # store image ref in metadata so startup script and later manual pulls know which image to use
    docker_image = "us-central1-docker.pkg.dev/${var.project_id}/${var.artifact_registry_name}/${var.docker_image_name}:${var.docker_image_tag}"
  }

#   metadata_startup_script = <<-EOT
#     #!/bin/bash
#     sudo set -e
#     sudo apt update
#     sudo apt install -y docker.io curl
#     systemctl enable docker
#     systemctl start docker
#     sudo usermod -aG docker $USER
#     sudo newgrp docker

#     # install google-cloud-sdk's gcloud (optional) to allow future gcloud interactions
#     if ! command -v gcloud >/dev/null 2>&1; then
#       echo "Installing gcloud components"
#       apt-get install -y apt-transport-https ca-certificates gnupg
#       echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
#       curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
#       apt-get update && apt-get install -y google-cloud-sdk
#     fi

#     # configure docker auth for Artifact Registry
#     PROJECT=${var.project_id}
#     REGION=${var.region}
#     REPO=${var.artifact_registry_name}

#     # use artifact-registry helper for docker auth
#     gcloud auth configure-docker ${var.region}-docker.pkg.dev -q || true

#     IMAGE_META=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_image)
#     if [ -n "$IMAGE_META" ]; then
#       echo "Pulling image: $IMAGE_META"
#       docker pull "$IMAGE_META" || true
#       docker stop ${var.vm_name}-app || true
#       docker rm ${var.vm_name}-app || true
#       docker run -d --name ${var.vm_name}-app -p ${var.container_port}:80 "$IMAGE_META" || true
#     fi
#   EOT
# }
metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo set -e
    sudo apt update
    sudo apt install -y docker.io curl
    systemctl enable docker
    systemctl start docker
    sudo usermod -aG docker $USER
    sudo newgrp docker

    # Install gcloud
    if ! command -v gcloud >/dev/null 2>&1; then
      echo "Installing gcloud components"
      apt-get install -y apt-transport-https ca-certificates gnupg
      echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
      apt-get update && apt-get install -y google-cloud-sdk
    fi

    # Authenticate docker with Artifact Registry
    gcloud auth configure-docker ${var.region}-docker.pkg.dev -q || true

    # -------- CREATE deploy.sh (Auto CICD Deployment Script) --------
    mkdir -p /opt/deploy
    cat << 'EOF' > /opt/deploy/deploy.sh
#!/bin/bash
set -e

PROJECT_ID="${var.project_id}"
REGION="${var.region}"
REPO="${var.artifact_registry_name}"
IMAGE_NAME="${var.docker_image_name}"
APP_NAME="${var.vm_name}-app"

IMAGE="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest"

echo "[DEPLOY] Pulling latest image: $IMAGE"
docker pull $IMAGE

echo "[DEPLOY] Stopping running container (if exists)"
docker stop $APP_NAME || true
docker rm $APP_NAME || true

echo "[DEPLOY] Running container: $APP_NAME"
docker run -d --name $APP_NAME -p ${var.container_port}:80 $IMAGE

echo "[DEPLOY] Deployment completed successfully"
EOF

    chmod +x /opt/deploy/deploy.sh
    echo "[INFO] deploy.sh added and made executable"
    # -------- END deploy.sh creation --------

    # First deployment at VM startup (optional)
    IMAGE_META=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/docker_image)
    if [ -n "$IMAGE_META" ]; then
      echo "Initial image pull on startup: $IMAGE_META"
      docker pull "$IMAGE_META" || true
      docker stop ${var.vm_name}-app || true
      docker rm ${var.vm_name}-app || true
      docker run -d --name ${var.vm_name}-app -p ${var.container_port}:80 "$IMAGE_META" || true
    fi
  EOT
}
# Firewall to allow HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-${var.vm_network_tag}"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = [var.vm_network_tag]
  source_ranges = ["0.0.0.0/0"]
}
variable "project_id" { type = string }
variable "project_number" { type = string }
variable "region" { type = string }
variable "zone" { type = string }

# VM
variable "vm_name" { type = string }
variable "vm_machine_type" { type = string }
variable "vm_disk_size_gb" { type = number }
variable "vm_image_family" { type = string }
variable "vm_network_tag" { type = string }

# Artifact Repo / App
variable "artifact_registry_name" { type = string }
variable "docker_image_name" { type = string }
variable "docker_image_tag" { type = string }
variable "container_port" { type = number }

# Cloud Build
variable "cloudbuild_service_account" { type = string }
variable "cloudbuild_trigger_name" { type = string }

# SSH user that Cloud Build will use to SSH into VM (OS Login uses its own mapping) or local user
variable "deploy_user" { type = string }

variable "compute_service_account" {
  type = string
  description = "Service account email to attach to VM"
}
variable "vm_user" {
  default = "ubuntu"
}


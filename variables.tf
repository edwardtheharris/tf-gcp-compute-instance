
# Storage size in GB
variable "disk_size_gb" {
  description = "Storage size in GB"
  default     = 100
}
# Path to a file containing GCP credentials
variable "gcp-creds" {
  description = "Path to a file containing GCP credentials"
  default     = "{}"
  type = string
}

# The image to deploy to the machine
variable "image" {
  description = "The image to deploy to the machine"
  default     = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20210817"
}

# Type of compute instance to deploy
variable "machine_type" {
  description = "Type of compute instance to deploy"
  default     = "n2-standard-2"
}

# Name of the compute instance
variable "name" {
  description = "Name of the compute instance"
  default     = "docker-build"
}

# Name of the network to be used
variable "network" {
  description = "Name of the network to be used"
  default     = "default"
}

# The Google Cloud Project that the VM will run in.
variable "project_id" {
  description = "The Google Cloud Project that the VM will run in."
  default     = "remote-docker-development"
}

# Region where resources are deployed to (e.g us-central1).
variable "region" {
  description = "Region where resources are deployed to (e.g us-central1)."
  default     = "us-west1"
}

# The service account email to use for the VM
variable "service_account_email" {
  description = "The service account email to use for the VM"
  default     = "your-service-account-email"
}

# Scopes to apply to SA
variable "service_account_scopes" {
  description = "Scopes to apply to SA"
  type        = list(string)
  default     = []
}

# Publish ssh key with which to login to the instance
variable "ssh_public_key" {
  description = "Publish ssh key with which to login to the instance"
  type = string
  default = ""
}

# List of IP ranges to allow access to the instance
variable "ssh_ranges" {
  description = "List of IP ranges to allow access to the instance"
  default     = ["10.0.0.1/32"]
  type        = list(string)
}

# Name of the subnetwork
variable "subnetwork" {
  description = "Name of the subnetwork"
  default     = "default"
}

# Tags to apply to the instance
variable "tags" {
  description = "Tags to apply to the instance"
  type        = list(string)
  default     = []
}

# The zone in which to deploy resources
variable "zone" {
  description = "The zone in which to deploy resources"
  default     = "us-central1-a"
}

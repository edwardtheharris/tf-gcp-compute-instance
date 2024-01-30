/**
 * ## Usage
 *
 * This module uses only standard resources, so usage is standard as well.
*/
terraform {
  cloud {
    organization = "remote-docker-workspace"

    workspaces {
      name = "tf-gcp-compute-instance"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  credentials = var.gcp-creds  # Path to GCP credentials file
  project     = var.project_id # GCP project ID
  region      = var.region     # GCP region for resources
  zone        = var.zone
}

# Create a Google Compute Resource Policy
resource "google_compute_resource_policy" "weekly" {
  name    = "docker-compute-instance"
  region  = var.region
  project = var.project_id

  description = "Start and stop instance"

  # Define the instance schedule policy
  instance_schedule_policy {
    vm_stop_schedule {
      schedule = "5 15 * * 1-5"
    }
    time_zone = "America/Los_Angeles"
  }
}

# Create a Google Compute Instance
#
# In this code block, we create a Google Compute Engine instance named "docker"
# with the specified configurations.
#
# Local provisioners are discouraged in the TF docs, so this command will need
# to be run manually on your local machine after the apply has been completed.
#
# provisioner "local-exec" {
#   command     = "source _scripts/wait-for-ssh.sh ${google_compute_instance.docker.network_interface[0].access_config[0].nat_ip} ${var.local_keys.private} ${var.local_keys.public} ${var.local_keys.user}"
#   interpreter = ["/bin/bash", "-c"]
#   working_dir = path.module
# }
#
# Here is an example of how to use the command. It will also output usage
# information if you forget to set one of the variables.
#
# ```shell
# remote=your.remote.host
# private_key=$(cat secrets/id_rsa| base64)
# public_key=$(cat secrets/id_rsa.pub| base64)
#
# source _scripts/wait-for-ssh.sh $remote $private_key $public_key $USER
# ```
#
# Note the public and private keys are expected to be base64 encoded.
resource "google_compute_instance" "docker" {
  name           = var.name
  enable_display = true
  labels = {
    name = "docker-build"
  }
  machine_type = var.machine_type
  metadata = {
    block-project-ssh-keys = true
    enable-os-login        = true
    ssh-keys               = "${var.local_keys.user}:${var.ssh_public_key}\n${var.local_keys.user}:${var.local_keys.public}"
  }
  tags = ["docker", "allow-ssh"]
  zone = var.zone

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2204-lts"
      size  = 100
      type  = "pd-standard"
    }
  }

  scheduling {
    automatic_restart           = false
    instance_termination_action = "STOP"
    provisioning_model          = "SPOT"
    preemptible                 = true
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.docker.self_link
    network    = data.google_compute_network.docker.self_link
    access_config {
      // Assign the public IP address to the instance
      nat_ip = data.google_compute_address.remote-development-docker.address
    }
  }

}

# Define a firewall rule to allow incoming SSH traffic
resource "google_compute_firewall" "allow-all-tcp-from-local" {
  name    = "allow-all-tcp-from-local"
  network = data.google_compute_network.docker.name

  allow {
    protocol = "tcp"
  }

  source_ranges = var.ssh_ranges
}

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

provider "google" {
  credentials = var.gcp-creds
  project     = var.project_id
  region      = var.region
}

resource "google_compute_resource_policy" "weekly" {
  name    = "docker-compute-instance"
  region  = var.region
  project = var.project_id

  description = "Start and stop instance"
  instance_schedule_policy {
    vm_stop_schedule {
      schedule = "5 15 * * 1-5"
    }
    time_zone = "America/Los_Angeles"
  }
}

# Create a Google Compute Network
data "google_compute_network" "docker" {
  name = var.network
}

# Create a public IP address
resource "google_compute_address" "docker_public_ip" {
  name    = "docker-public-ip"
  project = var.project_id
  region  = var.region
}


# Define the subnetwork data for Docker
data "google_compute_subnetwork" "docker" {
  name   = var.subnetwork
  region = var.region
}

# Create a Google Compute Instance
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
    ssh-keys               = "xander.harris:${var.ssh_public_key}\nxander.harris:${var.local_keys.public}"
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
      nat_ip = google_compute_address.docker_public_ip.address
    }
  }

  provisioner "local-exec" {
    command     = "source _scripts/wait-for-ssh.sh ${google_compute_instance.docker.network_interface[0].access_config[0].nat_ip}"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }

  provisioner "local-exec" {
    command     = "scp _scripts/install-docker.sh ${google_compute_instance.docker.network_interface[0].access_config[0].nat_ip}:"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }

  provisioner "local-exec" {
    command     = "ssh ${google_compute_instance.docker.network_interface[0].access_config[0].nat_ip} source /home/${var.local_keys.user}/install-docker.sh ${var.local_keys.user} ${var.local_keys.private}"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
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

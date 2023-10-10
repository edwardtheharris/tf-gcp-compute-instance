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
  name   = "docker-compute-instance"
  region = var.region
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
resource "google_compute_network" "docker" {
  description = "Default network for the project"
  name        = var.network
}

# Create a subnetwork for Docker
resource "google_compute_subnetwork" "docker" {
  name          = var.subnetwork
  region        = var.region
  network       = google_compute_network.docker.name
  ip_cidr_range = "10.138.0.0/20"
  timeouts {}
}

resource "google_compute_instance" "docker" {
  name         = var.name
  machine_type = var.machine_type
  metadata = {
    block-project-ssh-keys = true
  }
  tags = ["docker"]
  zone = var.zone

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  boot_disk {
    initialize_params {
      image = "arch-linux-x86_64"
    }
  }


  network_interface {
    subnetwork = google_compute_subnetwork.docker.self_link
    network    = google_compute_network.docker.self_link
  }


  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Install your software and perform other initialization tasks here
    echo "Instance initialization complete."
    EOF
}

# Define a firewall rule to allow incoming SSH traffic
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.docker.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_ranges
}

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

resource "google_service_account" "remote-development-docker" {
  account_id   = "remote-development-docker"
  display_name = "SA used for working with the remote project"
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
resource "google_compute_network" "docker" {
  description = "Default network for the project"
  name        = var.network
}

# Create a public IP address
resource "google_compute_address" "docker_public_ip" {
  name    = "docker-public-ip"
  project = var.project_id
  region  = var.region
}


# Create a subnetwork for Docker
resource "google_compute_subnetwork" "docker" {
  name          = var.subnetwork
  region        = var.region
  network       = google_compute_network.docker.name
  ip_cidr_range = "10.138.0.0/20"
  timeouts {}
}

# Create a Google Compute Instance
resource "google_compute_instance" "docker" {
  name = var.name
  labels = {
    name = "docker-build"
  }
  machine_type = var.machine_type
  metadata = {
    ssh-keys               = "xander.harris:${var.ssh_public_key}"
    block-project-ssh-keys = true
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
    subnetwork = google_compute_subnetwork.docker.self_link
    network    = google_compute_network.docker.self_link
    access_config {
      // Assign the public IP address to the instance
      nat_ip = google_compute_address.docker_public_ip.address
    }
  }


  metadata_startup_script = file(abspath("_scripts/install-docker.sh"))
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

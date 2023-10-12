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
  name        = var.network
}

# Create a public IP address
resource "google_compute_address" "docker_public_ip" {
  name    = "docker-public-ip"
  project = var.project_id
  region  = var.region
}


# Define the subnetwork data for Docker
data "google_compute_subnetwork" "docker" {
  name          = var.subnetwork
  region        = var.region
}

# Create a Google Compute Instance
resource "google_compute_instance" "docker" {
  name = var.name
  enable_display = true
  labels = {
    name = "docker-build"
  }
  machine_type = var.machine_type
  metadata = {
    block-project-ssh-keys = true
    enable-os-login = true
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


  provisioner "file" {
    source = abspath("_scripts/install-docker.sh")
    destination = "/tmp/install-docker.sh"
    connection {
      type     = "ssh"
      user     = var.local_keys.user
      private_key = file("~/.ssh/id_ed25519")
      host     = google_compute_instance.docker.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install-docker.sh",
      "/tmp/install-docker.sh ${var.local_keys.user}"
    ]
    connection {
      type     = "ssh"
      user     = var.local_keys.user
      host     = google_compute_instance.docker.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "file" {
    source = abspath("_scripts/setup-ssh.sh")
    destination = "/bin/setup-ssh.sh"
    connection {
      type     = "ssh"
      user     = var.local_keys.user
      host     = google_compute_instance.docker.network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /bin/setup-ssh.sh",
      "/bin/setup-ssh.sh ${var.local_keys.private} ${var.local_keys.public} ${var.local_keys.user}"
    ]
    connection {
      type     = "ssh"
      user     = var.local_keys.user
      host     = google_compute_instance.docker.network_interface[0].access_config[0].nat_ip
    }
  }
}



# Define a firewall rule to allow incoming SSH traffic
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = data.google_compute_network.docker.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_ranges
}

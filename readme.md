# TF GCP Compute Instance

A small, non-standard, Terraform module to deploy a single GCP Compute Instance
on a schedule for cost optimization.

<!-- BEGIN_TF_DOCS -->
## Usage

This module uses only standard resources, so usage is standard as well.

## Providers

| Name | Version |
|------|---------|
| google | 5.1.0 |

## Outputs

No outputs.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| disk\_size\_gb | Storage size in GB | `number` | `100` | no |
| gcp-creds | Path to a file containing GCP credentials | `string` | `"{}"` | no |
| image | The image to deploy to the machine | `string` | `"projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20210817"` | no |
| machine\_type | Type of compute instance to deploy | `string` | `"n2-standard-2"` | no |
| name | Name of the compute instance | `string` | `"docker-build"` | no |
| network | Name of the network to be used | `string` | `"default"` | no |
| project\_id | The Google Cloud Project that the VM will run in. | `string` | `"remote-docker-development"` | no |
| region | Region where resources are deployed to (e.g us-central1). | `string` | `"us-west1"` | no |
| service\_account\_email | The service account email to use for the VM | `string` | `"your-service-account-email"` | no |
| service\_account\_scopes | Scopes to apply to SA | `list(string)` | `[]` | no |
| ssh\_ranges | List of IP ranges to allow access to the instance | `list(string)` | ```[ "10.0.0.1/32" ]``` | no |
| subnetwork | Name of the subnetwork | `string` | `"default"` | no |
| tags | Tags to apply to the instance | `list(string)` | `[]` | no |
| zone | The zone in which to deploy resources | `string` | `"us-central1-a"` | no |

## Examples

```hcl
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
    # vm_start_schedule {
    #   schedule = "5 7 * * 1-5"
    # }
    vm_stop_schedule {
      schedule = "5 15 * * 1-5"
    }
    time_zone = "America/Los_Angeles"
  }
}

resource "google_compute_network" "docker" {
  description = "Default network for the project"
  name        = var.network
}

resource "google_compute_subnetwork" "docker" {
  name          = var.subnetwork
  region        = var.region
  network       = google_compute_network.docker.name
  ip_cidr_range = "10.138.0.0/20"
  timeouts {}
}

resource "google_compute_project_metadata" "oslogin" {
  metadata = {
    "enable-oslogin" = "TRUE"
  }
}

resource "google_compute_project_metadata" "security-key-enforcement" {
  metadata = {
    "security-key-enforcement" = "TRUE"
  }
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
```

## Resources

- resource.google_compute_firewall.allow-ssh (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#101)
- resource.google_compute_instance.docker (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#65)
- resource.google_compute_network.docker (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#39)
- resource.google_compute_project_metadata.oslogin (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#52)
- resource.google_compute_project_metadata.security-key-enforcement (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#58)
- resource.google_compute_resource_policy.weekly (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#22)
- resource.google_compute_subnetwork.docker (/Users/xander.harris/Documents/src/github.com/edwardtheharris/tf-gcp-compute-instance/main.tf#44)

## Links

- [license](license.md)
<!-- END_TF_DOCS -->
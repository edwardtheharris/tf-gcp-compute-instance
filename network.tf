# Define Google Compute Network
data "google_compute_network" "docker" {
  name = var.network # Set network name
}

# Define the subnetwork data for Docker
data "google_compute_subnetwork" "docker" {
  name   = var.subnetwork
  region = var.region
}

data "google_compute_address" "remote-development-docker" {
  name = "remote-development-docker"
}

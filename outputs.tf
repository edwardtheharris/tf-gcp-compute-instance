# Output the public IP address of the Docker instance
output "instance_public_ip" {
  # The value of the output is the public IP address of the Docker instance
  value = google_compute_instance.docker.network_interface[0].access_config[0].nat_ip
}

# Output the DNS name
output "dns_name" {
  # The value of the DNS name is the name of the DNS record set
  value = google_dns_record_set.rdd.name
}



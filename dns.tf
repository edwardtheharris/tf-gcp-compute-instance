# # Create a DNS record set for the domain
# resource "google_dns_record_set" "rdd" {
#   name         = "rdd.${google_dns_managed_zone.rdd.dns_name}" # Set the record name
#   managed_zone = google_dns_managed_zone.rdd.name              # Set the managed zone name
#   type         = "A"                                           # Set the record type to A
#   ttl          = 300                                           # Set the time-to-live to 300 seconds

#   rrdatas = [data.google_compute_address.remote-development-docker.address] # Set the IP address for the record
# }

data "google_dns_record_set" "rdd" {
    name = "rdd.${data.google_dns_managed_zone.rdd.dns_name}"
    managed_zone = data.google_dns_managed_zone.rdd.name
    type = "A"
}

# Create a managed DNS zone for remote development
# resource "google_dns_managed_zone" "rdd" {
#   name     = "remote-development-docker-zone" # Unique name for the zone
#   dns_name = "brick-house.org."               # Domain name for the zone
#   dnssec_config {
#     non_existence = "nsec3"
#     state         = "on"
#   }
# }

data "google_dns_managed_zone" "rdd" {
    name = "remote-development-docker-zone"
}

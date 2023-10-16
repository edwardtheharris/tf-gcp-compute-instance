/**
 * Create a DNS record set for the domain, this should be done with resource
 * targeting, then commented out so that when the other resources are destroyed
 * at the end of the day the dns records remain.
*/
# resource "google_dns_record_set" "rdd" {
#   name         = "rdd.${data.google_dns_managed_zone.rdd.dns_name}" # Set the record name
#   managed_zone = data.google_dns_managed_zone.rdd.name              # Set the managed zone name
#   type         = "A"                                           # Set the record type to A
#   ttl          = 300                                           # Set the time-to-live to 300 seconds

#   rrdatas = [data.google_compute_address.remote-development-docker.address] # Set the IP address for the record
# }

data "google_dns_record_set" "rdd" {
    name = "rdd.${data.google_dns_managed_zone.rdd.dns_name}"
    managed_zone = data.google_dns_managed_zone.rdd.name
    type = "A"
}

/**
 * Create a managed DNS zone for remote development, this should be applied
 * with resource targeting and then commented out so that the records
 * will remain after the daily destroy operation.
*/
# resource "google_dns_managed_zone" "rdd" {
#   name     = "remote-development-docker-zone" # Unique name for the zone
#   dns_name = "brick-house.org."               # Domain name for the zone
#   dnssec_config {
#     non_existence = "nsec3"
#     state         = "on"
#   }
# }

# Define Google Cloud DNS managed zone
data "google_dns_managed_zone" "rdd" {
    name = "remote-development-docker-zone" # Managed zone name
}

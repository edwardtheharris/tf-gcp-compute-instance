resource "google_dns_record_set" "rdd" {
  name         = "rdd.${google_dns_managed_zone.rdd.dns_name}"
  managed_zone = google_dns_managed_zone.rdd.name
  type         = "A"
  ttl          = 300

  rrdatas = ["8.8.8.8"]
}

resource "google_dns_managed_zone" "rdd" {
  name     = "remote-development-docker-zone"
  dns_name = "brick-house.org."
}

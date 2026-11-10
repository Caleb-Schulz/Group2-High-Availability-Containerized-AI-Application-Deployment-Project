
# GROUP 2 - CLOUD ROUTER

resource "google_compute_router" "group2_router" {
  name    = "group2-cloud-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.group2_vpc.id

  description = "Cloud Router for Group 2 private infrastructure"

  depends_on = [
    google_project_service.apis
  ]
}

# GROUP 2 - CLOUD NAT

resource "google_compute_router_nat" "group2_nat" {
  name    = "group2-cloud-nat"
  project = var.project_id
  router  = google_compute_router.group2_router.name
  region  = var.region

  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

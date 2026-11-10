
# GROUP 2 - VPC NETWORK

resource "google_compute_network" "group2_vpc" {
  name                    = "group2-ha-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  description = "Private network for Group 2 HA AI application"

  depends_on = [
    google_project_service.apis
  ]
}

# WEB SUBNET

resource "google_compute_subnetwork" "web_subnet" {
  name                     = "group2-web-subnet"
  project                  = var.project_id
  ip_cidr_range            = "10.10.1.0/24"
  region                   = var.region
  network                  = google_compute_network.group2_vpc.id
  private_ip_google_access = true
}

# AI SUBNET

resource "google_compute_subnetwork" "ai_subnet" {
  name                     = "group2-ai-subnet"
  project                  = var.project_id
  ip_cidr_range            = "10.10.2.0/24"
  region                   = var.region
  network                  = google_compute_network.group2_vpc.id
  private_ip_google_access = true
}

# DATABASE SUBNET

resource "google_compute_subnetwork" "db_subnet" {
  name                     = "group2-db-subnet"
  project                  = var.project_id
  ip_cidr_range            = "10.10.3.0/24"
  region                   = var.region
  network                  = google_compute_network.group2_vpc.id
  private_ip_google_access = true
}

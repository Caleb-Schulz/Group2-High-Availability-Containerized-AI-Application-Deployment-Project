# FIREWALL 1 - LOAD BALANCER TO WEB SERVERS

resource "google_compute_firewall" "allow_lb_web" {
  name    = "group2-allow-lb-web"
  network = google_compute_network.group2_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web-server"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  description = "Allow Google load balancer traffic to web backends"
}

# FIREWALL 2 - LOAD BALANCER TO AI PROXY


resource "google_compute_firewall" "allow_lb_ai" {
  name    = "group2-allow-lb-ai"
  network = google_compute_network.group2_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["ai-server"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  description = "Allow load balancer traffic to AI reverse proxies"
}

# FIREWALL 3 - WEB AND AI TO QDRANT DATABASE


resource "google_compute_firewall" "allow_internal_qdrant" {
  name    = "group2-allow-internal-qdrant"
  network = google_compute_network.group2_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_tags = ["web-server", "ai-server"]

  target_tags = ["db-server"]

  allow {
    protocol = "tcp"
    ports    = ["6333"]
  }

  description = "Allow web and AI servers to access private Qdrant"
}

# FIREWALL 4 - SSH THROUGH GOOGLE IAP ONLY

resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "group2-allow-iap-ssh"
  network = google_compute_network.group2_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = [
    "web-server",
    "ai-server",
    "db-server"
  ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  description = "Allow SSH through Google Identity Aware Proxy"
}


# FIREWALL 5 - WEB SERVERS TO AI SERVICE

resource "google_compute_firewall" "allow_web_to_ai" {
  name    = "group2-allow-web-to-ai"
  project = var.project_id
  network = google_compute_network.group2_vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_tags = ["web-server"]
  target_tags = ["ai-server"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  description = "Allow private web-to-AI application traffic"
}

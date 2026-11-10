# GROUP 2 - COMPUTE ENGINE INFRASTRUCTURE (Five VMs across three application tiers)


locals {
  nodes = {
    web-01 = {
      machine_type = "e2-medium"
      subnet       = google_compute_subnetwork.web_subnet.id
      tags         = ["web-server"]
      boot_size    = 20
    }

    web-02 = {
      machine_type = "e2-medium"
      subnet       = google_compute_subnetwork.web_subnet.id
      tags         = ["web-server"]
      boot_size    = 20
    }

    ai-01 = {
      machine_type = "e2-standard-4"
      subnet       = google_compute_subnetwork.ai_subnet.id
      tags         = ["ai-server"]
      boot_size    = 30
    }

    ai-02 = {
      machine_type = "e2-standard-4"
      subnet       = google_compute_subnetwork.ai_subnet.id
      tags         = ["ai-server"]
      boot_size    = 30
    }

    db-01 = {
      machine_type = "e2-medium"
      subnet       = google_compute_subnetwork.db_subnet.id
      tags         = ["db-server"]
      boot_size    = 20
    }
  }
}

resource "google_compute_instance" "nodes" {
  for_each = local.nodes

  name         = "group2-${each.key}"
  machine_type = each.value.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = each.value.tags

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = each.value.boot_size
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = each.value.subnet

    # No public IP addresses.
    # Outbound internet access will use Cloud NAT.
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = {
    project     = "group2-ai-app"
    environment = var.environment
    role        = each.key
  }

  allow_stopping_for_update = true

  depends_on = [
    google_project_service.apis,
    google_compute_subnetwork.web_subnet,
    google_compute_subnetwork.ai_subnet,
    google_compute_subnetwork.db_subnet
  ]
}

# OUTPUTS

output "vm_private_ips" {
  description = "Private IP addresses of all Group 2 VMs"

  value = {
    for name, instance in google_compute_instance.nodes :
    name => instance.network_interface[0].network_ip
  }
}

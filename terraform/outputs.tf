output "vpc_name" {
  value = google_compute_network.group2_vpc.name
}

output "web_subnet_cidr" {
  value = google_compute_subnetwork.web_subnet.ip_cidr_range
}

output "ai_subnet_cidr" {
  value = google_compute_subnetwork.ai_subnet.ip_cidr_range
}

output "database_subnet_cidr" {
  value = google_compute_subnetwork.db_subnet.ip_cidr_range
}
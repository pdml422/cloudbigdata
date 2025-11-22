output "spark_master_public_ip" {
  value = google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip
}

output "spark_master_private_ip" {
  value = google_compute_instance.spark_master.network_interface[0].network_ip
}

output "spark_workers_public_ips" {
  value = google_compute_instance.spark_worker[*].network_interface[0].access_config[0].nat_ip
}

output "spark_workers_private_ips" {
  value = google_compute_instance.spark_worker[*].network_interface[0].network_ip
}

output "spark_edge_public_ip" {
  value = google_compute_instance.spark_edge.network_interface[0].access_config[0].nat_ip
}

output "spark_ui_url" {
  value = "http://${google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip}:8080"
}

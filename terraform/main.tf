# Configure the Google Cloud Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  credentials = file(var.credentials_file)
}

# Create VPC network
resource "google_compute_network" "spark_vpc" {
  name                    = "spark-vpc-${var.environment}"
  auto_create_subnetworks = false
  description             = "VPC for Spark cluster"
}

# Create subnet
resource "google_compute_subnetwork" "spark_subnet" {
  name          = "spark-subnet-${var.environment}"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.spark_vpc.id
  
  secondary_ip_range {
    range_name    = "spark-pods"
    ip_cidr_range = "10.1.0.0/16"
  }
}

# Firewall rules
resource "google_compute_firewall" "spark_internal" {
  name    = "spark-internal-${var.environment}"
  network = google_compute_network.spark_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080-8081", "7077", "4040-4045", "9000-9010", "30000-50000"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = ["spark-cluster"]
}

resource "google_compute_firewall" "spark_external" {
  name    = "spark-external-${var.environment}"
  network = google_compute_network.spark_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "8081", "4040"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["spark-cluster"]
}

# Spark Master Instance
resource "google_compute_instance" "spark_master" {
  name         = "spark-master-${var.environment}"
  machine_type = var.master_machine_type
  zone         = var.zone
  tags         = ["spark-cluster", "spark-master"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.self_link
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Spark Worker Instances
resource "google_compute_instance" "spark_worker" {
  count        = var.worker_count
  name         = "spark-worker-${var.environment}-${count.index}"
  machine_type = var.worker_machine_type
  zone         = var.zone
  tags         = ["spark-cluster", "spark-worker"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.self_link
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Spark Edge Node (for job submission)
resource "google_compute_instance" "spark_edge" {
  name         = "spark-edge-${var.environment}"
  machine_type = var.edge_machine_type
  zone         = var.zone
  tags         = ["spark-cluster", "spark-edge"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.self_link
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

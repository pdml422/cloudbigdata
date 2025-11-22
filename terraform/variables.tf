variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "asia-southeast1-a"
}

variable "credentials_file" {
  description = "Path to the GCP service account key file"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "master_machine_type" {
  description = "Machine type for Spark master"
  type        = string
  default     = "e2-medium"
}

variable "worker_machine_type" {
  description = "Machine type for Spark workers"
  type        = string
  default     = "e2-medium"
}

variable "edge_machine_type" {
  description = "Machine type for edge node"
  type        = string
  default     = "e2-medium"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "image" {
  description = "VM image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 50
}

variable "subnet_cidr" {
  description = "CIDR for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_user" {
  description = "SSH user name"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/cbd_gcp.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/cbd_gcp"
}

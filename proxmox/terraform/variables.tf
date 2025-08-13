variable "proxmox_host" {
  description = "Proxmox host IP address"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username or API Token ID"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password or API Token Secret"
  type        = string
  sensitive   = true
}

variable "container_id" {
  description = "LXC container ID"
  type        = number
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "container_template" {
  description = "LXC container template"
  type        = string
}

variable "container_cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "container_memory" {
  description = "Memory in MB"
  type        = number
}

variable "storage_pool" {
  description = "Storage pool for LXC containers"
  type        = string
}

variable "container_disk_size" {
  description = "Disk size in GB"
  type        = string
}

variable "container_ip" {
  description = "Container IP address"
  type        = string
}

variable "container_gateway" {
  description = "Container gateway"
  type        = string
}

variable "container_name" {
  description = "LXC container name"
  type        = string
}

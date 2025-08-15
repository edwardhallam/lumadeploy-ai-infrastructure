# Proxmox Connection Variables
variable "proxmox_host" {
  description = "Proxmox host IP address or hostname"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox username (e.g., root@pam)"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "proxmox_port" {
  description = "Proxmox API port"
  type        = number
  default     = 8006
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

# Network Configuration
variable "network_gateway" {
  description = "Network gateway IP address"
  type        = string
}

variable "network_subnet" {
  description = "Network subnet in CIDR notation"
  type        = string
}

variable "dns_servers" {
  description = "List of DNS server IP addresses"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# Resource Allocation
variable "container_cpu_limit" {
  description = "CPU limit for containers"
  type        = number
  default     = 2
}

variable "container_memory_limit" {
  description = "Memory limit for containers in MB"
  type        = number
  default     = 4096
}

variable "container_storage_limit" {
  description = "Storage limit for containers in GB"
  type        = number
  default     = 20
}

# Storage Configuration
variable "storage_pool" {
  description = "Proxmox storage pool name"
  type        = string
  default     = "local-lvm"
}

# Container Configuration
variable "librechat_container_name" {
  description = "Name for the LibreChat container"
  type        = string
  default     = "librechat"
}

variable "mcp_server_container_name" {
  description = "Name for the MCP server container"
  type        = string
  default     = "mcp-server"
}

# Cloudflare Configuration (Optional)
variable "use_cloudflare" {
  description = "Whether to configure Cloudflare tunnel"
  type        = bool
  default     = false
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
  default     = ""
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = ""
}

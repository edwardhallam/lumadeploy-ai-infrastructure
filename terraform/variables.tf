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

variable "search_domain" {
  description = "Search domain for DNS resolution"
  type        = string
  default     = "local"
}

# Storage Configuration
variable "storage_pool" {
  description = "Proxmox storage pool name"
  type        = string
  default     = "local-lvm"
}

# VM Template Configuration
variable "vm_template" {
  description = "VM template to clone from"
  type        = string
  default     = "ubuntu-22.04-cloud"
}

variable "vm_user" {
  description = "Default VM user"
  type        = string
  default     = "ubuntu"
}

variable "vm_password" {
  description = "Default VM password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

# K3s Master/Control Plane Configuration
variable "k3s_master_cpu" {
  description = "CPU cores for K3s master node"
  type        = number
  default     = 2
}

variable "k3s_master_memory" {
  description = "Memory for K3s master node in MB"
  type        = number
  default     = 4096
}

variable "k3s_master_storage" {
  description = "Storage for K3s master node in GB"
  type        = number
  default     = 20
}

# K3s Worker Configuration
variable "k3s_worker_cpu" {
  description = "CPU cores for K3s worker nodes"
  type        = number
  default     = 4
}

variable "k3s_worker_memory" {
  description = "Memory for K3s worker nodes in MB"
  type        = number
  default     = 8192
}

variable "k3s_worker_storage" {
  description = "Storage for K3s worker nodes in GB"
  type        = number
  default     = 30
}

# Load Balancer Configuration
variable "k3s_lb_cpu" {
  description = "CPU cores for load balancer"
  type        = number
  default     = 1
}

variable "k3s_lb_memory" {
  description = "Memory for load balancer in MB"
  type        = number
  default     = 2048
}

variable "k3s_lb_storage" {
  description = "Storage for load balancer in GB"
  type        = number
  default     = 10
}

# K3s Cluster Configuration
variable "k3s_version" {
  description = "K3s version to install"
  type        = string
  default     = "v1.28.5+k3s1"
}

variable "k3s_token" {
  description = "K3s cluster token"
  type        = string
  sensitive   = true
}

variable "k3s_cluster_cidr" {
  description = "K3s cluster CIDR for pods"
  type        = string
  default     = "10.42.0.0/16"
}

variable "k3s_service_cidr" {
  description = "K3s service CIDR"
  type        = string
  default     = "10.43.0.0/16"
}

# MCP Server Configuration
variable "mcp_server_count" {
  description = "Number of MCP servers to deploy"
  type        = number
  default     = 5
}

variable "mcp_server_cpu_request" {
  description = "CPU request per MCP server (millicores)"
  type        = number
  default     = 500
}

variable "mcp_server_cpu_limit" {
  description = "CPU limit per MCP server (millicores)"
  type        = number
  default     = 1000
}

variable "mcp_server_memory_request" {
  description = "Memory request per MCP server in MB"
  type        = number
  default     = 512
}

variable "mcp_server_memory_limit" {
  description = "Memory limit per MCP server in MB"
  type        = number
  default     = 1024
}

# Ollama Configuration
variable "ollama_enabled" {
  description = "Whether to deploy Ollama"
  type        = bool
  default     = true
}

variable "ollama_cpu_request" {
  description = "CPU request for Ollama (millicores)"
  type        = number
  default     = 2000
}

variable "ollama_cpu_limit" {
  description = "CPU limit for Ollama (millicores)"
  type        = number
  default     = 4000
}

variable "ollama_memory_request" {
  description = "Memory request for Ollama in MB"
  type        = number
  default     = 8192
}

variable "ollama_memory_limit" {
  description = "Memory limit for Ollama in MB"
  type        = number
  default     = 16384
}

# LibreChat Configuration
variable "librechat_enabled" {
  description = "Whether to deploy LibreChat"
  type        = bool
  default     = true
}

variable "librechat_cpu_request" {
  description = "CPU request for LibreChat (millicores)"
  type        = number
  default     = 1000
}

variable "librechat_cpu_limit" {
  description = "CPU limit for LibreChat (millicores)"
  type        = number
  default     = 2000
}

variable "librechat_memory_request" {
  description = "Memory request for LibreChat in MB"
  type        = number
  default     = 2048
}

variable "librechat_memory_limit" {
  description = "Memory limit for LibreChat in MB"
  type        = number
  default     = 4096
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

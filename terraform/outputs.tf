# Container IP Addresses for Ansible
output "librechat_ip" {
  description = "IP address of the LibreChat container"
  value       = proxmox_lxc.librechat.network[0].ip
}

output "mcp_server_ip" {
  description = "IP address of the MCP server container"
  value       = proxmox_lxc.mcp_server.network[0].ip
}

output "monitoring_ip" {
  description = "IP address of the monitoring container"
  value       = proxmox_lxc.monitoring.network[0].ip
}

output "reverse_proxy_ip" {
  description = "IP address of the reverse proxy container"
  value       = proxmox_lxc.reverse_proxy.network[0].ip
}

# Container Status
output "librechat_status" {
  description = "Status of the LibreChat container"
  value       = proxmox_lxc.librechat.status
}

output "mcp_server_status" {
  description = "Status of the MCP server container"
  value       = proxmox_lxc.mcp_server.status
}

output "monitoring_status" {
  description = "Status of the monitoring container"
  value       = proxmox_lxc.monitoring.status
}

output "reverse_proxy_status" {
  description = "Status of the reverse proxy container"
  value       = proxmox_lxc.reverse_proxy.status
}

# Network Information
output "network_gateway" {
  description = "Network gateway IP address"
  value       = var.network_gateway
}

output "network_subnet" {
  description = "Network subnet in CIDR notation"
  value       = var.network_subnet
}

output "dns_servers" {
  description = "DNS server IP addresses"
  value       = var.dns_servers
}

# Infrastructure Summary
output "infrastructure_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    total_containers = 4
    total_cpu        = var.container_cpu_limit * 2 + 2       # 2 main containers + monitoring + proxy
    total_memory_mb  = var.container_memory_limit * 2 + 3072 # 2 main containers + monitoring + proxy
    total_storage_gb = var.container_storage_limit * 2 + 15  # 2 main containers + monitoring + proxy
    containers = {
      librechat     = proxmox_lxc.librechat.hostname
      mcp_server    = proxmox_lxc.mcp_server.hostname
      monitoring    = proxmox_lxc.monitoring.hostname
      reverse_proxy = proxmox_lxc.reverse_proxy.hostname
    }
  }
}

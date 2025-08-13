output "container_id" {
  description = "The ID of the created LXC container"
  value       = proxmox_lxc.librechat.vmid
}

output "container_ip" {
  description = "The IP address of the created LXC container"
  value       = proxmox_lxc.librechat.network[0].ip
}

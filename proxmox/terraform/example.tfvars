# Example terraform.tfvars - Copy this to terraform.tfvars and fill in your values

# Proxmox connection settings
proxmox_host = "your_proxmox_ip_here"
proxmox_user = "root@pam"
proxmox_password = "your_password_here"

# Container settings
container_id = 200
container_name = "librechat"
container_cores = 2
container_memory = 2048
container_disk_size = "10G"
container_ip = "your_container_ip_here/24"
container_gateway = "your_gateway_ip_here"

# Storage and networking
storage_pool = "local-lvm"
proxmox_node = "pve01"

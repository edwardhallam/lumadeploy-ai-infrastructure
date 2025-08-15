# Configure Proxmox Provider
provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  pm_api_token_id     = var.proxmox_user
  pm_api_token_secret = var.proxmox_password
  pm_tls_insecure    = true  # Set to false in production with proper certificates
}

# Create LXC container for LibreChat
resource "proxmox_lxc" "librechat" {
  target_node = var.proxmox_node
  hostname    = var.librechat_container_name
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  
  cores   = var.container_cpu_limit
  memory  = var.container_memory_limit
  swap    = var.container_memory_limit / 2
  
  rootfs {
    storage = var.storage_pool
    size    = "${var.container_storage_limit}G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = cidrhost(var.network_subnet, 10)  # Assign IP from subnet
    gw     = var.network_gateway
  }
  
  nameserver = join(" ", var.dns_servers)
  
  # SSH access for Ansible (commented out for now - will be configured via Ansible)
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")
  
  # Start container after creation
  start = true
  
  tags = "ai-infrastructure,librechat"
}

# Create LXC container for MCP Server
resource "proxmox_lxc" "mcp_server" {
  target_node = var.proxmox_node
  hostname    = var.mcp_server_container_name
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  
  cores   = var.container_cpu_limit
  memory  = var.container_memory_limit
  swap    = var.container_memory_limit / 2
  
  rootfs {
    storage = var.storage_pool
    size    = "${var.container_storage_limit}G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = cidrhost(var.network_subnet, 11)  # Assign IP from subnet
    gw     = var.network_gateway
  }
  
  nameserver = join(" ", var.dns_servers)
  
  # SSH access for Ansible (commented out for now - will be configured via Ansible)
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")
  
  # Start container after creation
  start = true
  
  tags = "ai-infrastructure,mcp-server"
}

# Create LXC container for monitoring/logging
resource "proxmox_lxc" "monitoring" {
  target_node = var.proxmox_node
  hostname    = "monitoring"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  
  cores   = 1
  memory  = 2048
  swap    = 1024
  
  rootfs {
    storage = var.storage_pool
    size    = "10G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = cidrhost(var.network_subnet, 12)  # Assign IP from subnet
    gw     = var.network_gateway
  }
  
  nameserver = join(" ", var.dns_servers)
  
  # SSH access for Ansible (commented out for now - will be configured via Ansible)
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")
  
  # Start container after creation
  start = true
  
  tags = "ai-infrastructure,monitoring"
}

# Create LXC container for reverse proxy/load balancer
resource "proxmox_lxc" "reverse_proxy" {
  target_node = var.proxmox_node
  hostname    = "reverse-proxy"
  ostemplate  = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  
  cores   = 1
  memory  = 1024
  swap    = 512
  
  rootfs {
    storage = var.storage_pool
    size    = "5G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = cidrhost(var.network_subnet, 13)  # Assign IP from subnet
    gw     = var.network_gateway
  }
  
  nameserver = join(" ", var.dns_servers)
  
  # SSH access for Ansible (commented out for now - will be configured via Ansible)
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")
  
  # Start container after creation
  start = true
  
  tags = "ai-infrastructure,reverse-proxy"
}

# Configure Proxmox Provider
provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  pm_api_token_id     = var.proxmox_user
  pm_api_token_secret = var.proxmox_password
  pm_tls_insecure     = true # Set to false in production with proper certificates
}

# Create K3s Master/Control Plane VM
resource "proxmox_vm_qemu" "k3s_master" {
  name        = "k3s-master"
  target_node = var.proxmox_node
  vmid        = 200

  # VM Configuration
  cores   = var.k3s_master_cpu
  memory  = var.k3s_master_memory
  sockets = 1

  # Disk Configuration
  disk {
    slot    = 0
    type    = "virtio"
    storage = var.storage_pool
    size    = "${var.k3s_master_storage}G"
    format  = "qcow2"
  }

  # Network Configuration
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain
  ipconfig0    = "ip=${cidrhost(var.network_subnet, 20)}/24,gw=${var.network_gateway}"

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=1,up=30"

  # Tags
  tags = "k3s,master,ai-infrastructure"
}

# Create K3s Worker Node 1
resource "proxmox_vm_qemu" "k3s_worker1" {
  name        = "k3s-worker1"
  target_node = var.proxmox_node
  vmid        = 201

  # VM Configuration
  cores   = var.k3s_worker_cpu
  memory  = var.k3s_worker_memory
  sockets = 1

  # Disk Configuration
  disk {
    slot    = 0
    type    = "virtio"
    storage = var.storage_pool
    size    = "${var.k3s_worker_storage}G"
    format  = "qcow2"
  }

  # Network Configuration
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain
  ipconfig0    = "ip=${cidrhost(var.network_subnet, 21)}/24,gw=${var.network_gateway}"

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=2,up=30"

  # Tags
  tags = "k3s,worker,ai-infrastructure"
}

# Create K3s Worker Node 2
resource "proxmox_vm_qemu" "k3s_worker2" {
  name        = "k3s-worker2"
  target_node = var.proxmox_node
  vmid        = 202

  # VM Configuration
  cores   = var.k3s_worker_cpu
  memory  = var.k3s_worker_memory
  sockets = 1

  # Disk Configuration
  disk {
    slot    = 0
    type    = "virtio"
    storage = var.storage_pool
    size    = "${var.k3s_worker_storage}G"
    format  = "qcow2"
  }

  # Network Configuration
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain
  ipconfig0    = "ip=${cidrhost(var.network_subnet, 22)}/24,gw=${var.network_gateway}"

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=2,up=30"

  # Tags
  tags = "k3s,worker,ai-infrastructure"
}

# Create HAProxy Load Balancer VM
resource "proxmox_vm_qemu" "k3s_loadbalancer" {
  name        = "k3s-lb"
  target_node = var.proxmox_node
  vmid        = 199

  # VM Configuration
  cores   = var.k3s_lb_cpu
  memory  = var.k3s_lb_memory
  sockets = 1

  # Disk Configuration
  disk {
    slot    = 0
    type    = "virtio"
    storage = var.storage_pool
    size    = "${var.k3s_lb_storage}G"
    format  = "qcow2"
  }

  # Network Configuration
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain
  ipconfig0    = "ip=${cidrhost(var.network_subnet, 15)}/24,gw=${var.network_gateway}"

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=0,up=30"

  # Tags
  tags = "k3s,loadbalancer,haproxy,ai-infrastructure"
}

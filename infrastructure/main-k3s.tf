# Proxmox provider configuration moved to providers.tf

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

  # Cloud-init configuration
  ipconfig0 = "ip=${cidrhost(var.network_subnet, 20)}/24,gw=${var.network_gateway}"

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=1,up=30"

  # Tags
  tags = "k3s,master,ai-infrastructure"
}

# Create K3s Worker VM 1
resource "proxmox_vm_qemu" "k3s_worker_1" {
  name        = "k3s-worker-1"
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

  # Cloud-init configuration
  ipconfig0 = "ip=${cidrhost(var.network_subnet, 21)}/24,gw=${var.network_gateway}"

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=2,up=30"

  # Tags
  tags = "k3s,worker,ai-infrastructure"

  # Depends on master
  depends_on = [proxmox_vm_qemu.k3s_master]
}

# Create K3s Worker VM 2
resource "proxmox_vm_qemu" "k3s_worker_2" {
  name        = "k3s-worker-2"
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

  # Cloud-init configuration
  ipconfig0 = "ip=${cidrhost(var.network_subnet, 22)}/24,gw=${var.network_gateway}"

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=3,up=30"

  # Tags
  tags = "k3s,worker,ai-infrastructure"

  # Depends on master
  depends_on = [proxmox_vm_qemu.k3s_master]
}

# Create Load Balancer VM (HAProxy/Nginx)
resource "proxmox_vm_qemu" "k3s_loadbalancer" {
  name        = "k3s-lb"
  target_node = var.proxmox_node
  vmid        = 210

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

  # Cloud-init configuration
  ipconfig0 = "ip=${cidrhost(var.network_subnet, 15)}/24,gw=${var.network_gateway}"

  # OS Configuration
  clone      = var.vm_template
  os_type    = "cloud-init"
  ciuser     = var.vm_user
  cipassword = var.vm_password

  # Cloud-init configuration
  nameserver   = join(" ", var.dns_servers)
  searchdomain = var.search_domain

  # SSH Keys
  sshkeys = var.ssh_public_key

  # Start VM after creation
  startup = "order=0,up=30"

  # Tags
  tags = "k3s,loadbalancer,ai-infrastructure"
}

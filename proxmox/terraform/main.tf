provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_api_token_id     = var.proxmox_user
  pm_api_token_secret = var.proxmox_password
  pm_tls_insecure     = true
}

resource "proxmox_lxc" "librechat" {
  target_node = var.proxmox_node
  vmid        = var.container_id
  hostname    = var.container_name
  ostemplate  = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  cores       = var.container_cores
  memory      = var.container_memory
  rootfs {
    storage = var.storage_pool
    size    = var.container_disk_size
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = var.container_ip
    gw     = var.container_gateway
  }
  # ssh_public_keys = file("~/.ssh/id_rsa.pub")
  onboot          = true
  unprivileged    = false
  tags            = "librechat,terraform,automated"
}

# K3s Cluster Outputs
output "k3s_master_ip" {
  description = "IP address of K3s master node"
  value       = proxmox_vm_qemu.k3s_master.network[0].cidr
}

output "k3s_worker_1_ip" {
  description = "IP address of K3s worker 1"
  value       = proxmox_vm_qemu.k3s_worker_1.network[0].cidr
}

output "k3s_worker_2_ip" {
  description = "IP address of K3s worker 2"
  value       = proxmox_vm_qemu.k3s_worker_2.network[0].cidr
}

output "k3s_loadbalancer_ip" {
  description = "IP address of K3s load balancer"
  value       = proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr
}

output "k3s_cluster_info" {
  description = "K3s cluster information"
  value = {
    master_ip      = split("/", proxmox_vm_qemu.k3s_master.network[0].cidr)[0]
    worker_1_ip    = split("/", proxmox_vm_qemu.k3s_worker_1.network[0].cidr)[0]
    worker_2_ip    = split("/", proxmox_vm_qemu.k3s_worker_2.network[0].cidr)[0]
    loadbalancer_ip = split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]
    cluster_cidr   = var.k3s_cluster_cidr
    service_cidr   = var.k3s_service_cidr
    version        = var.k3s_version
  }
}

output "ansible_inventory" {
  description = "Ansible inventory for K3s cluster"
  value = {
    k3s_master = {
      hosts = {
        "k3s-master" = {
          ansible_host = split("/", proxmox_vm_qemu.k3s_master.network[0].cidr)[0]
          ansible_user = var.vm_user
          node_role    = "master"
        }
      }
    }
    k3s_workers = {
      hosts = {
        "k3s-worker-1" = {
          ansible_host = split("/", proxmox_vm_qemu.k3s_worker_1.network[0].cidr)[0]
          ansible_user = var.vm_user
          node_role    = "worker"
        }
        "k3s-worker-2" = {
          ansible_host = split("/", proxmox_vm_qemu.k3s_worker_2.network[0].cidr)[0]
          ansible_user = var.vm_user
          node_role    = "worker"
        }
      }
    }
    k3s_loadbalancer = {
      hosts = {
        "k3s-lb" = {
          ansible_host = split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]
          ansible_user = var.vm_user
          node_role    = "loadbalancer"
        }
      }
    }
  }
}

output "kubeconfig_info" {
  description = "Information for accessing the K3s cluster"
  value = {
    server_url = "https://${split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]}:6443"
    master_ip  = split("/", proxmox_vm_qemu.k3s_master.network[0].cidr)[0]
    token_location = "/var/lib/rancher/k3s/server/node-token"
    kubeconfig_location = "/etc/rancher/k3s/k3s.yaml"
  }
}

output "service_endpoints" {
  description = "Expected service endpoints after deployment"
  value = {
    librechat_url = var.librechat_enabled ? "http://${split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]}/librechat" : null
    ollama_url    = var.ollama_enabled ? "http://${split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]}/ollama" : null
    mcp_servers   = [for i in range(var.mcp_server_count) : "http://${split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]}/mcp-server-${i + 1}"]
    kubernetes_dashboard = "https://${split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]}/dashboard"
  }
}

output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    cluster_nodes = {
      master    = "k3s-master (${split("/", proxmox_vm_qemu.k3s_master.network[0].cidr)[0]}) - ${var.k3s_master_cpu} cores, ${var.k3s_master_memory}MB"
      worker_1  = "k3s-worker-1 (${split("/", proxmox_vm_qemu.k3s_worker_1.network[0].cidr)[0]}) - ${var.k3s_worker_cpu} cores, ${var.k3s_worker_memory}MB"
      worker_2  = "k3s-worker-2 (${split("/", proxmox_vm_qemu.k3s_worker_2.network[0].cidr)[0]}) - ${var.k3s_worker_cpu} cores, ${var.k3s_worker_memory}MB"
      lb        = "k3s-lb (${split("/", proxmox_vm_qemu.k3s_loadbalancer.network[0].cidr)[0]}) - ${var.k3s_lb_cpu} cores, ${var.k3s_lb_memory}MB"
    }
    total_resources = {
      cpu_cores = var.k3s_master_cpu + (var.k3s_worker_cpu * 2) + var.k3s_lb_cpu
      memory_gb = (var.k3s_master_memory + (var.k3s_worker_memory * 2) + var.k3s_lb_memory) / 1024
      storage_gb = var.k3s_master_storage + (var.k3s_worker_storage * 2) + var.k3s_lb_storage
    }
    services = {
      mcp_servers = var.mcp_server_count
      ollama      = var.ollama_enabled
      librechat   = var.librechat_enabled
    }
  }
}

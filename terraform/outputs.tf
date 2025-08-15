# K3s Cluster Outputs
output "k3s_master_ip" {
  description = "IP address of K3s master node"
  value       = cidrhost(var.network_subnet, 20)
}

output "k3s_worker1_ip" {
  description = "IP address of K3s worker 1"
  value       = cidrhost(var.network_subnet, 21)
}

output "k3s_worker2_ip" {
  description = "IP address of K3s worker 2"
  value       = cidrhost(var.network_subnet, 22)
}

output "k3s_loadbalancer_ip" {
  description = "IP address of K3s load balancer"
  value       = cidrhost(var.network_subnet, 15)
}

output "k3s_cluster_info" {
  description = "K3s cluster information"
  value = {
    master_ip       = cidrhost(var.network_subnet, 20)
    worker1_ip      = cidrhost(var.network_subnet, 21)
    worker2_ip      = cidrhost(var.network_subnet, 22)
    loadbalancer_ip = cidrhost(var.network_subnet, 15)
    cluster_cidr    = var.k3s_cluster_cidr
    service_cidr    = var.k3s_service_cidr
  }
}

# Ansible Inventory Output
output "ansible_inventory" {
  description = "Ansible inventory in YAML format"
  value = yamlencode({
    all = {
      children = {
        k3s_masters = {
          hosts = {
            k3s-master = {
              ansible_host = cidrhost(var.network_subnet, 20)
              ansible_user = var.vm_user
            }
          }
        }
        k3s_workers = {
          hosts = {
            k3s-worker1 = {
              ansible_host = cidrhost(var.network_subnet, 21)
              ansible_user = var.vm_user
            }
            k3s-worker2 = {
              ansible_host = cidrhost(var.network_subnet, 22)
              ansible_user = var.vm_user
            }
          }
        }
        k3s_loadbalancers = {
          hosts = {
            k3s-lb = {
              ansible_host = cidrhost(var.network_subnet, 15)
              ansible_user = var.vm_user
            }
          }
        }
      }
    }
  })
}

# Kubeconfig Information
output "kubeconfig_info" {
  description = "Information for setting up kubeconfig"
  value = {
    server_url          = "https://${cidrhost(var.network_subnet, 15)}:6443"
    master_ip           = cidrhost(var.network_subnet, 20)
    kubeconfig_location = "/etc/rancher/k3s/k3s.yaml"
  }
}

# Service Endpoints
output "service_endpoints" {
  description = "Service endpoints for deployed applications"
  value = {
    librechat_url        = var.librechat_enabled ? "http://${cidrhost(var.network_subnet, 15)}/librechat" : null
    ollama_url           = var.ollama_enabled ? "http://${cidrhost(var.network_subnet, 15)}/ollama" : null
    mcp_servers          = [for i in range(var.mcp_server_count) : "http://${cidrhost(var.network_subnet, 15)}/mcp-server-${i + 1}"]
    kubernetes_dashboard = "https://${cidrhost(var.network_subnet, 15)}/dashboard"
  }
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    nodes = {
      master  = "k3s-master (${cidrhost(var.network_subnet, 20)}) - ${var.k3s_master_cpu} cores, ${var.k3s_master_memory}MB"
      worker1 = "k3s-worker1 (${cidrhost(var.network_subnet, 21)}) - ${var.k3s_worker_cpu} cores, ${var.k3s_worker_memory}MB"
      worker2 = "k3s-worker2 (${cidrhost(var.network_subnet, 22)}) - ${var.k3s_worker_cpu} cores, ${var.k3s_worker_memory}MB"
      lb      = "k3s-lb (${cidrhost(var.network_subnet, 15)}) - ${var.k3s_lb_cpu} cores, ${var.k3s_lb_memory}MB"
    }
    services = {
      librechat_enabled = var.librechat_enabled
      ollama_enabled    = var.ollama_enabled
      mcp_server_count  = var.mcp_server_count
    }
    network = {
      subnet           = var.network_subnet
      gateway          = var.network_gateway
      k3s_cluster_cidr = var.k3s_cluster_cidr
      k3s_service_cidr = var.k3s_service_cidr
    }
  }
}

# 🚀 K3s AI Infrastructure Platform

**Production-Ready Kubernetes Infrastructure for AI Services**

This repository provides a complete K3s-based infrastructure platform optimized for AI workloads, including MCP servers, Ollama, LibreChat, and more.

## 🎯 **What This Platform Provides**

Transform your Proxmox environment into a powerful AI infrastructure platform with:

### **🤖 AI Services**
- **LibreChat** - Self-hosted AI chat assistant with Ollama integration
- **Ollama** - Local LLM hosting (7B-30B parameter models)
- **5x MCP Servers** - Model Context Protocol servers for AI tools
- **Monitoring & Logging** - Prometheus, Grafana, and centralized logging

### **🏗️ Infrastructure Components**
- **K3s Cluster** - Lightweight Kubernetes (1 master + 2 workers)
- **HAProxy Load Balancer** - High-availability ingress
- **Longhorn Storage** - Distributed block storage
- **NGINX Ingress** - HTTP/HTTPS routing
- **Cert-Manager** - Automatic SSL certificates

## 🏗️ **Architecture Overview**

```
┌─────────────────────────────────────────────────────┐
│                 Proxmox Host                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │   HAProxy   │  │ K3s Master  │  │K3s Worker 1 │ │
│  │Load Balancer│  │Control Plane│  │   Nodes     │ │
│  │    VM       │  │     VM      │  │     VM      │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
│         │               │               │          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │   Ingress   │  │  AI Services│  │K3s Worker 2 │ │
│  │  :80/:443   │  │   Storage   │  │   Nodes     │ │
│  │             │  │   Monitoring│  │     VM      │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────┘
```

### **🔄 Service Flow**
```
User Request → HAProxy → NGINX Ingress → K3s Services → Pods
```

### **📊 Resource Allocation (After 64GB Upgrade)**
```
┌─────────────────────────────────────────┐
│     HP ENVY TE01 (i7-12700, 64GB)       │
├─────────────────────────────────────────┤
│ EXISTING WORKLOADS:                     │
│ ├── Plex:          4 cores, 8GB        │
│ ├── Ubuntu VM:     4 cores, 8GB        │
│ ├── HomeAssistant: 2 cores, 4GB        │
│ └── Original MCP:  1 core,  1GB        │
│                                         │
│ K3S CLUSTER:                            │
│ ├── HAProxy LB:    1 core,  2GB        │
│ ├── K3s Master:    2 cores, 4GB        │
│ ├── K3s Worker 1:  4 cores, 8GB        │
│ ├── K3s Worker 2:  4 cores, 8GB        │
│                                         │
│ K3S WORKLOADS:                          │
│ ├── 5x MCP Servers: 2.5 cores, 2.5GB  │
│ ├── Ollama:        2 cores, 16GB       │
│ ├── LibreChat:     1 core,  4GB        │
│ ├── MongoDB:       0.5 cores, 2GB      │
│ ├── MeiliSearch:   0.5 cores, 1GB      │
│ └── Monitoring:    0.5 cores, 2GB      │
│                                         │
│ TOTAL:            22 cores, 60.5GB     │
│ AVAILABLE:         -2 cores, 3.5GB     │
└─────────────────────────────────────────┘
```

## 🚀 **Quick Start**

### **Prerequisites**
- **64GB RAM upgrade** (ordered! ✅)
- **Proxmox VE 8.x** - Virtualization platform
- **Ubuntu 22.04 cloud template** - For VM deployment
- **SSH key pair** - For VM access
- **Terraform 1.7+** - Infrastructure provisioning
- **Ansible 8.6+** - Configuration management

### **Step 1: Configure Infrastructure**
```bash
# Clone and setup
git clone <your-repo>
cd infrastructure

# Run interactive setup
./setup.sh

# This will generate:
# - config/terraform.tfvars
# - config/ansible-vars.yml
# - SSH keys if needed
```

### **Step 2: Deploy K3s Infrastructure**
```bash
# Full deployment (recommended)
./deploy-k3s.sh deploy

# Or step-by-step:
./deploy-k3s.sh infra    # Deploy VMs with Terraform
./deploy-k3s.sh k3s      # Configure K3s with Ansible
./deploy-k3s.sh apps     # Deploy applications
```

### **Step 3: Access Your Services**
```bash
# Check deployment status
./deploy-k3s.sh check

# Your services will be available at:
# http://<load-balancer-ip>/librechat
# http://<load-balancer-ip>/ollama
# http://<load-balancer-ip>/mcp-server-1
# http://<load-balancer-ip>/mcp-server-2
# http://<load-balancer-ip>/mcp-server-3
# http://<load-balancer-ip>/mcp-server-4
# http://<load-balancer-ip>/mcp-server-5
```

## 🔧 **Configuration Options**

### **Terraform Variables (terraform.tfvars)**
```hcl
# Proxmox Connection
proxmox_host = "192.168.1.34"
proxmox_user = "root@pam!cursor-proxmox-management-tool"
proxmox_password = "your-api-token-secret"
proxmox_node = "pve01"

# Network Configuration
network_gateway = "192.168.1.1"
network_subnet = "192.168.1.0/24"
dns_servers = ["8.8.8.8", "8.8.4.4"]

# K3s Cluster Resources
k3s_master_cpu = 2
k3s_master_memory = 4096
k3s_worker_cpu = 4
k3s_worker_memory = 8192

# MCP Server Configuration
mcp_server_count = 5
mcp_server_cpu_request = 500    # millicores
mcp_server_memory_request = 512 # MB

# Ollama Configuration
ollama_enabled = true
ollama_cpu_request = 2000       # millicores
ollama_memory_request = 8192    # MB
```

### **Ansible Variables (ansible-vars.yml)**
```yaml
# K3s Configuration
k3s_version: "v1.28.5+k3s1"
k3s_token: "your-secure-cluster-token"
k3s_cluster_cidr: "10.42.0.0/16"
k3s_service_cidr: "10.43.0.0/16"

# Application Configuration
librechat_enabled: true
ollama_enabled: true
mcp_server_count: 5

# Storage Configuration
storage_class: "longhorn"
backup_enabled: true
```

## 📊 **Service Management**

### **MCP Servers**
```bash
# Generate additional MCP servers
cd k8s
./generate-mcp-servers.sh 10  # Generate 10 servers

# Deploy new servers
kubectl apply -f mcp-servers-generated/all-mcp-servers.yaml

# Check MCP server status
kubectl get pods -n mcp-servers
kubectl get services -n mcp-servers
kubectl get ingress -n mcp-servers
```

### **Ollama Model Management**
```bash
# Access Ollama pod
kubectl exec -it -n ai-infrastructure deployment/ollama -- /bin/bash

# Download models
ollama pull llama2:7b
ollama pull codellama:7b
ollama pull mistral:7b

# List installed models
ollama list

# Test model
ollama run llama2:7b "Hello, how are you?"
```

### **LibreChat Configuration**
```bash
# Access LibreChat logs
kubectl logs -n ai-infrastructure deployment/librechat

# Scale LibreChat
kubectl scale -n ai-infrastructure deployment/librechat --replicas=2

# Update LibreChat image
kubectl set image -n ai-infrastructure deployment/librechat librechat=ghcr.io/danny-avila/librechat:latest
```

## 🔍 **Monitoring & Troubleshooting**

### **Cluster Health**
```bash
# Check cluster status
kubectl get nodes -o wide
kubectl get pods --all-namespaces
kubectl top nodes
kubectl top pods --all-namespaces

# Check resource usage
kubectl describe node <node-name>
kubectl describe pod -n <namespace> <pod-name>
```

### **Service Debugging**
```bash
# Check service endpoints
kubectl get endpoints --all-namespaces

# Check ingress status
kubectl describe ingress -n <namespace> <ingress-name>

# View service logs
kubectl logs -n <namespace> deployment/<deployment-name> --tail=100 -f
```

### **HAProxy Load Balancer**
```bash
# Access HAProxy stats
# http://<load-balancer-ip>:8404/stats

# Check HAProxy logs
ssh ubuntu@<load-balancer-ip> sudo journalctl -u haproxy -f

# Reload HAProxy config
ssh ubuntu@<load-balancer-ip> sudo systemctl reload haproxy
```

## 🔄 **Scaling Operations**

### **Add More MCP Servers**
```bash
# Generate more servers
cd k8s
./generate-mcp-servers.sh 8  # Scale to 8 servers

# Apply new configuration
kubectl apply -f mcp-servers-generated/all-mcp-servers.yaml
```

### **Scale Existing Services**
```bash
# Scale LibreChat
kubectl scale -n ai-infrastructure deployment/librechat --replicas=3

# Scale Ollama (not recommended - stateful)
kubectl scale -n ai-infrastructure deployment/ollama --replicas=1
```

### **Add Worker Nodes**
```bash
# Update terraform.tfvars to add more workers
# Then run:
cd terraform
terraform plan -var-file="../config/terraform.tfvars"
terraform apply
```

## 🛠️ **Maintenance Operations**

### **Backup**
```bash
# Backup Longhorn volumes
kubectl create -n longhorn-system job backup-job --from=cronjob/backup-cronjob

# Backup K3s cluster state
kubectl get all --all-namespaces -o yaml > cluster-backup.yaml
```

### **Updates**
```bash
# Update K3s version
# Edit ansible-vars.yml with new k3s_version
ansible-playbook -i ansible/inventory/hosts.yml ansible/site-k3s.yml

# Update application images
kubectl set image -n ai-infrastructure deployment/ollama ollama=ollama/ollama:latest
```

### **Cleanup**
```bash
# Remove specific applications
kubectl delete -f k8s/librechat.yaml

# Remove entire cluster
./deploy-k3s.sh cleanup
```

## 🎯 **Performance Tuning**

### **Resource Optimization**
```bash
# Adjust resource requests/limits
kubectl patch -n mcp-servers deployment/mcp-server-1 -p '{"spec":{"template":{"spec":{"containers":[{"name":"mcp-server","resources":{"requests":{"cpu":"250m","memory":"256Mi"}}}]}}}}'

# Enable horizontal pod autoscaling
kubectl autoscale -n ai-infrastructure deployment/librechat --cpu-percent=70 --min=1 --max=3
```

### **Storage Optimization**
```bash
# Check storage usage
kubectl get pvc --all-namespaces
kubectl exec -n longhorn-system deployment/longhorn-manager -- longhorn-manager volume list

# Resize PVC
kubectl patch pvc -n ai-infrastructure ollama-data -p '{"spec":{"resources":{"requests":{"storage":"100Gi"}}}}'
```

## 🎉 **Next Steps After Memory Upgrade**

Once your 64GB RAM arrives:

1. **Install Memory** - Power down, install 3x16GB sticks
2. **Verify Capacity** - Boot and check `free -h` shows ~64GB
3. **Deploy K3s** - Run `./deploy-k3s.sh deploy`
4. **Test Services** - Access all URLs and verify functionality
5. **Scale Up** - Add more MCP servers as needed

**Your infrastructure will be production-ready for serious AI workloads!** 🚀

## 📞 **Support**

For issues or questions:
- Check logs: `kubectl logs -n <namespace> <pod>`
- Review status: `kubectl describe <resource>`
- Monitor resources: `kubectl top nodes/pods`

**Happy AI Infrastructure Building!** 🎉✨

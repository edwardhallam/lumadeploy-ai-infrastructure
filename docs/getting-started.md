# 🚀 Getting Started with LumaDeploy AI Service Builder

Welcome to **LumaDeploy** - your AI-powered infrastructure platform! This guide will walk you through setting up your own AI infrastructure on Proxmox with the help of Cursor AI.

## 🎯 **What You'll Build**

By the end of this guide, you'll have:

- **☸️ K3s Kubernetes Cluster** - Modern container orchestration
- **🧠 Ollama** - Local LLM hosting with your choice of models
- **💬 LibreChat** - ChatGPT-like web interface for your AI models
- **🔌 MCP Servers** - Model Context Protocol servers for AI tool integration
- **📊 Monitoring Stack** - Prometheus + Grafana for observability
- **🔐 Security Features** - Automated secret protection and access control

## 📋 **Prerequisites**

### **Hardware Requirements**
- **Proxmox VE Server** (7.0+ recommended)
- **32GB+ RAM** (64GB recommended for multiple LLMs)
- **500GB+ Storage** (SSD recommended)
- **8+ CPU Cores** (16+ recommended)
- **Network Access** to your Proxmox server

### **Software Requirements**
- **Cursor IDE** - Your AI coding assistant
- **Git** - Version control system
- **Python 3.8+** - For automation scripts
- **SSH Access** to your Proxmox server

### **Knowledge Requirements**
- **Basic Linux** - Command line familiarity
- **Basic Networking** - IP addresses, subnets
- **Proxmox Basics** - How to access the web interface

*Don't worry if you're not an expert - Cursor will help you with everything!*

## 🚀 **Quick Start (5 Minutes)**

### **Step 1: Clone LumaDeploy**
```bash
git clone https://github.com/your-username/lumadeploy-ai-service-builder.git
cd lumadeploy-ai-service-builder
```

### **Step 2: Run Interactive Setup**
```bash
./setup.sh
```

The setup script will:
- ✅ Check prerequisites
- ✅ Set up Python environment
- ✅ Configure security features
- ✅ Guide you through configuration
- ✅ Generate all necessary files

### **Step 3: Ask Cursor for Help**
Open the project in Cursor and ask:

> **"Help me set up LumaDeploy on my Proxmox server"**

Cursor will guide you through:
- Understanding your hardware requirements
- Configuring Proxmox connection
- Planning your AI services
- Deploying your infrastructure

### **Step 4: Deploy Your Infrastructure**
```bash
make validate  # Check configuration
make plan      # Preview deployment
make deploy    # Deploy everything!
```

## 🔧 **Detailed Setup Process**

### **1. Proxmox Preparation**

#### **Create API Token**
1. Log into Proxmox web interface
2. Go to **Datacenter → Permissions → API Tokens**
3. Click **Add** and create a new token
4. **Save the token ID and secret** - you'll need these!

#### **Verify Resources**
Check your available resources:
- **RAM**: `free -h`
- **CPU**: `lscpu`
- **Storage**: `df -h`
- **Network**: Ensure bridge `vmbr0` exists

**💡 Ask Cursor**: *"Help me check if my Proxmox server has enough resources for AI workloads"*

### **2. Network Planning**

#### **IP Address Planning**
Plan your IP addresses (example for 192.168.1.0/24):
- **HAProxy LB**: 192.168.1.19
- **K3s Master**: 192.168.1.20
- **K3s Worker 1**: 192.168.1.21
- **K3s Worker 2**: 192.168.1.22

#### **DNS Configuration**
- Use your router's DNS or public DNS (8.8.8.8, 8.8.4.4)
- Ensure all VMs can resolve external domains

**💡 Ask Cursor**: *"Help me plan the network configuration for my LumaDeploy cluster"*

### **3. Configuration Walkthrough**

The setup script will ask for:

#### **Proxmox Settings**
- **Host**: Your Proxmox server IP
- **Node**: Usually "pve01" or similar
- **API Token**: The token you created
- **Storage Pool**: Usually "local-lvm"

#### **Network Settings**
- **Gateway**: Your router IP
- **Subnet**: Your network range
- **DNS Servers**: Domain name servers

#### **Resource Allocation**
- **CPU Cores**: How many cores for K3s
- **Memory**: How much RAM for K3s
- **Storage**: Disk space for VMs

#### **AI Services**
- **Ollama**: Enable local LLM hosting
- **LibreChat**: Enable web chat interface
- **MCP Servers**: Number of AI tool servers

**💡 Ask Cursor**: *"Help me understand these configuration options and choose the right values"*

## 🎯 **Deployment Options**

### **Option 1: Full Deployment (Recommended)**
Deploy everything at once:
```bash
make deploy
```

### **Option 2: Step-by-Step Deployment**
Deploy components individually:
```bash
# 1. Infrastructure only
cd terraform && terraform apply -target=proxmox_vm_qemu.k3s_master

# 2. K3s cluster
ansible-playbook ansible/site.yml

# 3. AI services
kubectl apply -f kubernetes/
```

### **Option 3: Development Mode**
Deploy minimal setup for testing:
```bash
# Edit config/terraform.tfvars
k3s_worker_count = 1
mcp_server_count = 2
```

**💡 Ask Cursor**: *"Which deployment option is best for my use case?"*

## 📊 **Monitoring Your Deployment**

### **Check Deployment Status**
```bash
make status                    # Overall status
kubectl get nodes             # K3s cluster status
kubectl get pods -A           # All running services
```

### **Access Your Services**
After deployment, access your services:
- **LibreChat**: `http://your-haproxy-ip/chat`
- **Grafana**: `http://your-haproxy-ip/grafana`
- **Prometheus**: `http://your-haproxy-ip/prometheus`
- **HAProxy Stats**: `http://your-haproxy-ip:8080`

### **View Logs**
```bash
make logs                     # Deployment logs
kubectl logs -f deployment/ollama -n ollama
kubectl logs -f deployment/librechat -n librechat
```

**💡 Ask Cursor**: *"Help me check if my deployment is working correctly"*

## 🔧 **Common Customizations**

### **Add More AI Models**
Edit `config/ansible-vars.yml`:
```yaml
ollama:
  models:
    - "llama3.1:8b"
    - "llama3.1:70b"      # Add larger model
    - "codellama:13b"     # Add code model
    - "mistral:7b"
```

### **Scale MCP Servers**
Edit `config/terraform.tfvars`:
```hcl
mcp_server_count = 10  # Increase from 5 to 10
```

### **Adjust Resources**
Edit VM resources in `config/terraform.tfvars`:
```hcl
k3s_worker_memory_mb = 16384  # Increase to 16GB
k3s_worker_cpu_cores = 8      # Increase to 8 cores
```

**💡 Ask Cursor**: *"Help me customize my LumaDeploy configuration for my specific needs"*

## 🚨 **Troubleshooting**

### **Common Issues**

#### **Terraform Errors**
```bash
# Check Proxmox connection
terraform plan -var-file="config/terraform.tfvars"

# Common fixes
terraform init
terraform refresh
```

#### **Ansible Failures**
```bash
# Check SSH connectivity
ansible all -i ansible/inventory -m ping

# Run with verbose output
ansible-playbook -vvv ansible/site.yml
```

#### **Kubernetes Issues**
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# Check pod status
kubectl describe pod <pod-name>
```

**💡 Ask Cursor**: *"Help me troubleshoot this specific error message"*

### **Getting Help**

1. **Ask Cursor First** - Your AI assistant knows LumaDeploy
2. **Check Logs** - Use `make logs` and `kubectl logs`
3. **Review Documentation** - Check other files in `docs/`
4. **GitHub Issues** - Report bugs and get community help

## 🎉 **Next Steps**

Once your deployment is complete:

1. **🧠 Configure AI Models** - Add your preferred LLMs to Ollama
2. **💬 Customize LibreChat** - Set up your chat interface
3. **🔌 Develop MCP Tools** - Create custom AI integrations
4. **📊 Set Up Monitoring** - Configure alerts and dashboards
5. **🔐 Harden Security** - Review and enhance security settings

**💡 Ask Cursor**: *"What should I do next with my LumaDeploy deployment?"*

---

**🚀 Ready to build your AI infrastructure? Let's get started!**

*Remember: Cursor is your AI assistant throughout this entire process. Don't hesitate to ask for help!*

#!/bin/bash
# LumaDeploy AI Service Builder - Interactive Setup Script
# This script helps you configure and deploy your AI infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Banner
print_banner() {
    echo -e "${PURPLE}"
    cat << "EOF"
    ██╗     ██╗   ██╗███╗   ███╗ █████╗ ██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗   ██╗
    ██║     ██║   ██║████╗ ████║██╔══██╗██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗╚██╗ ██╔╝
    ██║     ██║   ██║██╔████╔██║███████║██║  ██║█████╗  ██████╔╝██║     ██║   ██║ ╚████╔╝
    ██║     ██║   ██║██║╚██╔╝██║██╔══██║██║  ██║██╔══╝  ██╔═══╝ ██║     ██║   ██║  ╚██╔╝
    ███████╗╚██████╔╝██║ ╚═╝ ██║██║  ██║██████╔╝███████╗██║     ███████╗╚██████╔╝   ██║
    ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝    ╚═╝

                            AI Service Builder
EOF
    echo -e "${NC}"
    echo -e "${CYAN}🚀 Professional AI Infrastructure Platform with Cursor-Guided Deployment${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_cursor_tip() {
    echo -e "${PURPLE}[CURSOR TIP]${NC} $1"
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "README.md" ]] || [[ ! -d "terraform" ]]; then
        print_error "Please run this script from the LumaDeploy root directory"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    print_status "🔍 Checking prerequisites..."

    local missing_tools=()

    # Check for required tools
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi

    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi

    if ! command -v terraform &> /dev/null; then
        print_warning "Terraform not found. You'll need it for infrastructure deployment."
        print_cursor_tip "Ask Cursor: 'Help me install Terraform on my system'"
    fi

    if ! command -v ansible &> /dev/null; then
        print_warning "Ansible not found. You'll need it for configuration management."
        print_cursor_tip "Ask Cursor: 'Help me install Ansible on my system'"
    fi

    if ! command -v kubectl &> /dev/null; then
        print_warning "kubectl not found. You'll need it for Kubernetes management."
        print_cursor_tip "Ask Cursor: 'Help me install kubectl on my system'"
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_cursor_tip "Ask Cursor: 'Help me install the missing prerequisites for LumaDeploy'"
        exit 1
    fi

    print_success "All basic prerequisites found"
}

# Setup Python virtual environment
setup_python_env() {
    print_status "🐍 Setting up Python environment..."

    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
        print_success "Created Python virtual environment"
    fi

    source venv/bin/activate

    if [[ -f "proxmox/python-tools/requirements.txt" ]]; then
        pip install -r proxmox/python-tools/requirements.txt
        print_success "Installed Python dependencies"
    fi
}

# Setup security
setup_security() {
    print_status "🔐 Setting up security features..."

    if [[ -f "setup-security.sh" ]]; then
        print_cursor_tip "Running security setup. This will install git-secrets and configure pre-commit hooks."
        ./setup-security.sh
    else
        print_warning "Security setup script not found. Manual security configuration may be needed."
    fi
}

# Interactive configuration
interactive_config() {
    print_status "⚙️ Interactive Configuration Setup"
    echo ""
    print_cursor_tip "You can ask Cursor to help you with any of these configuration questions!"
    echo ""

    # Proxmox Configuration
    echo -e "${CYAN}📡 Proxmox Configuration${NC}"
    echo "Please provide your Proxmox server details:"
    echo ""

    read -p "Proxmox host IP or hostname: " proxmox_host
    read -p "Proxmox node name (default: pve01): " proxmox_node
    proxmox_node=${proxmox_node:-pve01}

    read -p "Proxmox API token ID (root@pam!token-name): " proxmox_user
    read -s -p "Proxmox API token secret: " proxmox_password
    echo ""

    # Network Configuration
    echo ""
    echo -e "${CYAN}🌐 Network Configuration${NC}"
    read -p "Network gateway (e.g., 192.168.1.1): " network_gateway
    read -p "Network subnet (e.g., 192.168.1.0/24): " network_subnet

    # Resource Configuration
    echo ""
    echo -e "${CYAN}💾 Resource Configuration${NC}"
    read -p "Storage pool name (default: local-lvm): " storage_pool
    storage_pool=${storage_pool:-local-lvm}

    read -p "Total CPU cores available for K3s (default: 10): " total_cpu
    total_cpu=${total_cpu:-10}

    read -p "Total memory available for K3s in GB (default: 24): " total_memory_gb
    total_memory_gb=${total_memory_gb:-24}
    total_memory=$((total_memory_gb * 1024))

    # AI Services Configuration
    echo ""
    echo -e "${CYAN}🤖 AI Services Configuration${NC}"
    read -p "Deploy Ollama for local LLMs? (y/n, default: y): " deploy_ollama
    deploy_ollama=${deploy_ollama:-y}

    read -p "Deploy LibreChat web interface? (y/n, default: y): " deploy_librechat
    deploy_librechat=${deploy_librechat:-y}

    read -p "Number of MCP servers to deploy (default: 5): " mcp_count
    mcp_count=${mcp_count:-5}

    # Generate configuration files
    generate_terraform_config
    generate_ansible_config

    print_success "Configuration files generated successfully!"
    print_cursor_tip "Your configuration is ready! Ask Cursor: 'Help me review and deploy my LumaDeploy configuration'"
}

# Generate Terraform configuration
generate_terraform_config() {
    print_status "📝 Generating Terraform configuration..."

    cat > config/terraform.tfvars << EOF
# LumaDeploy AI Service Builder - Generated Configuration
# Generated on $(date)

# Proxmox Connection
proxmox_host     = "$proxmox_host"
proxmox_port     = 8006
proxmox_node     = "$proxmox_node"
proxmox_user     = "$proxmox_user"
proxmox_password = "$proxmox_password"

# Network Configuration
network_gateway = "$network_gateway"
network_subnet  = "$network_subnet"
dns_servers     = ["8.8.8.8", "8.8.4.4"]

# Storage Configuration
storage_pool = "$storage_pool"

# K3s Cluster Configuration
k3s_master_vm_name    = "k3s-master"
k3s_master_cpu_cores  = 2
k3s_master_memory_mb  = 4096
k3s_master_disk_gb    = 30

k3s_worker_count      = 2
k3s_worker_vm_name    = "k3s-worker"
k3s_worker_cpu_cores  = 4
k3s_worker_memory_mb  = 8192
k3s_worker_disk_gb    = 50

# HAProxy Load Balancer
haproxy_lb_container_name = "haproxy-lb"
haproxy_lb_cpu_cores      = 1
haproxy_lb_memory_mb      = 2048
haproxy_lb_disk_gb        = 10

# VM Authentication
vm_username       = "ubuntu"
vm_password       = "lumadeploy-$(date +%s)"
vm_ssh_public_key = "$(cat ~/.ssh/id_rsa.pub 2>/dev/null || echo 'REPLACE-WITH-YOUR-SSH-PUBLIC-KEY')"

# IP Address Allocation
k3s_master_ip_offset   = 20
k3s_worker_ip_offset   = 21
haproxy_lb_ip_offset   = 19

# AI Services Configuration
ollama_enabled    = $([ "$deploy_ollama" = "y" ] && echo "true" || echo "false")
librechat_enabled = $([ "$deploy_librechat" = "y" ] && echo "true" || echo "false")
mcp_server_count  = $mcp_count

# Resource Limits
total_cpu_limit    = $total_cpu
total_memory_limit = $total_memory
EOF
}

# Generate Ansible configuration
generate_ansible_config() {
    print_status "📝 Generating Ansible configuration..."

    cat > config/ansible-vars.yml << EOF
# LumaDeploy AI Service Builder - Generated Configuration
# Generated on $(date)

# K3s Cluster Configuration
k3s_version: "v1.29.4+k3s1"
k3s_token: "lumadeploy-$(openssl rand -hex 16)"
k3s_cluster_cidr: "10.42.0.0/16"
k3s_service_cidr: "10.43.0.0/16"

# HAProxy Configuration
haproxy_frontend_port: 6443
haproxy_backend_port: 6443
haproxy_stats_port: 8080
haproxy_stats_user: "admin"
haproxy_stats_password: "lumadeploy-$(openssl rand -hex 8)"

# Ollama Configuration
ollama:
  enabled: $([ "$deploy_ollama" = "y" ] && echo "true" || echo "false")
  models:
    - "llama3.1:8b"
    - "codellama:7b"
  memory_limit: "8Gi"
  cpu_limit: "4"

# LibreChat Configuration
librechat:
  enabled: $([ "$deploy_librechat" = "y" ] && echo "true" || echo "false")
  admin_email: "admin@lumadeploy.local"
  app_title: "LumaDeploy AI Chat"

# MCP Servers Configuration
mcp_servers:
  count: $mcp_count
  base_port: 3000
  memory_limit: "1Gi"
  cpu_limit: "500m"

# Monitoring Configuration
monitoring:
  prometheus:
    enabled: true
    retention: "30d"
  grafana:
    enabled: true
    admin_password: "lumadeploy-$(openssl rand -hex 8)"

# Security Configuration
security:
  firewall_enabled: true
  ssh_port: 22
  fail2ban_enabled: true
EOF
}

# Create Makefile for easy commands
create_makefile() {
    print_status "📋 Creating Makefile for easy commands..."

    cat > Makefile << 'EOF'
# LumaDeploy AI Service Builder - Makefile
# Use these commands to manage your AI infrastructure

.PHONY: help setup validate plan deploy status logs destroy clean

# Default target
help:
	@echo "🚀 LumaDeploy AI Service Builder"
	@echo ""
	@echo "Available commands:"
	@echo "  make setup     - Run interactive setup"
	@echo "  make validate  - Validate Terraform and Ansible configs"
	@echo "  make plan      - Plan Terraform deployment"
	@echo "  make deploy    - Deploy infrastructure"
	@echo "  make status    - Check infrastructure status"
	@echo "  make logs      - View deployment logs"
	@echo "  make destroy   - Destroy infrastructure"
	@echo "  make clean     - Clean temporary files"
	@echo ""
	@echo "💡 Ask Cursor: 'Help me understand these LumaDeploy commands'"

setup:
	@echo "🔧 Running LumaDeploy setup..."
	./setup.sh

validate:
	@echo "✅ Validating configuration..."
	@cd terraform && terraform fmt -check
	@cd terraform && terraform validate
	@ansible-playbook --syntax-check ansible/site.yml
	@echo "✅ Configuration is valid"

plan:
	@echo "📋 Planning deployment..."
	@cd terraform && terraform init
	@cd terraform && terraform plan -var-file="../config/terraform.tfvars"

deploy:
	@echo "🚀 Deploying LumaDeploy infrastructure..."
	./scripts/deploy.sh

status:
	@echo "📊 Checking infrastructure status..."
	@cd terraform && terraform show
	@kubectl get nodes 2>/dev/null || echo "Kubernetes not accessible"

logs:
	@echo "📝 Viewing deployment logs..."
	@tail -f /tmp/lumadeploy-deploy.log 2>/dev/null || echo "No deployment logs found"

destroy:
	@echo "💥 Destroying infrastructure..."
	@read -p "Are you sure you want to destroy the infrastructure? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	@cd terraform && terraform destroy -var-file="../config/terraform.tfvars"

clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -rf terraform/.terraform
	@rm -f terraform/terraform.tfstate*
	@rm -f /tmp/lumadeploy-*.log
	@echo "✅ Cleanup complete"
EOF

    print_success "Makefile created"
}

# Show next steps
show_next_steps() {
    echo ""
    echo -e "${GREEN}🎉 LumaDeploy Setup Complete!${NC}"
    echo ""
    echo -e "${CYAN}📋 Next Steps:${NC}"
    echo ""
    echo "1. 📝 Review your configuration:"
    echo "   - config/terraform.tfvars"
    echo "   - config/ansible-vars.yml"
    echo ""
    echo "2. 🔍 Validate your setup:"
    echo "   make validate"
    echo ""
    echo "3. 📋 Plan your deployment:"
    echo "   make plan"
    echo ""
    echo "4. 🚀 Deploy your AI infrastructure:"
    echo "   make deploy"
    echo ""
    echo "5. 📊 Monitor your deployment:"
    echo "   make status"
    echo ""
    echo -e "${PURPLE}💡 Cursor Integration:${NC}"
    echo "Ask Cursor any of these questions:"
    echo "• 'Help me review my LumaDeploy configuration'"
    echo "• 'Guide me through deploying my AI infrastructure'"
    echo "• 'Help me troubleshoot any deployment issues'"
    echo "• 'Show me how to access my deployed AI services'"
    echo ""
    echo -e "${YELLOW}⚠️  Important:${NC}"
    echo "• Keep your API tokens and passwords secure"
    echo "• Review the generated configuration before deployment"
    echo "• Ensure your Proxmox server has sufficient resources"
    echo ""
    print_cursor_tip "Ready to deploy? Ask Cursor: 'Help me deploy LumaDeploy step by step'"
}

# Main execution
main() {
    print_banner

    print_status "🚀 Welcome to LumaDeploy AI Service Builder Setup!"
    echo ""
    print_cursor_tip "This setup will help you configure your AI infrastructure. Ask Cursor for help anytime!"
    echo ""

    check_directory
    check_prerequisites
    setup_python_env
    setup_security
    interactive_config
    create_makefile
    show_next_steps
}

# Run main function
main "$@"

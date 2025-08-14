#!/bin/bash

# AI Infrastructure Platform Setup Script - GitOps Edition
# ======================================================
# This script is designed to work seamlessly with Cursor's AI assistance
# Cursor will guide users through this process and generate IaC configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3.8+ first."
        print_cursor_tip "Ask Cursor: 'Help me install Python 3.8+ on my system'"
        exit 1
    fi
    
    # Check Python version
    PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
        print_success "Python $PYTHON_VERSION detected ✓"
    else
        print_error "Python 3.8+ required, found $PYTHON_VERSION"
        print_cursor_tip "Ask Cursor: 'Help me upgrade Python to version 3.8 or higher'"
        exit 1
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please install Git first."
        print_cursor_tip "Ask Cursor: 'Help me install Git on my system'"
        exit 1
    fi
    print_success "Git detected ✓"
    
    # Check Make
    if ! command -v make &> /dev/null; then
        print_warning "Make is not installed. Installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install make
            else
                print_error "Please install Homebrew first: https://brew.sh/"
                print_cursor_tip "Ask Cursor: 'Help me install Homebrew and then Make on macOS'"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y make
            elif command -v yum &> /dev/null; then
                sudo yum install -y make
            else
                print_error "Please install make manually for your distribution"
                print_cursor_tip "Ask Cursor: 'Help me install Make on my Linux distribution'"
                exit 1
            fi
        fi
    fi
    print_success "Make detected ✓"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_warning "Terraform is not installed. Installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew tap hashicorp/tap
                brew install hashicorp/tap/terraform
            else
                print_error "Please install Homebrew first: https://brew.sh/"
                print_cursor_tip "Ask Cursor: 'Help me install Homebrew and then Terraform on macOS'"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install terraform
        fi
    fi
    print_success "Terraform detected ✓"
    
    # Check Ansible
    if ! command -v ansible &> /dev/null; then
        print_warning "Ansible is not installed. Installing..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install ansible
            else
                print_error "Please install Homebrew first: https://brew.sh/"
                print_cursor_tip "Ask Cursor: 'Help me install Homebrew and then Ansible on macOS'"
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo apt-add-repository --yes --update ppa:ansible/ansible
            sudo apt-get install -y ansible
        fi
    fi
    print_success "Ansible detected ✓"
}

# Function to install Python dependencies
install_dependencies() {
    print_status "Installing Python dependencies..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        print_status "Creating Python virtual environment..."
        python3 -m venv venv
        print_success "Virtual environment created ✓"
        print_cursor_tip "Cursor will automatically activate this environment for you"
    fi
    
    # Activate virtual environment and install dependencies
    if [ -f "requirements.txt" ]; then
        print_status "Installing Python dependencies in virtual environment..."
        source venv/bin/activate
        python3 -m pip install -r requirements.txt
        print_success "Python dependencies installed ✓"
    else
        print_warning "No requirements.txt found, skipping Python dependencies"
    fi
}

# Function to get user input with validation
get_input() {
    local prompt="$1"
    local default="$2"
    local validation="$3"
    local env_var="$4"
    local cursor_help="$5"
    
    # Check if environment variable is set (for non-interactive mode)
    if [ -n "$env_var" ] && [ -n "${!env_var}" ]; then
        echo "${!env_var}"
        return 0
    fi
    
    # Show Cursor help if provided
    if [ -n "$cursor_help" ]; then
        print_cursor_tip "$cursor_help"
    fi
    
    while true; do
        if [ -n "$default" ]; then
            read -p "$prompt [$default]: " input
            input=${input:-$default}
        else
            read -p "$prompt: " input
        fi
        
        if [ -n "$validation" ]; then
            if eval "$validation"; then
                break
            else
                print_error "Invalid input. Please try again."
                print_cursor_tip "Ask Cursor for help with this configuration"
            fi
        else
            break
        fi
    done
    
    echo "$input"
}

# Function to validate IP address
validate_ip() {
    local ip="$1"
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra ADDR <<< "$ip"
        for i in "${ADDR[@]}"; do
            if [ "$i" -gt 255 ] || [ "$i" -lt 0 ]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# Function to validate subnet
validate_subnet() {
    local subnet="$1"
    if [[ $subnet =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        return 0
    fi
    return 1
}

# Function to create Terraform variables file
create_terraform_vars() {
    print_status "Creating Terraform variables file..."
    
    cat > infrastructure/config/terraform.tfvars << EOF
# Proxmox Configuration
proxmox_host = "$PROXMOX_HOST"
proxmox_user = "$PROXMOX_USER"
proxmox_password = "$PROXMOX_PASS"
proxmox_node = "$PROXMOX_NODE"
proxmox_port = 8006

# Network Configuration
network_gateway = "$NETWORK_GATEWAY"
network_subnet = "$NETWORK_SUBNET"
dns_servers = ["$DNS_SERVERS"]

# Resource Allocation
container_cpu_limit = $CONTAINER_CPU_LIMIT
container_memory_limit = $CONTAINER_MEMORY_LIMIT
container_storage_limit = $CONTAINER_STORAGE_LIMIT

# Storage Configuration
storage_pool = "$STORAGE_POOL"

# Container Configuration
librechat_container_name = "$LIBRECHAT_CONTAINER_NAME"
mcp_server_container_name = "$MCP_SERVER_CONTAINER_NAME"

# Cloudflare Configuration
use_cloudflare = $USE_CLOUDFLARE
cloudflare_zone_id = "$CLOUDFLARE_ZONE_ID"
cloudflare_account_id = "$CLOUDFLARE_ACCOUNT_ID"
EOF

    print_success "Terraform variables file created ✓"
    print_cursor_tip "Cursor can help you modify these settings later if needed"
}

# Function to create Ansible variables file
create_ansible_vars() {
    print_status "Creating Ansible variables file..."
    
    cat > infrastructure/config/ansible-vars.yml << EOF
---
# Ansible Variables for AI Infrastructure Platform

# Proxmox Connection
proxmox_host: "$PROXMOX_HOST"
proxmox_user: "$PROXMOX_USER"
proxmox_node: "$PROXMOX_NODE"

# Network Configuration
network_gateway: "$NETWORK_GATEWAY"
network_subnet: "$NETWORK_SUBNET"
dns_servers: ["$DNS_SERVERS"]

# Container Configuration
librechat:
  container_name: "$LIBRECHAT_CONTAINER_NAME"
  web_port: 3000
  admin_email: "admin@example.com"
  admin_password: "changeme123"

mcp_server:
  container_name: "$MCP_SERVER_CONTAINER_NAME"
  api_port: 8000
  model_name: "gpt-3.5-turbo"
  api_key: "your-openai-api-key"

monitoring:
  container_name: "monitoring"
  prometheus_port: 9090
  grafana_port: 3000
  grafana_admin_password: "changeme123"

reverse_proxy:
  container_name: "reverse-proxy"
  http_port: 80
  https_port: 443
  ssl_cert_email: "admin@example.com"

# Security Configuration
security:
  firewall_enabled: true
  ssh_port: 22
  allowed_ports: [80, 443, 3000, 8000, 9090]
  
# Backup Configuration
backup:
  enabled: true
  retention_days: 7
  schedule: "0 2 * * *"  # Daily at 2 AM
EOF

    print_success "Ansible variables file created ✓"
}

# Function to create environment file for local development
create_env_file() {
    print_status "Creating environment configuration..."
    
    cat > .env << EOF
# AI Infrastructure Platform Configuration
# ======================================
# Generated by setup.sh - DO NOT edit manually
# Cursor will help you modify this file if needed

# Environment
ENVIRONMENT=production
PROJECT_NAME=ai-infrastructure
LOG_LEVEL=INFO

# Proxmox Configuration
PROXMOX_HOST=$PROXMOX_HOST
PROXMOX_USER=$PROXMOX_USER
PROXMOX_PASS=$PROXMOX_PASS
PROXMOX_NODE=$PROXMOX_NODE
PROXMOX_PORT=8006

# Network Configuration
NETWORK_GATEWAY=$NETWORK_GATEWAY
NETWORK_SUBNET=$NETWORK_SUBNET
DNS_SERVERS=$DNS_SERVERS

# Resource Allocation
CONTAINER_CPU_LIMIT=$CONTAINER_CPU_LIMIT
CONTAINER_MEMORY_LIMIT=$CONTAINER_MEMORY_LIMIT
CONTAINER_STORAGE_LIMIT=$CONTAINER_STORAGE_LIMIT

# Storage Configuration
STORAGE_POOL=$STORAGE_POOL

# Container Names
LIBRECHAT_CONTAINER_NAME=$LIBRECHAT_CONTAINER_NAME
MCP_SERVER_CONTAINER_NAME=$MCP_SERVER_CONTAINER_NAME

# Cloudflare Configuration
USE_CLOUDFLARE=$USE_CLOUDFLARE
CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN
CLOUDFLARE_ZONE_ID=$CLOUDFLARE_ZONE_ID
CLOUDFLARE_ACCOUNT_ID=$CLOUDFLARE_ACCOUNT_ID

# Security Settings
SECURITY_SCAN_ENABLED=true
SECURITY_ALERT_LEVEL=medium

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_RETENTION_DAYS=7
EOF

    print_success "Environment file created ✓"
}

# Function to create Makefile
create_makefile() {
    print_status "Creating Makefile..."
    
    cat > Makefile << 'EOF'
# AI Infrastructure Platform Makefile - GitOps Edition
# ===================================================
# Cursor will help you use these commands

.PHONY: setup deploy destroy status logs help plan validate

setup:
	@echo "🚀 Setting up AI Infrastructure Platform..."
	@chmod +x setup.sh
	@./setup.sh

plan:
	@echo "📋 Planning infrastructure deployment..."
	@cd infrastructure/terraform && terraform plan -var-file="../config/terraform.tfvars"

validate:
	@echo "🔍 Validating configuration..."
	@cd infrastructure/terraform && terraform validate
	@cd infrastructure/ansible && ansible-playbook --syntax-check site.yml

deploy:
	@echo "🚀 Deploying AI infrastructure..."
	@echo "💡 This will trigger GitHub Actions to deploy your infrastructure"
	@echo "📝 Make sure to commit and push your configuration changes first:"
	@echo "   git add infrastructure/config/"
	@echo "   git commit -m 'Deploy AI infrastructure'"
	@echo "   git push origin main"

destroy:
	@echo "🗑️  Destroying infrastructure..."
	@echo "⚠️  WARNING: This will permanently delete all infrastructure!"
	@echo "💡 Use GitHub Actions to destroy infrastructure safely"
	@echo "   Go to Actions tab and run the 'destroy' workflow"

status:
	@echo "📊 Checking infrastructure status..."
	@cd infrastructure/terraform && terraform show

logs:
	@echo "📋 Showing deployment logs..."
	@echo "💡 Check GitHub Actions for deployment logs:"
	@echo "   https://github.com/$(shell git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^/]*\).*/\1/')/actions"

test-connection:
	@echo "🧪 Testing Proxmox connection..."
	@cd infrastructure/terraform && terraform output

activate:
	@echo "🐍 Activating Python virtual environment..."
	@echo "Run: source venv/bin/activate"
	@echo "Then you can use python3 commands directly"

help:
	@echo "AI Infrastructure Platform Commands (GitOps Edition):"
	@echo "===================================================="
	@echo "  setup             Interactive configuration setup"
	@echo "  plan              Plan Terraform deployment"
	@echo "  validate          Validate Terraform and Ansible configs"
	@echo "  deploy            Deploy via GitHub Actions (commit & push)"
	@echo "  destroy           Destroy via GitHub Actions"
	@echo "  status            Show infrastructure status"
	@echo "  logs              Show deployment logs (GitHub Actions)"
	@echo "  test-connection   Test Proxmox connectivity"
	@echo "  activate          Show how to activate virtual environment"
	@echo "  help              Show this help message"
	@echo ""
	@echo "💡 Tip: Ask Cursor to help you with any of these commands!"
	@echo "🚀 GitOps Workflow: Edit config → Commit → Push → Auto-deploy"
EOF

    print_success "Makefile created ✓"
}

# Function to create requirements.txt
create_requirements() {
    print_status "Creating Python requirements..."
    
    cat > requirements.txt << 'EOF'
# AI Infrastructure Platform Dependencies
# ======================================
# Cursor will help you install and manage these dependencies

# Core dependencies
requests>=2.31.0
pyyaml>=6.0
urllib3>=2.0.0
python-dotenv>=1.0.0
pydantic>=2.0.0

# Proxmox API
proxmoxer>=1.4.0

# Cloudflare integration
cloudflare>=2.19.0

# Logging and monitoring
structlog>=23.0.0
colorama>=0.4.6

# Development and testing (optional)
pytest>=7.0.0
pytest-cov>=4.0.0
EOF

    print_success "Requirements file created ✓"
}

# Function to create main.py
create_main_py() {
    print_status "Creating main deployment script..."
    
    cat > main.py << 'EOF'
#!/usr/bin/env python3
"""
AI Infrastructure Platform - Main Deployment Script (GitOps Edition)
==================================================================
Handles the deployment and management of AI infrastructure on Proxmox.
This script is now primarily for local development and testing.
For production deployment, use the GitOps workflow with GitHub Actions.
Cursor will help you use this script and understand the GitOps process.
"""

import os
import sys
import logging
import argparse
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('deployment.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

def plan():
    """Plan Terraform deployment."""
    logger.info("📋 Planning Terraform deployment...")
    
    # TODO: Implement Terraform plan execution
    logger.info("💡 Use 'make plan' or GitHub Actions for Terraform planning")
    logger.info("💡 Ask Cursor: 'Help me plan the Terraform deployment'")

def deploy():
    """Deploy the AI infrastructure via GitOps."""
    logger.info("🚀 Starting AI infrastructure deployment via GitOps...")
    
    # Validate configuration
    if not validate_config():
        logger.error("❌ Configuration validation failed")
        logger.info("💡 Ask Cursor to help you fix the configuration")
        sys.exit(1)
    
    logger.info("✅ Configuration validated!")
    logger.info("💡 To deploy, commit and push your changes:")
    logger.info("   git add infrastructure/config/")
    logger.info("   git commit -m 'Deploy AI infrastructure'")
    logger.info("   git push origin main")
    logger.info("💡 GitHub Actions will automatically deploy your infrastructure")

def destroy():
    """Destroy infrastructure via GitOps."""
    logger.info("🗑️  To destroy infrastructure, use GitHub Actions:")
    logger.info("💡 Go to Actions tab and run the 'destroy' workflow")
    logger.info("💡 This ensures safe, tracked infrastructure removal")

def status():
    """Check infrastructure status."""
    logger.info("📊 Checking infrastructure status...")
    
    # TODO: Implement status checking
    logger.info("💡 Use 'make status' or check GitHub Actions for deployment status")
    logger.info("💡 Ask Cursor: 'Help me check the infrastructure status'")

def logs():
    """Show deployment logs."""
    logger.info("📋 For deployment logs, check GitHub Actions:")
    logger.info("💡 https://github.com/[your-repo]/actions")
    logger.info("💡 This provides the complete deployment history and logs")

def test_connection():
    """Test Proxmox connection."""
    logger.info("🧪 Testing Proxmox connectivity...")
    
    # TODO: Implement actual Proxmox connection test
    logger.info("💡 Use 'make test-connection' to test Proxmox connectivity")
    logger.info("💡 Ask Cursor: 'Help me test the Proxmox connection'")

def validate_config():
    """Validate configuration files."""
    logger.info("🔍 Validating configuration...")
    
    required_files = [
        'infrastructure/config/terraform.tfvars',
        'infrastructure/config/ansible-vars.yml',
        '.env'
    ]
    
    missing_files = []
    for file_path in required_files:
        if not Path(file_path).exists():
            missing_files.append(file_path)
    
    if missing_files:
        logger.error(f"Missing required configuration files: {', '.join(missing_files)}")
        logger.info("💡 Run './setup.sh' to generate configuration files")
        logger.info("💡 Ask Cursor: 'Help me run the setup script'")
        return False
    
    logger.info("✅ Configuration validation passed!")
    return True

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='AI Infrastructure Platform (GitOps Edition)')
    parser.add_argument('command', choices=['plan', 'deploy', 'destroy', 'status', 'logs', 'test-connection'],
                       help='Command to execute')
    
    args = parser.parse_args()
    
    try:
        if args.command == 'plan':
            plan()
        elif args.command == 'deploy':
            deploy()
        elif args.command == 'destroy':
            destroy()
        elif args.command == 'status':
            status()
        elif args.command == 'logs':
            logs()
        elif args.command == 'test-connection':
            test_connection()
    except KeyboardInterrupt:
        logger.info("🛑 Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Error: {e}")
        logger.info("💡 Ask Cursor to help you resolve this error")
        sys.exit(1)

if __name__ == '__main__':
    main()
EOF

    print_success "Main deployment script created ✓"
}

# Function to create documentation
create_docs() {
    print_status "Creating documentation..."
    
    mkdir -p docs
    
    # Create GitOps guide
    cat > docs/gitops-guide.md << 'EOF'
# GitOps Deployment Guide

## Overview

This platform uses GitOps principles for infrastructure deployment. Changes are committed to source control and then automatically deployed via GitHub Actions.

## Workflow

1. **Edit Configuration**: Modify files in `infrastructure/config/`
2. **Commit Changes**: `git add infrastructure/config/ && git commit -m "Update config"`
3. **Push to Deploy**: `git push origin main` triggers GitHub Actions
4. **Monitor Deployment**: Check GitHub Actions tab for progress

## Configuration Files

- **`terraform.tfvars`**: Terraform variables for Proxmox infrastructure
- **`ansible-vars.yml`**: Ansible variables for service configuration
- **`.env`**: Local environment variables

## GitHub Actions

- **Validate**: Checks configuration syntax
- **Plan**: Shows what will be deployed
- **Deploy**: Applies infrastructure changes
- **Destroy**: Removes infrastructure (manual trigger)

## Benefits

- **Audit Trail**: All changes tracked in git
- **Rollback**: Revert to previous configurations
- **Collaboration**: Multiple users can contribute
- **Automation**: No manual deployment steps
EOF

    # Create troubleshooting guide
    cat > docs/troubleshooting.md << 'EOF'
# Troubleshooting Guide

## Getting Help with Cursor

**The best way to get help is to ask Cursor directly!**

### Common Issues and Solutions

#### Configuration Issues

**Missing Configuration Files**
- Run `./setup.sh` to generate configuration files
- Check that `infrastructure/config/` directory exists
- Verify all required files are present
- **Ask Cursor**: "Help me generate the configuration files"

**Terraform Validation Errors**
- Run `make validate` to check syntax
- Check Terraform and Ansible file formats
- Verify variable references
- **Ask Cursor**: "Help me fix the Terraform validation errors"

#### Deployment Issues

**GitHub Actions Failures**
- Check the Actions tab in GitHub
- Review error logs and messages
- Verify secrets are configured correctly
- **Ask Cursor**: "Help me troubleshoot the GitHub Actions failure"

**Proxmox Connection Issues**
- Verify Proxmox credentials in GitHub secrets
- Check network connectivity
- Ensure Proxmox API is accessible
- **Ask Cursor**: "Help me fix the Proxmox connection issue"

#### GitOps Workflow Issues

**Changes Not Deploying**
- Ensure you're pushing to the main branch
- Check that configuration files are in the right paths
- Verify GitHub Actions are enabled
- **Ask Cursor**: "Help me understand why my changes aren't deploying"

## Getting Help

1. **Ask Cursor first** - It's your AI assistant and knows this platform
2. Check GitHub Actions logs
3. Review this troubleshooting guide
4. Open a GitHub issue with error details

## Cursor Commands

**Ask Cursor to:**
- "Help me understand the GitOps workflow"
- "Guide me through committing and pushing changes"
- "Help me troubleshoot this deployment error"
- "Explain what this GitHub Actions log means"
EOF

    # Create API reference
    cat > docs/api.md << 'EOF'
# API Reference

## Commands

### `make plan`
Plans the Terraform deployment.

**Usage:**
```bash
make plan
```

**What it does:**
- Validates Terraform configuration
- Shows what infrastructure will be created
- Does not make any changes

**Ask Cursor**: "Help me plan the infrastructure deployment"

### `make deploy`
Deploys the infrastructure via GitOps.

**Usage:**
```bash
make deploy
```

**What it does:**
- Guides you through the GitOps workflow
- Explains commit and push process
- Triggers GitHub Actions deployment

**Ask Cursor**: "Help me deploy the infrastructure"

### `make validate`
Validates all configuration files.

**Usage:**
```bash
make validate
```

**What it does:**
- Checks Terraform syntax
- Validates Ansible playbooks
- Ensures configuration is correct

**Ask Cursor**: "Help me validate the configuration"

## GitOps Workflow

### Configuration Management
- Edit files in `infrastructure/config/`
- Commit changes with descriptive messages
- Push to trigger automatic deployment

### Monitoring Deployment
- Check GitHub Actions tab
- Review deployment logs
- Monitor infrastructure status

## Getting Help

**Ask Cursor for help with any command:**
- "What does this command do?"
- "Help me run this command"
- "What's the output mean?"
- "Help me fix this error"
EOF

    # Create architecture guide
    cat > docs/architecture.md << 'EOF'
# Architecture Overview

## System Components

### Infrastructure Layer (Terraform)
- **Proxmox Provider**: Manages Proxmox VE resources
- **LXC Containers**: Lightweight virtualization for AI workloads
- **Network Configuration**: Bridges, IP addresses, subnets
- **Storage Management**: Storage pools and volumes

### Application Layer (Ansible)
- **Container Configuration**: OS setup and package installation
- **Service Deployment**: LibreChat, MCP server, monitoring
- **Security Hardening**: Firewall rules and access control
- **Monitoring Setup**: Logging and health checks

### Orchestration Layer (GitHub Actions)
- **Configuration Validation**: Syntax and format checking
- **Infrastructure Planning**: Terraform plan generation
- **Automated Deployment**: Terraform apply and Ansible execution
- **Status Monitoring**: Deployment progress tracking

## Deployment Flow

1. **Configuration**: User edits configuration files (with Cursor's help)
2. **Commit**: Changes committed to git repository
3. **Validation**: GitHub Actions validates configuration
4. **Planning**: Terraform generates deployment plan
5. **Provisioning**: Terraform creates Proxmox infrastructure
6. **Configuration**: Ansible configures services and applications
7. **Verification**: Deployment status and health checks

## Resource Requirements

- **Minimum**: 2 CPU cores, 4GB RAM, 20GB storage
- **Recommended**: 4 CPU cores, 8GB RAM, 50GB storage
- **Production**: 8+ CPU cores, 16GB+ RAM, 100GB+ storage

## Getting Help

**Ask Cursor to explain:**
- "How does the GitOps workflow work?"
- "What resources do I need?"
- "How is the deployment process structured?"
- "What are the security features?"
EOF

    print_success "Documentation created ✓"
}

# Main setup function
main() {
    echo "🚀 AI Infrastructure Platform Setup - GitOps Edition"
    echo "===================================================="
    echo ""
    echo "💡 This setup is designed to work with Cursor's AI assistance"
    echo "   Cursor will guide you through the process and help with any issues"
    echo ""
    echo "🏗️  This version uses GitOps principles:"
    echo "   - Configuration committed to git"
    echo "   - GitHub Actions trigger deployment"
    echo "   - Full audit trail of changes"
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Install dependencies
    install_dependencies
    
    echo ""
    print_status "Starting interactive configuration..."
    print_cursor_tip "Cursor will help you with each configuration step"
    echo ""
    
    # Get Proxmox configuration
    echo "🔧 Proxmox Configuration"
    echo "========================"
    
    PROXMOX_HOST=$(get_input "Enter Proxmox host IP address" "" "validate_ip" "PROXMOX_HOST" "Ask Cursor: 'What IP address should I use for my Proxmox host?'")
    PROXMOX_USER=$(get_input "Enter Proxmox username" "root@pam" "" "PROXMOX_USER" "Ask Cursor: 'What username should I use for Proxmox authentication?'")
    PROXMOX_PASS=$(get_input "Enter Proxmox password" "" "" "PROXMOX_PASS" "Ask Cursor: 'Where can I find my Proxmox password?'")
    PROXMOX_NODE=$(get_input "Enter Proxmox node name" "pve" "" "PROXMOX_NODE" "Ask Cursor: 'How do I find my Proxmox node name?'")
    
    echo ""
    echo "🌐 Network Configuration"
    echo "========================"
    
    NETWORK_GATEWAY=$(get_input "Enter network gateway IP" "192.168.1.1" "validate_ip" "NETWORK_GATEWAY" "Ask Cursor: 'How do I find my network gateway IP address?'")
    NETWORK_SUBNET=$(get_input "Enter network subnet (CIDR)" "192.168.1.0/24" "validate_subnet" "NETWORK_SUBNET" "Ask Cursor: 'What subnet should I use for my network configuration?'")
    DNS_SERVERS=$(get_input "Enter DNS servers (comma-separated)" "8.8.8.8,8.8.4.4" "" "DNS_SERVERS" "Ask Cursor: 'What DNS servers should I use? Can I use Google's 8.8.8.8?'")
    
    echo ""
    echo "⚙️  Resource Configuration"
    echo "=========================="
    
    CONTAINER_CPU_LIMIT=$(get_input "Enter CPU limit per container" "2" "" "CONTAINER_CPU_LIMIT" "Ask Cursor: 'How many CPU cores should each container have?'")
    CONTAINER_MEMORY_LIMIT=$(get_input "Enter memory limit per container (MB)" "4096" "" "CONTAINER_MEMORY_LIMIT" "Ask Cursor: 'How much memory should each container have?'")
    CONTAINER_STORAGE_LIMIT=$(get_input "Enter storage limit per container (GB)" "20" "" "CONTAINER_STORAGE_LIMIT" "Ask Cursor: 'How much storage should each container have?'")
    STORAGE_POOL=$(get_input "Enter Proxmox storage pool name" "local-lvm" "" "STORAGE_POOL" "Ask Cursor: 'What storage pool should I use on Proxmox?'")
    
    echo ""
    echo "🏷️  Container Configuration"
    echo "==========================="
    
    LIBRECHAT_CONTAINER_NAME=$(get_input "Enter LibreChat container name" "librechat" "" "LIBRECHAT_CONTAINER_NAME" "Ask Cursor: 'What should I name the LibreChat container?'")
    MCP_SERVER_CONTAINER_NAME=$(get_input "Enter MCP server container name" "mcp-server" "" "MCP_SERVER_CONTAINER_NAME" "Ask Cursor: 'What should I name the MCP server container?'")
    
    echo ""
    echo "☁️  Cloudflare Configuration (Optional)"
    echo "======================================"
    echo "You can skip this section and configure later if needed."
    
    USE_CLOUDFLARE=$(get_input "Use Cloudflare tunnel? (y/n)" "n" "" "USE_CLOUDFLARE" "Ask Cursor: 'What is Cloudflare tunnel and do I need it?'")
    
    if [[ "$USE_CLOUDFLARE" =~ ^[Yy]$ ]]; then
        CLOUDFLARE_API_TOKEN=$(get_input "Enter Cloudflare API token" "" "" "CLOUDFLARE_API_TOKEN" "Ask Cursor: 'How do I create a Cloudflare API token?'")
        CLOUDFLARE_ZONE_ID=$(get_input "Enter Cloudflare zone ID" "" "" "CLOUDFLARE_ZONE_ID" "Ask Cursor: 'Where can I find my Cloudflare zone ID?'")
        CLOUDFLARE_ACCOUNT_ID=$(get_input "Enter Cloudflare account ID" "" "" "CLOUDFLARE_ACCOUNT_ID" "Ask Cursor: 'How do I find my Cloudflare account ID?'")
    else
        CLOUDFLARE_API_TOKEN=""
        CLOUDFLARE_ZONE_ID=""
        CLOUDFLARE_ACCOUNT_ID=""
    fi
    
    echo ""
    print_status "Creating configuration files..."
    
    # Create all necessary files
    create_terraform_vars
    create_ansible_vars
    create_env_file
    create_makefile
    create_requirements
    create_main_py
    create_docs
    
    echo ""
    print_success "Setup completed successfully! 🎉"
    echo ""
    echo "💡 Next steps with Cursor:"
    echo "1. Ask Cursor to review your configuration"
    echo "2. Ask Cursor to help you commit and push:"
    echo "   git add infrastructure/config/"
    echo "   git commit -m 'Initial AI infrastructure configuration'"
    echo "   git push origin main"
    echo "3. Ask Cursor to monitor the GitHub Actions deployment"
    echo ""
    echo "🔧 Available commands:"
    echo "  make help          - Show all available commands"
    echo "  make plan          - Plan Terraform deployment"
    echo "  make validate      - Validate configuration"
    echo "  make deploy        - Deploy via GitOps (commit & push)"
    echo ""
    echo "💬 Need help? Ask Cursor:"
    echo "  'Help me understand the GitOps workflow'"
    echo "  'Help me commit and push my configuration'"
    echo "  'Help me monitor the deployment'"
    echo ""
    echo "🚀 GitOps Workflow: Edit config → Commit → Push → Auto-deploy"
    echo "Happy deploying with Cursor and GitOps! 🎉"
}

# Run main function
main "$@"

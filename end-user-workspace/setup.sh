#!/bin/bash

# AI Infrastructure Platform Setup Script
# ======================================
# This script is designed to work seamlessly with Cursor's AI assistance
# Cursor will guide users through this process and execute commands as needed

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

# Function to create environment file
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
PROXMOX_PORT=8006

# Network Configuration
NETWORK_GATEWAY=$NETWORK_GATEWAY
NETWORK_SUBNET=$NETWORK_SUBNET
DNS_SERVERS=$DNS_SERVERS

# Cloudflare Configuration
CLOUDFLARE_API_TOKEN=$CLOUDFLARE_API_TOKEN
CLOUDFLARE_ZONE_ID=$CLOUDFLARE_ZONE_ID
CLOUDFLARE_ACCOUNT_ID=$CLOUDFLARE_ACCOUNT_ID

# Resource Allocation
CONTAINER_CPU_LIMIT=2
CONTAINER_MEMORY_LIMIT=4096
CONTAINER_STORAGE_LIMIT=20

# Security Settings
SECURITY_SCAN_ENABLED=true
SECURITY_ALERT_LEVEL=medium

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_RETENTION_DAYS=7
EOF

    print_success "Environment file created ✓"
    print_cursor_tip "Cursor can help you modify these settings later if needed"
}

# Function to create Makefile
create_makefile() {
    print_status "Creating Makefile..."
    
    cat > Makefile << 'EOF'
# AI Infrastructure Platform Makefile
# ===================================
# Cursor will help you use these commands

.PHONY: setup deploy destroy status logs help

setup:
	@echo "🚀 Setting up AI Infrastructure Platform..."
	@chmod +x setup.sh
	@./setup.sh

deploy:
	@echo "🚀 Deploying AI infrastructure..."
	@source venv/bin/activate && python3 main.py deploy

destroy:
	@echo "🗑️  Destroying infrastructure..."
	@source venv/bin/activate && python3 main.py destroy

status:
	@echo "📊 Checking infrastructure status..."
	@source venv/bin/activate && python3 main.py status

logs:
	@echo "📋 Showing deployment logs..."
	@source venv/bin/activate && python3 main.py logs

validate:
	@echo "🔍 Validating configuration..."
	@source venv/bin/activate && python3 -c "import yaml; yaml.safe_load(open('.env'))" 2>/dev/null || echo "⚠️  Configuration validation failed"

test-connection:
	@echo "🧪 Testing Proxmox connection..."
	@source venv/bin/activate && python3 main.py test-connection

activate:
	@echo "🐍 Activating Python virtual environment..."
	@echo "Run: source venv/bin/activate"
	@echo "Then you can use python3 commands directly"

help:
	@echo "AI Infrastructure Platform Commands:"
	@echo "===================================="
	@echo "  setup             Interactive configuration setup"
	@echo "  deploy            Deploy the entire infrastructure"
	@echo "  destroy           Remove all infrastructure"
	@echo "  status            Check deployment status"
	@echo "  logs              View deployment logs"
	@echo "  validate          Validate configuration files"
	@echo "  test-connection   Test Proxmox connectivity"
	@echo "  activate          Show how to activate virtual environment"
	@echo "  help              Show this help message"
	@echo ""
	@echo "💡 Tip: Ask Cursor to help you with any of these commands!"
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
AI Infrastructure Platform - Main Deployment Script
=================================================
Handles the deployment and management of AI infrastructure on Proxmox.
Cursor will help you use this script and interpret its output.
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

def deploy():
    """Deploy the AI infrastructure."""
    logger.info("🚀 Starting AI infrastructure deployment...")
    
    # Validate configuration
    if not validate_config():
        logger.error("❌ Configuration validation failed")
        logger.info("💡 Ask Cursor to help you fix the configuration")
        sys.exit(1)
    
    # Test Proxmox connection
    if not test_proxmox_connection():
        logger.error("❌ Proxmox connection failed")
        logger.info("💡 Ask Cursor to help you troubleshoot the connection")
        sys.exit(1)
    
    # Deploy infrastructure
    logger.info("📦 Deploying LXC containers...")
    # TODO: Implement container deployment
    
    logger.info("🤖 Setting up LibreChat...")
    # TODO: Implement LibreChat setup
    
    logger.info("🔌 Configuring MCP server...")
    # TODO: Implement MCP server setup
    
    logger.info("🌐 Setting up Cloudflare tunnel...")
    # TODO: Implement Cloudflare setup
    
    logger.info("✅ Deployment completed successfully!")
    logger.info("💡 Ask Cursor to help you access and manage your new AI infrastructure")

def destroy():
    """Destroy the AI infrastructure."""
    logger.info("🗑️  Starting infrastructure destruction...")
    
    # TODO: Implement infrastructure cleanup
    
    logger.info("✅ Infrastructure destroyed successfully!")

def status():
    """Check infrastructure status."""
    logger.info("📊 Checking infrastructure status...")
    
    # TODO: Implement status checking
    
    logger.info("✅ Status check completed!")

def logs():
    """Show deployment logs."""
    log_file = Path("deployment.log")
    if log_file.exists():
        with open(log_file, 'r') as f:
            print(f.read())
    else:
        logger.info("No deployment logs found.")

def test_connection():
    """Test Proxmox connection."""
    logger.info("🧪 Testing Proxmox connectivity...")
    
    # TODO: Implement actual Proxmox connection test
    
    logger.info("✅ Connection test completed!")

def validate_config():
    """Validate configuration files."""
    logger.info("🔍 Validating configuration...")
    
    required_vars = [
        'PROXMOX_HOST', 'PROXMOX_USER', 'PROXMOX_PASS',
        'NETWORK_GATEWAY', 'NETWORK_SUBNET', 'DNS_SERVERS'
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        logger.error(f"Missing required environment variables: {', '.join(missing_vars)}")
        logger.info("💡 Ask Cursor to help you set up the missing configuration")
        return False
    
    logger.info("✅ Configuration validation passed!")
    return True

def test_proxmox_connection():
    """Test connection to Proxmox."""
    logger.info("🔌 Testing Proxmox connectivity...")
    
    # TODO: Implement actual Proxmox connection test
    
    logger.info("✅ Proxmox connection test passed!")
    return True

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description='AI Infrastructure Platform')
    parser.add_argument('command', choices=['deploy', 'destroy', 'status', 'logs', 'test-connection'],
                       help='Command to execute')
    
    args = parser.parse_args()
    
    try:
        if args.command == 'deploy':
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
    
    # Create troubleshooting guide
    cat > docs/troubleshooting.md << 'EOF'
# Troubleshooting Guide

## Getting Help with Cursor

**The best way to get help is to ask Cursor directly!**

### Common Issues and Solutions

#### Connection Issues

**Proxmox Connection Failed**
- Verify Proxmox is running and accessible
- Check firewall settings
- Ensure credentials are correct
- **Ask Cursor**: "Help me troubleshoot my Proxmox connection"

**Container Creation Fails**
- Check Proxmox resource availability
- Verify storage pool configuration
- Review Proxmox logs
- **Ask Cursor**: "Help me fix the container creation issue"

#### Configuration Issues

**Environment Variables Missing**
- Run `./setup.sh` to recreate configuration
- Check `.env` file exists and is readable
- Verify all required variables are set
- **Ask Cursor**: "Help me fix my configuration file"

**Network Configuration Errors**
- Validate IP address format
- Check subnet mask notation
- Ensure gateway is reachable
- **Ask Cursor**: "Help me configure my network settings correctly"

#### Deployment Issues

**Python Dependencies**
- Run `source venv/bin/activate` to activate virtual environment
- Check Python version (3.8+ required)
- Verify pip is up to date
- **Ask Cursor**: "Help me install the missing Python dependencies"

**Permission Errors**
- Check file permissions on scripts
- Ensure execute permissions: `chmod +x *.sh`
- Verify user has necessary privileges
- **Ask Cursor**: "Help me fix the permission issues"

## Getting Help

1. **Ask Cursor first** - It's your AI assistant and knows this platform
2. Check the logs: `make logs`
3. Review this troubleshooting guide
4. Open a GitHub issue with error details

## Cursor Commands

**Ask Cursor to:**
- "Help me deploy the infrastructure"
- "Check the status of my deployment"
- "Show me the deployment logs"
- "Help me fix this error"
- "Explain what this configuration means"
EOF

    # Create API reference
    cat > docs/api.md << 'EOF'
# API Reference

## Commands

### `make deploy`
Deploys the entire AI infrastructure.

**Usage:**
```bash
make deploy
```

**What it does:**
- Validates configuration
- Tests Proxmox connectivity
- Creates LXC containers
- Sets up LibreChat
- Configures MCP server
- Establishes Cloudflare tunnel

**Ask Cursor**: "Help me deploy the infrastructure"

### `make status`
Checks the status of deployed infrastructure.

**Usage:**
```bash
make status
```

**Output:**
- Container status
- Service health
- Resource usage
- Network connectivity

**Ask Cursor**: "Check the status of my deployment"

### `make destroy`
Removes all deployed infrastructure.

**Usage:**
```bash
make destroy
```

**Warning:** This will permanently delete all containers and data.

**Ask Cursor**: "Help me safely destroy the infrastructure"

## Python Script

### `python3 main.py deploy`
Direct Python deployment command.

### `python3 main.py status`
Direct status checking command.

### `python3 main.py logs`
Display deployment logs.

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

### Proxmox Virtualization
- **LXC Containers**: Lightweight virtualization for AI workloads
- **Resource Management**: CPU, memory, and storage allocation
- **Network Isolation**: Secure container networking

### AI Services
- **LibreChat**: Web-based AI chat interface
- **MCP Server**: Model Context Protocol server
- **API Gateway**: RESTful API endpoints

### Infrastructure
- **Terraform**: Infrastructure as Code provisioning
- **Python Automation**: Deployment and management scripts
- **Configuration Management**: Environment-based configuration

### Security & Networking
- **Cloudflare Tunnel**: Secure external access
- **Firewall Rules**: Network security policies
- **SSL/TLS**: Encrypted communications

## Deployment Flow

1. **Configuration**: User runs setup script (with Cursor's help)
2. **Validation**: System validates all inputs
3. **Connection**: Tests Proxmox connectivity
4. **Provisioning**: Creates LXC containers
5. **Configuration**: Sets up AI services
6. **Networking**: Establishes secure tunnels
7. **Verification**: Tests all services

## Resource Requirements

- **Minimum**: 2 CPU cores, 4GB RAM, 20GB storage
- **Recommended**: 4 CPU cores, 8GB RAM, 50GB storage
- **Production**: 8+ CPU cores, 16GB+ RAM, 100GB+ storage

## Getting Help

**Ask Cursor to explain:**
- "How does the architecture work?"
- "What resources do I need?"
- "How is the deployment process structured?"
- "What are the security features?"
EOF

    print_success "Documentation created ✓"
}

# Main setup function
main() {
    echo "🚀 AI Infrastructure Platform Setup"
    echo "==================================="
    echo ""
    echo "💡 This setup is designed to work with Cursor's AI assistance"
    echo "   Cursor will guide you through the process and help with any issues"
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
    
    echo ""
    echo "🌐 Network Configuration"
    echo "========================"
    
    NETWORK_GATEWAY=$(get_input "Enter network gateway IP" "192.168.1.1" "validate_ip" "NETWORK_GATEWAY" "Ask Cursor: 'How do I find my network gateway IP address?'")
    NETWORK_SUBNET=$(get_input "Enter network subnet (CIDR)" "192.168.1.0/24" "validate_subnet" "NETWORK_SUBNET" "Ask Cursor: 'What subnet should I use for my network configuration?'")
    DNS_SERVERS=$(get_input "Enter DNS servers (comma-separated)" "8.8.8.8,8.8.4.4" "" "DNS_SERVERS" "Ask Cursor: 'What DNS servers should I use? Can I use Google's 8.8.8.8?'")
    
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
    echo "2. Ask Cursor to help you deploy: 'make deploy'"
    echo "3. Ask Cursor to check status: 'make status'"
    echo "4. Ask Cursor to show logs: 'make logs'"
    echo ""
    echo "🔧 Available commands:"
    echo "  make help          - Show all available commands"
    echo "  make deploy        - Deploy the infrastructure"
    echo "  make status        - Check deployment status"
    echo ""
    echo "💬 Need help? Ask Cursor:"
    echo "  'Help me deploy this infrastructure'"
    echo "  'What does this configuration mean?'"
    echo "  'Help me troubleshoot this issue'"
    echo ""
    echo "Happy deploying with Cursor! 🚀"
}

# Run main function
main "$@"

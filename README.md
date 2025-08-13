# Infrastructure Management

## Overview
Centralized management for Proxmox, LXC containers, and Cloudflare tunnels with automation and best practices.

## Technology Stack
- **Infrastructure**: Proxmox VE, LXC Containers, Docker
- **Languages**: Python 3.9+, Bash, YAML
- **APIs**: Proxmox REST API, Cloudflare API
- **Tools**: Git, Make, Docker Compose
- **Testing**: Pytest, Coverage, Type Checking
- **Quality**: Mypy, Pydantic, Custom Exceptions

## Key Features
- **Automated Infrastructure Management** - API-driven Proxmox operations
- **Container Orchestration** - Standardized LXC templates and deployment
- **Secure Networking** - Cloudflare tunnels with SSL termination
- **Professional Code Quality** - Comprehensive testing, type hints, logging
- **DevOps Automation** - Shared scripts for backup, monitoring, deployment
- **Configuration Management** - Environment-based configs with validation

## Projects

### Proxmox Management
- **Location**: `proxmox-management/`
- **Purpose**: Proxmox API integration and LXC container management
- **Language**: Python
- **Key Features**: Node management, container operations, API integration

### LXC Templates
- **Location**: `lxc-templates/`
- **Purpose**: Standardized LXC container configurations
- **Format**: YAML
- **Key Features**: OS templates, resource specifications, network configs

### Cloudflare Tunnels
- **Location**: `cloudflare-tunnels/`
- **Purpose**: Tunnel configuration and management
- **Format**: YAML + Docker
- **Key Features**: Secure tunneling, SSL termination, domain management

### Shared Scripts
- **Location**: `shared-scripts/`
- **Purpose**: Common automation and utility scripts
- **Format**: Bash + Python
- **Key Features**: Backup, monitoring, deployment automation

## Quick Start
### Prerequisites
- Python 3.9+
- Docker & Docker Compose
- Proxmox VE environment
- Cloudflare account

### Setup
```bash
# Clone and navigate
git clone <repository-url>
cd infrastructure-management

# Install dependencies for specific projects
cd proxmox-management
pip install -r requirements.txt

# Configure environment
cp env.example .env
# Edit .env with your configuration
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Proxmox      │    │   LXC           │    │   Cloudflare    │
│   Management   │◄──►│   Templates     │◄──►│   Tunnels       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Shared        │
                    │   Scripts       │
                    └─────────────────┘
```

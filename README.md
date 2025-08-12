# Infrastructure Management

## Overview
Centralized management for Proxmox, LXC containers, and Cloudflare tunnels with automation and best practices.

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

## Getting Started

### 1. Repository Setup
This is a unified infrastructure repository containing all related projects:
```bash
# Clone the entire repository
git clone https://github.com/edwardhallam/infrastructure-management.git
cd infrastructure-management

# Open in your preferred editor (recommended: Cursor/VS Code)
cursor .  # Opens the entire infrastructure workspace
```

### 2. Development Workflow
1. **Start with Proxmox Management** - Core infrastructure tool
2. **Add LXC Templates** - Standardize container deployments
3. **Configure Cloudflare Tunnels** - Secure external access
4. **Use Shared Scripts** - Automate common operations

### 3. Extension Discovery
Cursor will automatically suggest relevant extensions as you work:
- **Python extension** for Proxmox management
- **YAML extension** for configurations
- **Shell Script extension** for automation
- **Docker extension** for container management

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

## Backup Strategy
- **Git repositories** for version control
- **Automated backups** via shared scripts
- **Cloud storage** for critical configurations
- **Documentation** for recovery procedures

## Security Considerations
- **API tokens** stored securely
- **SSH keys** for remote access
- **Tunnel authentication** via Cloudflare
- **Container isolation** and resource limits

## Contributing
1. Follow the established project structure
2. Update documentation for new features
3. Test scripts in development environment
4. Use consistent naming conventions

## Support
- Check project-specific READMEs within this repository for detailed setup
- Use shared scripts for common operations
- Document any custom configurations
- Maintain runbooks for troubleshooting

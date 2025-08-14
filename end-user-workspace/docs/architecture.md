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

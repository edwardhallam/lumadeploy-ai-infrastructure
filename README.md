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

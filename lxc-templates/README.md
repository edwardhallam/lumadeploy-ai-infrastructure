# LXC Templates

## Overview
Standardized LXC container configurations for consistent deployment across Proxmox nodes.

## Available Templates

### Ubuntu
- `ubuntu-22.04.yml` - Ubuntu 22.04 LTS template
- `ubuntu-20.04.yml` - Ubuntu 20.04 LTS template (coming soon)

### Debian
- `debian-12.yml` - Debian 12 Bookworm template (coming soon)
- `debian-11.yml` - Debian 11 Bullseye template (coming soon)

### Alpine
- `alpine-3.18.yml` - Alpine Linux 3.18 template (coming soon)

### Custom
- Place custom templates here for specific use cases

## Usage
1. Copy the desired template to your Proxmox node
2. Modify configuration values as needed
3. Use with `pct create` command or Proxmox API

## Template Structure
Each template includes:
- Base OS specifications
- Resource allocation (CPU, memory, storage)
- Network configuration
- Feature flags

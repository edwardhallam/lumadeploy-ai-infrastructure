# Cloudflare Tunnels

## Overview
Configuration and management for Cloudflare tunnels to securely expose local services.

## Features
- Tunnel configuration management
- Docker container setup
- Automated deployment scripts
- SSL termination and security

## Configuration
- `configs/tunnel.yml` - Main tunnel configuration
- `docker/` - Docker compose files for tunnel containers
- `scripts/` - Setup and management scripts

## Quick Start
1. Update `configs/tunnel.yml` with your domain and services
2. Run setup script: `./scripts/setup-tunnel.sh`
3. Start tunnel: `docker-compose up -d`

## Security
- Tunnels provide secure access without opening firewall ports
- Automatic SSL certificates via Cloudflare
- Zero-trust network access

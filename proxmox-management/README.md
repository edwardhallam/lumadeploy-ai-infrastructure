# Proxmox Management Tool

## Overview
Python-based tool for managing Proxmox VE and LXC containers through the API.

## Features
- Proxmox node management
- LXC container operations
- Configuration management
- API integration

## Setup
1. Create virtual environment: `python3 -m venv venv`
2. Activate: `source venv/bin/activate`
3. Install dependencies: `pip install -r requirements.txt`

## Configuration
1. Copy `env.example` to `.env`: `cp env.example .env`
2. Update `.env` with your Proxmox host details:
   - `PROXMOX_HOST`: Your Proxmox IP address or hostname
   - `PROXMOX_PORT`: Port (usually 8006 for home setups)
   - `PROXMOX_VERIFY_SSL`: Set to `false` for self-signed certificates
   - `PROXMOX_API_TOKEN`: Your Proxmox API token
3. **Never commit your `.env` file** - it's already in `.gitignore`

## Usage

### Basic Connection and Capacity Check
```python
from src.main import ProxmoxManager

# Method 1: Use environment variables (recommended)
manager = ProxmoxManager.from_env()

# Method 2: Manual configuration
manager = ProxmoxManager("your-proxmox-host.local", "your-api-token")

# Get all nodes
nodes = manager.get_nodes()

# Check capacity for a specific node
manager.print_capacity_summary("pve")  # Replace with your node name
```

## Project Structure
```
proxmox-management/
├── src/           # Source code
├── configs/       # Configuration files
├── scripts/       # Setup and utility scripts
└── tests/         # Test files
```

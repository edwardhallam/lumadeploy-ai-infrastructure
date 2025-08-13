#!/bin/bash
# Setup script for Proxmox management environment

echo "Setting up Proxmox Management Environment..."

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install requests pyyaml

echo "Environment setup complete!"

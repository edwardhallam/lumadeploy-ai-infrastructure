#!/usr/bin/env python3
"""
Test Proxmox Connection
Quick script to test Proxmox API connectivity
"""

import os
import sys
from dotenv import load_dotenv

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from main import ProxmoxManager

def main():
    """Test Proxmox connection and basic functionality"""
    
    # Load environment variables
    load_dotenv()
    
    try:
        print("🔌 Testing Proxmox connection...")
        
        # Initialize Proxmox manager
        proxmox = ProxmoxManager.from_env()
        
        # Test connection
        if proxmox.test_connection():
            print("✅ Connection successful!")
            
            # Get nodes
            print("\n📋 Getting nodes...")
            nodes = proxmox.get_nodes()
            if nodes:
                print(f"✅ Found {len(nodes)} node(s):")
                for node in nodes:
                    print(f"   - {node['node']} ({node.get('status', 'unknown')})")
                
                # Get capacity for first node
                first_node = nodes[0]['node']
                print(f"\n📊 Getting capacity for {first_node}...")
                proxmox.print_capacity_summary(first_node)
                
                # List containers
                print(f"\n🐳 Listing containers on {first_node}...")
                containers = proxmox.list_containers(first_node)
                if containers:
                    print(f"✅ Found {len(containers)} container(s):")
                    for container in containers:
                        status = container.get('status', 'unknown')
                        name = container.get('name', 'unnamed')
                        vmid = container.get('vmid', 'unknown')
                        print(f"   - {vmid}: {name} ({status})")
                else:
                    print("ℹ️  No containers found")
                
                # Get templates
                print(f"\n📦 Getting available templates on {first_node}...")
                templates = proxmox.get_available_templates(first_node)
                if templates:
                    print(f"✅ Found {len(templates)} template(s):")
                    for template in templates[:5]:  # Show first 5
                        print(f"   - {template['volid']}")
                else:
                    print("ℹ️  No templates found")
                    
            else:
                print("❌ No nodes found")
                
        else:
            print("❌ Connection failed!")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        print(f"💡 Make sure your .env file is configured correctly")
        print(f"   Required: PROXMOX_HOST, PROXMOX_API_TOKEN")

if __name__ == "__main__":
    main()


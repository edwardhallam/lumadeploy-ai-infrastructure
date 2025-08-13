#!/usr/bin/env python3
"""
Check Proxmox Storage and Content
Script to explore available storage options and content types
"""

import sys
import os
from dotenv import load_dotenv

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from main import ProxmoxManager

def main():
    """Check available storage and content on Proxmox"""
    
    # Load environment variables
    load_dotenv()
    
    try:
        # Initialize Proxmox manager
        print("🔌 Initializing Proxmox connection...")
        proxmox = ProxmoxManager.from_env()
        
        # Get available nodes
        print("\n📋 Getting available nodes...")
        nodes = proxmox.get_nodes()
        if not nodes:
            print("❌ No nodes found!")
            return
        
        # Use first node
        node = nodes[0]['node']
        print(f"✅ Using node: {node}")
        
        # Get storage information
        print(f"\n💾 Getting storage information for {node}...")
        
        # List all storage
        try:
            response = proxmox.session.get(
                f"{proxmox.base_url}/nodes/{node}/storage",
                verify=proxmox.verify_ssl,
                timeout=30
            )
            response.raise_for_status()
            storage_list = response.json()['data']
            
            print(f"✅ Found {len(storage_list)} storage location(s):")
            for storage in storage_list:
                storage_name = storage.get('storage', 'unknown')
                storage_type = storage.get('type', 'unknown')
                storage_status = storage.get('status', 'unknown')
                print(f"   - {storage_name} ({storage_type}) - {storage_status}")
                
                # Check content types for each storage
                try:
                    content_response = proxmox.session.get(
                        f"{proxmox.base_url}/nodes/{node}/storage/{storage_name}/content",
                        verify=proxmox.verify_ssl,
                        timeout=30
                    )
                    content_response.raise_for_status()
                    content_list = content_response.json()['data']
                    
                    if content_list:
                        print(f"     Content types:")
                        content_types = {}
                        for item in content_list:
                            content_type = item.get('content', 'unknown')
                            if content_type not in content_types:
                                content_types[content_type] = 0
                            content_types[content_type] += 1
                        
                        for content_type, count in content_types.items():
                            print(f"       - {content_type}: {count} items")
                    else:
                        print(f"     No content found")
                        
                except Exception as e:
                    print(f"     Error checking content: {e}")
                    
        except Exception as e:
            print(f"❌ Failed to get storage info: {e}")
            
        # Check if there are any existing templates
        print(f"\n📦 Checking for existing templates...")
        templates = proxmox.get_available_templates(node)
        if templates:
            print(f"✅ Found {len(templates)} template(s):")
            for template in templates:
                print(f"   - {template['volid']}")
        else:
            print("ℹ️  No templates found")
            
        # Check what's available in local-lvm specifically
        print(f"\n🔍 Checking local-lvm storage content...")
        try:
            response = proxmox.session.get(
                f"{proxmox.base_url}/nodes/{node}/storage/local-lvm/content",
                verify=proxmox.verify_ssl,
                timeout=30
            )
            response.raise_for_status()
            content_list = response.json()['data']
            
            if content_list:
                print(f"✅ Found {len(content_list)} items in local-lvm:")
                for item in content_list[:10]:  # Show first 10
                    content_type = item.get('content', 'unknown')
                    volid = item.get('volid', 'unknown')
                    size = item.get('size', 0)
                    size_mb = round(size / (1024*1024), 1) if size > 0 else 0
                    print(f"   - {content_type}: {volid} ({size_mb}MB)")
            else:
                print("ℹ️  No content in local-lvm")
                
        except Exception as e:
            print(f"❌ Error checking local-lvm content: {e}")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()


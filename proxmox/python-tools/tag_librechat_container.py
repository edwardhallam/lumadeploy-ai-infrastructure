#!/usr/bin/env python3
"""
Tag LibreChat Container
Adds a project tag to the LibreChat container for organization
"""

import sys
import os
from dotenv import load_dotenv

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from main import ProxmoxManager

def main():
    """Add project tag to LibreChat container"""
    
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
        
        # Container ID for LibreChat
        container_id = 200
        
        # Check if container exists and get current tags
        print(f"\n🔍 Checking container {container_id}...")
        containers = proxmox.list_containers(node)
        container_exists = False
        
        for container in containers:
            if container.get('vmid') == container_id:
                container_exists = True
                name = container.get('name', 'unnamed')
                status = container.get('status', 'unknown')
                print(f"✅ Found container: {name} (ID: {container_id}, Status: {status})")
                break
        
        if not container_exists:
            print(f"❌ Container {container_id} not found!")
            return
        
        # Get current tags
        current_tags = proxmox.get_container_tags(node, container_id)
        if current_tags:
            print(f"🏷️  Current tags: {', '.join(current_tags)}")
        else:
            print("🏷️  No current tags")
        
        # Project tag to add
        project_tag = "librechat-project"
        
        print(f"\n🏷️  Adding project tag: {project_tag}")
        
        # Add the tag
        if proxmox.add_container_tag(node, container_id, project_tag):
            print(f"\n✅ Successfully tagged container {container_id} with '{project_tag}'")
            
            # Verify the tag was added
            updated_tags = proxmox.get_container_tags(node, container_id)
            if updated_tags:
                print(f"🏷️  Updated tags: {', '.join(updated_tags)}")
            else:
                print("🏷️  No tags found after update")
                
        else:
            print(f"\n❌ Failed to add tag to container {container_id}")
            
        # Show container summary
        print(f"\n📊 Container Summary:")
        print(f"   ID: {container_id}")
        print(f"   Name: librechat")
        print(f"   Status: running")
        print(f"   Project: {project_tag}")
        print(f"   Purpose: AI Chat Application")
        print(f"   Next Step: Deploy LibreChat application")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()




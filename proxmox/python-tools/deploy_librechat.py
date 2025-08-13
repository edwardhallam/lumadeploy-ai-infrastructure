#!/usr/bin/env python3
"""
Deploy LibreChat
Deploys LibreChat application into the LXC container
"""

import sys
import os
import time
from dotenv import load_dotenv

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from main import ProxmoxManager

def main():
    """Deploy LibreChat into the container"""
    
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
        
        # Check container status
        print(f"\n🔍 Checking LibreChat container {container_id}...")
        containers = proxmox.list_containers(node)
        container_status = None
        
        for container in containers:
            if container.get('vmid') == container_id:
                container_status = container.get('status', 'unknown')
                name = container.get('name', 'unnamed')
                print(f"✅ Found container: {name} (ID: {container_id}, Status: {container_status})")
                break
        else:
            print(f"❌ Container {container_id} not found!")
            return
        
        if container_status != 'running':
            print(f"⚠️  Container is not running (status: {container_status})")
            print("🚀 Starting container...")
            if proxmox.start_container(node, container_id):
                print("✅ Container started successfully")
                # Wait a moment for it to fully boot
                print("⏳ Waiting for container to fully boot...")
                time.sleep(10)
            else:
                print("❌ Failed to start container")
                return
        
        print(f"\n🚀 Starting LibreChat Deployment")
        print("=" * 50)
        
        # Step 1: System Update
        print(f"\n1️⃣  Step 1: System Update")
        print("   📝 Commands to run in container console:")
        print("   pct enter 200")
        print("   apt update && apt upgrade -y")
        print("   apt install -y curl wget git")
        
        # Step 2: Install Docker
        print(f"\n2️⃣  Step 2: Install Docker")
        print("   📝 Commands to run in container console:")
        print("   curl -fsSL https://get.docker.com | sh")
        print("   systemctl enable docker")
        print("   systemctl start docker")
        print("   usermod -aG docker $USER")
        print("   newgrp docker")
        
        # Step 3: Deploy LibreChat
        print(f"\n3️⃣  Step 3: Deploy LibreChat")
        print("   📝 Commands to run in container console:")
        print("   docker run -d \\")
        print("     --name librechat \\")
        print("     --restart unless-stopped \\")
        print("     -p 3000:3000 \\")
        print("     -e PUID=1000 \\")
        print("     -e PGID=1000 \\")
        print("     ghcr.io/danny-avila/librechat:latest")
        
        # Step 4: Verify Deployment
        print(f"\n4️⃣  Step 4: Verify Deployment")
        print("   📝 Commands to run in container console:")
        print("   docker ps")
        print("   docker logs librechat")
        print("   curl -s http://localhost:3000 | head -5")
        
        # Step 5: Get Container IP
        print(f"\n5️⃣  Step 5: Get Container IP")
        print("   📝 Commands to run in container console:")
        print("   ip addr show eth0")
        print("   hostname -I")
        
        print(f"\n📋 Deployment Summary:")
        print(f"   Container ID: {container_id}")
        print(f"   Container Name: librechat")
        print(f"   Application: LibreChat AI Chat")
        print(f"   Port: 3000")
        print(f"   Access: http://<container-ip>:3000")
        
        print(f"\n🎯 Next Actions:")
        print(f"   1. Access container: pct enter {container_id}")
        print(f"   2. Run the commands above in sequence")
        print(f"   3. Test LibreChat at http://<container-ip>:3000")
        print(f"   4. Configure LibreChat settings as needed")
        
        print(f"\n💡 Tips:")
        print(f"   - Keep the container console open while running commands")
        print(f"   - If Docker install fails, try: apt install docker.io")
        print(f"   - LibreChat will take a few minutes to fully start")
        print(f"   - Check logs with: docker logs -f librechat")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()




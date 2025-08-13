#!/usr/bin/env python3
"""
Debug Container Creation
Script to test different approaches for creating LXC containers
"""

import sys
import os
import json
from dotenv import load_dotenv

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from main import ProxmoxManager

def test_container_creation_methods():
    """Test different methods for creating containers"""
    
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
        
        # Get available templates
        print(f"\n📦 Getting available templates on {node}...")
        templates = proxmox.get_available_templates(node)
        if not templates:
            print("❌ No templates found!")
            return
        
        print(f"✅ Found {len(templates)} template(s):")
        template = templates[0]['volid']  # Use first template
        print(f"   Using template: {template}")
        
        # Test different storage formats
        test_cases = [
            {
                'name': 'Simple local storage',
                'rootfs': 'local:20',
                'description': 'Basic local storage with size'
            },
            {
                'name': 'Local storage with filename',
                'rootfs': 'local:vz-200-disk-0',
                'description': 'Local storage with specific filename'
            },
            {
                'name': 'Local storage with full path',
                'rootfs': 'local:vz-200-disk-0,size=20G',
                'description': 'Local storage with filename and size'
            },
            {
                'name': 'Minimal config',
                'rootfs': None,
                'description': 'No rootfs specified (let Proxmox choose)'
            }
        ]
        
        for i, test_case in enumerate(test_cases, 1):
            print(f"\n🧪 Test {i}: {test_case['name']}")
            print(f"   Description: {test_case['description']}")
            
            # Prepare container data
            container_data = {
                'vmid': 200 + i,  # Use different ID for each test
                'ostemplate': template,
                'hostname': f'librechat-test-{i}',
                'cores': 2,
                'memory': 2048,
                'net0': 'name=eth0,bridge=vmbr0,ip=dhcp,ip6=dhcp',
                'onboot': 1,
                'start': 0  # Don't start automatically
            }
            
            # Add rootfs if specified
            if test_case['rootfs']:
                container_data['rootfs'] = test_case['rootfs']
            
            print(f"   Container data: {json.dumps(container_data, indent=2)}")
            
            try:
                # Try to create container
                response = proxmox.session.post(
                    f"{proxmox.base_url}/nodes/{node}/lxc",
                    json=container_data,
                    verify=proxmox.verify_ssl,
                    timeout=60
                )
                
                print(f"   Response status: {response.status_code}")
                if response.status_code == 200:
                    print(f"   ✅ Success! Container created")
                    # Clean up - delete the test container
                    try:
                        delete_response = proxmox.session.delete(
                            f"{proxmox.base_url}/nodes/{node}/lxc/{container_data['vmid']}",
                            verify=proxmox.verify_ssl,
                            timeout=30
                        )
                        if delete_response.status_code == 200:
                            print(f"   🗑️  Test container cleaned up")
                        else:
                            print(f"   ⚠️  Could not clean up test container")
                    except Exception as e:
                        print(f"   ⚠️  Error cleaning up: {e}")
                else:
                    print(f"   ❌ Failed: {response.status_code}")
                    print(f"   Response: {response.text}")
                    
            except Exception as e:
                print(f"   ❌ Exception: {e}")
            
            print("-" * 50)
            
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    """Main function"""
    print("🔍 Debug Container Creation Methods")
    print("=" * 50)
    
    test_container_creation_methods()
    
    print("\n💡 Recommendations:")
    print("1. If all tests fail, the API token may not have container creation permissions")
    print("2. Check Proxmox user permissions for the API token")
    print("3. Consider using Proxmox CLI commands instead of API")
    print("4. Verify storage configuration and permissions")

if __name__ == "__main__":
    main()




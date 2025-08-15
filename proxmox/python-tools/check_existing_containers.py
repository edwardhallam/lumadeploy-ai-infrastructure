#!/usr/bin/env python3
"""
Check Existing Containers
Script to examine existing containers and their configuration
"""

import os
import sys

from dotenv import load_dotenv

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), "src"))


def main():
    """Check existing containers and their configuration"""
    # Import here to avoid import order issues
    from main import ProxmoxManager

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
        node = nodes[0]["node"]
        print(f"✅ Using node: {node}")

        # List containers with detailed info
        print(f"\n🐳 Listing containers on {node}...")
        containers = proxmox.list_containers(node)
        if containers:
            print(f"✅ Found {len(containers)} container(s):")
            for container in containers:
                vmid = container.get("vmid", "unknown")
                name = container.get("name", "unnamed")
                status = container.get("status", "unknown")
                rootfs = container.get("rootfs", "unknown")
                memory = container.get("maxmem", 0)
                memory_mb = round(memory / (1024 * 1024), 1) if memory > 0 else 0
                cores = container.get("maxcpu", 0)

                print(f"\n   📦 Container {vmid}: {name}")
                print(f"      Status: {status}")
                print(f"      RootFS: {rootfs}")
                print(f"      Memory: {memory_mb}MB")
                print(f"      Cores: {cores}")

                # Get detailed container config
                try:
                    config_response = proxmox.session.get(
                        f"{proxmox.base_url}/nodes/{node}/lxc/{vmid}/config",
                        verify=proxmox.verify_ssl,
                        timeout=30,
                    )
                    config_response.raise_for_status()
                    config = config_response.json()["data"]

                    print("      Config:")
                    for key, value in config.items():
                        if key in ["rootfs", "net0", "memory", "cores", "hostname"]:
                            print(f"        {key}: {value}")

                except Exception as e:
                    print(f"      Error getting config: {e}")
        else:
            print("ℹ️  No containers found")

        # Also check VMs
        print(f"\n🖥️  Listing VMs on {node}...")
        try:
            vm_response = proxmox.session.get(
                f"{proxmox.base_url}/nodes/{node}/qemu",
                verify=proxmox.verify_ssl,
                timeout=30,
            )
            vm_response.raise_for_status()
            vms = vm_response.json()["data"]

            if vms:
                print(f"✅ Found {len(vms)} VM(s):")
                for vm in vms:
                    vmid = vm.get("vmid", "unknown")
                    name = vm.get("name", "unnamed")
                    status = vm.get("status", "unknown")
                    print(f"   - {vmid}: {name} ({status})")
            else:
                print("ℹ️  No VMs found")

        except Exception as e:
            print(f"❌ Error getting VMs: {e}")

    except Exception as e:
        print(f"❌ Error: {e}")


if __name__ == "__main__":
    main()

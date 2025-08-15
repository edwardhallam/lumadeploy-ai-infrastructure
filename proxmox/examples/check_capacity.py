#!/usr/bin/env python3
"""
Example script to check Proxmox server capacity
"""

import os
import sys
from dotenv import load_dotenv

# Add the python-tools directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), "..", "python-tools"))

# Load environment variables
load_dotenv()


def main():
    """Main function to check Proxmox capacity"""
    # Import here to avoid import order issues
    from main import ProxmoxManager

    print("Proxmox Capacity Checker")
    print("=" * 40)

    # Get configuration from environment variables
    host = os.getenv("PROXMOX_HOST", "localhost")
    port = int(os.getenv("PROXMOX_PORT", "8006"))
    verify_ssl = os.getenv("PROXMOX_VERIFY_SSL", "false").lower() == "true"
    api_token = os.getenv("PROXMOX_API_TOKEN")

    # Prompt for API token if not in environment
    if not api_token:
        api_token = input("Enter your Proxmox API token: ").strip()
        if not api_token:
            print("❌ API token is required!")
            return

    try:
        # Initialize connection
        print(f"\nConnecting to Proxmox host: {host}:{port}")
        manager = ProxmoxManager(host, api_token, port, verify_ssl)
        print("✓ Connection successful!")

        # Get all nodes
        print("\nFetching node information...")
        nodes = manager.get_nodes()

        if not nodes:
            print("No nodes found or failed to retrieve node list.")
            return

        print(f"Found {len(nodes)} node(s):")
        for node in nodes:
            print(f"  - {node['node']} ({node['status']})")

        # Check capacity for each node
        for node in nodes:
            node_name = node["node"]
            print(f"\nChecking capacity for node: {node_name}")
            manager.print_capacity_summary(node_name)

    except ConnectionError as e:
        print(f"❌ Connection failed: {e}")
        print("\nTroubleshooting tips:")
        print("1. Check if Proxmox is running and accessible")
        print("2. Verify the host address and port")
        print("3. Ensure your API token is correct")
        print("4. Check firewall settings")
        print("5. For self-signed certificates, verify_ssl should be False")
        print("6. Make sure your .env file is properly configured")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")


if __name__ == "__main__":
    main()

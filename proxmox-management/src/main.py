#!/usr/bin/env python3
"""
Proxmox Management Tool
Handles Proxmox API interactions and LXC container management
"""

import json
import os
import requests
import urllib3
from typing import Dict, List, Optional, Any
from urllib.parse import urljoin
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

def get_config() -> dict:
    """Get configuration from environment variables with sensible defaults"""
    return {
        'host': os.getenv('PROXMOX_HOST', 'localhost'),
        'port': int(os.getenv('PROXMOX_PORT', '8006')),
        'verify_ssl': os.getenv('PROXMOX_VERIFY_SSL', 'false').lower() == 'true',
        'api_token': os.getenv('PROXMOX_API_TOKEN', '')
    }

# Disable SSL warnings for self-signed certificates (common in home setups)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class ProxmoxManager:
    def __init__(self, host: str, api_token: str, port: int = 8006, verify_ssl: bool = False):
        self.host = host
        self.api_token = api_token
        self.port = port
        self.verify_ssl = verify_ssl
        self.base_url = f"https://{host}:{port}/api2/json"
        self.session = requests.Session()
        
        # Set up session headers
        self.session.headers.update({
            'Authorization': f'PVEAPIToken={api_token}',
            'Content-Type': 'application/json'
        })
        
        # Test connection on initialization
        if not self.test_connection():
            raise ConnectionError(f"Failed to connect to Proxmox host: {host}")
    
    @classmethod
    def from_env(cls) -> 'ProxmoxManager':
        """Create ProxmoxManager instance from environment variables"""
        config = get_config()
        if not config['api_token']:
            raise ValueError("PROXMOX_API_TOKEN environment variable is required")
        return cls(
            host=config['host'],
            api_token=config['api_token'],
            port=config['port'],
            verify_ssl=config['verify_ssl']
        )
    
    def test_connection(self) -> bool:
        """Test connection to Proxmox host"""
        try:
            print(f"Testing connection to: {self.base_url}/version")
            print(f"Headers: {self.session.headers}")
            print(f"SSL verification: {self.verify_ssl}")
            
            response = self.session.get(
                f"{self.base_url}/version",
                verify=self.verify_ssl,
                timeout=10
            )
            print(f"Response status: {response.status_code}")
            print(f"Response headers: {dict(response.headers)}")
            
            if response.status_code == 200:
                print("✓ Connection test successful!")
                return True
            else:
                print(f"✗ Connection test failed with status: {response.status_code}")
                print(f"Response content: {response.text}")
                return False
                
        except Exception as e:
            print(f"Connection test failed with exception: {e}")
            print(f"Exception type: {type(e).__name__}")
            return False
    
    def get_nodes(self) -> List[Dict[str, Any]]:
        """Get list of Proxmox nodes"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes",
                verify=self.verify_ssl,
                timeout=30
            )
            response.raise_for_status()
            return response.json()['data']
        except Exception as e:
            print(f"Failed to get nodes: {e}")
            return []
    
    def get_node_status(self, node: str) -> Optional[Dict[str, Any]]:
        """Get detailed status of a specific node"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes/{node}/status",
                verify=self.verify_ssl,
                timeout=30
            )
            response.raise_for_status()
            return response.json()['data']
        except Exception as e:
            print(f"Failed to get node status for {node}: {e}")
            return None
    
    def get_node_capacity(self, node: str) -> Optional[Dict]:
        """Get capacity information for a specific node"""
        try:
            # Get node status (CPU, memory, uptime)
            status = self.get_node_status(node)
            if not status:
                return None
            
            # Debug: Let's see what we're actually getting
            print(f"Debug - Status data: {status}")
            print(f"Debug - CPU data: {status.get('cpu', 'Not found')}")
            print(f"Debug - Memory data: {status.get('memory', 'Not found')}")
            
            # Get storage information
            storage_response = self.session.get(
                f"{self.base_url}/nodes/{node}/storage",
                verify=self.verify_ssl,
                timeout=30
            )
            storage_response.raise_for_status()
            storage_data = storage_response.json()['data']
            
            # Calculate storage capacity - separate local from network storage
            total_storage = 0
            used_storage = 0
            local_storage = 0
            local_used = 0
            nas_storage = 0
            nas_used = 0
            
            for storage in storage_data:
                if storage['type'] in ['dir', 'lvmthin']:
                    # Local storage
                    local_storage += storage.get('avail', 0)
                    local_used += storage.get('used', 0)
                elif storage['type'] in ['nfs', 'cifs']:
                    # Network storage
                    nas_storage += storage.get('avail', 0)
                    nas_used += storage.get('used', 0)
                
                total_storage += storage.get('avail', 0)
                used_storage += storage.get('used', 0)
            
            # Get container and VM information
            containers_response = self.session.get(
                f"{self.base_url}/nodes/{node}/lxc",
                verify=self.verify_ssl,
                timeout=30
            )
            vms_response = self.session.get(
                f"{self.base_url}/nodes/{node}/qemu",
                verify=self.verify_ssl,
                timeout=30
            )
            
            container_count = len(containers_response.json()['data']) if containers_response.status_code == 200 else 0
            vm_count = len(vms_response.json()['data']) if vms_response.status_code == 200 else 0
            
            return {
                'status': status,
                'storage': {
                    'total': total_storage,
                    'used': used_storage,
                    'local': local_storage,
                    'local_used': local_used,
                    'nas': nas_storage,
                    'nas_used': nas_used
                },
                'containers': container_count,
                'vms': vm_count
            }
            
        except Exception as e:
            print(f"Failed to get capacity for {node}: {e}")
            return None
    
    def print_capacity_summary(self, node: str) -> None:
        """Print a formatted capacity summary for a node"""
        capacity = self.get_node_capacity(node)
        if not capacity:
            print(f"Failed to get capacity information for {node}")
            return
        
        status = capacity['status']
        storage = capacity['storage']
        
        # CPU info
        cpu_info = status.get('cpuinfo', {})
        cpu_model = cpu_info.get('model', 'Unknown CPU')
        cpu_cores = cpu_info.get('cpus', 0)
        cpu_usage = status.get('cpu', 0)
        
        # Memory info
        memory = status.get('memory', {})
        memory_total = memory.get('total', 0)
        memory_used = memory.get('used', 0)
        memory_gb_total = round(memory_total / (1024**3), 1)
        memory_gb_used = round(memory_used / (1024**3), 1)
        
        # Storage info
        storage_gb_total = round(storage['total'] / (1024**3), 1)
        storage_gb_used = round(storage['used'] / (1024**3), 1)
        local_gb_total = round(storage['local'] / (1024**3), 1)
        local_gb_used = round(storage['local_used'] / (1024**3), 1)
        nas_gb_total = round(storage['nas'] / (1024**3), 1)
        nas_gb_used = round(storage['nas_used'] / (1024**3), 1)
        
        # Uptime
        uptime = status.get('uptime', 0)
        
        # Load average
        loadavg = status.get('loadavg', [0, 0, 0])
        
        print(f"\n=== Capacity Summary for Node: {node} ===")
        print(f"CPU: {cpu_cores} cores ({cpu_model})")
        print(f"CPU Usage: {cpu_usage:.1%}")
        print(f"Memory: {memory_gb_used}GB / {memory_gb_total}GB")
        print()
        print("💾 Storage Breakdown:")
        print(f"  📁 Local Server: {local_gb_used}GB / {local_gb_total}GB")
        print(f"  🌐 NAS/Network: {nas_gb_used}GB / {nas_gb_total}GB")
        print(f"  📊 Total Combined: {storage_gb_used}GB / {storage_gb_total}GB")
        print()
        print(f"🐳 Containers: {capacity['containers']} LXC + {capacity['vms']} VMs")
        print(f"⏱️  Uptime: {uptime} seconds")
        print(f"📈 Load Average: {', '.join(map(str, loadavg))}")
    
    def list_containers(self, node: str) -> List[Dict[str, Any]]:
        """List LXC containers on a specific node"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes/{node}/lxc",
                verify=self.verify_ssl,
                timeout=30
            )
            response.raise_for_status()
            return response.json()['data']
        except Exception as e:
            print(f"Failed to list containers for {node}: {e}")
            return []

if __name__ == "__main__":
    print("Proxmox Management Tool")

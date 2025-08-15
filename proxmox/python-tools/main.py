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
        "host": os.getenv("PROXMOX_HOST", "localhost"),
        "port": int(os.getenv("PROXMOX_PORT", "8006")),
        "verify_ssl": os.getenv("PROXMOX_VERIFY_SSL", "false").lower() == "true",
        "api_token": os.getenv("PROXMOX_API_TOKEN", ""),
    }


# Disable SSL warnings for self-signed certificates (common in home setups)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class ProxmoxManager:
    def __init__(
        self, host: str, api_token: str, port: int = 8006, verify_ssl: bool = False
    ):
        self.host = host
        self.api_token = api_token
        self.port = port
        self.verify_ssl = verify_ssl
        self.base_url = f"https://{host}:{port}/api2/json"
        self.session = requests.Session()

        # Set up session headers
        self.session.headers.update(
            {
                "Authorization": f"PVEAPIToken={api_token}",
                "Content-Type": "application/json",
            }
        )

        # Test connection on initialization
        if not self.test_connection():
            raise ConnectionError(f"Failed to connect to Proxmox host: {host}")

    @classmethod
    def from_env(cls) -> "ProxmoxManager":
        """Create ProxmoxManager instance from environment variables"""
        config = get_config()
        if not config["api_token"]:
            raise ValueError("PROXMOX_API_TOKEN environment variable is required")
        return cls(
            host=config["host"],
            api_token=config["api_token"],
            port=config["port"],
            verify_ssl=config["verify_ssl"],
        )

    def test_connection(self) -> bool:
        """Test connection to Proxmox host"""
        try:
            print(f"Testing connection to: {self.base_url}/version")
            print(f"Headers: {self.session.headers}")
            print(f"SSL verification: {self.verify_ssl}")

            response = self.session.get(
                f"{self.base_url}/version", verify=self.verify_ssl, timeout=10
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
                f"{self.base_url}/nodes", verify=self.verify_ssl, timeout=30
            )
            response.raise_for_status()
            return response.json()["data"]
        except Exception as e:
            print(f"Failed to get nodes: {e}")
            return []

    def get_node_status(self, node: str) -> Optional[Dict[str, Any]]:
        """Get detailed status of a specific node"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes/{node}/status",
                verify=self.verify_ssl,
                timeout=30,
            )
            response.raise_for_status()
            return response.json()["data"]
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
                timeout=30,
            )
            storage_response.raise_for_status()
            storage_data = storage_response.json()["data"]

            # Calculate storage capacity - separate local from network storage
            total_storage = 0
            used_storage = 0
            local_storage = 0
            local_used = 0
            nas_storage = 0
            nas_used = 0

            for storage in storage_data:
                if storage["type"] in ["dir", "lvmthin"]:
                    # Local storage
                    local_storage += storage.get("avail", 0)
                    local_used += storage.get("used", 0)
                elif storage["type"] in ["nfs", "cifs"]:
                    # Network storage
                    nas_storage += storage.get("avail", 0)
                    nas_used += storage.get("used", 0)

                total_storage += storage.get("avail", 0)
                used_storage += storage.get("used", 0)

            # Get container and VM information
            containers_response = self.session.get(
                f"{self.base_url}/nodes/{node}/lxc", verify=self.verify_ssl, timeout=30
            )
            vms_response = self.session.get(
                f"{self.base_url}/nodes/{node}/qemu", verify=self.verify_ssl, timeout=30
            )

            container_count = (
                len(containers_response.json()["data"])
                if containers_response.status_code == 200
                else 0
            )
            vm_count = (
                len(vms_response.json()["data"])
                if vms_response.status_code == 200
                else 0
            )

            return {
                "status": status,
                "storage": {
                    "total": total_storage,
                    "used": used_storage,
                    "local": local_storage,
                    "local_used": local_used,
                    "nas": nas_storage,
                    "nas_used": nas_used,
                },
                "containers": container_count,
                "vms": vm_count,
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

        status = capacity["status"]
        storage = capacity["storage"]

        # CPU info
        cpu_info = status.get("cpuinfo", {})
        cpu_model = cpu_info.get("model", "Unknown CPU")
        cpu_cores = cpu_info.get("cpus", 0)
        cpu_usage = status.get("cpu", 0)

        # Memory info
        memory = status.get("memory", {})
        memory_total = memory.get("total", 0)
        memory_used = memory.get("used", 0)
        memory_gb_total = round(memory_total / (1024**3), 1)
        memory_gb_used = round(memory_used / (1024**3), 1)

        # Storage info
        storage_gb_total = round(storage["total"] / (1024**3), 1)
        storage_gb_used = round(storage["used"] / (1024**3), 1)
        local_gb_total = round(storage["local"] / (1024**3), 1)
        local_gb_used = round(storage["local_used"] / (1024**3), 1)
        nas_gb_total = round(storage["nas"] / (1024**3), 1)
        nas_gb_used = round(storage["nas_used"] / (1024**3), 1)

        # Uptime
        uptime = status.get("uptime", 0)

        # Load average
        loadavg = status.get("loadavg", [0, 0, 0])

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
                f"{self.base_url}/nodes/{node}/lxc", verify=self.verify_ssl, timeout=30
            )
            response.raise_for_status()
            return response.json()["data"]
        except Exception as e:
            print(f"Failed to list containers for {node}: {e}")
            return []

    def create_container(
        self,
        node: str,
        container_id: int,
        template: str,
        hostname: str,
        cores: int = 2,
        memory: int = 2048,
        rootfs_size: str = "8G",
        storage: str = "local-lvm",
    ) -> bool:
        """Create a new LXC container on the specified node"""
        try:
            # Container creation data
            container_data = {
                "vmid": container_id,
                "ostemplate": template,
                "hostname": hostname,
                "cores": cores,
                "memory": memory,
                "net0": "name=eth0,bridge=vmbr0,ip=dhcp,ip6=dhcp",
                "onboot": 1,
                "start": 1,
            }

            print(f"Creating container {container_id} ({hostname}) on node {node}...")
            print(f"Template: {template}")
            print(f"Specs: {cores} cores, {memory}MB RAM, {rootfs_size} storage")

            response = self.session.post(
                f"{self.base_url}/nodes/{node}/lxc",
                json=container_data,
                verify=self.verify_ssl,
                timeout=60,
            )

            if response.status_code == 200:
                print(f"✓ Container {container_id} created successfully!")
                return True
            else:
                print(f"✗ Failed to create container: {response.status_code}")
                print(f"Response: {response.text}")
                return False

        except Exception as e:
            print(f"Exception creating container: {e}")
            return False

    def get_available_templates(self, node: str) -> List[Dict[str, Any]]:
        """Get available LXC templates on a specific node"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes/{node}/storage/local/content",
                verify=self.verify_ssl,
                timeout=30,
            )
            response.raise_for_status()

            # Filter for LXC templates
            templates = []
            for item in response.json()["data"]:
                if item.get("content") == "vztmpl":
                    templates.append(
                        {
                            "volid": item.get("volid"),
                            "size": item.get("size"),
                            "ctime": item.get("ctime"),
                        }
                    )

            return templates
        except Exception as e:
            print(f"Failed to get templates for {node}: {e}")
            return []

    def wait_for_container_status(
        self,
        node: str,
        container_id: int,
        target_status: str = "running",
        timeout: int = 300,
    ) -> bool:
        """Wait for container to reach target status"""
        import time

        print(f"Waiting for container {container_id} to reach status: {target_status}")
        start_time = time.time()

        while time.time() - start_time < timeout:
            try:
                containers = self.list_containers(node)
                for container in containers:
                    if container.get("vmid") == container_id:
                        current_status = container.get("status")
                        print(f"Container {container_id} status: {current_status}")

                        if current_status == target_status:
                            print(f"✓ Container {container_id} is now {target_status}")
                            return True
                        elif current_status == "stopped" and target_status == "running":
                            print(f"Starting container {container_id}...")
                            self.start_container(node, container_id)

                        break

                time.sleep(5)

            except Exception as e:
                print(f"Error checking container status: {e}")
                time.sleep(5)

        print(f"Timeout waiting for container {container_id} to reach {target_status}")
        return False

    def start_container(self, node: str, container_id: int) -> bool:
        """Start a stopped container"""
        try:
            response = self.session.post(
                f"{self.base_url}/nodes/{node}/lxc/{container_id}/status/start",
                verify=self.verify_ssl,
                timeout=30,
            )

            if response.status_code == 200:
                print(f"✓ Container {container_id} started successfully!")
                return True
            else:
                print(f"✗ Failed to start container: {response.status_code}")
                return False

        except Exception as e:
            print(f"Exception starting container: {e}")
            return False

    def add_container_tag(self, node: str, container_id: int, tag: str) -> bool:
        """Add a tag to a container"""
        try:
            print(f"🏷️  Adding tag '{tag}' to container {container_id}...")

            # Get current container config
            config_response = self.session.get(
                f"{self.base_url}/nodes/{node}/lxc/{container_id}/config",
                verify=self.verify_ssl,
                timeout=30,
            )
            config_response.raise_for_status()
            current_config = config_response.json()["data"]

            # Add or update the tag
            current_config["tags"] = tag

            # Update the container config
            update_response = self.session.put(
                f"{self.base_url}/nodes/{node}/lxc/{container_id}/config",
                json=current_config,
                verify=self.verify_ssl,
                timeout=30,
            )

            if update_response.status_code == 200:
                print(f"✅ Tag '{tag}' added successfully to container {container_id}")
                return True
            else:
                print(f"❌ Failed to add tag: {update_response.status_code}")
                print(f"Response: {update_response.text}")
                return False

        except Exception as e:
            print(f"Exception adding tag: {e}")
            return False

    def get_container_tags(self, node: str, container_id: int) -> List[str]:
        """Get tags for a container"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes/{node}/lxc/{container_id}/config",
                verify=self.verify_ssl,
                timeout=30,
            )
            response.raise_for_status()
            config = response.json()["data"]

            tags = config.get("tags", "")
            if tags:
                return [tag.strip() for tag in tags.split(",")]
            return []

        except Exception as e:
            print(f"Failed to get tags for container {container_id}: {e}")
            return []

    def download_template(
        self, node: str, template_url: str, storage: str = "local-lvm"
    ) -> bool:
        """Download an LXC template from a URL"""
        try:
            print(f"📥 Downloading template: {template_url}")
            print(f"   Storage: {storage}")
            print(f"   Node: {node}")

            # Extract filename from URL
            filename = template_url.split("/")[-1]

            # Download template data - correct Proxmox API format
            download_data = {
                "content": "vztmpl",
                "filename": filename,
                "url": template_url,
            }

            response = self.session.post(
                f"{self.base_url}/nodes/{node}/storage/{storage}/content",
                json=download_data,
                verify=self.verify_ssl,
                timeout=300,  # Longer timeout for downloads
            )

            if response.status_code == 200:
                print(f"✓ Template download started successfully!")
                return True
            else:
                print(f"✗ Failed to start template download: {response.status_code}")
                print(f"Response: {response.text}")
                return False

        except Exception as e:
            print(f"Exception downloading template: {e}")
            return False

    def get_template_download_status(
        self, node: str, storage: str = "local-lvm"
    ) -> List[Dict[str, Any]]:
        """Get status of template downloads"""
        try:
            response = self.session.get(
                f"{self.base_url}/nodes/{node}/storage/{storage}/content",
                verify=self.verify_ssl,
                timeout=30,
            )
            response.raise_for_status()

            # Filter for templates and show download status
            templates = []
            for item in response.json()["data"]:
                if item.get("content") == "vztmpl":
                    templates.append(
                        {
                            "volid": item.get("volid"),
                            "size": item.get("size"),
                            "ctime": item.get("ctime"),
                            "status": (
                                "downloaded"
                                if item.get("size", 0) > 0
                                else "downloading"
                            ),
                        }
                    )

            return templates
        except Exception as e:
            print(f"Failed to get template status for {node}: {e}")
            return []


if __name__ == "__main__":
    print("Proxmox Management Tool")

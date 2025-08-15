#!/usr/bin/env python3
"""
Cursor Container Client
Client for Cursor to interact with container console API
"""

import requests
from dataclasses import dataclass
from typing import Any, Dict, List, Optional


@dataclass
class ContainerCommand:
    """Container command configuration"""

    container_id: int
    command: str
    timeout: int = 30
    description: str = ""


class CursorContainerClient:
    """Client for interacting with container console API"""

    def __init__(self, api_base_url: str = None):
        if api_base_url is None:
            import os

            api_base_url = os.getenv(
                "CONTAINER_CONSOLE_API_URL", "http://localhost:5000"
            )

        self.api_base_url = api_base_url
        self.session = requests.Session()
        self.session.timeout = 30

    def test_connection(self) -> bool:
        """Test connection to the container console API"""
        try:
            print(f"🔍 Testing connection to: {self.api_base_url}/health")
            print(f"🔍 Using session timeout: {self.session.timeout}s")

            response = self.session.get(f"{self.api_base_url}/health")
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Connected to Container Console API: {data['status']}")
                return True
            else:
                print(f"❌ API connection failed: {response.status_code}")
                print(f"📤 Response: {response.text}")
                return False
        except requests.exceptions.ConnectTimeout as e:
            print(f"❌ Connection timeout: {e}")
            return False
        except requests.exceptions.ReadTimeout as e:
            print(f"❌ Read timeout: {e}")
            return False
        except requests.exceptions.ConnectionError as e:
            print(f"❌ Connection error: {e}")
            print(f"🔍 Error details: {type(e).__name__}")
            return False
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            print(f"🔍 Error type: {type(e).__name__}")
            return False

    def list_containers(self) -> List[Dict[str, Any]]:
        """List all available containers"""
        try:
            response = self.session.get(f"{self.api_base_url}/containers")
            response.raise_for_status()
            data = response.json()

            if data["success"]:
                print(f"📋 Found {len(data['containers'])} container(s):")
                for container in data["containers"]:
                    if "error" not in container:
                        print(
                            f"   - {container['id']}: {container['name']} "
                            f"({container['status']})"
                        )
                    else:
                        print(f"   ❌ Error: {container['error']}")
                return data["containers"]
            else:
                print(
                    f"❌ Failed to list containers: "
                    f"{data.get('error', 'Unknown error')}"
                )
                return []

        except Exception as e:
            print(f"❌ Error listing containers: {e}")
            return []

    def get_container_info(self, container_id: int) -> Optional[Dict[str, Any]]:
        """Get information about a specific container"""
        try:
            response = self.session.get(
                f"{self.api_base_url}/containers/{container_id}/info"
            )
            response.raise_for_status()
            data = response.json()

            if data["success"]:
                info = data["container_info"]
                print(f"📊 Container {container_id} Info:")
                print(f"   Status: {info.get('status', 'unknown')}")
                print(f"   Config: {info.get('config', 'unknown')[:100]}...")
                return info
            else:
                print(
                    f"❌ Failed to get container info: "
                    f"{data.get('error', 'Unknown error')}"
                )
                return None

        except Exception as e:
            print(f"❌ Error getting container info: {e}")
            return None

    def test_container_access(self, container_id: int) -> bool:
        """Test if a container is accessible"""
        try:
            response = self.session.get(
                f"{self.api_base_url}/containers/{container_id}/test"
            )
            response.raise_for_status()
            data = response.json()

            if data["success"]:
                accessible = data["accessible"]
                status = "✅ Accessible" if accessible else "❌ Not accessible"
                print(f"🔍 Container {container_id}: {status}")
                return accessible
            else:
                print(f"❌ Failed to test access: {data.get('error', 'Unknown error')}")
                return False

        except Exception as e:
            print(f"❌ Error testing container access: {e}")
            return False

    def execute_command(
        self, container_id: int, command: str, timeout: int = 30
    ) -> Optional[Dict[str, Any]]:
        """Execute a command in a container"""
        try:
            payload = {"command": command, "timeout": timeout}

            print(f"🚀 Executing command in container {container_id}: {command}")

            response = self.session.post(
                f"{self.api_base_url}/containers/{container_id}/execute", json=payload
            )
            response.raise_for_status()
            data = response.json()

            if data["success"]:
                result = data["result"]
                print("✅ Command completed successfully!")
                print(f"   📤 Output: {result['output'].strip()}")
                if result["error"]:
                    print(f"   ⚠️  Errors: {result['error'].strip()}")
                print(f"   📊 Exit Code: {result['exit_code']}")
                print(f"   ⏱️  Execution Time: {result['execution_time']:.2f}s")
                return result
            else:
                print(
                    f"❌ Command execution failed: {data.get('error', 'Unknown error')}"
                )
                return None

        except Exception as e:
            print(f"❌ Error executing command: {e}")
            return None

    def deploy_librechat(self, container_id: int) -> bool:
        """Deploy LibreChat in a container"""
        try:
            print(f"🚀 Starting LibreChat deployment in container {container_id}...")
            print("⏳ This may take several minutes...")

            response = self.session.post(
                f"{self.api_base_url}/containers/{container_id}/deploy-librechat"
            )
            response.raise_for_status()
            data = response.json()

            if data["success"]:
                print("✅ LibreChat deployment completed!")

                # Show deployment results
                results = data["deployment_results"]
                print("\n📋 Deployment Summary:")
                for step_result in results:
                    status = "✅" if step_result["success"] else "❌"
                    print(f"   {status} {step_result['step']}")
                    if not step_result["success"]:
                        print(f"      Error: {step_result['error']}")

                # Show final status
                librechat_running = data["librechat_running"]
                container_ip = data["container_ip"]
                access_url = data["access_url"]

                print("\n🎉 Final Status:")
                print(
                    f"   LibreChat Running: {'✅ Yes' if librechat_running else '❌ No'}"
                )
                print(f"   Container IP: {container_ip}")
                print(f"   Access URL: {access_url}")

                if librechat_running:
                    print(f"\n🌐 LibreChat is ready! Open: {access_url}")

                return True
            else:
                print(f"❌ Deployment failed: {data.get('error', 'Unknown error')}")
                return False

        except Exception as e:
            print(f"❌ Error during deployment: {e}")
            return False

    def interactive_session(self, container_id: int):
        """Start an interactive command session"""
        print(f"🐳 Interactive Session for Container {container_id}")
        print("Type 'exit' to quit, 'help' for available commands")
        print("=" * 50)

        while True:
            try:
                command = input(f"container-{container_id}> ").strip()

                if command.lower() in ["exit", "quit"]:
                    print("👋 Goodbye!")
                    break
                elif command.lower() == "help":
                    print("Available commands:")
                    print("  exit/quit - Exit session")
                    print("  help - Show this help")
                    print("  info - Show container info")
                    print("  status - Show container status")
                    print("  <any command> - Execute in container")
                elif command.lower() == "info":
                    self.get_container_info(container_id)
                elif command.lower() == "status":
                    self.execute_command(container_id, "ps aux | head -10")
                elif command:
                    self.execute_command(container_id, command)
                else:
                    continue

            except KeyboardInterrupt:
                print("\n👋 Goodbye!")
                break
            except Exception as e:
                print(f"❌ Error: {e}")


def main():
    """Main function for testing the client"""
    print("🐳 Cursor Container Client")
    print("=" * 40)

    # Initialize client
    client = CursorContainerClient()

    # Test connection
    if not client.test_connection():
        print("❌ Cannot connect to Container Console API")
        print("💡 Make sure the API service is running on your Proxmox host")
        return

    # List containers
    containers = client.list_containers()

    if not containers:
        print("❌ No containers found")
        return

    # Find LibreChat container
    librechat_container = None
    for container in containers:
        if "error" not in container and container.get("name") == "librechat":
            librechat_container = container
            break

    if librechat_container:
        container_id = int(librechat_container["id"])
        print(f"\n🎯 LibreChat container found: {container_id}")

        # Test access
        if client.test_container_access(container_id):
            print("\n🚀 Ready to deploy LibreChat!")

            # Ask user what to do
            print("\nWhat would you like to do?")
            print("1. Deploy LibreChat (automated)")
            print("2. Interactive session")
            print("3. Test single command")

            choice = input("Enter choice (1-3): ").strip()

            if choice == "1":
                client.deploy_librechat(container_id)
            elif choice == "2":
                client.interactive_session(container_id)
            elif choice == "3":
                command = input("Enter command to test: ").strip()
                if command:
                    client.execute_command(container_id, command)
            else:
                print("Invalid choice")
        else:
            print(f"❌ Cannot access container {container_id}")
    else:
        print("❌ LibreChat container not found")
        print("💡 Make sure container 200 (librechat) exists and is running")


if __name__ == "__main__":
    main()

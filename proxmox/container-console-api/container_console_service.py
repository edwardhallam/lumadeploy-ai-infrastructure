#!/usr/bin/env python3
"""
Container Console Service
Service running on Proxmox host to execute commands in LXC containers
"""

import subprocess
import time
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Dict, List


@dataclass
class CommandResult:
    """Result of a command execution"""

    command: str
    output: str
    error: str
    exit_code: int
    execution_time: float
    timestamp: datetime
    container_id: int


class ContainerConsoleManager:
    """Manages LXC container console operations"""

    def __init__(self):
        self.active_sessions = {}

    def execute_command(
        self, container_id: int, command: str, timeout: int = 30
    ) -> CommandResult:
        """Execute a command in a specific container"""
        start_time = time.time()

        try:
            print(f"🚀 Executing command in container {container_id}: {command}")

            # Use pct exec to run command in container
            full_command = [
                "pct",
                "exec",
                str(container_id),
                "--",
                "bash",
                "-c",
                command,
            ]

            # Execute command with timeout
            result = subprocess.run(
                full_command, capture_output=True, text=True, timeout=timeout
            )

            execution_time = time.time() - start_time

            command_result = CommandResult(
                command=command,
                output=result.stdout,
                error=result.stderr,
                exit_code=result.returncode,
                execution_time=execution_time,
                timestamp=datetime.now(),
                container_id=container_id,
            )

            print(
                f"✅ Command completed in {execution_time:.2f}s "
                f"(exit code: {result.returncode})"
            )
            return command_result

        except subprocess.TimeoutExpired:
            execution_time = time.time() - start_time
            print(f"⏰ Command timed out after {timeout}s")
            return CommandResult(
                command=command,
                output="",
                error=f"Command timed out after {timeout} seconds",
                exit_code=-1,
                execution_time=execution_time,
                timestamp=datetime.now(),
                container_id=container_id,
            )
        except Exception as e:
            execution_time = time.time() - start_time
            print(f"❌ Command execution failed: {e}")
            return CommandResult(
                command=command,
                output="",
                error=str(e),
                exit_code=-1,
                execution_time=execution_time,
                timestamp=datetime.now(),
                container_id=container_id,
            )

    def get_container_info(self, container_id: int) -> Dict[str, Any]:
        """Get information about a specific container"""
        try:
            # Get container status
            status_result = subprocess.run(
                ["pct", "status", str(container_id)], capture_output=True, text=True
            )

            # Get container config
            config_result = subprocess.run(
                ["pct", "config", str(container_id)], capture_output=True, text=True
            )

            return {
                "id": container_id,
                "status": (
                    status_result.stdout.strip()
                    if status_result.returncode == 0
                    else "unknown"
                ),
                "config": (
                    config_result.stdout.strip()
                    if config_result.returncode == 0
                    else "unknown"
                ),
                "status_command_success": status_result.returncode == 0,
                "config_command_success": config_result.returncode == 0,
            }
        except Exception as e:
            return {
                "id": container_id,
                "error": str(e),
                "status": "error",
                "config": "error",
            }

    def list_containers(self) -> List[Dict[str, Any]]:
        """List all LXC containers"""
        try:
            result = subprocess.run(["pct", "list"], capture_output=True, text=True)

            if result.returncode == 0:
                lines = result.stdout.strip().split("\n")
                containers = []

                # Skip header line
                for line in lines[1:]:
                    if line.strip():
                        parts = line.split()
                        if len(parts) >= 4:
                            containers.append(
                                {
                                    "id": parts[0],
                                    "status": parts[1],
                                    "name": parts[2],
                                    "template": parts[3] if len(parts) > 3 else "N/A",
                                }
                            )

                return containers
            else:
                return [{"error": "Failed to list containers", "stderr": result.stderr}]

        except Exception as e:
            return [{"error": str(e)}]

    def test_container_access(self, container_id: int) -> bool:
        """Test if we can access a container"""
        try:
            # Try to run a simple command
            result = subprocess.run(
                ["pct", "exec", str(container_id), "--", "echo", "test"],
                capture_output=True,
                text=True,
                timeout=10,
            )
            return result.returncode == 0
        except Exception:
            return False


def main():
    """Main function for testing the service"""
    print("🐳 Container Console Service")
    print("=" * 40)

    manager = ContainerConsoleManager()

    # Test container listing
    print("\n📋 Available Containers:")
    containers = manager.list_containers()
    for container in containers:
        if "error" not in container:
            print(
                f"   - {container['id']}: {container['name']} ({container['status']})"
            )
        else:
            print(f"   ❌ Error: {container['error']}")

    # Test with LibreChat container (ID 200)
    container_id = 200
    print(f"\n🧪 Testing Container {container_id}:")

    # Test access
    if manager.test_container_access(container_id):
        print(f"   ✅ Container {container_id} is accessible")

        # Test simple command
        print("\n🚀 Testing command execution...")
        result = manager.execute_command(
            container_id, "echo 'Hello from LibreChat container!' && hostname"
        )

        print(f"   📤 Output: {result.output.strip()}")
        if result.error:
            print(f"   ⚠️  Errors: {result.error.strip()}")
        print(f"   📊 Exit Code: {result.exit_code}")
        print(f"   ⏱️  Execution Time: {result.execution_time:.2f}s")

        # Test system info
        print("\n🔍 Getting system information...")
        system_result = manager.execute_command(
            container_id, "uname -a && cat /etc/os-release | head -3"
        )
        print(f"   📤 System Info: {system_result.output.strip()}")

    else:
        print(f"   ❌ Container {container_id} is not accessible")

    print("\n🎯 Service is ready for integration!")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Dynamic Ansible Inventory Script
Reads Terraform outputs to generate inventory
"""

import json
import subprocess
import sys
import os


def run_terraform_output():
    """Run terraform output and return JSON"""
    try:
        # Change to terraform directory
        terraform_dir = os.path.join(os.path.dirname(__file__), "..", "terraform")
        os.chdir(terraform_dir)

        # Run terraform output -json
        result = subprocess.run(
            ["terraform", "output", "-json"], capture_output=True, text=True, check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running terraform output: {e}", file=sys.stderr)
        return {}
    except json.JSONDecodeError as e:
        print(f"Error parsing terraform output: {e}", file=sys.stderr)
        return {}


def generate_inventory():
    """Generate Ansible inventory from Terraform outputs"""
    tf_outputs = run_terraform_output()

    inventory = {
        "_meta": {"hostvars": {}},
        "all": {
            "children": [
                "ai_containers",
                "librechat",
                "mcp_server",
                "monitoring",
                "reverse_proxy",
            ]
        },
        "ai_containers": {
            "hosts": [],
            "vars": {
                "ansible_user": "root",
                "ansible_ssh_common_args": "-o StrictHostKeyChecking=no",
            },
        },
        "librechat": {
            "hosts": [],
            "vars": {"service_type": "librechat", "web_port": 3000},
        },
        "mcp_server": {
            "hosts": [],
            "vars": {"service_type": "mcp_server", "api_port": 8000},
        },
        "monitoring": {
            "hosts": [],
            "vars": {
                "service_type": "monitoring",
                "prometheus_port": 9090,
                "grafana_port": 3000,
            },
        },
        "reverse_proxy": {
            "hosts": [],
            "vars": {
                "service_type": "reverse_proxy",
                "http_port": 80,
                "https_port": 443,
            },
        },
    }

    # Add hosts based on Terraform outputs
    if "librechat_ip" in tf_outputs:
        ip = tf_outputs["librechat_ip"]["value"]
        inventory["_meta"]["hostvars"][ip] = {
            "ansible_host": ip,
            "container_name": "librechat",
        }
        inventory["ai_containers"]["hosts"].append(ip)
        inventory["librechat"]["hosts"].append(ip)

    if "mcp_server_ip" in tf_outputs:
        ip = tf_outputs["mcp_server_ip"]["value"]
        inventory["_meta"]["hostvars"][ip] = {
            "ansible_host": ip,
            "container_name": "mcp_server",
        }
        inventory["ai_containers"]["hosts"].append(ip)
        inventory["mcp_server"]["hosts"].append(ip)

    if "monitoring_ip" in tf_outputs:
        ip = tf_outputs["monitoring_ip"]["value"]
        inventory["_meta"]["hostvars"][ip] = {
            "ansible_host": ip,
            "container_name": "monitoring",
        }
        inventory["ai_containers"]["hosts"].append(ip)
        inventory["monitoring"]["hosts"].append(ip)

    if "reverse_proxy_ip" in tf_outputs:
        ip = tf_outputs["reverse_proxy_ip"]["value"]
        inventory["_meta"]["hostvars"][ip] = {
            "ansible_host": ip,
            "container_name": "reverse_proxy",
        }
        inventory["ai_containers"]["hosts"].append(ip)
        inventory["reverse_proxy"]["hosts"].append(ip)

    return inventory


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--list":
        print(json.dumps(generate_inventory(), indent=2))
    elif len(sys.argv) > 2 and sys.argv[1] == "--host":
        # Return empty hostvars for individual host
        print(json.dumps({}))
    else:
        print("Usage: inventory.py --list | --host <hostname>", file=sys.stderr)
        sys.exit(1)

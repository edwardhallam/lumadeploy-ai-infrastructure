#!/usr/bin/env python3
"""
Container Console API
Flask API service to bridge between Cursor and container console manager
"""

import logging
from datetime import datetime

from flask import Flask, jsonify, request
from flask_cors import CORS

from container_console_service import ContainerConsoleManager

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests

# Initialize the container console manager
console_manager = ContainerConsoleManager()


@app.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint"""
    return jsonify(
        {
            "status": "healthy",
            "service": "container-console-api",
            "timestamp": datetime.now().isoformat(),
        }
    )


@app.route("/containers", methods=["GET"])
def list_containers():
    """List all available containers"""
    try:
        containers = console_manager.list_containers()
        return jsonify(
            {
                "success": True,
                "containers": containers,
                "timestamp": datetime.now().isoformat(),
            }
        )
    except Exception as e:
        logger.error(f"Error listing containers: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
                }
            ),
            500,
        )


@app.route("/containers/<int:container_id>/info", methods=["GET"])
def get_container_info(container_id):
    """Get information about a specific container"""
    try:
        info = console_manager.get_container_info(container_id)
        return jsonify(
            {
                "success": True,
                "container_info": info,
                "timestamp": datetime.now().isoformat(),
            }
        )
    except Exception as e:
        logger.error(f"Error getting container info: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
                }
            ),
            500,
        )


@app.route("/containers/<int:container_id>/execute", methods=["POST"])
def execute_command(container_id):
    """Execute a command in a specific container"""
    try:
        data = request.get_json()
        if not data or "command" not in data:
            return (
                jsonify(
                    {
                        "success": False,
                        "error": "Command is required",
                        "timestamp": datetime.now().isoformat(),
                    }
                ),
                400,
            )

        command = data["command"]
        timeout = data.get("timeout", 30)

        logger.info(f"Executing command in container {container_id}: {command}")

        # Execute the command
        result = console_manager.execute_command(container_id, command, timeout)

        # Convert result to JSON-serializable format
        result_dict = {
            "command": result.command,
            "output": result.output,
            "error": result.error,
            "exit_code": result.exit_code,
            "execution_time": result.execution_time,
            "timestamp": result.timestamp.isoformat(),
            "container_id": result.container_id,
        }

        return jsonify(
            {
                "success": True,
                "result": result_dict,
                "timestamp": datetime.now().isoformat(),
            }
        )

    except Exception as e:
        logger.error(f"Error executing command: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
                }
            ),
            500,
        )


@app.route("/containers/<int:container_id>/test", methods=["GET"])
def test_container_access(container_id):
    """Test if a container is accessible"""
    try:
        accessible = console_manager.test_container_access(container_id)
        return jsonify(
            {
                "success": True,
                "container_id": container_id,
                "accessible": accessible,
                "timestamp": datetime.now().isoformat(),
            }
        )
    except Exception as e:
        logger.error(f"Error testing container access: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
                }
            ),
            500,
        )


@app.route("/containers/<int:container_id>/deploy-librechat", methods=["POST"])
def deploy_librechat(container_id):
    """Deploy LibreChat in a container (automated deployment)"""
    try:
        logger.info(f"Starting LibreChat deployment in container {container_id}")

        deployment_steps = [
            ("System Update", "apt update && apt upgrade -y"),
            ("Install Dependencies", "apt install -y curl wget git"),
            ("Install Docker", "curl -fsSL https://get.docker.com | sh"),
            ("Enable Docker", "systemctl enable docker"),
            ("Start Docker", "systemctl start docker"),
            ("Add User to Docker Group", "usermod -aG docker $USER"),
            (
                "Deploy LibreChat",
                "docker run -d --name librechat --restart unless-stopped "
                "-p 3000:3000 -e PUID=1000 -e PGID=1000 "
                "ghcr.io/danny-avila/librechat:latest",
            ),
        ]

        results = []

        for step_name, command in deployment_steps:
            logger.info(f"Executing step: {step_name}")
            result = console_manager.execute_command(container_id, command, timeout=120)

            step_result = {
                "step": step_name,
                "command": command,
                "success": result.exit_code == 0,
                "output": result.output,
                "error": result.error,
                "exit_code": result.exit_code,
                "execution_time": result.execution_time,
            }

            results.append(step_result)

            if not step_result["success"]:
                logger.warning(f"Step '{step_name}' failed: {result.error}")
                # Continue with next steps even if one fails

        # Check if LibreChat is running
        check_result = console_manager.execute_command(
            container_id, "docker ps | grep librechat", timeout=30
        )
        librechat_running = "librechat" in check_result.output

        # Get container IP
        ip_result = console_manager.execute_command(
            container_id, "hostname -I", timeout=30
        )
        container_ip = (
            ip_result.output.strip().split()[0]
            if ip_result.output.strip()
            else "unknown"
        )

        return jsonify(
            {
                "success": True,
                "deployment_results": results,
                "librechat_running": librechat_running,
                "container_ip": container_ip,
                "access_url": (
                    f"http://{container_ip}:3000"
                    if container_ip != "unknown"
                    else "unknown"
                ),
                "timestamp": datetime.now().isoformat(),
            }
        )

    except Exception as e:
        logger.error(f"Error deploying LibreChat: {e}")
        return (
            jsonify(
                {
                    "success": False,
                    "error": str(e),
                    "timestamp": datetime.now().isoformat(),
                }
            ),
            500,
        )


if __name__ == "__main__":
    print("🚀 Starting Container Console API...")
    print("📡 API will be available at: http://0.0.0.0:5000")
    print("🔑 Endpoints:")
    print("   GET  /health")
    print("   GET  /containers")
    print("   GET  /containers/<id>/info")
    print("   POST /containers/<id>/execute")
    print("   GET  /containers/<id>/test")
    print("   POST /containers/<id>/deploy-librechat")
    print("=" * 50)

    # Run the Flask app
    app.run(host="0.0.0.0", port=5000, debug=True)

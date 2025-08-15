#!/usr/bin/env python3
"""
GitHub Actions Webhook Server
Real-time monitoring endpoint for GitHub Actions events
"""

import json
import logging
import os
import subprocess
import sys
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer

import hashlib
import hmac

# Configuration
PORT = int(os.environ.get("WEBHOOK_PORT", 8080))
SECRET = os.environ.get("GITHUB_WEBHOOK_SECRET", "")
SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL", "")
DISCORD_WEBHOOK_URL = os.environ.get("DISCORD_WEBHOOK_URL", "")
LOG_FILE = os.environ.get("WEBHOOK_LOG_FILE", "/tmp/github_webhook.log")

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler(LOG_FILE), logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)


class GitHubWebhookHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        """Override to use our logger"""
        logger.info(f"{self.address_string()} - {format % args}")

    def verify_signature(self, payload_body, signature_header):
        """Verify GitHub webhook signature"""
        if not SECRET:
            return True  # Skip verification if no secret is set

        if not signature_header:
            return False

        expected_signature = hmac.new(
            SECRET.encode("utf-8"), payload_body, hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(f"sha256={expected_signature}", signature_header)

    def send_slack_notification(self, message, color="good"):
        """Send notification to Slack"""
        if not SLACK_WEBHOOK_URL:
            return

        try:
            import requests

            payload = {
                "attachments": [
                    {"color": color, "text": message, "ts": datetime.now().timestamp()}
                ]
            }
            requests.post(SLACK_WEBHOOK_URL, json=payload, timeout=10)
            logger.info("Slack notification sent")
        except Exception as e:
            logger.error(f"Failed to send Slack notification: {e}")

    def send_discord_notification(self, message):
        """Send notification to Discord"""
        if not DISCORD_WEBHOOK_URL:
            return

        try:
            import requests

            payload = {"content": message}
            requests.post(DISCORD_WEBHOOK_URL, json=payload, timeout=10)
            logger.info("Discord notification sent")
        except Exception as e:
            logger.error(f"Failed to send Discord notification: {e}")

    def run_auto_prioritize(self):
        """Run the auto-prioritize failures script"""
        try:
            script_path = os.path.join(
                os.path.dirname(__file__), "auto-prioritize-failures.sh"
            )
            if os.path.exists(script_path):
                result = subprocess.run(
                    [script_path], capture_output=True, text=True, timeout=30
                )
                if result.returncode == 0:
                    logger.info("Auto-prioritize script executed successfully")
                else:
                    logger.warning(f"Auto-prioritize script failed: {result.stderr}")
            else:
                logger.warning("Auto-prioritize script not found")
        except Exception as e:
            logger.error(f"Failed to run auto-prioritize script: {e}")

    def handle_workflow_run_event(self, payload):
        """Handle workflow_run webhook events"""
        action = payload.get("action", "")
        workflow_run = payload.get("workflow_run", {})

        workflow_name = workflow_run.get("name", "Unknown")
        status = workflow_run.get("status", "")
        conclusion = workflow_run.get("conclusion", "")
        html_url = workflow_run.get("html_url", "")
        head_branch = workflow_run.get("head_branch", "")
        head_sha = workflow_run.get("head_sha", "")[:7]
        actor = workflow_run.get("triggering_actor", {}).get("login", "Unknown")

        logger.info(
            f"Workflow event: {action} - {workflow_name} ({status}/{conclusion})"
        )

        # Create notification message
        if action == "requested":
            message = (
                f"🚀 **Workflow Started**\n**Name:** {workflow_name}\n**Branch:** "
                f"{head_branch}\n**Commit:** {head_sha}\n**Actor:** {actor}\n**URL:** "
                f"{html_url}"
            )
            color = "warning"

        elif action == "in_progress":
            message = (
                f"🔄 **Workflow Running**\n**Name:** {workflow_name}\n**Branch:** "
                f"{head_branch}\n**URL:** {html_url}"
            )
            color = "warning"

        elif action == "completed":
            if conclusion == "success":
                message = (
                    f"✅ **Workflow Succeeded**\n**Name:** {workflow_name}\n**Branch:** "
                    f"{head_branch}\n**Commit:** {head_sha}\n**Actor:** {actor}\n**URL:** "
                    f"{html_url}"
                )
                color = "good"
            elif conclusion == "failure":
                message = (
                    f"❌ **Workflow Failed**\n**Name:** {workflow_name}\n**Branch:** "
                    f"{head_branch}\n**Commit:** {head_sha}\n**Actor:** {actor}\n**URL:** "
                    f"{html_url}"
                )
                color = "danger"

                # Auto-prioritize failures
                logger.info("Workflow failed, running auto-prioritize script...")
                self.run_auto_prioritize()

            elif conclusion == "cancelled":
                message = (
                    f"⚠️ **Workflow Cancelled**\n**Name:** {workflow_name}\n**Branch:** "
                    f"{head_branch}\n**URL:** {html_url}"
                )
                color = "warning"
            else:
                message = (
                    f"❓ **Workflow Completed**\n**Name:** {workflow_name}\n**Status:** "
                    f"{conclusion}\n**Branch:** {head_branch}\n**URL:** {html_url}"
                )
                color = "warning"
        else:
            message = (
                f"📋 **Workflow Event**\n**Action:** {action}\n**Name:** {workflow_name}\n**Status:** "
                f"{status}\n**URL:** {html_url}"
            )
            color = "good"

        # Send notifications
        self.send_slack_notification(message, color)
        self.send_discord_notification(message)

        return {
            "event": "workflow_run",
            "action": action,
            "workflow": workflow_name,
            "status": status,
            "conclusion": conclusion,
            "branch": head_branch,
            "commit": head_sha,
            "actor": actor,
            "url": html_url,
            "timestamp": datetime.now().isoformat(),
        }

    def handle_push_event(self, payload):
        """Handle push webhook events"""
        ref = payload.get("ref", "")
        commits = payload.get("commits", [])
        pusher = payload.get("pusher", {}).get("name", "Unknown")

        if ref.startswith("refs/heads/"):
            branch = ref.replace("refs/heads/", "")
            commit_count = len(commits)

            message = (
                f"📝 **Push Event**\n**Branch:** {branch}\n**Commits:** {commit_count}\n**Pusher:** "
                f"{pusher}"
            )

            if commits:
                latest_commit = commits[-1]
                commit_sha = latest_commit.get("id", "")[:7]
                commit_message = latest_commit.get("message", "")
                message += f"\n**Latest Commit:** {commit_sha} - {commit_message}"

            logger.info(f"Push event: {commit_count} commits to {branch} by {pusher}")

            # Only send notifications for main/master branches
            if branch in ["main", "master", "develop"]:
                self.send_slack_notification(message, "good")
                self.send_discord_notification(message)

            return {
                "event": "push",
                "branch": branch,
                "commits": commit_count,
                "pusher": pusher,
                "timestamp": datetime.now().isoformat(),
            }

    def do_GET(self):
        """Handle GET requests (health check)"""
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            response = {
                "status": "healthy",
                "timestamp": datetime.now().isoformat(),
                "port": PORT,
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        """Handle POST requests (webhook events)"""
        if self.path != "/webhook":
            self.send_response(404)
            self.end_headers()
            return

        try:
            # Read the payload
            content_length = int(self.headers.get("Content-Length", 0))
            payload_body = self.rfile.read(content_length)

            # Verify signature
            signature = self.headers.get("X-Hub-Signature-256")
            if not self.verify_signature(payload_body, signature):
                logger.warning("Invalid webhook signature")
                self.send_response(401)
                self.end_headers()
                return

            # Parse JSON payload
            payload = json.loads(payload_body.decode("utf-8"))
            event_type = self.headers.get("X-GitHub-Event", "")

            logger.info(f"Received {event_type} event")

            # Handle different event types
            result = None
            if event_type == "workflow_run":
                result = self.handle_workflow_run_event(payload)
            elif event_type == "push":
                result = self.handle_push_event(payload)
            elif event_type == "ping":
                logger.info("Received ping event - webhook is working!")
                result = {"event": "ping", "status": "ok"}
            else:
                logger.info(f"Unhandled event type: {event_type}")
                result = {"event": event_type, "status": "ignored"}

            # Send response
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()

            response = {
                "status": "success",
                "event": event_type,
                "processed": result,
                "timestamp": datetime.now().isoformat(),
            }
            self.wfile.write(json.dumps(response, indent=2).encode())

        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON payload: {e}")
            self.send_response(400)
            self.end_headers()
        except Exception as e:
            logger.error(f"Error processing webhook: {e}")
            self.send_response(500)
            self.end_headers()


def main():
    """Start the webhook server"""
    server_address = ("", PORT)
    httpd = HTTPServer(server_address, GitHubWebhookHandler)

    logger.info(f"🔔 GitHub Actions Webhook Server starting on port {PORT}")
    logger.info(f"📝 Logs will be written to: {LOG_FILE}")
    logger.info(f"🔗 Webhook URL: http://your-server:{PORT}/webhook")
    logger.info(f"❤️ Health check: http://your-server:{PORT}/health")

    if SECRET:
        logger.info("🔐 Webhook signature verification enabled")
    else:
        logger.warning(
            "⚠️  Webhook signature verification disabled (set GITHUB_WEBHOOK_SECRET)"
        )

    if SLACK_WEBHOOK_URL:
        logger.info("📢 Slack notifications enabled")

    if DISCORD_WEBHOOK_URL:
        logger.info("🎮 Discord notifications enabled")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info("🛑 Shutting down webhook server...")
        httpd.server_close()


if __name__ == "__main__":
    main()

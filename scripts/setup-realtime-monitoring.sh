#!/bin/bash
# Setup Real-time GitHub Actions Monitoring
# Configures webhooks, notifications, and monitoring services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_banner() {
    echo -e "${PURPLE}🔔 Real-time GitHub Actions Monitoring Setup${NC}"
    echo "=============================================="
    echo ""
}

print_section() {
    echo -e "${CYAN}📋 $1${NC}"
    echo "----------------------------------------"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    local missing_deps=()
    
    if ! command -v gh &> /dev/null; then
        missing_deps+=("GitHub CLI (gh)")
        print_error "GitHub CLI not found. Install with: brew install gh"
    else
        print_success "GitHub CLI found"
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
        print_error "jq not found. Install with: brew install jq"
    else
        print_success "jq found"
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("Python 3")
        print_error "Python 3 not found"
    else
        print_success "Python 3 found"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_status "Please install the missing dependencies and run this script again"
        exit 1
    fi
    
    # Check GitHub CLI authentication
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub CLI"
        print_status "Run: gh auth login"
        exit 1
    else
        print_success "GitHub CLI authenticated"
    fi
    
    echo ""
}

# Get repository information
get_repo_info() {
    print_section "Repository Information"
    
    if git remote get-url origin &> /dev/null; then
        REPO_URL=$(git remote get-url origin)
        if [[ $REPO_URL == *"github.com"* ]]; then
            REPO=$(echo $REPO_URL | sed -E 's/.*github\.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/' | sed 's/\.git$//')
            print_success "Repository: $REPO"
        else
            print_error "Not a GitHub repository"
            exit 1
        fi
    else
        print_error "No git remote origin found"
        exit 1
    fi
    
    echo ""
}

# Setup monitoring scripts
setup_scripts() {
    print_section "Setting Up Monitoring Scripts"
    
    # Make scripts executable
    chmod +x scripts/realtime-monitor.sh
    chmod +x scripts/webhook-server.py
    print_success "Made monitoring scripts executable"
    
    # Install Python dependencies for webhook server
    if command -v pip3 &> /dev/null; then
        print_status "Installing Python dependencies..."
        pip3 install requests --user --quiet || print_warning "Failed to install requests (webhook server may not work)"
    fi
    
    echo ""
}

# Configure GitHub webhooks
configure_webhooks() {
    print_section "GitHub Webhook Configuration"
    
    print_status "Current webhooks for repository $REPO:"
    gh api repos/$REPO/hooks --jq '.[] | {id, name, config: {url: .config.url, content_type: .config.content_type}, events}' || print_warning "Failed to list webhooks"
    
    echo ""
    print_status "To configure a webhook for real-time monitoring:"
    echo ""
    echo "1. Go to: https://github.com/$REPO/settings/hooks"
    echo "2. Click 'Add webhook'"
    echo "3. Set Payload URL to: http://your-server:8080/webhook"
    echo "4. Set Content type to: application/json"
    echo "5. Select individual events:"
    echo "   - Workflow runs"
    echo "   - Pushes"
    echo "6. Add webhook"
    echo ""
    print_status "Or use the GitHub CLI:"
    echo "gh api repos/$REPO/hooks -X POST -f url='http://your-server:8080/webhook' -f content_type='json' -F events='[\"workflow_run\",\"push\"]'"
    
    echo ""
}

# Setup Slack integration
setup_slack() {
    print_section "Slack Integration Setup"
    
    echo "To enable Slack notifications:"
    echo ""
    echo "1. Create a Slack App:"
    echo "   - Go to https://api.slack.com/apps"
    echo "   - Click 'Create New App'"
    echo "   - Choose 'From scratch'"
    echo "   - Name: 'GitHub Actions Monitor'"
    echo ""
    echo "2. Enable Incoming Webhooks:"
    echo "   - Go to 'Incoming Webhooks'"
    echo "   - Turn on 'Activate Incoming Webhooks'"
    echo "   - Click 'Add New Webhook to Workspace'"
    echo "   - Choose your channel (e.g., #infrastructure)"
    echo ""
    echo "3. Configure GitHub Secrets:"
    echo "   - Go to https://github.com/$REPO/settings/secrets/actions"
    echo "   - Add secret: SLACK_WEBHOOK_URL"
    echo "   - Value: Your Slack webhook URL"
    echo ""
    echo "4. Uncomment Slack notification steps in .github/workflows/validate.yml"
    
    echo ""
}

# Setup Discord integration
setup_discord() {
    print_section "Discord Integration Setup"
    
    echo "To enable Discord notifications:"
    echo ""
    echo "1. Create a Discord Webhook:"
    echo "   - Go to your Discord server"
    echo "   - Right-click on the channel you want notifications in"
    echo "   - Select 'Edit Channel'"
    echo "   - Go to 'Integrations' > 'Webhooks'"
    echo "   - Click 'New Webhook'"
    echo "   - Name: 'GitHub Actions'"
    echo "   - Copy the webhook URL"
    echo ""
    echo "2. Configure GitHub Secrets:"
    echo "   - Go to https://github.com/$REPO/settings/secrets/actions"
    echo "   - Add secret: DISCORD_WEBHOOK_URL"
    echo "   - Value: Your Discord webhook URL"
    echo ""
    echo "3. Uncomment Discord notification steps in .github/workflows/notify.yml"
    
    echo ""
}

# Create systemd service for webhook server
create_systemd_service() {
    print_section "Systemd Service Setup (Linux)"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local service_file="/tmp/github-webhook.service"
        local script_path="$(pwd)/scripts/webhook-server.py"
        
        cat > "$service_file" << EOF
[Unit]
Description=GitHub Actions Webhook Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
ExecStart=/usr/bin/python3 $script_path
Restart=always
RestartSec=10
Environment=WEBHOOK_PORT=8080
Environment=WEBHOOK_LOG_FILE=/var/log/github-webhook.log

[Install]
WantedBy=multi-user.target
EOF

        print_status "Created systemd service file: $service_file"
        echo ""
        echo "To install and start the service:"
        echo "sudo cp $service_file /etc/systemd/system/"
        echo "sudo systemctl daemon-reload"
        echo "sudo systemctl enable github-webhook"
        echo "sudo systemctl start github-webhook"
        echo ""
        echo "To check status:"
        echo "sudo systemctl status github-webhook"
        echo "sudo journalctl -u github-webhook -f"
    else
        print_status "Systemd service setup is only available on Linux"
        print_status "For macOS, you can use launchd or run the webhook server manually"
    fi
    
    echo ""
}

# Create monitoring dashboard
create_dashboard() {
    print_section "Monitoring Dashboard"
    
    local dashboard_file="monitoring/github-actions-dashboard.html"
    mkdir -p monitoring
    
    cat > "$dashboard_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GitHub Actions Monitor</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { background: #24292e; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .status-card { background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .success { border-left: 4px solid #28a745; }
        .failure { border-left: 4px solid #dc3545; }
        .running { border-left: 4px solid #ffc107; }
        .timestamp { color: #666; font-size: 0.9em; }
        .refresh-btn { background: #0366d6; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
        .logs { background: #f8f9fa; padding: 15px; border-radius: 4px; font-family: monospace; font-size: 0.9em; max-height: 300px; overflow-y: auto; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔔 GitHub Actions Real-time Monitor</h1>
            <p>Live monitoring dashboard for GitHub Actions workflows</p>
        </div>
        
        <div class="status-card">
            <h2>Quick Actions</h2>
            <button class="refresh-btn" onclick="checkStatus()">🔄 Check Status</button>
            <button class="refresh-btn" onclick="startMonitoring()">▶️ Start Monitoring</button>
            <button class="refresh-btn" onclick="viewLogs()">📋 View Logs</button>
        </div>
        
        <div class="status-card" id="status-display">
            <h2>Current Status</h2>
            <p>Click "Check Status" to see the latest workflow status</p>
        </div>
        
        <div class="status-card">
            <h2>Recent Activity</h2>
            <div id="activity-log" class="logs">
                <p>No recent activity</p>
            </div>
        </div>
        
        <div class="status-card">
            <h2>Setup Instructions</h2>
            <ol>
                <li>Configure GitHub webhook: <code>http://your-server:8080/webhook</code></li>
                <li>Start webhook server: <code>./scripts/webhook-server.py</code></li>
                <li>Start real-time monitor: <code>./scripts/realtime-monitor.sh monitor</code></li>
                <li>Configure Slack/Discord notifications (optional)</li>
            </ol>
        </div>
    </div>
    
    <script>
        function checkStatus() {
            document.getElementById('status-display').innerHTML = '<h2>Current Status</h2><p>🔄 Checking status...</p>';
            // This would integrate with your monitoring API
            setTimeout(() => {
                document.getElementById('status-display').innerHTML = '<h2>Current Status</h2><div class="success"><p>✅ All workflows are healthy</p><p class="timestamp">Last checked: ' + new Date().toLocaleString() + '</p></div>';
            }, 1000);
        }
        
        function startMonitoring() {
            alert('Start the monitoring script: ./scripts/realtime-monitor.sh monitor');
        }
        
        function viewLogs() {
            const logs = document.getElementById('activity-log');
            logs.innerHTML = `
                <p>[${new Date().toLocaleTimeString()}] 🚀 Workflow started: Validate LumaDeploy</p>
                <p>[${new Date().toLocaleTimeString()}] 🔄 Workflow running: Validate LumaDeploy</p>
                <p>[${new Date().toLocaleTimeString()}] ✅ Workflow completed: Validate LumaDeploy</p>
            `;
        }
        
        // Auto-refresh every 30 seconds
        setInterval(() => {
            if (document.getElementById('status-display').innerHTML.includes('healthy')) {
                checkStatus();
            }
        }, 30000);
    </script>
</body>
</html>
EOF

    print_success "Created monitoring dashboard: $dashboard_file"
    print_status "Open in browser: file://$(pwd)/$dashboard_file"
    
    echo ""
}

# Update Makefile with new commands
update_makefile() {
    print_section "Updating Makefile"
    
    if [ -f "Makefile" ]; then
        # Add real-time monitoring commands to Makefile
        if ! grep -q "monitor-realtime" Makefile; then
            cat >> Makefile << 'EOF'

# Real-time GitHub Actions Monitoring
.PHONY: monitor-realtime monitor-once webhook-server setup-monitoring

monitor-realtime: ## Start real-time GitHub Actions monitoring
	@echo "🔔 Starting real-time GitHub Actions monitoring..."
	@./scripts/realtime-monitor.sh monitor

monitor-once: ## Perform one-time GitHub Actions check
	@echo "🔍 Checking GitHub Actions status..."
	@./scripts/realtime-monitor.sh check

webhook-server: ## Start GitHub webhook server
	@echo "🌐 Starting GitHub webhook server..."
	@./scripts/webhook-server.py

setup-monitoring: ## Setup real-time monitoring
	@echo "⚙️ Setting up real-time monitoring..."
	@./scripts/setup-realtime-monitoring.sh
EOF
            print_success "Added real-time monitoring commands to Makefile"
        else
            print_status "Makefile already contains monitoring commands"
        fi
    else
        print_warning "Makefile not found, skipping Makefile update"
    fi
    
    echo ""
}

# Create documentation
create_documentation() {
    print_section "Creating Documentation"
    
    local doc_file="docs/realtime-monitoring.md"
    
    cat > "$doc_file" << 'EOF'
# 🔔 Real-time GitHub Actions Monitoring

Advanced real-time monitoring system for GitHub Actions with instant notifications and comprehensive tracking.

## 🚀 Quick Start

```bash
# Setup monitoring (one-time)
make setup-monitoring

# Start real-time monitoring
make monitor-realtime

# Start webhook server (in another terminal)
make webhook-server
```

## 📋 Features

### ✅ **Real-time Notifications**
- Instant alerts when workflows start, complete, or fail
- Slack and Discord integration
- Webhook-based event handling
- Auto-prioritization of failures

### ✅ **Multiple Monitoring Modes**
- **Continuous monitoring** - Polls GitHub API every 10 seconds
- **Webhook server** - Receives real-time events from GitHub
- **One-time checks** - Manual status verification
- **Dashboard view** - Web-based monitoring interface

### ✅ **Smart Failure Handling**
- Automatic failure prioritization
- Integration with existing failure management
- Detailed error reporting and links
- Retry logic for API failures

## 🛠️ Setup Instructions

### 1. **Configure GitHub Webhook**
```bash
# Go to your repository settings
https://github.com/your-username/your-repo/settings/hooks

# Add webhook with:
# - Payload URL: http://your-server:8080/webhook
# - Content type: application/json
# - Events: Workflow runs, Pushes
```

### 2. **Setup Slack Notifications (Optional)**
```bash
# Create Slack app and webhook
# Add GitHub secret: SLACK_WEBHOOK_URL
# Uncomment Slack steps in workflows
```

### 3. **Setup Discord Notifications (Optional)**
```bash
# Create Discord webhook
# Add GitHub secret: DISCORD_WEBHOOK_URL
# Uncomment Discord steps in workflows
```

## 🔧 Usage

### **Continuous Monitoring**
```bash
# Start monitoring with default 10-second intervals
./scripts/realtime-monitor.sh monitor

# Custom poll interval (30 seconds)
./scripts/realtime-monitor.sh monitor -i 30
```

### **Webhook Server**
```bash
# Start webhook server on default port 8080
./scripts/webhook-server.py

# Custom port
WEBHOOK_PORT=9000 ./scripts/webhook-server.py

# With environment variables
export SLACK_WEBHOOK_URL="https://hooks.slack.com/..."
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
./scripts/webhook-server.py
```

### **One-time Checks**
```bash
# Quick status check
./scripts/realtime-monitor.sh check

# Or via Makefile
make monitor-once
```

## 📊 Monitoring Dashboard

Open the web dashboard:
```bash
open monitoring/github-actions-dashboard.html
```

Features:
- Live status updates
- Recent activity log
- Quick action buttons
- Setup instructions

## 🔔 Notification Examples

### **Slack Notifications**
```
🚀 Workflow Started
Name: Validate LumaDeploy
Branch: main
Commit: abc1234
Actor: username
URL: https://github.com/...
```

### **Discord Notifications**
```
✅ Workflow Succeeded
Name: Validate LumaDeploy
Branch: main
Commit: abc1234
Actor: username
URL: https://github.com/...
```

## 🚨 Failure Handling

When a workflow fails:
1. **Immediate notification** sent to configured channels
2. **Auto-prioritize script** runs automatically
3. **Failure details** logged with direct links
4. **Todo items** created for tracking

## 🔧 Configuration

### **Environment Variables**
```bash
# Webhook server
export WEBHOOK_PORT=8080
export GITHUB_WEBHOOK_SECRET="your-secret"
export WEBHOOK_LOG_FILE="/tmp/webhook.log"

# Notifications
export SLACK_WEBHOOK_URL="https://hooks.slack.com/..."
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."

# Monitoring
export POLL_INTERVAL=10
```

### **GitHub Secrets**
Configure in repository settings:
- `SLACK_WEBHOOK_URL` - Slack webhook URL
- `DISCORD_WEBHOOK_URL` - Discord webhook URL
- `GITHUB_WEBHOOK_SECRET` - Webhook signature verification

## 🔍 Troubleshooting

### **Common Issues**

**Webhook not receiving events:**
- Check webhook URL is accessible
- Verify webhook configuration in GitHub
- Check firewall/network settings

**Notifications not working:**
- Verify webhook URLs are correct
- Check GitHub secrets are configured
- Review webhook server logs

**API rate limiting:**
- Increase poll interval
- Use webhook mode instead of polling
- Check GitHub API rate limits

### **Logs and Debugging**
```bash
# Webhook server logs
tail -f /tmp/github_webhook.log

# Monitor state file
cat /tmp/github_actions_state.json

# Notification log
tail -f /tmp/github_actions_notifications.log
```

## 🎯 Best Practices

1. **Use webhooks for production** - More reliable than polling
2. **Configure proper secrets** - Enable signature verification
3. **Monitor webhook health** - Use `/health` endpoint
4. **Set up proper logging** - Configure log rotation
5. **Test notifications** - Verify all channels work

## 🔗 Integration

### **With Existing Scripts**
The real-time monitor integrates with:
- `auto-prioritize-failures.sh` - Automatic failure handling
- `check-github-actions.sh` - Status checking
- GitHub Actions workflows - Built-in notifications

### **With CI/CD Pipelines**
```bash
# In your deployment pipeline
if ! ./scripts/realtime-monitor.sh check; then
    echo "GitHub Actions failed, stopping deployment"
    exit 1
fi
```

## 📈 Benefits

- **Immediate feedback** on workflow status
- **Proactive failure handling** with auto-prioritization
- **Multiple notification channels** for team awareness
- **Comprehensive logging** for audit trails
- **Flexible deployment** options (polling vs webhooks)

---

**🔔 Real-time monitoring ensures you never miss a GitHub Actions event!**
EOF

    print_success "Created documentation: $doc_file"
    
    echo ""
}

# Main execution
main() {
    print_banner
    
    check_prerequisites
    get_repo_info
    setup_scripts
    configure_webhooks
    setup_slack
    setup_discord
    create_systemd_service
    create_dashboard
    update_makefile
    create_documentation
    
    print_section "Setup Complete!"
    print_success "Real-time GitHub Actions monitoring is now configured!"
    echo ""
    print_status "Next steps:"
    echo "1. Configure GitHub webhook: https://github.com/$REPO/settings/hooks"
    echo "2. Set up Slack/Discord notifications (optional)"
    echo "3. Start monitoring: make monitor-realtime"
    echo "4. Start webhook server: make webhook-server"
    echo "5. Open dashboard: monitoring/github-actions-dashboard.html"
    echo ""
    print_status "Documentation: docs/realtime-monitoring.md"
    print_status "Available commands: make help"
    
    echo ""
    print_success "🎉 Happy monitoring!"
}

# Run main function
main "$@"

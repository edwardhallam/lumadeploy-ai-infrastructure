#!/bin/bash
# Real-time GitHub Actions Monitor
# Provides immediate alerts and continuous monitoring of GitHub Actions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO=""
POLL_INTERVAL=10  # seconds
MAX_RETRIES=3
NOTIFICATION_FILE="/tmp/github_actions_notifications.log"
STATE_FILE="/tmp/github_actions_state.json"

print_banner() {
    echo -e "${PURPLE}🔔 Real-time GitHub Actions Monitor${NC}"
    echo "========================================"
    echo -e "${CYAN}Monitoring repository: ${REPO}${NC}"
    echo -e "${CYAN}Poll interval: ${POLL_INTERVAL}s${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ❌${NC} $1"
}

print_alert() {
    echo -e "${RED}[$(date '+%H:%M:%S')] 🚨 ALERT:${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed"
        print_status "Install with: brew install gh"
        exit 1
    fi

    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub CLI"
        print_status "Run: gh auth login"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed (required for JSON processing)"
        print_status "Install with: brew install jq"
        exit 1
    fi
}

# Get repository information
get_repo_info() {
    if git remote get-url origin &> /dev/null; then
        REPO_URL=$(git remote get-url origin)
        if [[ $REPO_URL == *"github.com"* ]]; then
            REPO=$(echo $REPO_URL | sed -E 's/.*github\.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/' | sed 's/\.git$//')
        else
            print_error "Not a GitHub repository"
            exit 1
        fi
    else
        print_error "No git remote origin found"
        exit 1
    fi
}

# Initialize state file
init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        echo '{"last_check": 0, "known_runs": {}}' > "$STATE_FILE"
    fi
}

# Get current workflow runs
get_workflow_runs() {
    local retries=0
    while [ $retries -lt $MAX_RETRIES ]; do
        if gh api repos/$REPO/actions/runs --jq '.workflow_runs[] | {id, name, status, conclusion, html_url, head_sha, head_branch, created_at, updated_at}' 2>/dev/null; then
            return 0
        else
            retries=$((retries + 1))
            if [ $retries -lt $MAX_RETRIES ]; then
                print_warning "API call failed, retrying in 5 seconds... ($retries/$MAX_RETRIES)"
                sleep 5
            fi
        fi
    done
    print_error "Failed to fetch workflow runs after $MAX_RETRIES attempts"
    return 1
}

# Compare states and detect changes
detect_changes() {
    local current_runs="$1"
    local last_state=$(cat "$STATE_FILE")
    local known_runs=$(echo "$last_state" | jq -r '.known_runs')
    local changes_detected=false

    # Process each current run
    echo "$current_runs" | jq -c '.' | while read -r run; do
        local run_id=$(echo "$run" | jq -r '.id')
        local run_name=$(echo "$run" | jq -r '.name')
        local run_status=$(echo "$run" | jq -r '.status')
        local run_conclusion=$(echo "$run" | jq -r '.conclusion')
        local run_url=$(echo "$run" | jq -r '.html_url')
        local run_branch=$(echo "$run" | jq -r '.head_branch')
        local run_sha=$(echo "$run" | jq -r '.head_sha')
        
        # Check if this run is new or has changed
        local known_run=$(echo "$known_runs" | jq -r --arg id "$run_id" '.[$id]')
        
        if [ "$known_run" = "null" ]; then
            # New workflow run detected
            print_alert "New workflow started: $run_name"
            print_status "Branch: $run_branch"
            print_status "Commit: ${run_sha:0:7}"
            print_status "Status: $run_status"
            print_status "URL: $run_url"
            echo ""
            
            # Log notification
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] NEW: $run_name ($run_status) - $run_url" >> "$NOTIFICATION_FILE"
            changes_detected=true
            
        else
            # Check if status changed
            local known_status=$(echo "$known_run" | jq -r '.status')
            local known_conclusion=$(echo "$known_run" | jq -r '.conclusion')
            
            if [ "$run_status" != "$known_status" ] || [ "$run_conclusion" != "$known_conclusion" ]; then
                case "$run_status" in
                    "completed")
                        case "$run_conclusion" in
                            "success")
                                print_success "Workflow completed successfully: $run_name"
                                ;;
                            "failure")
                                print_alert "Workflow failed: $run_name"
                                print_status "URL: $run_url"
                                
                                # Auto-prioritize failures
                                if [ -f "./scripts/auto-prioritize-failures.sh" ]; then
                                    print_status "Auto-prioritizing failure..."
                                    ./scripts/auto-prioritize-failures.sh || true
                                fi
                                ;;
                            "cancelled")
                                print_warning "Workflow cancelled: $run_name"
                                ;;
                            *)
                                print_status "Workflow completed with status: $run_conclusion - $run_name"
                                ;;
                        esac
                        ;;
                    "in_progress")
                        print_status "Workflow running: $run_name"
                        ;;
                    "queued")
                        print_status "Workflow queued: $run_name"
                        ;;
                esac
                
                # Log notification
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] UPDATE: $run_name ($run_status/$run_conclusion) - $run_url" >> "$NOTIFICATION_FILE"
                changes_detected=true
            fi
        fi
    done

    # Update state file with current runs
    local new_known_runs="{}"
    echo "$current_runs" | jq -c '.' | while read -r run; do
        local run_id=$(echo "$run" | jq -r '.id')
        new_known_runs=$(echo "$new_known_runs" | jq --arg id "$run_id" --argjson run "$run" '.[$id] = $run')
    done
    
    local new_state=$(echo "$last_state" | jq --argjson runs "$new_known_runs" --arg timestamp "$(date +%s)" '.known_runs = $runs | .last_check = ($timestamp | tonumber)')
    echo "$new_state" > "$STATE_FILE"
}

# Send webhook notification (if configured)
send_webhook() {
    local event="$1"
    local data="$2"
    
    if [ -n "$WEBHOOK_URL" ]; then
        curl -s -X POST -H "Content-Type: application/json" \
             -d "$data" \
             "$WEBHOOK_URL" || print_warning "Failed to send webhook notification"
    fi
}

# Main monitoring loop
monitor_continuous() {
    print_banner
    print_status "Starting continuous monitoring..."
    print_status "Press Ctrl+C to stop"
    echo ""
    
    init_state
    
    while true; do
        if workflow_runs=$(get_workflow_runs); then
            detect_changes "$workflow_runs"
        else
            print_error "Failed to get workflow runs, continuing..."
        fi
        
        sleep $POLL_INTERVAL
    done
}

# One-time check mode
check_once() {
    print_banner
    print_status "Performing one-time check..."
    echo ""
    
    init_state
    
    if workflow_runs=$(get_workflow_runs); then
        detect_changes "$workflow_runs"
        print_success "Check completed"
    else
        print_error "Failed to get workflow runs"
        exit 1
    fi
}

# Webhook server mode (simple HTTP server)
start_webhook_server() {
    local port=${1:-8080}
    print_banner
    print_status "Starting webhook server on port $port..."
    print_status "Configure GitHub webhook to: http://your-server:$port/webhook"
    echo ""
    
    # Simple webhook server using netcat (for demonstration)
    while true; do
        echo -e "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK" | nc -l -p $port -q 1
        print_status "Webhook received, checking workflows..."
        check_once
    done
}

# Usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  monitor     Start continuous monitoring (default)"
    echo "  check       Perform one-time check"
    echo "  webhook     Start webhook server"
    echo ""
    echo "Options:"
    echo "  -i, --interval SECONDS    Set poll interval (default: 10)"
    echo "  -p, --port PORT          Set webhook server port (default: 8080)"
    echo "  -w, --webhook-url URL    Set webhook URL for notifications"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  WEBHOOK_URL              URL to send webhook notifications"
    echo "  SLACK_WEBHOOK_URL        Slack webhook URL for notifications"
    echo "  DISCORD_WEBHOOK_URL      Discord webhook URL for notifications"
    echo ""
    echo "Examples:"
    echo "  $0 monitor                    # Start continuous monitoring"
    echo "  $0 check                      # One-time check"
    echo "  $0 webhook -p 9000           # Start webhook server on port 9000"
    echo "  $0 monitor -i 30             # Monitor with 30-second intervals"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interval)
            POLL_INTERVAL="$2"
            shift 2
            ;;
        -p|--port)
            WEBHOOK_PORT="$2"
            shift 2
            ;;
        -w|--webhook-url)
            WEBHOOK_URL="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        monitor|check|webhook)
            COMMAND="$1"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Set default command
COMMAND=${COMMAND:-monitor}

# Main execution
check_prerequisites
get_repo_info

case "$COMMAND" in
    monitor)
        monitor_continuous
        ;;
    check)
        check_once
        ;;
    webhook)
        start_webhook_server ${WEBHOOK_PORT:-8080}
        ;;
    *)
        echo "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac

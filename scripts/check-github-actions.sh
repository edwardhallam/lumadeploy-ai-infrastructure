#!/bin/bash
# GitHub Actions Status Checker for LumaDeploy
# Automatically checks the status of GitHub Actions after pushing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

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

print_header() {
    echo -e "${PURPLE}🔍 GitHub Actions Status Check${NC}"
    echo "=================================="
}

# Check if GitHub CLI is installed
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed"
        print_status "Install with: brew install gh"
        print_status "Or visit: https://cli.github.com/"
        exit 1
    fi
}

# Check if user is authenticated with GitHub CLI
check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub CLI"
        print_status "Run: gh auth login"
        exit 1
    fi
}

# Get repository information
get_repo_info() {
    if git remote get-url origin &> /dev/null; then
        REPO_URL=$(git remote get-url origin)
        # Extract owner/repo from URL
        if [[ $REPO_URL == *"github.com"* ]]; then
            # Handle both SSH and HTTPS URLs, remove .git suffix
            REPO=$(echo $REPO_URL | sed -E 's/.*github\.com[:/]([^/]+\/[^/]+)(\.git)?$/\1/' | sed 's/\.git$//')
            print_status "Repository: $REPO"
        else
            print_error "Not a GitHub repository"
            exit 1
        fi
    else
        print_error "No git remote origin found"
        exit 1
    fi
}

# Get current branch and latest commit
get_commit_info() {
    BRANCH=$(git branch --show-current)
    COMMIT_SHA=$(git rev-parse HEAD)
    SHORT_SHA=$(git rev-parse --short HEAD)
    COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
    
    print_status "Branch: $BRANCH"
    print_status "Commit: $SHORT_SHA - $COMMIT_MESSAGE"
}

# Check GitHub Actions status
check_actions_status() {
    print_status "Checking GitHub Actions status..."
    echo ""
    
    # Get workflow runs for the current commit
    RUNS=$(gh api repos/$REPO/actions/runs --jq ".workflow_runs[] | select(.head_sha == \"$COMMIT_SHA\")")
    
    if [ -z "$RUNS" ]; then
        print_warning "No GitHub Actions runs found for commit $SHORT_SHA"
        print_status "This might be normal if:"
        print_status "  • The commit was just pushed (workflows may be starting)"
        print_status "  • No workflows are configured to run on this branch"
        print_status "  • Workflows only run on specific triggers"
        return 0
    fi
    
    # Initialize failure flag
    FAILED=false
    
    # Parse and display workflow runs
    while IFS='|' read -r name status conclusion url; do
        case $status in
            "completed")
                case $conclusion in
                    "success")
                        print_success "✅ $name - Passed"
                        ;;
                    "failure")
                        print_error "❌ $name - Failed"
                        print_status "   View details: $url"
                        FAILED=true
                        ;;
                    "cancelled")
                        print_warning "⚠️  $name - Cancelled"
                        ;;
                    "skipped")
                        print_warning "⏭️  $name - Skipped"
                        ;;
                    *)
                        print_warning "❓ $name - $conclusion"
                        ;;
                esac
                ;;
            "in_progress")
                print_status "🔄 $name - Running..."
                print_status "   View progress: $url"
                ;;
            "queued")
                print_status "⏳ $name - Queued"
                ;;
            *)
                print_status "❓ $name - $status"
                ;;
        esac
    done < <(echo "$RUNS" | jq -r '. | "\(.name)|\(.status)|\(.conclusion)|\(.html_url)"')
    
    # If any workflows failed, exit with error
    if [ "$FAILED" = true ]; then
        echo ""
        print_error "Some GitHub Actions failed!"
        print_status "💡 Common fixes:"
        print_status "  • Check the workflow logs for specific errors"
        print_status "  • Verify all required secrets are configured"
        print_status "  • Ensure configuration files are present"
        print_status "  • Run 'make validate' locally first"
        return 1
    fi
}

# Wait for workflows to start (dynamic detection)
wait_for_workflows_to_start() {
    local max_wait=60  # Maximum 60 seconds to wait for workflows to start
    local wait_time=0
    local check_interval=2
    
    print_status "Waiting for GitHub Actions workflows to start..."
    
    while [ $wait_time -lt $max_wait ]; do
        # Check if any workflows exist for this commit
        local workflow_count=$(gh api repos/$REPO/actions/runs --jq ".workflow_runs[] | select(.head_sha == \"$COMMIT_SHA\")" | wc -l | tr -d ' ')
        
        if [ "$workflow_count" -gt 0 ]; then
            print_success "Found $workflow_count workflow(s) for commit $SHORT_SHA"
            return 0
        fi
        
        printf "\r⏳ Waiting for workflows to start... ${wait_time}s/${max_wait}s"
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
    done
    
    echo ""
    print_warning "No workflows started within ${max_wait} seconds"
    print_status "This might be normal if no workflows are configured for this push"
    return 1
}

# Wait for running workflows to complete with progress tracking
wait_for_completion() {
    if [ "$1" = "--wait" ]; then
        print_status "Monitoring workflows until completion..."
        
        local last_status=""
        local start_time=$(date +%s)
        
        while true; do
            # Get current workflow status
            local runs_data=$(gh api repos/$REPO/actions/runs --jq ".workflow_runs[] | select(.head_sha == \"$COMMIT_SHA\")")
            
            if [ -z "$runs_data" ]; then
                print_warning "No workflows found for this commit"
                break
            fi
            
            # Count workflows by status
            local total=$(echo "$runs_data" | jq -s 'length')
            local completed=$(echo "$runs_data" | jq -s 'map(select(.status == "completed")) | length')
            local running=$(echo "$runs_data" | jq -s 'map(select(.status == "in_progress")) | length')
            local queued=$(echo "$runs_data" | jq -s 'map(select(.status == "queued")) | length')
            local success=$(echo "$runs_data" | jq -s 'map(select(.conclusion == "success")) | length')
            local failed=$(echo "$runs_data" | jq -s 'map(select(.conclusion == "failure")) | length')
            
            # Create status summary
            local current_status="Total: $total | Completed: $completed | Running: $running | Queued: $queued | Success: $success | Failed: $failed"
            
            # Only print if status changed
            if [ "$current_status" != "$last_status" ]; then
                local elapsed=$(($(date +%s) - start_time))
                printf "\r🔄 [${elapsed}s] $current_status"
                
                # Show individual workflow status if there are active workflows
                if [ "$running" -gt 0 ] || [ "$queued" -gt 0 ]; then
                    echo ""
                    echo "$runs_data" | jq -r 'select(.status != "completed") | "   \(.status | ascii_upcase): \(.name)"' | head -3
                    if [ "$(echo "$runs_data" | jq -s 'map(select(.status != "completed")) | length')" -gt 3 ]; then
                        echo "   ... and $(($(echo "$runs_data" | jq -s 'map(select(.status != "completed")) | length') - 3)) more"
                    fi
                fi
                
                last_status="$current_status"
            fi
            
            # Check if all workflows are completed
            if [ "$running" -eq 0 ] && [ "$queued" -eq 0 ]; then
                echo ""
                if [ "$failed" -gt 0 ]; then
                    print_error "✗ All workflows completed with $failed failure(s)"
                else
                    print_success "✓ All workflows completed successfully"
                fi
                break
            fi
            
            sleep 3  # Check every 3 seconds for responsive updates
        done
        
        echo ""
        # Check final status
        check_actions_status
    fi
}

# Show workflow summary
show_summary() {
    echo ""
    print_status "📊 GitHub Actions Summary:"
    
    # Get summary of all runs for this commit
    gh api repos/$REPO/actions/runs --jq ".workflow_runs[] | select(.head_sha == \"$COMMIT_SHA\") | {name, status, conclusion}" | jq -s '
        group_by(.name) | map({
            workflow: .[0].name,
            total: length,
            completed: map(select(.status == "completed")) | length,
            success: map(select(.conclusion == "success")) | length,
            failed: map(select(.conclusion == "failure")) | length,
            running: map(select(.status == "in_progress")) | length
        })[]'
}

# Main execution
main() {
    print_header
    echo ""
    
    check_gh_cli
    check_gh_auth
    get_repo_info
    get_commit_info
    
    echo ""
    
    # Handle different wait modes
    case "$1" in
        "--smart-wait")
            # Smart wait: detect workflow startup, then monitor to completion
            if wait_for_workflows_to_start; then
                print_status "Workflows detected, monitoring progress..."
                wait_for_completion "--wait"
            else
                # No workflows started, just check current status
                if ! check_actions_status; then
                    show_summary
                    echo ""
                    print_error "GitHub Actions check failed!"
                    exit 1
                fi
            fi
            ;;
        "--wait")
            # Traditional wait: monitor existing workflows to completion
            wait_for_completion "--wait"
            ;;
        *)
            # Default: just check current status
            if ! check_actions_status; then
                # Actions failed, but still show summary
                show_summary
                echo ""
                print_error "GitHub Actions check failed!"
                exit 1
            fi
            ;;
    esac
    
    show_summary
    
    echo ""
    print_success "GitHub Actions status check complete!"
    print_status "💡 Run with --wait to wait for running workflows to finish"
    print_status "💡 Run with --smart-wait to detect startup and monitor to completion"
    print_status "💡 Add to git hooks with: ln -s ../../scripts/check-github-actions.sh .git/hooks/post-push"
    
    # Auto-prioritize failures if they exist
    if [ "$FAILED" = true ]; then
        echo ""
        print_status "🚨 Auto-prioritizing GitHub Actions failures..."
        if [ -f "./scripts/auto-prioritize-failures.sh" ]; then
            ./scripts/auto-prioritize-failures.sh || true
        else
            print_warning "Auto-prioritize script not found, skipping automatic prioritization"
        fi
    fi
}

# Run main function with all arguments
main "$@"

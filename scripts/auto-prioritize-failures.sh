#!/bin/bash
# Auto-Prioritize GitHub Actions Failures
# Automatically detects GitHub Actions failures and adds them to the top of todo list

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[AUTO-PRIORITIZE]${NC} $1"
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
    echo -e "${PURPLE}🚨 Auto-Prioritizing GitHub Actions Failures${NC}"
    echo "=================================================="
}

# Check if GitHub CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub CLI"
        exit 1
    fi
}

# Get repository information
get_repo_info() {
    if git remote get-url origin &> /dev/null; then
        REPO_URL=$(git remote get-url origin)
        if [[ $REPO_URL == *"github.com"* ]]; then
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

# Get current commit info
get_commit_info() {
    BRANCH=$(git branch --show-current)
    COMMIT_SHA=$(git rev-parse HEAD)
    SHORT_SHA=$(git rev-parse --short HEAD)
    COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
    
    print_status "Branch: $BRANCH"
    print_status "Commit: $SHORT_SHA - $COMMIT_MESSAGE"
}

# Check for GitHub Actions failures
check_for_failures() {
    print_status "Checking for GitHub Actions failures..."
    
    # Get workflow runs for the current commit
    RUNS=$(gh api repos/$REPO/actions/runs --jq ".workflow_runs[] | select(.head_sha == \"$COMMIT_SHA\")")
    
    if [ -z "$RUNS" ]; then
        print_status "No GitHub Actions runs found for commit $SHORT_SHA"
        return 0
    fi
    
    # Check for failures
    FAILED_RUNS=$(echo "$RUNS" | jq -r 'select(.conclusion == "failure") | "\(.name)|\(.html_url)|\(.run_number)"')
    
    if [ -z "$FAILED_RUNS" ]; then
        print_success "No failed workflows found!"
        return 0
    fi
    
    # Process failed runs
    echo "$FAILED_RUNS" | while IFS='|' read -r name url run_number; do
        print_error "Failed workflow: $name (Run #$run_number)"
        print_status "URL: $url"
        
        # Create todo item for this failure
        create_failure_todo "$name" "$url" "$run_number"
    done
    
    return 1
}

# Create a high-priority todo item for the failure
create_failure_todo() {
    local workflow_name="$1"
    local workflow_url="$2"
    local run_number="$3"
    
    # Generate unique ID for this failure
    local failure_id="fix_github_actions_$(echo "$workflow_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')_${run_number}"
    
    # Create todo content
    local todo_content="🚨 URGENT: Fix GitHub Actions failure in '$workflow_name' (Run #$run_number) - $workflow_url"
    
    print_status "Creating high-priority todo: $failure_id"
    
    # TODO: Integrate with your todo system here
    # For now, we'll create a simple todo file
    echo "TODO: $todo_content" >> .github-actions-failures.todo
    
    # Also create a commit message template
    cat >> .failure-commit-template.txt << EOF
fix: Resolve GitHub Actions failure in $workflow_name

🚨 GitHub Actions Failure:
- Workflow: $workflow_name
- Run: #$run_number
- URL: $workflow_url
- Commit: $SHORT_SHA

🔧 Resolution:
- [ ] Analyze failure logs
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Verify resolution

This addresses the automatic failure prioritization rule.
EOF

    print_success "Created todo for failure: $workflow_name"
}

# Integration with make commands
integrate_with_make() {
    print_status "Setting up Makefile integration..."
    
    # Check if Makefile exists and has our commands
    if [ -f "Makefile" ]; then
        if ! grep -q "auto-prioritize-failures" Makefile; then
            cat >> Makefile << 'EOF'

# Auto-prioritize GitHub Actions failures
auto-prioritize-failures:
	@echo "🚨 Auto-prioritizing GitHub Actions failures..."
	@./scripts/auto-prioritize-failures.sh

push-and-prioritize:
	@echo "🚀 Pushing to GitHub and auto-prioritizing failures..."
	@git push origin main || true
	@sleep 3
	@./scripts/auto-prioritize-failures.sh || echo "⚠️  Failures detected and prioritized"

EOF
            print_success "Added auto-prioritize commands to Makefile"
        fi
    fi
}

# Set up git hooks for automatic failure detection
setup_git_hooks() {
    print_status "Setting up git hooks for automatic failure prioritization..."
    
    mkdir -p .git/hooks
    
    # Create post-push hook that runs failure detection
    cat > .git/hooks/post-push << 'EOF'
#!/bin/bash
echo "🔍 Checking for GitHub Actions failures after push..."
sleep 5  # Give GitHub a moment to start workflows
./scripts/auto-prioritize-failures.sh || {
    echo "⚠️  GitHub Actions failures detected and prioritized"
    echo "💡 Check .github-actions-failures.todo for details"
}
EOF
    
    chmod +x .git/hooks/post-push
    print_success "Git post-push hook configured"
}

# Set up automated failure monitoring
setup_automated_monitoring() {
    print_status "Setting up automated failure monitoring..."
    
    # Create a monitoring script that can be run periodically
    cat > scripts/monitor-github-actions.sh << 'EOF'
#!/bin/bash
# Continuous GitHub Actions Monitoring
# Run this script periodically (e.g., via cron) to monitor for failures

cd "$(dirname "$0")/.."
./scripts/auto-prioritize-failures.sh

# If failures are detected, optionally send notifications
if [ $? -ne 0 ]; then
    echo "🚨 GitHub Actions failures detected!"
    
    # Optional: Send Slack notification
    # curl -X POST -H 'Content-type: application/json' \
    #     --data '{"text":"🚨 GitHub Actions failures detected in LumaDeploy!"}' \
    #     $SLACK_WEBHOOK_URL
    
    # Optional: Send email notification
    # echo "GitHub Actions failures detected" | mail -s "LumaDeploy Alert" your-email@domain.com
fi
EOF
    
    chmod +x scripts/monitor-github-actions.sh
    print_success "Automated monitoring script created"
}

# Create a comprehensive failure analysis report
create_failure_report() {
    if [ ! -f ".github-actions-failures.todo" ]; then
        return 0
    fi
    
    print_status "Creating failure analysis report..."
    
    cat > GITHUB_ACTIONS_FAILURES.md << EOF
# 🚨 GitHub Actions Failures Report

Generated: $(date)
Repository: $REPO
Branch: $BRANCH
Commit: $SHORT_SHA

## Current Failures

$(cat .github-actions-failures.todo)

## Recommended Actions

1. **Immediate**: Review failure logs at the provided URLs
2. **Analysis**: Identify root cause of each failure
3. **Resolution**: Implement fixes following the commit template
4. **Verification**: Ensure fixes resolve the issues
5. **Prevention**: Add tests/checks to prevent recurrence

## Failure Prioritization Rule

Following the established rule: "Any time we have a failure in GitHub Actions, 
we should prioritize fixing the failure and moving that to the top of the todo."

This report was automatically generated by the failure prioritization system.
EOF

    print_success "Failure report created: GITHUB_ACTIONS_FAILURES.md"
}

# Main execution
main() {
    print_header
    echo ""
    
    check_gh_cli
    get_repo_info
    get_commit_info
    
    echo ""
    if check_for_failures; then
        print_success "No GitHub Actions failures to prioritize"
        
        # Clean up old failure files if no failures
        rm -f .github-actions-failures.todo
        rm -f .failure-commit-template.txt
        rm -f GITHUB_ACTIONS_FAILURES.md
        
        exit 0
    else
        print_warning "GitHub Actions failures detected and prioritized"
        
        create_failure_report
        integrate_with_make
        setup_git_hooks
        setup_automated_monitoring
        
        echo ""
        print_status "📋 Next Steps:"
        print_status "1. Review: cat .github-actions-failures.todo"
        print_status "2. Analyze: Check failure URLs for detailed logs"
        print_status "3. Fix: Use .failure-commit-template.txt for commit messages"
        print_status "4. Monitor: Run 'make auto-prioritize-failures' anytime"
        
        exit 1
    fi
}

# Run main function with all arguments
main "$@"

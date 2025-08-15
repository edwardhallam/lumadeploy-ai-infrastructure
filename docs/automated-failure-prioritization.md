# 🚨 Automated GitHub Actions Failure Prioritization

LumaDeploy includes a comprehensive automated system to detect, prioritize, and manage GitHub Actions failures, ensuring critical issues are addressed immediately.

## 🎯 **The Prioritization Rule**

> **"Any time we have a failure in GitHub Actions, we should prioritize fixing the failure and moving that to the top of the todo list."**

This rule is now **automatically enforced** through programmatic detection and prioritization.

## 🛠️ **Automated System Components**

### **1. Auto-Prioritize Script**
**File**: `scripts/auto-prioritize-failures.sh`

**Features**:
- ✅ Automatically detects GitHub Actions failures
- ✅ Creates high-priority todo items
- ✅ Generates failure analysis reports
- ✅ Provides commit message templates
- ✅ Sets up monitoring infrastructure

**Usage**:
```bash
# Manual execution
./scripts/auto-prioritize-failures.sh

# Via Makefile
make auto-prioritize-failures
```

### **2. Enhanced GitHub Actions Monitoring**
**File**: `scripts/check-github-actions.sh` (enhanced)

**New Features**:
- ✅ Automatic failure prioritization integration
- ✅ Calls auto-prioritize script when failures detected
- ✅ Seamless workflow integration

### **3. Makefile Integration**
**Commands**:
```bash
# Push and automatically prioritize any failures
make push-and-prioritize

# Check for existing failures and prioritize them
make auto-prioritize-failures

# Standard push with smart monitoring (now includes auto-prioritization)
make push-and-check
```

## 🔄 **Automated Workflows**

### **Workflow 1: Push-Triggered Prioritization**
```bash
# User pushes code
git push origin main

# OR uses enhanced command
make push-and-prioritize

# System automatically:
# 1. Pushes code to GitHub
# 2. Monitors GitHub Actions with dynamic progress tracking
# 3. Detects any failures
# 4. Creates high-priority todo items
# 5. Generates failure reports
# 6. Provides next steps
```

### **Workflow 2: Continuous Monitoring**
```bash
# Set up git hooks for automatic monitoring
make setup-hooks

# Now every git push automatically:
# 1. Triggers failure detection
# 2. Prioritizes failures
# 3. Updates todo lists
# 4. Creates failure reports
```

### **Workflow 3: Periodic Monitoring**
```bash
# Run periodic monitoring (can be automated via cron)
./scripts/monitor-github-actions.sh

# Optional: Set up cron job
# */15 * * * * cd /path/to/lumadeploy && ./scripts/monitor-github-actions.sh
```

## 📋 **Generated Artifacts**

### **1. High-Priority Todo Items**
**File**: `.github-actions-failures.todo`

**Format**:
```
TODO: 🚨 URGENT: Fix GitHub Actions failure in 'Validate LumaDeploy' (Run #123) - https://github.com/user/repo/actions/runs/123
```

### **2. Commit Message Templates**
**File**: `.failure-commit-template.txt`

**Format**:
```
fix: Resolve GitHub Actions failure in Validate LumaDeploy

🚨 GitHub Actions Failure:
- Workflow: Validate LumaDeploy
- Run: #123
- URL: https://github.com/user/repo/actions/runs/123
- Commit: abc1234

🔧 Resolution:
- [ ] Analyze failure logs
- [ ] Identify root cause
- [ ] Implement fix
- [ ] Verify resolution

This addresses the automatic failure prioritization rule.
```

### **3. Failure Analysis Report**
**File**: `GITHUB_ACTIONS_FAILURES.md`

**Contents**:
- Current failures with URLs
- Recommended actions
- Prioritization rule explanation
- Automated generation timestamp

## 🎛️ **Configuration Options**

### **Environment Variables**
```bash
# Optional: Slack webhook for notifications
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."

# Optional: Email for notifications
export NOTIFICATION_EMAIL="your-email@domain.com"
```

### **Customization**
Edit `scripts/auto-prioritize-failures.sh` to:
- Modify todo item format
- Add custom notification methods
- Integrate with external task management systems
- Customize failure analysis logic

## 🔧 **Integration Examples**

### **With External Task Management**
```bash
# Example: Integrate with Jira
create_failure_todo() {
    local workflow_name="$1"
    local workflow_url="$2"

    # Create Jira ticket
    curl -X POST \
        -H "Content-Type: application/json" \
        -d "{
            \"fields\": {
                \"project\": {\"key\": \"LUMA\"},
                \"summary\": \"🚨 URGENT: GitHub Actions failure in $workflow_name\",
                \"description\": \"Failure URL: $workflow_url\",
                \"priority\": {\"name\": \"Highest\"}
            }
        }" \
        "https://your-domain.atlassian.net/rest/api/2/issue/"
}
```

### **With Slack Notifications**
```bash
# Example: Send Slack notification
if [ "$FAILED_RUNS" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 GitHub Actions failures detected in LumaDeploy! Check: $workflow_url\"}" \
        $SLACK_WEBHOOK_URL
fi
```

### **With Email Alerts**
```bash
# Example: Send email notification
if [ "$FAILED_RUNS" ]; then
    echo "GitHub Actions failures detected. Check: $workflow_url" | \
        mail -s "🚨 LumaDeploy Alert" $NOTIFICATION_EMAIL
fi
```

## 📊 **Monitoring Dashboard**

### **Quick Status Check**
```bash
# Check current failure status
make auto-prioritize-failures

# View current failures
cat .github-actions-failures.todo

# View failure report
cat GITHUB_ACTIONS_FAILURES.md
```

### **Failure History**
```bash
# View git log for failure-related commits
git log --grep="🚨 URGENT" --oneline

# View all failure prioritization activity
git log --grep="automatic failure prioritization" --oneline
```

## 🎯 **Best Practices**

### **1. Immediate Response**
- ✅ Address failures as soon as they're detected
- ✅ Use generated commit message templates
- ✅ Follow the recommended action steps

### **2. Prevention**
- ✅ Add tests to prevent similar failures
- ✅ Improve validation workflows
- ✅ Document common failure patterns

### **3. Continuous Improvement**
- ✅ Analyze failure patterns
- ✅ Enhance detection logic
- ✅ Improve automated responses

## 🚀 **Advanced Features**

### **1. Failure Pattern Detection**
The system can be extended to detect patterns:
```bash
# Example: Detect recurring failures
analyze_failure_patterns() {
    git log --grep="🚨 URGENT" --since="1 week ago" | \
        grep -o "failure in '.*'" | \
        sort | uniq -c | sort -nr
}
```

### **2. Automatic Fix Suggestions**
```bash
# Example: Suggest fixes based on failure type
suggest_fixes() {
    case "$failure_type" in
        "terraform")
            echo "💡 Run: terraform fmt && terraform validate"
            ;;
        "ansible")
            echo "💡 Run: ansible-playbook --syntax-check playbook.yml"
            ;;
        "python")
            echo "💡 Run: python -m py_compile *.py"
            ;;
    esac
}
```

### **3. Automated Recovery**
```bash
# Example: Attempt automatic fixes for common issues
auto_fix_common_issues() {
    if [[ "$failure_log" == *"terraform fmt"* ]]; then
        terraform fmt
        git add . && git commit -m "fix: Auto-format Terraform files"
    fi
}
```

## 🎉 **Benefits**

### **For Developers**
- ✅ **Never miss failures** - Automatic detection and prioritization
- ✅ **Clear guidance** - Generated commit templates and action steps
- ✅ **Reduced cognitive load** - System handles prioritization logic

### **For Teams**
- ✅ **Consistent process** - Standardized failure handling
- ✅ **Audit trail** - Complete history of failure responses
- ✅ **Shared visibility** - Everyone sees prioritized failures

### **For Operations**
- ✅ **Reliable systems** - Failures addressed immediately
- ✅ **Process automation** - Reduced manual intervention
- ✅ **Continuous improvement** - Pattern analysis and prevention

---

**🚨 The automated failure prioritization system ensures that GitHub Actions failures are never overlooked and always receive immediate attention!**

*Ask Cursor: "Help me set up automated failure prioritization for my LumaDeploy project"*

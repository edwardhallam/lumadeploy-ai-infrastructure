# 🔍 GitHub Actions Monitoring for LumaDeploy

LumaDeploy includes comprehensive GitHub Actions monitoring to ensure your infrastructure deployments are successful and catch issues early.

## 🎯 **Why Monitor GitHub Actions?**

- **🚨 Early Problem Detection** - Catch deployment issues immediately
- **📊 Deployment Visibility** - Know the status of your infrastructure changes
- **🔄 Continuous Integration** - Ensure code quality and deployment success
- **⚡ Fast Feedback** - Get immediate notification of workflow results

## 🛠️ **Available Commands**

### **Basic Status Checking**
```bash
# Check current GitHub Actions status
make check-actions

# Check status and wait for running workflows to complete
make check-actions-wait

# Push changes and automatically check Actions status
make push-and-check
```

### **Automatic Monitoring Setup**
```bash
# Set up git hooks for automatic checking after every push
make setup-hooks
```

## 📋 **Command Details**

### **`make check-actions`**
- ✅ Shows status of all workflows for the latest commit
- ✅ Displays running, completed, failed, and cancelled workflows
- ✅ Provides direct links to workflow details
- ✅ Exits with error if any workflows failed

**Example Output:**
```
🔍 GitHub Actions Status Check
==================================

[INFO] Repository: edwardhallam/ai-infrastructure-platform
[INFO] Branch: main
[INFO] Commit: 8a68453 - fix: Update GitHub Actions workflow

✅ LumaDeploy AI Service Builder - Passed
📊 GitHub Actions Summary: All workflows successful
```

### **`make check-actions-wait`**
- ✅ Same as `check-actions` but waits for running workflows
- ✅ Polls every 10 seconds until all workflows complete
- ✅ Shows final status of all workflows
- ✅ Perfect for CI/CD pipelines

### **`make push-and-check`**
- ✅ Pushes your changes to GitHub
- ✅ Waits 5 seconds for workflows to start
- ✅ Automatically checks the status
- ✅ One command for push + verification

### **`make setup-hooks`**
- ✅ Creates a git `post-push` hook
- ✅ Automatically runs status check after every `git push`
- ✅ Provides immediate feedback on workflow status
- ✅ No need to remember to check manually

## 🔧 **Prerequisites**

### **GitHub CLI Installation**
The monitoring requires GitHub CLI (`gh`):

```bash
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows
winget install --id GitHub.cli
```

### **GitHub Authentication**
```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status
```

## 📊 **Workflow Status Indicators**

### **Status Icons**
- **✅ Passed** - Workflow completed successfully
- **❌ Failed** - Workflow failed (requires attention)
- **🔄 Running** - Workflow is currently executing
- **⏳ Queued** - Workflow is waiting to start
- **⚠️ Cancelled** - Workflow was cancelled
- **⏭️ Skipped** - Workflow was skipped
- **❓ Unknown** - Unexpected status

### **Common Failure Reasons**
- **Missing Secrets** - Required GitHub secrets not configured
- **Configuration Issues** - Missing `terraform.tfvars` or `ansible-vars.yml`
- **Syntax Errors** - Terraform or Ansible syntax problems
- **Resource Conflicts** - Proxmox resource allocation issues
- **Network Problems** - Connectivity issues with Proxmox

## 🔄 **Automatic Monitoring Workflow**

### **1. Set Up Once**
```bash
make setup-hooks
```

### **2. Normal Development Flow**
```bash
# Make your changes
git add .
git commit -m "feat: Add new AI service"

# Push and automatically check status
git push origin main  # Hook automatically runs check

# Or use the combined command
make push-and-check
```

### **3. Monitor Results**
The system will automatically:
- ✅ Show workflow status after each push
- ✅ Provide links to failed workflows
- ✅ Exit with error if workflows fail
- ✅ Give guidance on common fixes

## 🚨 **Handling Failures**

When GitHub Actions fail, the monitoring system provides:

### **Immediate Feedback**
```
❌ LumaDeploy AI Service Builder - Failed
   View details: https://github.com/user/repo/actions/runs/123456

[ERROR] Some GitHub Actions failed!
💡 Common fixes:
  • Check the workflow logs for specific errors
  • Verify all required secrets are configured
  • Ensure configuration files are present
  • Run 'make validate' locally first
```

### **Troubleshooting Steps**
1. **Click the provided link** to view detailed logs
2. **Check GitHub Secrets** - Ensure all required secrets are set
3. **Validate locally** - Run `make validate` before pushing
4. **Review configuration** - Ensure `config/terraform.tfvars` exists
5. **Check Proxmox connectivity** - Verify API token and network access

## 🎯 **Best Practices**

### **Development Workflow**
1. **Always validate locally first**:
   ```bash
   make validate  # Check syntax before pushing
   ```

2. **Use descriptive commit messages**:
   ```bash
   git commit -m "feat: Add Ollama GPU support"  # Clear description
   ```

3. **Monitor after pushing**:
   ```bash
   make push-and-check  # Push and verify in one command
   ```

### **Team Collaboration**
1. **Set up hooks for everyone**:
   ```bash
   make setup-hooks  # Each team member should run this
   ```

2. **Share status in PRs**:
   - Include GitHub Actions status in pull request descriptions
   - Wait for green status before merging

3. **Fix failures quickly**:
   - Address failed workflows immediately
   - Don't let broken workflows accumulate

## 🔧 **Advanced Usage**

### **Custom Monitoring Script**
You can also run the monitoring script directly:

```bash
# Basic check
./scripts/check-github-actions.sh

# Wait for completion
./scripts/check-github-actions.sh --wait

# Check specific commit
COMMIT_SHA=abc1234 ./scripts/check-github-actions.sh
```

### **Integration with CI/CD**
The monitoring can be integrated into other CI/CD systems:

```bash
# In your CI pipeline
if ! ./scripts/check-github-actions.sh --wait; then
    echo "GitHub Actions failed, stopping deployment"
    exit 1
fi
```

### **Slack/Discord Notifications**
Extend the script for team notifications:

```bash
# Add to scripts/check-github-actions.sh
if [ "$FAILED" = true ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data '{"text":"🚨 LumaDeploy deployment failed!"}' \
        $SLACK_WEBHOOK_URL
fi
```

## 📈 **Monitoring Dashboard**

### **GitHub Actions Tab**
- Visit your repository's **Actions** tab
- View all workflow runs and their status
- Filter by workflow, branch, or status
- Download logs and artifacts

### **Command Line Summary**
The monitoring script provides a summary:
```
📊 GitHub Actions Summary:
{
  "workflow": "LumaDeploy AI Service Builder",
  "total": 1,
  "completed": 1,
  "success": 1,
  "failed": 0,
  "running": 0
}
```

## 🎉 **Benefits**

### **For Developers**
- **Immediate feedback** on code changes
- **Automated quality checks** before deployment
- **Clear guidance** when things go wrong
- **Professional workflow** with minimal overhead

### **For Teams**
- **Consistent deployment process** across all team members
- **Shared visibility** into infrastructure changes
- **Automated quality gates** prevent broken deployments
- **Audit trail** of all infrastructure changes

### **For Operations**
- **Reliable deployments** with automated validation
- **Early problem detection** before production impact
- **Standardized processes** across environments
- **Comprehensive logging** for troubleshooting

---

**🔍 GitHub Actions monitoring ensures your LumaDeploy infrastructure deployments are reliable, visible, and successful every time!**

*Ask Cursor: "Help me set up GitHub Actions monitoring for my LumaDeploy project"*

# 🔐 Security Guide for AI Infrastructure Platform

This repository implements comprehensive security measures to prevent accidental exposure of sensitive information like API tokens, passwords, and private keys.

## 🛡️ Security Implementation

Based on the best practices from [Preventing Sensitive Data Leaks: Implementing Husky and Git-Secrets](https://medium.com/simform-engineering/preventing-sensitive-data-leaks-implementing-husky-and-git-secrets-in-your-git-workflow-dc7e5c7e14d7), we use:

- **git-secrets**: AWS Lab's tool for preventing secrets in Git repositories
- **Husky**: Pre-commit hooks for automated security scanning
- **Custom patterns**: Infrastructure-specific secret detection

## 🚀 Quick Setup

Run the automated security setup:

```bash
./setup-security.sh
```

This will:

- Install git-secrets (via Homebrew on macOS, manual on Linux)
- Install Husky and configure pre-commit hooks
- Register AWS and custom security patterns
- Test the setup with a sample secret

## 🔍 What Gets Detected

Our security patterns catch:

### Proxmox Secrets

- API tokens: `root@pam!token-name=uuid-secret`
- Connection strings with credentials

### Generic Secrets

- API keys: `api_key = "secret123"`
- Passwords: `password = "secret123"`
- Tokens: `token = "secret123"`

### Cloud Provider Keys

- AWS Access Keys: `AKIA[0-9A-Z]{16}`
- Stripe Keys: `sk_live_[0-9a-zA-Z]{99}`

### Infrastructure Secrets

- SSH Private Keys
- Database connection strings
- Kubernetes secrets (base64)
- Terraform sensitive variables
- Ansible vault passwords

### Environment Variables

- Any exported variable containing SECRET, KEY, TOKEN, PASS

## ✅ Allowed Patterns (Whitelist)

These patterns are allowed and won't trigger alerts:

```bash
your-proxmox-host.local
your_proxmox_ip_here
your-api-token-here
example.com
localhost
127.0.0.1
password.*placeholder
secret.*example
```

## 🔧 Manual Commands

### Scan Repository

```bash
# Scan entire repository
git-secrets --scan -r

# Scan specific file
git-secrets --scan filename

# Scan staged files only
git-secrets --pre_commit_hook -- "$@"
```

### Manage Patterns

```bash
# List all patterns
git secrets --list

# Add new pattern
git secrets --add "your-regex-pattern"

# Add allowed pattern
git secrets --add --allowed "safe-pattern"

# Register AWS patterns
git secrets --register-aws
```

### NPM Scripts

```bash
# Run security scan
npm run security-scan

# Run all pre-commit checks
npm run pre-commit

# Install git-secrets hooks
npm run security-install
```

## 🚨 What Happens on Commit

1. **Pre-commit hook runs** automatically
2. **Scans all files** for secret patterns
3. **Blocks commit** if secrets found
4. **Shows detected secrets** for review
5. **Allows commit** only after secrets removed

## 🛠️ Handling False Positives

If legitimate code triggers false positives:

1. **Review the detection** - ensure it's not actually sensitive
2. **Add to allowed list** in `.husky/pre-commit`:

   ```bash
   git secrets --add --allowed "your-safe-pattern"
   ```

3. **Or modify the pattern** to be more specific

## 🔄 Bypassing (Emergency Only)

**⚠️ Only use in emergencies and remove secrets immediately after:**

```bash
# Skip pre-commit hooks (NOT RECOMMENDED)
git commit --no-verify -m "Emergency commit"

# Then immediately fix and recommit properly
```

## 📁 File Structure

```
.
├── .husky/
│   └── pre-commit              # Main security hook
├── package.json                # Husky configuration
├── setup-security.sh           # Automated setup script
├── SECURITY.md                 # This file
└── .git-secrets.log           # Scan logs (auto-generated)
```

## 🧪 Testing the Setup

The setup script automatically tests secret detection. You can also test manually:

```bash
# Create test file with fake secret
echo 'api_key = "sk_live_test123"' > test-secret.txt

# Scan it
git-secrets --scan test-secret.txt

# Should detect and report the fake secret
# Clean up
rm test-secret.txt
```

## 🔗 Integration with Infrastructure

### Proxmox Integration

- Detects API tokens in `.env` files
- Catches hardcoded credentials in Python scripts
- Validates Terraform variable files

### Kubernetes Integration

- Scans for base64-encoded secrets
- Detects service account tokens
- Validates ConfigMap and Secret manifests

### Terraform Integration

- Identifies sensitive variables
- Catches provider credentials
- Validates state file references

## 📋 Best Practices

1. **Use environment variables** for all secrets
2. **Use .env files** (and add to .gitignore)
3. **Use secret management tools** (HashiCorp Vault, etc.)
4. **Regular security audits** of the repository
5. **Team education** on security practices

## 🆘 If Secrets Are Already Committed

If secrets were committed before this setup:

1. **Change the compromised secrets immediately**
2. **Use git filter-branch or BFG Repo-Cleaner** to remove from history
3. **Force push the cleaned history**
4. **Notify team members** to re-clone the repository

```bash
# Example with BFG Repo-Cleaner
java -jar bfg.jar --replace-text passwords.txt repo.git
cd repo.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

## 📞 Support

- **Setup Issues**: Run `./setup-security.sh` again
- **Pattern Issues**: Check `.git-secrets.log`
- **False Positives**: Add to allowed patterns
- **Integration Issues**: Verify git-secrets installation

## 📚 References

- [git-secrets GitHub Repository](https://github.com/awslabs/git-secrets)
- [Husky Documentation](https://typicode.github.io/husky/)
- [Medium Article: Preventing Sensitive Data Leaks](https://medium.com/simform-engineering/preventing-sensitive-data-leaks-implementing-husky-and-git-secrets-in-your-git-workflow-dc7e5c7e14d7)

---

**Remember: Security is everyone's responsibility. When in doubt, don't commit it!** 🔒

---

# 🚀 Security Setup Guide

## 🔒 Security Features

### 1. Automated Security Checks

- **GitHub Actions**: Automatically runs security validation on push/PR
- **Pre-commit Hooks**: Can be set up locally for immediate feedback
- **Make Targets**: Easy-to-use commands for security validation

### 2. Sensitive Data Protection

- **Environment Variables**: Use `.env` files for sensitive configuration
- **GitIgnore Rules**: Prevents accidental commit of sensitive files
- **Pattern Detection**: Scans for hardcoded credentials and API keys

### 3. Configuration Security

- **YAML Validation**: Ensures configuration files are properly formatted
- **IP Address Detection**: Warns about hardcoded network addresses
- **Documentation**: Clear examples and guidelines

## 🚀 Getting Started

### 1. Environment Setup

```bash
# Copy the example environment file
cp config/env.example .env

# Edit with your actual values
nano .env

# Ensure .env is in .gitignore (it should be by default)
echo ".env" >> .gitignore
```

### 2. Run Security Checks

```bash
# Run security validation
make security-check

# Test security checks (non-failing)
make security-check-dry-run

# Validate infrastructure configurations
make validate-configs
```

### 3. Set Up Pre-commit Hook (Optional)

```bash
# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🔒 Running pre-commit security checks..."
make security-check
EOF

# Make it executable
chmod +x .git/hooks/pre-commit
```

## 📋 Security Checklist

- [ ] Environment variables are used for sensitive data
- [ ] `.env` files are in `.gitignore`
- [ ] No hardcoded credentials in code
- [ ] IP addresses are configurable via environment
- [ ] Security checks pass locally
- [ ] GitHub Actions security workflow is enabled

## 🔍 What Gets Checked

### Critical Violations (Will Fail Build)

- Hardcoded passwords
- API keys in code
- Authentication tokens

### Warnings (Will Pass But Alert)

- Hardcoded IP addresses
- Configuration that should be externalized

### Files Excluded

- Virtual environments (`venv/`, `node_modules/`)
- Git directories (`.git/`)
- Security scripts themselves
- Cache directories

## 🛠️ Customizing Security Rules

Edit `scripts/security-check-simple.sh` to:

- Add new patterns to detect
- Modify severity levels
- Exclude additional file types
- Add custom validation logic

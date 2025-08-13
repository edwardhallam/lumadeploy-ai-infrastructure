# Security Setup for Infrastructure Management

This document outlines the security measures implemented in the infrastructure management repository.

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
cp env.example .env

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

## 📞 Support

If you encounter security-related issues:
1. Check this documentation
2. Review the security script output
3. Ensure environment variables are properly configured
4. Verify `.gitignore` includes sensitive files

## 🔄 Regular Maintenance

- Review security patterns monthly
- Update environment examples when adding new services
- Keep security documentation current
- Monitor GitHub Actions for security alerts
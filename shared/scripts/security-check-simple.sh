#!/bin/bash

# Simple security validation script for checking sensitive data
# Run this before pushing to GitHub or as part of CI/CD

set -e

echo "🔒 Running simple security checks..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track violations
VIOLATIONS=0
WARNINGS=0

# Only check specific project files, not virtual environments
PROJECT_FILES=(
    "*.tf"
    "*.py"
    "*.sh"
    "*.yml"
    "*.yaml"
    "*.md"
    "*.txt"
)

echo "📁 Scanning project files for sensitive data..."

# Check for sensitive patterns in project files
for pattern in "${PROJECT_FILES[@]}"; do
    # Find files matching pattern, excluding virtual environments and common directories
    while IFS= read -r -d '' file; do
        # Skip virtual environments and common directories
        if [[ "$file" == *"/venv/"* ]] || \
           [[ "$file" == *"/cursor-client-env/"* ]] || \
           [[ "$file" == *"/.terraform/"* ]] || \
           [[ "$file" == *"/.git/"* ]] || \
           [[ "$file" == *"/node_modules/"* ]] || \
           [[ "$file" == *"/__pycache__/"* ]] || \
           [[ "$file" == *"/site-packages/"* ]] || \
           [[ "$file" == *"/dist-packages/"* ]]; then
            continue
        fi

        if [ -f "$file" ]; then
            echo "Checking $file..."
            file_violations=0

            # Check for hardcoded IP addresses
            if grep -E "192\.168\.1\.[0-9]{1,3}" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found hardcoded IP address: 192.168.1.x${NC}"
                file_violations=$((file_violations + 1))
            fi

            # Check for API tokens in the format we're using
            if grep -E "root@pam![a-zA-Z0-9-]+" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found API token ID pattern${NC}"
                file_violations=$((file_violations + 1))
            fi

            # Check for UUID-like strings that might be API secrets
            if grep -E "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found UUID-like string (potential API secret)${NC}"
                file_violations=$((file_violations + 1))
            fi

            # Check for hardcoded passwords (but exclude the security script itself)
            if [[ "$file" != *"security-check"* ]] && grep -E "password.*=.*['\"][^'\"]*['\"]" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found hardcoded password pattern${NC}"
                file_violations=$((file_violations + 1))
            fi

            # Check for hardcoded API keys
            if grep -E "api_key.*=.*['\"][^'\"]*['\"]" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found hardcoded API key pattern${NC}"
                file_violations=$((file_violations + 1))
            fi

            if [ $file_violations -gt 0 ]; then
                VIOLATIONS=$((VIOLATIONS + file_violations))
            fi
        fi
    done < <(find . -name "$pattern" -type f -print0)
done

echo ""
echo "=========================================="
echo "📊 Security Check Results:"
echo ""

if [ $VIOLATIONS -eq 0 ]; then
    echo -e "${GREEN}✅ No security violations found!${NC}"
    echo -e "${GREEN}✅ Code is safe to commit and push${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $VIOLATIONS security violation(s)${NC}"
    echo -e "${RED}❌ Please fix these issues before committing${NC}"
    echo ""
    echo "🔧 Common fixes:"
    echo "  - Use environment variables for secrets"
    echo "  - Use Terraform variables for IP addresses"
    echo "  - Remove hardcoded credentials"
    echo "  - Use .env files (and add them to .gitignore)"
    exit 1
fi

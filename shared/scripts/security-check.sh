#!/bin/bash

# Security validation script for checking sensitive data
# Run this before pushing to GitHub or as part of CI/CD

set -e

echo "🔒 Running comprehensive security checks..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track violations
VIOLATIONS=0
WARNINGS=0

# Check for sensitive patterns in all files (excluding .git, .terraform, etc.)
echo "📁 Scanning files for sensitive data..."

# Common sensitive patterns
SENSITIVE_PATTERNS=(
    "password.*=.*['\"][^'\"]*['\"]"
    "api_key.*=.*['\"][^'\"]*['\"]"
    "api_token.*=.*['\"][^'\"]*['\"]"
    "secret.*=.*['\"][^'\"]*['\"]"
    "token.*=.*['\"][^'\"]*['\"]"
    "key.*=.*['\"][^'\"]*['\"]"
    "pwd.*=.*['\"][^'\"]*['\"]"
    "passwd.*=.*['\"][^'\"]*['\"]"
)

# IP address patterns
IP_PATTERNS=(
    "192\.168\.1\.[0-9]{1,3}"
    "10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"
    "172\.(1[6-9]|2[0-9]|3[0-1])\.[0-9]{1,3}\.[0-9]{1,3}"
)

# API token patterns
API_PATTERNS=(
    "root@pam![a-zA-Z0-9-]+"
    "[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"
)

# Find all files to check (excluding common directories)
FILES_TO_CHECK=$(find . -type f \( -name "*.tf" -o -name "*.py" -o -name "*.sh" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.txt" \) -not -path "./.git/*" -not -path "./.terraform/*" -not -path "./venv/*" -not -path "./node_modules/*" -not -path "./__pycache__/*")

for file in $FILES_TO_CHECK; do
    if [ -f "$file" ]; then
        echo "Checking $file..."
        file_violations=0
        
        # Check for sensitive patterns
        for pattern in "${SENSITIVE_PATTERNS[@]}"; do
            if grep -E "$pattern" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found sensitive pattern: $pattern${NC}"
                file_violations=$((file_violations + 1))
            fi
        done
        
        # Check for IP addresses
        for pattern in "${IP_PATTERNS[@]}"; do
            if grep -E "$pattern" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found IP address: $pattern${NC}"
                file_violations=$((file_violations + 1))
            fi
        done
        
        # Check for API tokens
        for pattern in "${API_PATTERNS[@]}"; do
            if grep -E "$pattern" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found API token pattern: $pattern${NC}"
                file_violations=$((file_violations + 1))
            fi
        done
        
        # Check for potential secrets in comments
        if grep -i "secret\|password\|key\|token" "$file" | grep -v "example\|placeholder\|TODO\|FIXME" > /dev/null 2>&1; then
            echo -e "  ${YELLOW}⚠️  Potential sensitive data in comments${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
        
        if [ $file_violations -gt 0 ]; then
            VIOLATIONS=$((VIOLATIONS + file_violations))
        fi
    fi
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

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $WARNINGS warning(s) - review these manually${NC}"
fi

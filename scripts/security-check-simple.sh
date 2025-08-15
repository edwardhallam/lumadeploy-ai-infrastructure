#!/bin/bash

# Simple security validation script for infrastructure management
# Run this before pushing to GitHub or as part of CI/CD

set -e

echo "🔒 Running infrastructure security checks..."
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track violations
VIOLATIONS=0
WARNINGS=0

# Only check specific infrastructure files
PROJECT_FILES=(
    "*.yml"
    "*.yaml"
    "*.sh"
    "*.md"
    "*.txt"
)

echo "📁 Scanning infrastructure files for sensitive data..."

# Function to check a single file for sensitive data
check_file() {
    local file="$1"

    # Skip virtual environments, common directories, and security scripts
    if [[ "$file" == *"/venv/"* ]] || \
       [[ "$file" == *"/.git/"* ]] || \
       [[ "$file" == *"/node_modules/"* ]] || \
       [[ "$file" == *"/__pycache__/"* ]] || \
       [[ "$file" == *"security-check"* ]]; then
        return 0
    fi

    # Skip documentation and example files for strict checks (but still check for IPs)
    local is_docs_or_example=false
    if [[ "$file" == *"/docs/"* ]] || \
       [[ "$file" == *"/examples/"* ]] || \
       [[ "$file" == *"README"* ]] || \
       [[ "$file" == *"SECURITY.md"* ]] || \
       [[ "$file" == *".example"* ]] || \
       [[ "$file" == *"github-actions-monitoring.md"* ]]; then
        is_docs_or_example=true
    fi

    if [ -f "$file" ]; then
        echo "Checking $file..."

        local file_violations=0

        # Check for hardcoded IP addresses (more lenient for infrastructure)
        if grep -E "192\.168\.1\.[0-9]{1,3}" "$file" > /dev/null 2>&1; then
            echo -e "  ${YELLOW}⚠️  Found hardcoded IP address: 192.168.1.x${NC}"
            echo -e "  ${YELLOW}   Consider using environment variables${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi

        # Check for hardcoded passwords (strict, but skip docs/examples)
        if ! $is_docs_or_example; then
            if grep -E "password.*=.*['\"][^'\"]{8,}['\"]" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found hardcoded password pattern${NC}"
                file_violations=$((file_violations + 1))
            fi

            # Check for API keys (strict, but skip docs/examples)
            if grep -E "api_key.*=.*['\"][^'\"]{8,}['\"]" "$file" > /dev/null 2>&1; then
                echo -e "  ${RED}❌ Found hardcoded API key pattern${NC}"
                file_violations=$((file_violations + 1))
            fi
        else
            # For docs/examples, just warn about potential patterns
            if grep -E "(password|api_key).*=.*['\"][^'\"]{8,}['\"]" "$file" > /dev/null 2>&1; then
                echo -e "  ${YELLOW}📝 Documentation contains example credentials (OK)${NC}"
            fi
        fi

        if [ $file_violations -gt 0 ]; then
            VIOLATIONS=$((VIOLATIONS + file_violations))
        fi
    fi
}

# Check for sensitive patterns in infrastructure files
for pattern in "${PROJECT_FILES[@]}"; do
    # Find files matching pattern and check each one
    while IFS= read -r -d '' file; do
        check_file "$file"
    done < <(find . -name "$pattern" -type f -print0 2>/dev/null)
done

echo ""
echo "=========================================="
echo "📊 Infrastructure Security Check Results:"
echo ""

if [ $VIOLATIONS -eq 0 ]; then
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Found $WARNINGS warning(s) - review recommended${NC}"
        echo -e "${GREEN}✅ No critical security violations found${NC}"
        echo -e "${GREEN}✅ Code is safe to commit and push${NC}"
    else
        echo -e "${GREEN}✅ No security issues found!${NC}"
        echo -e "${GREEN}✅ Code is safe to commit and push${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ Found $VIOLATIONS critical security violation(s)${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Also found $WARNINGS warning(s)${NC}"
    fi
    echo -e "${RED}❌ Please fix critical issues before committing${NC}"
    echo ""
    echo "🔧 Common fixes:"
    echo "  - Use environment variables for secrets"
    echo "  - Use configuration files for IP addresses"
    echo "  - Remove hardcoded credentials"
    echo "  - Use .env files (and add them to .gitignore)"
    exit 1
fi

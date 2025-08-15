#!/bin/bash

# Simplified security validation script using git-secrets
# This script uses only the default git-secrets patterns for AWS credentials

set -e

echo "🔒 Running simplified security checks..."
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if git-secrets is installed
GIT_SECRETS_PATH=$(command -v git-secrets)
if [ -z "$GIT_SECRETS_PATH" ]; then
    echo -e "${RED}❌ git-secrets is not installed.${NC}"
    echo -e "${YELLOW}Please install git-secrets:${NC}"
    echo -e "  macOS: ${GREEN}brew install git-secrets${NC}"
    echo -e "  Linux: ${GREEN}git clone https://github.com/awslabs/git-secrets.git && cd git-secrets && make install${NC}"
    exit 1
fi

echo -e "${GREEN}✅ git-secrets found at: $GIT_SECRETS_PATH${NC}"

# Initialize git-secrets with default AWS patterns only
echo -e "${BLUE}🔧 Initializing git-secrets with default AWS patterns...${NC}"
git-secrets --register-aws > /dev/null 2>&1

# Add basic allowed patterns for common false positives
echo -e "${BLUE}🔍 Adding basic allowed patterns...${NC}"
git secrets --add --allowed "example.com" 2>/dev/null || true
git secrets --add --allowed "localhost" 2>/dev/null || true
git secrets --add --allowed "127.0.0.1" 2>/dev/null || true
git secrets --add --allowed "your-.*-here" 2>/dev/null || true
git secrets --add --allowed "placeholder" 2>/dev/null || true

echo -e "${BLUE}🔍 Running git-secrets scan on entire repository...${NC}"

# Scan the entire repository
if git-secrets --scan -r; then
    echo -e "${GREEN}✅ No secrets detected in repository${NC}"
    echo -e "${GREEN}✅ Code is safe to commit and push${NC}"
    exit 0
else
    echo -e "${RED}❌ SECURITY ALERT: Potential secrets detected!${NC}"
    echo -e "${YELLOW}Please review the above output and remove any sensitive data.${NC}"
    echo -e "${BLUE}💡 If these are false positives, you can add them to the allowed list${NC}"
    exit 1
fi

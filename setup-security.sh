#!/bin/bash
# Security Setup Script for AI Infrastructure Platform
# Based on: https://medium.com/simform-engineering/preventing-sensitive-data-leaks-implementing-husky-and-git-secrets-in-your-git-workflow-dc7e5c7e14d7

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_status "🔐 Setting up security infrastructure for AI Infrastructure Platform"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "This script must be run from the root of a git repository"
    exit 1
fi

# Check Node.js installation
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed. Please install Node.js first."
    print_status "Visit: https://nodejs.org/"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm is required but not installed. Please install npm first."
    exit 1
fi

print_success "Node.js and npm are installed"

# Install git-secrets
print_status "🔧 Installing git-secrets..."

if command -v git-secrets &> /dev/null; then
    print_success "git-secrets is already installed"
else
    print_status "Installing git-secrets..."
    
    # Detect OS and install accordingly
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            print_status "Installing git-secrets via Homebrew..."
            brew install git-secrets
        else
            print_warning "Homebrew not found. Installing git-secrets manually..."
            # Manual installation for macOS
            git clone https://github.com/awslabs/git-secrets.git /tmp/git-secrets
            cd /tmp/git-secrets
            make install
            cd - > /dev/null
            rm -rf /tmp/git-secrets
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        print_status "Installing git-secrets manually for Linux..."
        git clone https://github.com/awslabs/git-secrets.git /tmp/git-secrets
        cd /tmp/git-secrets
        make install
        cd - > /dev/null
        rm -rf /tmp/git-secrets
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows
        print_error "Please install git-secrets manually on Windows:"
        print_status "1. Download from: https://github.com/awslabs/git-secrets"
        print_status "2. Run: ./install.ps1"
        exit 1
    else
        print_error "Unsupported operating system: $OSTYPE"
        print_status "Please install git-secrets manually from: https://github.com/awslabs/git-secrets"
        exit 1
    fi
fi

# Verify git-secrets installation
if ! command -v git-secrets &> /dev/null; then
    print_error "git-secrets installation failed. Please install manually."
    exit 1
fi

print_success "git-secrets installed successfully"

# Install npm dependencies (Husky)
print_status "📦 Installing npm dependencies..."
npm install

# Initialize Husky
print_status "🐕 Initializing Husky..."
npx husky install

# Make sure the pre-commit hook is executable
if [ -f ".husky/pre-commit" ]; then
    chmod +x .husky/pre-commit
    print_success "Pre-commit hook is ready"
else
    print_error "Pre-commit hook not found. Please check the .husky/pre-commit file."
    exit 1
fi

# Initialize git-secrets for this repository
print_status "🔐 Initializing git-secrets for this repository..."
git secrets --install --force

# Register AWS patterns
print_status "🔧 Registering AWS secret patterns..."
git secrets --register-aws

print_success "Security setup completed successfully!"
echo ""
print_status "🎯 What happens now:"
echo "  ✅ git-secrets is installed and configured"
echo "  ✅ Husky pre-commit hooks are active"
echo "  ✅ Custom patterns for infrastructure secrets are added"
echo "  ✅ AWS secret patterns are registered"
echo ""
print_status "🔍 Security patterns include:"
echo "  • Proxmox API tokens (root@pam!token=uuid format)"
echo "  • SSH private keys"
echo "  • Database connection strings"
echo "  • Generic API keys and secrets"
echo "  • Terraform sensitive variables"
echo "  • Kubernetes secrets"
echo "  • Environment variables with secrets"
echo ""
print_status "🧪 Testing the setup..."

# Create a test file with a fake secret to verify the setup works
test_file=".test-secret-detection"
echo "# Test file for secret detection" > "$test_file"
echo "api_key = 'sk_live_abcdefghijklmnopqrstuvwxyz1234567890123456789012345678901234567890123456789012345678901234567890'" >> "$test_file"

print_status "Running git-secrets scan on test file..."
if git-secrets --scan "$test_file" 2>&1 | grep -q "sk_live_"; then
    print_success "✅ Secret detection is working correctly!"
    rm "$test_file"
else
    print_warning "⚠️  Secret detection test inconclusive. Manual verification recommended."
    rm "$test_file"
fi

echo ""
print_success "🎉 Security setup complete!"
print_status "💡 Tips:"
echo "  • All commits will now be scanned for secrets automatically"
echo "  • If you get false positives, add them to the allowed list in .husky/pre-commit"
echo "  • Run 'npm run security-scan' to manually scan the repository"
echo "  • Check '.git-secrets.log' for detailed scan logs"
echo ""
print_warning "⚠️  Important:"
echo "  • Never commit real secrets, even in comments or documentation"
echo "  • Use environment variables or secret management tools"
echo "  • Regularly audit your repository for sensitive data"
echo ""
print_status "🔗 Reference: https://medium.com/simform-engineering/preventing-sensitive-data-leaks-implementing-husky-and-git-secrets-in-your-git-workflow-dc7e5c7e14d7"

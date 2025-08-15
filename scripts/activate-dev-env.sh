#!/bin/bash

# Activate Development Environment for LumaDeploy Infrastructure
# This script activates the Python virtual environment and sets up the development tools

set -e

echo "🚀 Activating LumaDeploy Development Environment..."

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Virtual environment not found. Creating one..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "🐍 Activating Python virtual environment..."
source .venv/bin/activate

# Install/upgrade development dependencies
echo "📦 Installing/upgrading development dependencies..."
pip install --upgrade pip
pip install PyYAML ansible-lint black flake8

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "📦 Installing pre-commit..."
    pip install pre-commit
fi

# Install pre-commit hooks if not already installed
if [ ! -f ".git/hooks/pre-commit" ]; then
    echo "🔧 Installing pre-commit hooks..."
    pre-commit install
fi

# Check if other tools are available
echo "🔍 Checking development tools..."

# Check Terraform
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform version | head -n1)"
else
    echo "❌ Terraform not found. Please install Terraform first."
fi

# Check tflint
if command -v tflint &> /dev/null; then
    echo "✅ tflint: $(tflint --version)"
else
    echo "⚠️  tflint not found. Run 'brew install tflint' for Terraform linting."
fi

# Check shellcheck
if command -v shellcheck &> /dev/null; then
    echo "✅ shellcheck: $(shellcheck --version | head -n1)"
else
    echo "⚠️  shellcheck not found. Run 'brew install shellcheck' for shell script validation."
fi

echo ""
echo "🎯 Development environment activated!"
echo ""
echo "🔧 Available commands:"
echo "   • pre-commit run --all-files    # Run all quality checks"
echo "   • pre-commit run terraform_fmt  # Format Terraform files"
echo "   • pre-commit run black          # Format Python files"
echo "   • pre-commit run flake8         # Lint Python files"
echo "   • pre-commit run shellcheck     # Validate shell scripts"
echo ""
echo "💡 To deactivate, run: deactivate"
echo "💡 To reactivate later, run: source scripts/activate-dev-env.sh"
echo ""
echo "🚀 Happy coding!"

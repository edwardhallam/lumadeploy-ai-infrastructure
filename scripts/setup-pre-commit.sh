#!/bin/bash

# Setup Pre-commit Hooks for LumaDeploy Infrastructure
# This script installs and configures pre-commit hooks for code quality validation

set -e

echo "🚀 Setting up Pre-commit Hooks for LumaDeploy Infrastructure..."

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed. Please install Python 3.11+ first."
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo "🐍 Found Python version: $PYTHON_VERSION"

# Install pre-commit if not already installed
if ! command -v pre-commit &> /dev/null; then
    echo "📦 Installing pre-commit..."

    # Check if we're on macOS with Homebrew
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
        echo "🍎 macOS detected, using Homebrew..."
        brew install pre-commit
    else
        # Try pipx first (recommended for Python applications)
        if command -v pipx &> /dev/null; then
            echo "📦 Using pipx to install pre-commit..."
            pipx install pre-commit
        else
            # Fallback to pip with user flag
            echo "📦 Using pip with --user flag..."
            python3 -m pip install --user pre-commit

            # Add to PATH if not already there
            if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
                echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.zshrc
                echo "⚠️  Added ~/.local/bin to PATH. Please restart your terminal or run:"
                echo "   source ~/.bashrc  # or source ~/.zshrc"
            fi
        fi
    fi
else
    echo "✅ pre-commit is already installed"
fi

# Install the pre-commit hooks
echo "🔧 Installing pre-commit hooks..."

# Check if there's a custom hooks path that might conflict
if git config --get core.hooksPath &> /dev/null; then
    echo "⚠️  Custom git hooks path detected. Attempting to resolve..."
    git config --unset-all core.hooksPath
    echo "✅ Cleared custom hooks path"
fi

# Install pre-commit hooks
if pre-commit install; then
    echo "✅ Pre-commit hooks installed successfully"
else
    echo "❌ Failed to install pre-commit hooks"
    echo "💡 Try running manually: pre-commit install"
    exit 1
fi

# Install additional dependencies for Terraform hooks
echo "📦 Installing Terraform pre-commit dependencies..."
if ! command -v terraform &> /dev/null; then
    echo "⚠️  Terraform not found. Please install Terraform first for full validation."
else
    echo "✅ Terraform found, installing tflint..."
    # Install tflint for Terraform linting
    if ! command -v tflint &> /dev/null; then
        echo "📦 Installing tflint..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            brew install tflint
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
        else
            echo "⚠️  Please install tflint manually for your OS: https://github.com/terraform-linters/tflint#installation"
        fi
    else
        echo "✅ tflint is already installed"
    fi
fi

# Install Python dependencies for hooks
echo "🐍 Installing Python dependencies for hooks..."
if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
    echo "🍎 macOS detected, using Homebrew for Python tools..."
    brew install black flake8 yaml-cpp
    # Install PyYAML via pip since it's not in Homebrew
    echo "📦 Installing PyYAML via pip..."
    if ! python3 -m pip install --user PyYAML; then
        echo "⚠️  PyYAML installation failed, trying alternative approach..."
        # Try using pipx if available
        if command -v pipx &> /dev/null; then
            echo "📦 Using pipx for PyYAML..."
            pipx install PyYAML
        else
            echo "❌ Failed to install PyYAML. Some YAML validation may not work."
        fi
    fi
else
    python3 -m pip install --user black flake8 PyYAML
fi

# Install shellcheck if not available
if ! command -v shellcheck &> /dev/null; then
    echo "📦 Installing shellcheck..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew install shellcheck
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        sudo apt-get update && sudo apt-get install -y shellcheck
    else
        echo "⚠️  Please install shellcheck manually for your OS"
    fi
else
    echo "✅ shellcheck is already installed"
fi

# Install ansible-lint if not available
if ! command -v ansible-lint &> /dev/null; then
    echo "📦 Installing ansible-lint..."
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
        echo "🍎 macOS detected, using Homebrew..."
        brew install ansible-lint
    else
        python3 -m pip install --user ansible-lint
    fi
else
    echo "✅ ansible-lint is already installed"
fi

# Test the setup
echo "🧪 Testing pre-commit setup..."
if pre-commit --version &> /dev/null; then
    echo "✅ Pre-commit setup completed successfully!"
    echo ""
    echo "🎯 What happens now:"
    echo "   • Pre-commit hooks will run automatically before each commit"
    echo "   • They will validate Terraform, YAML, Python, and shell scripts"
    echo "   • Commits will be blocked if validation fails"
    echo ""
    echo "🔧 Manual commands:"
    echo "   • Run all hooks: pre-commit run --all-files"
    echo "   • Run specific hook: pre-commit run terraform_fmt"
    echo "   • Skip hooks (not recommended): git commit --no-verify"
    echo ""
    echo "📚 For more info: https://pre-commit.com/"
else
    echo "❌ Pre-commit setup failed. Please check the installation."
    exit 1
fi

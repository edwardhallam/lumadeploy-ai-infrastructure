# Development Best Practices Guide

This guide outlines the best practices for the LumaDeploy Infrastructure project, addressing the issues identified by pre-commit hooks and providing solutions for maintaining high code quality.

## 🎯 **What This Guide Covers**

- **Terraform Best Practices** - Provider configuration, variable management, documentation
- **Python Code Quality** - Import organization, line length, f-string usage
- **Shell Script Standards** - POSIX compliance, error handling, variable declaration
- **macOS Development Environment** - Virtual environments, tool installation, configuration

## 🏗️ **Terraform Best Practices**

### **1. Provider Configuration**

**❌ Problem**: Duplicate provider configurations causing conflicts

```hcl
# main.tf
provider "proxmox" { ... }

# main-k3s.tf
provider "proxmox" { ... }  # ❌ Duplicate!
```

**✅ Solution**: Use provider aliases or consolidate into one file

```hcl
# providers.tf (single file for all providers)
provider "proxmox" {
  pm_api_url          = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
  pm_api_token_id     = var.proxmox_user
  pm_api_token_secret = var.proxmox_password
  pm_tls_insecure     = true
}

# Use aliases if you need different configurations
provider "proxmox" {
  alias = "production"
  # ... different config
}
```

### **2. Variable Management**

**❌ Problem**: Duplicate variable declarations

```hcl
# variables.tf
variable "proxmox_host" { ... }

# variables-k3s.tf
variable "proxmox_host" { ... }  # ❌ Duplicate!
```

**✅ Solution**: Consolidate variables into logical groups

```hcl
# variables.tf - Core Proxmox variables
variable "proxmox_host" { ... }
variable "proxmox_user" { ... }
variable "proxmox_password" { ... }

# variables-k3s.tf - K3s-specific variables only
variable "k3s_version" { ... }
variable "k3s_token" { ... }
```

### **3. Documentation Generation**

**❌ Problem**: Missing terraform-docs tool

```bash
# Install terraform-docs
brew install terraform-docs

# Generate documentation
terraform-docs markdown . > README.md
```

**✅ Best Practice**: Auto-generate documentation

```hcl
# Add to your pre-commit hooks
- id: terraform_docs
  args: ["--args=--sort-by-required"]
```

## 🐍 **Python Code Quality Standards**

### **1. Import Organization**

**❌ Problem**: Imports not at top of file

```python
# Some code here
import json  # ❌ Import in middle of file
```

**✅ Solution**: Follow PEP 8 import order

```python
# Standard library imports
import json
import os
import sys

# Third-party imports
import requests
import yaml

# Local imports
from .config import Config
from .utils import helper_function
```

### **2. Line Length Management**

**❌ Problem**: Lines longer than 88 characters

```python
# ❌ Too long
result = some_very_long_function_call(with_many_parameters, that_makes_the_line_exceed_88_characters)

# ✅ Better
result = some_very_long_function_call(
    with_many_parameters,
    that_makes_the_line_exceed_88_characters
)
```

### **3. F-string Usage**

**❌ Problem**: F-strings without placeholders

```python
# ❌ Unnecessary f-string
message = f"Hello world"  # No variables to interpolate

# ✅ Better
message = "Hello world"
```

**✅ Solution**: Only use f-strings when needed

```python
name = "Alice"
# ✅ Good f-string usage
message = f"Hello {name}"

# ✅ Regular string when no interpolation needed
message = "Hello world"
```

### **4. Unused Imports**

**❌ Problem**: Importing unused modules

```python
import json  # ❌ Imported but never used
import os    # ❌ Imported but never used
```

**✅ Solution**: Remove unused imports

```python
# Only import what you use
import sys
from typing import Optional
```

## 🐚 **Shell Script Best Practices**

### **1. POSIX Compliance**

**❌ Problem**: Non-portable echo flags

```bash
# ❌ Not POSIX compliant
echo -e "${BLUE}Hello${NC}"
```

**✅ Solution**: Use printf for colored output

```bash
# ✅ POSIX compliant
printf "%b" "${BLUE}Hello${NC}\n"

# Or define colors as functions
print_info() {
    printf "%b" "${BLUE}$1${NC}\n"
}
```

### **2. Variable Declaration**

**❌ Problem**: Declaring and assigning in one line

```bash
# ❌ Can mask return values
local var=$(some_command)
```

**✅ Solution**: Declare and assign separately

```bash
# ✅ Better practice
local var
var=$(some_command)
```

### **3. Error Handling**

**❌ Problem**: Missing error handling for commands

```bash
# ❌ No error handling
cd "$(dirname "$0")/.."
```

**✅ Solution**: Add proper error handling

```bash
# ✅ With error handling
cd "$(dirname "$0")/.." || exit 1
```

## 🍎 **macOS Development Environment Setup**

### **1. Python Virtual Environment**

**Best Practice**: Use virtual environments for project dependencies

```bash
# Create virtual environment
python3 -m venv .venv

# Activate it
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### **2. Homebrew for System Tools**

**Best Practice**: Use Homebrew for development tools

```bash
# Install essential tools
brew install terraform tflint shellcheck pre-commit

# Install Python tools in virtual environment
pip install black flake8 PyYAML ansible-lint
```

### **3. Pre-commit Configuration**

**Best Practice**: Configure pre-commit for your environment

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: black
        name: black
        entry: black
        language: system
        types: [python]
```

## 🔧 **Implementation Steps**

### **Phase 1: Fix Critical Issues (Week 1)**

1. **Resolve Terraform conflicts** - Consolidate providers and variables
2. **Install missing tools** - terraform-docs, tflint
3. **Fix duplicate configurations** - Merge conflicting files

### **Phase 2: Improve Code Quality (Week 2)**

1. **Fix Python imports** - Organize and remove unused imports
2. **Standardize line lengths** - Break long lines appropriately
3. **Fix f-string usage** - Remove unnecessary f-strings

### **Phase 3: Enhance Scripts (Week 3)**

1. **Improve shell scripts** - Add error handling and POSIX compliance
2. **Standardize variable usage** - Follow shell best practices
3. **Add documentation** - Comment complex logic

### **Phase 4: Automation (Week 4)**

1. **Configure pre-commit** - Set up automatic quality checks
2. **Add CI/CD validation** - Ensure remote repository quality
3. **Document standards** - Create team guidelines

## 📋 **Quick Fix Commands**

### **Fix Python Code**

```bash
# Format Python code
black .

# Lint Python code
flake8 .

# Fix import order
isort .
```

### **Fix Terraform Code**

```bash
# Format Terraform
terraform fmt -recursive

# Validate Terraform
terraform validate

# Generate documentation
terraform-docs markdown . > README.md
```

### **Fix Shell Scripts**

```bash
# Check shell scripts
shellcheck scripts/*.sh

# Fix common issues
# - Replace echo -e with printf
# - Add error handling for cd commands
# - Separate variable declaration and assignment
```

## 🎯 **Quality Gates**

### **Pre-commit Hooks**

- ✅ **Terraform**: Formatting, validation, documentation
- ✅ **Python**: Black formatting, Flake8 linting
- ✅ **YAML**: Syntax validation, structure checking
- ✅ **Shell**: ShellCheck validation, best practices

### **CI/CD Validation**

- ✅ **GitHub Actions**: Remote repository validation
- ✅ **Automated Testing**: Infrastructure validation
- ✅ **Documentation**: Auto-generated docs

## 📚 **Resources**

- **Terraform**: [Official Documentation](https://www.terraform.io/docs)
- **Python**: [PEP 8 Style Guide](https://pep8.org/)
- **Shell**: [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- **Pre-commit**: [Official Documentation](https://pre-commit.com/)

## 🚀 **Getting Started**

1. **Activate development environment**: `source scripts/activate-dev-env.sh`
2. **Run quality checks**: `pre-commit run --all-files`
3. **Fix issues systematically**: Start with critical Terraform conflicts
4. **Commit improvements**: Use pre-commit hooks to maintain quality

By following these best practices, you'll create a more maintainable, reliable, and professional infrastructure codebase! 🎉

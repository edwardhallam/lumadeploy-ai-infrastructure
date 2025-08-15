# Pre-commit Hooks Setup Guide

This guide explains how to set up and use pre-commit hooks for the LumaDeploy Infrastructure project to ensure code quality and consistency.

## What are Pre-commit Hooks? 🎯

Pre-commit hooks are automated checks that run before each Git commit to:

- Validate code syntax and formatting
- Enforce coding standards
- Catch errors early in the development process
- Ensure consistent code quality across the project

## What Gets Validated 🔍

### **Terraform Files**

- **Formatting**: Ensures consistent spacing, indentation, and structure
- **Syntax**: Validates Terraform configuration is correct
- **Documentation**: Auto-generates/updates documentation
- **Linting**: Checks for best practices and naming conventions

### **YAML/JSON Files**

- **Syntax**: Validates YAML and JSON are properly formatted
- **Structure**: Ensures files end with newlines and have no trailing spaces
- **Size**: Prevents large files from being committed

### **Python Files**

- **Formatting**: Auto-formats code using Black
- **Linting**: Checks for style issues and potential problems
- **Standards**: Enforces PEP 8 compliance

### **Shell Scripts**

- **Syntax**: Validates shell script syntax
- **Security**: Catches common security issues
- **Best Practices**: Ensures scripts follow shell scripting standards

### **Ansible Playbooks**

- **Syntax**: Validates Ansible playbook syntax
- **Best Practices**: Checks for production-ready configurations

## Quick Setup 🚀

### **Option 1: Using Make (Recommended)**

```bash
make setup-pre-commit
```

### **Option 2: Manual Setup**

```bash
# Install pre-commit
pip install pre-commit

# Install the hooks
pre-commit install

# Install additional dependencies
./scripts/setup-pre-commit.sh
```

## How It Works ⚙️

1. **Automatic Execution**: Hooks run automatically before each commit
2. **Validation**: Each file type is checked according to its rules
3. **Blocking**: Commits are blocked if validation fails
4. **Fixing**: Some hooks can automatically fix issues (like formatting)

## What Happens During Commit 📝

```bash
git commit -m "Add new K3s worker node"

# Pre-commit hooks run automatically:
✅ terraform_fmt: Fixed formatting in main-k3s.tf
✅ terraform_validate: Configuration is valid
✅ check-yaml: Validated infrastructure/k8s/worker.yaml
✅ shellcheck: Checked scripts/deploy.sh
✅ black: Formatted proxmox/python-tools/new_script.py

# If successful, commit proceeds
# If any hook fails, commit is blocked until issues are fixed
```

## Manual Commands 🛠️

### **Run All Hooks**

```bash
pre-commit run --all-files
```

### **Run Specific Hook**

```bash
pre-commit run terraform_fmt
pre-commit run black
pre-commit run shellcheck
```

### **Run Hooks on Staged Files Only**

```bash
pre-commit run
```

### **Skip Hooks (Not Recommended)**

```bash
git commit --no-verify
```

## Configuration Details ⚙️

The pre-commit configuration is in `.pre-commit-config.yaml` and includes:

### **Terraform Hooks**

- `terraform_fmt`: Formatting validation
- `terraform_validate`: Syntax validation
- `terraform_docs`: Documentation generation
- `terraform_tflint`: Advanced linting

### **General Hooks**

- `check-yaml`: YAML syntax validation
- `check-json`: JSON syntax validation
- `end-of-file-fixer`: Ensures files end with newline
- `trailing-whitespace`: Removes trailing spaces
- `check-added-large-files`: Prevents large file commits

### **Language-Specific Hooks**

- `black`: Python code formatting
- `flake8`: Python linting
- `shellcheck`: Shell script validation
- `ansible-lint`: Ansible playbook validation

## Troubleshooting 🔧

### **Hook Installation Issues**

```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Update hooks to latest versions
pre-commit autoupdate
```

### **Python Dependencies**

```bash
# Install required Python packages
pip install pre-commit black flake8 PyYAML ansible-lint

# Or use the setup script
./scripts/setup-pre-commit.sh
```

### **Terraform Issues**

```bash
# Install tflint for Terraform linting
# macOS
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

### **Shell Script Issues**

```bash
# Install shellcheck
# macOS
brew install shellcheck

# Linux
sudo apt-get install shellcheck
```

## Customization Options 🎨

### **Modify Hook Behavior**

Edit `.pre-commit-config.yaml` to:

- Change hook versions
- Add/remove hooks
- Modify hook arguments
- Set hooks to manual (non-blocking)

### **Example Customizations**

```yaml
# Make documentation generation non-blocking
- id: terraform_docs
  stages: [manual]  # Won't block commit

# Customize line length for Python
- id: flake8
  args: [--max-line-length=100]

# Disable specific Terraform rules
- id: terraform_tflint
  args: ['--args=--disable-rule=terraform_deprecated_index,terraform_unused_declarations']
```

## Integration with CI/CD 🔄

The pre-commit hooks complement your existing GitHub Actions:

- **Pre-commit**: Catches issues locally before commit
- **GitHub Actions**: Validates on remote repository
- **Dual Protection**: Ensures code quality at multiple stages

## Best Practices 💡

1. **Always run hooks**: Let them run automatically before commits
2. **Fix issues locally**: Don't use `--no-verify` unless absolutely necessary
3. **Keep hooks updated**: Run `pre-commit autoupdate` periodically
4. **Customize thoughtfully**: Only modify hooks when you understand the impact
5. **Team coordination**: Ensure all team members have hooks installed

## Getting Help 🆘

- **Pre-commit Documentation**: <https://pre-commit.com/>
- **Terraform Hooks**: <https://github.com/antonbabenko/pre-commit-terraform>
- **Python Hooks**: <https://black.readthedocs.io/>, <https://flake8.pycqa.org/>
- **Shell Hooks**: <https://github.com/koalaman/shellcheck>

## Summary 🎯

Pre-commit hooks provide an automated quality gate that:

- ✅ Ensures consistent code formatting
- ✅ Catches syntax errors early
- ✅ Enforces coding standards
- ✅ Improves code quality
- ✅ Reduces CI/CD failures
- ✅ Maintains project consistency

By setting up these hooks, you're ensuring that every commit to your infrastructure project meets quality standards before it even reaches the repository.

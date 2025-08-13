# Infrastructure Ecosystem Makefile
# ==================================

# Security checks
.PHONY: security-check
security-check:
	@echo "🔒 Running infrastructure security checks..."
	@./scripts/security-check-simple.sh

.PHONY: security-check-dry-run
security-check-dry-run:
	@echo "🔒 Running security checks (dry run)..."
	@./scripts/security-check-simple.sh || echo "Security violations found - fix before committing"

.PHONY: pre-commit
pre-commit: security-check
	@echo "✅ Pre-commit checks passed"

# Infrastructure validation
.PHONY: validate-configs
validate-configs:
	@echo "🔍 Validating infrastructure configurations..."
	@find . -name "*.yml" -o -name "*.yaml" | xargs -I {} sh -c 'echo "Checking: {}" && python -c "import yaml; yaml.safe_load(open(\"{}\"))" 2>/dev/null || echo "⚠️  YAML syntax issue in {}"'
	@echo "✅ Configuration validation complete"

# Proxmox management
.PHONY: proxmox-init
proxmox-init:
	@echo "🔧 Initializing Proxmox Terraform..."
	@cd proxmox/terraform && terraform init

.PHONY: proxmox-plan
proxmox-plan:
	@echo "📋 Planning Proxmox infrastructure changes..."
	@cd proxmox/terraform && terraform plan

.PHONY: proxmox-apply
proxmox-apply:
	@echo "🚀 Applying Proxmox infrastructure changes..."
	@cd proxmox/terraform && terraform apply

.PHONY: proxmox-status
proxmox-status:
	@echo "📊 Checking Proxmox infrastructure status..."
	@cd proxmox/terraform && terraform output

# Container management
.PHONY: container-console
container-console:
	@echo "🐳 Starting container console API..."
	@cd proxmox/container-console-api && python container_console_api.py

.PHONY: container-test
container-test:
	@echo "🧪 Testing container connectivity..."
	@cd proxmox/python-tools && python test_connection.py

# Documentation
.PHONY: docs
docs:
	@echo "📚 Infrastructure documentation available in:"
	@echo "  - README.md (main documentation)"
	@echo "  - SECURITY_SETUP.md (security guide)"
	@echo "  - proxmox/docs/ (Proxmox-specific docs)"
	@echo "  - cloudflare/docs/ (Cloudflare docs)"
	@echo "  - */README.md (component-specific docs)"

# Help
.PHONY: help
help:
	@echo "Infrastructure Ecosystem Commands:"
	@echo "=================================="
	@echo ""
	@echo "🔒 Security & Validation:"
	@echo "  security-check        Run security validation"
	@echo "  security-check-dry-run Test security checks"
	@echo "  validate-configs      Validate YAML configurations"
	@echo "  pre-commit           Run pre-commit validation"
	@echo ""
	@echo "🔧 Proxmox Management:"
	@echo "  proxmox-init         Initialize Terraform"
	@echo "  proxmox-plan         Plan infrastructure changes"
	@echo "  proxmox-apply        Apply infrastructure changes"
	@echo "  proxmox-status       Show current infrastructure status"
	@echo ""
	@echo "🐳 Container Management:"
	@echo "  container-console    Start container console API"
	@echo "  container-test       Test container connectivity"
	@echo ""
	@echo "📚 Documentation:"
	@echo "  docs                 Show documentation locations"
	@echo "  help                 Show this help message"

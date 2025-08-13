# Infrastructure Management Makefile
# ===================================

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

# Documentation
.PHONY: docs
docs:
	@echo "📚 Infrastructure documentation available in:"
	@echo "  - README.md (main documentation)"
	@echo "  - docs/ (detailed guides)"
	@echo "  - */README.md (component-specific docs)"

# Help
.PHONY: help
help:
	@echo "Infrastructure Management Commands:"
	@echo "=================================="
	@echo "  security-check        Run security validation"
	@echo "  security-check-dry-run Test security checks"
	@echo "  validate-configs      Validate YAML configurations"
	@echo "  pre-commit           Run pre-commit validation"
	@echo "  docs                 Show documentation locations"
	@echo "  help                 Show this help message"

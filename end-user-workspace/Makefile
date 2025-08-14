# AI Infrastructure Platform Makefile
# ===================================
# Cursor will help you use these commands

.PHONY: setup deploy destroy status logs help

setup:
	@echo "🚀 Setting up AI Infrastructure Platform..."
	@chmod +x setup.sh
	@./setup.sh

deploy:
	@echo "🚀 Deploying AI infrastructure..."
	@source venv/bin/activate && python3 main.py deploy

destroy:
	@echo "🗑️  Destroying infrastructure..."
	@source venv/bin/activate && python3 main.py destroy

status:
	@echo "📊 Checking infrastructure status..."
	@source venv/bin/activate && python3 main.py status

logs:
	@echo "📋 Showing deployment logs..."
	@source venv/bin/activate && python3 main.py logs

validate:
	@echo "🔍 Validating configuration..."
	@source venv/bin/activate && python3 -c "import yaml; yaml.safe_load(open('.env'))" 2>/dev/null || echo "⚠️  Configuration validation failed"

test-connection:
	@echo "🧪 Testing Proxmox connection..."
	@source venv/bin/activate && python3 main.py test-connection

activate:
	@echo "🐍 Activating Python virtual environment..."
	@echo "Run: source venv/bin/activate"
	@echo "Then you can use python3 commands directly"

help:
	@echo "AI Infrastructure Platform Commands:"
	@echo "===================================="
	@echo "  setup             Interactive configuration setup"
	@echo "  deploy            Deploy the entire infrastructure"
	@echo "  destroy           Remove all infrastructure"
	@echo "  status            Check deployment status"
	@echo "  logs              View deployment logs"
	@echo "  validate          Validate configuration files"
	@echo "  test-connection   Test Proxmox connectivity"
	@echo "  activate          Show how to activate virtual environment"
	@echo "  help              Show this help message"
	@echo ""
	@echo "💡 Tip: Ask Cursor to help you with any of these commands!"

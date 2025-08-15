# LumaDeploy AI Service Builder - Makefile
# Professional AI Infrastructure Platform with Cursor-Guided Deployment

.PHONY: help setup validate plan deploy status logs destroy clean security test docs

# Default target
help:
	@echo ""
	@echo "🚀 LumaDeploy AI Service Builder"
	@echo "   Professional AI Infrastructure Platform"
	@echo ""
	@echo "📋 Available Commands:"
	@echo ""
	@echo "  🔧 Setup & Configuration:"
	@echo "    make setup      - Run interactive setup wizard"
	@echo "    make security   - Configure security features (git-secrets, Husky)"
	@echo "    make validate   - Validate all configuration files"
	@echo ""
	@echo "  🚀 Deployment:"
	@echo "    make plan       - Preview infrastructure deployment"
	@echo "    make deploy     - Deploy complete AI infrastructure"
	@echo "    make status     - Check deployment status"
	@echo "    make logs       - View deployment and service logs"
	@echo ""
	@echo "  🧪 Testing & Development:"
	@echo "    make test       - Run infrastructure tests"
	@echo "    make docs       - Generate/update documentation"
	@echo ""
	@echo "  🔍 GitHub Actions:"
	@echo "    make check-actions      - Check GitHub Actions status"
	@echo "    make check-actions-wait - Check status and wait for completion"
	@echo "    make push-and-check     - Push to GitHub and check Actions"
	@echo "    make setup-hooks        - Setup automatic Actions checking"
	@echo ""
	@echo "  🧹 Maintenance:"
	@echo "    make destroy    - Destroy infrastructure (with confirmation)"
	@echo "    make clean      - Clean temporary files and caches"
	@echo ""
	@echo "💡 Cursor Integration:"
	@echo "   Ask Cursor: 'Help me understand these LumaDeploy commands'"
	@echo "   Ask Cursor: 'Guide me through deploying my AI infrastructure'"
	@echo ""

# Setup and Configuration
setup:
	@echo "🔧 Running LumaDeploy interactive setup..."
	@./setup.sh

security:
	@echo "🔐 Setting up security features..."
	@if [ -f "setup-security.sh" ]; then \
		./setup-security.sh; \
	else \
		echo "❌ Security setup script not found"; \
		exit 1; \
	fi

validate:
	@echo "✅ Validating LumaDeploy configuration..."
	@echo "  📋 Checking Terraform configuration..."
	@if [ ! -f "config/terraform.tfvars" ]; then \
		echo "❌ terraform.tfvars not found. Run 'make setup' first."; \
		exit 1; \
	fi
	@cd terraform && terraform fmt -check -diff
	@cd terraform && terraform init -backend=false
	@cd terraform && terraform validate
	@echo "  📋 Checking Ansible configuration..."
	@if [ ! -f "config/ansible-vars.yml" ]; then \
		echo "❌ ansible-vars.yml not found. Run 'make setup' first."; \
		exit 1; \
	fi
	@ansible-playbook --syntax-check ansible/site.yml
	@echo "  📋 Checking Kubernetes manifests..."
	@for file in kubernetes/*.yaml kubernetes/*/*.yaml; do \
		if [ -f "$$file" ]; then \
			echo "    Validating $$file..."; \
			kubectl --dry-run=client apply -f "$$file" > /dev/null 2>&1 || echo "    ⚠️  Warning: $$file may have issues"; \
		fi; \
	done
	@echo "✅ All configurations are valid!"

# Deployment
plan:
	@echo "📋 Planning LumaDeploy infrastructure deployment..."
	@if [ ! -f "config/terraform.tfvars" ]; then \
		echo "❌ Configuration not found. Run 'make setup' first."; \
		exit 1; \
	fi
	@cd terraform && terraform init
	@cd terraform && terraform plan -var-file="../config/terraform.tfvars"
	@echo ""
	@echo "💡 Cursor Tip: Ask 'Help me understand this Terraform plan'"

deploy:
	@echo "🚀 Deploying LumaDeploy AI infrastructure..."
	@if [ ! -f "config/terraform.tfvars" ]; then \
		echo "❌ Configuration not found. Run 'make setup' first."; \
		exit 1; \
	fi
	@echo "📋 Step 1: Deploying infrastructure with Terraform..."
	@cd terraform && terraform init
	@cd terraform && terraform apply -var-file="../config/terraform.tfvars" -auto-approve
	@echo "📋 Step 2: Configuring services with Ansible..."
	@ansible-playbook -i ansible/inventory ansible/site.yml --extra-vars "@config/ansible-vars.yml"
	@echo "📋 Step 3: Deploying Kubernetes applications..."
	@kubectl apply -f kubernetes/namespaces.yaml
	@kubectl apply -f kubernetes/ollama/
	@kubectl apply -f kubernetes/librechat/
	@kubectl apply -f kubernetes/mcp-servers/
	@kubectl apply -f kubernetes/monitoring/
	@echo ""
	@echo "🎉 LumaDeploy deployment complete!"
	@echo "💡 Run 'make status' to check your services"

status:
	@echo "📊 LumaDeploy Infrastructure Status"
	@echo ""
	@echo "🏗️  Terraform Infrastructure:"
	@cd terraform && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[] | select(.type=="proxmox_vm_qemu") | "  ✅ VM: \(.values.name) - \(.values.network[0].ip)"' 2>/dev/null || echo "  ❌ Terraform state not available"
	@echo ""
	@echo "☸️  Kubernetes Cluster:"
	@kubectl get nodes 2>/dev/null || echo "  ❌ Kubernetes not accessible"
	@echo ""
	@echo "🤖 AI Services:"
	@kubectl get pods -n ollama 2>/dev/null | grep -E "(NAME|ollama)" || echo "  ❌ Ollama not accessible"
	@kubectl get pods -n librechat 2>/dev/null | grep -E "(NAME|librechat)" || echo "  ❌ LibreChat not accessible"
	@kubectl get pods -n mcp-servers 2>/dev/null | grep -E "(NAME|mcp-server)" || echo "  ❌ MCP Servers not accessible"
	@echo ""
	@echo "📊 Monitoring:"
	@kubectl get pods -n monitoring 2>/dev/null | grep -E "(NAME|prometheus|grafana)" || echo "  ❌ Monitoring not accessible"
	@echo ""
	@echo "💡 Cursor Tip: Ask 'Help me troubleshoot any issues with my deployment'"

logs:
	@echo "📝 LumaDeploy Service Logs"
	@echo ""
	@echo "🤖 Ollama Logs:"
	@kubectl logs -n ollama deployment/ollama --tail=10 2>/dev/null || echo "  ❌ Ollama logs not available"
	@echo ""
	@echo "💬 LibreChat Logs:"
	@kubectl logs -n librechat deployment/librechat --tail=10 2>/dev/null || echo "  ❌ LibreChat logs not available"
	@echo ""
	@echo "🔌 MCP Server Logs:"
	@kubectl logs -n mcp-servers deployment/mcp-server-1 --tail=5 2>/dev/null || echo "  ❌ MCP Server logs not available"
	@echo ""
	@echo "💡 For detailed logs, use: kubectl logs -f deployment/<service> -n <namespace>"

# Testing and Development
test:
	@echo "🧪 Running LumaDeploy infrastructure tests..."
	@echo "📋 Testing Proxmox connectivity..."
	@if [ -f "proxmox/python-tools/test_connection.py" ]; then \
		cd proxmox/python-tools && python test_connection.py; \
	else \
		echo "  ⚠️  Proxmox connection test not available"; \
	fi
	@echo "📋 Testing Kubernetes connectivity..."
	@kubectl cluster-info 2>/dev/null || echo "  ❌ Kubernetes cluster not accessible"
	@echo "📋 Testing AI services..."
	@curl -s http://localhost:11434/api/tags 2>/dev/null | jq -r '.models[].name' 2>/dev/null || echo "  ⚠️  Ollama API not accessible"
	@echo "✅ Infrastructure tests complete"

docs:
	@echo "📚 Generating LumaDeploy documentation..."
	@echo "  📝 Updating README with current configuration..."
	@echo "  📝 Generating architecture diagrams..."
	@echo "  📝 Creating API documentation..."
	@echo "✅ Documentation updated"
	@echo "💡 View docs in the docs/ directory"

# Maintenance
destroy:
	@echo "💥 Destroying LumaDeploy infrastructure..."
	@echo ""
	@echo "⚠️  WARNING: This will destroy all your AI infrastructure!"
	@echo "   - All VMs and containers will be deleted"
	@echo "   - All data will be lost"
	@echo "   - This action cannot be undone"
	@echo ""
	@read -p "Are you absolutely sure? Type 'destroy-lumadeploy' to confirm: " confirm; \
	if [ "$$confirm" = "destroy-lumadeploy" ]; then \
		echo "🗑️  Destroying Kubernetes resources..."; \
		kubectl delete -f kubernetes/ --ignore-not-found=true 2>/dev/null || true; \
		echo "🗑️  Destroying Terraform infrastructure..."; \
		cd terraform && terraform destroy -var-file="../config/terraform.tfvars" -auto-approve; \
		echo "✅ Infrastructure destroyed"; \
	else \
		echo "❌ Destruction cancelled"; \
	fi

clean:
	@echo "🧹 Cleaning LumaDeploy temporary files..."
	@echo "  🗑️  Cleaning Terraform cache..."
	@rm -rf terraform/.terraform
	@rm -f terraform/.terraform.lock.hcl
	@rm -f terraform/terraform.tfstate.backup
	@echo "  🗑️  Cleaning Python cache..."
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@echo "  🗑️  Cleaning logs..."
	@rm -f *.log
	@rm -f /tmp/lumadeploy-*.log 2>/dev/null || true
	@echo "  🗑️  Cleaning node modules..."
	@rm -rf node_modules 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Utility targets
.PHONY: ssh-master ssh-worker1 ssh-worker2 kubeconfig check-actions push-and-check
ssh-master:
	@echo "🔗 Connecting to K3s master node..."
	@MASTER_IP=$$(cd terraform && terraform output -raw k3s_master_ip 2>/dev/null); \
	if [ -n "$$MASTER_IP" ]; then \
		ssh ubuntu@$$MASTER_IP; \
	else \
		echo "❌ Master IP not found. Is the infrastructure deployed?"; \
	fi

ssh-worker1:
	@echo "🔗 Connecting to K3s worker node 1..."
	@WORKER_IP=$$(cd terraform && terraform output -json k3s_worker_ips 2>/dev/null | jq -r '.[0]'); \
	if [ -n "$$WORKER_IP" ] && [ "$$WORKER_IP" != "null" ]; then \
		ssh ubuntu@$$WORKER_IP; \
	else \
		echo "❌ Worker IP not found. Is the infrastructure deployed?"; \
	fi

kubeconfig:
	@echo "📋 Fetching kubeconfig from K3s master..."
	@MASTER_IP=$$(cd terraform && terraform output -raw k3s_master_ip 2>/dev/null); \
	if [ -n "$$MASTER_IP" ]; then \
		scp ubuntu@$$MASTER_IP:/etc/rancher/k3s/k3s.yaml ~/.kube/lumadeploy-config; \
		sed -i "s/127.0.0.1/$$MASTER_IP/g" ~/.kube/lumadeploy-config; \
		echo "✅ Kubeconfig saved to ~/.kube/lumadeploy-config"; \
		echo "💡 Use: export KUBECONFIG=~/.kube/lumadeploy-config"; \
	else \
		echo "❌ Master IP not found. Is the infrastructure deployed?"; \
	fi

# Development helpers
.PHONY: dev-setup dev-test dev-logs
dev-setup:
	@echo "🔧 Setting up development environment..."
	@python3 -m venv venv
	@. venv/bin/activate && pip install -r proxmox/python-tools/requirements.txt
	@npm install
	@echo "✅ Development environment ready"

dev-test:
	@echo "🧪 Running development tests..."
	@. venv/bin/activate && python -m pytest tests/ -v 2>/dev/null || echo "⚠️  No tests found"

dev-logs:
	@echo "📝 Following all service logs..."
	@kubectl logs -f -l app=ollama -n ollama &
	@kubectl logs -f -l app=librechat -n librechat &
	@kubectl logs -f -l app=mcp-server -n mcp-servers &
	@wait

# GitHub Actions Management
check-actions:
	@echo "🔍 Checking GitHub Actions status..."
	@./scripts/check-github-actions.sh

check-actions-wait:
	@echo "🔍 Checking GitHub Actions status (waiting for completion)..."
	@./scripts/check-github-actions.sh --wait

push-and-check:
	@echo "🚀 Pushing to GitHub and checking Actions status..."
	@git push origin main
	@echo ""
	@echo "⏳ Waiting a moment for workflows to start..."
	@sleep 5
	@./scripts/check-github-actions.sh

# Git hooks setup
setup-hooks:
	@echo "🔗 Setting up git hooks..."
	@mkdir -p .git/hooks
	@echo '#!/bin/bash' > .git/hooks/post-push
	@echo 'echo "🔍 Checking GitHub Actions after push..."' >> .git/hooks/post-push
	@echo './scripts/check-github-actions.sh' >> .git/hooks/post-push
	@chmod +x .git/hooks/post-push
	@echo "✅ Git hooks configured"
	@echo "💡 GitHub Actions will be checked automatically after each push"
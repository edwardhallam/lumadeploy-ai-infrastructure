# AI Infrastructure Platform - End User Edition

**🚀 Professional GitOps + Interactive Setup for AI Infrastructure**

This repository provides a **hybrid approach** that combines the best of both worlds:
- **Interactive Setup with Cursor** - Get guided through configuration
- **GitOps Deployment** - Professional Infrastructure as Code with full audit trail
- **Automated Infrastructure** - Terraform + Ansible + GitHub Actions

## 🎯 **What This Platform Provides**

Transform your Proxmox environment into a powerful AI infrastructure platform with:
- **LibreChat** - Self-hosted AI chat assistant
- **MCP Server** - Model Context Protocol server for AI tools
- **Monitoring & Logging** - Prometheus, Grafana, and centralized logging
- **Reverse Proxy** - Nginx with SSL termination and load balancing
- **Security Hardening** - Firewall rules, access control, and security policies

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Interactive   │    │   GitOps         │    │   Infrastructure│
│   Setup with    │───▶│   Workflow       │───▶│   Deployment    │
│   Cursor        │    │   (Git + GitHub) │    │   (Proxmox)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### **1. Interactive Setup Phase**
- Cursor guides you through configuration
- Script generates Terraform and Ansible files
- All settings explained and validated

### **2. GitOps Deployment Phase**
- Commit configuration changes to git
- GitHub Actions automatically validates and deploys
- Full audit trail of all infrastructure changes

### **3. Infrastructure Management**
- Terraform manages Proxmox resources
- Ansible configures services and applications
- Automated monitoring and health checks

## 🚀 **Quick Start with Cursor**

### **Prerequisites**
- **Cursor IDE** - Your AI coding assistant
- **Proxmox VE** - Virtualization platform
- **Git** - Version control
- **Python 3.8+** - For local development tools

### **Step 1: Clone and Setup**
```bash
git clone https://github.com/edwardhallam/ai-infrastructure-end-user.git
cd ai-infrastructure-end-user
./setup.sh
```

**💡 Ask Cursor**: "Help me run the setup script and configure my AI infrastructure"

### **Step 2: Follow Cursor's Guidance**
The setup script will:
- Check prerequisites and install missing tools
- Guide you through Proxmox configuration
- Help you configure network settings
- Generate all necessary IaC files
- Explain the GitOps workflow

### **Step 3: Deploy via GitOps**
```bash
# Commit your configuration
git add infrastructure/config/
git commit -m "Configure AI infrastructure for production"
git push origin main

# GitHub Actions will automatically deploy your infrastructure!
```

**💡 Ask Cursor**: "Help me commit and push my configuration to trigger deployment"

## 🔧 **Available Commands**

### **Setup and Configuration**
```bash
make setup          # Interactive configuration setup
make validate       # Validate Terraform and Ansible configs
make plan           # Plan Terraform deployment
```

### **GitOps Deployment**
```bash
make deploy         # Deploy via GitHub Actions (commit & push)
make status         # Check infrastructure status
make logs           # View deployment logs (GitHub Actions)
```

### **Development and Testing**
```bash
make test-connection # Test Proxmox connectivity
make activate        # Activate Python virtual environment
make help            # Show all available commands
```

**💡 Ask Cursor**: "What does this command do and how do I use it?"

## 🏗️ **Infrastructure Components**

### **LXC Containers Created**
- **LibreChat** - AI chat interface (Port 3000)
- **MCP Server** - Model Context Protocol (Port 8000)
- **Monitoring** - Prometheus + Grafana (Ports 9090, 3000)
- **Reverse Proxy** - Nginx with SSL (Ports 80, 443)

### **Network Configuration**
- Automatic IP assignment from your subnet
- Bridge networking with Proxmox
- Configurable DNS servers
- Firewall rules for security

### **Storage Management**
- Configurable storage pools
- Resource limits (CPU, memory, storage)
- Automatic container sizing

## 🔄 **GitOps Workflow**

### **Configuration Management**
1. **Edit files** in `infrastructure/config/`
2. **Commit changes** with descriptive messages
3. **Push to main** to trigger deployment
4. **Monitor progress** in GitHub Actions

### **Deployment Pipeline**
```
Push to main → Validate → Plan → Deploy → Monitor
```

- **Validate**: Check syntax and format
- **Plan**: Generate deployment plan
- **Deploy**: Apply infrastructure changes
- **Monitor**: Track deployment status

### **Benefits of GitOps**
- **Audit Trail**: All changes tracked in git
- **Rollback**: Revert to previous configurations
- **Collaboration**: Multiple users can contribute
- **Automation**: No manual deployment steps

## 🤖 **Cursor's Role in This Workflow**

### **1. Setup Guidance**
- **Explains each configuration option** in simple terms
- **Helps you find correct values** for your environment
- **Validates inputs** before generating files
- **Shows examples** of good configurations

### **2. GitOps Education**
- **Explains the workflow** - why we commit before deploying
- **Guides git operations** - add, commit, push
- **Explains GitHub Actions** - what happens after push
- **Shows deployment status** - how to monitor progress

### **3. Troubleshooting Support**
- **Analyzes GitHub Actions logs** when deployments fail
- **Explains Terraform/Ansible errors** in user-friendly terms
- **Suggests fixes** for common issues
- **Guides rollback procedures** if needed

## 📚 **Documentation**

### **Guides**
- **[GitOps Guide](docs/gitops-guide.md)** - Understanding the deployment workflow
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions
- **[API Reference](docs/api.md)** - Command reference and usage
- **[Architecture](docs/architecture.md)** - System design and components

### **Configuration Examples**
- **[Terraform Variables](infrastructure/config/terraform.tfvars.example)** - Infrastructure configuration
- **[Ansible Variables](infrastructure/config/ansible-vars.yml.example)** - Service configuration

## 🔐 **Security Features**

### **Infrastructure Security**
- **Firewall rules** - Only necessary ports open
- **SSH key authentication** - No password-based access
- **Container isolation** - LXC security features
- **Network segmentation** - Isolated container networks

### **Access Control**
- **Proxmox API tokens** - Secure authentication
- **SSH key management** - Automated key distribution
- **User permissions** - Role-based access control
- **Audit logging** - Track all access attempts

## 📊 **Monitoring and Observability**

### **Infrastructure Monitoring**
- **Prometheus** - Metrics collection and storage
- **Grafana** - Visualization and dashboards
- **Container health checks** - Automated status monitoring
- **Resource utilization** - CPU, memory, storage tracking

### **Logging and Debugging**
- **Centralized logging** - All container logs in one place
- **Error tracking** - Automated error detection and reporting
- **Performance metrics** - Response time and throughput monitoring
- **Health status** - Real-time infrastructure health

## 🚨 **Getting Help**

### **1. Ask Cursor First**
Cursor is your AI assistant and knows this platform inside and out:
- **"Help me understand the GitOps workflow"**
- **"Guide me through committing and pushing changes"**
- **"Help me troubleshoot this deployment error"**
- **"Explain what this GitHub Actions log means"**

### **2. Check Documentation**
- Review the guides in the `docs/` directory
- Check configuration examples in `infrastructure/config/`
- Review GitHub Actions logs for deployment issues

### **3. Common Issues**
- **Missing configuration files** → Run `./setup.sh`
- **Terraform validation errors** → Run `make validate`
- **GitHub Actions failures** → Check Actions tab and logs
- **Proxmox connection issues** → Verify credentials and network

## 🔄 **Workflow Examples**

### **Adding a New Service**
1. **Edit configuration** - Add service to Ansible variables
2. **Ask Cursor** - "Help me add a new service to the infrastructure"
3. **Commit changes** - `git add infrastructure/config/`
4. **Push to deploy** - `git push origin main`
5. **Monitor deployment** - Check GitHub Actions progress

### **Updating Resource Limits**
1. **Edit Terraform variables** - Modify CPU/memory limits
2. **Ask Cursor** - "Help me update the resource allocation"
3. **Commit and push** - Changes automatically deployed
4. **Verify changes** - Check new resource allocation

### **Rollback Configuration**
1. **Revert commit** - `git revert HEAD`
2. **Push changes** - `git push origin main`
3. **Monitor rollback** - GitHub Actions will revert infrastructure
4. **Verify rollback** - Check that changes were reverted

## 🎯 **Next Steps**

### **Immediate Actions**
1. **Run the setup script** - `./setup.sh` with Cursor's help
2. **Configure GitHub secrets** - Proxmox credentials, SSH keys
3. **Test the GitOps workflow** - Commit and push configuration
4. **Monitor deployment** - Check GitHub Actions progress

### **Future Enhancements**
- **Add more AI services** - Additional AI models and tools
- **Implement backup automation** - Automated backup workflows
- **Add multi-environment support** - Dev, staging, production
- **Enhance monitoring** - Custom dashboards and alerts
- **Security scanning** - Container vulnerability checks

## 🏆 **Why This Approach?**

### **For End-Users**
- **Learn real-world practices** - Professional IaC experience
- **Interactive guidance** - Cursor helps with every step
- **Automated deployment** - No manual infrastructure management
- **Full audit trail** - All changes tracked and documented
- **Rollback capability** - Safe, controlled infrastructure changes

### **For the Platform**
- **Promotes best practices** - Users learn proper IaC
- **Professional workflow** - Enterprise-grade deployment
- **Better user education** - Users understand GitOps principles
- **Scalable architecture** - Supports team collaboration
- **Reduced support burden** - Cursor handles most questions

## 🎉 **Ready to Get Started?**

**The AI Infrastructure Platform is ready to transform your Proxmox environment!**

1. **Clone this repository**
2. **Run `./setup.sh` with Cursor's guidance**
3. **Configure your infrastructure**
4. **Commit and push to deploy**
5. **Monitor your automated deployment**

**💡 Remember: Cursor is your AI assistant throughout this entire process!**

---

**Happy deploying with GitOps and Cursor! 🚀🤖✨**

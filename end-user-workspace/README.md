# AI Infrastructure Platform - Cursor-First Setup

**🚀 Get your AI infrastructure running with Cursor's AI assistance!**

This is the end-user version of the AI Infrastructure Platform, designed specifically for Cursor users. Cursor will guide you through the entire setup process and execute the necessary commands to deploy your AI infrastructure on Proxmox.

## 🎯 What You'll Get

- **AI Chat Assistant**: LibreChat deployment with intelligent conversation capabilities
- **MCP Server**: Model Context Protocol server for enhanced AI functionality
- **Infrastructure as Code**: Automated deployment using Terraform and Python
- **Production Ready**: Secure, scalable infrastructure with Cloudflare integration

## 📋 Prerequisites

- **Cursor IDE** with AI assistance enabled
- **Proxmox VE 7.0+** running and accessible
- **Python 3.8+** installed on your local machine
- **Git** for downloading this repository
- **Basic networking knowledge** (IP addresses, subnets)

## 🚀 Quick Start with Cursor

### 1. Download and Setup

```bash
# Download the platform
git clone https://github.com/edwardhallam/ai-infrastructure-platform.git
cd ai-infrastructure-platform
```

### 2. Let Cursor Guide You

**In Cursor, ask:**
> "Help me set up this AI infrastructure platform. I need to configure Proxmox connection, network settings, and deploy the infrastructure."

**Cursor will:**
- Guide you through the configuration process
- Execute the setup script automatically
- Validate your inputs
- Deploy the infrastructure
- Monitor the deployment

### 3. Cursor-Executed Commands

Cursor will run these commands for you:
```bash
# Interactive configuration
./setup.sh

# Deploy infrastructure
make deploy

# Check status
make status

# View logs
make logs
```

## 🤖 How Cursor Helps

### **Configuration Wizard**
Cursor will guide you through:
1. **Proxmox Connection**: Host, username, password
2. **Network Settings**: IP addresses, subnets, DNS
3. **Cloudflare Setup**: API tokens and domain configuration
4. **Resource Allocation**: CPU, memory, storage limits

### **Automated Deployment**
Cursor will:
- Validate all configurations
- Test Proxmox connectivity
- Deploy LXC containers
- Set up AI services
- Configure networking
- Monitor deployment progress

### **Error Handling**
Cursor will:
- Detect and explain any issues
- Suggest solutions
- Retry failed operations
- Provide troubleshooting guidance

## 🔧 Available Commands

```bash
make setup          # Interactive configuration setup
make deploy         # Deploy the entire infrastructure
make destroy        # Remove all infrastructure
make status         # Check deployment status
make logs           # View deployment logs
make help           # Show all available commands
```

## 📁 What Gets Deployed

- **LXC Containers**: Optimized for AI workloads
- **LibreChat**: AI chat assistant with web interface
- **MCP Server**: Model Context Protocol server
- **Cloudflare Tunnel**: Secure external access
- **Monitoring**: Basic health checks and logging

## 🆘 Getting Help with Cursor

### **Ask Cursor For:**

**Setup Issues:**
> "Cursor, help me configure the Proxmox connection. I'm getting an error with the host IP."

**Deployment Problems:**
> "Cursor, the deployment failed. Can you check the logs and help me fix it?"

**Configuration Questions:**
> "Cursor, what should I set for the network subnet? My network uses 192.168.1.x"

**Troubleshooting:**
> "Cursor, the container creation is failing. Help me diagnose the issue."

### **Cursor Will:**
- Analyze error messages
- Check configuration files
- Review deployment logs
- Suggest specific fixes
- Execute corrective commands

## 🔒 Security

- All sensitive data is stored in `.env` files (never committed)
- Automated security scanning during deployment
- Secure defaults for production use
- Regular security updates

## 📚 Documentation

- **Setup Guide**: This README (Cursor will explain each step)
- **Cursor Guide**: [CURSOR_GUIDE.md](CURSOR_GUIDE.md) - How to work with Cursor
- **Troubleshooting**: Ask Cursor for help with any issues
- **API Reference**: Cursor can show you available commands
- **Architecture**: Cursor can explain how everything works

## 🤝 Support

- **Cursor AI**: Your primary guide through the entire process
- **GitHub Issues**: For bugs and feature requests
- **Documentation**: Comprehensive guides and examples

## 🎯 Cursor Workflow

1. **Download** the repository
2. **Ask Cursor** to help you set it up
3. **Follow Cursor's guidance** through configuration
4. **Let Cursor deploy** the infrastructure
5. **Ask Cursor** to monitor and manage your deployment

---

**Ready to deploy? Ask Cursor to help you set up this AI infrastructure platform!** 🚀

**Example prompt for Cursor:**
> "I just downloaded this AI infrastructure platform. Can you help me set it up? I need to configure it for my Proxmox server and deploy the AI services."

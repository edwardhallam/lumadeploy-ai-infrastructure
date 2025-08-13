# AI-First Infrastructure Platform

**🤖 AI Infrastructure as a Service (AI IaaS) with Complete IaC Automation**

An enterprise-grade AI Infrastructure as a Service platform that delivers LibreChat-based AI assistants and on-demand MCP (Model Context Protocol) servers through comprehensive Infrastructure as Code (IaC). Built for developers and organizations who demand intelligent AI chat systems with Cursor integration, featuring fully automated provisioning via Terraform and Ansible on Proxmox infrastructure. This platform transforms traditional infrastructure into an AI-native, code-driven experience.

## 🚀 Enterprise Features

- **🏗️ Complete Infrastructure as Code (IaC)**: 100% Terraform + Ansible automation for reproducible, version-controlled deployments
- **☁️ AI Infrastructure as a Service (AI IaaS)**: On-demand provisioning of LibreChat and MCP server instances
- **🤖 AI-Native Architecture**: Purpose-built for intelligent chat assistants and Model Context Protocol servers
- **⚡ Declarative Provisioning**: Code-driven infrastructure with GitOps workflows
- **🔧 MCP Server Orchestration**: Automated Model Context Protocol server lifecycle management
- **🖥️ Proxmox Virtualization**: Enterprise LXC container management with IaC principles
- **🌐 Production-Ready**: Professional GitHub setup with external-facing documentation
- **🛡️ Security-First IaC**: Automated security scanning and compliance validation
- **📡 API-Driven Management**: RESTful Container Console API for programmatic operations
- **⚙️ Cursor IDE Integration**: Seamless development workflow with AI-powered coding assistance

## 📋 Prerequisites

- **Infrastructure as Code Tools**:
  - Terraform 1.0+ (for infrastructure provisioning)
  - Ansible 2.9+ (for configuration management)
  - Python 3.8+ (for automation scripts and API services)
- **Development Environment**:
  - Make (for automation commands)
  - Git (for version control and GitOps workflows)
  - YAML support (for IaC configuration validation)
- **Target Infrastructure**:
  - Proxmox VE 7.0+ (for virtualization platform)
  - Sufficient resources for AI workloads (LibreChat + MCP servers)

## 🔧 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/edwardhallam/ai-infrastructure-platform.git
cd ai-infrastructure-platform

# Copy environment configuration
cp env.example .env
# Edit .env with your actual values
```

### 2. Run Security Checks

```bash
# Run security validation
make security-check

# Validate configurations
make validate-configs

# See all available commands
make help
```

## 🏗️ AI Infrastructure Components

### 🤖 LibreChat Foundation
- **AI Chat Assistant**: Core LibreChat deployment with intelligent conversation capabilities
- **MCP Server Integration**: Model Context Protocol servers for enhanced AI functionality
- **Cursor Integration**: Seamless development workflow with AI-powered coding assistance
- **Working Deployment**: LXC container 200 (librechat) running production-ready AI assistant

### 🚀 Infrastructure as Code (IaC) Automation
- **Terraform Provisioning**: Declarative LXC container infrastructure for AI workloads with state management
- **Ansible Configuration Management**: Idempotent LibreChat and MCP server configuration as code
- **GitOps Workflows**: Version-controlled infrastructure changes with automated validation
- **Python Automation APIs**: AI-focused container lifecycle management with programmatic interfaces
- **Container Console API**: RESTful API for remote AI system management and orchestration

### 🌐 Connectivity & Security
- **Cloudflare Integration**: Secure tunnel configurations for AI assistant access
- **Professional DNS**: External-facing setup for production AI deployments
- **Security Scanning**: AI workload-specific security validation

### 📦 AI-Optimized Templates
- **LibreChat Templates**: Pre-configured containers optimized for AI chat workloads
- **MCP Server Templates**: Ready-to-deploy Model Context Protocol server configurations
- **Development Templates**: Cursor-integrated development environments

## 📁 Project Structure

```
ai-infrastructure-platform/
├── .github/workflows/       # CI/CD and security automation
├── proxmox/                # AI infrastructure on Proxmox
│   ├── terraform/          # Terraform configs for LibreChat & MCP containers
│   ├── python-tools/       # AI workload management and automation scripts
│   ├── container-console-api/ # Remote AI system management API
│   ├── docs/              # Proxmox-specific documentation
│   ├── configs/           # Configuration files
│   ├── examples/          # Usage examples
│   └── tests/             # Test suites
├── cloudflare/             # Cloudflare tunnel management
│   ├── configs/           # Tunnel configurations
│   ├── scripts/           # Deployment and management scripts
│   └── docs/              # Cloudflare documentation
├── lxc-templates/          # AI-optimized container templates
│   ├── ubuntu/            # Ubuntu templates for LibreChat/MCP servers
│   ├── debian/            # Debian templates for AI workloads
│   └── alpine/            # Lightweight Alpine templates for MCP services
├── shared/                 # Common utilities and scripts
│   ├── scripts/           # Reusable automation scripts
│   ├── backup/            # Backup utilities
│   ├── monitoring/        # Monitoring tools
│   └── security/          # Security validation tools
├── scripts/               # Root-level automation and security
├── docs/                  # General documentation
├── env.example            # Environment configuration template
├── Makefile              # Unified automation commands
└── README.md             # This file
```

## 🔍 Available Commands

```bash
make security-check        # Run security validation
make security-check-dry-run # Test security checks
make validate-configs      # Validate YAML configurations
make pre-commit           # Run pre-commit validation
make docs                 # Show documentation locations
make help                 # Show all available commands
```

## 🛡️ Security Features

- **Automated Security Scanning**: GitHub Actions and local validation
- **Sensitive Data Protection**: Environment variable management
- **Configuration Validation**: YAML and infrastructure checks
- **Pre-commit Hooks**: Local development security

See [SECURITY_SETUP.md](SECURITY_SETUP.md) for detailed security information.

## 📚 Documentation

- **Main Documentation**: This README
- **Security Setup**: [SECURITY_SETUP.md](SECURITY_SETUP.md)
- **Component Docs**: Each directory contains specific documentation
- **Environment Setup**: [env.example](env.example)

## 🎯 Current AI Deployment Status

- **✅ LibreChat AI Assistant**: LXC container 200 running production-ready AI chat system (Debian 12, 2 cores, 2GB RAM, 10GB disk)
- **✅ Container Console API**: Operational on port 5000 for remote AI system management
- **✅ Terraform Infrastructure**: Fully configured for AI workload provisioning with API token authentication
- **✅ MCP Server Ready**: Infrastructure prepared for on-demand Model Context Protocol server deployment
- **✅ Cursor Integration**: Development workflow optimized for AI-first infrastructure management
- **✅ Professional GitHub Setup**: External-facing documentation and professional presentation

## 🤖 AI Infrastructure as a Service (AI IaaS) Architecture

This platform represents a paradigm shift from traditional infrastructure management to AI-native, code-driven operations:

### Core Philosophy
- **Infrastructure as Code First**: Every component defined, versioned, and managed through declarative code
- **AI IaaS Delivery Model**: On-demand AI infrastructure provisioning with service-level automation
- **GitOps-Driven Operations**: Infrastructure changes through pull requests with automated validation
- **Developer Experience**: Cursor integration for seamless AI-powered development workflows with IaC
- **Declarative Intelligence**: Code-defined AI chat assistants and MCP servers with reproducible deployments
- **Enterprise Standards**: Production-ready IaC with security scanning, compliance, and professional documentation

### Consolidated Infrastructure
This repository unifies previously separate infrastructure components into an AI-focused ecosystem:
- `proxmox-management` → AI workload provisioning (`proxmox/`)
- `cloudflare-tunnel-setup` → AI assistant connectivity (`cloudflare/`)
- `lxc-container-templates` → AI-optimized templates (`lxc-templates/`)
- `infrastructure-automation` → AI deployment utilities (`shared/`)

The unified approach ensures complete context for AI infrastructure operations while maintaining professional standards for external visibility.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

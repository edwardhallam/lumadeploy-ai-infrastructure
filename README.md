# Infrastructure Ecosystem

**🎯 Complete Infrastructure Management in One Repository**

A unified infrastructure management ecosystem containing all tools, configurations, and automation for Proxmox virtualization, Cloudflare tunnels, LXC containers, and shared infrastructure utilities. This consolidated approach ensures complete context, consistent standards, and simplified maintenance.

## 🚀 Features

- **Unified Ecosystem**: All infrastructure components in one repository for complete context
- **Proxmox Integration**: Full LXC container management with Terraform and Python tools
- **Container Console API**: Remote container management and automation
- **Multi-Cloud Infrastructure**: Support for various cloud and on-premises solutions
- **Security-First**: Automated security scanning and validation across all components
- **Infrastructure as Code**: Version-controlled infrastructure configurations
- **Professional Tooling**: Industry-standard DevOps practices

## 📋 Prerequisites

- Python 3.8+ (for scripts and automation)
- Make (for automation commands)
- YAML support (for configuration validation)
- Git (for version control)

## 🔧 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/edwardhallam/infrastructure-management.git
cd infrastructure-management

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

## 🏗️ Infrastructure Components

### Proxmox Management
- **Terraform Infrastructure**: Complete LXC container provisioning and management
- **Python Tools**: Container lifecycle management, storage checking, deployment automation
- **Container Console API**: Remote container access and command execution
- **Working Deployment**: LXC container 200 (librechat) running Debian 12

### Cloudflare Integration
- Secure tunnel configurations and management
- Automated deployment scripts
- DNS and routing management

### LXC Templates
- Pre-configured container templates
- Ubuntu, Debian, and Alpine variants
- Standardized configurations for Proxmox deployment

### Shared Utilities
- Backup automation and monitoring
- Security scanning and validation
- Deployment utilities and scripts

## 📁 Project Structure

```
infrastructure-ecosystem/
├── .github/workflows/       # CI/CD and security automation
├── proxmox/                # Proxmox infrastructure management
│   ├── terraform/          # Terraform configurations for LXC containers
│   ├── python-tools/       # Container management and automation scripts
│   ├── container-console-api/ # Remote container access API
│   ├── docs/              # Proxmox-specific documentation
│   ├── configs/           # Configuration files
│   ├── examples/          # Usage examples
│   └── tests/             # Test suites
├── cloudflare/             # Cloudflare tunnel management
│   ├── configs/           # Tunnel configurations
│   ├── scripts/           # Deployment and management scripts
│   └── docs/              # Cloudflare documentation
├── lxc-templates/          # Container templates
│   ├── ubuntu/            # Ubuntu LXC templates
│   ├── debian/            # Debian LXC templates
│   └── alpine/            # Alpine LXC templates
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

## 🎯 Current Deployment Status

- **✅ LXC Container 200 (librechat)**: Running Debian 12, 2 cores, 2GB RAM, 10GB disk
- **✅ Container Console API**: Operational on port 5000 for remote management
- **✅ Terraform Infrastructure**: Fully configured with API token authentication
- **✅ Security Scanning**: Comprehensive validation across all components
- **✅ Unified Repository**: Complete ecosystem in one location for optimal context

## 🔄 Migration Notes

This repository consolidates multiple previously separate infrastructure repositories:
- `proxmox-management` (now in `proxmox/`)
- `cloudflare-tunnel-setup` (now in `cloudflare/`)
- `lxc-container-templates` (now in `lxc-templates/`)
- `infrastructure-automation` (now in `shared/`)

This unified approach eliminates context loss, ensures consistent standards, and simplifies maintenance while preserving all functionality.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

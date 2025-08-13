# Infrastructure Management

A comprehensive infrastructure management repository containing tools, configurations, and automation for various infrastructure components including Cloudflare tunnels, LXC templates, and shared scripts.

## 🚀 Features

- **Multi-Cloud Infrastructure**: Support for various cloud and on-premises solutions
- **Security-First**: Automated security scanning and validation
- **Infrastructure as Code**: Version-controlled infrastructure configurations
- **Modular Design**: Organized components for different infrastructure needs
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

### Cloudflare Tunnels
- Secure tunnel configurations
- Automated deployment scripts
- DNS and routing management

### LXC Templates
- Pre-configured container templates
- Ubuntu, Debian, and Alpine variants
- Standardized configurations

### Shared Scripts
- Backup automation
- Deployment utilities
- Monitoring tools

## 📁 Project Structure

```
infrastructure-management/
├── .github/workflows/       # CI/CD and security automation
├── cloudflare-tunnels/      # Cloudflare tunnel configurations
├── lxc-templates/          # Container templates
├── shared-scripts/         # Reusable automation scripts
├── scripts/               # Security and validation tools
├── docs/                  # Documentation
├── env.example            # Environment configuration template
├── Makefile              # Automation commands
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

## 🔗 Related Projects

- **[proxmox-management](https://github.com/edwardhallam/proxmox-management)**: Dedicated Proxmox LXC management with Terraform

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

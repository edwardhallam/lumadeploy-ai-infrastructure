# Troubleshooting Guide

## Getting Help with Cursor

**The best way to get help is to ask Cursor directly!**

### Common Issues and Solutions

#### Connection Issues

**Proxmox Connection Failed**
- Verify Proxmox is running and accessible
- Check firewall settings
- Ensure credentials are correct
- **Ask Cursor**: "Help me troubleshoot my Proxmox connection"

**Container Creation Fails**
- Check Proxmox resource availability
- Verify storage pool configuration
- Review Proxmox logs
- **Ask Cursor**: "Help me fix the container creation issue"

#### Configuration Issues

**Environment Variables Missing**
- Run `./setup.sh` to recreate configuration
- Check `.env` file exists and is readable
- Verify all required variables are set
- **Ask Cursor**: "Help me fix my configuration file"

**Network Configuration Errors**
- Validate IP address format
- Check subnet mask notation
- Ensure gateway is reachable
- **Ask Cursor**: "Help me configure my network settings correctly"

#### Deployment Issues

**Python Dependencies**
- Run `source venv/bin/activate` to activate virtual environment
- Check Python version (3.8+ required)
- Verify pip is up to date
- **Ask Cursor**: "Help me install the missing Python dependencies"

**Permission Errors**
- Check file permissions on scripts
- Ensure execute permissions: `chmod +x *.sh`
- Verify user has necessary privileges
- **Ask Cursor**: "Help me fix the permission issues"

## Getting Help

1. **Ask Cursor first** - It's your AI assistant and knows this platform
2. Check the logs: `make logs`
3. Review this troubleshooting guide
4. Open a GitHub issue with error details

## Cursor Commands

**Ask Cursor to:**
- "Help me deploy the infrastructure"
- "Check the status of my deployment"
- "Show me the deployment logs"
- "Help me fix this error"
- "Explain what this configuration means"

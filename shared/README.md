# Shared Scripts

## Overview
Common automation and utility scripts used across all infrastructure projects.

## Categories

### Backup
- `backup/backup-projects.sh` - Backup all infrastructure projects
- Automated backup scheduling
- Compression and archiving

### Monitoring
- System health checks
- Resource monitoring
- Alert notifications

### Deployment
- Automated deployment scripts
- Environment management
- Rollback procedures

## Usage
1. Make scripts executable: `chmod +x scripts/*.sh`
2. Run from the infrastructure root directory
3. Customize paths and settings as needed

## Best Practices
- Always test scripts in development first
- Use environment variables for configuration
- Implement proper error handling
- Log all operations for debugging

# API Reference

## Commands

### `make deploy`
Deploys the entire AI infrastructure.

**Usage:**
```bash
make deploy
```

**What it does:**
- Validates configuration
- Tests Proxmox connectivity
- Creates LXC containers
- Sets up LibreChat
- Configures MCP server
- Establishes Cloudflare tunnel

**Ask Cursor**: "Help me deploy the infrastructure"

### `make status`
Checks the status of deployed infrastructure.

**Usage:**
```bash
make status
```

**Output:**
- Container status
- Service health
- Resource usage
- Network connectivity

**Ask Cursor**: "Check the status of my deployment"

### `make destroy`
Removes all deployed infrastructure.

**Usage:**
```bash
make destroy
```

**Warning:** This will permanently delete all containers and data.

**Ask Cursor**: "Help me safely destroy the infrastructure"

## Python Script

### `python3 main.py deploy`
Direct Python deployment command.

### `python3 main.py status`
Direct status checking command.

### `python3 main.py logs`
Display deployment logs.

## Getting Help

**Ask Cursor for help with any command:**
- "What does this command do?"
- "Help me run this command"
- "What's the output mean?"
- "Help me fix this error"

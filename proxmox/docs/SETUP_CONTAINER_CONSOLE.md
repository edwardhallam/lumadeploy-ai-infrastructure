# 🐳 Container Console Bridge Setup Guide

This guide will help you set up a system that allows Cursor to execute commands directly in LXC containers on your Proxmox host.

## 🏗️ **Architecture Overview**

```
Cursor (Local) ←→ Container Console API (Proxmox Host) ←→ LXC Containers
```

## 📋 **What We're Building**

1. **Container Console Service** - Python service running on Proxmox host
2. **Flask API Bridge** - REST API for remote command execution
3. **Cursor Client** - Local client for Cursor integration
4. **Automated Deployment** - One-click LibreChat deployment

## 🚀 **Setup Steps**

### **Step 1: Prepare Proxmox Host**

SSH into your Proxmox server (`your_proxmox_ip`):

```bash
ssh root@your_proxmox_ip
```

### **Step 2: Install Python Dependencies**

```bash
# Update system
apt update && apt upgrade -y

# Install Python and pip
apt install -y python3 python3-pip python3-venv

# Create virtual environment
cd /root
python3 -m venv container-console-env
source container-console-env/bin/activate

# Install requirements
pip install -r container_console_requirements.txt
```

### **Step 3: Copy Service Files**

Copy these files to your Proxmox host:
- `container_console_service.py`
- `container_console_api.py`
- `container_console_requirements.txt`

### **Step 4: Test the Service**

```bash
# Test the basic service
python3 container_console_service.py

# Test the API
python3 container_console_api.py
```

The API will start on port 5000.

### **Step 5: Test from Cursor (Local Machine)**

On your local machine (where Cursor is running):

```bash
# Test the client
python3 cursor_container_client.py
```

## 🔧 **Configuration**

### **API Configuration**

The API runs on `http://your_proxmox_ip:5000` by default. You can modify this in `container_console_api.py`.

### **Security Considerations**

- **Firewall**: Ensure port 5000 is accessible from your local machine
- **Authentication**: Consider adding API key authentication for production use
- **Network**: The API is currently open - restrict access as needed

## 📡 **API Endpoints**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/containers` | GET | List all containers |
| `/containers/<id>/info` | GET | Get container info |
| `/containers/<id>/execute` | POST | Execute command |
| `/containers/<id>/test` | GET | Test container access |
| `/containers/<id>/deploy-librechat` | POST | Deploy LibreChat |

## 🎯 **Usage Examples**

### **Execute a Command**

```bash
# From Cursor client
python3 cursor_container_client.py

# Choose option 3 (Test single command)
# Enter: apt update
```

### **Deploy LibreChat**

```bash
# From Cursor client
python3 cursor_container_client.py

# Choose option 1 (Deploy LibreChat)
# This will automatically:
# 1. Update system
# 2. Install Docker
# 3. Deploy LibreChat
# 4. Provide access URL
```

### **Interactive Session**

```bash
# From Cursor client
python3 cursor_container_client.py

# Choose option 2 (Interactive session)
# Type commands directly:
# - info (container info)
# - status (system status)
# - docker ps (running containers)
# - exit (quit session)
```

## 🚀 **Advanced Features**

### **Real-time Command Execution**

The system supports:
- **Command timeouts** (configurable)
- **Error handling** and reporting
- **Execution time** tracking
- **Output capture** (stdout/stderr)

### **Automated Deployment**

The LibreChat deployment:
- **Updates system** automatically
- **Installs dependencies** (curl, git, Docker)
- **Deploys application** with proper configuration
- **Provides status** and access information

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Connection Failed**
   - Check if API service is running on Proxmox
   - Verify firewall settings
   - Check network connectivity

2. **Container Access Denied**
   - Ensure container is running
   - Check container permissions
   - Verify LXC configuration

3. **Command Execution Failed**
   - Check command syntax
   - Verify container state
   - Review error messages

### **Debug Mode**

Enable debug logging in `container_console_api.py`:

```python
app.run(host='0.0.0.0', port=5000, debug=True)
```

## 🔮 **Future Enhancements**

### **Planned Features**

1. **WebSocket Support** - Real-time console output
2. **File Transfer** - Upload/download files to containers
3. **Multi-container Management** - Manage multiple containers simultaneously
4. **Container Templates** - Pre-configured container setups
5. **Monitoring Dashboard** - Container health and performance

### **Integration Possibilities**

- **Cursor Extensions** - Direct IDE integration
- **Web Interface** - Browser-based container management
- **Mobile App** - Container management on the go
- **CI/CD Integration** - Automated container deployments

## 🎉 **What You'll Achieve**

With this setup, you'll be able to:

✅ **Execute commands** in LXC containers directly from Cursor
✅ **Deploy applications** with a single command
✅ **Manage containers** remotely and efficiently
✅ **Automate infrastructure** operations
✅ **Monitor containers** in real-time

## 🆘 **Need Help?**

If you encounter issues:

1. **Check logs** on Proxmox host
2. **Verify network** connectivity
3. **Test individual components** step by step
4. **Review error messages** for specific issues

## 🚀 **Ready to Deploy?**

Once setup is complete, you can deploy LibreChat with:

```bash
python3 cursor_container_client.py
# Choose option 1: Deploy LibreChat
```

This will give you a fully functional AI chat application running in your infrastructure, managed entirely from Cursor! 🎯

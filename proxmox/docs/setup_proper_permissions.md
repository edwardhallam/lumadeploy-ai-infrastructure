# Fixing Proxmox API Token Permissions

## 🚨 **Current Issue**
Your API token doesn't have the necessary permissions to create LXC containers. The error shows:
- Storage 'local' does not support container directories
- Unable to parse directory volume names
- Permission check failed for LVM operations

## 🔑 **Solution: Create New API Token with Proper Permissions**

### **Step 1: Access Proxmox Web Interface**
1. Open your browser and go to: `https://your_proxmox_ip:8006`
2. Login with your root credentials

### **Step 2: Create New API Token**
1. Go to **Datacenter** → **Permissions** → **API Tokens**
2. Click **Add** → **API Token**
3. Configure the token:
   - **User**: `root@pam`
   - **Token ID**: `librechat-management-tool`
   - **Privilege Separation**: Enable
   - **Comment**: `Full container management permissions`

### **Step 3: Set Permissions**
1. Go to **Datacenter** → **Permissions**
2. Click **Add** → **Permission**
3. Configure:
   - **Path**: `/`
   - **User**: `your_api_token_id`
   - **Role**: `Administrator`
   - **Propagate**: ✓ (checked)

### **Step 4: Update Your .env File**
Replace your current API token with the new one:
```bash
PROXMOX_API_TOKEN=your_api_token_id=your-new-token-here
```

## 🐳 **Alternative: Manual Container Creation**

If you prefer to create the container manually:

### **Step 1: Create Container via Web Interface**
1. Go to **pve01** → **LXC Containers**
2. Click **Create CT**
3. Configure:
   - **Node**: pve01
   - **VM ID**: 200
   - **Hostname**: librechat
   - **Template**: Debian 12 Standard
   - **Cores**: 4
   - **Memory**: 4098 MB
   - **Root disk**: 20 GB (local-lvm)
   - **Network**: vmbr0, DHCP

### **Step 2: Start and Configure**
1. Start the container
2. Access console: `pct enter 200`
3. Update system: `apt update && apt upgrade -y`
4. Install Docker: `curl -fsSL https://get.docker.com | sh`
5. Deploy LibreChat: `docker run -d --name librechat -p 3000:3000 ghcr.io/danny-avila/librechat:latest`

## 🔍 **Verify Permissions**

After creating the new API token, test with:
```bash
python test_connection.py
```

You should see successful container operations.

## 📋 **Next Steps**

1. **Fix API permissions** (recommended)
2. **Test container creation** with new token
3. **Deploy LibreChat** automatically
4. **Configure networking** and access

## 🆘 **Need Help?**

If you continue having issues:
1. Check Proxmox logs: `tail -f /var/log/pve/tasks/`
2. Verify storage configuration
3. Ensure LVM is properly configured
4. Check firewall/network settings

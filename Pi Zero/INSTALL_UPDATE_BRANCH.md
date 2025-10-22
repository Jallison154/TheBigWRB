# WRB Installation Guide - Update-1.0 Branch

This guide covers installation of the WRB (Wireless Remote Button) system from the Update-1.0 branch, which includes the latest features and improvements.

## 🚀 Quick Installation Options

### Option 1: One-Line Install (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/one_liner_install.sh | bash
```

### Option 2: Quick Install Script
```bash
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/quick_install_update.sh | bash
```

### Option 3: Clone and Install
```bash
git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB
cd ~/TheBigWRB/Pi\ Zero
chmod +x install_update_branch.sh
./install_update_branch.sh
```

## 📋 What's New in Update-1.0 Branch

### Enhanced Features
- **Improved Branch Management**: Automatic detection and checkout of Update-1.0 branch
- **Better Error Handling**: More robust installation process
- **Enhanced Git Integration**: Automatic branch switching and updates
- **Updated Service Configuration**: Service files optimized for Update-1.0 features
- **Improved Logging**: Better tracking of installation progress

### Installation Scripts Available

1. **`install_update_branch.sh`** - Full installation script for Update-1.0 branch
2. **`quick_install_update.sh`** - Quick installation with automatic cleanup
3. **`one_liner_install.sh`** - Single command installation
4. **`install.sh`** - Updated main install script with Update-1.0 support

## 🔧 Manual Installation Steps

If you prefer to install manually:

### Step 1: Clone the Repository
```bash
git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB
cd ~/TheBigWRB/Pi\ Zero
```

### Step 2: Run Installation
```bash
chmod +x install_update_branch.sh
./install_update_branch.sh
```

### Step 3: Verify Installation
```bash
sudo systemctl status WRB-enhanced.service
```

## 🌿 Branch Management

### Switching to Update-1.0 Branch
If you already have the system installed and want to switch to Update-1.0:

```bash
cd ~/WRB
git fetch origin Update-1.0
git checkout Update-1.0
```

### Updating from Update-1.0 Branch
```bash
cd ~/WRB
git pull origin Update-1.0
```

## 📊 Installation Features

### Automatic Branch Detection
- The installation script automatically detects and uses the Update-1.0 branch
- Falls back to main branch if Update-1.0 is not available
- Provides clear feedback about which branch is being used

### Enhanced Service Configuration
- Service files are optimized for Update-1.0 features
- Better error handling and logging
- Improved restart mechanisms

### Git Integration
- Automatic repository setup with Update-1.0 branch
- Easy updates and branch switching
- Proper remote configuration

## 🔍 Verification Commands

After installation, verify everything is working:

```bash
# Check service status
sudo systemctl status WRB-enhanced.service

# Check branch
cd ~/WRB && git branch

# View logs
sudo journalctl -u WRB-enhanced.service -f

# Test ESP32 connection
python3 ~/WRB/test_esp32_connection.py
```

## 🛠️ Troubleshooting

### Branch Issues
If you encounter branch-related issues:

```bash
# Force checkout Update-1.0 branch
cd ~/WRB
git fetch origin Update-1.0
git checkout -f Update-1.0

# Or reset to Update-1.0
git reset --hard origin/Update-1.0
```

### Installation Issues
If the installation fails:

```bash
# Check git repository
cd ~/WRB
git remote -v
git branch -a

# Re-run installation
cd ~/TheBigWRB/Pi\ Zero
./install_update_branch.sh
```

## 📁 File Structure

After installation with Update-1.0 branch:

```
~/WRB/
├── PiScript                    # Main application (Update-1.0 version)
├── config.py                   # Configuration
├── monitor_system.py           # System monitoring
├── test_esp32_connection.py    # ESP32 connection test
├── test_system_integration.py  # Integration tests
├── requirements.txt            # Python dependencies
├── sounds/                     # Sound files directory
└── .git/                       # Git repository (Update-1.0 branch)
```

## 🔄 Updates and Maintenance

### Regular Updates
```bash
cd ~/WRB
git pull origin Update-1.0
sudo systemctl restart WRB-enhanced.service
```

### Branch Switching
```bash
# Switch to main branch
git checkout main

# Switch back to Update-1.0
git checkout Update-1.0
```

## 📞 Support

### Useful Commands for Update-1.0 Branch
```bash
# Check current branch
git branch

# View branch information
git log --oneline -5

# Check for updates
git fetch origin Update-1.0
git status

# Force update to latest Update-1.0
git reset --hard origin/Update-1.0
```

### Service Management
```bash
# Restart service
sudo systemctl restart WRB-enhanced.service

# Check service logs
sudo journalctl -u WRB-enhanced.service -f

# Monitor system
python3 ~/WRB/monitor_system.py
```

---

## ✅ Installation Complete!

Your WRB system is now installed from the Update-1.0 branch with all the latest features and improvements. The system will automatically start on boot and provide enhanced functionality.

**Next Steps:**
1. Test your ESP32 transmitters
2. Customize sound files in `~/WRB/sounds/`
3. Monitor the system with `python3 ~/WRB/monitor_system.py`
4. Check for updates with `git pull origin Update-1.0`

#!/bin/bash
# WRB Pi Installation Script
# Complete installation for ESP32 Wireless Button System with Update-1.0 branch support

set -e

echo "=========================================="
echo "  WRB Pi Installation Script"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Configuration
REPO_URL="https://github.com/Jallison154/TheBigWRB.git"
DEFAULT_BRANCH="Update-1.0"
FALLBACK_BRANCH="main"

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Script directory: $SCRIPT_DIR"

# Step 1: Update system
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Step 2: Install required packages
echo "📦 Installing required packages..."
sudo apt install -y python3-pip python3-pygame python3-serial python3-gpiozero sox git alsa-utils

# Step 3: Create directory structure
echo "📁 Creating directory structure..."
mkdir -p ~/WRB/sounds

# Step 4: Setup git repository and get latest code
echo "🌿 Setting up git repository..."
cd ~/WRB

if [ ! -d ".git" ]; then
    echo "📥 Initializing git repository..."
    git init
    git remote add origin "$REPO_URL"
    git config pull.rebase false
    echo "✅ Git repository initialized"
    
    # Try to checkout Update-1.0 branch first
    echo "🌿 Attempting to checkout $DEFAULT_BRANCH branch..."
    if git fetch origin "$DEFAULT_BRANCH" 2>/dev/null; then
        git checkout -b "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH" 2>/dev/null && echo "✅ $DEFAULT_BRANCH branch checked out" || {
            echo "⚠️  $DEFAULT_BRANCH branch checkout failed, trying $FALLBACK_BRANCH..."
            git checkout -b "$FALLBACK_BRANCH" "origin/$FALLBACK_BRANCH" 2>/dev/null && echo "✅ $FALLBACK_BRANCH branch checked out" || echo "❌ Failed to checkout any branch"
        }
    else
        echo "⚠️  $DEFAULT_BRANCH branch not found, trying $FALLBACK_BRANCH..."
        if git fetch origin "$FALLBACK_BRANCH" 2>/dev/null; then
            git checkout -b "$FALLBACK_BRANCH" "origin/$FALLBACK_BRANCH" 2>/dev/null && echo "✅ $FALLBACK_BRANCH branch checked out" || echo "❌ Failed to checkout $FALLBACK_BRANCH branch"
        else
            echo "❌ No branches available"
        fi
    fi
else
    echo "✅ Git repository already exists"
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "📋 Current branch: $CURRENT_BRANCH"
    
    # Try to update to Update-1.0 branch if not already on it
    if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
        echo "🌿 Attempting to switch to $DEFAULT_BRANCH branch..."
        if git fetch origin "$DEFAULT_BRANCH" 2>/dev/null && git checkout "$DEFAULT_BRANCH" 2>/dev/null; then
            echo "✅ Switched to $DEFAULT_BRANCH branch"
        else
            echo "⚠️  $DEFAULT_BRANCH branch not available, staying on $CURRENT_BRANCH"
        fi
    fi
fi

# Step 5: Copy application files
echo "📋 Copying application files..."

# Copy files from the git repository (Pi Zero directory)
if [ -d "Pi Zero" ]; then
    echo "📁 Copying from Pi Zero directory..."
    cp "Pi Zero/PiScript" ~/WRB/ 2>/dev/null && echo "✅ PiScript copied" || echo "❌ PiScript not found"
    cp "Pi Zero/config.py" ~/WRB/ 2>/dev/null && echo "✅ config.py copied" || echo "❌ config.py not found"
    cp "Pi Zero/monitor_system.py" ~/WRB/ 2>/dev/null && echo "✅ monitor_system.py copied" || echo "❌ monitor_system.py not found"
    cp "Pi Zero/requirements.txt" ~/WRB/ 2>/dev/null && echo "✅ requirements.txt copied" || echo "❌ requirements.txt not found"
    
    # Copy default sound files
    if [ -d "Pi Zero/default_sounds" ]; then
        echo "🎵 Copying default sound files..."
        cp "Pi Zero/default_sounds"/*.wav ~/WRB/sounds/ 2>/dev/null && echo "✅ Default sounds copied" || echo "⚠️  Could not copy default sounds"
    fi
else
    echo "⚠️  Pi Zero directory not found in repository, trying script directory..."
    # Fallback to script directory
    cp "$SCRIPT_DIR/PiScript" ~/WRB/ 2>/dev/null && echo "✅ PiScript copied" || echo "❌ PiScript not found"
    cp "$SCRIPT_DIR/config.py" ~/WRB/ 2>/dev/null && echo "✅ config.py copied" || echo "❌ config.py not found"
    cp "$SCRIPT_DIR/monitor_system.py" ~/WRB/ 2>/dev/null && echo "✅ monitor_system.py copied" || echo "❌ monitor_system.py not found"
    cp "$SCRIPT_DIR/requirements.txt" ~/WRB/ 2>/dev/null && echo "✅ requirements.txt copied" || echo "❌ requirements.txt not found"
    
    # Copy default sound files
    if [ -d "$SCRIPT_DIR/default_sounds" ]; then
        echo "🎵 Copying default sound files..."
        cp "$SCRIPT_DIR/default_sounds"/*.wav ~/WRB/sounds/ 2>/dev/null && echo "✅ Default sounds copied" || echo "⚠️  Could not copy default sounds"
    fi
fi

# Step 5: Set permissions
echo "🔐 Setting file permissions..."
chmod +x ~/WRB/PiScript 2>/dev/null && echo "✅ PiScript permissions set" || echo "⚠️  PiScript not found"
chmod +x ~/WRB/*.py 2>/dev/null && echo "✅ Python files permissions set" || echo "⚠️  No Python files found"

# Step 6: Install Python dependencies
echo "🐍 Installing Python dependencies..."
if pip3 install -r ~/WRB/requirements.txt 2>/dev/null; then
    echo "✅ Python packages installed via pip"
else
    echo "⚠️  pip install failed, trying apt packages..."
    sudo apt install -y python3-pygame python3-serial python3-gpiozero
    echo "✅ Python packages installed via apt"
fi

# Step 7: Audio setup
echo "🔊 Setting up audio..."
sudo usermod -a -G audio $USER

# Create ALSA configuration
cat > ~/.asoundrc << 'EOF'
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
EOF

# Step 8: Create sample sound files if none exist
echo "🎵 Checking for sound files..."
if [ ! -f ~/WRB/sounds/button1.wav ] || [ ! -f ~/WRB/sounds/button2.wav ] || [ ! -f ~/WRB/sounds/hold1.wav ] || [ ! -f ~/WRB/sounds/hold2.wav ]; then
    echo "📁 Creating sample sound files..."
    if [ ! -f ~/WRB/sounds/button1.wav ]; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/button1.wav synth 0.5 sine 800 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping sample sound creation"
    fi
    if [ ! -f ~/WRB/sounds/button2.wav ]; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/button2.wav synth 0.5 sine 400 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping sample sound creation"
    fi
    if [ ! -f ~/WRB/sounds/hold1.wav ]; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/hold1.wav synth 1.0 sine 1000 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping sample sound creation"
    fi
    if [ ! -f ~/WRB/sounds/hold2.wav ]; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/hold2.wav synth 1.0 sine 600 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping sample sound creation"
    fi
    echo "✅ Sample sound files created"
else
    echo "✅ Sound files already exist"
fi

# Step 9: Install systemd service
echo "⚙️ Installing systemd service..."
ACTUAL_USER=$(whoami)
echo "🔧 Using username: $ACTUAL_USER"

sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << EOF
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target sound.target

[Service]
Type=simple
User=$ACTUAL_USER
Group=audio
WorkingDirectory=/home/$ACTUAL_USER/WRB
Environment=HOME=/home/$ACTUAL_USER
Environment=USER=$ACTUAL_USER
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=pulse
ExecStart=/usr/bin/python3 /home/$ACTUAL_USER/WRB/PiScript
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Step 10: Enable and start service
echo "🚀 Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service
sudo systemctl start WRB-enhanced.service

# Step 11: Wait and check status
echo "⏳ Waiting for service to start..."
sleep 3

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""

# Check service status
echo "📊 Service Status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "🎉 WRB Pi system is now installed!"
echo ""

# Show branch information
CURRENT_BRANCH=$(cd ~/WRB && git branch --show-current 2>/dev/null || echo "unknown")
echo "🌿 Installed from branch: $CURRENT_BRANCH"
echo ""

echo "📋 Useful Commands:"
echo "  Check service:     sudo systemctl status WRB-enhanced.service"
echo "  View logs:         sudo journalctl -u WRB-enhanced.service -f"
echo "  Restart service:   sudo systemctl restart WRB-enhanced.service"
echo "  Test ESP32:        python3 ~/WRB/monitor_system.py"
echo "  Update system:     cd ~/WRB && git pull origin $CURRENT_BRANCH"
echo ""
echo "🎵 Sound Files: ~/WRB/sounds/"
echo "🔄 Reboot to test: sudo reboot"
echo ""
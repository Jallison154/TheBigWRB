#!/bin/bash
# Complete WRB Pi Installation Script
# This single script handles everything needed for installation

set -e  # Exit on any error

echo "=========================================="
echo "  WRB Pi Installation Script"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Auto-detect and navigate to the correct directory
if [ ! -f "PiScript" ]; then
    echo "🔍 PiScript not found in current directory, searching..."
    
    # Try common locations
    if [ -f "Pi Zero/PiScript" ]; then
        echo "📁 Found in Pi Zero subdirectory, navigating..."
        cd "Pi Zero"
    elif [ -f "../Pi Zero/PiScript" ]; then
        echo "📁 Found in parent Pi Zero directory, navigating..."
        cd "../Pi Zero"
    elif [ -f "~/TheBigWRB/Pi Zero/PiScript" ]; then
        echo "📁 Found in TheBigWRB directory, navigating..."
        cd "~/TheBigWRB/Pi Zero"
    else
        echo "❌ PiScript not found. Please run this from the Pi Zero directory or clone the repository first."
        echo "   Try: git clone https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB"
        exit 1
    fi
fi

echo "✅ Starting WRB Pi installation..."
echo ""

# Step 1: Update system
echo "📦 Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Step 2: Install required packages
echo "📦 Installing required packages..."
sudo apt install -y python3-pip python3-pygame python3-serial python3-gpiozero sox git alsa-utils python3-venv

# Step 3: Create directory structure
echo "📁 Creating directory structure..."
mkdir -p ~/WRB/sounds

# Step 4: Copy all files
echo "📋 Copying application files..."
cp PiScript ~/WRB/
cp config.py ~/WRB/
cp monitor_system.py ~/WRB/
cp test_esp32_connection.py ~/WRB/
cp test_system_integration.py ~/WRB/
cp requirements.txt ~/WRB/

# Step 5: Set permissions
echo "🔐 Setting file permissions..."
chmod +x ~/WRB/PiScript
chmod +x ~/WRB/*.py

# Step 6: Install Python dependencies
echo "🐍 Installing Python dependencies..."
# Try pip first, fall back to apt if externally managed environment
if ! pip3 install -r ~/WRB/requirements.txt 2>/dev/null; then
    echo "⚠️  pip install failed (externally managed environment detected)"
    echo "📦 Installing Python packages via apt instead..."
    
    # Install the specific packages we need via apt
    sudo apt install -y python3-pygame python3-serial python3-gpiozero
    
    # Check if pygame is working
    python3 -c "import pygame; print('pygame version:', pygame.version.ver)" 2>/dev/null || {
        echo "⚠️  pygame not found, trying alternative installation..."
        # Try using --break-system-packages as last resort
        pip3 install pygame --break-system-packages 2>/dev/null || echo "❌ Could not install pygame"
    }
    
    echo "✅ Python packages installed via apt"
else
    echo "✅ Python packages installed via pip"
fi

# Step 7: Audio setup
echo "🔊 Setting up audio..."
sudo usermod -a -G audio $USER

# Create ALSA configuration
# Remove any existing .asoundrc file or directory to prevent conflicts
rm -rf ~/.asoundrc
cat > ~/.asoundrc << 'EOF'
pcm.!default {
    type hw
    card 0
}
ctl.!default {
    type hw
    card 0
}
EOF

# Step 8: Install default sound files
echo "🎵 Installing default sound files..."
# Copy default sound files if they exist
if [ -d "default_sounds" ]; then
    echo "📁 Found default sound files, copying..."
    cp default_sounds/*.wav ~/WRB/sounds/ 2>/dev/null || echo "⚠️  Could not copy default sounds"
    echo "✅ Default sound files installed"
else
    echo "📁 No default sounds found, creating sample files..."
    # Fallback to creating sample sounds if default files not available
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
fi

# Step 9: Install systemd service
echo "⚙️ Installing systemd service..."
# Create service file with actual username
ACTUAL_USER=$(whoami)
echo "🔧 Using username: $ACTUAL_USER"

sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << EOF
[Unit]
Description=WRB Enhanced Audio System
After=network.target
Wants=network.target

[Service]
Type=simple
User=$ACTUAL_USER
Group=audio
WorkingDirectory=/home/$ACTUAL_USER/WRB
Environment=HOME=/home/$ACTUAL_USER
Environment=USER=$ACTUAL_USER
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=alsa
Environment=AUDIODEV=plughw:0,0
Environment=ALSA_CARD=0
Environment=ALSA_DEVICE=0
ExecStart=/usr/bin/python3 /home/$ACTUAL_USER/WRB/PiScript
Restart=always
RestartSec=5
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
echo "🎉 WRB Pi system is now installed and running!"
echo ""
echo "📋 Useful Commands:"
echo "  Check status: sudo systemctl status WRB-enhanced.service"
echo "  View logs:    sudo journalctl -u WRB-enhanced.service -f"
echo "  Restart:      sudo systemctl restart WRB-enhanced.service"
echo "  Stop:         sudo systemctl stop WRB-enhanced.service"
echo ""
echo "🔧 Testing Commands:"
echo "  Test ESP32:   python3 ~/WRB/test_esp32_connection.py"
echo "  System test:  python3 ~/WRB/test_system_integration.py"
echo "  Monitor:      python3 ~/WRB/monitor_system.py"
echo ""
echo "🎵 Sound Files:"
echo "  Location:     ~/WRB/sounds/"
echo "  Customize:    Replace button1*.wav, button2*.wav, hold1*.wav, hold2*.wav"
echo ""
echo "⚠️  IMPORTANT: You may need to reboot for audio group changes to take effect:"
echo "  sudo reboot"
echo ""
echo "🔧 If the service is still failing after reboot, run the audio fix:"
echo "  chmod +x fix_audio_device.sh && ./fix_audio_device.sh"
echo ""

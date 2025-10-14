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

# Check if we're in the right directory
if [ ! -f "PiScript" ]; then
    echo "❌ PiScript not found. Please run this from the Pi Zero directory."
    exit 1
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

# Step 8: Create sample sound files
echo "🎵 Creating sample sound files..."
if [ ! -f ~/WRB/sounds/button1.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/button1.wav synth 0.5 sine 800 fade h 0.1 0.1
fi
if [ ! -f ~/WRB/sounds/button2.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/button2.wav synth 0.5 sine 400 fade h 0.1 0.1
fi
if [ ! -f ~/WRB/sounds/hold1.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/hold1.wav synth 1.0 sine 1000 fade h 0.1 0.1
fi
if [ ! -f ~/WRB/sounds/hold2.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/hold2.wav synth 1.0 sine 600 fade h 0.1 0.1
fi

# Step 9: Install systemd service
echo "⚙️ Installing systemd service..."
sudo cp WRB-enhanced.service /etc/systemd/system/

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

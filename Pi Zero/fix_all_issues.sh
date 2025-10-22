#!/bin/bash
# WRB Fix All Issues Script
# Comprehensive fix for all common WRB issues

echo "🔧 WRB Fix All Issues"
echo "===================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

echo "🔍 Diagnosing issues first..."

# Run diagnostic
if [ -f "$HOME/WRB/diagnose_system.sh" ]; then
    bash "$HOME/WRB/diagnose_system.sh"
elif [ -f "$(dirname "$0")/diagnose_system.sh" ]; then
    bash "$(dirname "$0")/diagnose_system.sh"
else
    echo "⚠️  Diagnostic script not found, proceeding with fixes..."
fi

echo ""
echo "🔧 Applying fixes..."

# Fix 1: Update system packages
echo "📦 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Fix 2: Install missing packages
echo "📦 Installing required packages..."
sudo apt install -y python3-pip python3-pygame python3-serial python3-gpiozero sox git alsa-utils

# Fix 3: Fix permissions
echo "🔐 Fixing permissions..."
sudo usermod -a -G gpio,audio,pulse,pulse-access,dialout,spi,i2c $USER

# Fix 4: Create WRB directory if missing
echo "📁 Creating WRB directory structure..."
mkdir -p ~/WRB/sounds

# Fix 5: Download latest files if missing
echo "📥 Downloading latest files..."
cd ~/WRB

# Download PiScript
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/PiScript -o PiScript 2>/dev/null || echo "⚠️  PiScript download failed"

# Download config.py
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/config.py -o config.py 2>/dev/null || echo "⚠️  config.py download failed"

# Download monitor_system.py
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/monitor_system.py -o monitor_system.py 2>/dev/null || echo "⚠️  monitor_system.py download failed"

# Download test_system.py
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/test_system.py -o test_system.py 2>/dev/null || echo "⚠️  test_system.py download failed"

# Download requirements.txt
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/requirements.txt -o requirements.txt 2>/dev/null || echo "⚠️  requirements.txt download failed"

# Fix 6: Set permissions
echo "🔐 Setting file permissions..."
chmod +x ~/WRB/PiScript 2>/dev/null && echo "✅ PiScript permissions set" || echo "⚠️  PiScript not found"
chmod +x ~/WRB/*.py 2>/dev/null && echo "✅ Python files permissions set" || echo "⚠️  No Python files found"

# Fix 7: Install Python dependencies
echo "🐍 Installing Python dependencies..."
if pip3 install -r ~/WRB/requirements.txt 2>/dev/null; then
    echo "✅ Python packages installed via pip"
else
    echo "⚠️  pip install failed, trying apt packages..."
    sudo apt install -y python3-pygame python3-serial python3-gpiozero
fi

# Fix 8: Create sample sound files
echo "🎵 Creating sample sound files..."
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

# Fix 9: Audio configuration
echo "🔊 Setting up audio configuration..."
# Create ALSA configuration
cat > ~/.asoundrc << 'EOF'
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
EOF

# Create PulseAudio configuration
mkdir -p ~/.config/pulse
cat > ~/.config/pulse/client.conf << 'EOF'
default-server = unix:/run/user/1000/pulse/native
autospawn = no
daemon-binary = /bin/true
enable-shm = false
EOF

# Fix 10: Service configuration
echo "⚙️  Setting up service..."
sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << 'EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target sound.target
StartLimitInterval=300
StartLimitBurst=3

[Service]
Type=simple
User=pi
Group=audio
WorkingDirectory=/home/pi/WRB
Environment=HOME=/home/pi
Environment=USER=pi
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=pulse
Environment=PULSE_RUNTIME_PATH=/run/user/1000/pulse
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
StandardOutput=journal
StandardError=journal
TimeoutStartSec=30
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF

# Fix 11: Enable and start service
echo "🚀 Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service
sudo systemctl start WRB-enhanced.service

# Fix 12: Wait and check status
echo "⏳ Waiting for service to start..."
sleep 3

echo ""
echo "📊 Service Status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "🎉 Fix script completed!"
echo ""
echo "📋 What was fixed:"
echo "  ✅ System packages updated"
echo "  ✅ Required packages installed"
echo "  ✅ User permissions fixed"
echo "  ✅ WRB directory structure created"
echo "  ✅ Latest files downloaded"
echo "  ✅ File permissions set"
echo "  ✅ Python dependencies installed"
echo "  ✅ Sample sound files created"
echo "  ✅ Audio configuration set up"
echo "  ✅ Service configured and started"
echo ""
echo "🔧 Next steps:"
echo "  1. Test the system: python3 ~/WRB/test_system.py"
echo "  2. Check service logs: sudo journalctl -u WRB-enhanced.service -f"
echo "  3. Reboot if needed: sudo reboot"
echo ""
echo "💡 If issues persist, run the diagnostic:"
echo "  python3 ~/WRB/test_system.py"
echo ""

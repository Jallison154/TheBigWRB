#!/bin/bash
# WRB Issues Fix Script
# Fixes common issues with LED, USB, audio, and service problems

echo "🔧 WRB Issues Fix Script"
echo "========================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

echo "🔍 Diagnosing issues..."

# Fix 1: GPIO permissions
echo "🔌 Fixing GPIO permissions..."
sudo usermod -a -G gpio $USER
sudo usermod -a -G spi $USER
sudo usermod -a -G i2c $USER
echo "✅ GPIO permissions updated"

# Fix 2: Audio permissions
echo "🔊 Fixing audio permissions..."
sudo usermod -a -G audio $USER
sudo usermod -a -G pulse $USER
sudo usermod -a -G pulse-access $USER
echo "✅ Audio permissions updated"

# Fix 3: Serial permissions
echo "📡 Fixing serial permissions..."
sudo usermod -a -G dialout $USER
echo "✅ Serial permissions updated"

# Fix 4: USB mounting
echo "💾 Setting up USB mounting..."
sudo mkdir -p /media
sudo chmod 755 /media
echo "✅ USB mounting configured"

# Fix 5: Service configuration
echo "⚙️ Fixing service configuration..."
sudo systemctl daemon-reload
sudo systemctl stop WRB-enhanced.service 2>/dev/null || true
sudo systemctl disable WRB-enhanced.service 2>/dev/null || true

# Update service file
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

sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service
echo "✅ Service configuration updated"

# Fix 6: Audio configuration
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

echo "✅ Audio configuration updated"

# Fix 7: Create test sound files
echo "🎵 Creating test sound files..."
mkdir -p ~/WRB/sounds

# Create test sounds if they don't exist
if [ ! -f ~/WRB/sounds/button1.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/button1.wav synth 0.5 sine 800 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping test sound creation"
fi

if [ ! -f ~/WRB/sounds/button2.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/button2.wav synth 0.5 sine 400 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping test sound creation"
fi

if [ ! -f ~/WRB/sounds/hold1.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/hold1.wav synth 1.0 sine 1000 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping test sound creation"
fi

if [ ! -f ~/WRB/sounds/hold2.wav ]; then
    sox -n -r 44100 -c 2 ~/WRB/sounds/hold2.wav synth 1.0 sine 600 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available, skipping test sound creation"
fi

echo "✅ Test sound files created"

# Fix 8: Update PiScript
echo "📝 Updating PiScript..."
if [ -f ~/WRB/PiScript ]; then
    cp ~/WRB/PiScript ~/WRB/PiScript.backup
    echo "✅ PiScript backed up"
fi

# Copy updated PiScript
cp "$(dirname "$0")/PiScript" ~/WRB/ 2>/dev/null && echo "✅ PiScript updated" || echo "⚠️  PiScript update failed"

# Fix 9: Set permissions
echo "🔐 Setting file permissions..."
chmod +x ~/WRB/PiScript 2>/dev/null && echo "✅ PiScript permissions set" || echo "⚠️  PiScript not found"
chmod +x ~/WRB/*.py 2>/dev/null && echo "✅ Python files permissions set" || echo "⚠️  No Python files found"

# Fix 10: Test the system
echo "🧪 Testing the system..."
python3 ~/WRB/test_system.py

echo ""
echo "🎉 Fix script completed!"
echo ""
echo "📋 Next steps:"
echo "  1. Reboot the system: sudo reboot"
echo "  2. Check service status: sudo systemctl status WRB-enhanced.service"
echo "  3. Test the system: python3 ~/WRB/test_system.py"
echo "  4. Check logs: sudo journalctl -u WRB-enhanced.service -f"
echo ""
echo "🔧 If issues persist:"
echo "  - Check GPIO wiring (pins 23 and 24)"
echo "  - Verify ESP32 connection"
echo "  - Check sound files in ~/WRB/sounds/"
echo "  - Test with: python3 ~/WRB/PiScript"
echo ""

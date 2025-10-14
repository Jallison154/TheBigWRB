#!/bin/bash
# Audio Device Access Fix
# Run this to fix the ALSA audio device access issue

echo "=== Audio Device Access Fix ==="
echo ""

# Stop the failing service
echo "🛑 Stopping WRB-enhanced.service..."
sudo systemctl stop WRB-enhanced.service

# Add user to audio group (ensure it's done)
echo "👥 Adding user to audio group..."
sudo usermod -a -G audio $USER

# Set audio device permissions
echo "🔐 Setting audio device permissions..."
sudo chmod 666 /dev/snd/* 2>/dev/null || true

# Create proper ALSA configuration
echo "⚙️ Creating ALSA configuration..."
rm -rf ~/.asoundrc
cat > ~/.asoundrc << 'EOF'
pcm.!default {
    type hw
    card 0
    device 0
}
ctl.!default {
    type hw
    card 0
}
EOF

# Test audio device access
echo "🧪 Testing audio device access..."
if aplay -l >/dev/null 2>&1; then
    echo "✅ Audio device accessible via aplay"
else
    echo "⚠️  Audio device not accessible via aplay"
fi

# Check if user is in audio group
echo "👥 Checking user groups..."
groups $USER | grep -q audio && echo "✅ User is in audio group" || echo "⚠️  User not in audio group"

# Update the systemd service with better audio environment
echo "⚙️ Updating systemd service configuration..."
sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << 'EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target

[Service]
Type=simple
User=pi
Group=audio
WorkingDirectory=/home/pi/WRB
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=alsa
Environment=AUDIODEV=plughw:0,0
Environment=ALSA_CARD=0
Environment=ALSA_DEVICE=0
Environment=PYTHONPATH=/home/pi/WRB
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "🔄 Reloading systemd and starting service..."
sudo systemctl daemon-reload
sudo systemctl start WRB-enhanced.service

# Wait and check status
sleep 3
echo ""
echo "📊 Service Status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "🔧 Audio Device Fix Complete!"
echo ""
echo "If the service is still failing, try:"
echo "1. Reboot the Pi: sudo reboot"
echo "2. Check logs: sudo journalctl -u WRB-enhanced.service -f"
echo "3. Test audio manually: aplay -l && speaker-test -t wav -c 2"

#!/bin/bash
# Audio Device Fix Script for WRB-enhanced.service
# Run this on your Raspberry Pi to fix audio device access issues

echo "=== WRB Audio Device Fix ==="
echo ""

# Stop the failing service
echo "Stopping WRB-enhanced.service..."
sudo systemctl stop WRB-enhanced.service

# Add user to audio group
echo "Adding user to audio group..."
sudo usermod -a -G audio $USER

# Install audio utilities if not present
echo "Installing audio utilities..."
sudo apt update
sudo apt install -y alsa-utils pulseaudio-utils

# Set up audio device permissions
echo "Setting up audio device permissions..."
sudo chmod 666 /dev/snd/* 2>/dev/null || true

# Create ALSA configuration for the user
echo "Creating ALSA configuration..."
mkdir -p ~/.asoundrc
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

# Test audio devices
echo "Testing audio devices..."
echo "Available audio cards:"
cat /proc/asound/cards

echo ""
echo "Available audio devices:"
ls -la /dev/snd/

# Try to set default audio device
echo "Setting default audio device..."
if command -v aplay &> /dev/null; then
    echo "Testing audio with aplay..."
    aplay -l
else
    echo "aplay not available, trying alternative..."
fi

# Create a test sound file and play it
echo "Creating test sound..."
if command -v sox &> /dev/null; then
    sox -n -r 44100 -c 2 /tmp/test.wav synth 0.1 sine 440
    echo "Playing test sound..."
    aplay /tmp/test.wav 2>/dev/null || echo "Could not play test sound"
    rm -f /tmp/test.wav
else
    echo "sox not available for test sound creation"
fi

# Update the service to run with proper audio environment
echo "Updating systemd service with audio environment..."
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
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service
sudo systemctl start WRB-enhanced.service

# Wait a moment and check status
sleep 3
echo ""
echo "=== Service Status ==="
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "=== Audio Device Fix Complete ==="
echo ""
echo "If the service is still failing, try these additional steps:"
echo "1. Reboot the Pi: sudo reboot"
echo "2. Check audio devices after reboot: aplay -l"
echo "3. Test manual audio: speaker-test -t wav -c 2"
echo "4. Check logs: sudo journalctl -u WRB-enhanced.service -f"

#!/bin/bash
# Fix the WRB Service - Update to use correct script and GPIO 23

echo "🔧 Fixing WRB Service Configuration..."

# Get the actual username
ACTUAL_USER=$(whoami)
echo "👤 Detected user: $ACTUAL_USER"

# Stop the service first
echo "⏹️  Stopping service..."
sudo systemctl stop WRB-enhanced.service

# Update the service file to use correct script and GPIO 23
echo "📝 Updating service configuration..."
sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << 'SERVICE_EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target
Wants=network.target

[Service]
Type=simple
User=wrb01
Group=audio
WorkingDirectory=/home/wrb01/WRB
Environment=HOME=/home/wrb01
Environment=USER=wrb01
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=pulse
Environment=PULSE_RUNTIME_PATH=/run/user/1000/pulse
ExecStart=/usr/bin/python3 /home/wrb01/WRB/PiScript
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload systemd and restart service
echo "🔄 Reloading systemd configuration..."
sudo systemctl daemon-reload

echo "🚀 Starting service with corrected configuration..."
sudo systemctl start WRB-enhanced.service

# Wait a moment and check status
echo "⏳ Checking service status..."
sleep 2

echo ""
echo "📊 Service Status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "✅ Service fix complete!"
echo ""
echo "🔍 To monitor logs:"
echo "   sudo journalctl -u WRB-enhanced.service -f"
echo ""
echo "🎯 LED Configuration:"
echo "   GPIO 23 ←→ Ready LED (shows when service is running)"
echo "   GPIO 24 ←→ USB LED (shows when USB drive is mounted)"

#!/bin/bash

echo "🔧 Fixing systemd service file paths..."

# Fix the WRB-enhanced.service file
sudo tee /etc/systemd/system/WRB-enhanced.service > /dev/null << 'SERVICE_EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target sound.target
StartLimitInterval=60
StartLimitBurst=3

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
RestartSec=3
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE_EOF

# Reload systemd and restart the service
echo "🔄 Reloading systemd and restarting service..."
sudo systemctl daemon-reload
sudo systemctl restart WRB-enhanced.service

echo "✅ Service file fixed and service restarted"
echo "📊 Service status:"
systemctl status WRB-enhanced.service --no-pager -l

#!/bin/bash
# Fix for status=217/USER error
# This script addresses the most common causes of this error

echo "=== WRB Service User Fix ==="
echo ""

# Stop the failing service
echo "🛑 Stopping WRB-enhanced.service..."
sudo systemctl stop WRB-enhanced.service
sudo systemctl disable WRB-enhanced.service

# Remove the problematic service file
echo "🗑️ Removing old service file..."
sudo rm -f /etc/systemd/system/WRB-enhanced.service
sudo systemctl daemon-reload

# Check current user and groups
echo "👤 Current user information:"
echo "User: $(whoami)"
echo "UID: $(id -u)"
echo "Groups: $(groups)"
echo "Home: $HOME"

# Ensure user is in required groups
echo "👥 Adding user to required groups..."
sudo usermod -a -G audio,dialout $USER

# Create a simple, working service file
echo "⚙️ Creating new service file..."
sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << 'EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target
Wants=network.target

[Service]
Type=simple
User=pi
Group=audio
WorkingDirectory=/home/pi/WRB
Environment=HOME=/home/pi
Environment=USER=pi
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=SDL_AUDIODRIVER=alsa
Environment=AUDIODEV=plughw:0,0
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Set proper permissions
echo "🔐 Setting service file permissions..."
sudo chmod 644 /etc/systemd/system/WRB-enhanced.service

# Reload systemd
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start service
echo "🚀 Enabling and starting service..."
sudo systemctl enable WRB-enhanced.service
sudo systemctl start WRB-enhanced.service

# Wait and check status
sleep 3
echo ""
echo "📊 Service Status:"
sudo systemctl status WRB-enhanced.service --no-pager

# If still failing, try alternative approach
if ! sudo systemctl is-active --quiet WRB-enhanced.service; then
    echo ""
    echo "⚠️  Service still failing, trying alternative configuration..."
    
    # Create a user service instead
    echo "👤 Creating user service..."
    mkdir -p ~/.config/systemd/user
    
    cat > ~/.config/systemd/user/WRB-enhanced.service << 'EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target

[Service]
Type=simple
WorkingDirectory=/home/pi/WRB
Environment=SDL_AUDIODRIVER=alsa
Environment=AUDIODEV=plughw:0,0
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF
    
    # Enable user service
    systemctl --user daemon-reload
    systemctl --user enable WRB-enhanced.service
    systemctl --user start WRB-enhanced.service
    
    echo ""
    echo "📊 User Service Status:"
    systemctl --user status WRB-enhanced.service --no-pager
    
    echo ""
    echo "🔧 To enable user service on boot, run:"
    echo "   loginctl enable-linger $USER"
fi

echo ""
echo "🔧 Service User Fix Complete!"
echo ""
echo "📋 If the service is still failing:"
echo "1. Check logs: sudo journalctl -u WRB-enhanced.service -f"
echo "2. Test script manually: cd ~/WRB && python3 PiScript"
echo "3. Check file permissions: ls -la ~/WRB/PiScript"
echo "4. Verify user groups: groups $USER"

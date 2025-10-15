#!/bin/bash

echo "🔄 Updating PiScript and restarting service..."

# Copy the updated PiScript to the WRB directory
echo "📋 Copying updated PiScript..."
cp PiScript ~/WRB/

# Set permissions
chmod +x ~/WRB/PiScript

# Restart the service
echo "🔄 Restarting WRB-enhanced.service..."
sudo systemctl restart WRB-enhanced.service

# Wait a moment for startup
sleep 2

echo "📊 Service status:"
systemctl status WRB-enhanced.service --no-pager -l

echo ""
echo "📝 Recent logs:"
journalctl -u WRB-enhanced.service --no-pager -n 10

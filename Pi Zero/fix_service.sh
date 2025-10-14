#!/bin/bash
# Quick Fix Script for WRB-enhanced.service
# Run this on your Raspberry Pi to fix the service issue

echo "=== WRB Service Quick Fix ==="
echo ""

# Stop the failing service
echo "Stopping WRB-enhanced.service..."
sudo systemctl stop WRB-enhanced.service

# Create WRB directory if it doesn't exist
echo "Creating ~/WRB directory..."
mkdir -p ~/WRB
mkdir -p ~/WRB/sounds

# Copy files from the current directory (assuming we're in Pi Zero folder)
echo "Copying files to ~/WRB..."
cp PiScript ~/WRB/
cp config.py ~/WRB/
cp monitor_system.py ~/WRB/
cp test_esp32_connection.py ~/WRB/
cp test_system_integration.py ~/WRB/
cp test_usb_led.py ~/WRB/
cp verify_configuration.py ~/WRB/
cp requirements.txt ~/WRB/

# Make scripts executable
echo "Setting permissions..."
chmod +x ~/WRB/PiScript
chmod +x ~/WRB/*.py

# Install Python dependencies
echo "Installing Python dependencies..."
pip3 install -r ~/WRB/requirements.txt

# Copy service file
echo "Installing systemd service..."
sudo cp WRB-enhanced.service /etc/systemd/system/

# Reload systemd and start service
echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service
sudo systemctl start WRB-enhanced.service

# Check status
echo ""
echo "=== Service Status ==="
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "=== Fix Complete ==="
echo "If the service is still failing, check the logs with:"
echo "sudo journalctl -u WRB-enhanced.service -f"

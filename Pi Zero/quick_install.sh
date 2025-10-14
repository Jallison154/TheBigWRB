#!/bin/bash
# Quick Install Script for WRB Pi System
# This script downloads and runs the main installation script

echo "🚀 WRB Pi Quick Installer"
echo "=========================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "📦 Installing curl..."
    sudo apt update && sudo apt install -y curl
fi

echo "📥 Downloading and running installation script..."
echo ""

# Download and run the main installation script
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/main/Pi%20Zero/install.sh | bash

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📋 Next steps:"
echo "1. Connect your ESP32 receiver to the Pi via USB"
echo "2. Check service status: sudo systemctl status WRB-enhanced.service"
echo "3. View logs: sudo journalctl -u WRB-enhanced.service -f"
echo "4. Test with your ESP32 transmitter buttons"
echo ""
echo "🔧 If you encounter issues, try:"
echo "   sudo reboot"
echo "   # Then check service status again"

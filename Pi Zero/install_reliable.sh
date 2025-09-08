#!/bin/bash
# Reliable Pi Script Installation for ESP32 Wireless Button System

echo "=== ESP32 Wireless Button System - Reliable Pi Script Installer ==="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p ~/WRB
mkdir -p ~/WRB/sounds

# Install Python dependencies
echo "Installing Python dependencies..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-pygame python3-serial python3-gpiozero

# Install pygame if not already installed
pip3 install pygame

# Copy the reliable script and supporting files
echo "Installing reliable Pi script and supporting files..."
cp Pi_Script_Reliable.py ~/WRB/
cp monitor_system.py ~/WRB/
chmod +x ~/WRB/Pi_Script_Reliable.py
chmod +x ~/WRB/monitor_system.py

# Install systemd service
echo "Installing systemd service..."
sudo cp WRB-enhanced.service /etc/systemd/system/
sudo systemctl daemon-reload

# Set up audio permissions
echo "Setting up audio permissions..."
sudo usermod -a -G audio pi

# Create sample sound files (if they don't exist)
echo "Setting up sample sound files..."
if [ ! -f ~/WRB/sounds/button1.wav ]; then
    echo "Creating sample button1 sound file..."
    # Create a simple beep sound using sox if available
    if command -v sox &> /dev/null; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/button1.wav synth 0.5 sine 800
    else
        echo "sox not found. Please install sox or add your own button1.wav file to ~/WRB/sounds/"
    fi
fi

if [ ! -f ~/WRB/sounds/button2.wav ]; then
    echo "Creating sample button2 sound file..."
    if command -v sox &> /dev/null; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/button2.wav synth 0.5 sine 400
    else
        echo "sox not found. Please install sox or add your own button2.wav file to ~/WRB/sounds/"
    fi
fi

if [ ! -f ~/WRB/sounds/hold1.wav ]; then
    echo "Creating sample hold1 sound file..."
    if command -v sox &> /dev/null; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/hold1.wav synth 1.0 sine 600
    else
        echo "sox not found. Please install sox or add your own hold1.wav file to ~/WRB/sounds/"
    fi
fi

if [ ! -f ~/WRB/sounds/hold2.wav ]; then
    echo "Creating sample hold2 sound file..."
    if command -v sox &> /dev/null; then
        sox -n -r 44100 -c 2 ~/WRB/sounds/hold2.wav synth 1.0 sine 500
    else
        echo "sox not found. Please install sox or add your own hold2.wav file to ~/WRB/sounds/"
    fi
fi

# Create log files
touch ~/WRB/button_log.txt
touch ~/WRB/health_log.txt

# Set permissions
chmod 755 ~/WRB
chmod 644 ~/WRB/*.py
chmod 644 ~/WRB/*.txt

# Enable and start service
echo "Enabling and starting service..."
sudo systemctl enable WRB-enhanced.service
sudo systemctl start WRB-enhanced.service

# Check service status
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Service status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "=== Reliability Features Installed ==="
echo "✅ Comprehensive error handling and logging"
echo "✅ Automatic serial connection recovery"
echo "✅ Health monitoring and statistics"
echo "✅ Graceful shutdown handling"
echo "✅ Audio system robustness"
echo "✅ Resource management and cleanup"
echo "✅ Security event logging"
echo "✅ USB hot-swapping support"

echo ""
echo "=== Usage Instructions ==="
echo "1. Connect your ESP32 receiver to the Pi via USB"
echo "2. The service will automatically start and look for the ESP32"
echo "3. Press buttons on your ESP32 transmitters to trigger sounds"
echo "4. Monitor system health with: python3 ~/WRB/monitor_system.py"

echo ""
echo "=== Useful Commands ==="
echo "Check service status: sudo systemctl status WRB-enhanced.service"
echo "View logs: sudo journalctl -u WRB-enhanced.service -f"
echo "Restart service: sudo systemctl restart WRB-enhanced.service"
echo "Stop service: sudo systemctl stop WRB-enhanced.service"
echo "Monitor system: python3 ~/WRB/monitor_system.py"
echo "View button logs: tail -f ~/WRB/button_log.txt"
echo "View health logs: tail -f ~/WRB/health_log.txt"

echo ""
echo "=== Sound Files ==="
echo "Place your sound files in ~/WRB/sounds/"
echo "- button1*.wav for Button 1 quick press sounds"
echo "- button2*.wav for Button 2 quick press sounds"
echo "- hold1*.wav for Button 1 hold sounds"
echo "- hold2*.wav for Button 2 hold sounds"
echo "Or use a USB drive with button1*.wav, button2*.wav, hold1*.wav, hold2*.wav files"

echo ""
echo "=== Logging ==="
echo "Button press logs: ~/WRB/button_log.txt"
echo "Health statistics: ~/WRB/health_log.txt"
echo "System logs: sudo journalctl -u WRB-enhanced.service -f"

echo ""
echo "=== Reliability Features ==="
echo "• Automatic reconnection if ESP32 disconnects"
echo "• Comprehensive error logging and recovery"
echo "• Health monitoring every 30 seconds"
echo "• Graceful handling of audio failures"
echo "• Resource cleanup and memory management"
echo "• Signal handling for clean shutdowns"
echo "• USB drive hot-swapping support"
echo "• Security event monitoring"

echo ""
echo "Installation complete! Your reliable ESP32 button system is ready."

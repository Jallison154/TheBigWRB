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
mkdir -p ~/mattsfx
mkdir -p ~/mattsfx/sounds

# Install Python dependencies
echo "Installing Python dependencies..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-pygame python3-serial python3-gpiozero

# Install pygame if not already installed
pip3 install pygame

# Copy the reliable script and supporting files
echo "Installing reliable Pi script and supporting files..."
cp Pi_Script_Reliable.py ~/mattsfx/
cp monitor_system.py ~/mattsfx/
chmod +x ~/mattsfx/Pi_Script_Reliable.py
chmod +x ~/mattsfx/monitor_system.py

# Install systemd service
echo "Installing systemd service..."
sudo cp mattsfx-enhanced.service /etc/systemd/system/
sudo systemctl daemon-reload

# Set up audio permissions
echo "Setting up audio permissions..."
sudo usermod -a -G audio pi

# Create sample sound files (if they don't exist)
echo "Setting up sample sound files..."
if [ ! -f ~/mattsfx/sounds/right1.wav ]; then
    echo "Creating sample right sound file..."
    # Create a simple beep sound using sox if available
    if command -v sox &> /dev/null; then
        sox -n -r 44100 -c 2 ~/mattsfx/sounds/right1.wav synth 0.5 sine 800
    else
        echo "sox not found. Please install sox or add your own right1.wav file to ~/mattsfx/sounds/"
    fi
fi

if [ ! -f ~/mattsfx/sounds/wrong1.wav ]; then
    echo "Creating sample wrong sound file..."
    if command -v sox &> /dev/null; then
        sox -n -r 44100 -c 2 ~/mattsfx/sounds/wrong1.wav synth 0.5 sine 400
    else
        echo "sox not found. Please install sox or add your own wrong1.wav file to ~/mattsfx/sounds/"
    fi
fi

# Create log files
touch ~/mattsfx/button_log.txt
touch ~/mattsfx/health_log.txt

# Set permissions
chmod 755 ~/mattsfx
chmod 644 ~/mattsfx/*.py
chmod 644 ~/mattsfx/*.txt

# Enable and start service
echo "Enabling and starting service..."
sudo systemctl enable mattsfx-enhanced.service
sudo systemctl start mattsfx-enhanced.service

# Check service status
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Service status:"
sudo systemctl status mattsfx-enhanced.service --no-pager

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
echo "4. Monitor system health with: python3 ~/mattsfx/monitor_system.py"

echo ""
echo "=== Useful Commands ==="
echo "Check service status: sudo systemctl status mattsfx-enhanced.service"
echo "View logs: sudo journalctl -u mattsfx-enhanced.service -f"
echo "Restart service: sudo systemctl restart mattsfx-enhanced.service"
echo "Stop service: sudo systemctl stop mattsfx-enhanced.service"
echo "Monitor system: python3 ~/mattsfx/monitor_system.py"
echo "View button logs: tail -f ~/mattsfx/button_log.txt"
echo "View health logs: tail -f ~/mattsfx/health_log.txt"

echo ""
echo "=== Sound Files ==="
echo "Place your sound files in ~/mattsfx/sounds/"
echo "- right1.wav, right2.wav, etc. for correct answers"
echo "- wrong1.wav, wrong2.wav, etc. for incorrect answers"
echo "Or use a USB drive with right*.wav and wrong*.wav files"

echo ""
echo "=== Logging ==="
echo "Button press logs: ~/mattsfx/button_log.txt"
echo "Health statistics: ~/mattsfx/health_log.txt"
echo "System logs: sudo journalctl -u mattsfx-enhanced.service -f"

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

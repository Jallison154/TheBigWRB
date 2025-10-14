#!/bin/bash

# WRB Pi Setup Script
# Run this on your Pi Zero after fresh install

echo "=== WRB Pi Setup Script ==="

# Update system
echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y python3-pygame python3-serial python3-gpiozero python3-pip

# Install Python dependencies from requirements.txt
echo "Installing Python dependencies..."
pip3 install -r requirements.txt

# Create directory structure
echo "Creating directory structure..."
mkdir -p ~/WRB/sounds

# Copy the main PiScript and supporting files
echo "Copying PiScript and supporting files..."
cp PiScript ~/WRB/
cp config.py ~/WRB/
cp monitor_system.py ~/WRB/
cp test_esp32_connection.py ~/WRB/
cp test_system_integration.py ~/WRB/
cp test_usb_led.py ~/WRB/
cp verify_configuration.py ~/WRB/
cp requirements.txt ~/WRB/

# Make all scripts executable
chmod +x ~/WRB/PiScript
chmod +x ~/WRB/*.py

# Create the systemd service file
echo "Creating systemd service..."
sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << 'EOF'
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=/home/pi/WRB
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=alsa
Environment=AUDIODEV=plughw:0,0
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Create sample sound files
echo "Creating sample sound files..."
sudo apt install -y sox

# Create sample button sounds
sox -n -r 44100 -c 2 ~/WRB/sounds/button1.wav synth 0.5 sine 800 fade h 0.1 0.1
sox -n -r 44100 -c 2 ~/WRB/sounds/button2.wav synth 0.5 sine 400 fade h 0.1 0.1
sox -n -r 44100 -c 2 ~/WRB/sounds/hold1.wav synth 1.0 sine 1000 fade h 0.1 0.1
sox -n -r 44100 -c 2 ~/WRB/sounds/hold2.wav synth 1.0 sine 600 fade h 0.1 0.1

# Reload systemd and enable service
echo "Setting up systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable WRB-enhanced.service

# Add pi user to audio group
sudo usermod -a -G audio pi

echo "=== Setup Complete! ==="
echo ""
echo "To start the service:"
echo "  sudo systemctl start WRB-enhanced.service"
echo ""
echo "To check status:"
echo "  sudo systemctl status WRB-enhanced.service"
echo ""
echo "To view logs:"
echo "  journalctl -u WRB-enhanced.service -f"
echo ""
echo "To test manually:"
echo "  cd ~/WRB && python3 PiScript"
echo ""
echo "Sample sound files created in ~/WRB/sounds/"
echo "Replace with your own button1*.wav, button2*.wav, hold1*.wav, hold2*.wav files"

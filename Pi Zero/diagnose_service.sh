#!/bin/bash
# Service Diagnostic Script
# Run this to identify the exact cause of service failures

echo "=== WRB Service Diagnostic ==="
echo ""

# Check current user
echo "👤 User Information:"
echo "Current user: $(whoami)"
echo "User ID: $(id -u)"
echo "Primary group: $(id -gn)"
echo "Groups: $(groups)"
echo "Home directory: $HOME"
echo ""

# Check if files exist and permissions
echo "📁 File Check:"
if [ -f "/home/pi/WRB/PiScript" ]; then
    echo "✅ PiScript exists"
    ls -la /home/pi/WRB/PiScript
else
    echo "❌ PiScript not found at /home/pi/WRB/PiScript"
fi

if [ -f "/home/pi/WRB/config.py" ]; then
    echo "✅ config.py exists"
else
    echo "❌ config.py not found"
fi

echo ""

# Check directory permissions
echo "📂 Directory Permissions:"
if [ -d "/home/pi/WRB" ]; then
    echo "✅ WRB directory exists"
    ls -la /home/pi/WRB/
else
    echo "❌ WRB directory not found"
fi

echo ""

# Check Python and dependencies
echo "🐍 Python Check:"
echo "Python3 path: $(which python3)"
echo "Python3 version: $(python3 --version)"

# Test Python imports
echo "Testing Python imports..."
python3 -c "
try:
    import pygame
    print('✅ pygame imported successfully')
except ImportError as e:
    print('❌ pygame import failed:', e)

try:
    import serial
    print('✅ pyserial imported successfully')
except ImportError as e:
    print('❌ pyserial import failed:', e)

try:
    from gpiozero import LED
    print('✅ gpiozero imported successfully')
except ImportError as e:
    print('❌ gpiozero import failed:', e)
"

echo ""

# Check audio devices
echo "🔊 Audio Check:"
echo "Audio devices:"
ls -la /dev/snd/ 2>/dev/null || echo "❌ No audio devices found"

echo "ALSA cards:"
cat /proc/asound/cards 2>/dev/null || echo "❌ No ALSA cards found"

echo ""

# Check service file
echo "⚙️ Service File Check:"
if [ -f "/etc/systemd/system/WRB-enhanced.service" ]; then
    echo "✅ Service file exists"
    echo "Service file contents:"
    cat /etc/systemd/system/WRB-enhanced.service
else
    echo "❌ Service file not found"
fi

echo ""

# Check service status
echo "📊 Service Status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""

# Check service logs
echo "📋 Recent Service Logs:"
sudo journalctl -u WRB-enhanced.service --no-pager -n 20

echo ""

# Test manual script execution
echo "🧪 Manual Script Test:"
echo "Attempting to run PiScript manually..."
cd /home/pi/WRB 2>/dev/null && timeout 10 python3 PiScript 2>&1 | head -10 || echo "❌ Manual execution failed or timed out"

echo ""
echo "=== Diagnostic Complete ==="
echo ""
echo "🔧 Common fixes based on results:"
echo "1. If files missing: Re-run installation script"
echo "2. If Python imports fail: Install packages via apt"
echo "3. If audio issues: Run audio fix script"
echo "4. If user issues: Run service user fix script"

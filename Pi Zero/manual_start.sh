#!/bin/bash
# Manual WRB Start Script - For debugging service issues

echo "=========================================="
echo "  WRB Manual Start Script"
echo "=========================================="
echo ""

# Get current user
ACTUAL_USER=$(whoami)
echo "🔍 Current user: $ACTUAL_USER"
echo ""

# Check if we're in the right directory
if [ ! -f "PiScript" ]; then
    echo "❌ PiScript not found in current directory"
    echo "   Please run this script from the Pi Zero directory"
    exit 1
fi

# Check if WRB directory exists
if [ ! -d "/home/$ACTUAL_USER/WRB" ]; then
    echo "❌ WRB directory missing, creating it..."
    mkdir -p "/home/$ACTUAL_USER/WRB"
    mkdir -p "/home/$ACTUAL_USER/WRB/sounds"
fi

# Copy files if missing
echo "📋 Ensuring files are in place..."
if [ ! -f "/home/$ACTUAL_USER/WRB/PiScript" ]; then
    cp PiScript "/home/$ACTUAL_USER/WRB/"
    chmod +x "/home/$ACTUAL_USER/WRB/PiScript"
    echo "✅ PiScript copied"
fi

if [ ! -f "/home/$ACTUAL_USER/WRB/config.py" ]; then
    cp config.py "/home/$ACTUAL_USER/WRB/"
    echo "✅ config.py copied"
fi

# Set permissions
chmod +x "/home/$ACTUAL_USER/WRB/PiScript"
chown -R "$ACTUAL_USER:$ACTUAL_USER" "/home/$ACTUAL_USER/WRB"

echo ""
echo "🔍 Pre-flight checks..."
echo "   WRB directory: $(ls -la /home/$ACTUAL_USER/WRB/)"
echo "   User groups: $(groups $ACTUAL_USER)"
echo "   Audio group: $(groups $ACTUAL_USER | grep -o audio || echo 'Not in audio group')"

echo ""
echo "🐍 Testing Python dependencies..."
python3 -c "import pygame; print('✅ pygame available')" 2>/dev/null || echo "❌ pygame not available"
python3 -c "import serial; print('✅ serial available')" 2>/dev/null || echo "❌ serial not available"
python3 -c "from gpiozero import LED; print('✅ gpiozero available')" 2>/dev/null || echo "❌ gpiozero not available"

echo ""
echo "🚀 Starting WRB manually..."
echo "   This will run the PiScript directly to test if it works"
echo "   Press Ctrl+C to stop"
echo ""

# Change to WRB directory and run PiScript
cd "/home/$ACTUAL_USER/WRB"
python3 PiScript

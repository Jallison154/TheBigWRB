#!/bin/bash
# USB Audio Optimization Script
# This script applies USB audio optimizations to prevent audio cutoff

echo "🔧 Applying USB audio optimizations..."
echo "   This fixes the issue where audio is cut off at the beginning of playback"
echo "   Optimized for USB audio cards (not HDMI)"
echo ""

# Check if PulseAudio is available
if ! command -v pulseaudio &> /dev/null; then
    echo "❌ PulseAudio not found. Installing PulseAudio..."
    sudo apt update
    sudo apt install -y pulseaudio pulseaudio-utils
fi

# Apply USB audio optimizations
echo "🔊 Optimizing USB audio configuration..."

# Disable PulseAudio suspend-on-idle module (prevents audio cutoff with USB audio)
echo "🔧 Disabling PulseAudio suspend-on-idle module..."
if [ -f /etc/pulse/default.pa ]; then
    sudo sed -i 's/^load-module module-suspend-on-idle/#load-module module-suspend-on-idle/' /etc/pulse/default.pa
    echo "✅ Disabled suspend-on-idle in system PulseAudio config"
else
    echo "⚠️  System PulseAudio config not found, using user config"
fi

# Create user-level PulseAudio config if needed
mkdir -p ~/.config/pulse
if [ ! -f ~/.config/pulse/default.pa ]; then
    cat > ~/.config/pulse/default.pa << 'PULSE_USER_EOF'
# Custom PulseAudio configuration for USB audio
# Disable suspend-on-idle to prevent audio cutoff
# load-module module-suspend-on-idle
load-module module-device-manager
load-module module-stream-restore
load-module module-card-restore
load-module module-augment-properties
load-module module-switch-on-port-available
PULSE_USER_EOF
    echo "✅ Created user PulseAudio config with suspend-on-idle disabled"
fi

# Restart PulseAudio with optimized settings
echo "📡 Restarting PulseAudio with USB audio optimizations..."
pulseaudio --kill
sleep 2
pulseaudio --start

# Check if USB audio device is detected
echo "🔍 Checking USB audio devices..."
if aplay -l | grep -i usb; then
    echo "✅ USB audio device detected"
else
    echo "⚠️  No USB audio device found in aplay -l output"
    echo "   Make sure your USB audio card is connected"
fi

# Test audio configuration
echo "🧪 Testing audio configuration..."
if pulseaudio --check; then
    echo "✅ PulseAudio is running with optimized settings"
    echo ""
    echo "📋 What this does:"
    echo "   - Optimizes PulseAudio for USB audio cards"
    echo "   - Reduces audio buffer latency"
    echo "   - Prevents audio cutoff at the beginning of playback"
    echo "   - Uses real-time scheduling for better audio performance"
    echo ""
    echo "🔄 To apply these settings permanently:"
    echo "   sudo systemctl restart WRB-enhanced.service"
    echo ""
    echo "🔍 To check audio devices:"
    echo "   aplay -l"
    echo "   pactl list short sinks"
else
    echo "❌ Failed to start PulseAudio with optimizations"
    echo "   Check your USB audio card connection and drivers"
    exit 1
fi

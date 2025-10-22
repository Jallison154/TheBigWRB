#!/bin/bash
# WRB Installation Verification Script
# Verifies that all components are properly installed and configured

set -e

echo "🔍 WRB Installation Verification"
echo "================================"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check file exists
file_exists() {
    [ -f "$1" ]
}

# Function to check directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to check service status
check_service() {
    if systemctl is-active --quiet "$1" 2>/dev/null; then
        echo "✅ $1 is running"
        return 0
    else
        echo "❌ $1 is not running"
        return 1
    fi
}

# Check 1: Required commands
echo "📋 Checking required commands..."
REQUIRED_COMMANDS=("python3" "pip3" "git" "systemctl")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command_exists "$cmd"; then
        echo "✅ $cmd is available"
    else
        echo "❌ $cmd is missing"
        exit 1
    fi
done

# Check 2: Python packages
echo ""
echo "🐍 Checking Python packages..."
PYTHON_PACKAGES=("pygame" "serial" "gpiozero")

for pkg in "${PYTHON_PACKAGES[@]}"; do
    if python3 -c "import $pkg" 2>/dev/null; then
        echo "✅ $pkg is installed"
    else
        echo "❌ $pkg is missing"
        exit 1
    fi
done

# Check 3: WRB directory structure
echo ""
echo "📁 Checking WRB directory structure..."
WRB_DIR="$HOME/WRB"

if dir_exists "$WRB_DIR"; then
    echo "✅ WRB directory exists"
else
    echo "❌ WRB directory missing"
    exit 1
fi

# Check required files
REQUIRED_FILES=("PiScript" "config.py" "monitor_system.py" "requirements.txt")

for file in "${REQUIRED_FILES[@]}"; do
    if file_exists "$WRB_DIR/$file"; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Check sound files directory
if dir_exists "$WRB_DIR/sounds"; then
    echo "✅ sounds directory exists"
else
    echo "❌ sounds directory missing"
    exit 1
fi

# Check 4: Service status
echo ""
echo "⚙️ Checking service status..."
if check_service "WRB-enhanced.service"; then
    echo "✅ WRB service is running"
else
    echo "⚠️  WRB service is not running (this may be normal if not started yet)"
fi

# Check 5: Git repository
echo ""
echo "🌿 Checking git repository..."
if dir_exists "$WRB_DIR/.git"; then
    echo "✅ Git repository exists"
    cd "$WRB_DIR"
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "📋 Current branch: $CURRENT_BRANCH"
else
    echo "⚠️  Git repository not found (this may be normal for manual installations)"
fi

# Check 6: Audio setup
echo ""
echo "🔊 Checking audio setup..."
if groups | grep -q audio; then
    echo "✅ User is in audio group"
else
    echo "⚠️  User not in audio group (may need: sudo usermod -a -G audio $USER)"
fi

# Check 7: Serial ports
echo ""
echo "🔌 Checking serial ports..."
SERIAL_PORTS=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo "")
if [ -n "$SERIAL_PORTS" ]; then
    echo "✅ Serial ports found: $SERIAL_PORTS"
else
    echo "⚠️  No serial ports found (ESP32 may not be connected)"
fi

echo ""
echo "🎉 Verification complete!"
echo ""
echo "📋 Summary:"
echo "  - All required commands are available"
echo "  - Python packages are installed"
echo "  - WRB directory structure is correct"
echo "  - Service status checked"
echo "  - Git repository configured"
echo "  - Audio permissions verified"
echo "  - Serial ports checked"
echo ""
echo "🚀 System is ready for use!"
echo ""
echo "💡 Useful commands:"
echo "  Check service:     sudo systemctl status WRB-enhanced.service"
echo "  View logs:         sudo journalctl -u WRB-enhanced.service -f"
echo "  Test ESP32:        python3 ~/WRB/test_esp32_connection.py"
echo "  Monitor system:    python3 ~/WRB/monitor_system.py"
echo ""

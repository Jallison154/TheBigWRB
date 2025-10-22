#!/bin/bash
# WRB System Diagnostic Script
# Comprehensive system diagnosis to identify all issues

echo "🔍 WRB System Diagnostic"
echo "======================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Function to check command exists
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

echo "📋 System Information:"
echo "  User: $(whoami)"
echo "  Home: $HOME"
echo "  Date: $(date)"
echo ""

# Check 1: Basic system requirements
echo "🔧 Checking system requirements..."
REQUIRED_COMMANDS=("python3" "pip3" "git" "systemctl" "sudo")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command_exists "$cmd"; then
        echo "✅ $cmd is available"
    else
        echo "❌ $cmd is missing"
    fi
done
echo ""

# Check 2: WRB directory structure
echo "📁 Checking WRB directory structure..."
WRB_DIR="$HOME/WRB"

if dir_exists "$WRB_DIR"; then
    echo "✅ WRB directory exists: $WRB_DIR"
    
    # Check required files
    REQUIRED_FILES=("PiScript" "config.py" "monitor_system.py" "requirements.txt")
    
    for file in "${REQUIRED_FILES[@]}"; do
        if file_exists "$WRB_DIR/$file"; then
            echo "✅ $file exists"
        else
            echo "❌ $file missing"
        fi
    done
    
    # Check sounds directory
    if dir_exists "$WRB_DIR/sounds"; then
        echo "✅ sounds directory exists"
        SOUND_COUNT=$(find "$WRB_DIR/sounds" -name "*.wav" | wc -l)
        echo "📊 Found $SOUND_COUNT sound files"
    else
        echo "❌ sounds directory missing"
    fi
else
    echo "❌ WRB directory not found: $WRB_DIR"
fi
echo ""

# Check 3: Python packages
echo "🐍 Checking Python packages..."
PYTHON_PACKAGES=("pygame" "serial" "gpiozero")

for pkg in "${PYTHON_PACKAGES[@]}"; do
    if python3 -c "import $pkg" 2>/dev/null; then
        echo "✅ $pkg is installed"
    else
        echo "❌ $pkg is missing"
    fi
done
echo ""

# Check 4: Service status
echo "⚙️ Checking service status..."
if systemctl is-active --quiet WRB-enhanced.service 2>/dev/null; then
    echo "✅ WRB-enhanced.service is running"
else
    echo "❌ WRB-enhanced.service is not running"
    
    # Check if service exists
    if systemctl list-unit-files | grep -q WRB-enhanced.service; then
        echo "📋 Service exists but not running"
        echo "📊 Service status:"
        systemctl status WRB-enhanced.service --no-pager
    else
        echo "❌ WRB-enhanced.service not found"
    fi
fi
echo ""

# Check 5: GPIO permissions
echo "🔌 Checking GPIO permissions..."
if groups | grep -q gpio; then
    echo "✅ User is in gpio group"
else
    echo "❌ User not in gpio group"
fi

if groups | grep -q audio; then
    echo "✅ User is in audio group"
else
    echo "❌ User not in audio group"
fi

if groups | grep -q dialout; then
    echo "✅ User is in dialout group"
else
    echo "❌ User not in dialout group"
fi
echo ""

# Check 6: Serial ports
echo "📡 Checking serial ports..."
SERIAL_PORTS=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo "")
if [ -n "$SERIAL_PORTS" ]; then
    echo "✅ Serial ports found: $SERIAL_PORTS"
else
    echo "❌ No serial ports found (ESP32 may not be connected)"
fi
echo ""

# Check 7: Audio system
echo "🔊 Checking audio system..."
if command_exists aplay; then
    echo "✅ aplay is available"
else
    echo "❌ aplay not found"
fi

if command_exists speaker-test; then
    echo "✅ speaker-test is available"
else
    echo "❌ speaker-test not found"
fi

# Test audio device
if aplay -l >/dev/null 2>&1; then
    echo "✅ Audio device detected"
else
    echo "❌ No audio device detected"
fi
echo ""

# Check 8: USB mounting
echo "💾 Checking USB mounting..."
if dir_exists "/media"; then
    echo "✅ /media directory exists"
    USB_COUNT=$(find /media -maxdepth 1 -type d 2>/dev/null | wc -l)
    echo "📊 Found $USB_COUNT mounted devices"
else
    echo "❌ /media directory not found"
fi
echo ""

# Check 9: Git repository
echo "🌿 Checking git repository..."
if dir_exists "$WRB_DIR/.git"; then
    echo "✅ Git repository exists"
    cd "$WRB_DIR"
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    echo "📋 Current branch: $CURRENT_BRANCH"
    
    # Check for updates
    git fetch origin 2>/dev/null
    if git status -uno | grep -q "Your branch is behind"; then
        echo "⚠️  Updates available"
    else
        echo "✅ Repository is up to date"
    fi
else
    echo "❌ Git repository not found"
fi
echo ""

# Check 10: Recent logs
echo "📋 Checking recent logs..."
if systemctl is-active --quiet WRB-enhanced.service 2>/dev/null; then
    echo "📊 Recent service logs:"
    journalctl -u WRB-enhanced.service --no-pager -n 10
else
    echo "⚠️  Service not running, no recent logs"
fi
echo ""

# Check 11: Test Python script
echo "🧪 Testing Python script..."
if file_exists "$WRB_DIR/PiScript"; then
    if python3 -m py_compile "$WRB_DIR/PiScript" 2>/dev/null; then
        echo "✅ PiScript syntax is valid"
    else
        echo "❌ PiScript has syntax errors"
    fi
else
    echo "❌ PiScript not found"
fi
echo ""

# Summary
echo "📊 Diagnostic Summary:"
echo "====================="
echo ""

# Count issues
ISSUES=0

# Check for common issues
if ! systemctl is-active --quiet WRB-enhanced.service 2>/dev/null; then
    echo "❌ Service not running"
    ISSUES=$((ISSUES + 1))
fi

if ! groups | grep -q gpio; then
    echo "❌ GPIO permissions missing"
    ISSUES=$((ISSUES + 1))
fi

if ! groups | grep -q audio; then
    echo "❌ Audio permissions missing"
    ISSUES=$((ISSUES + 1))
fi

if [ -z "$SERIAL_PORTS" ]; then
    echo "❌ No serial ports found"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -d "$WRB_DIR/sounds" ] || [ $(find "$WRB_DIR/sounds" -name "*.wav" 2>/dev/null | wc -l) -eq 0 ]; then
    echo "❌ No sound files found"
    ISSUES=$((ISSUES + 1))
fi

echo ""
if [ $ISSUES -eq 0 ]; then
    echo "🎉 No major issues found!"
    echo "💡 Try running: python3 ~/WRB/test_system.py"
else
    echo "⚠️  Found $ISSUES issues that need attention"
    echo ""
    echo "🔧 Recommended fixes:"
    echo "  1. Run: ~/WRB/fix_issues.sh"
    echo "  2. Or: sudo systemctl restart WRB-enhanced.service"
    echo "  3. Or: python3 ~/WRB/test_system.py"
fi

echo ""
echo "💡 For more detailed testing, run:"
echo "  python3 ~/WRB/test_system.py"
echo ""

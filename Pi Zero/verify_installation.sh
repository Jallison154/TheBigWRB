#!/bin/bash
# WRB Installation Verification Script

echo "🔍 WRB Installation Verification"
echo "================================"
echo ""

# Check if we're in the right directory
if [ ! -f "PiScript" ]; then
    echo "❌ PiScript not found. Please run this from the Pi Zero directory."
    exit 1
fi

echo "✅ PiScript found"

# Check required files
REQUIRED_FILES=("PiScript" "config.py" "monitor_system.py" "requirements.txt" "WRB-enhanced.service")

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Check Python syntax
echo ""
echo "🐍 Checking Python syntax..."
if python3 -m py_compile PiScript 2>/dev/null; then
    echo "✅ PiScript syntax is valid"
else
    echo "❌ PiScript has syntax errors"
    exit 1
fi

if python3 -m py_compile config.py 2>/dev/null; then
    echo "✅ config.py syntax is valid"
else
    echo "❌ config.py has syntax errors"
    exit 1
fi

if python3 -m py_compile monitor_system.py 2>/dev/null; then
    echo "✅ monitor_system.py syntax is valid"
else
    echo "❌ monitor_system.py has syntax errors"
    exit 1
fi

# Check if required Python packages are available
echo ""
echo "📦 Checking Python packages..."
PYTHON_PACKAGES=("pygame" "serial" "gpiozero")

for pkg in "${PYTHON_PACKAGES[@]}"; do
    if python3 -c "import $pkg" 2>/dev/null; then
        echo "✅ $pkg is available"
    else
        echo "⚠️  $pkg not installed (will be installed during setup)"
    fi
done

# Check sound files
echo ""
echo "🎵 Checking sound files..."
if [ -d "default_sounds" ]; then
    SOUND_COUNT=$(find default_sounds -name "*.wav" | wc -l)
    echo "✅ Found $SOUND_COUNT sound files in default_sounds/"
else
    echo "⚠️  default_sounds directory not found"
fi

echo ""
echo "🎉 Verification complete!"
echo ""
echo "📋 Summary:"
echo "  - All required files are present"
echo "  - Python syntax is valid"
echo "  - Ready for installation"
echo ""
echo "🚀 To install:"
echo "  chmod +x install.sh"
echo "  ./install.sh"
echo ""
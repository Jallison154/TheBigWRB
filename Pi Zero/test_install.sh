#!/bin/bash
# Test script to verify Update-1.0 branch installation
# This script tests the installation without actually installing

set -e

echo "🧪 Testing WRB Update-1.0 Branch Installation"
echo "============================================="
echo ""

# Test 1: Check if we can access the repository
echo "📡 Testing repository access..."
if git ls-remote https://github.com/Jallison154/TheBigWRB.git Update-1.0 >/dev/null 2>&1; then
    echo "✅ Update-1.0 branch is accessible"
else
    echo "❌ Update-1.0 branch not found"
    exit 1
fi

# Test 2: Check if required files exist in the branch
echo "📁 Testing file availability..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git TheBigWRB
cd TheBigWRB/Pi\ Zero

# Check for required files
REQUIRED_FILES=("PiScript" "config.py" "monitor_system.py" "requirements.txt" "install_update_branch.sh")

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file found"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Test 3: Check if install script is executable
echo "🔧 Testing install script..."
if [ -x "install_update_branch.sh" ]; then
    echo "✅ install_update_branch.sh is executable"
else
    echo "⚠️  install_update_branch.sh is not executable, fixing..."
    chmod +x install_update_branch.sh
    echo "✅ Fixed permissions"
fi

# Test 4: Check Python requirements
echo "🐍 Testing Python requirements..."
if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt found"
    echo "📋 Required packages:"
    cat requirements.txt | while read line; do
        echo "   - $line"
    done
else
    echo "❌ requirements.txt not found"
fi

# Test 5: Check default sounds
echo "🎵 Testing default sounds..."
if [ -d "default_sounds" ]; then
    echo "✅ default_sounds directory found"
    SOUND_FILES=$(find default_sounds -name "*.wav" 2>/dev/null | wc -l)
    echo "   Found $SOUND_FILES sound files"
else
    echo "⚠️  default_sounds directory not found"
fi

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 All tests passed! Update-1.0 branch is ready for installation."
echo ""
echo "📋 Installation options:"
echo "  1. One-line install: curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/one_liner_install.sh | bash"
echo "  2. Quick install: curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/quick_install_update.sh | bash"
echo "  3. Manual install: git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git && cd TheBigWRB/Pi\\ Zero && ./install_update_branch.sh"
echo ""

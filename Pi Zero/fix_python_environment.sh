#!/bin/bash
# Fix for Python externally managed environment error
# Run this if you get the "externally-managed-environment" error

echo "=== Python Environment Fix ==="
echo ""

echo "🔧 Installing Python packages via apt (recommended method)..."
sudo apt update
sudo apt install -y python3-pygame python3-serial python3-gpiozero

echo ""
echo "🧪 Testing Python imports..."
python3 -c "
import pygame
import serial
from gpiozero import LED
print('✅ All Python packages imported successfully!')
print('pygame version:', pygame.version.ver)
" 2>/dev/null && echo "✅ Python environment is working correctly!" || {
    echo "⚠️  Some packages may not be available, trying alternative installation..."
    
    echo "🔧 Trying pip with --break-system-packages..."
    pip3 install pygame --break-system-packages 2>/dev/null || echo "❌ pip install failed"
    
    echo "🧪 Testing again..."
    python3 -c "import pygame; print('pygame version:', pygame.version.ver)" 2>/dev/null || {
        echo "❌ pygame still not working. You may need to:"
        echo "   1. Update your system: sudo apt update && sudo apt upgrade"
        echo "   2. Reboot and try again"
        echo "   3. Check the installation guide for manual setup"
    }
}

echo ""
echo "📋 If you're still having issues, the packages are likely already installed via apt."
echo "   Try running your Python script directly to see if it works."

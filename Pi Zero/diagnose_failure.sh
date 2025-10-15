#!/bin/bash

echo "🔍 Diagnosing WRB service failure..."

echo ""
echo "📊 Current service status:"
systemctl status WRB-enhanced.service --no-pager -l

echo ""
echo "📝 Recent detailed logs:"
journalctl -u WRB-enhanced.service --no-pager -n 20

echo ""
echo "🔍 Checking if PiScript exists and is executable:"
ls -la ~/WRB/PiScript

echo ""
echo "🐍 Testing Python script directly:"
echo "Running: python3 ~/WRB/PiScript"
timeout 10 python3 ~/WRB/PiScript || echo "Script exited or timed out"

echo ""
echo "🔍 Checking sound files:"
ls -la ~/WRB/sounds/

echo ""
echo "🔍 Checking serial devices:"
ls -la /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo "No ACM/USB devices found"

echo ""
echo "🔍 Checking audio devices:"
aplay -l 2>/dev/null || echo "aplay not available"

echo ""
echo "🔍 Checking Python packages:"
python3 -c "import pygame, serial, gpiozero; print('All packages available')" 2>/dev/null || echo "Missing packages"

echo ""
echo "🔍 Checking permissions:"
whoami
groups
ls -la /home/wrb01/WRB/

echo ""
echo "✅ Diagnosis complete"

#!/bin/bash
# WRB Auto-Start Diagnostic Script
# This script helps diagnose why the WRB service might not be auto-starting

echo "=========================================="
echo "  WRB Auto-Start Diagnostic Tool"
echo "=========================================="
echo ""

# Get current user
ACTUAL_USER=$(whoami)
echo "🔍 Current user: $ACTUAL_USER"
echo ""

# Check if service files exist
echo "📁 Checking service files..."
if [ -f "/etc/systemd/system/WRB-enhanced.service" ]; then
    echo "✅ WRB-enhanced.service exists"
else
    echo "❌ WRB-enhanced.service missing"
fi

if [ -f "/etc/systemd/system/WRB-auto-start.service" ]; then
    echo "✅ WRB-auto-start.service exists"
else
    echo "❌ WRB-auto-start.service missing"
fi

if [ -f "/etc/systemd/system/WRB-watchdog.service" ]; then
    echo "✅ WRB-watchdog.service exists"
else
    echo "❌ WRB-watchdog.service missing"
fi

echo ""

# Check service status
echo "📊 Checking service status..."
echo "Main service status:"
systemctl status WRB-enhanced.service --no-pager || echo "❌ Service not found or not running"

echo ""
echo "Auto-start service status:"
systemctl status WRB-auto-start.service --no-pager || echo "❌ Auto-start service not found or not running"

echo ""
echo "Watchdog service status:"
systemctl status WRB-watchdog.service --no-pager || echo "❌ Watchdog service not found or not running"

echo ""

# Check if services are enabled
echo "🔧 Checking if services are enabled..."
echo "Main service enabled: $(systemctl is-enabled WRB-enhanced.service 2>/dev/null || echo 'disabled/not found')"
echo "Auto-start service enabled: $(systemctl is-enabled WRB-auto-start.service 2>/dev/null || echo 'disabled/not found')"
echo "Watchdog service enabled: $(systemctl is-enabled WRB-watchdog.service 2>/dev/null || echo 'disabled/not found')"

echo ""

# Check application files
echo "📁 Checking application files..."
if [ -f "/home/$ACTUAL_USER/WRB/PiScript" ]; then
    echo "✅ PiScript exists"
    echo "   Permissions: $(ls -la /home/$ACTUAL_USER/WRB/PiScript)"
else
    echo "❌ PiScript missing at /home/$ACTUAL_USER/WRB/PiScript"
fi

if [ -f "/home/$ACTUAL_USER/WRB/config.py" ]; then
    echo "✅ config.py exists"
else
    echo "❌ config.py missing"
fi

echo ""

# Check user permissions
echo "👤 Checking user permissions..."
echo "User groups: $(groups $ACTUAL_USER)"
echo "Audio group membership: $(groups $ACTUAL_USER | grep -o audio || echo 'Not in audio group')"

echo ""

# Check service file content for username mismatch
echo "🔍 Checking service file configuration..."
if [ -f "/etc/systemd/system/WRB-enhanced.service" ]; then
    SERVICE_USER=$(grep "^User=" /etc/systemd/system/WRB-enhanced.service | cut -d'=' -f2)
    echo "Service configured for user: $SERVICE_USER"
    if [ "$SERVICE_USER" != "$ACTUAL_USER" ]; then
        echo "⚠️  WARNING: Service user ($SERVICE_USER) doesn't match current user ($ACTUAL_USER)"
        echo "   This could cause the service to fail to start!"
    else
        echo "✅ Service user matches current user"
    fi
fi

echo ""

# Check recent logs
echo "📋 Recent service logs (last 10 lines):"
journalctl -u WRB-enhanced.service --no-pager -n 10 || echo "No logs available"

echo ""

# Provide recommendations
echo "💡 RECOMMENDATIONS:"
echo ""

if ! systemctl is-enabled --quiet WRB-enhanced.service; then
    echo "1. Enable the service: sudo systemctl enable WRB-enhanced.service"
fi

if ! systemctl is-active --quiet WRB-enhanced.service; then
    echo "2. Start the service: sudo systemctl start WRB-enhanced.service"
fi

if ! groups $ACTUAL_USER | grep -q audio; then
    echo "3. Add user to audio group: sudo usermod -a -G audio $ACTUAL_USER"
fi

if [ ! -f "/home/$ACTUAL_USER/WRB/PiScript" ]; then
    echo "4. Re-run installation script to copy missing files"
fi

echo ""
echo "🔄 To fix auto-start issues:"
echo "   sudo systemctl daemon-reload"
echo "   sudo systemctl enable WRB-enhanced.service"
echo "   sudo systemctl start WRB-enhanced.service"
echo ""

echo "=========================================="
echo "  Diagnostic Complete"
echo "=========================================="

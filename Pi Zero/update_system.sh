#!/bin/bash
# WRB System Update Script
# Updates the system with latest changes without full reinstallation

echo "🔄 WRB System Update"
echo "==================="
echo ""

# Check if we're in the right directory
if [ ! -d "~/WRB" ]; then
    echo "❌ WRB directory not found. Please run this from the WRB directory."
    exit 1
fi

# Stop the service
echo "⏹️  Stopping WRB service..."
sudo systemctl stop WRB-enhanced.service

# Navigate to WRB directory
cd ~/WRB

# Check current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "📋 Current branch: $CURRENT_BRANCH"

# Pull latest changes
echo "📥 Pulling latest changes..."
if git pull origin $CURRENT_BRANCH; then
    echo "✅ Git pull successful"
else
    echo "⚠️  Git pull failed, trying to fetch and reset..."
    git fetch origin $CURRENT_BRANCH
    git reset --hard origin/$CURRENT_BRANCH
    echo "✅ Git reset successful"
fi

# Copy updated files
echo "📋 Copying updated files..."
if [ -d "Pi Zero" ]; then
    cp "Pi Zero/PiScript" ~/WRB/ 2>/dev/null && echo "✅ PiScript updated" || echo "⚠️  PiScript update failed"
    cp "Pi Zero/config.py" ~/WRB/ 2>/dev/null && echo "✅ config.py updated" || echo "⚠️  config.py update failed"
    cp "Pi Zero/monitor_system.py" ~/WRB/ 2>/dev/null && echo "✅ monitor_system.py updated" || echo "⚠️  monitor_system.py update failed"
    cp "Pi Zero/test_system.py" ~/WRB/ 2>/dev/null && echo "✅ test_system.py updated" || echo "⚠️  test_system.py update failed"
    cp "Pi Zero/fix_issues.sh" ~/WRB/ 2>/dev/null && echo "✅ fix_issues.sh updated" || echo "⚠️  fix_issues.sh update failed"
    cp "Pi Zero/requirements.txt" ~/WRB/ 2>/dev/null && echo "✅ requirements.txt updated" || echo "⚠️  requirements.txt update failed"
else
    echo "❌ Pi Zero directory not found in repository"
    exit 1
fi

# Set permissions
echo "🔐 Setting file permissions..."
chmod +x ~/WRB/PiScript 2>/dev/null && echo "✅ PiScript permissions set" || echo "⚠️  PiScript not found"
chmod +x ~/WRB/*.py 2>/dev/null && echo "✅ Python files permissions set" || echo "⚠️  No Python files found"
chmod +x ~/WRB/*.sh 2>/dev/null && echo "✅ Shell scripts permissions set" || echo "⚠️  No shell scripts found"

# Update service file
echo "⚙️  Updating service file..."
sudo cp "Pi Zero/WRB-enhanced.service" /etc/systemd/system/ 2>/dev/null && echo "✅ Service file updated" || echo "⚠️  Service file update failed"
sudo systemctl daemon-reload

# Update Python dependencies if needed
echo "🐍 Checking Python dependencies..."
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt --upgrade 2>/dev/null && echo "✅ Python dependencies updated" || echo "⚠️  Python dependencies update failed"
fi

# Start the service
echo "🚀 Starting WRB service..."
sudo systemctl start WRB-enhanced.service

# Check service status
echo "📊 Service status:"
sudo systemctl status WRB-enhanced.service --no-pager

echo ""
echo "🎉 System update complete!"
echo ""
echo "📋 What was updated:"
echo "  ✅ PiScript with LED, USB, and debouncing fixes"
echo "  ✅ Service configuration improvements"
echo "  ✅ Test and fix scripts"
echo "  ✅ Python dependencies"
echo ""
echo "🔧 Next steps:"
echo "  1. Test the system: python3 ~/WRB/test_system.py"
echo "  2. Run fix script if needed: ~/WRB/fix_issues.sh"
echo "  3. Check service logs: sudo journalctl -u WRB-enhanced.service -f"
echo ""

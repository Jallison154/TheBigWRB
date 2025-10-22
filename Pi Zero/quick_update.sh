#!/bin/bash
# Quick Update Script for WRB System
# Simple commands to update without full reinstallation

echo "🔄 Quick WRB Update"
echo "==================="
echo ""

# Method 1: If you have the repository cloned
echo "📋 Method 1: Update from cloned repository"
echo "cd ~/WRB"
echo "git pull origin Update-1.0"
echo "cp Pi\\ Zero/PiScript ~/WRB/"
echo "cp Pi\\ Zero/fix_issues.sh ~/WRB/"
echo "chmod +x ~/WRB/*.sh"
echo "sudo systemctl restart WRB-enhanced.service"
echo ""

# Method 2: Direct download of updated files
echo "📋 Method 2: Direct download of updated files"
echo "curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/PiScript -o ~/WRB/PiScript"
echo "curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/fix_issues.sh -o ~/WRB/fix_issues.sh"
echo "chmod +x ~/WRB/fix_issues.sh"
echo "~/WRB/fix_issues.sh"
echo ""

# Method 3: Run the update script
echo "📋 Method 3: Use the update script"
echo "curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/update_system.sh -o ~/WRB/update_system.sh"
echo "chmod +x ~/WRB/update_system.sh"
echo "~/WRB/update_system.sh"
echo ""

echo "💡 Choose the method that works best for your setup!"

#!/bin/bash
# Quick Install Script for WRB Update-1.0 Branch
# This script downloads and installs the system from the Update-1.0 branch

set -e  # Exit on any error

echo "=========================================="
echo "  WRB Quick Install (Update-1.0 Branch)"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "📥 Downloading WRB system from Update-1.0 branch..."

# Clone the repository with the Update-1.0 branch
git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git TheBigWRB

echo "✅ Repository cloned successfully"

# Navigate to the Pi Zero directory
cd TheBigWRB/Pi\ Zero

# Make the install script executable
chmod +x install_update_branch.sh

# Run the installation
echo "🚀 Starting installation..."
./install_update_branch.sh

# Clean up
cd ~
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Installation completed successfully!"
echo "🌿 Installed from Update-1.0 branch"
echo ""

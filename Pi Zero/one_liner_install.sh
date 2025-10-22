#!/bin/bash
# One-liner install script for Update-1.0 branch
# Usage: curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/one_liner_install.sh | bash

set -e

echo "🚀 WRB Update-1.0 Branch - One-Line Install"
echo "=========================================="

# Create temp directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone Update-1.0 branch
echo "📥 Downloading from Update-1.0 branch..."
git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git TheBigWRB

# Navigate and run install
cd TheBigWRB/Pi\ Zero
chmod +x install_update_branch.sh
./install_update_branch.sh

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

echo "✅ Installation complete from Update-1.0 branch!"

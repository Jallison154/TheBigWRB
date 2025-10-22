#!/bin/bash
# WRB Pi Installation Script - Clean Version
# Handles installation from both main and Update-1.0 branches

set -e  # Exit on any error

# Configuration
REPO_URL="https://github.com/Jallison154/TheBigWRB.git"
DEFAULT_BRANCH="Update-1.0"
FALLBACK_BRANCH="main"

echo "=========================================="
echo "  WRB Pi Installation Script"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root. Run as pi user instead."
    exit 1
fi

# Function to detect script location
detect_script_location() {
    if [ -f "PiScript" ]; then
        echo "✅ Found PiScript in current directory"
        return 0
    fi
    
    # Try common locations
    for path in "Pi Zero/PiScript" "../Pi Zero/PiScript" "~/TheBigWRB/Pi Zero/PiScript"; do
        if [ -f "$path" ]; then
            echo "📁 Found in $path, navigating..."
            cd "$(dirname "$path")"
            return 0
        fi
    done
    
    echo "❌ PiScript not found. Please run this from the Pi Zero directory or clone the repository first."
    echo "   Try: git clone $REPO_URL ~/TheBigWRB"
    exit 1
}

# Function to setup git repository
setup_git_repo() {
    echo "🔧 Setting up git repository..."
    cd ~/WRB
    
    if [ ! -d ".git" ]; then
        git init
        git remote add origin "$REPO_URL"
        git config pull.rebase false
        echo "✅ Git repository initialized"
        
        # Try to checkout Update-1.0 branch first
        echo "🌿 Attempting to checkout $DEFAULT_BRANCH branch..."
        if git fetch origin "$DEFAULT_BRANCH" 2>/dev/null; then
            git checkout -b "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH" 2>/dev/null && echo "✅ $DEFAULT_BRANCH branch checked out" || {
                echo "⚠️  $DEFAULT_BRANCH branch checkout failed, trying $FALLBACK_BRANCH..."
                git checkout -b "$FALLBACK_BRANCH" "origin/$FALLBACK_BRANCH" 2>/dev/null && echo "✅ $FALLBACK_BRANCH branch checked out" || echo "❌ Failed to checkout any branch"
            }
        else
            echo "⚠️  $DEFAULT_BRANCH branch not found, trying $FALLBACK_BRANCH..."
            if git fetch origin "$FALLBACK_BRANCH" 2>/dev/null; then
                git checkout -b "$FALLBACK_BRANCH" "origin/$FALLBACK_BRANCH" 2>/dev/null && echo "✅ $FALLBACK_BRANCH branch checked out" || echo "❌ Failed to checkout $FALLBACK_BRANCH branch"
            else
                echo "❌ No branches available"
            fi
        fi
    else
        echo "✅ Git repository already exists"
        CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
        echo "📋 Current branch: $CURRENT_BRANCH"
    fi
}

# Function to install system packages
install_system_packages() {
    echo "📦 Installing system packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y python3-pip python3-pygame python3-serial python3-gpiozero sox git alsa-utils python3-venv
}

# Function to copy application files
copy_application_files() {
    echo "📋 Copying application files..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "🔍 Script directory: $SCRIPT_DIR"
    
    # Copy main files
    local files=("PiScript" "config.py" "monitor_system.py" "test_esp32_connection.py" "test_system_integration.py" "requirements.txt")
    
    for file in "${files[@]}"; do
        if [ -f "$SCRIPT_DIR/$file" ]; then
            cp "$SCRIPT_DIR/$file" ~/WRB/ 2>/dev/null && echo "✅ $file copied" || echo "⚠️  Failed to copy $file"
        else
            echo "⚠️  $file not found in $SCRIPT_DIR"
        fi
    done
    
    # Copy default sounds
    if [ -d "$SCRIPT_DIR/default_sounds" ]; then
        echo "🎵 Copying default sound files..."
        cp "$SCRIPT_DIR/default_sounds"/*.wav ~/WRB/sounds/ 2>/dev/null && echo "✅ Default sounds copied" || echo "⚠️  Could not copy default sounds"
    fi
    
    # Set permissions
    chmod +x ~/WRB/PiScript 2>/dev/null && echo "✅ PiScript permissions set" || echo "⚠️  PiScript not found"
    chmod +x ~/WRB/*.py 2>/dev/null && echo "✅ Python files permissions set" || echo "⚠️  No Python files found"
}

# Function to install Python dependencies
install_python_dependencies() {
    echo "🐍 Installing Python dependencies..."
    
    if pip3 install -r ~/WRB/requirements.txt 2>/dev/null; then
        echo "✅ Python packages installed via pip"
    else
        echo "⚠️  pip install failed, trying apt packages..."
        sudo apt install -y python3-pygame python3-serial python3-gpiozero
        
        # Test pygame installation
        python3 -c "import pygame; print('pygame version:', pygame.version.ver)" 2>/dev/null || {
            echo "⚠️  pygame not found, trying alternative installation..."
            pip3 install pygame --break-system-packages 2>/dev/null || echo "❌ Could not install pygame"
        }
        
        echo "✅ Python packages installed via apt"
    fi
}

# Function to setup audio
setup_audio() {
    echo "🔊 Setting up audio..."
    sudo usermod -a -G audio $USER
    
    # Create PulseAudio configuration
    mkdir -p ~/.config/pulse
    cat > ~/.config/pulse/client.conf << 'PULSE_EOF'
default-server = unix:/run/user/1000/pulse/native
autospawn = no
daemon-binary = /bin/true
enable-shm = false
PULSE_EOF
    
    # Create ALSA configuration
    rm -rf ~/.asoundrc
    cat > ~/.asoundrc << 'ALSA_EOF'
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
ALSA_EOF
}

# Function to create sample sounds
create_sample_sounds() {
    echo "🎵 Checking for sound files..."
    
    local sounds=("button1.wav" "button2.wav" "hold1.wav" "hold2.wav")
    local missing_sounds=()
    
    for sound in "${sounds[@]}"; do
        if [ ! -f ~/WRB/sounds/"$sound" ]; then
            missing_sounds+=("$sound")
        fi
    done
    
    if [ ${#missing_sounds[@]} -gt 0 ]; then
        echo "📁 Creating sample sound files..."
        for sound in "${missing_sounds[@]}"; do
            case "$sound" in
                "button1.wav") sox -n -r 44100 -c 2 ~/WRB/sounds/"$sound" synth 0.5 sine 800 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available for $sound" ;;
                "button2.wav") sox -n -r 44100 -c 2 ~/WRB/sounds/"$sound" synth 0.5 sine 400 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available for $sound" ;;
                "hold1.wav") sox -n -r 44100 -c 2 ~/WRB/sounds/"$sound" synth 1.0 sine 1000 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available for $sound" ;;
                "hold2.wav") sox -n -r 44100 -c 2 ~/WRB/sounds/"$sound" synth 1.0 sine 600 fade h 0.1 0.1 2>/dev/null || echo "⚠️  sox not available for $sound" ;;
            esac
        done
        echo "✅ Sample sound files created"
    else
        echo "✅ Sound files already exist"
    fi
}

# Function to install systemd service
install_systemd_service() {
    echo "⚙️ Installing systemd service..."
    
    ACTUAL_USER=$(whoami)
    echo "🔧 Using username: $ACTUAL_USER"
    
    sudo tee /etc/systemd/system/WRB-enhanced.service >/dev/null << EOF
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target sound.target
StartLimitInterval=300
StartLimitBurst=3
StartLimitAction=none

[Service]
Type=simple
User=$ACTUAL_USER
Group=audio
WorkingDirectory=/home/$ACTUAL_USER/WRB
Environment=HOME=/home/$ACTUAL_USER
Environment=USER=$ACTUAL_USER
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=pulse
Environment=PULSE_RUNTIME_PATH=/run/user/1000/pulse
ExecStart=/usr/bin/python3 /home/$ACTUAL_USER/WRB/PiScript
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
StandardOutput=journal
StandardError=journal
TimeoutStartSec=30
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    # Enable and start service
    echo "🚀 Starting service..."
    sudo systemctl daemon-reload
    sudo systemctl enable WRB-enhanced.service
    sudo systemctl start WRB-enhanced.service
}

# Function to check installation status
check_installation() {
    echo "⏳ Waiting for service to start..."
    sleep 3
    
    echo ""
    echo "=========================================="
    echo "  Installation Complete!"
    echo "=========================================="
    echo ""
    
    # Check service status
    echo "📊 Service Status:"
    sudo systemctl status WRB-enhanced.service --no-pager
    
    echo ""
    echo "🎉 WRB Pi system is now installed!"
    echo ""
    echo "📋 Useful Commands:"
    echo "  Check service:     sudo systemctl status WRB-enhanced.service"
    echo "  View logs:         sudo journalctl -u WRB-enhanced.service -f"
    echo "  Restart service:   sudo systemctl restart WRB-enhanced.service"
    echo "  Test ESP32:        python3 ~/WRB/test_esp32_connection.py"
    echo "  Monitor system:    python3 ~/WRB/monitor_system.py"
    echo ""
    echo "🎵 Sound Files: ~/WRB/sounds/"
    echo "🔄 Reboot to test: sudo reboot"
    echo ""
}

# Main installation process
main() {
    # Step 1: Detect script location
    detect_script_location
    
    echo "✅ Starting WRB Pi installation..."
    echo ""
    
    # Step 2: Create directory structure
    echo "📁 Creating directory structure..."
    mkdir -p ~/WRB/sounds
    
    # Step 3: Setup git repository
    setup_git_repo
    
    # Step 4: Install system packages
    install_system_packages
    
    # Step 5: Copy application files
    copy_application_files
    
    # Step 6: Install Python dependencies
    install_python_dependencies
    
    # Step 7: Setup audio
    setup_audio
    
    # Step 8: Create sample sounds
    create_sample_sounds
    
    # Step 9: Install systemd service
    install_systemd_service
    
    # Step 10: Check installation
    check_installation
}

# Run main function
main "$@"

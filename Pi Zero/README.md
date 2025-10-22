# WRB Pi Zero Installation

This directory contains all files needed to install the ESP32 Wireless Button System on a Raspberry Pi.

## 📁 Files

- **`install.sh`** - Main installation script
- **`PiScript`** - Main Python application
- **`config.py`** - Configuration file
- **`monitor_system.py`** - System monitoring
- **`requirements.txt`** - Python dependencies
- **`WRB-enhanced.service`** - Systemd service
- **`verify_installation.sh`** - Installation verification
- **`default_sounds/`** - Default sound files

## 🚀 Quick Installation

### One-Command Install (Update-1.0 Branch)
```bash
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/install.sh | bash
```

### Manual Install
```bash
git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB
cd ~/TheBigWRB/Pi\ Zero
chmod +x install.sh
./install.sh
```

## 🔧 Verification

Before installing, verify files are correct:
```bash
chmod +x verify_installation.sh
./verify_installation.sh
```

## 📋 What the Installation Does

1. **Updates system packages**
2. **Installs Python dependencies** (pygame, pyserial, gpiozero)
3. **Creates ~/WRB directory structure**
4. **Sets up git repository with Update-1.0 branch support**
5. **Copies application files from the repository**
6. **Sets up audio configuration**
7. **Creates sample sound files**
8. **Installs systemd service for auto-start**
9. **Starts the service**

## 🌿 Update-1.0 Branch Support

The install script automatically:
- **Tries to checkout Update-1.0 branch first**
- **Falls back to main branch if Update-1.0 not available**
- **Copies files from the Pi Zero directory in the repository**
- **Shows which branch was used during installation**
- **Provides update commands for the current branch**

## 🎵 Sound Files

The system looks for sound files in `~/WRB/sounds/` with these names:
- `button1*.wav` - Button 1 quick press
- `button2*.wav` - Button 2 quick press  
- `hold1*.wav` - Button 1 hold
- `hold2*.wav` - Button 2 hold

## 🔧 Configuration

Edit `config.py` to configure:
- Serial port settings
- GPIO pin assignments
- Audio settings
- MAC addresses for ESP32 devices

## 📊 Monitoring

Check system status:
```bash
python3 ~/WRB/monitor_system.py
```

## 🛠️ Troubleshooting

1. **Service not starting**: `sudo systemctl status WRB-enhanced.service`
2. **No sound**: Check audio permissions with `groups $USER`
3. **ESP32 not detected**: Check serial ports with `ls /dev/ttyACM*`
4. **Installation issues**: Run verification script

## 📞 Support

For detailed instructions, see `INSTALLATION_GUIDE.md`.
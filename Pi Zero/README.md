# WRB Pi Zero Installation Files

This directory contains all the files needed to install and run the ESP32 Wireless Button System on a Raspberry Pi.

## 📁 File Structure

```
Pi Zero/
├── install.sh                    # Main installation script
├── verify_installation.sh        # Installation verification script
├── PiScript                      # Main Python application
├── config.py                     # Configuration file
├── monitor_system.py             # System monitoring script
├── requirements.txt              # Python dependencies
├── WRB-enhanced.service          # Systemd service file
├── default_sounds/               # Default sound files
│   ├── button1.wav
│   ├── button2.wav
│   ├── hold1.wav
│   └── hold2.wav
└── README.md                     # This file
```

## 🚀 Quick Installation

### One-Command Install
```bash
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/main/Pi%20Zero/install.sh | bash
```

### Manual Install
```bash
git clone https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB
cd ~/TheBigWRB/Pi\ Zero
chmod +x install.sh
./install.sh
```

## 🔧 Verification

After installation, verify everything is working:

```bash
chmod +x verify_installation.sh
./verify_installation.sh
```

## 📋 Key Files

- **`install.sh`** - Complete installation script with automatic branch detection
- **`PiScript`** - Main Python application that handles ESP32 communication and audio
- **`config.py`** - Configuration file with MAC addresses and pin settings
- **`monitor_system.py`** - System health monitoring and diagnostics
- **`WRB-enhanced.service`** - Systemd service for auto-start on boot

## 🎵 Sound Files

The system supports custom sound files with these naming conventions:
- `button1*.wav` - Button 1 quick press sounds
- `button2*.wav` - Button 2 quick press sounds
- `hold1*.wav` - Button 1 hold sounds
- `hold2*.wav` - Button 2 hold sounds

## 🔧 Configuration

Edit `config.py` to configure:
- MAC addresses for ESP32 devices
- GPIO pin assignments
- Audio settings
- Serial communication settings

## 📊 Monitoring

Use the monitoring script to check system health:
```bash
python3 ~/WRB/monitor_system.py
```

## 🛠️ Troubleshooting

1. **Service not starting**: Check logs with `sudo journalctl -u WRB-enhanced.service -f`
2. **No sound**: Verify audio permissions with `groups $USER`
3. **ESP32 not detected**: Check serial ports with `ls /dev/ttyACM* /dev/ttyUSB*`
4. **Installation issues**: Run verification script with `./verify_installation.sh`

## 📞 Support

For detailed installation instructions, see `INSTALLATION_GUIDE.md`.

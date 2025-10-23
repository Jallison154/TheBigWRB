# WRB Project Restart - Complete Requirements List

## 🎯 Project Overview
**ESP32 Wireless Button System (WRB)** - A complete battery-efficient wireless button system using Seeed Studio XIAO ESP32C3 devices with ESP-NOW protocol, featuring release-based triggering, hold detection, audio feedback, and one-command Raspberry Pi installation.

## 📋 Core Requirements

### 1. **Hardware Requirements**
- **2x Seeed Studio XIAO ESP32C3** boards (transmitter + receiver)
- **2x Push buttons** (for transmitter)
- **2x LEDs** (for status indicators)
- **2x Resistors** (220Ω for LEDs)
- **Raspberry Pi** (Pi Zero, Pi 3, Pi 4, or Pi 5)
- **MicroSD card** (8GB+ for Raspberry Pi)
- **USB drive** (optional, for custom sound files)
- **Breadboard and jumper wires** (for prototyping)

### 2. **Software Requirements**
- **Raspberry Pi OS** (Lite or Desktop)
- **Arduino IDE** with ESP32 board package
- **Python 3.7+** with required packages
- **Git** (for version control)
- **Systemd** (for service management)

## 🔧 Technical Specifications

### 3. **ESP32 Configuration**

#### **Hardware Specifications**
- **Board**: Seeed Studio XIAO ESP32C3
- **CPU**: RISC-V 32-bit single-core processor
- **WiFi**: 802.11 b/g/n (2.4GHz)
- **Bluetooth**: BLE 5.0
- **GPIO**: 11 digital pins
- **Power**: 3.3V operation
- **Dimensions**: 20×17.5×3.5mm

#### **Pin Configuration**
```
Transmitter ESP32:
├── D1 (GPIO2)  ←→ Button 1 ←→ GND
├── D2 (GPIO3)  ←→ Button 2 ←→ GND  
├── D10 (GPIO8) ←→ LED (220Ω) ←→ 3.3V
└── USB ←→ Power/Programming

Receiver ESP32:
├── D10 (GPIO8) ←→ LED (220Ω) ←→ 3.3V
├── USB ←→ Raspberry Pi (Serial)
└── Power ←→ USB or Battery
```

#### **MAC Address Configuration**
```
Example MAC Addresses:
├── Receiver MAC:  58:8c:81:9e:30:10 (0x58,0x8C,0x81,0x9E,0x30,0x10)
├── Transmitter 1: 58:8c:81:9f:22:ac (0x58,0x8C,0x81,0x9F,0x22,0xAC)
├── Transmitter 2: 58:8c:81:9f:22:ad (0x58,0x8C,0x81,0x9F,0x22,0xAD)
└── Transmitter 3: 58:8c:81:9f:22:ae (0x58,0x8C,0x81,0x9F,0x22,0xAE)
```

#### **Communication Protocol**
- **Protocol**: ESP-NOW for low-latency communication
- **Channel**: WiFi Channel 1 (2.412 GHz)
- **Power Management**: Light sleep + deep sleep modes
- **Security**: MAC address-based authentication
- **Buttons**: 2 buttons with release-based triggering
- **Hold Detection**: 800ms threshold for hold vs press
- **LED Feedback**: Status indicators for connection and activity
- **Retry Mechanism**: 3 retries for failed transmissions
- **Link Monitoring**: Continuous ping/ack system
- **Message Types**: 
  - `MSG_PING (0xA0)` - Keep-alive ping
  - `MSG_ACK (0xA1)` - Acknowledgment
  - `MSG_BTN (0xB0)` - Button press
  - `MSG_BTN_HOLD (0xB1)` - Button hold

### 4. **Raspberry Pi Configuration**

#### **Hardware Specifications**
- **Board**: Raspberry Pi Zero/3/4/5
- **OS**: Raspberry Pi OS (Lite or Desktop)
- **CPU**: ARM Cortex-A53/A72/A76 (depending on model)
- **RAM**: 512MB - 8GB (depending on model)
- **Storage**: MicroSD card (8GB+ recommended)
- **GPIO**: 40-pin header
- **USB**: USB 2.0/3.0 ports
- **Audio**: 3.5mm jack or HDMI audio

#### **GPIO Pin Configuration**
```
Raspberry Pi GPIO:
├── GPIO 23 ←→ Ready LED (220Ω) ←→ 3.3V
├── GPIO 24 ←→ USB LED (220Ω) ←→ 3.3V
├── USB ←→ ESP32 Receiver (Serial)
├── 3.3V ←→ LED Power
├── GND ←→ LED Ground
└── 5V ←→ ESP32 Power (if needed)
```

#### **Serial Communication**
- **Port**: `/dev/ttyACM0` (primary), `/dev/ttyACM1`, `/dev/ttyUSB0`, `/dev/ttyUSB1` (fallback)
- **Baud Rate**: 115200
- **Protocol**: ASCII text messages
- **Message Format**: `BTN1`, `BTN2`, `HOLD1`, `HOLD2`
- **Timeout**: 1 second
- **Auto-detection**: Multiple port scanning

#### **Audio System Configuration**
- **Primary**: PulseAudio (recommended)
- **Fallback**: ALSA
- **Sample Rate**: 44100 Hz
- **Channels**: Stereo (2-channel)
- **Bit Depth**: 16-bit
- **Buffer Size**: 512 samples
- **Mixer**: Keep-open (no audio cutoffs)
- **Channels**: 4 simultaneous playback

#### **USB Drive Support**
- **Mount Point**: `/media/[username]/[drive_name]`
- **File Detection**: Automatic scanning for sound files
- **Supported Formats**: WAV files only
- **Naming Convention**: `button1*.wav`, `button2*.wav`, `hold1*.wav`, `hold2*.wav`
- **LED Indicator**: GPIO 24 shows USB drive status
- **Hot-swapping**: Automatic detection of USB insertion/removal

#### **Service Configuration**
- **Service Name**: `WRB-enhanced.service`
- **User**: `pi` (non-root execution)
- **Group**: `audio` (audio permissions)
- **Working Directory**: `/home/pi/WRB`
- **Environment Variables**:
  - `WRB_SERIAL=/dev/ttyACM0`
  - `SDL_AUDIODRIVER=pulse`
  - `PULSE_RUNTIME_PATH=/run/user/1000/pulse`
- **Restart Policy**: `on-failure` with 10-second delay
- **Timeout**: 30 seconds start, 10 seconds stop

## 📁 Project Structure Requirements

### 5. **File Organization**
```
TheBigWRB/
├── Transmitter/
│   └── Transmitter_ESP32.ino    # Transmitter code
├── Receiver/
│   └── Receiver_ESP32.ino       # Receiver code
├── Pi Zero/
│   ├── install.sh               # Main installation script
│   ├── PiScript                 # Main Python application
│   ├── config.py                # Configuration file
│   ├── monitor_system.py        # System monitoring
│   ├── test_system.py           # System testing
│   ├── diagnose_system.sh       # Diagnostic script
│   ├── fix_all_issues.sh        # Comprehensive fix script
│   ├── requirements.txt         # Python dependencies
│   ├── WRB-enhanced.service     # Systemd service
│   ├── default_sounds/          # Default sound files
│   ├── README.md                # Documentation
│   └── INSTALLATION_GUIDE.md    # Installation guide
├── MAC_Finder.ino               # MAC address utility
└── README.md                    # Main documentation
```

### 6. **Documentation Requirements**
- **Complete installation guide** with step-by-step instructions
- **Hardware setup diagrams** with pin connections
- **Troubleshooting guide** for common issues
- **Configuration examples** for different setups
- **Update procedures** for system maintenance
- **API documentation** for customization

## 🚀 Installation Requirements

### 7. **One-Command Installation**
- **Direct download**: `curl -sSL [URL] | bash`
- **Git clone**: `git clone -b Update-1.0 [URL]`
- **Automatic branch detection** (Update-1.0 preferred)
- **Fallback to main branch** if Update-1.0 unavailable
- **Comprehensive error handling** for all failure modes
- **Progress indicators** during installation
- **Verification steps** after installation

### 8. **System Setup Requirements**
- **Automatic package installation** (Python, audio, GPIO)
- **Permission configuration** (GPIO, audio, serial)
- **Directory structure creation** (~/WRB/)
- **Service configuration** (systemd)
- **Audio setup** (ALSA, PulseAudio)
- **Sample sound file creation**
- **Git repository setup** for updates

## 🔧 Functionality Requirements

### 9. **ESP32 Transmitter Features**
- **Release-based triggering** (no double triggers)
- **Hold detection** (800ms threshold)
- **LED status indicators** (connection, activity)
- **Power management** (light sleep, deep sleep)
- **Retry mechanism** (3 attempts for failed transmissions)
- **MAC address security** (only authorized devices)
- **Serial debugging** (comprehensive logging)

### 10. **ESP32 Receiver Features**
- **Multi-transmitter support** (up to 10 devices)
- **Message parsing** (button, hold, ping, ack)
- **LED feedback** (connection status, received messages)
- **Serial output** (debugging and monitoring)
- **Security validation** (MAC address checking)
- **Error handling** (malformed messages)

### 11. **Raspberry Pi Features**
- **Audio playback** (4-channel simultaneous)
- **GPIO control** (LED feedback)
- **USB detection** (automatic sound file loading)
- **Serial communication** (ESP32 receiver)
- **Service management** (auto-start, restart)
- **Logging system** (button presses, errors)
- **Health monitoring** (connection status)

## 🎵 Audio System Requirements

### 12. **Sound File Support**
- **File formats**: WAV files (44.1kHz, 16-bit recommended)
- **Naming convention**: 
  - `button1*.wav` - Button 1 quick press
  - `button2*.wav` - Button 2 quick press
  - `hold1*.wav` - Button 1 hold
  - `hold2*.wav` - Button 2 hold
- **USB support**: Automatic detection and loading
- **Local fallback**: Default sounds if no USB
- **Sample creation**: Automatic test sound generation

### 13. **Audio Configuration**
- **Keep-open mixer** (no audio cutoffs)
- **4-channel support** (simultaneous playback)
- **ALSA configuration** (fallback audio)
- **PulseAudio support** (primary audio)
- **Volume control** (system-level)
- **Error handling** (audio device failures)

## 🔒 Security Requirements

### 14. **Device Authentication**
- **MAC address validation** (transmitter/receiver pairs)
- **Unauthorized device rejection** (logging and ignoring)
- **Connection monitoring** (ping/ack system)
- **Security logging** (rejected connections)
- **Device management** (add/remove transmitters)

### 15. **System Security**
- **User permissions** (GPIO, audio, serial)
- **Service isolation** (non-root execution)
- **File permissions** (executable scripts)
- **Network security** (ESP-NOW only)
- **Update verification** (git-based updates)

## 🧪 Testing Requirements

### 16. **System Testing**
- **Hardware testing** (GPIO, audio, serial)
- **Service testing** (startup, restart, failure)
- **Audio testing** (playback, file detection)
- **ESP32 testing** (connection, communication)
- **USB testing** (mounting, file detection)
- **Performance testing** (latency, reliability)

### 17. **Diagnostic Tools**
- **System health check** (all components)
- **Error diagnosis** (common issues)
- **Performance monitoring** (latency, errors)
- **Log analysis** (service, application)
- **Hardware verification** (connections, permissions)

## 🔄 Maintenance Requirements

### 18. **Update System**
- **Git-based updates** (branch management)
- **Automatic updates** (service restart)
- **Rollback capability** (previous versions)
- **Update verification** (file integrity)
- **Configuration preservation** (user settings)

### 19. **Monitoring System**
- **Service status** (running, failed, restarting)
- **Hardware status** (GPIO, audio, serial)
- **Performance metrics** (latency, errors)
- **Log management** (rotation, cleanup)
- **Alert system** (failures, issues)

## 📊 Performance Requirements

### 20. **Latency Requirements**
- **Button press to sound**: < 100ms
- **Hold detection**: 800ms ± 50ms
- **Audio playback**: Immediate start
- **LED feedback**: < 50ms
- **Serial communication**: < 10ms
- **ESP-NOW transmission**: < 5ms
- **Message parsing**: < 1ms
- **GPIO response**: < 10ms

### 21. **Reliability Requirements**
- **Uptime**: 99%+ (with auto-restart)
- **Error recovery**: Automatic restart on failure
- **Connection stability**: Auto-reconnect ESP32
- **Audio stability**: No cutoffs or glitches
- **Service stability**: Auto-restart on crash
- **Power management**: 6+ months battery life
- **Transmission success**: > 95% (with retries)
- **Message integrity**: 100% (with validation)

## ⚡ Power Management Specifications

### 22. **ESP32 Power Management**
- **Active Mode**: 50-100mA (button press/transmission)
- **Light Sleep**: 5-10mA (idle with breathing LED)
- **Deep Sleep**: 10-50μA (extended idle)
- **Battery Life**: 6+ months (with 2x AA batteries)
- **Wake-up Sources**: GPIO interrupt (button press)
- **Sleep Timers**:
  - Light sleep: 5 minutes of inactivity
  - Deep sleep: 15 minutes of inactivity
- **Power Optimization**: 
  - WiFi off during sleep
  - CPU frequency scaling
  - Peripheral shutdown

### 23. **Raspberry Pi Power Management**
- **Idle Power**: 1-2W (Pi Zero)
- **Active Power**: 2-3W (audio playback)
- **USB Power**: 5V/1A (ESP32 receiver)
- **GPIO Power**: 3.3V/50mA (LEDs)
- **Power Supply**: 5V/2.5A (recommended)
- **Power Management**: 
  - CPU governor: ondemand
  - USB power management
  - HDMI power saving

## 🔧 Hardware Specifications

### 24. **Component Specifications**

#### **ESP32 XIAO ESP32C3**
- **Dimensions**: 20×17.5×3.5mm
- **Weight**: 2.3g
- **Operating Voltage**: 3.3V
- **Input Voltage**: 3.3V-5V
- **Digital I/O**: 11 pins
- **Analog Input**: 4 pins
- **PWM**: 6 channels
- **UART**: 1
- **SPI**: 1
- **I2C**: 1
- **WiFi**: 802.11 b/g/n
- **Bluetooth**: BLE 5.0
- **Flash**: 4MB
- **SRAM**: 400KB

#### **Raspberry Pi Models**
```
Pi Zero W:    1GHz ARM, 512MB RAM, WiFi, Bluetooth
Pi 3B+:       1.4GHz ARM, 1GB RAM, WiFi, Bluetooth, Ethernet
Pi 4B:        1.5GHz ARM, 2-8GB RAM, WiFi, Bluetooth, Gigabit Ethernet
Pi 5:         2.4GHz ARM, 4-8GB RAM, WiFi, Bluetooth, Gigabit Ethernet
```

#### **Button Specifications**
- **Type**: Momentary push button
- **Voltage**: 3.3V compatible
- **Current**: < 1mA
- **Debounce**: Hardware + software
- **Connection**: Pull-up resistor (internal)
- **Activation**: Press to GND

#### **LED Specifications**
- **Type**: Standard LED (3mm or 5mm)
- **Color**: Any (red, green, blue, white)
- **Voltage**: 2.0-3.3V forward voltage
- **Current**: 20mA (with 220Ω resistor)
- **Resistor**: 220Ω (for 3.3V supply)
- **Brightness**: Adjustable via PWM

### 25. **Timing Specifications**

#### **Button Timing**
- **Debounce Time**: 50ms (hardware + software)
- **Hold Threshold**: 800ms ± 50ms
- **Release Detection**: < 10ms
- **Double-tap Prevention**: 500ms cooldown
- **Long-press Detection**: 1000ms+ (for special functions)

#### **Communication Timing**
- **ESP-NOW Latency**: < 5ms
- **Serial Latency**: < 10ms
- **Message Processing**: < 1ms
- **Retry Interval**: 50ms
- **Ping Interval**: 500ms
- **Link Timeout**: 4000ms
- **Status Update**: 10000ms

#### **Audio Timing**
- **Playback Start**: < 50ms
- **File Loading**: < 100ms
- **Mixer Initialization**: < 200ms
- **Channel Switching**: < 10ms
- **Volume Changes**: < 5ms

## 🎨 User Experience Requirements

### 22. **Ease of Use**
- **One-command installation** (no technical knowledge required)
- **Automatic configuration** (no manual setup)
- **Clear documentation** (step-by-step guides)
- **Visual feedback** (LEDs, status indicators)
- **Audio feedback** (immediate response)

### 23. **Troubleshooting**
- **Diagnostic tools** (automatic issue detection)
- **Fix scripts** (automatic problem resolution)
- **Clear error messages** (user-friendly)
- **Recovery procedures** (step-by-step fixes)
- **Support documentation** (common issues)

## 🔧 Development Requirements

### 24. **Code Quality**
- **Clean, readable code** (well-commented)
- **Error handling** (comprehensive try/catch)
- **Modular design** (separate concerns)
- **Configuration management** (external config files)
- **Logging system** (debug and error logs)

### 25. **Testing**
- **Unit tests** (individual components)
- **Integration tests** (full system)
- **Hardware tests** (real device testing)
- **Performance tests** (latency, reliability)
- **User acceptance tests** (end-to-end)

## 📈 Future Requirements

### 26. **Extensibility**
- **Additional buttons** (easy to add)
- **More transmitters** (scalable design)
- **Custom actions** (beyond audio)
- **API integration** (external systems)
- **Mobile app** (remote control)

### 27. **Scalability**
- **Multiple receivers** (network of devices)
- **Centralized control** (master/slave)
- **Cloud integration** (remote monitoring)
- **Enterprise features** (user management)
- **Analytics** (usage tracking)

## 🔧 Configuration Examples

### 26. **ESP32 Code Configuration**

#### **Transmitter Configuration**
```cpp
// MAC Address Configuration
uint8_t RX_MAC[] = { 0x58,0x8C,0x81,0x9E,0x30,0x10 }; // Receiver MAC

// Pin Configuration
#define LED_PIN D10
#define BTN1_PIN D1
#define BTN2_PIN D2

// Timing Configuration
const uint32_t HOLD_DELAY_MS = 800;           // Hold threshold
const uint32_t IDLE_LIGHT_MS = 5 * 60 * 1000; // Light sleep delay
const uint32_t IDLE_DEEP_MS = 15 * 60 * 1000; // Deep sleep delay
const uint8_t MAX_RETRIES = 3;                 // Retry count
const uint32_t RETRY_DELAY_MS = 50;           // Retry interval

// Message Types
#define MSG_PING 0xA0
#define MSG_ACK 0xA1
#define MSG_BTN 0xB0
#define MSG_BTN_HOLD 0xB1
```

#### **Receiver Configuration**
```cpp
// Allowed Transmitter MACs
uint8_t ALLOWED_TX_MACS[][6] = {
  { 0x58,0x8C,0x81,0x9F,0x22,0xAC }, // Transmitter 1
  { 0x58,0x8C,0x81,0x9F,0x22,0xAD }, // Transmitter 2
  { 0x58,0x8C,0x81,0x9F,0x22,0xAE }, // Transmitter 3
};

// Pin Configuration
#define LED_PIN D10

// Communication Settings
const uint32_t PING_INTERVAL_MS = 500;        // Ping interval
const uint32_t LINK_TIMEOUT_MS = 4000;        // Link timeout
const uint8_t MAX_TRANSMITTERS = 10;          // Max transmitters
```

### 27. **Raspberry Pi Configuration**

#### **config.py Configuration**
```python
# Serial Communication
BAUD = 115200
SERIAL_PORT = "/dev/ttyACM0"

# GPIO Pins
READY_PIN = 23
USB_LED_PIN = 24

# Audio Configuration
MIX_FREQ = 44100
MIX_BUF = 512

# File Paths
SOUNDS_DIR = "~/WRB/sounds"
LOG_FILE = "~/WRB/button_log.txt"

# ESP32 Message Types
MSG_PING = 0xA0
MSG_ACK = 0xA1
MSG_BTN = 0xB0
MSG_BTN_HOLD = 0xB1

# Timing Configuration
BUTTON_DEBOUNCE_TIME = 0.5  # 500ms debounce
HOLD_DELAY_MS = 800         # Hold threshold
```

#### **Systemd Service Configuration**
```ini
[Unit]
Description=WRB Enhanced Audio System
After=network.target sound.target
Wants=network.target sound.target
StartLimitInterval=300
StartLimitBurst=3

[Service]
Type=simple
User=pi
Group=audio
WorkingDirectory=/home/pi/WRB
Environment=HOME=/home/pi
Environment=USER=pi
Environment=WRB_SERIAL=/dev/ttyACM0
Environment=SDL_AUDIODRIVER=pulse
Environment=PULSE_RUNTIME_PATH=/run/user/1000/pulse
ExecStart=/usr/bin/python3 /home/pi/WRB/PiScript
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=1
StandardOutput=journal
StandardError=journal
TimeoutStartSec=30
TimeoutStopSec=10

[Install]
WantedBy=multi-user.target
```

## 📋 Installation Commands

### 28. **One-Command Installation**
```bash
# Update-1.0 Branch (Recommended)
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/Update-1.0/Pi%20Zero/install.sh | bash

# Main Branch (Fallback)
curl -sSL https://raw.githubusercontent.com/Jallison154/TheBigWRB/main/Pi%20Zero/install.sh | bash
```

### 29. **Manual Installation**
```bash
# Clone Update-1.0 branch
git clone -b Update-1.0 https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB
cd ~/TheBigWRB/Pi\ Zero
chmod +x install.sh
./install.sh

# Or clone main branch
git clone https://github.com/Jallison154/TheBigWRB.git ~/TheBigWRB
cd ~/TheBigWRB/Pi\ Zero
chmod +x install.sh
./install.sh
```

### 30. **Update Commands**
```bash
# Update from Update-1.0 branch
cd ~/WRB
git pull origin Update-1.0

# Update from main branch
cd ~/WRB
git pull origin main

# Force update (if needed)
cd ~/WRB
git fetch origin Update-1.0
git reset --hard origin/Update-1.0
```

## ✅ Success Criteria

### 31. **Functional Requirements**
- ✅ **One-command installation works**
- ✅ **ESP32 communication reliable**
- ✅ **Audio playback immediate and clear**
- ✅ **LED feedback responsive**
- ✅ **USB mounting automatic**
- ✅ **Service auto-starts on boot**
- ✅ **Hold detection accurate**
- ✅ **No double triggers**
- ✅ **Error recovery automatic**

### 32. **Non-Functional Requirements**
- ✅ **Installation time < 5 minutes**
- ✅ **System startup < 30 seconds**
- ✅ **Button response < 100ms**
- ✅ **Uptime > 99%**
- ✅ **Documentation complete**
- ✅ **Troubleshooting tools available**
- ✅ **Update process simple**
- ✅ **User experience smooth**

## 🎯 Project Goals

**Primary Goal**: Create a reliable, easy-to-install, wireless button system that "just works" out of the box.

**Secondary Goals**: 
- Comprehensive documentation
- Robust error handling
- Easy maintenance and updates
- Extensible architecture
- Professional user experience

This requirements list ensures the restarted project will be robust, reliable, and user-friendly from day one.

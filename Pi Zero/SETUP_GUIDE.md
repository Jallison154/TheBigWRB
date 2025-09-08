# ESP32 Wireless Button System - Setup Guide

This guide ensures all components work together properly.

## Prerequisites

1. **Hardware**:
   - Raspberry Pi (any model with GPIO)
   - 2x Seeed Studio XIAO ESP32C3 boards
   - 2x buttons (for transmitter)
   - 2x LEDs (for Pi status indicators)
   - USB drive (optional, for sound files)

2. **Software**:
   - Python 3.7+
   - pip3
   - Arduino IDE with ESP32 board package

## Step 1: Hardware Setup

### ESP32 Transmitter
- Connect button 1 to D1 (to GND)
- Connect button 2 to D2 (to GND)
- Connect LED to D10 (with resistor)
- Power with 3.3V battery

### ESP32 Receiver
- Connect LED to D10 (with resistor)
- Power via USB (connected to Pi)

### Raspberry Pi
- Connect Ready LED to GPIO 18 (with resistor)
- Connect USB LED to GPIO 23 (with resistor)
- Connect ESP32 receiver via USB

## Step 2: Find MAC Addresses

1. **Upload MAC_Finder.ino to both ESP32 boards**
2. **Open Serial Monitor (115200 baud)**
3. **Note the MAC addresses displayed**

## Step 3: Configure MAC Addresses

### Receiver Configuration
In `Receiver ESP32`, update line 12:
```cpp
uint8_t ALLOWED_TX_MACS[][6] = {
  { 0x58,0x8C,0x81,0x9F,0x22,0xAC }, // Your transmitter MAC (58:8c:81:9f:22:ac)
};
```

### Transmitter Configuration
In `Transmitter ESP32.c`, update line 16:
```cpp
uint8_t RX_MAC[] = { 0x58,0x8C,0x81,0x9E,0x30,0x10 }; // Your receiver MAC (58:8c:81:9e:30:10)
```

## Step 4: Flash ESP32 Code

1. **Flash Transmitter ESP32.c to transmitter board**
2. **Flash Receiver ESP32 to receiver board**
3. **Connect receiver to Pi via USB**

## Step 5: Pi Software Setup

### Install Dependencies
```bash
sudo apt update
sudo apt install python3-pip python3-pygame
pip3 install pyserial gpiozero
```

### Create Directory Structure
```bash
mkdir -p ~/WRB
chmod 755 ~/WRB
```

### Copy Files
```bash
# Copy the Pi script to the WRB directory
cp "Pi Script" ~/WRB/Pi_Script_Enhanced.py
chmod +x ~/WRB/Pi_Script_Enhanced.py

# Copy test scripts
cp test_usb_led.py ~/WRB/
cp test_system_integration.py ~/WRB/
```

## Step 6: Test System

### Run Integration Test
```bash
cd ~/WRB
python3 test_system_integration.py
```

### Test USB LED
```bash
python3 test_usb_led.py
```

### Test Main Script
```bash
python3 Pi_Script_Enhanced.py
```

## Step 7: Add Sound Files

### Option 1: Local Storage
```bash
# Create sound files in ~/WRB/sounds/
# button1*.wav for Button 1 quick press sounds
# button2*.wav for Button 2 quick press sounds
# hold1*.wav for Button 1 hold sounds
# hold2*.wav for Button 2 hold sounds
```

### Option 2: USB Drive
- Format USB drive as FAT32
- Add sound files with names: `button1*.wav`, `button2*.wav`, `hold1*.wav`, `hold2*.wav`
- Insert USB drive into Pi

## Step 8: Verify Operation

### LED Indicators
- **Ready LED (GPIO 18)**: ON when system ready
- **USB LED (GPIO 23)**: ON when USB drive mounted
- **ESP32 LEDs**: Show connection status

### Button Mapping
- **Button 1 Quick Press**: Plays `button1*.wav` sound
- **Button 1 Hold (1s)**: Plays `hold1*.wav` sound
- **Button 2 Quick Press**: Plays `button2*.wav` sound
- **Button 2 Hold (1s)**: Plays `hold2*.wav` sound

### Serial Output
Monitor with:
```bash
tail -f ~/WRB/button_log.txt
```

## Troubleshooting

### No Connection Between ESP32s
1. Check MAC addresses match
2. Ensure both devices are powered
3. Check serial output for "Rejected message from unauthorized MAC"

### Pi Script Issues
1. Run integration test: `python3 test_system_integration.py`
2. Check permissions: `ls -la ~/WRB/`
3. Check dependencies: `pip3 list | grep -E "(pygame|pyserial|gpiozero)"`

### Audio Issues
1. Check audio permissions: `sudo usermod -a -G audio pi`
2. Test audio: `speaker-test -t wav -c 2 -l 1`
3. Check pygame: `python3 -c "import pygame; print('pygame OK')"`

### LED Issues
1. Check GPIO permissions: `sudo usermod -a -G gpio pi`
2. Test LED: `python3 test_usb_led.py`
3. Check wiring and resistors

## System Status

### Normal Operation
- Ready LED: ON
- USB LED: ON (if USB drive mounted)
- ESP32 receiver LED: 25% brightness (linked)
- ESP32 transmitter LED: 25% brightness (linked)

### Button Press
- Ready LED: Blinks
- ESP32 LEDs: Full brightness briefly
- Sound plays
- Log entry created

### Error States
- Ready LED: OFF (system not ready)
- ESP32 LEDs: Double blink (no connection)
- Check serial output for error messages

## File Structure
```
~/WRB/
├── Pi_Script_Enhanced.py    # Main script
├── test_usb_led.py          # USB LED test
├── test_system_integration.py # System test
├── button_log.txt           # Button press log
└── sounds/                  # Sound files (optional)
    ├── button1.wav
    ├── button2.wav
    ├── hold1.wav
    ├── hold2.wav
    └── ...
```

## Support

If issues persist:
1. Run integration test and note failures
2. Check serial output from both ESP32s
3. Verify all connections and power supplies
4. Check log files for error messages

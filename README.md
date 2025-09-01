# ESP32 Wireless Button System

A battery-efficient wireless button system using **Seeed Studio XIAO ESP32C3** devices with ESP-NOW protocol. The system consists of transmitters (with buttons) and a receiver that processes button presses.

## System Overview

- **Transmitters**: Seeed Studio XIAO ESP32C3 devices with buttons that send button press events wirelessly
- **Receiver**: Seeed Studio XIAO ESP32C3 device that receives button presses and can trigger actions
- **Protocol**: ESP-NOW for low-latency, direct communication
- **Power Management**: Advanced sleep modes for extended battery life
- **Security**: MAC address-based authentication to ensure devices only communicate with authorized partners

## Files

- `Transmitter_ESP32.ino` - Transmitter code (for button devices)
- `Receiver ESP32` - Receiver code (for central device)
- `Transmitter ESP32.c` - Original transmitter file (legacy)
- `MAC_Finder.ino` - Utility to find device MAC addresses

## Key Improvements Made

### 1. **Proper System Architecture**
- Separated transmitter and receiver functionality
- Clear distinction between sending and receiving devices
- Proper message handling and acknowledgment system

### 2. **Enhanced Reliability**
- **Retry Mechanism**: Button presses are retried up to 3 times if transmission fails
- **Error Handling**: Better error reporting and handling of ESP-NOW failures
- **Link Monitoring**: Continuous ping/ack system to monitor connection health

### 3. **Improved Power Management**
- **Light Sleep**: Proper implementation of light sleep during breathing LED phase
- **Deep Sleep**: Automatic deep sleep after 15 minutes of inactivity
- **Wake-up Handling**: GPIO wake-up from both light and deep sleep modes

### 4. **Better LED Feedback**
- **Transmitter**: Shows connection status and button activity
- **Receiver**: Shows connected transmitters and received button presses
- **Breathing Effect**: Smooth LED breathing during low-power mode

### 5. **Multi-Transmitter Support**
- Receiver can handle up to 10 transmitters simultaneously
- Automatic transmitter discovery and management
- Individual link status tracking

### 6. **MAC Address Security**
- **Transmitter**: Only accepts responses from authorized receiver MAC
- **Receiver**: Only accepts messages from pre-configured transmitter MACs
- **Unauthorized Device Rejection**: Logs and ignores messages from unknown devices

## Hardware Setup

### Transmitter
- **Board**: Seeed Studio XIAO ESP32C3
- **Buttons**: 2 buttons connected to D1 and D2 (to GND)
- **Status LED**: On D10
- **Power**: Battery recommended for portability (3.3V)

### Receiver
- **Board**: Seeed Studio XIAO ESP32C3
- **Status LED**: On D10
- **Power**: USB or battery (3.3V)

### Pin Connections
- `LED_PIN`: D10 (status LED)
- `BTN1_PIN`: D1 (button 1)
- `BTN2_PIN`: D2 (button 2)

**Note**: The XIAO ESP32C3 uses the Dx pin aliases which map to the actual GPIO pins on the board.

## Configuration

### MAC Address Security Setup

**IMPORTANT**: You must configure the correct MAC addresses for your devices to communicate.

#### Step 1: Find Your Device MAC Addresses
1. Use the included `MAC_Finder.ino` sketch to find your device MAC addresses:
   - Open `MAC_Finder.ino` in Arduino IDE
   - Select your board (XIAO_ESP32C3)
   - Upload the sketch
   - Open Serial Monitor (115200 baud)
   - The MAC address will be displayed in the correct format for copying to your code

Alternatively, you can use this simple sketch:
```cpp
#include <WiFi.h>
void setup() {
  Serial.begin(115200);
  Serial.printf("MAC Address: %s\n", WiFi.macAddress().c_str());
}
void loop() {}
```

#### Step 2: Configure the Receiver
In `Receiver ESP32`, update the allowed transmitter MACs:
```cpp
uint8_t ALLOWED_TX_MACS[][6] = {
  { 0x58,0x8C,0x81,0x9F,0x22,0xAC }, // Your transmitter MAC
  // Add more transmitters as needed
};
```

#### Step 3: Configure the Transmitter
In `Transmitter_ESP32.ino`, update the receiver MAC:
```cpp
uint8_t RX_MAC[] = { 0x58,0x8C,0x81,0x9E,0x30,0x10 }; // Your receiver MAC
```

### Pin Configuration
- `LED_PIN`: D10 (status LED)
- `BTN1_PIN`: D1 (button 1)
- `BTN2_PIN`: D2 (button 2)

### Power Settings
- Light sleep after 5 minutes of inactivity
- Deep sleep after 15 minutes of inactivity
- Breathing LED during light sleep phase

## Usage

### Arduino IDE Setup
1. **Install ESP32 Board Package**:
   - Open Arduino IDE
   - Go to File → Preferences
   - Add this URL to "Additional Board Manager URLs": `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
   - Go to Tools → Board → Board Manager
   - Search for "ESP32" and install "ESP32 by Espressif Systems"

2. **Select Board**:
   - Tools → Board → ESP32 Arduino → XIAO_ESP32C3
   - Set Upload Speed to 921600
   - Set CPU Frequency to 160MHz
   - Set Flash Frequency to 80MHz
   - Set Flash Mode to QIO
   - Set Flash Size to 4MB

### Flashing the Code
1. **First**: Find your device MAC addresses using the `MAC_Finder.ino` sketch
2. **Second**: Update the MAC addresses in both files
3. **Third**: Flash `Transmitter_ESP32.ino` to your transmitter XIAO ESP32C3
4. **Fourth**: Flash `Receiver ESP32` to your receiver XIAO ESP32C3

### Operation
1. **Transmitter**: Press buttons to send events to receiver
2. **Receiver**: Receives button presses and can trigger actions
3. **LED Indicators**:
   - **Transmitter**: 
     - Solid 100%: Button held
     - 25%: Connected to receiver
     - Double blink: No connection
     - Breathing: Low-power mode
   - **Receiver**:
     - Solid 100%: Button press received
     - 25%: Transmitters connected
     - Double blink: No transmitters connected

### Serial Output
Both devices provide detailed serial output for debugging:
- Connection status
- Button press events
- Error messages
- Power management events
- **Security events**: Rejected unauthorized MAC addresses

## Security Features

### MAC Address Validation
- **Transmitter**: Only processes ACK messages from the configured receiver MAC
- **Receiver**: Only processes messages from pre-configured transmitter MACs
- **Logging**: Both devices log rejected messages for debugging

### Unauthorized Device Protection
- Messages from unknown MAC addresses are ignored
- Serial output shows rejected MAC addresses
- No impact on authorized device communication

## Power Consumption

- **Active Mode**: ~50-100mA
- **Light Sleep**: ~5-10mA
- **Deep Sleep**: ~10-50μA
- **Breathing Mode**: ~20-30mA (with periodic light sleep)

## Troubleshooting

### Common Issues

1. **No Connection**
   - Check MAC addresses are correctly configured
   - Ensure both devices are on the same WiFi channel (default: 1)
   - Verify ESP-NOW initialization
   - Check serial output for rejected MAC addresses

2. **Button Not Responding**
   - Check button wiring (should be to GND with INPUT_PULLUP)
   - Verify pin definitions
   - Check serial output for error messages

3. **High Power Consumption**
   - Ensure sleep modes are enabled (`ENABLE_SLEEP = true`)
   - Check for stuck loops or delays
   - Verify LED configuration

4. **Missed Button Presses**
   - Increase retry count if needed
   - Check for interference on WiFi channel
   - Verify receiver is processing messages

5. **Security Issues**
   - Verify MAC addresses match between devices
   - Check serial output for "Rejected message from unauthorized MAC"
   - Ensure transmitter MAC is in receiver's allowed list

### Debugging
- Monitor serial output on both devices
- Check LED indicators for status
- Use WiFi analyzer to check for channel conflicts
- Look for security rejection messages

## Customization

### Adding More Buttons
1. Define additional button pins
2. Add button debouncer structures
3. Update button handling in loop()

### Adding More Transmitters
1. Add transmitter MAC to `ALLOWED_TX_MACS` array in receiver
2. Update `NUM_ALLOWED_TXS` if needed
3. Flash updated receiver code

### Changing Power Settings
Modify these constants in the transmitter:
```cpp
const uint32_t IDLE_LIGHT_MS = 5UL * 60UL * 1000UL;  // Light sleep delay
const uint32_t IDLE_DEEP_MS = 15UL * 60UL * 1000UL;  // Deep sleep delay
```

### Adding Actions
In the receiver, add your desired actions when button presses are received:
```cpp
case MSG_BTN:
  if (len >= 2) {
    uint8_t btnId = data[1];
    // Add your custom actions here
    if (btnId == 1) {
      // Handle button 1 press
    } else if (btnId == 2) {
      // Handle button 2 press
    }
  }
  break;
```

## License

This project is open source. Feel free to modify and distribute as needed.

## Raspberry Pi Integration

### Enhanced Pi Script

The system includes an enhanced Raspberry Pi script that works seamlessly with the ESP32 receiver to play sound effects based on button presses.

#### Features:
- **ESP32 Message Parsing**: Automatically detects and parses ESP32 button messages
- **Audio Playback**: Plays different sounds for correct/incorrect answers
- **USB Hot-Swapping**: Automatically detects and uses sound files from USB drives
- **USB LED Indicator**: Visual indicator showing when USB drives are mounted
- **Logging**: Comprehensive logging of all button presses and system events
- **LED Feedback**: Visual feedback when buttons are pressed
- **Auto-Restart**: Automatically restarts if the ESP32 connection is lost
- **Systemd Service**: Runs as a system service that starts on boot

#### Installation:

1. **Copy the enhanced files to your Pi:**
   ```bash
   # Copy these files to your Raspberry Pi:
   # - Pi_Script_Enhanced.py
   # - mattsfx-enhanced.service
   # - install_enhanced.sh
   ```

2. **Run the installation script:**
   ```bash
   chmod +x install_enhanced.sh
   ./install_enhanced.sh
   ```

3. **Connect your ESP32 receiver:**
   - Connect the ESP32 receiver to the Pi via USB
   - The service will automatically detect and connect to it

#### Usage:

1. **Sound Files**: Place your sound files in `~/mattsfx/sounds/`
   - `right1.wav`, `right2.wav`, etc. for correct answers
   - `wrong1.wav`, `wrong2.wav`, etc. for incorrect answers
   - Or use a USB drive with `right*.wav` and `wrong*.wav` files

2. **Button Mapping**:
   - **Button 1** (D1) → Plays "right" sound
   - **Button 2** (D2) → Plays "wrong" sound

3. **Monitoring**:
   ```bash
   # Check service status
   sudo systemctl status mattsfx-enhanced.service
   
   # View real-time logs
   sudo journalctl -u mattsfx-enhanced.service -f
   
   # View button press history
   tail -f ~/mattsfx/button_log.txt
   ```

#### Configuration:

The script automatically detects:
- ESP32 serial connection (tries multiple ports)
- Sound files from USB drives or local storage
- LED feedback on GPIO pin 18
- USB drive status on GPIO pin 23

You can customize the configuration by editing the variables at the top of `Pi_Script_Enhanced.py`:
```python
BAUD = 115200                    # Serial baud rate
SERIAL = "/dev/ttyACM0"          # Default serial port
READY_PIN = 18                   # Ready LED pin
USB_LED_PIN = 23                 # USB drive LED pin
LOG_FILE = "/home/pi/mattsfx/button_log.txt"  # Log file location
```

#### LED Indicators:

The system uses two LEDs for status indication:

1. **Ready LED (GPIO 18)**: 
   - **ON**: System ready and connected to ESP32
   - **OFF**: System starting up or disconnected
   - **Blink**: Button press detected

2. **USB LED (GPIO 23)**:
   - **ON**: USB drive is mounted
   - **OFF**: No USB drive mounted
   - **Blink**: USB drive with sound files detected

#### Testing USB LED:

You can test the USB LED functionality independently using the test script:

```bash
# Run the USB LED test script
python3 test_usb_led.py
```

This script will:
- Check for mounted USB drives
- Control the USB LED based on mount status
- Test sound file detection
- Provide feedback in simulation mode if gpiozero is not available

#### Troubleshooting:

1. **No Sound**: Check audio permissions and pygame installation
2. **No Serial Connection**: Verify ESP32 is connected and check serial port
3. **Service Won't Start**: Check logs with `sudo journalctl -u mattsfx-enhanced.service`
4. **Permission Errors**: Ensure pi user is in the audio group
5. **USB LED Not Working**: Check GPIO pin 23 connections and run test script

The enhanced Pi script provides a complete, production-ready solution for integrating your ESP32 wireless button system with audio feedback on a Raspberry Pi.

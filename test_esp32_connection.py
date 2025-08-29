#!/usr/bin/env python3
"""
Test script for ESP32 connection and message parsing
Use this to verify your ESP32 receiver is working correctly
"""

import serial
import time
import sys

def test_esp32_connection():
    """Test ESP32 serial connection and message parsing"""
    
    # Try different serial ports
    ports = ["/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1", "/dev/serial0", "/dev/ttyAMA0", "/dev/ttyS0"]
    
    ser = None
    for port in ports:
        try:
            print(f"Trying {port}...")
            ser = serial.Serial(port, 115200, timeout=1)
            print(f"✓ Connected to ESP32 on {port}")
            break
        except:
            print(f"✗ Failed to connect to {port}")
            continue
    
    if not ser:
        print("❌ Could not connect to ESP32 on any port")
        print("Please check:")
        print("1. ESP32 is connected via USB")
        print("2. ESP32 receiver code is uploaded")
        print("3. Serial monitor is not open in Arduino IDE")
        return False
    
    print("\n=== ESP32 Connection Test ===")
    print("Waiting for ESP32 messages...")
    print("Press buttons on your ESP32 transmitter to test")
    print("Press Ctrl+C to exit\n")
    
    try:
        while True:
            if ser.in_waiting > 0:
                line = ser.readline().decode(errors="ignore").strip()
                if line:
                    print(f"ESP32: {line}")
                    
                    # Test message parsing
                    if "RX: BTN" in line:
                        if "BTN1" in line:
                            print("  → Detected RIGHT button press")
                        elif "BTN2" in line:
                            print("  → Detected WRONG button press")
                    elif "Authorized transmitter connected" in line:
                        print("  → Transmitter connected")
                    elif "Rejected message from unauthorized MAC" in line:
                        print("  → Security alert: Unauthorized device")
                    elif "Status:" in line:
                        print("  → Status update")
                    elif "Receiver ready" in line:
                        print("  → Receiver is ready")
            
            time.sleep(0.01)
            
    except KeyboardInterrupt:
        print("\n\nTest completed.")
        ser.close()
        return True
    except Exception as e:
        print(f"\nError: {e}")
        ser.close()
        return False

if __name__ == "__main__":
    success = test_esp32_connection()
    sys.exit(0 if success else 1)

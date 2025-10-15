#!/usr/bin/env python3
"""
Script to help find the correct MAC addresses for ESP32 devices
"""
import subprocess
import re

def find_esp32_macs():
    """Find ESP32 MAC addresses from serial output"""
    print("🔍 ESP32 MAC Address Finder")
    print("=" * 50)
    print()
    print("To find your ESP32 MAC addresses:")
    print()
    print("1. 📡 TRANSMITTER MAC:")
    print("   - Connect transmitter to USB")
    print("   - Open Serial Monitor (115200 baud)")
    print("   - Look for line like: 'MAC Address: 58:8C:81:XX:XX:XX'")
    print("   - Copy the MAC address")
    print()
    print("2. 📻 RECEIVER MAC:")
    print("   - Connect receiver to USB")
    print("   - Open Serial Monitor (115200 baud)")
    print("   - Look for line like: 'MAC Address: 58:8C:81:XX:XX:XX'")
    print("   - Copy the MAC address")
    print()
    print("3. 🔧 UPDATE THE CODE:")
    print("   - Update TRANSMITTER: RX_MAC[] with receiver's MAC")
    print("   - Update RECEIVER: ALLOWED_TX_MACS[] with transmitter's MAC")
    print()
    print("📋 CURRENT SETTINGS:")
    print("   Transmitter trying to reach: 58:8C:81:9E:30:10")
    print("   Receiver expecting from:     58:8C:81:9F:22:AC")
    print()
    print("❌ These don't match! That's why they won't connect.")
    print()
    print("💡 QUICK FIX:")
    print("   If you know your actual MAC addresses:")
    print("   1. Update Transmitter_ESP32.ino line 17")
    print("   2. Update Receiver ESP32 line 13")
    print("   3. Upload both devices")
    print()
    print("🔧 Or use this format:")
    print("   uint8_t RX_MAC[] = { 0x58,0x8C,0x81,0x9E,0x30,0x10 };")
    print("   uint8_t ALLOWED_TX_MACS[][6] = {")
    print("     { 0x58,0x8C,0x81,0x9F,0x22,0xAC },")
    print("   };")

def check_serial_devices():
    """Check for connected serial devices"""
    print("\n🔍 Checking for connected ESP32 devices...")
    try:
        # Check common ESP32 serial devices
        import serial.tools.list_ports
        ports = serial.tools.list_ports.comports()
        
        esp32_ports = []
        for port in ports:
            if any(keyword in port.description.lower() for keyword in ['esp32', 'cp210', 'ch340', 'ftdi']):
                esp32_ports.append((port.device, port.description))
        
        if esp32_ports:
            print("📱 Found potential ESP32 devices:")
            for device, description in esp32_ports:
                print(f"   {device}: {description}")
            print()
            print("💡 Connect to these ports in Serial Monitor to find MAC addresses")
        else:
            print("❌ No ESP32 devices detected")
            print("   Make sure ESP32 devices are connected via USB")
            
    except ImportError:
        print("⚠️  pyserial not installed, cannot scan for devices")
        print("   Install with: pip install pyserial")

if __name__ == "__main__":
    find_esp32_macs()
    check_serial_devices()

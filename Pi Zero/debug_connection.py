#!/usr/bin/env python3
"""
Debug ESP32 connection issues
"""
import serial
import time

def check_serial_connection(port="/dev/ttyACM0", baud=115200):
    """Check if ESP32 is connected and responsive"""
    try:
        print(f"🔍 Checking connection to {port}...")
        
        ser = serial.Serial(port, baud, timeout=1)
        time.sleep(2)  # Wait for ESP32 to boot
        
        print("✅ Serial port opened successfully")
        
        # Send a simple command to check if device is responsive
        ser.write(b'\n')
        time.sleep(0.1)
        
        # Read any available output
        if ser.in_waiting > 0:
            output = ser.read(ser.in_waiting).decode('utf-8', errors='ignore')
            print(f"📱 Device output: {output.strip()}")
        else:
            print("⚠️  No output from device")
        
        ser.close()
        return True
        
    except serial.SerialException as e:
        print(f"❌ Serial connection failed: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

def list_serial_devices():
    """List available serial devices"""
    print("🔍 Available serial devices:")
    try:
        import serial.tools.list_ports
        ports = serial.tools.list_ports.comports()
        
        if ports:
            for port in ports:
                print(f"  📱 {port.device}: {port.description}")
        else:
            print("  ❌ No serial devices found")
            
    except ImportError:
        print("  ⚠️  pyserial not installed")

def main():
    print("🔧 ESP32 Connection Debug Tool")
    print("=" * 40)
    print()
    
    # List available devices
    list_serial_devices()
    print()
    
    # Check common ESP32 ports
    common_ports = ["/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1"]
    
    print("🔍 Testing common ESP32 ports...")
    connected_devices = []
    
    for port in common_ports:
        if check_serial_connection(port):
            connected_devices.append(port)
        print()
    
    if connected_devices:
        print(f"✅ Found {len(connected_devices)} connected ESP32 device(s):")
        for device in connected_devices:
            print(f"  📱 {device}")
        
        print()
        print("🔧 Next steps:")
        print("1. Open Serial Monitor on each device")
        print("2. Look for MAC addresses and connection status")
        print("3. Check for error messages")
        print("4. Verify ESP-NOW initialization")
        
    else:
        print("❌ No ESP32 devices found")
        print()
        print("🔧 Troubleshooting:")
        print("1. Check USB connections")
        print("2. Install ESP32 drivers if needed")
        print("3. Try different USB ports")
        print("4. Check device manager (Windows) or lsusb (Linux)")

if __name__ == "__main__":
    main()

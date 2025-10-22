#!/usr/bin/env python3
"""
System Monitor for ESP32 Wireless Button System
Simple monitoring script to check system status
"""

import os
import subprocess
import time
from datetime import datetime

def check_service_status():
    """Check if the systemd service is running"""
    try:
        result = subprocess.run(['systemctl', 'is-active', 'WRB-enhanced.service'], 
                              capture_output=True, text=True, timeout=5)
        return result.stdout.strip() == 'active'
    except Exception as e:
        print(f"Error checking service status: {e}")
        return False

def check_serial_ports():
    """Check for available serial ports"""
    ports = []
    for port in ['/dev/ttyACM0', '/dev/ttyACM1', '/dev/ttyUSB0', '/dev/ttyUSB1']:
        if os.path.exists(port):
            ports.append(port)
    return ports

def check_sound_files():
    """Check for sound files"""
    sounds_dir = os.path.expanduser("~/WRB/sounds")
    if not os.path.exists(sounds_dir):
        return []
    
    sound_files = []
    for pattern in ["button1*.wav", "button2*.wav", "hold1*.wav", "hold2*.wav"]:
        import glob
        files = glob.glob(os.path.join(sounds_dir, pattern))
        sound_files.extend(files)
    
    return sound_files

def main():
    """Main monitoring function"""
    print("🔍 WRB System Monitor")
    print("=" * 50)
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Check service status
    print("📊 Service Status:")
    if check_service_status():
        print("✅ WRB-enhanced.service is running")
    else:
        print("❌ WRB-enhanced.service is not running")
    print()
    
    # Check serial ports
    print("🔌 Serial Ports:")
    ports = check_serial_ports()
    if ports:
        for port in ports:
            print(f"✅ {port} is available")
    else:
        print("⚠️  No serial ports found (ESP32 may not be connected)")
    print()
    
    # Check sound files
    print("🎵 Sound Files:")
    sound_files = check_sound_files()
    if sound_files:
        for file in sound_files:
            print(f"✅ {os.path.basename(file)}")
    else:
        print("⚠️  No sound files found in ~/WRB/sounds/")
    print()
    
    # Check WRB directory
    print("📁 WRB Directory:")
    wrb_dir = os.path.expanduser("~/WRB")
    if os.path.exists(wrb_dir):
        print(f"✅ WRB directory exists: {wrb_dir}")
        
        # List files
        files = os.listdir(wrb_dir)
        for file in files:
            if file.endswith(('.py', '.txt', '.wav')):
                print(f"  📄 {file}")
    else:
        print("❌ WRB directory not found")
    print()
    
    print("💡 Useful Commands:")
    print("  Check service:     sudo systemctl status WRB-enhanced.service")
    print("  View logs:         sudo journalctl -u WRB-enhanced.service -f")
    print("  Restart service:   sudo systemctl restart WRB-enhanced.service")
    print("  Test connection:   python3 ~/WRB/PiScript")

if __name__ == "__main__":
    main()
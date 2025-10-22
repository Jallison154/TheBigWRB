#!/usr/bin/env python3
"""
WRB System Test Script
Tests all components of the WRB system
"""

import os
import sys
import time
import serial
import pygame
import glob
import subprocess
from gpiozero import LED, PWMLED

def test_gpio():
    """Test GPIO functionality"""
    print("🔌 Testing GPIO...")
    
    try:
        # Test LED pins
        ready_led = LED(23)
        usb_led = LED(24)
        
        print("✅ GPIO LEDs initialized")
        
        # Test LED functionality
        print("🔍 Testing Ready LED (GPIO 23)...")
        ready_led.on()
        time.sleep(1)
        ready_led.off()
        print("✅ Ready LED test complete")
        
        print("🔍 Testing USB LED (GPIO 24)...")
        usb_led.on()
        time.sleep(1)
        usb_led.off()
        print("✅ USB LED test complete")
        
        return True
        
    except Exception as e:
        print(f"❌ GPIO test failed: {e}")
        return False

def test_audio():
    """Test audio functionality"""
    print("🔊 Testing Audio...")
    
    try:
        # Initialize pygame mixer
        pygame.mixer.pre_init(frequency=44100, size=-16, channels=2, buffer=512)
        pygame.mixer.init()
        print("✅ Pygame mixer initialized")
        
        # Test audio device
        print("🔍 Testing audio device...")
        pygame.mixer.get_init()
        print("✅ Audio device working")
        
        return True
        
    except Exception as e:
        print(f"❌ Audio test failed: {e}")
        return False

def test_serial():
    """Test serial communication"""
    print("📡 Testing Serial Communication...")
    
    ports_to_try = ["/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1"]
    
    for port in ports_to_try:
        if os.path.exists(port):
            try:
                ser = serial.Serial(port, 115200, timeout=1)
                print(f"✅ Serial port {port} is available")
                ser.close()
                return True
            except Exception as e:
                print(f"⚠️  Serial port {port} exists but not accessible: {e}")
    
    print("❌ No serial ports found")
    return False

def test_sound_files():
    """Test sound file detection"""
    print("🎵 Testing Sound Files...")
    
    sounds_dir = os.path.expanduser("~/WRB/sounds")
    if not os.path.exists(sounds_dir):
        print(f"❌ Sounds directory not found: {sounds_dir}")
        return False
    
    print(f"✅ Sounds directory exists: {sounds_dir}")
    
    # Check for sound files
    sound_patterns = ["button1*.wav", "button2*.wav", "hold1*.wav", "hold2*.wav"]
    found_files = []
    
    for pattern in sound_patterns:
        files = glob.glob(os.path.join(sounds_dir, pattern))
        if files:
            found_files.extend(files)
            print(f"✅ Found {pattern}: {files[0]}")
        else:
            print(f"⚠️  No files found for {pattern}")
    
    if found_files:
        print(f"✅ Total sound files found: {len(found_files)}")
        return True
    else:
        print("❌ No sound files found")
        return False

def test_usb_mounting():
    """Test USB mounting detection"""
    print("💾 Testing USB Mounting...")
    
    base = "/media"
    if not os.path.exists(base):
        print(f"❌ Media directory not found: {base}")
        return False
    
    try:
        usb_dirs = [os.path.join(base, d) for d in sorted(os.listdir(base)) 
                   if os.path.isdir(os.path.join(base, d)) and os.path.ismount(os.path.join(base, d))]
        
        if usb_dirs:
            print(f"✅ USB drives found: {usb_dirs}")
            return True
        else:
            print("⚠️  No USB drives mounted")
            return False
            
    except Exception as e:
        print(f"❌ USB mounting test failed: {e}")
        return False

def test_service():
    """Test systemd service"""
    print("⚙️ Testing Systemd Service...")
    
    try:
        result = subprocess.run(['systemctl', 'is-active', 'WRB-enhanced.service'], 
                              capture_output=True, text=True, timeout=5)
        
        if result.stdout.strip() == 'active':
            print("✅ WRB-enhanced.service is running")
            return True
        else:
            print(f"⚠️  WRB-enhanced.service status: {result.stdout.strip()}")
            return False
            
    except Exception as e:
        print(f"❌ Service test failed: {e}")
        return False

def main():
    """Main test function"""
    print("🧪 WRB System Test")
    print("=" * 50)
    print()
    
    tests = [
        ("GPIO", test_gpio),
        ("Audio", test_audio),
        ("Serial", test_serial),
        ("Sound Files", test_sound_files),
        ("USB Mounting", test_usb_mounting),
        ("Service", test_service)
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        print(f"🔍 Running {test_name} test...")
        results[test_name] = test_func()
        print()
    
    # Summary
    print("📊 Test Results Summary:")
    print("=" * 30)
    
    passed = 0
    total = len(tests)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:15} {status}")
        if result:
            passed += 1
    
    print()
    print(f"📈 Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! System is ready.")
    else:
        print("⚠️  Some tests failed. Check the issues above.")
    
    print()
    print("💡 Troubleshooting Tips:")
    print("  - GPIO issues: Check wiring and permissions")
    print("  - Audio issues: Check audio permissions with 'groups $USER'")
    print("  - Serial issues: Check ESP32 connection and permissions")
    print("  - Sound files: Add .wav files to ~/WRB/sounds/")
    print("  - USB issues: Check USB drive mounting")
    print("  - Service issues: Check with 'sudo systemctl status WRB-enhanced.service'")

if __name__ == "__main__":
    main()

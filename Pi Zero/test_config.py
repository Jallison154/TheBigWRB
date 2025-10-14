#!/usr/bin/env python3
"""
Test script to verify PiScript configuration and dependencies
Run this to check if everything is working before running the main script
"""

import sys
import os

def test_imports():
    """Test if all required modules can be imported"""
    print("=== Testing Python Imports ===")
    
    try:
        import pygame
        print(f"✅ pygame {pygame.version.ver}")
    except ImportError as e:
        print(f"❌ pygame import failed: {e}")
        return False
    
    try:
        import serial
        print("✅ pyserial")
    except ImportError as e:
        print(f"❌ pyserial import failed: {e}")
        return False
    
    try:
        from gpiozero import LED
        print("✅ gpiozero")
    except ImportError as e:
        print(f"❌ gpiozero import failed: {e}")
        return False
    
    return True

def test_config():
    """Test if config.py can be loaded"""
    print("\n=== Testing Configuration ===")
    
    try:
        from config import *
        print("✅ config.py loaded successfully")
        print(f"   BAUD: {BAUD}")
        print(f"   SERIAL: {SERIAL}")
        print(f"   READY_PIN: {READY_PIN}")
        print(f"   MIX_FREQ: {MIX_FREQ}")
        print(f"   MIX_BUF: {MIX_BUF}")
        return True
    except ImportError as e:
        print(f"❌ config.py import failed: {e}")
        return False
    except Exception as e:
        print(f"❌ config.py error: {e}")
        return False

def test_audio():
    """Test audio initialization"""
    print("\n=== Testing Audio ===")
    
    try:
        import pygame
        os.environ.setdefault("SDL_AUDIODRIVER", "alsa")
        os.environ.setdefault("AUDIODEV", "plughw:0,0")
        
        pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=512)
        print("✅ pygame mixer initialized successfully")
        
        # Test creating a simple sound
        import numpy as np
        sample_rate = 44100
        duration = 0.1
        frequency = 440
        frames = int(sample_rate * duration)
        arr = np.sin(2 * np.pi * frequency * np.linspace(0, duration, frames))
        arr = (arr * 32767).astype(np.int16)
        
        sound = pygame.sndarray.make_sound(arr)
        print("✅ Sound object created successfully")
        
        return True
    except Exception as e:
        print(f"❌ Audio test failed: {e}")
        return False

def test_gpio():
    """Test GPIO access"""
    print("\n=== Testing GPIO ===")
    
    try:
        from gpiozero import LED
        # Test creating an LED object (don't actually control it)
        led = LED(23, active_high=False)
        print("✅ GPIO LED object created successfully")
        return True
    except Exception as e:
        print(f"❌ GPIO test failed: {e}")
        return False

def test_serial():
    """Test serial port availability"""
    print("\n=== Testing Serial Ports ===")
    
    serial_ports = ["/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1"]
    available_ports = []
    
    for port in serial_ports:
        if os.path.exists(port):
            available_ports.append(port)
            print(f"✅ {port} exists")
        else:
            print(f"❌ {port} not found")
    
    if available_ports:
        print(f"✅ Found {len(available_ports)} serial port(s)")
        return True
    else:
        print("❌ No serial ports found")
        return False

def main():
    print("WRB PiScript Configuration Test")
    print("=" * 40)
    
    all_tests_passed = True
    
    # Run all tests
    if not test_imports():
        all_tests_passed = False
    
    if not test_config():
        all_tests_passed = False
    
    if not test_audio():
        all_tests_passed = False
    
    if not test_gpio():
        all_tests_passed = False
    
    if not test_serial():
        all_tests_passed = False
    
    print("\n" + "=" * 40)
    if all_tests_passed:
        print("🎉 All tests passed! PiScript should work correctly.")
        print("\nYou can now run: python3 PiScript")
    else:
        print("❌ Some tests failed. Please fix the issues above.")
        print("\nCommon fixes:")
        print("- Install missing packages: sudo apt install python3-pygame python3-serial python3-gpiozero")
        print("- Add user to audio group: sudo usermod -a -G audio $USER")
        print("- Reboot after adding user to audio group")

if __name__ == "__main__":
    main()

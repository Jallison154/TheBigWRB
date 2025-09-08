#!/usr/bin/env python3
"""
Test script for USB LED functionality
This script tests the USB LED indicator without running the full system
"""

import os
import time
import glob

# Configuration
USB_LED_PIN = 23
USB_LED_ACTIVE_LOW = True

def usb_mount_dirs():
    """Find mounted USB drives"""
    base = "/media"
    if not os.path.isdir(base):
        return []
    
    mounts = []
    for d in sorted(os.listdir(base)):
        path = os.path.join(base, d)
        if os.path.isdir(path) and os.path.ismount(path):
            mounts.append(path)
    return mounts

def update_usb_led(mounts):
    """Update USB LED based on mount status"""
    try:
        from gpiozero import LED
        usb_led = LED(USB_LED_PIN, active_high=(not USB_LED_ACTIVE_LOW))
        
        if mounts:
            usb_led.on()  # USB drive is mounted
            print(f"USB LED ON - {len(mounts)} USB drive(s) mounted")
        else:
            usb_led.off()  # No USB drive mounted
            print("USB LED OFF - No USB drives mounted")
            
    except ImportError:
        print("gpiozero not available - LED simulation mode")
        if mounts:
            print(f"LED would be ON - {len(mounts)} USB drive(s) mounted")
        else:
            print("LED would be OFF - No USB drives mounted")
    except Exception as e:
        print(f"USB LED control failed: {e}")

def blink_usb_led():
    """Blink the USB LED to indicate USB drive activity"""
    try:
        from gpiozero import LED
        usb_led = LED(USB_LED_PIN, active_high=(not USB_LED_ACTIVE_LOW))
        
        usb_led.off()
        time.sleep(0.1)
        usb_led.on()
        print("USB LED blinked")
        
    except ImportError:
        print("gpiozero not available - LED simulation mode")
        print("LED would blink")
    except Exception as e:
        print(f"USB LED blink failed: {e}")

def test_usb_detection():
    """Test USB drive detection and LED control"""
    print("=== USB LED Test Script ===")
    print(f"USB LED Pin: {USB_LED_PIN}")
    print(f"Active Low: {USB_LED_ACTIVE_LOW}")
    print()
    
    # Test initial state
    print("1. Testing initial USB detection...")
    mounts = usb_mount_dirs()
    update_usb_led(mounts)
    
    if mounts:
        print(f"   Found USB drives: {mounts}")
        
        # Test sound file detection
        print("\n2. Testing sound file detection...")
        for mnt in mounts:
            B1 = sorted(glob.glob(os.path.join(mnt, "button1*.wav")))
            B2 = sorted(glob.glob(os.path.join(mnt, "button2*.wav")))
            H1 = sorted(glob.glob(os.path.join(mnt, "hold1*.wav")))
            H2 = sorted(glob.glob(os.path.join(mnt, "hold2*.wav")))
            print(f"   {mnt}: {len(B1)} button1, {len(B2)} button2, {len(H1)} hold1, {len(H2)} hold2 sounds")
            
            if B1 or B2 or H1 or H2:
                print("   Blinking USB LED...")
                blink_usb_led()
                break
    else:
        print("   No USB drives found")
    
    print("\n3. Test complete!")
    print("   - LED ON = USB drive mounted")
    print("   - LED OFF = No USB drive mounted")
    print("   - LED blink = USB drive with sound files detected")

if __name__ == "__main__":
    test_usb_detection()

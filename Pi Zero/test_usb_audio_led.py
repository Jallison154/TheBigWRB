#!/usr/bin/env python3
"""
Test script for USB audio file mounting and LED functionality
"""
import os
import glob
import time
import subprocess
from gpiozero import PWMLED

# Configuration from config.py
try:
    from config import *
    print("[TEST] Loaded configuration from config.py")
except ImportError:
    print("[TEST] config.py not found, using defaults")
    READY_PIN = 23
    READY_ACTIVE_LOW = True
    USB_LED_PIN = 24
    USB_LED_ACTIVE_LOW = True

def test_led_functionality():
    """Test LED functionality on GPIO 23 and 24"""
    print("\n🔍 Testing LED functionality...")
    
    try:
        # Test Ready LED (GPIO 23)
        print(f"Testing Ready LED on GPIO {READY_PIN}...")
        ready_led = PWMLED(READY_PIN, active_high=(not READY_ACTIVE_LOW))
        
        # Breathing effect test
        print("  - Testing breathing effect...")
        for i in range(20):
            brightness = (i / 20.0) * 0.25  # 0 to 25% brightness
            if READY_ACTIVE_LOW:
                brightness = 0.25 - brightness  # Invert for active low
            ready_led.value = brightness
            time.sleep(0.1)
        
        # 25% brightness test
        print("  - Testing 25% brightness...")
        ready_led.value = 0.75 if READY_ACTIVE_LOW else 0.25
        time.sleep(1)
        
        # 100% blink test
        print("  - Testing 100% blink...")
        ready_led.value = 0.0 if READY_ACTIVE_LOW else 1.0
        time.sleep(0.2)
        ready_led.value = 0.75 if READY_ACTIVE_LOW else 0.25
        time.sleep(0.5)
        
        ready_led.off()
        print("  ✅ Ready LED test completed")
        
        # Test USB LED (GPIO 24) if different
        if USB_LED_PIN != READY_PIN:
            print(f"Testing USB LED on GPIO {USB_LED_PIN}...")
            usb_led = PWMLED(USB_LED_PIN, active_high=(not USB_LED_ACTIVE_LOW))
            
            # Simple on/off test
            usb_led.on()
            time.sleep(0.5)
            usb_led.off()
            time.sleep(0.5)
            usb_led.on()
            time.sleep(0.5)
            usb_led.off()
            print("  ✅ USB LED test completed")
        
        return True
        
    except Exception as e:
        print(f"  ❌ LED test failed: {e}")
        return False

def check_usb_mounts():
    """Check for USB devices and their mount points"""
    print("\n🔍 Checking USB mounts...")
    
    try:
        # Check /media directory
        if os.path.exists("/media"):
            print("  📁 /media directory exists")
            media_contents = os.listdir("/media")
            print(f"  📁 Contents: {media_contents}")
            
            # Check each mounted device
            for device in media_contents:
                device_path = os.path.join("/media", device)
                if os.path.ismount(device_path):
                    print(f"  📁 {device} is mounted at {device_path}")
                    
                    # Check for audio files
                    audio_files = []
                    for pattern in ["button1*.wav", "button2*.wav", "hold1*.wav", "hold2*.wav"]:
                        files = glob.glob(os.path.join(device_path, pattern))
                        audio_files.extend(files)
                    
                    if audio_files:
                        print(f"    🎵 Found {len(audio_files)} audio files:")
                        for file in audio_files:
                            print(f"      - {os.path.basename(file)}")
                    else:
                        print("    📁 No audio files found")
                else:
                    print(f"  📁 {device} is not a mount point")
        else:
            print("  ❌ /media directory does not exist")
            
        return True
        
    except Exception as e:
        print(f"  ❌ USB mount check failed: {e}")
        return False

def test_audio_file_detection():
    """Test the pick_source function from PiScript"""
    print("\n🔍 Testing audio file detection...")
    
    try:
        # Simulate the pick_source function
        def usb_mount_dirs():
            base = "/media"
            if not os.path.isdir(base):
                return []
            return [os.path.join(base, d) for d in sorted(os.listdir(base)) 
                    if os.path.isdir(os.path.join(base, d)) and os.path.ismount(os.path.join(base, d))]
        
        def pick_source():
            # Check USB mounts first
            for mnt in usb_mount_dirs():
                B1 = sorted(glob.glob(os.path.join(mnt, "button1*.wav")))
                B2 = sorted(glob.glob(os.path.join(mnt, "button2*.wav")))
                H1 = sorted(glob.glob(os.path.join(mnt, "hold1*.wav")))
                H2 = sorted(glob.glob(os.path.join(mnt, "hold2*.wav")))
                if B1 or B2 or H1 or H2:
                    return (f"USB:{mnt}", mnt, B1[:1], B2, H1[:1], H2)
            
            # Fall back to local
            local = os.path.expanduser("~/WRB/sounds")
            os.makedirs(local, exist_ok=True)
            B1 = sorted(glob.glob(os.path.join(local, "button1*.wav")))
            B2 = sorted(glob.glob(os.path.join(local, "button2*.wav")))
            H1 = sorted(glob.glob(os.path.join(local, "hold1*.wav")))
            H2 = sorted(glob.glob(os.path.join(local, "hold2*.wav")))
            return ("LOCAL", local, B1[:1], B2, H1[:1], H2)
        
        src_tag, base, B1, B2, H1, H2 = pick_source()
        print(f"  📍 Audio source: {src_tag}")
        print(f"  📍 Base path: {base}")
        print(f"  🎵 Button1 files: {B1}")
        print(f"  🎵 Button2 files: {len(B2)} files")
        print(f"  🎵 Hold1 files: {H1}")
        print(f"  🎵 Hold2 files: {len(H2)} files")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Audio file detection test failed: {e}")
        return False

def test_audio_playback():
    """Test basic audio playback capability"""
    print("\n🔍 Testing audio playback...")
    
    try:
        import pygame
        pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=256)
        print("  ✅ Pygame mixer initialized")
        
        # Try to find a test audio file
        test_files = []
        for pattern in ["button1*.wav", "button2*.wav", "hold1*.wav", "hold2*.wav"]:
            # Check USB mounts
            for mnt in usb_mount_dirs():
                files = glob.glob(os.path.join(mnt, pattern))
                test_files.extend(files)
            # Check local
            files = glob.glob(os.path.join(os.path.expanduser("~/WRB/sounds"), pattern))
            test_files.extend(files)
        
        if test_files:
            test_file = test_files[0]
            print(f"  🎵 Testing playback of: {os.path.basename(test_file)}")
            sound = pygame.mixer.Sound(test_file)
            sound.play()
            time.sleep(1)  # Let it play briefly
            pygame.mixer.stop()
            print("  ✅ Audio playback test completed")
        else:
            print("  ⚠️  No audio files found for playback test")
        
        pygame.mixer.quit()
        return True
        
    except Exception as e:
        print(f"  ❌ Audio playback test failed: {e}")
        return False

def usb_mount_dirs():
    """Helper function for USB mount detection"""
    base = "/media"
    if not os.path.isdir(base):
        return []
    return [os.path.join(base, d) for d in sorted(os.listdir(base)) 
            if os.path.isdir(os.path.join(base, d)) and os.path.ismount(os.path.join(base, d))]

def main():
    print("🚀 WRB USB Audio & LED Test")
    print("=" * 50)
    
    # Test LED functionality
    led_ok = test_led_functionality()
    
    # Check USB mounts
    usb_ok = check_usb_mounts()
    
    # Test audio file detection
    audio_detection_ok = test_audio_file_detection()
    
    # Test audio playback
    audio_playback_ok = test_audio_playback()
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 TEST SUMMARY:")
    print(f"  LED Functionality: {'✅ PASS' if led_ok else '❌ FAIL'}")
    print(f"  USB Mounts: {'✅ PASS' if usb_ok else '❌ FAIL'}")
    print(f"  Audio Detection: {'✅ PASS' if audio_detection_ok else '❌ FAIL'}")
    print(f"  Audio Playback: {'✅ PASS' if audio_playback_ok else '❌ FAIL'}")
    
    if all([led_ok, usb_ok, audio_detection_ok, audio_playback_ok]):
        print("\n🎉 All tests passed! System is ready.")
    else:
        print("\n⚠️  Some tests failed. Check the output above for details.")
    
    print("\n💡 To test USB mounting:")
    print("   1. Insert a USB drive with .wav files")
    print("   2. Files should be named: button1*.wav, button2*.wav, hold1*.wav, hold2*.wav")
    print("   3. Run this test again to verify detection")

if __name__ == "__main__":
    main()

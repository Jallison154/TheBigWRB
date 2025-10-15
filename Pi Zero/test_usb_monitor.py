#!/usr/bin/env python3
"""
Real-time USB monitoring test
"""
import os
import glob
import time

def monitor_usb_changes():
    """Monitor USB mount changes in real-time"""
    print("🔍 Monitoring USB changes...")
    print("Insert/remove USB drives to test auto-detection")
    print("Press Ctrl+C to stop")
    
    last_mounts = set()
    
    try:
        while True:
            current_mounts = set()
            
            if os.path.exists("/media"):
                for device in os.listdir("/media"):
                    device_path = os.path.join("/media", device)
                    if os.path.ismount(device_path):
                        current_mounts.add(device)
            
            # Check for changes
            added = current_mounts - last_mounts
            removed = last_mounts - current_mounts
            
            if added:
                for device in added:
                    print(f"📁 USB device mounted: {device}")
                    check_audio_files(device)
            
            if removed:
                for device in removed:
                    print(f"📁 USB device unmounted: {device}")
            
            last_mounts = current_mounts
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\n🛑 Monitoring stopped")

def check_audio_files(device):
    """Check for audio files on a mounted device"""
    device_path = os.path.join("/media", device)
    audio_patterns = ["button1*.wav", "button2*.wav", "hold1*.wav", "hold2*.wav"]
    
    for pattern in audio_patterns:
        files = glob.glob(os.path.join(device_path, pattern))
        if files:
            print(f"  🎵 Found {pattern}: {[os.path.basename(f) for f in files]}")

if __name__ == "__main__":
    monitor_usb_changes()

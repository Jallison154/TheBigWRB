#!/usr/bin/env python3
"""
Simple audio test script to diagnose ALSA/pygame issues
Run this to test audio device access before running the main PiScript
"""

import os
import sys

def test_audio_devices():
    """Test available audio devices"""
    print("=== Audio Device Test ===")
    
    # Check if audio devices exist
    audio_devices = [
        "/dev/snd/pcmC0D0p",  # Playback device
        "/dev/snd/pcmC0D0c",  # Capture device
        "/dev/snd/controlC0", # Control device
    ]
    
    print("Checking audio device files:")
    for device in audio_devices:
        if os.path.exists(device):
            print(f"✓ {device} exists")
        else:
            print(f"✗ {device} missing")
    
    # Check ALSA configuration
    print("\nChecking ALSA configuration:")
    alsa_cards = "/proc/asound/cards"
    if os.path.exists(alsa_cards):
        print("✓ ALSA cards file exists")
        try:
            with open(alsa_cards, 'r') as f:
                content = f.read()
                if content.strip():
                    print("Available audio cards:")
                    print(content)
                else:
                    print("✗ No audio cards found")
        except Exception as e:
            print(f"✗ Error reading ALSA cards: {e}")
    else:
        print("✗ ALSA cards file missing")
    
    # Test pygame import
    print("\nTesting pygame import:")
    try:
        import pygame
        print(f"✓ pygame imported successfully (version {pygame.version.ver})")
        
        # Test pygame mixer
        print("Testing pygame mixer initialization:")
        try:
            pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=512)
            print("✓ pygame mixer initialized successfully")
            
            # Test creating a simple sound
            try:
                import numpy as np
                # Create a simple sine wave
                sample_rate = 44100
                duration = 0.1
                frequency = 440
                frames = int(sample_rate * duration)
                arr = np.sin(2 * np.pi * frequency * np.linspace(0, duration, frames))
                arr = (arr * 32767).astype(np.int16)
                
                # Try to create a sound object
                sound = pygame.sndarray.make_sound(arr)
                print("✓ Sound object created successfully")
                
                # Try to play it
                sound.play()
                pygame.time.wait(200)  # Wait for playback
                print("✓ Sound played successfully")
                
            except Exception as e:
                print(f"✗ Sound creation/playback failed: {e}")
                
        except Exception as e:
            print(f"✗ pygame mixer initialization failed: {e}")
            
    except ImportError as e:
        print(f"✗ pygame import failed: {e}")
        print("Install pygame with: pip3 install pygame")

def test_environment():
    """Test environment variables"""
    print("\n=== Environment Test ===")
    
    env_vars = [
        "SDL_AUDIODRIVER",
        "AUDIODEV", 
        "ALSA_CARD",
        "ALSA_DEVICE"
    ]
    
    for var in env_vars:
        value = os.getenv(var, "Not set")
        print(f"{var}: {value}")
    
    # Set default environment
    os.environ.setdefault("SDL_AUDIODRIVER", "alsa")
    os.environ.setdefault("AUDIODEV", "plughw:0,0")
    
    print("\nAfter setting defaults:")
    for var in env_vars:
        value = os.getenv(var, "Not set")
        print(f"{var}: {value}")

def main():
    print("WRB Audio Diagnostic Tool")
    print("=" * 40)
    
    test_environment()
    test_audio_devices()
    
    print("\n=== Recommendations ===")
    print("1. If audio devices are missing, check hardware connections")
    print("2. If pygame fails, try: sudo apt install python3-pygame")
    print("3. If ALSA issues persist, try: sudo usermod -a -G audio $USER")
    print("4. For hardware audio issues, check: aplay -l")
    print("5. Consider rebooting after adding user to audio group")

if __name__ == "__main__":
    main()

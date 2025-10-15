#!/usr/bin/env python3
"""
Test script for the new GPIO 23 LED behavior
Tests breathing, 25% brightness, and 100% blink functionality
"""

import time
import math
from gpiozero import PWMLED

# Configuration (should match config.py)
READY_PIN = 23
READY_ACTIVE_LOW = True

def breathing_led(led, duration=2.0, steps=20):
    """Breathing LED effect from 0 to 100% brightness"""
    print("🫁 Testing breathing LED effect...")
    for i in range(int(steps * 2)):  # 2 cycles
        # Create smooth breathing curve using sine wave
        brightness = (math.sin(i * math.pi / steps) + 1) / 2  # 0 to 1
        if READY_ACTIVE_LOW:
            # For active low LEDs, invert the brightness
            brightness = 1 - brightness
        led.value = brightness
        time.sleep(duration / (steps * 2))

def test_led_behavior():
    """Test the new LED behavior patterns"""
    print("🔧 Testing GPIO 23 LED behavior...")
    print(f"📌 Pin: {READY_PIN}")
    print(f"📌 Active Low: {READY_ACTIVE_LOW}")
    print()
    
    # Initialize PWMLED
    led = PWMLED(READY_PIN, active_high=(not READY_ACTIVE_LOW))
    
    try:
        # Test 1: Breathing LED (startup simulation)
        print("1️⃣  Testing breathing LED (startup)...")
        breathing_led(led, duration=3.0, steps=20)
        time.sleep(1)
        
        # Test 2: 25% brightness (ready state)
        print("2️⃣  Testing 25% brightness (ready state)...")
        if READY_ACTIVE_LOW:
            led.value = 0.75  # 25% brightness for active low
        else:
            led.value = 0.25  # 25% brightness for active high
        print("   LED should be at 25% brightness")
        time.sleep(3)
        
        # Test 3: 100% blink (button press simulation)
        print("3️⃣  Testing 100% blink (button press)...")
        for i in range(3):
            print(f"   Blink {i+1}/3...")
            # Blink to 100% brightness
            led.value = 0.0 if READY_ACTIVE_LOW else 1.0
            time.sleep(0.1)
            # Return to 25% brightness
            led.value = 0.75 if READY_ACTIVE_LOW else 0.25
            time.sleep(0.5)
        
        print("4️⃣  Returning to 25% brightness (idle)...")
        time.sleep(2)
        
        print("✅ LED behavior test complete!")
        print()
        print("Expected behavior:")
        print("• Breathing: Smooth fade in/out during startup")
        print("• 25% Brightness: Dim but visible when ready")
        print("• 100% Blink: Bright flash when button pressed")
        print("• Return to 25%: Back to dim after button press")
        
    except KeyboardInterrupt:
        print("\n⚠️  Test interrupted by user")
    except Exception as e:
        print(f"❌ Error during test: {e}")
    finally:
        # Clean up - turn off LED
        led.off()
        print("🔚 LED turned off")

if __name__ == "__main__":
    test_led_behavior()

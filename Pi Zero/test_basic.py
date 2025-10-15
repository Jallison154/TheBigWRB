#!/usr/bin/env python3
import os, sys, time

print("[WRB] Basic test starting...", flush=True)

try:
    # Test 1: Import config
    print("[WRB] Testing config import...", flush=True)
    from config import *
    print("[WRB] Config imported successfully", flush=True)
except ImportError as e:
    print(f"[WRB] Config import failed: {e}", flush=True)
    sys.exit(1)

try:
    # Test 2: Import pygame
    print("[WRB] Testing pygame import...", flush=True)
    import pygame
    print("[WRB] Pygame imported successfully", flush=True)
except ImportError as e:
    print(f"[WRB] Pygame import failed: {e}", flush=True)
    sys.exit(1)

try:
    # Test 3: Import gpiozero
    print("[WRB] Testing gpiozero import...", flush=True)
    from gpiozero import PWMLED
    print("[WRB] GPIOZero imported successfully", flush=True)
except ImportError as e:
    print(f"[WRB] GPIOZero import failed: {e}", flush=True)
    sys.exit(1)

try:
    # Test 4: Test LED
    print("[WRB] Testing LED...", flush=True)
    led = PWMLED(READY_PIN, active_high=(not READY_ACTIVE_LOW))
    led.value = 0.5
    time.sleep(0.5)
    led.value = 0.0
    print("[WRB] LED test successful", flush=True)
except Exception as e:
    print(f"[WRB] LED test failed: {e}", flush=True)
    sys.exit(1)

try:
    # Test 5: Test file paths
    print("[WRB] Testing file paths...", flush=True)
    import glob
    local = os.path.expanduser("~/WRB/sounds")
    os.makedirs(local, exist_ok=True)
    B1 = sorted(glob.glob(os.path.join(local, "button1*.wav")))
    print(f"[WRB] Found {len(B1)} button1 files", flush=True)
except Exception as e:
    print(f"[WRB] File path test failed: {e}", flush=True)
    sys.exit(1)

print("[WRB] All basic tests passed!", flush=True)
print("[WRB] Exiting successfully", flush=True)
sys.exit(0)

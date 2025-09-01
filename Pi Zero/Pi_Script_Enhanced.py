#!/usr/bin/env python3
"""
Enhanced Pi Script for ESP32 Wireless Button System
Works with the ESP32 receiver to play sound effects based on button presses
"""

import os, glob, time, random, sys, serial, json, threading
from datetime import datetime

# Configuration
BAUD = 115200
SERIAL = os.getenv("MATT_SFX_SERIAL", "/dev/ttyACM0")
READY_PIN = 18
USB_LED_PIN = 23  # New LED for USB drive status
READY_ACTIVE_LOW = True
USB_LED_ACTIVE_LOW = True  # USB LED also active-low
MIX_FREQ = 44100
MIX_BUF = 256
RESCAN_SEC = 1.0
IDLE_SHUTOFF_SEC = 1.0
LOG_FILE = "/home/pi/mattsfx/button_log.txt"

# ESP32 Message Types (matching your ESP32 code)
MSG_PING = 0xA0
MSG_ACK = 0xA1
MSG_BTN = 0xB0

# --- LED (simple on/off, active-low wiring) ---
try:
    from gpiozero import LED
    led = LED(READY_PIN, active_high=(not READY_ACTIVE_LOW))
    usb_led = LED(USB_LED_PIN, active_high=(not USB_LED_ACTIVE_LOW))
    LED_AVAILABLE = True
    USB_LED_AVAILABLE = True
except ImportError:
    print("[mattsfx] Warning: gpiozero not available, LED disabled")
    LED_AVAILABLE = False
    USB_LED_AVAILABLE = False
except Exception as e:
    print(f"[mattsfx] Warning: LED initialization failed: {e}")
    LED_AVAILABLE = False
    USB_LED_AVAILABLE = False

def log_event(message):
    """Log events to file with timestamp"""
    try:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(LOG_FILE, "a") as f:
            f.write(f"{timestamp}: {message}\n")
    except:
        pass  # Don't fail if logging fails

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
    if not USB_LED_AVAILABLE:
        return
    
    try:
        if mounts:
            usb_led.on()  # USB drive is mounted
        else:
            usb_led.off()  # No USB drive mounted
    except Exception as e:
        print(f"[mattsfx] USB LED control failed: {e}", flush=True)

def pick_source():
    """Find sound files from USB or local storage"""
    # Check USB drives first
    mounts = usb_mount_dirs()
    update_usb_led(mounts)  # Update USB LED status
    
    for mnt in mounts:
        R = sorted(glob.glob(os.path.join(mnt, "right*.wav")))
        W = sorted(glob.glob(os.path.join(mnt, "wrong*.wav")))
        if R or W:
            return (f"USB:{mnt}", R[:1], W)
    
    # Fall back to local storage
    local = os.path.expanduser("~/mattsfx")
    os.makedirs(local, exist_ok=True)
    R = sorted(glob.glob(os.path.join(local, "right*.wav")))
    W = sorted(glob.glob(os.path.join(local, "wrong*.wav")))
    return ("LOCAL", R[:1], W)

def classify_esp32_message(line):
    """
    Parse ESP32 serial messages and classify button presses
    Handles both old format (R/W) and new ESP32 format
    """
    line = line.strip()
    
    # Try to parse as ESP32 message first
    try:
        # Look for ESP32 button messages: "RX: BTN1 from MAC" or "RX: BTN2 from MAC"
        if "RX: BTN" in line:
            if "BTN1" in line:
                return 'R', line  # Button 1 = Right
            elif "BTN2" in line:
                return 'W', line  # Button 2 = Wrong
        elif "Authorized transmitter connected" in line:
            return 'CONNECT', line
        elif "Status:" in line:
            return 'STATUS', line
        elif "Rejected message from unauthorized MAC" in line:
            return 'SECURITY', line
        elif "Receiver starting" in line:
            return 'STARTUP', line
        elif "Receiver ready" in line:
            return 'READY', line
        elif "ESP-NOW init failed" in line:
            return 'ERROR', line
    except:
        pass
    
    # Fall back to old format parsing
    u = line.upper()
    if u == "R" or "RIGHT" in u or "BTN1" in u or "BTN_R" in u:
        return 'R', line
    if u == "W" or "WRONG" in u or "BTN2" in u or "BTN_W" in u:
        return 'W', line
    
    return None, line

# --- Audio System ---
_mixer_ready = False
_last_play = 0
_right_paths = []
_wrong_paths = []

def set_paths(R, W):
    """Set audio file paths"""
    global _right_paths, _wrong_paths
    _right_paths, _wrong_paths = R, W

def ensure_mixer():
    """Initialize pygame mixer"""
    global _mixer_ready
    if _mixer_ready:
        return
    
    try:
        import pygame
        for i in range(8):
            try:
                pygame.mixer.init(frequency=MIX_FREQ, size=-16, channels=2, buffer=MIX_BUF)
                _mixer_ready = True
                print("[mattsfx] audio: mixer ready", flush=True)
                log_event("Audio mixer initialized")
                return
            except Exception as e:
                print(f"[mattsfx] audio init retry {i+1}: {e}", flush=True)
                time.sleep(0.2)
        raise SystemExit("audio init failed")
    except ImportError:
        print("[mattsfx] Error: pygame not installed. Install with: pip3 install pygame")
        raise SystemExit("pygame not available")

def shutdown_mixer_if_idle():
    """Close mixer if idle to save resources"""
    global _mixer_ready
    if not _mixer_ready:
        return
    
    try:
        import pygame
        if (time.time() - _last_play) > IDLE_SHUTOFF_SEC and not pygame.mixer.get_busy():
            pygame.mixer.quit()
            _mixer_ready = False
            print("[mattsfx] audio: mixer closed (idle)", flush=True)
    except:
        pass

def play_right():
    """Play right sound effect"""
    global _last_play
    if not _right_paths:
        print("[mattsfx] RIGHT (no file)", flush=True)
        return
    
    ensure_mixer()
    try:
        import pygame
        s = pygame.mixer.Sound(_right_paths[0])
        pygame.mixer.Channel(0).play(s)
        _last_play = time.time()
        log_event(f"Played RIGHT sound: {_right_paths[0]}")
    except Exception as e:
        print(f"[mattsfx] Error playing right sound: {e}", flush=True)

def play_wrong():
    """Play wrong sound effect"""
    global _last_play
    if not _wrong_paths:
        print("[mattsfx] WRONG (no files)", flush=True)
        return
    
    ensure_mixer()
    try:
        import pygame
        sound_file = random.choice(_wrong_paths)
        s = pygame.mixer.Sound(sound_file)
        pygame.mixer.Channel(1).play(s)
        _last_play = time.time()
        log_event(f"Played WRONG sound: {sound_file}")
    except Exception as e:
        print(f"[mattsfx] Error playing wrong sound: {e}", flush=True)

def blink_led():
    """Blink the ready LED"""
    if not LED_AVAILABLE:
        return
    
    try:
        led.off()
        time.sleep(0.04)
        led.on()
    except:
        pass

def wait_serial():
    """Wait for ESP32 serial connection"""
    print("[mattsfx] waiting for ESP32 serial connection...", flush=True)
    prefs = [SERIAL, "/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1", "/dev/serial0", "/dev/ttyAMA0", "/dev/ttyS0"]
    
    while True:
        for p in prefs:
            try:
                ser = serial.Serial(p, BAUD, timeout=0.1)
                print(f"[mattsfx] Connected to ESP32 on {p}", flush=True)
                log_event(f"Connected to ESP32 on {p}")
                return ser
            except:
                pass
        time.sleep(0.3)

def main():
    """Main function"""
    if LED_AVAILABLE:
        led.off()  # OFF until ready
    if USB_LED_AVAILABLE:
        usb_led.off()  # USB LED OFF initially
    
    print("[mattsfx] ESP32 Wireless Button System - Enhanced Pi Script", flush=True)
    log_event("Pi script started")
    
    # Initialize audio source
    tag, R, W = pick_source()
    set_paths(R, W)
    print(f"[mattsfx] source={tag} right={R[:1]} wrongs={len(W)}", flush=True)
    log_event(f"Audio source: {tag}, Right sounds: {len(R)}, Wrong sounds: {len(W)}")
    
    # Connect to ESP32
    ser = wait_serial()
    
    # Ready
    if LED_AVAILABLE:
        led.on()
    print("[mattsfx] READY - Waiting for ESP32 button presses", flush=True)
    log_event("System ready")
    
    last_scan = time.time()
    connection_status = "connected"
    
    while True:
        # Hot-swap audio files
        if time.time() - last_scan > RESCAN_SEC:
            ntag, nR, nW = pick_source()
            if (ntag != tag) or (nR != R) or (nW != W):
                tag, R, W = ntag, nR, nW
                set_paths(R, W)
                print(f"[mattsfx] reloaded: source={tag} right={R[:1]} wrongs={len(W)}", flush=True)
                log_event(f"Audio files reloaded: {tag}")
            last_scan = time.time()
        
        # Read serial from ESP32
        try:
            line = ser.readline().decode(errors="ignore")
        except Exception as e:
            if connection_status == "connected":
                print(f"[mattsfx] Serial error: {e}", flush=True)
                log_event(f"Serial error: {e}")
                connection_status = "error"
            time.sleep(0.05)
            continue
        
        if not line:
            shutdown_mixer_if_idle()
            continue
        
        # Reset connection status if we're getting data
        if connection_status != "connected":
            connection_status = "connected"
            print("[mattsfx] Serial connection restored", flush=True)
            log_event("Serial connection restored")
        
        # Parse and handle ESP32 messages
        msg_type, full_line = classify_esp32_message(line)
        
        if msg_type == 'R':
            print("[mattsfx] RIGHT button pressed", flush=True)
            play_right()
            blink_led()
            log_event("RIGHT button pressed")
            
        elif msg_type == 'W':
            print("[mattsfx] WRONG button pressed", flush=True)
            play_wrong()
            blink_led()
            log_event("WRONG button pressed")
            
        elif msg_type == 'CONNECT':
            print(f"[mattsfx] ESP32: {full_line}", flush=True)
            log_event(f"ESP32: {full_line}")
            
        elif msg_type == 'STATUS':
            print(f"[mattsfx] ESP32 Status: {full_line}", flush=True)
            
        elif msg_type == 'SECURITY':
            print(f"[mattsfx] Security Alert: {full_line}", flush=True)
            log_event(f"Security: {full_line}")
            
        elif msg_type == 'STARTUP':
            print(f"[mattsfx] ESP32: {full_line}", flush=True)
            log_event(f"ESP32: {full_line}")
            
        elif msg_type == 'READY':
            print(f"[mattsfx] ESP32: {full_line}", flush=True)
            log_event(f"ESP32: {full_line}")
            
        elif msg_type == 'ERROR':
            print(f"[mattsfx] ESP32 Error: {full_line}", flush=True)
            log_event(f"ESP32 Error: {full_line}")
            
        elif full_line.strip():  # Only log non-empty lines
            print(f"[mattsfx] ESP32: {full_line}", flush=True)
        
        shutdown_mixer_if_idle()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[mattsfx] Shutting down...", flush=True)
        log_event("Script stopped by user")
        if LED_AVAILABLE:
            led.off()
        if USB_LED_AVAILABLE:
            usb_led.off()
    except Exception as e:
        print(f"[mattsfx] Fatal error: {e}", flush=True)
        log_event(f"Fatal error: {e}")
        if LED_AVAILABLE:
            led.off()
        if USB_LED_AVAILABLE:
            usb_led.off()
        sys.exit(1)

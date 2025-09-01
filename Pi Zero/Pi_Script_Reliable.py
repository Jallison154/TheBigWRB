#!/usr/bin/env python3
"""
Highly Reliable Pi Script for ESP32 Wireless Button System
Enhanced with comprehensive error handling, logging, and recovery mechanisms
"""

import os, glob, time, random, sys, serial, json, threading, signal
from datetime import datetime
import traceback

# Configuration
BAUD = 115200
SERIAL = os.getenv("MATT_SFX_SERIAL", "/dev/ttyACM0")
READY_PIN = 18
READY_ACTIVE_LOW = True
MIX_FREQ = 44100
MIX_BUF = 256
RESCAN_SEC = 1.0
IDLE_SHUTOFF_SEC = 1.0
LOG_FILE = "/home/pi/mattsfx/button_log.txt"
HEALTH_LOG = "/home/pi/mattsfx/health_log.txt"
MAX_RECONNECT_ATTEMPTS = 10
RECONNECT_DELAY = 2.0
HEALTH_CHECK_INTERVAL = 30.0  # seconds

# Global state
running = True
serial_connection = None
last_health_check = 0
button_press_count = 0
error_count = 0
start_time = time.time()

# --- Signal handling for graceful shutdown ---
def signal_handler(signum, frame):
    global running
    print(f"\n[mattsfx] Received signal {signum}, shutting down gracefully...", flush=True)
    log_event("Shutdown signal received")
    running = False

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

# --- LED with error handling ---
try:
    from gpiozero import LED
    led = LED(READY_PIN, active_high=(not READY_ACTIVE_LOW))
    LED_AVAILABLE = True
    print("[mattsfx] LED initialized successfully", flush=True)
except ImportError:
    print("[mattsfx] Warning: gpiozero not available, LED disabled")
    LED_AVAILABLE = False
except Exception as e:
    print(f"[mattsfx] Warning: LED initialization failed: {e}")
    LED_AVAILABLE = False

def log_event(message, level="INFO"):
    """Log events with timestamp and level"""
    try:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"{timestamp} [{level}]: {message}\n"
        
        # Write to main log
        with open(LOG_FILE, "a") as f:
            f.write(log_entry)
        
        # Also write errors to health log
        if level in ["ERROR", "WARNING"]:
            with open(HEALTH_LOG, "a") as f:
                f.write(log_entry)
                
    except Exception as e:
        print(f"[mattsfx] Logging failed: {e}", flush=True)

def log_health_stats():
    """Log system health statistics"""
    global last_health_check, button_press_count, error_count, start_time
    
    try:
        uptime = time.time() - start_time
        hours = int(uptime // 3600)
        minutes = int((uptime % 3600) // 60)
        
        stats = {
            "uptime": f"{hours}h {minutes}m",
            "button_presses": button_press_count,
            "errors": error_count,
            "error_rate": f"{error_count/max(uptime/3600, 1):.2f}/hour" if uptime > 0 else "0",
            "led_available": LED_AVAILABLE,
            "serial_connected": serial_connection is not None and serial_connection.is_open if serial_connection else False
        }
        
        log_event(f"Health check: {json.dumps(stats)}", "HEALTH")
        last_health_check = time.time()
        
    except Exception as e:
        print(f"[mattsfx] Health logging failed: {e}", flush=True)

def usb_mount_dirs():
    """Find mounted USB drives with error handling"""
    try:
        base = "/media"
        if not os.path.isdir(base):
            return []
        
        mounts = []
        for d in sorted(os.listdir(base)):
            path = os.path.join(base, d)
            if os.path.isdir(path) and os.path.ismount(path):
                mounts.append(path)
        return mounts
    except Exception as e:
        log_event(f"USB mount detection failed: {e}", "ERROR")
        return []

def pick_source():
    """Find sound files from USB or local storage with error handling"""
    try:
        # Check USB drives first
        for mnt in usb_mount_dirs():
            try:
                R = sorted(glob.glob(os.path.join(mnt, "right*.wav")))
                W = sorted(glob.glob(os.path.join(mnt, "wrong*.wav")))
                if R or W:
                    return (f"USB:{mnt}", R[:1], W)
            except Exception as e:
                log_event(f"USB drive {mnt} scan failed: {e}", "WARNING")
                continue
        
        # Fall back to local storage
        local = os.path.expanduser("~/mattsfx")
        os.makedirs(local, exist_ok=True)
        R = sorted(glob.glob(os.path.join(local, "right*.wav")))
        W = sorted(glob.glob(os.path.join(local, "wrong*.wav")))
        return ("LOCAL", R[:1], W)
        
    except Exception as e:
        log_event(f"Sound source detection failed: {e}", "ERROR")
        return ("ERROR", [], [])

def classify_esp32_message(line):
    """
    Parse ESP32 serial messages and classify button presses
    Enhanced with better error handling and message detection
    """
    try:
        line = line.strip()
        
        # ESP32 message patterns
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
        
        # Fall back to old format parsing
        u = line.upper()
        if u == "R" or "RIGHT" in u or "BTN1" in u or "BTN_R" in u:
            return 'R', line
        if u == "W" or "WRONG" in u or "BTN2" in u or "BTN_W" in u:
            return 'W', line
        
        return None, line
        
    except Exception as e:
        log_event(f"Message classification failed: {e}", "ERROR")
        return None, line

# --- Robust Audio System ---
_mixer_ready = False
_last_play = 0
_right_paths = []
_wrong_paths = []
_audio_errors = 0

def set_paths(R, W):
    """Set audio file paths with validation"""
    global _right_paths, _wrong_paths
    try:
        _right_paths = [f for f in R if os.path.exists(f)]
        _wrong_paths = [f for f in W if os.path.exists(f)]
        
        if len(_right_paths) != len(R):
            log_event(f"Some right sound files not found: {len(R) - len(_right_paths)} missing", "WARNING")
        if len(_wrong_paths) != len(W):
            log_event(f"Some wrong sound files not found: {len(W) - len(_wrong_paths)} missing", "WARNING")
            
    except Exception as e:
        log_event(f"Audio path setting failed: {e}", "ERROR")

def ensure_mixer():
    """Initialize pygame mixer with enhanced error handling"""
    global _mixer_ready, _audio_errors
    
    if _mixer_ready:
        return True
    
    try:
        import pygame
        
        # Try multiple initialization attempts
        for i in range(8):
            try:
                pygame.mixer.init(frequency=MIX_FREQ, size=-16, channels=2, buffer=MIX_BUF)
                _mixer_ready = True
                _audio_errors = 0  # Reset error count on success
                print("[mattsfx] audio: mixer ready", flush=True)
                log_event("Audio mixer initialized successfully")
                return True
            except Exception as e:
                print(f"[mattsfx] audio init retry {i+1}: {e}", flush=True)
                time.sleep(0.2)
        
        # If we get here, all attempts failed
        _audio_errors += 1
        log_event(f"Audio mixer initialization failed after 8 attempts", "ERROR")
        return False
        
    except ImportError:
        log_event("pygame not installed - audio disabled", "ERROR")
        return False
    except Exception as e:
        _audio_errors += 1
        log_event(f"Audio mixer setup failed: {e}", "ERROR")
        return False

def shutdown_mixer_if_idle():
    """Close mixer if idle with error handling"""
    global _mixer_ready
    if not _mixer_ready:
        return
    
    try:
        import pygame
        if (time.time() - _last_play) > IDLE_SHUTOFF_SEC and not pygame.mixer.get_busy():
            pygame.mixer.quit()
            _mixer_ready = False
            print("[mattsfx] audio: mixer closed (idle)", flush=True)
    except Exception as e:
        log_event(f"Audio mixer shutdown failed: {e}", "WARNING")

def play_sound(sound_type, paths):
    """Generic sound playing function with comprehensive error handling"""
    global _last_play, _audio_errors
    
    if not paths:
        print(f"[mattsfx] {sound_type} (no files)", flush=True)
        return False
    
    if not ensure_mixer():
        return False
    
    try:
        import pygame
        
        # Select sound file
        if sound_type == "RIGHT":
            sound_file = paths[0]
        else:  # WRONG
            sound_file = random.choice(paths)
        
        # Load and play sound
        s = pygame.mixer.Sound(sound_file)
        channel = pygame.mixer.Channel(0 if sound_type == "RIGHT" else 1)
        channel.play(s)
        
        _last_play = time.time()
        _audio_errors = 0  # Reset error count on success
        log_event(f"Played {sound_type} sound: {os.path.basename(sound_file)}")
        return True
        
    except Exception as e:
        _audio_errors += 1
        log_event(f"Failed to play {sound_type} sound: {e}", "ERROR")
        print(f"[mattsfx] Error playing {sound_type} sound: {e}", flush=True)
        return False

def play_right():
    """Play right sound effect"""
    return play_sound("RIGHT", _right_paths)

def play_wrong():
    """Play wrong sound effect"""
    return play_sound("WRONG", _wrong_paths)

def blink_led():
    """Blink the ready LED with error handling"""
    if not LED_AVAILABLE:
        return
    
    try:
        led.off()
        time.sleep(0.04)
        led.on()
    except Exception as e:
        log_event(f"LED blink failed: {e}", "WARNING")

def wait_serial():
    """Wait for ESP32 serial connection with enhanced retry logic"""
    global serial_connection
    
    print("[mattsfx] waiting for ESP32 serial connection...", flush=True)
    prefs = [SERIAL, "/dev/ttyACM0", "/dev/ttyACM1", "/dev/ttyUSB0", "/dev/ttyUSB1", "/dev/serial0", "/dev/ttyAMA0", "/dev/ttyS0"]
    
    attempt = 0
    while running and attempt < MAX_RECONNECT_ATTEMPTS:
        for p in prefs:
            try:
                if serial_connection:
                    serial_connection.close()
                
                serial_connection = serial.Serial(p, BAUD, timeout=0.1)
                print(f"[mattsfx] Connected to ESP32 on {p}", flush=True)
                log_event(f"Connected to ESP32 on {p}")
                return serial_connection
            except Exception as e:
                log_event(f"Failed to connect to {p}: {e}", "WARNING")
                continue
        
        attempt += 1
        if attempt < MAX_RECONNECT_ATTEMPTS:
            print(f"[mattsfx] Connection attempt {attempt}/{MAX_RECONNECT_ATTEMPTS} failed, retrying in {RECONNECT_DELAY}s...", flush=True)
            time.sleep(RECONNECT_DELAY)
    
    log_event("Failed to establish serial connection after all attempts", "ERROR")
    raise SystemExit("Serial connection failed")

def check_serial_health():
    """Check if serial connection is healthy"""
    global serial_connection
    
    if not serial_connection:
        return False
    
    try:
        # Try to get port info - this will fail if connection is lost
        port = serial_connection.port
        return serial_connection.is_open
    except:
        return False

def main():
    """Main function with comprehensive error handling"""
    global running, serial_connection, button_press_count, error_count, last_health_check
    
    try:
        if LED_AVAILABLE:
            led.off()  # OFF until ready
        
        print("[mattsfx] ESP32 Wireless Button System - Reliable Pi Script", flush=True)
        log_event("Reliable Pi script started")
        
        # Initialize audio source
        tag, R, W = pick_source()
        set_paths(R, W)
        print(f"[mattsfx] source={tag} right={R[:1]} wrongs={len(W)}", flush=True)
        log_event(f"Audio source: {tag}, Right sounds: {len(R)}, Wrong sounds: {len(W)}")
        
        # Connect to ESP32
        serial_connection = wait_serial()
        
        # Ready
        if LED_AVAILABLE:
            led.on()
        print("[mattsfx] READY - Waiting for ESP32 button presses", flush=True)
        log_event("System ready")
        
        last_scan = time.time()
        last_health_check = time.time()
        connection_status = "connected"
        
        while running:
            try:
                # Health check
                if time.time() - last_health_check > HEALTH_CHECK_INTERVAL:
                    log_health_stats()
                
                # Check serial connection health
                if not check_serial_health():
                    if connection_status == "connected":
                        log_event("Serial connection lost", "ERROR")
                        connection_status = "disconnected"
                    # Try to reconnect
                    try:
                        serial_connection = wait_serial()
                        connection_status = "connected"
                        log_event("Serial connection restored")
                    except:
                        time.sleep(1)
                        continue
                
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
                    line = serial_connection.readline().decode(errors="ignore")
                except Exception as e:
                    error_count += 1
                    if connection_status == "connected":
                        log_event(f"Serial read error: {e}", "ERROR")
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
                    button_press_count += 1
                    if play_right():
                        blink_led()
                    log_event("RIGHT button pressed")
                    
                elif msg_type == 'W':
                    print("[mattsfx] WRONG button pressed", flush=True)
                    button_press_count += 1
                    if play_wrong():
                        blink_led()
                    log_event("WRONG button pressed")
                    
                elif msg_type in ['CONNECT', 'STARTUP', 'READY']:
                    print(f"[mattsfx] ESP32: {full_line}", flush=True)
                    log_event(f"ESP32: {full_line}")
                    
                elif msg_type == 'STATUS':
                    print(f"[mattsfx] ESP32 Status: {full_line}", flush=True)
                    
                elif msg_type == 'SECURITY':
                    print(f"[mattsfx] Security Alert: {full_line}", flush=True)
                    log_event(f"Security: {full_line}")
                    
                elif msg_type == 'ERROR':
                    print(f"[mattsfx] ESP32 Error: {full_line}", flush=True)
                    log_event(f"ESP32 Error: {full_line}")
                    error_count += 1
                    
                elif full_line.strip():  # Only log non-empty lines
                    print(f"[mattsfx] ESP32: {full_line}", flush=True)
                
                shutdown_mixer_if_idle()
                
            except Exception as e:
                error_count += 1
                log_event(f"Main loop error: {e}", "ERROR")
                print(f"[mattsfx] Main loop error: {e}", flush=True)
                time.sleep(1)  # Brief pause before continuing
                
    except KeyboardInterrupt:
        print("\n[mattsfx] Shutdown requested by user", flush=True)
        log_event("Shutdown requested by user")
    except Exception as e:
        error_count += 1
        log_event(f"Fatal error: {e}", "ERROR")
        print(f"[mattsfx] Fatal error: {e}", flush=True)
        traceback.print_exc()
    finally:
        # Cleanup
        if LED_AVAILABLE:
            try:
                led.off()
            except:
                pass
        
        if serial_connection:
            try:
                serial_connection.close()
            except:
                pass
        
        log_event("Script stopped")
        print("[mattsfx] Cleanup complete", flush=True)

if __name__ == "__main__":
    try:
        main()
    except SystemExit as e:
        sys.exit(e.code)
    except Exception as e:
        log_event(f"Unhandled exception: {e}", "ERROR")
        sys.exit(1)

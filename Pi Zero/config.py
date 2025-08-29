#!/usr/bin/env python3
"""
Configuration file for ESP32 Wireless Button System - Enhanced Pi Script
Modify these settings to customize the behavior
"""

# Serial Configuration
BAUD = 115200
SERIAL = "/dev/ttyACM0"  # Default serial port, can be overridden by MATT_SFX_SERIAL env var

# LED Configuration
READY_PIN = 18
READY_ACTIVE_LOW = True

# Audio Configuration
MIX_FREQ = 44100
MIX_BUF = 256
RESCAN_SEC = 1.0
IDLE_SHUTOFF_SEC = 1.0

# File Paths
LOG_FILE = "/home/pi/mattsfx/button_log.txt"
SOUND_DIR = "/home/pi/mattsfx/sounds"

# Button Mapping (which ESP32 button triggers which sound)
BUTTON_MAPPING = {
    1: "right",   # Button 1 = Right sound
    2: "wrong"    # Button 2 = Wrong sound
}

# Sound File Patterns
RIGHT_PATTERN = "right*.wav"
WRONG_PATTERN = "wrong*.wav"

# Logging Configuration
LOG_BUTTON_PRESSES = True
LOG_CONNECTIONS = True
LOG_SECURITY_EVENTS = True
LOG_AUDIO_EVENTS = True

# Serial Port Detection (tries these ports in order)
SERIAL_PORTS = [
    "/dev/ttyACM0",
    "/dev/ttyACM1", 
    "/dev/ttyUSB0",
    "/dev/ttyUSB1",
    "/dev/serial0",
    "/dev/ttyAMA0",
    "/dev/ttyS0"
]

# USB Mount Directory
USB_MOUNT_DIR = "/media"

# Debug Mode (set to True for verbose output)
DEBUG_MODE = False

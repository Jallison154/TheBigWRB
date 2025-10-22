#!/usr/bin/env python3
"""
Configuration file for ESP32 Wireless Button System
"""

# Serial Communication
BAUD = 115200
SERIAL_PORT = "/dev/ttyACM0"

# GPIO Pins
READY_PIN = 23
USB_LED_PIN = 24

# Audio Configuration
MIX_FREQ = 44100
MIX_BUF = 512

# File Paths
SOUNDS_DIR = "~/WRB/sounds"
LOG_FILE = "~/WRB/button_log.txt"

# ESP32 Message Types
MSG_PING = 0xA0
MSG_ACK = 0xA1
MSG_BTN = 0xB0
MSG_BTN_HOLD = 0xB1

# Hardware Pin Configuration (for ESP32)
LED_PIN = "D10"           # Status LED
BTN1_PIN = "D1"           # Button 1
BTN2_PIN = "D2"           # Button 2

# MAC Address Configuration
# IMPORTANT: These must match between transmitter and receiver
# 
# Receiver MAC: 0x58,0x8C,0x81,0x9E,0x30,0x10 (58:8c:81:9e:30:10)
# Transmitter MAC: 0x58,0x8C,0x81,0x9F,0x22,0xAC (58:8c:81:9f:22:ac)
#
# In the Receiver ESP32 code:
# ALLOWED_TX_MACS[][6] = { { 0x58,0x8C,0x81,0x9F,0x22,0xAC } }; // Transmitter MAC
#
# In the Transmitter ESP32 code:
# RX_MAC[] = { 0x58,0x8C,0x81,0x9E,0x30,0x10 }; // Receiver MAC
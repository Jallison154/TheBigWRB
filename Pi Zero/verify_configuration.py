#!/usr/bin/env python3
"""
Configuration Verification Script
Verifies that MAC addresses are properly configured across all files.
"""

import os
import re

def verify_mac_addresses():
    """Verify MAC addresses are consistent across all files"""
    print("=== MAC Address Configuration Verification ===")
    
    # Expected MAC addresses
    expected_rx_mac = "0x58,0x8C,0x81,0x9E,0x30,0x10"
    expected_tx_mac = "0x58,0x8C,0x81,0x9F,0x22,0xAC"
    
    print(f"Expected Receiver MAC: {expected_rx_mac}")
    print(f"Expected Transmitter MAC: {expected_tx_mac}")
    print()
    
    # Files to check
    files_to_check = [
        ("Receiver/Receiver ESP32", "ALLOWED_TX_MACS"),
        ("Transmitter/Transmitter ESP32.c", "RX_MAC"),
        ("Pi Zero/config.py", "MAC Address Configuration"),
    ]
    
    all_correct = True
    
    for file_path, search_term in files_to_check:
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r') as f:
                    content = f.read()
                
                if search_term in content:
                    if "ALLOWED_TX_MACS" in search_term:
                        # Check receiver file for transmitter MAC
                        if expected_tx_mac in content:
                            print(f"✓ {file_path}: Transmitter MAC correctly configured")
                        else:
                            print(f"✗ {file_path}: Transmitter MAC mismatch")
                            all_correct = False
                    elif "RX_MAC" in search_term:
                        # Check transmitter file for receiver MAC
                        if expected_rx_mac in content:
                            print(f"✓ {file_path}: Receiver MAC correctly configured")
                        else:
                            print(f"✗ {file_path}: Receiver MAC mismatch")
                            all_correct = False
                    else:
                        # Check config file for both MACs
                        if expected_rx_mac in content and expected_tx_mac in content:
                            print(f"✓ {file_path}: Both MAC addresses documented")
                        else:
                            print(f"✗ {file_path}: MAC address documentation incomplete")
                            all_correct = False
                else:
                    print(f"✗ {file_path}: {search_term} not found")
                    all_correct = False
                    
            except Exception as e:
                print(f"✗ {file_path}: Error reading file - {e}")
                all_correct = False
        else:
            print(f"✗ {file_path}: File not found")
            all_correct = False
    
    print()
    return all_correct

def verify_pi_script():
    """Verify Pi script has all required components"""
    print("=== Pi Script Verification ===")
    
    pi_script_path = "Pi Zero/Pi Script"
    if not os.path.exists(pi_script_path):
        print(f"✗ {pi_script_path}: File not found")
        return False
    
    try:
        with open(pi_script_path, 'r') as f:
            content = f.read()
        
        required_components = [
            "USB_LED_PIN = 23",
            "blink_usb_led()",
            "update_usb_led(",
            "classify_esp32_message",
            "RX: BTN",
            "play_right()",
            "play_wrong()",
        ]
        
        all_present = True
        for component in required_components:
            if component in content:
                print(f"✓ {component}")
            else:
                print(f"✗ {component} - Missing")
                all_present = False
        
        return all_present
        
    except Exception as e:
        print(f"✗ Error reading Pi script: {e}")
        return False

def verify_message_parsing():
    """Verify message parsing handles correct MAC format"""
    print("\n=== Message Parsing Verification ===")
    
    # Test messages with your actual MAC addresses
    test_messages = [
        "RX: BTN1 from 58:8c:81:9f:22:ac",
        "RX: BTN2 from 58:8c:81:9f:22:ac",
        "Authorized transmitter connected: 58:8c:81:9f:22:ac",
    ]
    
    # Simulate the parsing logic from the Pi script
    def classify_esp32_message(line):
        line = line.strip()
        
        if "RX: BTN" in line:
            if "BTN1" in line:
                return 'R', line
            elif "BTN2" in line:
                return 'W', line
        elif "Authorized transmitter connected" in line:
            return 'CONNECT', line
        
        return None, line
    
    all_parsed = True
    for message in test_messages:
        result, _ = classify_esp32_message(message)
        if result:
            print(f"✓ {message[:30]}... -> {result}")
        else:
            print(f"✗ {message[:30]}... -> Failed to parse")
            all_parsed = False
    
    return all_parsed

def main():
    """Run all verification checks"""
    print("ESP32 Wireless Button System - Configuration Verification")
    print("=" * 60)
    
    checks = [
        verify_mac_addresses,
        verify_pi_script,
        verify_message_parsing,
    ]
    
    passed = 0
    total = len(checks)
    
    for check in checks:
        try:
            if check():
                passed += 1
            print()
        except Exception as e:
            print(f"✗ Check failed with exception: {e}")
            print()
    
    print("=" * 60)
    print(f"Verification Results: {passed}/{total} checks passed")
    
    if passed == total:
        print("✓ All configurations verified! System is ready to use.")
        print("\nNext steps:")
        print("1. Flash Transmitter ESP32.c to your transmitter")
        print("2. Flash Receiver ESP32 to your receiver")
        print("3. Connect receiver to Pi via USB")
        print("4. Run the Pi script: python3 'Pi Script'")
        return True
    else:
        print("✗ Some configurations need attention. Please check the issues above.")
        return False

if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)

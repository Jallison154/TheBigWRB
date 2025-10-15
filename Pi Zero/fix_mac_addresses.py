#!/usr/bin/env python3
"""
Script to help fix MAC address mismatches
"""
import os
import sys

def update_transmitter_mac(new_rx_mac):
    """Update the receiver MAC in transmitter code"""
    transmitter_file = "Transmitter/Transmitter_ESP32.ino"
    
    if not os.path.exists(transmitter_file):
        print(f"❌ {transmitter_file} not found")
        return False
    
    try:
        with open(transmitter_file, 'r') as f:
            content = f.read()
        
        # Find and replace the RX_MAC line
        old_pattern = r'uint8_t RX_MAC\[\] = \{ [^}]+\};'
        new_line = f"uint8_t RX_MAC[] = {{ {new_rx_mac} }};"
        
        new_content = re.sub(old_pattern, new_line, content)
        
        if new_content != content:
            with open(transmitter_file, 'w') as f:
                f.write(new_content)
            print(f"✅ Updated transmitter to use receiver MAC: {new_rx_mac}")
            return True
        else:
            print("❌ Could not find RX_MAC line to update")
            return False
            
    except Exception as e:
        print(f"❌ Error updating transmitter: {e}")
        return False

def update_receiver_mac(new_tx_mac):
    """Update the allowed transmitter MAC in receiver code"""
    receiver_file = "Receiver/Receiver ESP32"
    
    if not os.path.exists(receiver_file):
        print(f"❌ {receiver_file} not found")
        return False
    
    try:
        with open(receiver_file, 'r') as f:
            content = f.read()
        
        # Find and replace the ALLOWED_TX_MACS line
        old_pattern = r'\{ 0x58,0x8C,0x81,0x9F,0x22,0xAC \}'
        new_line = f"{{ {new_tx_mac} }}"
        
        new_content = content.replace(old_pattern, new_line)
        
        if new_content != content:
            with open(receiver_file, 'w') as f:
                f.write(new_content)
            print(f"✅ Updated receiver to accept transmitter MAC: {new_tx_mac}")
            return True
        else:
            print("❌ Could not find ALLOWED_TX_MACS line to update")
            return False
            
    except Exception as e:
        print(f"❌ Error updating receiver: {e}")
        return False

def main():
    print("🔧 MAC Address Fix Tool")
    print("=" * 30)
    print()
    print("This tool will help you fix MAC address mismatches.")
    print()
    print("First, find your ESP32 MAC addresses:")
    print("1. Connect each ESP32 to USB")
    print("2. Open Serial Monitor (115200 baud)")
    print("3. Look for 'MAC Address: XX:XX:XX:XX:XX:XX'")
    print()
    
    # Get receiver MAC from user
    print("📻 Enter RECEIVER MAC address (format: 0x58,0x8C,0x81,0x9E,0x30,0x10):")
    rx_mac = input("Receiver MAC: ").strip()
    
    if not rx_mac:
        print("❌ No receiver MAC provided")
        return
    
    # Get transmitter MAC from user
    print()
    print("📡 Enter TRANSMITTER MAC address (format: 0x58,0x8C,0x81,0x9F,0x22,0xAC):")
    tx_mac = input("Transmitter MAC: ").strip()
    
    if not tx_mac:
        print("❌ No transmitter MAC provided")
        return
    
    print()
    print("🔄 Updating MAC addresses...")
    
    # Update transmitter
    if update_transmitter_mac(rx_mac):
        print("✅ Transmitter updated")
    else:
        print("❌ Failed to update transmitter")
    
    # Update receiver
    if update_receiver_mac(tx_mac):
        print("✅ Receiver updated")
    else:
        print("❌ Failed to update receiver")
    
    print()
    print("📤 Next steps:")
    print("1. Upload updated code to both ESP32 devices")
    print("2. Test the connection")
    print("3. Check Serial Monitor for connection status")

if __name__ == "__main__":
    import re
    main()

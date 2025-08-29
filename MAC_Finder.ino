/*
 * MAC Address Finder for ESP32
 * 
 * This simple sketch will print the MAC address of your ESP32 device.
 * Use this to find the MAC addresses you need to configure in your
 * transmitter and receiver code.
 */

#include <WiFi.h>

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("=== ESP32 MAC Address Finder ===");
  Serial.println();
  
  // Get and print the MAC address
  String macAddress = WiFi.macAddress();
  Serial.printf("Device MAC Address: %s\n", macAddress.c_str());
  
  // Also print in the format used in the code
  Serial.println();
  Serial.println("For use in code (replace the MAC in your transmitter/receiver):");
  Serial.print("uint8_t MAC[] = { ");
  
  // Parse the MAC address string and convert to hex values
  String mac = WiFi.macAddress();
  mac.replace(":", "");
  
  for (int i = 0; i < 12; i += 2) {
    String byteStr = mac.substring(i, i + 2);
    int byteVal = strtol(byteStr.c_str(), NULL, 16);
    Serial.printf("0x%02X", byteVal);
    if (i < 10) Serial.print(", ");
  }
  Serial.println(" };");
  
  Serial.println();
  Serial.println("Copy this MAC address to your transmitter or receiver code.");
  Serial.println("For transmitter: Set as RX_MAC");
  Serial.println("For receiver: Add to ALLOWED_TX_MACS array");
}

void loop() {
  // Nothing to do here
  delay(1000);
}

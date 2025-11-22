# Q_ble - iOS Bluetooth App

An iOS app that finds nearby Bluetooth devices and lets you send messages to them.

![iOS 14.0+](https://img.shields.io/badge/iOS-14.0+-blue.svg)

## 🚀 How to Use

### Setup
1. Open `Q_ble.xcodeproj` in Xcode
2. Connect your iPhone (Bluetooth doesn't work in simulator)
3. Select your device and click Run
4. Allow Bluetooth permission when asked

### Finding Devices
1. Tap "Start Scanning"
2. Wait for devices to appear in the list
3. Devices are sorted by signal strength (closest first)

### Connecting
1. Tap on a device (look for "BLE Peer" or devices without warning icons)
2. Wait for connection
3. Start sending messages!

### Sending Messages
1. Type your message
2. Tap the send button or press Return
3. Messages appear in the chat with timestamps

## 📱 Screenshots

### Main Screen - Device Discovery
![Device Discovery Screen](Screenshots/device_discovery.png)
The main screen shows:
- Start/Stop scanning button
- List of nearby Bluetooth devices
- Signal strength for each device

### Device List
![Device List Screen](Screenshots/device_list.png)
When scanning, you'll see:
- All nearby Bluetooth devices
- Which devices you can connect to
- Signal strength (green = strong, red = weak)

### Chat Screen
![Connection Screen](Screenshots/device_connection.png)
After connecting, you can:
- See device information
- Send and receive messages
- View message history

## ✨ Features

- Find nearby Bluetooth devices
- See signal strength for each device
- Connect to compatible devices
- Send and receive text messages
- Chat-like interface with message history

## 📋 Requirements

- iPhone or iPad with iOS 14.0 or later
- Physical device (simulator doesn't support Bluetooth)
- Bluetooth enabled on your device

## 🔗 Peer Device

To test the app, you need the macOS PeerDevice app running:
- See `../PeerDevice/README.md` for setup
- Start the PeerDevice app and click "Start Advertising"
- Your iPhone will find it in the device list

## 🐛 Troubleshooting

**No devices found?**
- Make sure scanning is active (green indicator)
- Check that PeerDevice is running and advertising
- Move devices closer together

**Can't connect?**
- Only devices with matching service can connect
- Make sure you're not already connected to another device

**Messages not working?**
- Check that you see "Connected" status
- Make sure messages are under 512 characters
- Verify PeerDevice is running

## 📁 Files

- `DeviceListView.swift` - Main screen with device list
- `DeviceConnectionView.swift` - Chat screen
- `BluetoothManager.swift` - Handles all Bluetooth operations
- `DiscoveredDevice.swift` - Device information model

---

**Note**: This app needs a real iPhone or iPad. Bluetooth doesn't work in the simulator.

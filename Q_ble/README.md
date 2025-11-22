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
![](https://github.com/yaelbe/Q/blob/main/screens/Screenshot%202025-11-22%20at%2023.10.00.png)
1. Tap "Start Scanning"
2. Wait for devices to appear in the list
3. Devices are sorted by signal strength (closest first)

### Connecting
![](https://github.com/yaelbe/Q/blob/main/screens/Screenshot%202025-11-22%20at%2023.10.05.png)

1. Tap on a device (look for "BLE Peer" or devices without warning icons)
2. Wait for connection
3. Start sending messages!

### Sending Messages
![](https://github.com/yaelbe/Q/blob/main/screens/Screenshot%202025-11-22%20at%2023.10.24.png)

1. Type your message
2. Tap the send button or press Return
3. Messages appear in the chat with timestamps

## Features

- Find nearby Bluetooth devices
- See signal strength for each device
- Connect to compatible devices
- Send and receive text messages
- Chat-like interface with message history


## Peer Device

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




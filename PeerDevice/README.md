# PeerDevice - macOS Bluetooth App

A macOS app that acts as a Bluetooth device that your iPhone can connect to and send messages with.

![macOS 11.0+](https://img.shields.io/badge/macOS-11.0+-blue.svg)

## 🚀 How to Use

### Setup
1. Open `PeerDevice.xcodeproj` in Xcode
2. Select your Mac as the target
3. Click Run to start the app
4. Allow Bluetooth permission when asked

### Starting Advertising
![](https://github.com/yaelbe/Q/blob/main/screens/PeerDevice.jpg)

1. Open the PeerDevice app
2. Wait for "Bluetooth is ready" (green indicator)
3. Click "Start Advertising"
4. Your Mac will now appear as "BLE Peer" on nearby iPhones

### Connecting
1. Once advertising starts, wait for an iPhone to connect
2. You'll see "Connected" status when someone connects
3. Start sending messages!

### Sending Messages
1. Type your message in the text field
2. Click the send button (paper airplane icon)
3. Messages appear in the chat area
4. Messages from iPhone will appear on the left (gray)
5. Your messages appear on the right (blue)

### Disconnecting
- Click "Disconnect" button to end the connection
- Or wait for the iPhone to disconnect
- Advertising will restart automatically

## ✨ Features

- Advertise as a Bluetooth device
- Accept connections from iPhones
- Send and receive text messages
- Chat-like interface
- Auto-restart advertising after disconnect
- Connection status indicators

## 📋 Requirements

- Mac with macOS 11.0 or later
- Bluetooth enabled
- Bluetooth permission granted

## 🔗 iOS App

This app works with the iOS Q_ble app:
- See `../Q_ble/README.md` for iOS app setup
- The iPhone app will find this Mac as "BLE Peer"
- Both apps use the same service UUID to connect

## 🐛 Troubleshooting

**"Start Advertising" button is disabled?**
- Check that Bluetooth is ready (green indicator)
- Make sure you're not already connected
- Grant Bluetooth permission in System Settings → Privacy & Security → Bluetooth

**iPhone can't find this device?**
- Make sure advertising is active (green "Advertising" status)
- Check that both devices have Bluetooth enabled
- Move devices closer together (within 10 meters)

**Can't send messages?**
- Verify you see "Connected" status
- Make sure messages are under 512 characters
- Check that the iPhone app is still connected

**Permission issues?**
- Go to System Settings → Privacy & Security → Bluetooth
- Make sure PeerDevice is enabled
- Restart the app if needed

## 📁 Files

- `PeerDeviceView.swift` - Main app interface
- `PeripheralManager.swift` - Handles Bluetooth operations
- `BluetoothConstants.swift` - Shared Bluetooth settings
- `PeerDeviceApp.swift` - App entry point

---

**Note**: This app must be running for the iPhone app to connect to it.

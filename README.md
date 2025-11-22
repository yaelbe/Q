# Q - iOS Bluetooth Assignment

This repository contains the complete iOS Bluetooth Low Energy (BLE) assignment implementation.

## 📱 Projects

### iOS App (Q_ble)
An iOS app that scans for nearby Bluetooth devices and enables two-way messaging.

- **Location:** `Q_ble/`
- **See:** [Q_ble/README.md](Q_ble/README.md) for details

### macOS Peer Device (PeerDevice)
A macOS app that acts as a BLE peripheral for testing the iOS app.

- **Location:** `PeerDevice/`
- **See:** [PeerDevice/README.md](PeerDevice/README.md) for details

## 🚀 Quick Start

1. **iOS App:**
   ```bash
   cd Q_ble
   open Q_ble.xcodeproj
   ```
   - Requires physical iPhone/iPad (Bluetooth doesn't work in simulator)
   - Connect device and run

2. **macOS Peer Device:**
   ```bash
   cd PeerDevice
   open PeerDevice.xcodeproj
   ```
   - Run the app
   - Click "Start Advertising"
   - Your iPhone will discover it

## Features

- Real-time BLE device scanning
- RSSI-based device sorting
- Two-way chat interface
- Service UUID filtering
- Auto-disconnect handling
- Clean MVVM architecture


## 📁 Repository Structure

```
Q/
├── Q_ble/              # iOS App
│   ├── Q_ble/         # Source files
│   └── README.md      # iOS app documentation
├── PeerDevice/         # macOS App
│   ├── PeerDevice/    # Source files
│   └── README.md      # macOS app documentation
└── README.md          # This file
```


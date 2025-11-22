//
//  BluetoothConstants.swift
//  Q_ble
//
//  Centralized Bluetooth constants
//

import Foundation
import CoreBluetooth

enum BluetoothConstants {
    static let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
    static let characteristicUUID = CBUUID(string: "12345678-1234-1234-1234-123456789DEF")
    
    // BLE MTU limits (Maximum Transmission Unit)
    static let maxMessageLength = 512 // bytes (typical BLE MTU is 20-512)
    
    // UI Update intervals
    static let deviceListUpdateInterval: TimeInterval = 0.5 // seconds
}


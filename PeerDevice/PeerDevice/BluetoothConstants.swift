//
//  BluetoothConstants.swift
//  PeerDevice
//
//  Centralized Bluetooth constants (should match iOS app)
//

import Foundation
import CoreBluetooth

enum BluetoothConstants {
    static let serviceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789ABC")
    static let characteristicUUID = CBUUID(string: "12345678-1234-1234-1234-123456789DEF")
    
    // BLE MTU limits (Maximum Transmission Unit)
    static let maxMessageLength = 512 // bytes (typical BLE MTU is 20-512)
    
    // Advertisement data limits
    static let maxAdvertisementDataSize = 28 // bytes (BLE advertisement limit)
    
    // UI Constants
    static let autoStartDelay: TimeInterval = 0.5 // seconds
    static let chatViewHeight: CGFloat = 200
}


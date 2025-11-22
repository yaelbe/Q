//
//  DiscoveredDevice.swift
//  Q_ble
//
//  Created for iOS Bluetooth Assignment
//

import Foundation
import CoreBluetooth

struct DiscoveredDevice: Identifiable, Equatable {
    let id: UUID
    let peripheral: CBPeripheral
    let name: String
    let rssi: Int
    let advertisementData: [String: Any]
    var manufacturerData: Data?
    
    init(peripheral: CBPeripheral, rssi: Int, advertisementData: [String: Any]) {
        self.id = peripheral.identifier
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
        
        // Extract manufacturer data if available
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            self.manufacturerData = manufacturerData
        }
        
        // macOS CoreBluetooth limitation: CBAdvertisementDataLocalNameKey is often not included
        // in advertisement data, even when set. This is a known macOS behavior.
        // Solution: Check advertisement data first, then check if device has our service UUID
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
           !advertisementName.isEmpty {
            self.name = advertisementName
        } else {
            // macOS doesn't include local name in advertisement data
            // Use peripheral.name as fallback (will be Mac's system name)
            self.name = peripheral.name ?? "Unknown Device"
        }
    }
    
    // Equatable conformance - compare by ID since CBPeripheral is not Equatable
    static func == (lhs: DiscoveredDevice, rhs: DiscoveredDevice) -> Bool {
        return lhs.id == rhs.id
    }
    
    var displayName: String {
        name.isEmpty ? "Unknown Device" : name
    }
    
    var rssiString: String {
        "\(rssi) dBm"
    }
    
    var manufacturerDataString: String? {
        guard let data = manufacturerData else { return nil }
        return data.map { String(format: "%02X", $0) }.joined(separator: ":")
    }
    
    // Check if device has the matching service UUID in advertisement data
    var hasMatchingService: Bool {
        guard let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else {
            return false
        }
        return serviceUUIDs.contains(BluetoothConstants.serviceUUID)
    }
}


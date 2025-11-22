//
//  PeripheralManager.swift
//  PeerDevice
//
//  Minimal macOS peer device for iOS Bluetooth Assignment
//

import Foundation
import CoreBluetooth
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isSent: Bool
    let timestamp = Date()
}

class PeripheralManager: NSObject, ObservableObject {
    static let shared = PeripheralManager()
    
    static let serviceUUID = BluetoothConstants.serviceUUID
    static let characteristicUUID = BluetoothConstants.characteristicUUID
    
    @Published var isAdvertising = false
    @Published var isConnected = false
    @Published var messages: [ChatMessage] = []
    @Published var bluetoothState: String = "Initializing..."
    @Published var lastError: String?
    
    private var peripheralManager: CBPeripheralManager!
    private var transferCharacteristic: CBMutableCharacteristic?
    private var connectedCentral: CBCentral?
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.main)
        DispatchQueue.main.async {
            self.updateBluetoothState(self.peripheralManager.state)
        }
    }
    
    func startAdvertising() {
        let currentState = peripheralManager.state
        
        if currentState == .unauthorized || currentState == .unsupported {
            updateBluetoothState(currentState)
            lastError = getBluetoothStateMessage(currentState)
            bluetoothState = getBluetoothStateMessage(currentState)
            return
        }
        
        guard currentState == .poweredOn else {
            let stateMessage = getBluetoothStateMessage(currentState)
            lastError = stateMessage
            bluetoothState = stateMessage
            return
        }
        
        lastError = nil
        
        // Prevent starting advertising while connected
        // This prevents the bug where starting advertising breaks message sending
        if isConnected {
            lastError = "Please disconnect first before starting advertising"
            return
        }
        
        // Create new service/characteristic
        transferCharacteristic = CBMutableCharacteristic(
            type: PeripheralManager.characteristicUUID,
            properties: [.read, .write, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        guard let characteristic = transferCharacteristic else {
            lastError = "Failed to create characteristic"
            return
        }
        
        let service = CBMutableService(type: PeripheralManager.serviceUUID, primary: true)
        service.characteristics = [characteristic]
        
        peripheralManager.add(service)
        
        // Don't start advertising until service is added
        // We'll start advertising in didAdd service callback
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        peripheralManager.removeAllServices()
        isAdvertising = false
        isConnected = false
        messages.removeAll()
    }
    
    func disconnect() {
        guard isConnected else { return }
        
        // Remove services to disconnect the central
        // This will trigger didUnsubscribeFrom on the central side
        peripheralManager.removeAllServices()
        
        // Clear connection state
        connectedCentral = nil
        isConnected = false
        messages.removeAll()
        
        // Restart advertising to allow reconnection
        if peripheralManager.state == .poweredOn {
            startAdvertising()
        }
    }
    
    func sendMessage(_ message: String) {
        // Validate message length (BLE MTU limit)
        guard message.count <= BluetoothConstants.maxMessageLength else {
            DispatchQueue.main.async {
                self.lastError = "Message too long (max \(BluetoothConstants.maxMessageLength) characters)"
            }
            return
        }
        
        guard let characteristic = transferCharacteristic,
              let central = connectedCentral,
              let data = message.data(using: .utf8) else {
            return
        }
        
        // Add sent message to chat
        DispatchQueue.main.async {
            self.messages.append(ChatMessage(text: message, isSent: true))
            
            // Limit message history to prevent memory issues
            if self.messages.count > 100 {
                self.messages.removeFirst(self.messages.count - 100)
            }
        }
        
        peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: [central])
    }
    
    private func updateBluetoothState(_ state: CBManagerState) {
        bluetoothState = getBluetoothStateMessage(state)
    }
    
    private func getBluetoothStateMessage(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "Bluetooth state unknown - initializing..."
        case .resetting:
            return "Bluetooth is resetting..."
        case .unsupported:
            return "Bluetooth not supported or permission needed. Grant permission in System Settings → Privacy & Security → Bluetooth"
        case .unauthorized:
            return "Bluetooth permission denied. Go to System Settings → Privacy & Security → Bluetooth and enable PeerDevice"
        case .poweredOff:
            return "Bluetooth is turned off. Enable in System Settings → Bluetooth"
        case .poweredOn:
            return "Bluetooth is ready"
        @unknown default:
            return "Unknown Bluetooth state"
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension PeripheralManager: CBPeripheralManagerDelegate {
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        updateBluetoothState(peripheral.state)
        
        if peripheral.state == .poweredOn && !isAdvertising {
            DispatchQueue.main.asyncAfter(deadline: .now() + BluetoothConstants.autoStartDelay) {
                self.startAdvertising()
            }
        } else if peripheral.state != .poweredOn && isAdvertising {
            stopAdvertising()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.lastError = "Error adding service: \(error.localizedDescription)"
            }
        } else {
            // Now that service is added, start advertising
            // Note: Advertisement data is limited to 28 bytes total
            // Service UUID takes ~16 bytes, so local name must be short
            // "BLE Peer" (8 bytes) fits better than "BLE Peer Device" (16 bytes)
            let advertisementData: [String: Any] = [
                CBAdvertisementDataLocalNameKey: "BLE Peer",  // Shorter name to fit within 28-byte limit
                CBAdvertisementDataServiceUUIDsKey: [PeripheralManager.serviceUUID]
            ]
            
            peripheralManager.startAdvertising(advertisementData)
            DispatchQueue.main.async {
                self.isAdvertising = true
            }
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.isAdvertising = false
                self.lastError = "Error advertising: \(error.localizedDescription)"
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        DispatchQueue.main.async {
            self.connectedCentral = central
            self.isConnected = true
            
            // Stop advertising once connected to save power
            // Connection is established, no need to advertise anymore
            if self.isAdvertising {
                self.peripheralManager.stopAdvertising()
                self.isAdvertising = false
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        DispatchQueue.main.async {
            self.connectedCentral = nil
            self.isConnected = false
            self.messages.removeAll() // Clear messages on disconnect
            
            // Restart advertising when disconnected to allow reconnection
            if !self.isAdvertising && self.peripheralManager.state == .poweredOn {
                self.startAdvertising()
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            // Always respond, even if it's not our characteristic
            // Check if this is our characteristic
            if request.characteristic.uuid == PeripheralManager.characteristicUUID {
                if let value = request.value,
                   let message = String(data: value, encoding: .utf8) {
                    // Update the characteristic value
                    transferCharacteristic?.value = value
                    
                    DispatchQueue.main.async {
                        self.messages.append(ChatMessage(text: message, isSent: false))
                        
                        // Limit message history to prevent memory issues
                        if self.messages.count > 100 {
                            self.messages.removeFirst(self.messages.count - 100)
                        }
                    }
                    peripheral.respond(to: request, withResult: .success)
                } else {
                    peripheral.respond(to: request, withResult: .invalidAttributeValueLength)
                }
            } else {
                peripheral.respond(to: request, withResult: .attributeNotFound)
            }
        }
    }
}


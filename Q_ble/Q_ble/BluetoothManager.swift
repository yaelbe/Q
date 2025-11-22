//
//  BluetoothManager.swift
//  Q_ble
//
//  Created for iOS Bluetooth Assignment
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

class BluetoothManager: NSObject, ObservableObject {
    static let shared = BluetoothManager()
    
    // Service and Characteristic UUIDs for communication
    static let serviceUUID = BluetoothConstants.serviceUUID
    static let characteristicUUID = BluetoothConstants.characteristicUUID
    
    @Published var isScanning = false
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var connectedDevice: CBPeripheral?
    @Published var connectionStatus: ConnectionStatus = .disconnected
    @Published var messages: [ChatMessage] = []
    @Published var lastError: String?
    
    enum ConnectionStatus: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)
        
        static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
            switch (lhs, rhs) {
            case (.disconnected, .disconnected),
                 (.connecting, .connecting),
                 (.connected, .connected):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [UUID: DiscoveredDevice] = [:]
    private var updateTimer: Timer?
    private var needsUpdate = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            lastError = "Bluetooth is not available. Please enable Bluetooth in Settings."
            return
        }
        
        guard !isScanning else { return }
        
        isScanning = true
        discoveredPeripherals.removeAll()
        discoveredDevices = []
        needsUpdate = false
        
        // Start update timer to batch UI updates (prevents flickering)
        updateTimer = Timer.scheduledTimer(withTimeInterval: BluetoothConstants.deviceListUpdateInterval, repeats: true) { [weak self] _ in
            self?.performBatchUpdate()
        }
        
        // Scan for any BLE devices
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }
    
    func stopScanning() {
        guard isScanning else { return }
        isScanning = false
        centralManager.stopScan()
        updateTimer?.invalidate()
        updateTimer = nil
        
        performBatchUpdate()
    }
    
    func connect(to device: DiscoveredDevice) {
        guard connectionStatus != .connecting && connectionStatus != .connected else {
            return
        }
        
        connectionStatus = .connecting
        connectedDevice = device.peripheral
        centralManager.connect(device.peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = connectedDevice {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectedDevice = nil
        connectionStatus = .disconnected
        messages.removeAll()
    }
    
    func sendMessage(_ message: String) {
        guard let peripheral = connectedDevice else {
            lastError = "Cannot send message: Device not ready"
            return
        }
        
        guard message.count <= BluetoothConstants.maxMessageLength else {
            lastError = "Message too long (max \(BluetoothConstants.maxMessageLength) characters)"
            return
        }
        
        guard let service = peripheral.services?.first(where: { $0.uuid == BluetoothManager.serviceUUID }) else {
            lastError = "Cannot send message: Service not found"
            return
        }
        
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == BluetoothManager.characteristicUUID }) else {
            lastError = "Cannot send message: Characteristic not found"
            return
        }
        
        guard let data = message.data(using: .utf8) else {
            lastError = "Cannot send message: Failed to encode message"
            return
        }
        
        // Add sent message to chat
        messages.append(ChatMessage(text: message, isSent: true))
        
        // Limit message history to prevent memory issues
        if messages.count > 100 {
            messages.removeFirst(messages.count - 100)
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    private func updateDeviceList(_ device: DiscoveredDevice) {
        // Update the device in our dictionary
        discoveredPeripherals[device.id] = device
        needsUpdate = true
    }
    
    private func performBatchUpdate() {
        guard needsUpdate else { return }
        
        // Update the published array with all discovered devices, sorted by RSSI (strongest first)
        let sortedDevices = Array(discoveredPeripherals.values)
            .sorted { $0.rssi > $1.rssi } // Sort by RSSI (strongest first)
        
        // Only update if the list actually changed (prevents unnecessary UI refreshes)
        if sortedDevices != discoveredDevices {
            discoveredDevices = sortedDevices
        }
        
        needsUpdate = false
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            lastError = nil
        case .poweredOff:
            lastError = "Bluetooth is turned off. Please enable Bluetooth in Settings."
            isScanning = false
        case .unauthorized:
            lastError = "Bluetooth permission denied. Please enable in Settings."
            isScanning = false
        case .unsupported:
            lastError = "Bluetooth is not supported on this device."
            isScanning = false
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let device = DiscoveredDevice(
            peripheral: peripheral,
            rssi: RSSI.intValue,
            advertisementData: advertisementData
        )
        
        DispatchQueue.main.async {
            self.updateDeviceList(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Ensure we're using the correct peripheral
        connectedDevice = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([BluetoothManager.serviceUUID])
        connectionStatus = .connected
        lastError = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus = .error(error?.localizedDescription ?? "Connection failed")
        connectedDevice = nil
        lastError = error?.localizedDescription ?? "Failed to connect"
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionStatus = .disconnected
        connectedDevice = nil
        messages.removeAll()
        if let error = error {
            lastError = error.localizedDescription
        } else {
            lastError = nil
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == BluetoothManager.serviceUUID {
                peripheral.discoverCharacteristics([BluetoothManager.characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == BluetoothManager.characteristicUUID {
                // Enable notifications to receive messages
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value,
              let message = String(data: data, encoding: .utf8) else { return }
        
        DispatchQueue.main.async {
            self.messages.append(ChatMessage(text: message, isSent: false))
            
            // Limit message history to prevent memory issues
            if self.messages.count > 100 {
                self.messages.removeFirst(self.messages.count - 100)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.lastError = "Failed to send message: \(error.localizedDescription)"
            }
        }
    }
    
    // Detect when peripheral removes services 
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // Check if our service was removed
        let ourServiceRemoved = invalidatedServices.contains { $0.uuid == BluetoothManager.serviceUUID }
        
        if ourServiceRemoved {
            // Service was removed, disconnect
            DispatchQueue.main.async {
                self.disconnect()
                self.lastError = "Device disconnected (service removed)"
            }
        }
    }
}


//
//  DeviceListView.swift
//

import SwiftUI

struct DeviceListView: View {
    @ObservedObject private var bluetoothManager = BluetoothManager.shared
    @State private var selectedDevice: DiscoveredDevice?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Scrollable List - enables large title animation
                List {
                        if bluetoothManager.discoveredDevices.isEmpty && !bluetoothManager.isScanning {
                            // Empty state - no scrolling, no header
                            Section {
                                VStack(spacing: 16) {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No devices found")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    Text("Start scanning to discover nearby BLE devices")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                .listRowInsets(EdgeInsets())
                            }
                        } else {
                            // Spacer at top to account for sticky controls (200pt)
                            Section {
                                Color(.clear)
                                    .frame(height: 150)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                            
                            // Device List
                            Section {
                                ForEach(bluetoothManager.discoveredDevices) { device in
                                    DeviceRow(device: device)
                                        .onTapGesture {
                                            if device.hasMatchingService {
                                                selectedDevice = device
                                            }
                                        }
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                }
                            } header: {
                                Text("Discovered Devices")
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollDisabled(bluetoothManager.discoveredDevices.isEmpty && !bluetoothManager.isScanning)
                    
                    // Sticky Control Section - positioned below large title
                    VStack(spacing: 0) {
                        // Control Card
                        VStack(spacing: 16) {
                            // Bluetooth Status
                            HStack {
                                Circle()
                                    .fill(bluetoothManager.isScanning ? Color.green : Color.gray)
                                    .frame(width: 10, height: 10)
                                Text(bluetoothManager.isScanning ? "Scanning for devices..." : "Not scanning")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Scan Button
                            Button(action: {
                                if bluetoothManager.isScanning {
                                    bluetoothManager.stopScanning()
                                } else {
                                    bluetoothManager.startScanning()
                                }
                            }) {
                                HStack {
                                    Image(systemName: bluetoothManager.isScanning ? "stop.circle.fill" : "play.circle.fill")
                                        .font(.title3)
                                    Text(bluetoothManager.isScanning ? "Stop Scanning" : "Start Scanning")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(bluetoothManager.isScanning ? Color.red : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            // Error Message
                            if let error = bluetoothManager.lastError {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(error)
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                .navigationTitle("BLE Devices")
                .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedDevice) { device in
                DeviceConnectionView(device: device)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}


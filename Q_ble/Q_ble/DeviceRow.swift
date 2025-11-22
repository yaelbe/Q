//
//  DeviceRow.swift
//  Q_ble
//
//  Created for iOS Bluetooth Assignment
//

import SwiftUI

struct DeviceRow: View {
    let device: DiscoveredDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(device.displayName)
                            .font(.headline)
                        if !device.hasMatchingService {
                            Image(systemName: "exclamationmark.circle")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text(device.id.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if !device.hasMatchingService {
                        Text("Cannot connect - service not available")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // RSSI Indicator
                    HStack(spacing: 4) {
                        Image(systemName: rssiIcon(for: device.rssi))
                            .foregroundColor(rssiColor(for: device.rssi))
                        Text(device.rssiString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Manufacturer Data
            if let manufacturerData = device.manufacturerDataString {
                Text("Manufacturer: \(manufacturerData)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .opacity(device.hasMatchingService ? 1.0 : 0.6)
    }
    
    private func rssiIcon(for rssi: Int) -> String {
        if rssi > -50 { return "wifi" }
        if rssi > -70 { return "wifi" }
        return "wifi.exclamationmark"
    }
    
    private func rssiColor(for rssi: Int) -> Color {
        if rssi > -50 { return .green }
        if rssi > -70 { return .orange }
        return .red
    }
}


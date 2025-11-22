//
//  DeviceConnectionView.swift
//  Q_ble
//
//  Created for iOS Bluetooth Assignment
//

import SwiftUI
import CoreBluetooth

struct DeviceConnectionView: View {
    let device: DiscoveredDevice
    @ObservedObject private var bluetoothManager = BluetoothManager.shared
    @State private var messageText = ""
    @Environment(\.dismiss) var dismiss
    
    var isConnected: Bool {
        bluetoothManager.connectedDevice?.identifier == device.id &&
        bluetoothManager.connectionStatus == .connected
    }
    
    var body: some View {
        VStack(spacing: 20) {
                // Device Info
                VStack(spacing: 12) {
                    Image(systemName: isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isConnected ? .green : .gray)
                    
                    Text(device.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(device.id.uuidString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Connection Status
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 10, height: 10)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Connection Button
                if !isConnected {
                    Button(action: {
                        bluetoothManager.connect(to: device)
                    }) {
                        HStack {
                            Image(systemName: "link")
                            Text("Connect")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(bluetoothManager.connectionStatus == .connecting ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(bluetoothManager.connectionStatus == .connecting)
                    .padding(.horizontal)
                }
                
                // Chat Section (only when connected)
                if isConnected {
                    chatSection
                }
                
                // Disconnect Button
                if isConnected {
                    Button(action: {
                        bluetoothManager.disconnect()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle")
                            Text("Disconnect")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Device Details")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                // Disconnect when sheet is closed
                if isConnected {
                    bluetoothManager.disconnect()
                }
            }
    }
    
    private var statusText: String {
        switch bluetoothManager.connectionStatus {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    private var statusColor: Color {
        switch bluetoothManager.connectionStatus {
        case .disconnected:
            return .gray
        case .connecting:
            return .orange
        case .connected:
            return .green
        case .error:
            return .red
        }
    }
    
    private var chatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Messages")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(bluetoothManager.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: 300)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .onChange(of: bluetoothManager.messages.count) {
                    if let lastMessage = bluetoothManager.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Enter message...", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        if !messageText.isEmpty {
                            sendMessage()
                        }
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        bluetoothManager.sendMessage(messageText)
        messageText = ""
    }
}

// MARK: - Chat Bubble View

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isSent {
                Spacer()
            }
            
            VStack(alignment: message.isSent ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isSent ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isSent ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 250, alignment: message.isSent ? .trailing : .leading)
            
            if !message.isSent {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    // Note: Preview requires a mock peripheral - actual device needed for real testing
    Text("Device Connection View")
        .padding()
}


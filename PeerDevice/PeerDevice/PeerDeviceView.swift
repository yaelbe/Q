//
//  PeerDeviceView.swift
//  PeerDevice
//
//  Minimal macOS peer device for iOS Bluetooth Assignment
//

import SwiftUI
import AppKit

struct PeerDeviceView: View {
    @ObservedObject private var peripheralManager = PeripheralManager.shared
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("BLE Peer Device")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 24)
            
            statusSection
            
            if let error = peripheralManager.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            advertisingButton
            
            if !isBluetoothReady && !peripheralManager.isAdvertising {
                permissionHelpSection
            }
            
            Divider()
            
            messageSection
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - View Components
    
    private var statusSection: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(bluetoothStatusColor)
                    .frame(width: 12, height: 12)
                Text(peripheralManager.bluetoothState)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Circle()
                    .fill(peripheralManager.isAdvertising ? .green : .gray)
                    .frame(width: 12, height: 12)
                Text(peripheralManager.isAdvertising ? "Advertising" : "Stopped")
                    .font(.subheadline)
            }
        }
    }
    
    private var advertisingButton: some View {
        Button(action: {
            if peripheralManager.isAdvertising {
                peripheralManager.stopAdvertising()
            } else {
                peripheralManager.startAdvertising()
            }
        }) {
            Text(peripheralManager.isAdvertising ? "Stop Advertising" : "Start Advertising")
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonBackgroundColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled((!canStartAdvertising && !peripheralManager.isAdvertising) || peripheralManager.isConnected)
    }
    
    private var permissionHelpSection: some View {
        VStack(spacing: 8) {
            Text("To enable Bluetooth:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                peripheralManager.startAdvertising()
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Request Bluetooth Permission")
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            .buttonStyle(.plain)
            
            Button(action: openBluetoothSettings) {
                HStack {
                    Image(systemName: "gear")
                    Text("Open Bluetooth Settings")
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Messages")
                    .font(.headline)
                Spacer()
                if peripheralManager.isConnected {
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("Connected")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Button(action: {
                            peripheralManager.disconnect()
                        }) {
                            Text("Disconnect")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(peripheralManager.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: BluetoothConstants.chatViewHeight)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
                .onChange(of: peripheralManager.messages.count) {
                    if let lastMessage = peripheralManager.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            VStack(spacing: 4) {
                if !peripheralManager.isConnected {
                    Text("Waiting for device to connect...")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    TextField("Enter message...", text: $messageText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            if canSendMessage {
                                sendMessage()
                            }
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(canSendMessage ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!canSendMessage)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var bluetoothStatusColor: Color {
        if peripheralManager.bluetoothState.contains("ready") {
            return .green
        } else if peripheralManager.bluetoothState.contains("denied") || peripheralManager.bluetoothState.contains("off") {
            return .red
        } else {
            return .orange
        }
    }
    
    private var isBluetoothReady: Bool {
        peripheralManager.bluetoothState.contains("ready")
    }
    
    private var canStartAdvertising: Bool {
        isBluetoothReady && !peripheralManager.isConnected
    }
    
    private var canSendMessage: Bool {
        !messageText.isEmpty && peripheralManager.isConnected
    }
    
    private var buttonBackgroundColor: Color {
        if peripheralManager.isAdvertising {
            return .red
        } else if canStartAdvertising && !peripheralManager.isConnected {
            return .blue
        } else {
            return .gray
        }
    }
    
    // MARK: - Methods
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        peripheralManager.sendMessage(messageText)
        messageText = ""
    }
    
    private func openBluetoothSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Bluetooth") {
            NSWorkspace.shared.open(url)
        }
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
                    .background(message.isSent ? Color.blue : Color(.controlAccentColor))
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
    PeerDeviceView()
}


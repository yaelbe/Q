//
//  PeerDeviceApp.swift
//  PeerDevice
//
//  Minimal macOS peer device for iOS Bluetooth Assignment
//

import SwiftUI
import AppKit

@main
struct PeerDeviceApp: App {
    init() {
        // Prevent multiple instances from running
        checkForExistingInstance()
    }
    
    var body: some Scene {
        WindowGroup {
            PeerDeviceView()
                .frame(width: 400, height: 500)
        }
        .windowResizability(.contentSize)
    }
    
    private func checkForExistingInstance() {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "QueenCode.PeerDevice"
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier)
        
        // Filter out the current instance
        let otherInstances = runningApps.filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        
        if !otherInstances.isEmpty {
            // Another instance is already running
            // Show alert to user
            let alert = NSAlert()
            alert.messageText = "PeerDevice is Already Running"
            alert.informativeText = "Another instance of PeerDevice is already running. The existing window will be brought to the front."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
            // Activate the existing instance and quit this one
            if let existingInstance = otherInstances.first {
                existingInstance.activate(options: [.activateAllWindows])
            }
            
            // Quit this instance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}


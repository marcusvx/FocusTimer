//
//  AppActivityMonitor.swift
//  FocusTimer
//
//  Created by Marcus Vinicius Ximenes on 23/05/25.
//


import AppKit // For NSWorkspace
import Foundation

class AppActivityMonitor {
    private var loggingTimer: Timer?
    var logHandler: ((String, Date) -> Void)? // Closure to handle logging the app name and timestamp

    func startLogging(interval: TimeInterval) {
        stopLogging() // Ensure no duplicate timers
        loggingTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.logCurrentApp()
        }
        logCurrentApp() // Log immediately on start
    }

    func stopLogging() {
        loggingTimer?.invalidate()
        loggingTimer = nil
    }

    private func logCurrentApp() {
        if let frontApp = NSWorkspace.shared.frontmostApplication {
            let appName = frontApp.localizedName ?? "Unknown App"
            logHandler?(appName, Date())
           // print("Active App: \(appName) at \(Date())") // For debugging
        }
    }
}

import Combine
import Foundation

#if os(macOS)
    import AppKit
#endif

class AppActivityMonitor: ObservableObject {
    @Published var isLogging: Bool = false
    @Published var lastDetectedAppName: String = "N/A"

    private var loggingTimer: Timer?

    var logHandler: ((String, Date) -> Void)?

    func startLogging(interval: TimeInterval) {
        stopLogging()
        isLogging = true
        loggingTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.logCurrentActiveApp()
        }
        logCurrentActiveApp()
    }

    func stopLogging() {
        loggingTimer?.invalidate()
        loggingTimer = nil
        isLogging = false
        lastDetectedAppName = "N/A"
    }

    private func getActiveAppName() -> String {
        #if os(macOS)
            guard let frontApp = NSWorkspace.shared.frontmostApplication else {
                return "Unknown"
            }
            return frontApp.localizedName ?? "Unknown App"
        #else
            return "Not on macOS"
        #endif
    }

    private func logCurrentActiveApp() {
        let appName = getActiveAppName()
        self.lastDetectedAppName = appName

        logHandler?(appName, Date())
    }
}

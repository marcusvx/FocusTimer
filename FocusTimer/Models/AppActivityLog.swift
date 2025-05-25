import Foundation

// Structure for logging individual app activity
struct AppActivityLog: Codable, Identifiable {
    let id: UUID         // Unique identifier for the log entry
    var timestamp: Date  // When this app was frontmost
    var appName: String  // e.g., "Xcode", "Safari"
    // var bundleIdentifier: String? // Optional: e.g., "com.apple.dt.Xcode"

    // Initializer
    init(timestamp: Date = Date(), appName: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.appName = appName
    }
}

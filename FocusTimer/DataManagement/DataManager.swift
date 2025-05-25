import Foundation

class DataManager {
    static let shared = DataManager()

    private let fileManager = FileManager.default
    private let appName: String

    // Base directory for all application data in Application Support
    private var applicationSupportDirectory: URL {
        let appSupportURL = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        return appSupportURL.appendingPathComponent(appName)
    }

    // Directory for individual Pomodoro cycle JSON files
    private var cyclesDirectoryURL: URL {
        let dataDir = applicationSupportDirectory.appendingPathComponent("data")
        return dataDir.appendingPathComponent("cycles")
    }

    // Directory for settings
    private var settingsDirectoryURL: URL {
        applicationSupportDirectory.appendingPathComponent("settings")
    }

    // File URL for preferences.json
    private var preferencesFileURL: URL {
        settingsDirectoryURL.appendingPathComponent("preferences.json")
    }

    private init() {
        // Determine app name (you might want a more robust way, e.g., from Info.plist)
        self.appName =
            Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "MyPomodoroApp"

        // Create necessary directories if they don't exist
        createDirectoryIfNeeded(at: applicationSupportDirectory)
        createDirectoryIfNeeded(
            at: cyclesDirectoryURL.deletingLastPathComponent()
        )  // .../data/
        createDirectoryIfNeeded(at: cyclesDirectoryURL)  // .../data/cycles/
        createDirectoryIfNeeded(at: settingsDirectoryURL)  // .../settings/
    }

    private func createDirectoryIfNeeded(at url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("DataManager: Created directory at \(url.path)")
            } catch {
                // In a real app, consider more robust error handling or logging
                print(
                    "DataManager: Error creating directory at \(url.path): \(error)"
                )
            }
        }
    }

    // MARK: - Pomodoro Cycle Management

    func savePomodoroCycle(_ cycle: PomodoroCycleRecord) {
        let fileName = "cycle_\(cycle.id.uuidString).json"
        let fileURL = cyclesDirectoryURL.appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601  // Standard date format
        encoder.outputFormatting = .prettyPrinted  // Makes the JSON human-readable (optional)

        do {
            let data = try encoder.encode(cycle)
            try data.write(to: fileURL, options: [.atomicWrite])  // Atomic write is safer
            print("DataManager: Pomodoro cycle saved to: \(fileURL.path)")
        } catch {
            print(
                "DataManager: Error saving pomodoro cycle \(cycle.id.uuidString): \(error)"
            )
        }
    }

    func loadPomodoroCycle(byID id: UUID) -> PomodoroCycleRecord? {
        let fileName = "cycle_\(id.uuidString).json"
        let fileURL = cyclesDirectoryURL.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            // print("DataManager: No cycle file found for ID \(id.uuidString)")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let data = try Data(contentsOf: fileURL)
            let cycle = try decoder.decode(PomodoroCycleRecord.self, from: data)
            return cycle
        } catch {
            print(
                "DataManager: Error loading pomodoro cycle \(id.uuidString): \(error)"
            )
            return nil
        }
    }

    func loadAllPomodoroCycles() -> [PomodoroCycleRecord] {
        var cycles: [PomodoroCycleRecord] = []
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: cyclesDirectoryURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )

            for fileURL in fileURLs
            where fileURL.pathExtension == "json"
                && fileURL.lastPathComponent.starts(with: "cycle_")
            {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let cycle = try decoder.decode(
                        PomodoroCycleRecord.self,
                        from: data
                    )
                    cycles.append(cycle)
                } catch {
                    print(
                        "DataManager: Error decoding cycle from \(fileURL.lastPathComponent): \(error)"
                    )
                }
            }
        } catch {
            // This error could happen if the cyclesDirectoryURL doesn't exist or is not readable
            print(
                "DataManager: Error listing contents of cycles directory at \(cyclesDirectoryURL.path): \(error)"
            )
        }

        // Optional: Sort cycles, e.g., by start time, most recent first
        return cycles.sorted(by: { $0.startTime > $1.startTime })
    }

    func deletePomodoroCycle(byID id: UUID) -> Bool {
        let fileName = "cycle_\(id.uuidString).json"
        let fileURL = cyclesDirectoryURL.appendingPathComponent(fileName)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            print(
                "DataManager: Cannot delete. No cycle file found for ID \(id.uuidString)"
            )
            return false
        }

        do {
            try fileManager.removeItem(at: fileURL)
            print("DataManager: Deleted cycle \(id.uuidString)")
            return true
        } catch {
            print(
                "DataManager: Error deleting cycle \(id.uuidString): \(error)"
            )
            return false
        }
    }

    /// Returns the URL to the directory where cycle files are stored.
    /// Useful if other parts of your app (e.g., syncing logic) need to access these files directly.
    public func getCyclesStorageURL() -> URL {
        return cyclesDirectoryURL
    }

    // MARK: - User Settings Management

    func saveUserSettings(_ settings: UserSettings) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(settings)
            try data.write(to: preferencesFileURL, options: [.atomicWrite])
            print(
                "DataManager: User settings saved to: \(preferencesFileURL.path)"
            )
        } catch {
            print("DataManager: Error saving user settings: \(error)")
        }
    }

    func loadUserSettings() -> UserSettings {
        guard fileManager.fileExists(atPath: preferencesFileURL.path) else {
            print(
                "DataManager: Preferences file not found. Returning default settings."
            )
            return UserSettings()  // Return default settings if file doesn't exist
        }

        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: preferencesFileURL)
            let settings = try decoder.decode(UserSettings.self, from: data)
            return settings
        } catch {
            print(
                "DataManager: Error loading user settings: \(error). Returning default settings."
            )
            return UserSettings()  // Return default on error
        }
    }
}

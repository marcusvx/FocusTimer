import Foundation

struct UserSettings: Codable {
    var workDurationMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var soundEnabled: Bool = true
}

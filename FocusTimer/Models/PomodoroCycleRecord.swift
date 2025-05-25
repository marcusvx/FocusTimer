import Foundation

struct PomodoroCycleRecord: Codable, Identifiable {
    let id: UUID  // Primary key for the cycle
    var startTime: Date
    var configuredDuration: TimeInterval
    var actualDuration: TimeInterval?
    var endTime: Date?
    var type: PomodoroCycleType
    var wasCompleted: Bool
    var appActivities: [AppActivityLog]  // Apps logged during this cycle

    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        configuredDuration: TimeInterval,
        type: PomodoroCycleType,
        appActivities: [AppActivityLog] = [],
        wasCompleted: Bool = false,
        endTime: Date? = nil,
        actualDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.configuredDuration = configuredDuration
        self.type = type
        self.appActivities = appActivities
        self.wasCompleted = wasCompleted
        self.endTime = endTime
        self.actualDuration = actualDuration
    }
}

import Foundation

struct WorkSessionRecord: Codable, Identifiable {
    let id: UUID
    var sessionStartTime: Date
    var sessionEndTime: Date?
    var pomodoroCycles: [PomodoroCycleRecord]

    init(sessionStartTime: Date = Date()) {
        self.id = UUID()
        self.sessionStartTime = sessionStartTime
        self.pomodoroCycles = []
    }
}

import Combine
import Foundation
import UserNotifications

enum PomodoroState {
    case idle, working, shortBreak, longBreak
}

class PomodoroEngine: ObservableObject {
    var delegate: PomodoroEngineDelegate?

    @Published var currentState: PomodoroState = .idle
    @Published var timeRemaining: TimeInterval = 0
    @Published var timeRemainingFormatted: String = "00:00"
    @Published var completedPomodoros: Int = 0
    @Published var currentCycleConfiguredDuration: TimeInterval = 25 * 60

    var workDuration: TimeInterval = 25 * 60 {
        didSet {
            if currentState == .idle || currentState == .working {
                currentCycleConfiguredDuration = workDuration
            }
        }
    }
    var shortBreakDuration: TimeInterval = 5 * 60 {
        didSet {
            if currentState == .shortBreak {
                currentCycleConfiguredDuration = shortBreakDuration
            }
        }
    }
    var longBreakDuration: TimeInterval = 15 * 60 {
        didSet {
            if currentState == .longBreak {
                currentCycleConfiguredDuration = longBreakDuration
            }
        }
    }
    var pomodorosBeforeLongBreak = 4

    private var timer: Timer?
    private var targetTime: Date?

    init() {
        self.timeRemaining = workDuration
        self.currentCycleConfiguredDuration = workDuration
        updateFormattedTime(from: workDuration)
    }

    private func updateFormattedTime(from interval: TimeInterval) {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        self.timeRemainingFormatted = String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }

    func startWorkSession() {
        completedPomodoros = 0
        startNextPomodoroCycle()
    }

    func startNextPomodoroCycle() {
        let previousWorkState = (currentState == .working)

        if previousWorkState {
            completedPomodoros += 1
            delegate?.pomodoroDidCompleteCycle()
            if completedPomodoros % pomodorosBeforeLongBreak == 0
                && completedPomodoros > 0
            {
                startTimer(duration: longBreakDuration, state: .longBreak)
            } else {
                startTimer(duration: shortBreakDuration, state: .shortBreak)
            }
        } else {
            startTimer(duration: workDuration, state: .working)
        }
    }

    private func startTimer(duration: TimeInterval, state: PomodoroState) {
        timer?.invalidate()
        currentState = state
        currentCycleConfiguredDuration = duration
        timeRemaining = duration  // This will publish change
        updateFormattedTime(from: duration)
        targetTime = Date().addingTimeInterval(duration)

        if state == .working {
            delegate?.pomodoroWorkIntervalDidStart()
        } else {
            delegate?.pomodoroWorkIntervalDidEnd()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let targetTime = targetTime, currentState != .idle else { return }
        let remaining = max(0, targetTime.timeIntervalSinceNow)
        self.timeRemaining = remaining
        updateFormattedTime(from: remaining)

        if remaining <= 0 {
            timer?.invalidate()
            timer = nil

            let previousState = currentState
            startNextPomodoroCycle()

            if previousState == .working {
                let nextBreakType =
                    (completedPomodoros % pomodorosBeforeLongBreak == 0
                        && completedPomodoros > 0) ? "long" : "short"
                sendNotification(
                    title: "Work Interval Complete!",
                    body: "Time for a \(nextBreakType) break."
                )
            } else if previousState == .shortBreak
                || previousState == .longBreak
            {
                sendNotification(
                    title: "Break Over!",
                    body: "Time to get back to work."
                )
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        let oldState = currentState
        currentState = .idle
        timeRemaining = workDuration
        updateFormattedTime(from: workDuration)

        if oldState == .working {
            delegate?.pomodoroWorkIntervalDidEnd()
        }
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "Error sending notification: \(error.localizedDescription)"
                )
            }
        }
    }
}

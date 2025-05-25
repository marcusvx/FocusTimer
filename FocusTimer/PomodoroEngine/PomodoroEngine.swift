import Foundation
import UserNotifications

enum PomodoroState {
    case idle, working, shortBreak, longBreak
}

class PomodoroEngine {
    weak var delegate: PomodoroEngineDelegate?

    var workDuration: TimeInterval = 25 * 60  // 25 minutes
    var shortBreakDuration: TimeInterval = 5 * 60
    var longBreakDuration: TimeInterval = 15 * 60
    var pomodorosBeforeLongBreak = 4

    private(set) var currentState: PomodoroState = .idle {
        didSet { delegate?.pomodoroStateDidChange(to: currentState) }
    }
    private(set) var completedPomodoros = 0
    private var timer: Timer?
    private var targetTime: Date?
    private var timeRemainingWhenPaused: TimeInterval?

    func startWorkSession() {
        // Main session tracking can start here
        startNextPomodoroCycle()
    }

    func startNextPomodoroCycle() {
        let previousWorkState = (currentState == .working)

        if previousWorkState {
            completedPomodoros += 1
            delegate?.pomodoroDidCompleteCycle()
            if completedPomodoros % pomodorosBeforeLongBreak == 0 {
                startTimer(duration: longBreakDuration, state: .longBreak)
            } else {
                startTimer(duration: shortBreakDuration, state: .shortBreak)
            }
        } else {  // Was idle or a break, now start work
            startTimer(duration: workDuration, state: .working)
        }
    }

    private func startTimer(duration: TimeInterval, state: PomodoroState) {
        timer?.invalidate()
        currentState = state  // State changes here
        targetTime = Date().addingTimeInterval(duration)
        timeRemainingWhenPaused = nil

        if state == .working {
            delegate?.pomodoroWorkIntervalDidStart()  // For app logging
        } else {
            // If transitioning *from* working to break, pomodoroWorkIntervalDidEnd
            // would have been called by tick(). If starting directly into a break (e.g. manual start break),
            // ensure app logging is off.
            delegate?.pomodoroWorkIntervalDidEnd()
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            self?.tick()
        }
        tick()  // Update UI immediately
    }

    func pause() {
        guard timer != nil, let target = targetTime else { return }
        timeRemainingWhenPaused = target.timeIntervalSinceNow
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard let remaining = timeRemainingWhenPaused, currentState != .idle
        else { return }
        startTimer(duration: remaining, state: currentState)  // State is already set
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default  // Uses the default notification sound

        // Create the request with a unique identifier
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )  // nil trigger means deliver immediately

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "Error sending notification: \(error.localizedDescription)"
                )
            }
        }
    }

    private func tick() {
        guard let targetTime = targetTime, currentState != .idle else { return }
        let remaining = targetTime.timeIntervalSinceNow
        delegate?.pomodoroTimerDidUpdate(timeRemaining: max(0, remaining))

        if remaining <= 0 {
            timer?.invalidate()
            timer = nil

            let previousState = currentState  // Capture state before it changes

            // Transition to the next state
            startNextPomodoroCycle()  // This will change currentState and start a new timer

            // Send notification based on the state that just ENDED
            if previousState == .working {
                let nextBreakType =
                    (completedPomodoros % pomodorosBeforeLongBreak == 0
                        && completedPomodoros > 0) ? "long" : "short"
                sendNotification(
                    title: "Work Interval Complete!",
                    body: "Time for a \(nextBreakType) break."
                )
                delegate?.pomodoroWorkIntervalDidEnd()  // Ensure app logging stops
            } else if previousState == .shortBreak
                || previousState == .longBreak
            {
                sendNotification(
                    title: "Break Over!",
                    body: "Time to get back to work."
                )
                // pomodoroWorkIntervalDidStart() will be called by the delegate when the new work state begins
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        currentState = .idle
        completedPomodoros = 0
        delegate?.pomodoroTimerDidUpdate(timeRemaining: 0)  // Reset timer display
        delegate?.pomodoroWorkIntervalDidEnd()
        // Main session tracking can stop here
    }
}

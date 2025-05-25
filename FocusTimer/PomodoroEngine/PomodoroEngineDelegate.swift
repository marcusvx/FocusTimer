import Foundation

protocol PomodoroEngineDelegate: AnyObject {
    func pomodoroStateDidChange(to state: PomodoroState)
    func pomodoroTimerDidUpdate(timeRemaining: TimeInterval)
    func pomodoroDidCompleteCycle()
    func pomodoroWorkIntervalDidStart()
    func pomodoroWorkIntervalDidEnd()
}

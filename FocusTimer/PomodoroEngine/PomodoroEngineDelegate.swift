import Foundation

protocol PomodoroEngineDelegate {
    func pomodoroStateDidChange(to state: PomodoroState)
    func pomodoroDidCompleteCycle()
    func pomodoroWorkIntervalDidStart()
    func pomodoroWorkIntervalDidEnd()
}

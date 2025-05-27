import Foundation

protocol PomodoroEngineDelegate {
    func pomodoroDidCompleteCycle()
    func pomodoroWorkIntervalDidStart()
    func pomodoroWorkIntervalDidEnd()
}

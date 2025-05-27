import SwiftUI

struct ContentView: View {
    @StateObject private var pomodoroEngine = PomodoroEngine()
    @StateObject private var appMonitor = AppActivityMonitor()

    @State private var currentInProgressCycleRecord: PomodoroCycleRecord?

    @State private var statusText: String = "Status: Idle (0 Pomos)"

    var body: some View {
        VStack(spacing: 20) {
            Text(pomodoroEngine.timeRemainingFormatted)
                .font(.system(size: 72, weight: .bold, design: .monospaced))
                .padding()

            Text(statusText)
                .font(.headline)

            Button(action: {
                if pomodoroEngine.currentState == .idle {
                    pomodoroEngine.startWorkSession()
                } else {
                    if pomodoroEngine.currentState == .working {
                        finalizeAndSaveCurrentCycle(wasCompleted: false)  // Mark as not fully completed
                    }
                    pomodoroEngine.stop()
                }
            }) {
                Text(
                    pomodoroEngine.currentState == .idle
                        ? "Start Session" : "Stop Session"
                )
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
            }
            .controlSize(.large)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 250)
        .onAppear {
            setupAppMonitorHandler()
            pomodoroEngine.delegate = self
        }
        .onReceive(pomodoroEngine.$currentState) { newState in
            updateStatusText(for: newState)
            handleStateTransitionForData(
                newState: newState,
                previousState: pomodoroEngine.currentState
            )
        }
        .onReceive(pomodoroEngine.$completedPomodoros) { _ in
            updateStatusText(for: pomodoroEngine.currentState)
        }
    }

    private func setupAppMonitorHandler() {
        appMonitor.logHandler = { [self] appName, timestamp in
            guard var currentRecord = self.currentInProgressCycleRecord,
                pomodoroEngine.currentState == .working
            else {
                return
            }

            let appLog = AppActivityLog(timestamp: timestamp, appName: appName)
            currentRecord.appActivities.append(appLog)
            self.currentInProgressCycleRecord = currentRecord
        }
    }

    private func updateStatusText(for state: PomodoroState) {
        self.statusText =
            "Status: \(state) (\(pomodoroEngine.completedPomodoros) Pomos)"
    }

    private func handleStateTransitionForData(
        newState: PomodoroState,
        previousState: PomodoroState
    ) {
        if newState == .working && (previousState != .working) {
            self.currentInProgressCycleRecord = PomodoroCycleRecord(
                configuredDuration: pomodoroEngine.workDuration,
                type: .work
            )
            print(
                "ContentView: New PomodoroCycleRecord started with ID: \(self.currentInProgressCycleRecord!.id)"
            )
        }

        if previousState == .working && newState != .working {
            finalizeAndSaveCurrentCycle(
                wasCompleted: (newState == .shortBreak
                    || newState == .longBreak)
            )
        }
    }

    private func finalizeAndSaveCurrentCycle(wasCompleted: Bool) {

        if var cycleToSave = self.currentInProgressCycleRecord {
            cycleToSave.endTime = Date()

            cycleToSave.actualDuration = cycleToSave.endTime!.timeIntervalSince(
                cycleToSave.startTime
            )

            cycleToSave.wasCompleted = wasCompleted

            DataManager.shared.savePomodoroCycle(cycleToSave)
            print(
                "ContentView: Saved PomodoroCycleRecord with ID: \(cycleToSave.id) and \(cycleToSave.appActivities.count) app activities."
            )

            self.currentInProgressCycleRecord = nil
        }
    }
}

extension ContentView: PomodoroEngineDelegate {
    func pomodoroDidCompleteCycle() {
        print("ContentView (Delegate): Pomodoro cycle completed!")
    }

    func pomodoroWorkIntervalDidStart() {
        appMonitor.startLogging(interval: 10.0)
        print(
            "ContentView (Delegate): Work interval started, app logging active."
        )
    }

    func pomodoroWorkIntervalDidEnd() {
        appMonitor.stopLogging()
        print(
            "ContentView (Delegate): Work interval ended, app logging stopped."
        )
    }
}
#Preview {
    ContentView()
}

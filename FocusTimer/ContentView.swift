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

            // Optional: Display number of completed Pomodoros
            // Text("Completed Pomodoros: \(pomodoroEngine.completedPomodoros)")
        }
        .padding()
        .frame(minWidth: 300, minHeight: 250)  // Set a reasonable default window size
        .onAppear {
            setupAppMonitorHandler()
            // Set the PomodoroEngine's delegate if you still use it for some actions
            // For UI updates, observing @Published properties is preferred.
            // However, for actions like starting/stopping app logging, the delegate can be useful.
            pomodoroEngine.delegate = self  // ContentView can conform to PomodoroEngineDelegate
        }
        // Use .onReceive to react to changes in pomodoroEngine's @Published properties
        // This is an alternative or supplement to the delegate pattern for UI updates
        .onReceive(pomodoroEngine.$currentState) { newState in
            updateStatusText(for: newState)
            handleStateTransitionForData(
                newState: newState,
                previousState: pomodoroEngine.currentState
            )  // Need to pass previous for comparison
        }
        .onReceive(pomodoroEngine.$completedPomodoros) { _ in
            updateStatusText(for: pomodoroEngine.currentState)
        }
    }

    private func setupAppMonitorHandler() {
        appMonitor.logHandler = { [self] appName, timestamp in  // `self` is fine here as View structs are recreated
            guard var currentRecord = self.currentInProgressCycleRecord,
                pomodoroEngine.currentState == .working
            else {
                // print("AppMonitor: Log received but no active work cycle or not in work state.")
                return
            }

            let appLog = AppActivityLog(timestamp: timestamp, appName: appName)
            currentRecord.appActivities.append(appLog)
            self.currentInProgressCycleRecord = currentRecord  // Update the state
            // print("App log added: \(appName). Total: \(currentRecord.appActivities.count)")
        }
    }

    private func updateStatusText(for state: PomodoroState) {
        self.statusText =
            "Status: \(state) (\(pomodoroEngine.completedPomodoros) Pomos)"
    }

    // This function handles data logic related to state transitions
    private func handleStateTransitionForData(
        newState: PomodoroState,
        previousState: PomodoroState
    ) {
        // Logic when a work interval *starts*
        if newState == .working && (previousState != .working) {
            // Create a new record for this work interval
            self.currentInProgressCycleRecord = PomodoroCycleRecord(
                configuredDuration: pomodoroEngine.workDuration,
                type: .work
            )
            print(
                "ContentView: New PomodoroCycleRecord started with ID: \(self.currentInProgressCycleRecord!.id)"
            )
            // App monitor starting is handled by delegate call pomodoroWorkIntervalDidStart
        }

        // Logic when a work interval *ends* (transitioned from .working to a break or idle)
        if previousState == .working && newState != .working {
            finalizeAndSaveCurrentCycle(
                wasCompleted: (newState == .shortBreak
                    || newState == .longBreak)
            )
        }
    }

    private func finalizeAndSaveCurrentCycle(wasCompleted: Bool) {

        if var cycleToSave = self.currentInProgressCycleRecord {
            cycleToSave.endTime = Date()  // Sets the optional endTime

            // Directly use startTime as it's non-optional.
            // endTime is now guaranteed to be non-nil due to the line above.
            cycleToSave.actualDuration = cycleToSave.endTime!.timeIntervalSince(
                cycleToSave.startTime
            )

            cycleToSave.wasCompleted = wasCompleted  // Assign the determined completion status

            // Important: After modifying cycleToSave (which is a copy because PomodoroCycleRecord is a struct),
            // if you need to reflect these changes back to the @State property before saving,
            // or if DataManager saves this specific instance, ensure it's the updated one.
            // However, typically you'd just save this 'cycleToSave' instance.

            DataManager.shared.savePomodoroCycle(cycleToSave)
            print(
                "ContentView: Saved PomodoroCycleRecord with ID: \(cycleToSave.id) and \(cycleToSave.appActivities.count) app activities."
            )

            self.currentInProgressCycleRecord = nil  // Reset for the next cycle
        }
    }
}

// Make ContentView conform to PomodoroEngineDelegate
extension ContentView: PomodoroEngineDelegate {
    func pomodoroStateDidChange(to state: PomodoroState) {
        // This delegate method is called by engine.
        // UI updates are primarily driven by @Published vars and .onReceive.
        // But we can use this to trigger specific logic if needed,
        // like the handleStateTransitionForData or starting/stopping appMonitor
        // updateStatusText(for: state) // Already handled by .onReceive(pomodoroEngine.$currentState)
    }

    func pomodoroDidCompleteCycle() {
        print("ContentView (Delegate): Pomodoro cycle completed!")
        // UI update for completedPomodoros handled by .onReceive(pomodoroEngine.$completedPomodoros)
    }

    func pomodoroWorkIntervalDidStart() {
        appMonitor.startLogging(interval: 10.0)
        print(
            "ContentView (Delegate): Work interval started, app logging active."
        )
        // Creation of currentInProgressCycleRecord is now handled in handleStateTransitionForData via .onReceive
    }

    func pomodoroWorkIntervalDidEnd() {
        appMonitor.stopLogging()
        print(
            "ContentView (Delegate): Work interval ended, app logging stopped."
        )
        // Saving of currentInProgressCycleRecord is now handled in handleStateTransitionForData via .onReceive
    }
}
#Preview {
    ContentView()
}

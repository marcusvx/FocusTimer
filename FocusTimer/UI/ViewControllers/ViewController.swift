//
//  ViewController.swift
//  FocusTimer
//
//  Created by Marcus Vinicius Ximenes on 23/05/25.
//

import Cocoa

class ViewController: NSViewController, PomodoroEngineDelegate {
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!
    
    private var pomodoroEngine: PomodoroEngine!
    private let appMonitor = AppActivityMonitor()

    override func viewDidLoad() {
        super.viewDidLoad()

        pomodoroEngine = PomodoroEngine()
        pomodoroEngine.delegate = self

        // Setup app monitor log handler (where you save the data)
        appMonitor.logHandler = { [weak self] appName, timestamp in
            // self?.saveAppData(name: appName, timestamp: timestamp)
            print("UI Layer Received Log: \(appName) at \(timestamp)")
        }

        updateUIForState()
    }

    @IBAction func startStopButtonPressed(_ sender: NSButton) {
        if pomodoroEngine.currentState == .idle {
            pomodoroEngine.startWorkSession()  // This will trigger .working state
            startStopButton.title = "Stop Session"
        } else {
            pomodoroEngine.stop()
            startStopButton.title = "Start Session"
        }
    }

    // PomodoroEngineDelegate methods
    func pomodoroStateDidChange(to state: PomodoroState) {
        updateUIForState()
        // Send notifications here based on state transitions
        switch state {
        case .working:
            // sendNotification(title: "Work Time!", body: "Focus...")
            break  // Handled by workIntervalDidStart
        case .shortBreak:
            sendNotification(
                title: "Short Break",
                body: "Time for a quick rest."
            )
        case .longBreak:
            sendNotification(title: "Long Break!", body: "Relax and recharge.")
        default:
            break
        }
    }

    func pomodoroTimerDidUpdate(timeRemaining: TimeInterval) {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        timeLabel.stringValue = String(format: "%02d:%02d", minutes, seconds)
    }

    func pomodoroDidCompleteCycle() {
        // Update UI or log cycle completion
        print("Pomodoro cycle completed!")
    }

    func pomodoroWorkIntervalDidStart() {
        appMonitor.startLogging(interval: 10.0)  // Log every 10 seconds
        sendNotification(title: "Work Time!", body: "Let's get focused!")
        print("Work interval started, app logging active.")
    }

    func pomodoroWorkIntervalDidEnd() {
        appMonitor.stopLogging()
        print("Work interval ended, app logging stopped.")
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    private func updateUIForState() {
        statusLabel.stringValue =
            "Status: \(pomodoroEngine.currentState) (\(pomodoroEngine.completedPomodoros) Pomos)"
        if pomodoroEngine.currentState == .idle {
            timeLabel.stringValue = "00:00"
            startStopButton.title = "Start Session"
        } else {
            startStopButton.title = "Stop Session"
        }
    }

    private func sendNotification(title: String, body: String) {
        // (Implementation from section F)
    }
}

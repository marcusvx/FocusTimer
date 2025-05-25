# FocusTimer for macOS 

> A small macOS utility to help you control working time, stay focused using Pomodoro intervals, and understand your app usage.

---

FocusTimer is designed for individuals who work on their Macs and want to enhance productivity, manage distractions, and maintain a healthy work-life balance through structured work intervals.

## Table of Contents (Optional)

* [Overview](#overview)
* [✨ Features](#-features)
* [📸 Screenshots](#-screenshots)
* [🖥️ Requirements](#️-requirements)
* [🚀 Installation](#-installation)
* [🛠️ How to Use](#️-how-to-use)
* [⚙️ Configuration](#️-configuration)
* [🧑‍💻 For Developers](#-for-developers)
* [🛣️ Roadmap](#️-roadmap)
* [🤝 Contributing](#-contributing)
* [📜 License](#-license)

## Overview

FocusTimer is a native macOS application built with Swift and AppKit that provides a simple yet effective way to manage your work sessions. It combines a Pomodoro timer with active application tracking to give you insights into how you spend your time during focus blocks.

The core idea is to help you break down work into manageable intervals, separated by short breaks, encouraging concentration and preventing burnout.

## ✨ Features

* **Pomodoro Timer**: Customizable work, short break, and long break durations.
* **Session Control**: Manually start and stop overall work tracking.
* **App Usage Tracking**: Monitors the applications you use during your "work" intervals. (Your data stays local!)
* **Notifications**: Get alerted when it's time to switch between work and break periods.
* **Minimalist Design**: Unobtrusive interface that stays out of your way.
* **Local Data Storage**: All your session and app usage data is stored locally on your Mac in JSON format. (Located at `~/Library/Application Support/FocusTimer/data/cycles/`)
* **Native macOS Experience**: Built with Swift and AppKit for optimal performance and system integration.

## 📸 Screenshots

Coming soon

## 🖥️ Requirements

* macOS [Specify minimum version, e.g., macOS 12.0 Monterey] or later.
* [Any other dependencies, though likely none for a self-contained native app]

## 🚀 Installation

### For Users (Release Version)

1.  Go to the [Releases page](https://github.com/your_username/your_repository_name/releases) of this repository.
2.  Download the latest `FocusTimer.dmg` or `FocusTimer.app.zip` file.
3.  If you downloaded a `.dmg`, open it and drag `FocusTimer.app` to your Applications folder.
4.  If you downloaded a `.zip`, unzip it and move `FocusTimer.app` to your Applications folder.
5.  **Important**: The first time you open the app, you might need to right-click (or Control-click) the app icon, select "Open," and then confirm in the dialog box, as the app might not be signed by an identified developer (unless you go through the Apple Developer Program).
6.  **Permissions**: The app will require permission for sending notifications. Please grant this when prompted for the best experience.

### For Developers (Building from Source)

See the [For Developers](#-for-developers) section below.

## 🛠️ How to Use

1.  **Launch FocusTimer.**
2.  **(Optional) Configure Timer Durations**: Access settings (if available in UI, or see [Configuration](#️-configuration) for `preferences.json`). By default, it might use standard Pomodoro timings (e.g., 25 min work, 5 min short break, 15 min long break).
3.  **Start a Pomodoro Session**: Click the "Start" or "Start Pomodoro" button.
    * The timer will begin counting down the first work interval.
    * During work intervals, the app you are actively using will be logged.
4.  **Follow the Prompts**:
    * When a work interval ends, you'll receive a notification to take a break.
    * When a break ends, you'll be notified to start the next work interval.
5.  **Pausing/Stopping**: You can typically pause the current interval or stop the entire Pomodoro session.
6.  **Viewing Data**: Your activity data (Pomodoro cycles and app usage during work) is stored locally. (Currently, you might need to inspect the JSON files directly at `~/Library/Application Support/FocusTimer/data/cycles/`. Future versions might include in-app reporting.)

## ⚙️ Configuration

FocusTimer stores its primary data and potentially its settings locally.

* **Pomodoro Cycles & App Usage**: Stored as individual JSON files in `~/Library/Application Support/FocusTimer/data/cycles/`. Each file `cycle_{UUID}.json` represents one completed Pomodoro cycle, including app activity during work phases.
* **Application Settings**: User-configurable settings (like Pomodoro durations, sound preferences) are managed via a `preferences.json` file located at `~/Library/Application Support/FocusTimer/settings/preferences.json`.
    You can manually edit this JSON file if needed (be cautious with formatting). Example structure:
    ```json
    {
      "workDurationMinutes": 25,
      "shortBreakMinutes": 5,
      "longBreakMinutes": 15,
      "soundEnabled": true
    }
    ```
    The application will use default values if this file is missing or corrupted.

## 🧑‍💻 For Developers

This project is built using Swift and AppKit for macOS.

### Project Structure

The source code is organized into logical groups:
* `App/`: AppDelegate, Assets, Info.plist.
* `Models/`: Swift `struct`s for data representation (e.g., `PomodoroCycleRecord`, `AppActivityLog`).
* `DataManagement/`: `DataManager.swift` for handling local JSON data storage.
* `PomodoroEngine/`: Core logic for the Pomodoro timer states and transitions.
* `AppTracking/`: `AppActivityMonitor.swift` for tracking active applications.
* `UI/`: Storyboards/XIBs, ViewControllers, and any custom views.
* `Utilities/`: Helper functions and extensions.

### Building from Source

1.  **Prerequisites**:
    * macOS [Specify macOS version used for development, e.g., macOS Sonoma 14.x]
    * Xcode [Specify Xcode version, e.g., Xcode 15.x]
    * Swift [Specify Swift version, e.g., Swift 5.9 or later]
2.  **Clone the Repository**:
    ```bash
    git clone [https://github.com/your_username/your_repository_name.git](https://github.com/your_username/your_repository_name.git)
    cd your_repository_name
    ```
3.  **Open in Xcode**:
    Open the `FocusTimer.xcodeproj` file in Xcode.
4.  **Build and Run**:
    Select a target (your Mac) and click the "Run" button (or press `Cmd+R`).

## 🛣️ Roadmap (Future Enhancements)

This is an early version. Potential future features include:

* [ ] In-app settings UI for Pomodoro durations and other preferences.
* [ ] Visual reports/charts for time spent and app usage.
* [ ] Customizable notification sounds.
* [ ] Task list integration for Pomodoro cycles.
* [ ] Optional cloud synchronization for data backup and cross-Mac usage.
* [ ] Menu bar integration for quick access.
* [ ] More detailed app usage statistics (e.g., time per app).

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute, please:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/YourAmazingFeature`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
5.  Push to the branch (`git push origin feature/YourAmazingFeature`).
6.  Open a Pull Request.

Please ensure your code adheres to the existing style and includes tests if applicable.

## 📜 License

This project is licensed under the [MIT License](LICENSE.md).
*(Create a `LICENSE.md` file in your repository with the text of the MIT License or your chosen license.)*

import AppKit
import AppIntents
import Foundation
import WidgetKit

@available(macOS 26.0, *)
enum FlClashControlWidgetStore {
    static var appGroupIdentifier: String {
        Bundle.main.object(forInfoDictionaryKey: "FlClashAppGroupIdentifier")
            as? String ?? "group.com.follow.clash"
    }
    static let pendingActionKey = "macosControlWidget.pendingAction"
    static let silentLaunchKey = "macosControlWidget.silentLaunch"
    static let runningStateKey = "macosControlWidget.running"
    static let profileNameKey = "macosControlWidget.profileName"
    static let profileIdKey = "macosControlWidget.profileId"
    static let hasProfileKey = "macosControlWidget.hasProfile"
    static let pendingFeedbackUntilKey = "macosControlWidget.pendingFeedbackUntil"
    static let requestedRunningKey = "macosControlWidget.requestedRunning"
    static let requestedRunningUntilKey = "macosControlWidget.requestedRunningUntil"
    static let actionNotificationName = "com.follow.clash.controlWidgetAction"
    static var runnerBundleIdentifier: String {
        Bundle.main.object(forInfoDictionaryKey: "FlClashRunnerBundleIdentifier")
            as? String ?? "com.follow.clash"
    }
    static let controlKind = "com.follow.clash.control-widget.v2"
    static let statusWidgetKind = "com.follow.clash.status-widget.v2"

    static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    static var isRunning: Bool {
        defaults?.bool(forKey: runningStateKey) ?? false
    }

    static var profileName: String {
        defaults?.string(forKey: profileNameKey) ?? ""
    }

    static var hasProfile: Bool {
        defaults?.bool(forKey: hasProfileKey) ?? false
    }

    static var pendingFeedbackUntil: TimeInterval {
        defaults?.double(forKey: pendingFeedbackUntilKey) ?? 0
    }

    static var requestedRunning: Bool {
        defaults?.bool(forKey: requestedRunningKey) ?? isRunning
    }

    static var requestedRunningUntil: TimeInterval {
        defaults?.double(forKey: requestedRunningUntilKey) ?? 0
    }

    static func requestAction(_ action: String, optimisticRunning: Bool? = nil) {
        defaults?.set(action, forKey: pendingActionKey)
        defaults?.set(true, forKey: silentLaunchKey)
        let feedbackUntil = Date().addingTimeInterval(6).timeIntervalSince1970
        if let optimisticRunning {
            defaults?.set(optimisticRunning, forKey: runningStateKey)
            defaults?.set(optimisticRunning, forKey: requestedRunningKey)
            defaults?.set(feedbackUntil, forKey: requestedRunningUntilKey)
        } else {
            defaults?.set(feedbackUntil, forKey: pendingFeedbackUntilKey)
        }
        defaults?.synchronize()
        ControlCenter.shared.reloadControls(ofKind: controlKind)
        WidgetCenter.shared.reloadTimelines(ofKind: statusWidgetKind)
        WidgetCenter.shared.reloadAllTimelines()
        NSLog("FlClash Widget requested action=%{public}@", action)
        notifyRunner()
    }

    static func requestRunning(_ running: Bool) {
        requestAction(running ? "start" : "stop", optimisticRunning: running)
    }

    static func requestProfileRefresh() {
        requestAction("refreshProfile")
    }

    static func notifyRunner() {
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name(actionNotificationName),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(actionNotificationName as CFString),
            nil,
            nil,
            true
        )
    }

    static func wakeRunnerAppIfNeeded(for running: Bool) {
        let isRunnerAppRunning = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == runnerBundleIdentifier
        }
        guard !isRunnerAppRunning else {
            return
        }
        let appURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = false
        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration)
    }
}

@available(macOS 26.0, *)
struct SetFlClashRunningIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Set FlClash Connection"
    static var isDiscoverable = false
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "Running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        FlClashControlWidgetStore.requestRunning(value)
        FlClashControlWidgetStore.wakeRunnerAppIfNeeded(for: value)
        return .result()
    }
}

@available(macOS 26.0, *)
struct ToggleFlClashConnectionIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle FlClash Connection"
    static var isDiscoverable = false
    static var openAppWhenRun: Bool { false }

    func perform() async throws -> some IntentResult {
        let running = !FlClashControlWidgetStore.isRunning
        FlClashControlWidgetStore.requestRunning(running)
        FlClashControlWidgetStore.wakeRunnerAppIfNeeded(for: running)
        return .result()
    }
}

@available(macOS 26.0, *)
struct RefreshFlClashProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh FlClash Profile"
    static var isDiscoverable = false
    static var openAppWhenRun: Bool { false }

    func perform() async throws -> some IntentResult {
        FlClashControlWidgetStore.requestProfileRefresh()
        FlClashControlWidgetStore.wakeRunnerAppIfNeeded(for: FlClashControlWidgetStore.isRunning)
        return .result()
    }
}

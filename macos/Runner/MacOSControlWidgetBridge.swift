import Cocoa
import FlutterMacOS
import WidgetKit

final class MacOSControlWidgetBridge: NSObject {
    static let shared = MacOSControlWidgetBridge()

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
    static let controlKind = "com.follow.clash.control-widget.v2"
    static let statusWidgetKind = "com.follow.clash.status-widget.v2"
    static let actionNotificationName = "com.follow.clash.controlWidgetAction"

    private var channel: FlutterMethodChannel?
    private var pendingActionRetryGeneration = 0
    private var windowPresentationRetryGeneration = 0

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: Self.appGroupIdentifier) ?? .standard
    }

    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(Self.actionNotificationName as CFString),
            nil
        )
        schedulePendingActionRetries()
    }

    func configure(binaryMessenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.follow.clash/macos_control_widget",
            binaryMessenger: binaryMessenger
        )
        channel.setMethodCallHandler(handleMethodCall)
        self.channel = channel

        DistributedNotificationCenter.default().removeObserver(self)
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleControlWidgetAction),
            name: Notification.Name(Self.actionNotificationName),
            object: nil
        )
        CFNotificationCenterRemoveObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            CFNotificationName(Self.actionNotificationName as CFString),
            nil
        )
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            Unmanaged.passUnretained(self).toOpaque(),
            { _, observer, _, _, _ in
                guard let observer else {
                    return
                }
                let bridge = Unmanaged<MacOSControlWidgetBridge>
                    .fromOpaque(observer)
                    .takeUnretainedValue()
                DispatchQueue.main.async {
                    bridge.performPendingAction()
                }
            },
            Self.actionNotificationName as CFString,
            nil,
            .deliverImmediately
        )
    }

    private func handleMethodCall(
        call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "getPendingAction":
            result(takePendingAction())
        case "isSilentLaunchRequested":
            result(isSilentLaunchRequested())
        case "allowWindowPresentation":
            allowWindowPresentation()
            result(nil)
        case "setRunningState":
            guard let arguments = call.arguments as? [String: Any],
                  let running = arguments["running"] as? Bool else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "running must be a Boolean",
                    details: nil
                ))
                return
            }
            setRunningState(running)
            result(nil)
        case "setWidgetStatus":
            guard let arguments = call.arguments as? [String: Any],
                  let running = arguments["running"] as? Bool,
                  let profileName = arguments["profileName"] as? String,
                  let hasProfile = arguments["hasProfile"] as? Bool else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "running, profileName, and hasProfile are required",
                    details: nil
                ))
                return
            }
            let profileId = (arguments["profileId"] as? NSNumber)?.int64Value
            setWidgetStatus(
                running: running,
                profileId: profileId,
                profileName: profileName,
                hasProfile: hasProfile
            )
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func takePendingAction() -> String? {
        let action = defaults?.string(forKey: Self.pendingActionKey)
        defaults?.removeObject(forKey: Self.pendingActionKey)
        defaults?.removeObject(forKey: Self.silentLaunchKey)
        defaults?.synchronize()
        return action
    }

    func allowUserRequestedPresentation() {
        defaults?.removeObject(forKey: Self.silentLaunchKey)
        defaults?.synchronize()
        allowWindowPresentation()
    }

    func isSilentLaunchRequested() -> Bool {
        guard defaults?.bool(forKey: Self.silentLaunchKey) == true else {
            return false
        }
        return defaults?.string(forKey: Self.pendingActionKey) != nil
    }

    func hasPendingAction() -> Bool {
        defaults?.string(forKey: Self.pendingActionKey) != nil
    }

    func setRunningState(_ running: Bool) {
        defaults?.set(running, forKey: Self.runningStateKey)
        defaults?.removeObject(forKey: Self.pendingFeedbackUntilKey)
        defaults?.synchronize()
        if #available(macOS 26.0, *) {
            ControlCenter.shared.reloadControls(ofKind: Self.controlKind)
        }
        WidgetCenter.shared.reloadTimelines(ofKind: Self.statusWidgetKind)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func setWidgetStatus(
        running: Bool,
        profileId: Int64?,
        profileName: String,
        hasProfile: Bool
    ) {
        defaults?.set(running, forKey: Self.runningStateKey)
        defaults?.set(profileName, forKey: Self.profileNameKey)
        defaults?.set(hasProfile, forKey: Self.hasProfileKey)
        defaults?.removeObject(forKey: Self.pendingFeedbackUntilKey)
        if let profileId {
            defaults?.set(profileId, forKey: Self.profileIdKey)
        } else {
            defaults?.removeObject(forKey: Self.profileIdKey)
        }
        defaults?.synchronize()
        if #available(macOS 26.0, *) {
            ControlCenter.shared.reloadControls(ofKind: Self.controlKind)
        }
        WidgetCenter.shared.reloadTimelines(ofKind: Self.statusWidgetKind)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func performPendingAction() {
        schedulePendingActionRetries()
    }

    private func schedulePendingActionRetries() {
        guard defaults?.string(forKey: Self.pendingActionKey) != nil else {
            return
        }
        pendingActionRetryGeneration += 1
        let generation = pendingActionRetryGeneration
        retryPendingAction(generation: generation, remainingAttempts: 20)
    }

    private func retryPendingAction(generation: Int, remainingAttempts: Int) {
        guard generation == pendingActionRetryGeneration,
              remainingAttempts > 0,
              defaults?.string(forKey: Self.pendingActionKey) != nil else {
            return
        }
        channel?.invokeMethod("performPendingAction", arguments: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.retryPendingAction(
                generation: generation,
                remainingAttempts: remainingAttempts - 1
            )
        }
    }

    func allowWindowPresentation() {
        NSApp.setActivationPolicy(.regular)
        for window in NSApp.windows {
            (window as? MainFlutterWindow)?.allowPresentation()
        }
    }

    func showWindowFromNative() {
        channel?.invokeMethod("showWindowFromNative", arguments: nil)
    }

    func showApplicationWindow() {
        scheduleWindowPresentationRetries()
    }

    func cancelWindowPresentation() {
        windowPresentationRetryGeneration += 1
    }

    private func scheduleWindowPresentationRetries() {
        windowPresentationRetryGeneration += 1
        let generation = windowPresentationRetryGeneration
        retryWindowPresentation(generation: generation, remainingAttempts: 20)
    }

    private func retryWindowPresentation(generation: Int, remainingAttempts: Int) {
        guard generation == windowPresentationRetryGeneration,
              remainingAttempts > 0 else {
            return
        }
        allowWindowPresentation()
        for window in NSApp.windows {
            if let mainWindow = window as? MainFlutterWindow {
                mainWindow.revealAfterControlWidgetLaunch()
            } else if !window.isVisible {
                window.setIsVisible(true)
            }
            window.alphaValue = 1
            window.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        }
        showWindowFromNative()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.retryWindowPresentation(
                generation: generation,
                remainingAttempts: remainingAttempts - 1
            )
        }
    }

    @objc private func handleControlWidgetAction() {
        performPendingAction()
    }
}

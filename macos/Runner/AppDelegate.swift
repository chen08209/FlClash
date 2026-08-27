import Cocoa
import FlutterMacOS
import window_ext

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationWillFinishLaunching(_ notification: Notification) {
        if MacOSControlWidgetBridge.shared.isSilentLaunchRequested() {
            NSApp.setActivationPolicy(.accessory)
        }
        super.applicationWillFinishLaunching(notification)
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        MacOSControlWidgetBridge.shared.cancelWindowPresentation()
        WindowExtPlugin.instance?.handleShouldTerminate()
        return .terminateCancel
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
      return true
    }
    
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        let shouldStayHidden = MacOSControlWidgetBridge.shared.isSilentLaunchRequested()
            || MacOSControlWidgetBridge.shared.hasPendingAction()
        MacOSControlWidgetBridge.shared.performPendingAction()
        if !shouldStayHidden {
            MacOSControlWidgetBridge.shared.allowUserRequestedPresentation()
            MacOSControlWidgetBridge.shared.showApplicationWindow()
        }
        return true
    }

    override func application(_ application: NSApplication, open urls: [URL]) {
        if urls.contains(where: isOpenApplicationURL) {
            MacOSControlWidgetBridge.shared.allowUserRequestedPresentation()
            MacOSControlWidgetBridge.shared.performPendingAction()
            MacOSControlWidgetBridge.shared.showApplicationWindow()
            return
        }
        let shouldStayHidden = MacOSControlWidgetBridge.shared.isSilentLaunchRequested()
            || MacOSControlWidgetBridge.shared.hasPendingAction()
        MacOSControlWidgetBridge.shared.performPendingAction()
        if !shouldStayHidden {
            MacOSControlWidgetBridge.shared.allowUserRequestedPresentation()
            MacOSControlWidgetBridge.shared.showApplicationWindow()
        }
    }

    private func isOpenApplicationURL(_ url: URL) -> Bool {
        url.scheme == "flclash" && (url.host == "open" || url.path == "/open")
    }
}

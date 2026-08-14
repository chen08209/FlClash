import Cocoa
import FlutterMacOS
import window_ext

@main
class AppDelegate: FlutterAppDelegate {
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        WindowExtPlugin.instance?.handleShouldTerminate()
        // terminateCancel aborts system logout/shutdown as well, so ask the
        // system to wait for the app's own exit sequence instead. That
        // sequence normally ends in exit(0); reply anyway after a grace
        // period so a missing Dart handler cannot leave the app hanging.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            NSApp.reply(toApplicationShouldTerminate: true)
        }
        return .terminateLater
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
      return true
    }
    
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in NSApp.windows {
                if !window.isVisible {
                    window.setIsVisible(true)
                }
                window.makeKeyAndOrderFront(self)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        return true
    }
}

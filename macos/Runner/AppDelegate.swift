import Cocoa
import FlutterMacOS
import window

@main
class AppDelegate: FlutterAppDelegate {
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        WindowPlugin.instance?.handleShouldTerminate()
        return .terminateCancel
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
      return true
    }
    
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WindowPlugin.instance?.handleReopen()
        return false
    }
}

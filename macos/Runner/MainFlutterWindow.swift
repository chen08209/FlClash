import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    private var hiddenAtLaunch = false

    override func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        super.awakeFromNib()
    }
    override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
        super.order(place, relativeTo: otherWin)
        // Only the first order hides the window, which Dart shows once it is configured.
        if !hiddenAtLaunch {
            hiddenAtLaunch = true
            setIsVisible(false)
        }
    }
}

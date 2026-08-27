import Cocoa
import FlutterMacOS
import window_manager
import LaunchAtLogin

class MainFlutterWindow: NSWindow {
    private var hideForControlWidgetLaunch = false

    private var shouldHideForControlWidgetLaunch: Bool {
        hideForControlWidgetLaunch
    }

    override func awakeFromNib() {
        hideForControlWidgetLaunch = MacOSControlWidgetBridge.shared.isSilentLaunchRequested()
        if shouldHideForControlWidgetLaunch {
            alphaValue = 0
            ignoresMouseEvents = true
        }

        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        FlutterMethodChannel(
            name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
        )
        .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "launchAtStartupIsEnabled":
                result(LaunchAtLogin.isEnabled)
            case "launchAtStartupSetEnabled":
                if let arguments = call.arguments as? [String: Any] {
                    LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        MacOSControlWidgetBridge.shared.configure(
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )
        super.awakeFromNib()
    }

    func allowPresentation() {
        hideForControlWidgetLaunch = false
        alphaValue = 1
        ignoresMouseEvents = false
    }

    func revealAfterControlWidgetLaunch() {
        allowPresentation()
        setIsVisible(true)
    }

    override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
        if place != .out && shouldHideForControlWidgetLaunch {
            alphaValue = 0
            super.order(place, relativeTo: otherWin)
            hiddenWindowAtLaunch()
            return
        }
        if place != .out {
            alphaValue = 1
        }
        super.order(place, relativeTo: otherWin)
        hiddenWindowAtLaunch()
    }
}

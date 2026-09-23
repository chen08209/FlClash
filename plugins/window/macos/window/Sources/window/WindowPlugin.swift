import Cocoa
import FlutterMacOS

struct PluginError: Error {
    let code: String
    let message: String?
}

public extension NSWindow {
    private static var hiddenAtLaunchKey = false

    // MainFlutterWindow.order(_:relativeTo:) calls this on every order call;
    // only the first one should hide the still-being-configured window.
    private var hiddenAtLaunchConfigured: Bool {
        get { objc_getAssociatedObject(self, &Self.hiddenAtLaunchKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Self.hiddenAtLaunchKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func hiddenWindowAtLaunch() {
        if !hiddenAtLaunchConfigured {
            setIsVisible(false)
            hiddenAtLaunchConfigured = true
        }
    }
}

public class WindowPlugin: NSObject, FlutterPlugin {
    public static var instance: WindowPlugin?

    private var channel: FlutterMethodChannel?
    private var registrar: FlutterPluginRegistrar?
    private let controller = WindowController()
    private lazy var handlers: [String: (Arguments) throws -> Any?] = makeHandlers()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window", binaryMessenger: registrar.messenger)
        let plugin = WindowPlugin()
        plugin.registrar = registrar
        plugin.channel = channel
        WindowPlugin.instance = plugin
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    public override init() {
        super.init()
        controller.onEvent = { [weak self] name in
            self?.emit(name)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = Arguments((call.arguments as? [String: Any]) ?? [:])
        guard let handler = handlers[call.method] else {
            result(FlutterMethodNotImplemented)
            return
        }
        do {
            result(try handler(arguments))
        } catch let error as ArgumentError {
            result(FlutterError(code: "bad_args", message: "\(call.method): \(error.key)", details: nil))
        } catch let error as PluginError {
            result(FlutterError(code: error.code, message: error.message, details: nil))
        } catch {
            result(FlutterError(code: "unsupported", message: "\(error)", details: nil))
        }
    }

    /// Forwarded from `applicationShouldTerminate` so Dart can run shutdown work first.
    public func handleShouldTerminate() {
        emit("should-terminate")
    }

    /// Forwarded from `applicationShouldHandleReopen` (Dock reopen / second launch).
    public func handleReopen() {
        emit("activate")
    }

    private func emit(_ name: String) {
        channel?.invokeMethod("onEvent", arguments: ["name": name])
    }

    private func makeHandlers() -> [String: (Arguments) throws -> Any?] {
        let controller = self.controller

        var handlers: [String: (Arguments) throws -> Any?] = [
            "show": { args in try controller.show(inactive: args.bool("inactive")); return nil },
            "hide": { _ in try controller.hide(); return nil },
            "isVisible": { _ in try controller.isVisible() },
            "focus": { _ in try controller.focus(); return nil },
            "close": { _ in try controller.close(); return nil },
            "setPreventClose": { args in try controller.setPreventClose(args.bool("value")); return nil },
            "isMaximized": { _ in try controller.isMaximized() },
            "maximize": { _ in try controller.maximize(); return nil },
            "unmaximize": { _ in try controller.unmaximize(); return nil },
            "isMinimized": { _ in try controller.isMinimized() },
            "minimize": { _ in try controller.minimize(); return nil },
            "restore": { _ in try controller.restore(); return nil },
            "isFullScreen": { _ in try controller.isFullScreen() },
            "setFullScreen": { args in try controller.setFullScreen(args.bool("value")); return nil },
            "getBounds": { _ in try controller.getBounds() },
            "setBounds": { args in
                try controller.setBounds(
                    x: args.optionalDouble("x"),
                    y: args.optionalDouble("y"),
                    width: args.optionalDouble("width"),
                    height: args.optionalDouble("height")
                )
                return nil
            },
            "isPositionSupported": { _ in try controller.isPositionSupported() },
            "setMinimumSize": { args in
                try controller.setMinimumSize(width: args.double("width"), height: args.double("height"))
                return nil
            },
            "isAlwaysOnTop": { _ in try controller.isAlwaysOnTop() },
            "setAlwaysOnTop": { args in try controller.setAlwaysOnTop(args.bool("value")); return nil },
            "setTitleBarStyle": { args in
                try controller.setTitleBarStyle(
                    style: args.string("style"),
                    windowButtonVisibility: args.bool("windowButtonVisibility")
                )
                return nil
            },
            "setSkipTaskbar": { args in try controller.setSkipTaskbar(args.bool("value")); return nil },
            "setRoundedCorners": { args in
                try controller.setRoundedCorners(args.bool("value"))
                return nil
            },
            "isEffectSupported": { args in
                guard let effect = WindowEffect(rawValue: try args.string("effect")) else {
                    throw ArgumentError(key: "effect")
                }
                return try controller.isEffectSupported(effect)
            },
            "setEffect": { args in
                guard let effect = WindowEffect(rawValue: try args.string("effect")) else {
                    throw ArgumentError(key: "effect")
                }
                guard WindowEffectView.isSupported(effect) else {
                    throw PluginError(code: "unsupported", message: "effect \(effect.rawValue) is not supported")
                }
                let tint = try args.optionalInt("tint")
                let appearance = try WindowEffectView.appearance(brightness: try args.optionalString("brightness"))
                try controller.setEffect(effect, tint: tint.map { NSColor(argb: $0) }, appearance: appearance)
                return nil
            },
            "startDragging": { _ in try controller.startDragging(); return nil }
        ]

        handlers["ensureInitialized"] = { [weak self] _ in
            guard let self, let window = self.registrar?.view?.window else {
                throw PluginError(code: "not_initialized", message: "no window for the Flutter view")
            }
            controller.ensureInitialized(with: window)
            return nil
        }

        return handlers
    }
}

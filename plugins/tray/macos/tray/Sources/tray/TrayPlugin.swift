import Cocoa
import FlutterMacOS

public class TrayPlugin: NSObject, FlutterPlugin, NSMenuDelegate {
    private var channel: FlutterMethodChannel!
    private var statusItem: TrayStatusItem?
    private var menu: TrayMenu?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "tray", binaryMessenger: registrar.messenger)
        let instance = TrayPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            result(show(call.arguments as? [String: Any]))
        case "setTitle":
            result(setTitle(call.arguments as? [String: Any]))
        case "hide":
            hide()
            result(true)
        case "openMenu":
            result(openMenu())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func show(_ arguments: [String: Any]?) -> Bool {
        guard let arguments = arguments else {
            return false
        }

        guard let item = statusItem ?? makeStatusItem() else {
            return false
        }

        if let icon = arguments["icon"] as? [String: Any] {
            guard let image = makeImage(icon) else {
                return false
            }
            item.setImage(image, position: icon["position"] as? String ?? "leading")
        }

        item.setToolTip(arguments["toolTip"] as? String ?? "")
        item.setTitle(arguments["title"] as? String ?? "")

        if let items = arguments["menu"] as? [[String: Any]] {
            let built = TrayMenu(items: items) { [weak self] id in
                self?.channel.invokeMethod("onMenuItemSelected", arguments: ["id": id])
            }
            built.delegate = self
            menu = built
        }

        return true
    }

    private func setTitle(_ arguments: [String: Any]?) -> Bool {
        guard let statusItem = statusItem else {
            return false
        }
        statusItem.setTitle(arguments?["title"] as? String ?? "")
        return true
    }

    private func hide() {
        statusItem?.remove()
        statusItem = nil
        menu = nil
    }

    private func openMenu() -> Bool {
        guard let statusItem = statusItem, let menu = menu else {
            return false
        }
        statusItem.openMenu(menu)
        return true
    }

    private func makeStatusItem() -> TrayStatusItem? {
        guard let item = TrayStatusItem(
            onActivate: { [weak self] in
                self?.channel.invokeMethod("onIconActivated", arguments: nil)
            },
            onMenuRequested: { [weak self] in
                self?.channel.invokeMethod("onMenuRequested", arguments: nil)
            }
        ) else {
            return nil
        }
        statusItem = item
        return item
    }

    private func makeImage(_ icon: [String: Any]) -> NSImage? {
        guard let encoded = icon["bytes"] as? String,
              let data = Data(base64Encoded: encoded, options: .ignoreUnknownCharacters),
              let image = NSImage(data: data) else {
            return nil
        }
        let size = icon["size"] as? Int ?? 18
        image.size = NSSize(width: size, height: size)
        image.isTemplate = icon["isTemplate"] as? Bool ?? false
        return image
    }

    public func menuDidClose(_ menu: NSMenu) {
        statusItem?.closeMenu()
    }
}

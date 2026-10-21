import Cocoa
import FlutterMacOS

enum WindowEffect: String {
    case none
    case transparent
    case blur
    case acrylic
    case mica
    case glass
}

@available(macOS 26.0, *)
private enum SidebarGlass {
    // A split view's sidebar glass is a private variant that NSGlassEffectView's
    // public styles lack and each macOS release redraws, so it is copied off one.
    private static let sidebarAttributes: [String: Any]? = {
        let split = NSSplitViewController()
        let sidebar = NSViewController(nibName: nil, bundle: nil)
        sidebar.view = NSView()
        let content = NSViewController(nibName: nil, bundle: nil)
        content.view = NSView()
        split.addSplitViewItem(NSSplitViewItem(sidebarWithViewController: sidebar))
        split.addSplitViewItem(NSSplitViewItem(viewController: content))
        split.view.frame = NSRect(x: 0, y: 0, width: 600, height: 400)
        split.view.layoutSubtreeIfNeeded()
        guard let glass = firstGlass(in: split.view) else {
            return nil
        }
        var attributes: [String: Any] = [:]
        for key in ["_variant", "_adaptiveAppearance"]
        where glass.responds(to: NSSelectorFromString(key)) {
            attributes[key] = glass.value(forKey: key)
        }
        return attributes
    }()

    static var isAvailable: Bool {
        sidebarAttributes != nil
    }

    static func make() -> NSGlassEffectView {
        let glass = NSGlassEffectView()
        for (key, value) in sidebarAttributes ?? [:]
        where glass.responds(to: NSSelectorFromString("set\(key):")) {
            glass.setValue(value, forKey: key)
        }
        return glass
    }

    private static func firstGlass(in view: NSView) -> NSGlassEffectView? {
        if let glass = view as? NSGlassEffectView {
            return glass
        }
        for subview in view.subviews {
            if let glass = firstGlass(in: subview) {
                return glass
            }
        }
        return nil
    }
}

private final class EffectHostViewController: NSViewController {
    let flutterViewController: FlutterViewController
    let effectView = NSVisualEffectView()
    private var glassView: NSView?

    init(hosting flutterViewController: FlutterViewController) {
        self.flutterViewController = flutterViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        effectView.frame = flutterViewController.view.frame
        effectView.autoresizingMask = [.width, .height]
        effectView.blendingMode = .behindWindow
        addChild(flutterViewController)
        attachFlutterView()
        view = effectView
    }

    func attachFlutterView() {
        let flutterView = flutterViewController.view
        guard flutterView.superview !== effectView else {
            return
        }
        flutterView.translatesAutoresizingMaskIntoConstraints = true
        flutterView.frame = effectView.bounds
        flutterView.autoresizingMask = [.width, .height]
        effectView.addSubview(flutterView)
    }

    @available(macOS 26.0, *)
    func showGlass(tint: NSColor?) {
        let glass: NSGlassEffectView
        if let existing = glassView as? NSGlassEffectView {
            glass = existing
        } else {
            glass = SidebarGlass.make()
            glass.frame = effectView.bounds
            glass.autoresizingMask = [.width, .height]
            effectView.addSubview(glass)
            glass.contentView = flutterViewController.view
            glassView = glass
        }
        glass.tintColor = tint
    }

    func removeGlass() {
        guard let glassView else {
            return
        }
        attachFlutterView()
        glassView.removeFromSuperview()
        self.glassView = nil
    }
}

enum WindowEffectView {
    static func isSupported(_ effect: WindowEffect) -> Bool {
        switch effect {
        case .none, .transparent, .blur, .acrylic:
            return true
        case .mica:
            return false
        case .glass:
            if #available(macOS 26.0, *) {
                return SidebarGlass.isAvailable
            }
            return false
        }
    }

    static func appearance(brightness: String?) throws -> NSAppearance? {
        switch brightness {
        case nil:
            return nil
        case "light":
            return NSAppearance(named: .aqua)
        case "dark":
            return NSAppearance(named: .darkAqua)
        default:
            throw ArgumentError(key: "brightness")
        }
    }

    static func install(in window: NSWindow) {
        guard let flutterViewController = window.contentViewController as? FlutterViewController else {
            return
        }
        let frame = window.frame
        let host = EffectHostViewController(hosting: flutterViewController)
        window.contentViewController = host
        // macOS 12 detaches the outgoing controller's view only after loading the
        // host, by then from the effect view, which leaves the window blank.
        host.attachFlutterView()
        window.setFrame(frame, display: true)
    }

    static func apply(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?, to window: NSWindow) {
        guard let host = window.contentViewController as? EffectHostViewController else {
            return
        }
        let effectView = host.effectView
        switch effect {
        case .none, .transparent, .mica, .glass:
            effectView.maskImage = NSImage()
            effectView.state = .inactive
            host.flutterViewController.backgroundColor = effect == .none ? .windowBackgroundColor : .clear
            if effect == .glass, #available(macOS 26.0, *) {
                host.showGlass(tint: tint)
            } else {
                host.removeGlass()
            }
        case .blur, .acrylic:
            host.removeGlass()
            effectView.maskImage = nil
            effectView.material = effect == .blur ? .sidebar : .fullScreenUI
            effectView.state = .followsWindowActiveState
            effectView.appearance = appearance
            applyTint(tint, to: effectView)
            host.flutterViewController.backgroundColor = .clear
        }
    }

    private static func applyTint(_ tint: NSColor?, to effectView: NSVisualEffectView) {
        guard let tint else {
            effectView.layer?.backgroundColor = nil
            return
        }
        // NSVisualEffectView paints the system material itself, so a translucent
        // layer color is the only way to tint it without replacing the material.
        effectView.wantsLayer = true
        effectView.layer?.backgroundColor = tint.cgColor
    }
}

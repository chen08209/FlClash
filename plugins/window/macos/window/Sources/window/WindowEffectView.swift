import Cocoa
import FlutterMacOS

enum WindowEffect: String {
    case none
    case transparent
    case blur
    case acrylic
    case mica
}

private final class EffectHostViewController: NSViewController {
    let flutterViewController: FlutterViewController
    let effectView = NSVisualEffectView()

    init(hosting flutterViewController: FlutterViewController) {
        self.flutterViewController = flutterViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        let flutterView = flutterViewController.view
        effectView.frame = flutterView.frame
        effectView.autoresizingMask = [.width, .height]
        effectView.blendingMode = .behindWindow
        flutterView.frame = effectView.bounds
        flutterView.autoresizingMask = [.width, .height]
        addChild(flutterViewController)
        effectView.addSubview(flutterView)
        view = effectView
    }
}

enum WindowEffectView {
    static func isSupported(_ effect: WindowEffect) -> Bool {
        effect != .mica
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
        window.contentViewController = EffectHostViewController(hosting: flutterViewController)
        window.setFrame(frame, display: true)
    }

    static func apply(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?, to window: NSWindow) {
        guard let host = window.contentViewController as? EffectHostViewController else {
            return
        }
        let effectView = host.effectView
        switch effect {
        case .none, .transparent, .mica:
            effectView.maskImage = NSImage()
            effectView.state = .inactive
            host.flutterViewController.backgroundColor = effect == .none ? .windowBackgroundColor : .clear
        case .blur, .acrylic:
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

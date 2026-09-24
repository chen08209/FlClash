import Cocoa

enum TitleBarStyle {
    case normal
    case hidden
}

extension NSColor {
    convenience init(argb: Int) {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255
        let red = CGFloat((argb >> 16) & 0xFF) / 255
        let green = CGFloat((argb >> 8) & 0xFF) / 255
        let blue = CGFloat(argb & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct WindowStyle {
    var titleBarStyle: TitleBarStyle = .normal
    var windowButtonVisibility = true
    var effect: WindowEffect = .none
    var effectTint: NSColor?
    var effectAppearance: NSAppearance?

    func apply(to window: NSWindow) {
        switch titleBarStyle {
        case .hidden:
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
        case .normal:
            window.titleVisibility = .visible
            window.titlebarAppearsTransparent = false
            window.styleMask.remove(.fullSizeContentView)
        }

        window.standardWindowButton(.closeButton)?.isHidden = !windowButtonVisibility
        window.standardWindowButton(.miniaturizeButton)?.isHidden = !windowButtonVisibility
        window.standardWindowButton(.zoomButton)?.isHidden = !windowButtonVisibility

        switch effect {
        case .none:
            window.isOpaque = true
            window.backgroundColor = .windowBackgroundColor
        case .transparent, .blur, .acrylic, .mica:
            window.isOpaque = false
            window.backgroundColor = .clear
        }
        window.hasShadow = true

        WindowEffectView.apply(effect, tint: effectTint, appearance: effectAppearance, to: window)
    }
}

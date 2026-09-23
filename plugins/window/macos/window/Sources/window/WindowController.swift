import Cocoa

final class WindowController: NSObject, NSWindowDelegate {
    var onEvent: ((String) -> Void)?

    private var window: NSWindow?
    private weak var previousDelegate: NSWindowDelegate?
    private var preventClose = false
    private var style = WindowStyle()
    private var wasZoomed = false
    private var geometrySettle: DispatchWorkItem?

    private static let geometrySettleDelay: DispatchTimeInterval = .milliseconds(150)

    func ensureInitialized(with window: NSWindow) {
        guard self.window !== window else { return }
        self.window = window
        previousDelegate = window.delegate
        window.delegate = self
        wasZoomed = window.isZoomed
        WindowEffectView.install(in: window)
    }

    private func requireWindow() throws -> NSWindow {
        guard let window else {
            throw PluginError(code: "not_initialized", message: "ensureInitialized has not run")
        }
        return window
    }

    func show(inactive: Bool) throws {
        let window = try requireWindow()
        let wasVisible = window.isVisible
        if inactive {
            window.orderFront(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        if !wasVisible && window.isVisible {
            emit("show")
        }
    }

    func hide() throws {
        let window = try requireWindow()
        let wasVisible = window.isVisible
        window.orderOut(nil)
        if wasVisible && !window.isVisible {
            emit("hide")
        }
    }

    func isVisible() throws -> Bool {
        try requireWindow().isVisible
    }

    func focus() throws {
        let window = try requireWindow()
        NSApp.activate(ignoringOtherApps: false)
        window.makeKeyAndOrderFront(nil)
    }

    func close() throws {
        try requireWindow().performClose(nil)
    }

    func setPreventClose(_ value: Bool) throws {
        _ = try requireWindow()
        preventClose = value
    }

    func isMaximized() throws -> Bool {
        try requireWindow().isZoomed
    }

    func maximize() throws {
        let window = try requireWindow()
        if !window.isZoomed {
            window.zoom(nil)
        }
    }

    func unmaximize() throws {
        let window = try requireWindow()
        if window.isZoomed {
            window.zoom(nil)
        }
    }

    func isMinimized() throws -> Bool {
        try requireWindow().isMiniaturized
    }

    func minimize() throws {
        try requireWindow().miniaturize(nil)
    }

    func restore() throws {
        try requireWindow().deminiaturize(nil)
    }

    func isFullScreen() throws -> Bool {
        try requireWindow().styleMask.contains(.fullScreen)
    }

    func setFullScreen(_ value: Bool) throws {
        let window = try requireWindow()
        if window.styleMask.contains(.fullScreen) != value {
            window.toggleFullScreen(nil)
        }
    }

    private var primaryScreenHeight: CGFloat {
        NSScreen.screens.first?.frame.height ?? 0
    }

    private func topLeft(of frame: NSRect) -> CGPoint {
        CGPoint(x: frame.origin.x, y: primaryScreenHeight - frame.origin.y - frame.size.height)
    }

    func getBounds() throws -> [String: Double] {
        let frame = try requireWindow().frame
        let point = topLeft(of: frame)
        return [
            "x": Double(point.x),
            "y": Double(point.y),
            "width": Double(frame.size.width),
            "height": Double(frame.size.height)
        ]
    }

    func setBounds(x: Double?, y: Double?, width: Double?, height: Double?) throws {
        let window = try requireWindow()
        var frame = window.frame
        if let width, let height {
            // The frame origin is bottom-left, so keep the top edge fixed when
            // only the size changes.
            frame.origin.y += frame.size.height - CGFloat(height)
            frame.size.width = CGFloat(width)
            frame.size.height = CGFloat(height)
        }
        if let x, let y {
            frame.origin = CGPoint(x: CGFloat(x), y: primaryScreenHeight - CGFloat(y) - frame.size.height)
        }
        window.setFrame(frame, display: true)
    }

    func isPositionSupported() throws -> Bool {
        _ = try requireWindow()
        return true
    }

    func setMinimumSize(width: Double, height: Double) throws {
        let window = try requireWindow()
        window.minSize = NSSize(width: width, height: height)
    }

    func isAlwaysOnTop() throws -> Bool {
        try requireWindow().level == .floating
    }

    func setAlwaysOnTop(_ value: Bool) throws {
        let window = try requireWindow()
        window.level = value ? .floating : .normal
    }

    func setTitleBarStyle(style styleName: String, windowButtonVisibility: Bool) throws {
        let window = try requireWindow()
        style.titleBarStyle = styleName == "hidden" ? .hidden : .normal
        style.windowButtonVisibility = windowButtonVisibility
        style.apply(to: window)
    }

    func setSkipTaskbar(_ value: Bool) throws {
        _ = try requireWindow()
        NSApplication.shared.setActivationPolicy(value ? .accessory : .regular)
    }

    func setRoundedCorners(_ value: Bool) throws {
        _ = try requireWindow()
    }

    func isEffectSupported(_ effect: WindowEffect) throws -> Bool {
        _ = try requireWindow()
        return WindowEffectView.isSupported(effect)
    }

    func setEffect(_ effect: WindowEffect, tint: NSColor?, appearance: NSAppearance?) throws {
        let window = try requireWindow()
        style.effect = effect
        style.effectTint = tint
        style.effectAppearance = appearance
        style.apply(to: window)
    }

    func startDragging() throws {
        let window = try requireWindow()
        guard let event = window.currentEvent else {
            return
        }
        // Deferred so the drag starts after the channel call that triggered it
        // returns; performDrag ignores the event otherwise.
        DispatchQueue.main.async {
            window.performDrag(with: event)
        }
    }

    private func scheduleGeometryChanged() {
        geometrySettle?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.geometrySettle = nil
            self?.emit("geometry-changed")
        }
        geometrySettle = work
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.geometrySettleDelay, execute: work)
    }

    // MARK: - NSWindowDelegate

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        emit("close")
        if preventClose {
            return false
        }
        if let previousDelegate, previousDelegate.responds(to: #selector(NSWindowDelegate.windowShouldClose(_:))) {
            return previousDelegate.windowShouldClose?(sender) ?? true
        }
        return true
    }

    func windowDidResize(_ notification: Notification) {
        scheduleGeometryChanged()
        guard let window else { return }
        // AppKit has no maximize/unmaximize delegate call of its own; infer the
        // transition from the isZoomed change a resize produced.
        let isZoomed = window.isZoomed
        if isZoomed != wasZoomed {
            wasZoomed = isZoomed
            emit(isZoomed ? "maximize" : "unmaximize")
        }
    }

    func windowDidMove(_ notification: Notification) {
        scheduleGeometryChanged()
    }

    func windowDidBecomeMain(_ notification: Notification) {
        emit("focus")
    }

    func windowDidResignMain(_ notification: Notification) {
        emit("blur")
    }

    func windowDidMiniaturize(_ notification: Notification) {
        emit("minimize")
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        emit("restore")
    }

    func windowDidEnterFullScreen(_ notification: Notification) {
        emit("enter-full-screen")
    }

    func windowDidExitFullScreen(_ notification: Notification) {
        emit("leave-full-screen")
    }

    private func emit(_ name: String) {
        onEvent?(name)
    }
}

import AppKit

// A native item leaves a fixed gap before its submenu arrow and draws every
// title in one color, so rows are drawn here to keep a detail next to the
// arrow and let it carry its own color. The metrics copy the native menu so
// these rows line up with the separators the menu still draws.
final class TrayMenuItemView: NSView {
    struct Content {
        let label: String
        let detail: String?
        let detailColor: NSColor?
        let checked: Bool
        let enabled: Bool
        let hasSubmenu: Bool

        // A colored detail is a measurement; a plain one reads like a key equivalent.
        var detailFont: NSFont {
            detailColor == nil ? TrayMenuItemView.metrics.font : TrayMenuItemView.valueFont
        }
    }

    private struct Metrics {
        let height: CGFloat
        let stateX: CGFloat
        let titleX: CGFloat
        let trailing: CGFloat
        let highlightInset: CGFloat
        let highlightRadius: CGFloat
        let font: NSFont

        static let current: Metrics = {
            if #available(macOS 26, *) {
                return Metrics(
                    height: 24,
                    stateX: 12,
                    titleX: 30,
                    trailing: 23,
                    highlightInset: 5,
                    highlightRadius: 8,
                    font: .menuFont(ofSize: 13)
                )
            }
            return Metrics(
                height: 22,
                stateX: 9,
                titleX: 21,
                trailing: 14,
                highlightInset: 5,
                highlightRadius: 4,
                font: .menuFont(ofSize: 0)
            )
        }()
    }

    private static let metrics = Metrics.current
    private static let detailGap: CGFloat = 20
    private static let arrowGap: CGFloat = 6

    private static let valueFont = NSFont.monospacedDigitSystemFont(
        ofSize: metrics.font.pointSize - 1,
        weight: .regular
    )

    private static let checkmark = symbol("checkmark", weight: .medium)
    private static let arrow = symbol("chevron.right", weight: .semibold)

    private let content: Content

    init(content: Content) {
        self.content = content
        let metrics = TrayMenuItemView.metrics
        var width = metrics.titleX + TrayMenuItemView.width(content.label) + metrics.trailing
        if let detail = content.detail {
            width += TrayMenuItemView.detailGap + TrayMenuItemView.width(detail, font: content.detailFont)
        }
        if content.hasSubmenu {
            width += TrayMenuItemView.arrowGap + TrayMenuItemView.arrow.size.width
        }
        super.init(frame: NSRect(x: 0, y: 0, width: ceil(width), height: metrics.height))
        autoresizingMask = [.width]
        setAccessibilityElement(true)
        setAccessibilityRole(.menuItem)
        setAccessibilityLabel([content.label, content.detail].compactMap { $0 }.joined(separator: ", "))
        setAccessibilityEnabled(content.enabled)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        true
    }

    private var isHighlighted: Bool {
        content.enabled && enclosingMenuItem?.isHighlighted == true
    }

    override func draw(_ dirtyRect: NSRect) {
        let metrics = TrayMenuItemView.metrics
        let highlighted = isHighlighted
        if highlighted {
            NSColor.controlAccentColor.setFill()
            NSBezierPath(
                roundedRect: bounds.insetBy(dx: metrics.highlightInset, dy: 0),
                xRadius: metrics.highlightRadius,
                yRadius: metrics.highlightRadius
            ).fill()
        }

        let primary: NSColor = highlighted
            ? .selectedMenuItemTextColor
            : content.enabled ? .labelColor : .tertiaryLabelColor
        if content.checked {
            drawSymbol(TrayMenuItemView.checkmark, x: metrics.stateX, color: primary)
        }

        var trailingX = bounds.width - metrics.trailing
        if content.hasSubmenu {
            let arrowWidth = TrayMenuItemView.arrow.size.width
            drawSymbol(TrayMenuItemView.arrow, x: trailingX - arrowWidth, color: primary)
            trailingX -= arrowWidth + TrayMenuItemView.arrowGap
        }

        if let detail = content.detail {
            let color: NSColor = highlighted
                ? .selectedMenuItemTextColor
                : content.enabled ? content.detailColor ?? .secondaryLabelColor : .tertiaryLabelColor
            let font = content.detailFont
            let detailWidth = TrayMenuItemView.width(detail, font: font)
            drawText(detail, x: trailingX - detailWidth, width: detailWidth, color: color, font: font)
            trailingX -= detailWidth + TrayMenuItemView.detailGap
        }

        drawText(content.label, x: metrics.titleX, width: trailingX - metrics.titleX, color: primary, font: metrics.font)
    }

    override func mouseUp(with event: NSEvent) {
        guard content.enabled, !content.hasSubmenu, let item = enclosingMenuItem,
              let action = item.action else {
            return
        }
        var root = item.menu
        while let parent = root?.supermenu {
            root = parent
        }
        root?.cancelTracking()
        NSApp.sendAction(action, to: item.target, from: item)
    }

    private func drawText(_ text: String, x: CGFloat, width: CGFloat, color: NSColor, font: NSFont) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        let height = ceil(font.ascender - font.descender)
        let rect = NSRect(x: x, y: (bounds.height - height) / 2, width: max(width, 0), height: height)
        (text as NSString).draw(
            with: rect,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: [.font: font, .foregroundColor: color, .paragraphStyle: style]
        )
    }

    private func drawSymbol(_ image: NSImage, x: CGFloat, color: NSColor) {
        let size = image.size
        let rect = NSRect(
            x: x,
            y: ((bounds.height - size.height) / 2).rounded(),
            width: size.width,
            height: size.height
        )
        let tinted = NSImage(size: size, flipped: false) { bounds in
            image.draw(in: bounds)
            color.setFill()
            bounds.fill(using: .sourceAtop)
            return true
        }
        tinted.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
    }

    private static func width(_ text: String, font: NSFont = metrics.font) -> CGFloat {
        ceil((text as NSString).size(withAttributes: [.font: font]).width)
    }

    private static func symbol(_ name: String, weight: NSFont.Weight) -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: metrics.font.pointSize, weight: weight)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(configuration) ?? NSImage()
    }
}

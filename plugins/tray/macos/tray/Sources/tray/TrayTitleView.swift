import AppKit

final class TrayTitleView: NSView {
    static let width: CGFloat = 42

    private static let font = NSFont.systemFont(ofSize: 8.75)
    private static let lineHeight: CGFloat = 9

    private var lines: [NSAttributedString] = [] {
        didSet { needsDisplay = true }
    }

    private var titleWidth: CGFloat = TrayTitleView.width

    private let attributes: [NSAttributedString.Key: Any] = [
        .font: TrayTitleView.font,
        .foregroundColor: NSColor.labelColor,
    ]

    override var isFlipped: Bool {
        true
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: titleWidth, height: NSView.noIntrinsicMetric)
    }

    func setTitle(_ title: String) -> Bool {
        let wasHidden = isHidden
        let previousWidth = titleWidth

        lines = title.isEmpty
            ? []
            : title.components(separatedBy: "\n").map {
                NSAttributedString(string: $0, attributes: attributes)
            }
        let textWidth = lines.map { ceil($0.size().width) }.max() ?? 0
        titleWidth = max(TrayTitleView.width, textWidth)
        isHidden = title.isEmpty

        let widthChanged = titleWidth != previousWidth
        if widthChanged {
            invalidateIntrinsicContentSize()
        }
        return wasHidden != isHidden || widthChanged
    }

    // Line boxes carry descender space, so centring them leaves the digits high.
    override func draw(_ dirtyRect: NSRect) {
        guard !lines.isEmpty else {
            return
        }
        let capHeight = TrayTitleView.font.capHeight
        let lineHeight = TrayTitleView.lineHeight
        let blockHeight = capHeight + lineHeight * CGFloat(lines.count - 1)
        let scale = window?.backingScaleFactor ?? 2
        var baseline = ((bounds.height - blockHeight) / 2 + capHeight) * scale
        baseline = baseline.rounded() / scale
        for line in lines {
            let width = line.size().width
            line.draw(
                with: NSRect(x: bounds.width - width, y: baseline, width: width, height: 0),
                options: []
            )
            baseline += lineHeight
        }
    }
}

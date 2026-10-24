import AppKit

final class TrayTitleView: NSImageView {
    static let width: CGFloat = 42

    private static let font = NSFont.systemFont(ofSize: 8.75)
    private static let lineHeight: CGFloat = 9

    private var titleWidth: CGFloat = TrayTitleView.width

    private let attributes: [NSAttributedString.Key: Any] = [
        .font: TrayTitleView.font,
        .foregroundColor: NSColor.black,
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

        let lines = title.isEmpty
            ? []
            : title.components(separatedBy: "\n").map {
                NSAttributedString(string: $0, attributes: attributes)
            }
        let textWidth = lines.map { ceil($0.size().width) }.max() ?? 0
        titleWidth = max(TrayTitleView.width, textWidth)
        isHidden = title.isEmpty
        imageScaling = .scaleNone
        image = lines.isEmpty ? nil : makeImage(lines)

        let widthChanged = titleWidth != previousWidth
        if widthChanged {
            invalidateIntrinsicContentSize()
        }
        return wasHidden != isHidden || widthChanged
    }

    private func makeImage(_ lines: [NSAttributedString]) -> NSImage {
        let capHeight = TrayTitleView.font.capHeight
        let lineHeight = TrayTitleView.lineHeight
        let blockHeight = capHeight + lineHeight * CGFloat(lines.count - 1)
        let size = NSSize(
            width: titleWidth,
            height: ceil(TrayTitleView.font.ascender - TrayTitleView.font.descender)
                + lineHeight * CGFloat(lines.count - 1)
        )
        let image = NSImage(size: size, flipped: true) { bounds in
            let scale = abs(NSGraphicsContext.current?.cgContext.ctm.d ?? 2)
            // Line boxes carry descender space, so centring them leaves the digits high.
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
            return true
        }
        image.isTemplate = true
        return image
    }
}

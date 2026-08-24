import AppKit

final class TrayTitleView: NSView {
    static let width: CGFloat = 42

    private var attributedTitle: NSAttributedString? {
        didSet { needsDisplay = true }
    }

    private var titleWidth: CGFloat = TrayTitleView.width

    private let attributes: [NSAttributedString.Key: Any] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = 9
        paragraphStyle.minimumLineHeight = 9
        paragraphStyle.alignment = .right
        paragraphStyle.lineBreakMode = .byClipping
        return [
            .paragraphStyle: paragraphStyle,
            .font: NSFont.systemFont(ofSize: 8.75),
            .foregroundColor: NSColor.labelColor,
        ]
    }()

    override var isFlipped: Bool {
        true
    }

    override var intrinsicContentSize: NSSize {
        NSSize(width: titleWidth, height: NSView.noIntrinsicMetric)
    }

    func setTitle(_ title: String) -> Bool {
        let wasHidden = isHidden
        let previousWidth = titleWidth

        if title.isEmpty {
            attributedTitle = nil
            titleWidth = TrayTitleView.width
        } else {
            let text = NSAttributedString(string: title, attributes: attributes)
            attributedTitle = text
            titleWidth = max(TrayTitleView.width, ceil(measure(text).width))
        }
        isHidden = title.isEmpty

        let widthChanged = titleWidth != previousWidth
        if widthChanged {
            invalidateIntrinsicContentSize()
        }
        return wasHidden != isHidden || widthChanged
    }

    private func measure(_ text: NSAttributedString) -> NSSize {
        text.boundingRect(
            with: NSSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: CGFloat.greatestFiniteMagnitude
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        ).size
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let attributedTitle = attributedTitle else {
            return
        }
        let textBounds = attributedTitle.boundingRect(
            with: NSSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        let y = max((bounds.height - textBounds.height) / 2, 0)
        attributedTitle.draw(
            in: NSRect(x: 0, y: y, width: bounds.width, height: ceil(textBounds.height))
        )
    }
}

import AppKit

final class TrayMenu: NSMenu {
    private static let detailGap: CGFloat = 24

    private let onSelect: (Int) -> Void

    init(items: [[String: Any]], onSelect: @escaping (Int) -> Void) {
        self.onSelect = onSelect
        super.init(title: "")
        autoenablesItems = false
        let detailTab = TrayMenu.detailTab(for: items)
        for entry in items {
            addItem(makeItem(entry, detailTab: detailTab))
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func detail(_ entry: [String: Any]) -> String? {
        guard let detail = entry["detail"] as? String, !detail.isEmpty else {
            return nil
        }
        return detail
    }

    private static func width(_ text: String) -> CGFloat {
        ceil((text as NSString).size(withAttributes: [.font: NSFont.menuFont(ofSize: 0)]).width)
    }

    // One right-aligned tab stop per menu keeps every detail in a single column.
    private static func detailTab(for items: [[String: Any]]) -> CGFloat {
        var labelWidth: CGFloat = 0
        var detailWidth: CGFloat = 0
        for entry in items {
            guard let detail = detail(entry) else {
                continue
            }
            labelWidth = max(labelWidth, width(entry["label"] as? String ?? ""))
            detailWidth = max(detailWidth, width(detail))
        }
        return labelWidth + detailGap + detailWidth
    }

    private func makeItem(_ entry: [String: Any], detailTab: CGFloat) -> NSMenuItem {
        let type = entry["type"] as? String ?? ""
        if type == "separator" {
            return NSMenuItem.separator()
        }

        let item = NSMenuItem()
        let label = entry["label"] as? String ?? ""
        item.title = label
        if let detail = TrayMenu.detail(entry) {
            item.attributedTitle = TrayMenu.titleWithDetail(label, detail, tab: detailTab)
        }
        item.tag = entry["id"] as? Int ?? 0
        item.isEnabled = entry["enabled"] as? Bool ?? true

        switch type {
        case "checkbox":
            item.state = (entry["checked"] as? Bool ?? false) ? .on : .off
            item.target = self
            item.action = #selector(didSelectItem(_:))
        case "submenu":
            let children = entry["items"] as? [[String: Any]] ?? []
            setSubmenu(TrayMenu(items: children, onSelect: onSelect), for: item)
        default:
            item.target = self
            item.action = #selector(didSelectItem(_:))
        }

        return item
    }

    // The label keeps no explicit color so the menu still dims it when disabled.
    // tertiaryLabelColor matches a native key equivalent and turns white on highlight.
    private static func titleWithDetail(
        _ label: String,
        _ detail: String,
        tab: CGFloat
    ) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.tabStops = [NSTextTab(textAlignment: .right, location: tab)]
        let font = NSFont.menuFont(ofSize: 0)
        let title = NSMutableAttributedString(
            string: label,
            attributes: [.font: font, .paragraphStyle: style]
        )
        title.append(NSAttributedString(
            string: "\t" + detail,
            attributes: [
                .font: font,
                .paragraphStyle: style,
                .foregroundColor: NSColor.tertiaryLabelColor,
            ]
        ))
        return title
    }

    @objc private func didSelectItem(_ sender: NSMenuItem) {
        onSelect(sender.tag)
    }
}

import AppKit

final class TrayMenu: NSMenu, NSMenuDelegate {
    private let onSelect: (Int) -> Void
    private let onClose: (() -> Void)?
    private var contents: [TrayMenuItemView.Content?] = []

    init(items: [[String: Any]], onSelect: @escaping (Int) -> Void, onClose: (() -> Void)? = nil) {
        self.onSelect = onSelect
        self.onClose = onClose
        super.init(title: "")
        autoenablesItems = false
        delegate = self
        for entry in items {
            let item = makeItem(entry)
            addItem(item)
            contents.append(item.isSeparatorItem ? nil : TrayMenu.content(entry, item))
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

    private static func detailColor(_ entry: [String: Any]) -> NSColor? {
        switch entry["detailTone"] as? String {
        case "success":
            return .systemGreen
        case "warning":
            return .systemOrange
        case "error":
            return .systemRed
        default:
            return nil
        }
    }

    private func makeItem(_ entry: [String: Any]) -> NSMenuItem {
        let type = entry["type"] as? String ?? ""
        if type == "separator" {
            return NSMenuItem.separator()
        }

        let item = NSMenuItem()
        item.title = entry["label"] as? String ?? ""
        item.tag = entry["id"] as? Int ?? 0
        item.isEnabled = entry["enabled"] as? Bool ?? true
        item.state = type == "checkbox" && entry["checked"] as? Bool == true ? .on : .off

        if type == "submenu" {
            let children = entry["items"] as? [[String: Any]] ?? []
            setSubmenu(TrayMenu(items: children, onSelect: onSelect), for: item)
        } else {
            item.target = self
            item.action = #selector(didSelectItem(_:))
        }
        return item
    }

    private static func content(_ entry: [String: Any], _ item: NSMenuItem) -> TrayMenuItemView.Content {
        TrayMenuItemView.Content(
            label: item.title,
            detail: detail(entry),
            detailColor: detailColor(entry),
            checked: item.state == .on,
            enabled: item.isEnabled,
            hasSubmenu: item.hasSubmenu
        )
    }

    // A delay test rebuilds the menu per result; measuring every row then costs ~20x.
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard !contents.isEmpty else {
            return
        }
        for (item, content) in zip(items, contents) {
            if let content = content {
                item.view = TrayMenuItemView(content: content)
            }
        }
        contents = []
    }

    // AppKit does not redraw an item's view when its highlight changes.
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        highlightedItem?.view?.needsDisplay = true
        item?.view?.needsDisplay = true
    }

    func menuDidClose(_ menu: NSMenu) {
        onClose?()
    }

    @objc private func didSelectItem(_ sender: NSMenuItem) {
        onSelect(sender.tag)
    }
}

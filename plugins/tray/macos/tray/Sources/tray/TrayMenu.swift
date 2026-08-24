import AppKit

final class TrayMenu: NSMenu {
    private let onSelect: (Int) -> Void

    init(items: [[String: Any]], onSelect: @escaping (Int) -> Void) {
        self.onSelect = onSelect
        super.init(title: "")
        autoenablesItems = false
        for entry in items {
            addItem(makeItem(entry))
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    @objc private func didSelectItem(_ sender: NSMenuItem) {
        onSelect(sender.tag)
    }
}

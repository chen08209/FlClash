import 'dart:convert';

import '../rust/api/tray.dart';
import 'tray_menu.dart';
import 'tray_spec.dart';

final class EncodedTray {
  const EncodedTray({
    required this.menu,
    required this.itemsById,
    required this.signature,
  });

  final List<TrayItem> menu;
  final Map<int, TrayMenuItem> itemsById;
  final String signature;
}

abstract final class TrayCodec {
  static const int firstItemId = 1024;

  static EncodedTray encode(TraySpec spec) {
    final itemsById = <int, TrayMenuItem>{};
    final menu = _encodeItems(spec.menu, itemsById, _IdAllocator());
    return EncodedTray(
      menu: menu,
      itemsById: itemsById,
      signature: jsonEncode(<Object?>[
        spec.icon.asset,
        spec.icon.isTemplate,
        spec.icon.size,
        spec.icon.position.name,
        spec.toolTip,
        _describe(menu),
      ]),
    );
  }

  static List<TrayItem> _encodeItems(
    List<TrayMenuItem> items,
    Map<int, TrayMenuItem> sink,
    _IdAllocator allocator,
  ) {
    return items.map((item) {
      final id = allocator.next();
      sink[id] = item;
      return switch (item) {
        TrayMenuSeparator() => TrayItem(
          id: id,
          kind: TrayItemKind.separator,
          label: '',
          enabled: true,
          checked: false,
          items: const [],
        ),
        TrayMenuAction(:final label, :final detail, :final enabled) => TrayItem(
          id: id,
          kind: TrayItemKind.action,
          label: label,
          detail: _detail(detail),
          enabled: enabled,
          checked: false,
          items: const [],
        ),
        TrayMenuCheckbox(
          :final label,
          :final detail,
          :final enabled,
          :final checked,
        ) =>
          TrayItem(
            id: id,
            kind: TrayItemKind.checkbox,
            label: label,
            detail: _detail(detail),
            enabled: enabled,
            checked: checked,
            items: const [],
          ),
        TrayMenuSubmenu(
          :final label,
          :final detail,
          :final enabled,
          :final items,
        ) =>
          TrayItem(
            id: id,
            kind: TrayItemKind.submenu,
            label: label,
            detail: _detail(detail),
            enabled: enabled,
            checked: false,
            items: _encodeItems(items, sink, allocator),
          ),
      };
    }).toList();
  }

  static String? _detail(String? detail) {
    return detail == null || detail.isEmpty ? null : detail;
  }

  static List<Object?> _describe(List<TrayItem> items) {
    return [
      for (final item in items)
        [
          item.id,
          item.kind.name,
          item.label,
          item.detail,
          item.enabled,
          item.checked,
          _describe(item.items),
        ],
    ];
  }
}

final class _IdAllocator {
  int _next = TrayCodec.firstItemId;

  int next() {
    final id = _next;
    _next = _next + 1;
    return id;
  }
}

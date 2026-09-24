import 'dart:convert';

import 'tray_menu.dart';
import 'tray_spec.dart';

final class EncodedTray {
  const EncodedTray({
    required this.icon,
    required this.toolTip,
    required this.menu,
    required this.itemsById,
    required this.signature,
  });

  final Map<String, Object?> icon;
  final String toolTip;
  final List<Object?> menu;
  final Map<int, TrayMenuItem> itemsById;
  final String signature;
}

abstract final class TrayCodec {
  static const int firstItemId = 1024;

  static EncodedTray encode(TraySpec spec) {
    final itemsById = <int, TrayMenuItem>{};
    final menu = _encodeItems(spec.menu, itemsById, _IdAllocator());
    final icon = <String, Object?>{
      'asset': spec.icon.asset,
      'isTemplate': spec.icon.isTemplate,
      'size': spec.icon.size,
      'position': spec.icon.position.name,
    };
    return EncodedTray(
      icon: icon,
      toolTip: spec.toolTip,
      menu: menu,
      itemsById: itemsById,
      signature: jsonEncode(<String, Object?>{
        'icon': icon,
        'toolTip': spec.toolTip,
        'menu': menu,
      }),
    );
  }

  static List<Object?> _encodeItems(
    List<TrayMenuItem> items,
    Map<int, TrayMenuItem> sink,
    _IdAllocator allocator,
  ) {
    return items.map((item) {
      final id = allocator.next();
      sink[id] = item;
      return switch (item) {
        TrayMenuSeparator() => <String, Object?>{'id': id, 'type': 'separator'},
        TrayMenuAction(
          :final label,
          :final detail,
          :final detailTone,
          :final enabled,
        ) =>
          <String, Object?>{
            'id': id,
            'type': 'action',
            'label': label,
            ..._encodeDetail(detail, detailTone),
            'enabled': enabled,
          },
        TrayMenuCheckbox(
          :final label,
          :final detail,
          :final detailTone,
          :final enabled,
          :final checked,
        ) =>
          <String, Object?>{
            'id': id,
            'type': 'checkbox',
            'label': label,
            ..._encodeDetail(detail, detailTone),
            'enabled': enabled,
            'checked': checked,
          },
        TrayMenuSubmenu(
          :final label,
          :final detail,
          :final detailTone,
          :final enabled,
          :final items,
        ) =>
          <String, Object?>{
            'id': id,
            'type': 'submenu',
            'label': label,
            ..._encodeDetail(detail, detailTone),
            'enabled': enabled,
            'items': _encodeItems(items, sink, allocator),
          },
      };
    }).toList();
  }
}

Map<String, Object?> _encodeDetail(String? detail, TrayDetailTone tone) {
  if (detail == null || detail.isEmpty) {
    return const {};
  }
  return <String, Object?>{
    'detail': detail,
    if (tone != TrayDetailTone.plain) 'detailTone': tone.name,
  };
}

final class _IdAllocator {
  int _next = TrayCodec.firstItemId;

  int next() {
    final id = _next;
    _next = _next + 1;
    return id;
  }
}

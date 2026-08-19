import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayManager extends ConsumerStatefulWidget {
  final Widget child;

  const TrayManager({super.key, required this.child});

  @override
  ConsumerState<TrayManager> createState() => _TrayContainerState();
}

class _TrayContainerState extends ConsumerState<TrayManager> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    ref.listenManual(trayStateProvider, (prev, next) {
      if (prev == null || _trayMenuNeedsRebuild(prev, next)) {
        ref.read(systemActionProvider.notifier).updateTray();
      }
    });
    if (system.isMacOS) {
      ref.listenManual(trayTitleStateProvider, (prev, next) {
        if (prev != next) {
          tray?.updateTrayTitle(
            showTrayTitle: next.showTrayTitle,
            traffic: next.traffic,
          );
        }
      });
    }
  }

  /// Ignore delay-sort reorder of the same proxy names; title updates are
  /// handled separately via [trayTitleStateProvider].
  bool _trayMenuNeedsRebuild(TrayState previous, TrayState next) {
    if (previous.mode != next.mode ||
        previous.port != next.port ||
        previous.autoLaunch != next.autoLaunch ||
        previous.systemProxy != next.systemProxy ||
        previous.tunEnable != next.tunEnable ||
        previous.isStart != next.isStart ||
        previous.locale != next.locale ||
        previous.brightness != next.brightness ||
        previous.showTrayTitle != next.showTrayTitle) {
      return true;
    }
    if (!mapEquals(previous.selectedMap, next.selectedMap)) {
      return true;
    }
    return !listEquals(
      _groupMenuSignature(previous.groups),
      _groupMenuSignature(next.groups),
    );
  }

  List<String> _groupMenuSignature(List<Group> groups) {
    return groups
        .map((group) {
          final names = group.all.map((proxy) => proxy.name).toList()..sort();
          return '${group.name}:${names.join(',')}';
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onTrayIconRightMouseDown() {
    // ignore: deprecated_member_use
    trayManager.popUpContextMenu(bringAppToFront: true);
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    render?.active();
    super.onTrayMenuItemClick(menuItem);
  }

  @override
  void onTrayIconMouseDown() {
    window?.show();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }
}

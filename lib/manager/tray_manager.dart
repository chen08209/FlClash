import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tray.dart';
import 'package:fl_clash/common/window.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray/tray.dart';

class TrayManager extends ConsumerStatefulWidget {
  final Widget child;

  const TrayManager({super.key, required this.child});

  @override
  ConsumerState<TrayManager> createState() => _TrayManagerState();
}

class _TrayManagerState extends ConsumerState<TrayManager> {
  StreamSubscription<TrayEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Tray.instance.events.listen(_handleTrayEvent);
    ref.listenManual(trayStateProvider, (prev, next) {
      if (prev == null || _trayMenuNeedsRebuild(prev, next)) {
        _reportFailure(ref.read(systemActionProvider.notifier).updateTray());
      }
    });
    ref.listenManual(loadedLocaleProvider, (prev, next) {
      if (prev != null && prev != next) {
        _reportFailure(ref.read(systemActionProvider.notifier).updateTray());
      }
    });
    if (system.isMacOS) {
      ref.listenManual(trayTitleStateProvider, (prev, next) {
        if (prev != next) {
          _reportFailure(
            appTray?.updateTitle(
              showTrayTitle: next.showTrayTitle,
              traffic: next.traffic,
            ),
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

  void _reportFailure(Future<void>? operation) {
    if (operation == null) {
      return;
    }
    unawaited(
      operation.onError<Object>((error, stackTrace) {
        commonPrint.log(
          'Tray operation failed: ${compactError(error)}',
          logLevel: LogLevel.error,
        );
      }),
    );
  }

  void _handleTrayEvent(TrayEvent event) {
    switch (event) {
      case TrayIconActivated():
        window?.show();
      case TrayMenuRequested():
        _reportFailure(Tray.instance.openMenu());
      case TrayMenuItemSelected():
        render?.active();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

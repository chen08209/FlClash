import 'dart:async';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TileManager extends ConsumerStatefulWidget {
  final Widget child;

  const TileManager({super.key, required this.child});

  @override
  ConsumerState<TileManager> createState() => _TileContainerState();
}

class _TileContainerState extends ConsumerState<TileManager> with TileListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  bool get isStart => ref.read(isStartProvider);

  @override
  Future<void> onStart() async {
    if (isStart && ref.read(coreStatusProvider) == CoreStatus.connected) {
      return;
    }
    unawaited(ref.read(setupActionProvider.notifier).setRunning(true));
    unawaited(app?.tip(currentAppLocalizations.startVpn));
    super.onStart();
  }

  @override
  Future<void> onStop() async {
    if (!isStart) {
      return;
    }
    unawaited(ref.read(setupActionProvider.notifier).setRunning(false));
    unawaited(app?.tip(currentAppLocalizations.stopVpn));
    super.onStop();
  }

  @override
  void initState() {
    super.initState();
    tile?.addListener(this);
  }

  @override
  void dispose() {
    tile?.removeListener(this);
    super.dispose();
  }
}

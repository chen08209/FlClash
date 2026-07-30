import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/core/controller.dart';
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
  Future<bool> onStart() async {
    if (isStart && coreController.isCompleted) {
      return true;
    }
    await ref.read(setupActionProvider.notifier).setRunning(true);
    final started = isStart;
    if (started) {
      app?.tip(currentAppLocalizations.startVpn);
    }
    return started;
  }

  @override
  Future<bool> onStop() async {
    if (!isStart) {
      return false;
    }
    await ref.read(setupActionProvider.notifier).setRunning(false);
    final stopped = !isStart;
    if (stopped) {
      app?.tip(currentAppLocalizations.stopVpn);
    }
    return stopped;
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

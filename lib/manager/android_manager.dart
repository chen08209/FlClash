import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AndroidManager extends ConsumerStatefulWidget {
  final Widget child;

  const AndroidManager({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AndroidManager> createState() => _AndroidContainerState();
}

class _AndroidContainerState extends ConsumerState<AndroidManager> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(appSettingProvider.select((state) => state.hidden),
        (prev, next) {
      app?.updateExcludeFromRecents(next);
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

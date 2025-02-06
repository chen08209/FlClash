import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    ref.listenManual(
      appSettingProvider.select((state) => state.hidden),
      (prev, next) {
        app?.updateExcludeFromRecents(next);
      },
      fireImmediately: true
    );
    ref.listenManual(
      appSettingProvider.select((state) => state.autoLaunch),
      (prev, next) {
        if (prev != next) {
          debouncer.call(
            DebounceTag.autoLaunch,
            () {
              autoLaunch.updateStatus(next);
            },
          );
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

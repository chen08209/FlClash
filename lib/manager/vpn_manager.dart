import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/banner.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(
      vpnOptionsProvider.select((state) => state.value?.effective),
      (prev, next) {
        final running = ref.read(runningVpnOptionsProvider)?.effective;
        if (next != null &&
            prev != next &&
            running != null &&
            running != next) {
          _showRestartTip();
        }
      },
    );
  }

  void _showRestartTip() {
    dialogs.showBanner(
      currentAppLocalizations.vpnConfigChangeDetected,
      level: BannerLevel.warning,
      onTap: () {
        unawaited(ref.read(setupActionProvider.notifier).restartVpn());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

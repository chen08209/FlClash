import 'dart:async';

import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin ProbeStartHold<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // A start's own probes often fail; its config re-apply asks again.
  static const _duration = Duration(seconds: 5);

  Timer? _hold;

  ProbePhase shownPhase(ProbeEntry<Object?> entry) =>
      _hold != null && entry.phase == ProbePhase.failed
      ? ProbePhase.probing
      : entry.phase;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      routeTrackerProvider.select((state) => state.proxied),
      (_, proxied) => _rearm(proxied),
    );
  }

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  void _rearm(bool proxied) {
    _hold?.cancel();
    setState(() {
      _hold = proxied
          ? Timer(_duration, () {
              if (mounted) setState(() => _hold = null);
            })
          : null;
    });
  }
}

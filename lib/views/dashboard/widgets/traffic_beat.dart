import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds a card's update for the Core's next traffic sample, so each second's
/// changes share one frame: Impeller redraws the whole screen for every frame.
mixin TrafficBeatMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  static const _lapse = Duration(milliseconds: 1500);

  var _hasShown = false;
  VoidCallback? _pending;
  Timer? _lapseTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual(trafficsProvider, (_, _) => _showPending());
    ref.listenManual(runTimeProvider.select((runTime) => runTime == null), (
      _,
      stopped,
    ) {
      if (stopped) {
        _showPending();
      }
    });
  }

  void showOnBeat(VoidCallback show) {
    if (!_hasShown || ref.read(runTimeProvider) == null) {
      _show(show);
      return;
    }
    _pending = show;
    _lapseTimer ??= Timer(_lapse, _showPending);
  }

  void _showPending() {
    final show = _pending;
    if (show != null) {
      _show(show);
    }
  }

  void _show(VoidCallback show) {
    _pending = null;
    _lapseTimer?.cancel();
    _lapseTimer = null;
    if (!mounted) {
      return;
    }
    _hasShown = true;
    show();
  }

  @override
  void dispose() {
    _lapseTimer?.cancel();
    super.dispose();
  }
}

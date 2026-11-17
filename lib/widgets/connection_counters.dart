import 'package:fl_clash/core/api/connection_book.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/inherited.dart';

/// Holds the Core's connection counters on while the page this state belongs to
/// is the one in view and [showsConnectionTraffic] is true.
mixin ConnectionCountersMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  CounterDemand? _held;
  bool _pageActive = true;

  bool get showsConnectionTraffic => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageActive =
        PageActivityScope.isActiveOf(context) &&
        TickerMode.valuesOf(context).enabled;
    syncConnectionCounters();
  }

  void syncConnectionCounters() {
    final want = _pageActive && showsConnectionTraffic;
    if (want == (_held != null)) {
      return;
    }
    if (want) {
      _held = ref.read(connectionBookProvider).demand..acquire();
    } else {
      _held?.release();
      _held = null;
    }
  }

  @override
  void dispose() {
    _held?.release();
    _held = null;
    super.dispose();
  }
}

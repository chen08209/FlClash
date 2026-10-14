import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Starts a push transition one frame after the page is first built, so a long
/// first build does not swallow the start of the transition.
mixin DeferredPushRouteMixin<T> on TransitionRoute<T> {
  _TickerCapture? _vsync;

  @override
  AnimationController createAnimationController() {
    final vsync = _vsync = _TickerCapture(navigator!);
    return AnimationController(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      debugLabel: debugLabel,
      vsync: vsync,
    );
  }

  @override
  TickerFuture didPush() {
    final ticker = _vsync?.ticker;
    if (ticker == null || ticker.muted) {
      return super.didPush();
    }
    ticker.muted = true;
    final pushed = super.didPush();
    final context = navigator!.context;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ticker.muted = !TickerMode.getValuesNotifier(context).value.enabled;
    });
    return pushed;
  }
}

class _TickerCapture implements TickerProvider {
  _TickerCapture(this._parent);

  final TickerProvider _parent;
  Ticker? ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return ticker = _parent.createTicker(onTick);
  }
}

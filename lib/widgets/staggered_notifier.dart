import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Tells its listeners of a change [perFrame] at a time, one batch a frame,
/// so a change that rebuilds many rows spreads over a few frames rather than
/// landing in one.
final class StaggeredNotifier implements Listenable {
  final int perFrame;

  StaggeredNotifier({this.perFrame = 4});

  final _listeners = <VoidCallback>{};
  final _pending = <VoidCallback>{};
  var _scheduled = false;
  var _disposed = false;

  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    _pending.remove(listener);
  }

  void notify() {
    _pending.addAll(_listeners);
    _schedule();
  }

  /// Calls [callback] once, in its turn among the listeners told of a change.
  void schedule(VoidCallback callback) {
    _pending.add(callback);
    _schedule();
  }

  void _schedule() {
    if (_scheduled || _pending.isEmpty || _disposed) {
      return;
    }
    _scheduled = true;
    final binding = SchedulerBinding.instance;
    binding.scheduleFrameCallback((_) {
      _scheduled = false;
      _flush();
    });
    binding.ensureVisualUpdate();
  }

  void _flush() {
    for (var told = 0; told < perFrame; told++) {
      if (_disposed || _pending.isEmpty) {
        return;
      }
      final listener = _pending.first;
      _pending.remove(listener);
      try {
        listener();
      } catch (exception, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'widgets library',
            context: ErrorDescription('while notifying $runtimeType listeners'),
          ),
        );
      }
    }
    _schedule();
  }

  void dispose() {
    _disposed = true;
    _listeners.clear();
    _pending.clear();
  }
}

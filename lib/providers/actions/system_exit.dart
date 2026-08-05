import 'dart:async';

typedef ExitStep = Future<void> Function();

final class SystemExitCoordinator {
  final Duration watchdogDuration;
  final ExitStep closeWindow;
  final ExitStep closeCore;
  final ExitStep exitApplication;

  Future<void>? _operation;
  Future<void>? _applicationExitOperation;

  SystemExitCoordinator({
    required this.watchdogDuration,
    required this.closeWindow,
    required this.closeCore,
    required this.exitApplication,
  });

  Future<void> exit({required ExitStep cleanup}) {
    final activeOperation = _operation;
    if (activeOperation != null) {
      return activeOperation;
    }
    final operation = _run(cleanup);
    _operation = operation;
    return operation;
  }

  Future<void> _run(ExitStep cleanup) async {
    Object? firstError;
    StackTrace? firstStackTrace;

    Future<void> runStep(ExitStep step) async {
      try {
        await step();
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;
      }
    }

    final watchdog = Timer(watchdogDuration, () {
      unawaited(_exitApplicationOnce().catchError((_) {}));
    });
    try {
      await runStep(cleanup);
      await runStep(closeWindow);
      await runStep(closeCore);
    } finally {
      watchdog.cancel();
      await runStep(_exitApplicationOnce);
    }
    final error = firstError;
    if (error != null) {
      Error.throwWithStackTrace(error, firstStackTrace!);
    }
  }

  Future<void> _exitApplicationOnce() {
    final activeOperation = _applicationExitOperation;
    if (activeOperation != null) {
      return activeOperation;
    }
    final operation = Future<void>.sync(exitApplication);
    _applicationExitOperation = operation;
    return operation;
  }
}

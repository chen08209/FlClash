import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

import 'helper_client.dart';
import 'model.dart';
import 'process_probe.dart';

typedef CoreProcessStarter =
    Future<Process> Function(String executable, List<String> arguments);

abstract interface class CoreProcessLauncher {
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  });
}

abstract interface class DesktopCoreLauncherResolver {
  Future<CoreProcessLauncher> resolve();
}

final class DirectCoreLauncher implements CoreProcessLauncher {
  final CoreProcessStarter _startProcess;
  final String corePath;

  DirectCoreLauncher({CoreProcessStarter? startProcess, String? corePath})
    : _startProcess = startProcess ?? Process.start,
      corePath = corePath ?? appPath.corePath;

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    final process = await _startProcess(corePath, [address]);
    process.stdout.listen((_) {});
    process.stderr.listen((data) {
      final error = utf8.decode(data);
      if (error.isNotEmpty) {
        commonPrint.log(error, logLevel: LogLevel.warning);
      }
    });
    await _handSessionToken(process, sessionId);
    return DirectCoreLease(sessionId: sessionId, process: process);
  }
}

Future<void> _handSessionToken(Process process, String sessionId) async {
  final stdin = process.stdin;
  unawaited(stdin.done.catchError((Object _) {}));
  try {
    stdin.writeln(sessionId);
    await stdin.close();
  } catch (_) {
    // A Core that exited before reading it is reported by its exit.
  }
}

final class DirectCoreLease implements CoreProcessLease {
  @override
  final String sessionId;

  final Process _process;
  Future<CoreProcessStopResult>? _stopOperation;
  var _stopRequested = false;

  DirectCoreLease({required this.sessionId, required Process process})
    : _process = process {
    unawaited(process.exitCode.then(_onExit));
  }

  void _onExit(int code) {
    if (_stopRequested) {
      return;
    }
    commonPrint.log(
      'Core ${_process.pid} exited on its own with code $code',
      logLevel: LogLevel.warning,
    );
  }

  @override
  CoreProcessOwner get owner => CoreProcessOwner.direct;

  @override
  int get pid => _process.pid;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) {
    _stopRequested = true;
    final stopOperation = _stopOperation;
    if (stopOperation != null) {
      return stopOperation;
    }
    final nextOperation = _stop(timeout).then((result) {
      if (!result.exitConfirmed) {
        _stopOperation = null;
      }
      return result;
    });
    _stopOperation = nextOperation;
    return nextOperation;
  }

  Future<CoreProcessStopResult> _stop(Duration timeout) async {
    final stopped = _process.kill();
    try {
      await _process.exitCode.timeout(timeout);
      return CoreProcessStopResult(stopped: stopped, exitConfirmed: true);
    } on TimeoutException {
      return CoreProcessStopResult(stopped: stopped, exitConfirmed: false);
    }
  }
}

final class HelperLauncher implements CoreProcessLauncher {
  final HelperClient client;
  final ProcessLivenessProbe livenessProbe;

  const HelperLauncher(this.client, {this.livenessProbe = isProcessAlive});

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    try {
      final response = await client.start(
        address: address,
        sessionId: sessionId,
      );
      return HelperCoreLease(
        sessionId: response.sessionId,
        pid: response.pid,
        client: client,
        livenessProbe: livenessProbe,
      );
    } catch (error, stackTrace) {
      try {
        await client.stop(sessionId);
      } catch (releaseError) {
        commonPrint.log(
          'Failed to release the Helper session after a start failure: '
          '${compactError(releaseError)}',
          logLevel: LogLevel.warning,
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

// The Helper reports these codes before it spawns a Core, and /start releases
// the previously managed Core first, so no Helper-managed Core is left behind
// and a direct launch is safe to retry.
const _preSpawnHelperErrors = {'coreVerificationFailed', 'processLaunchFailed'};

final class FallbackCoreLauncher implements CoreProcessLauncher {
  final CoreProcessLauncher primary;
  final CoreProcessLauncher fallback;

  const FallbackCoreLauncher({required this.primary, required this.fallback});

  @override
  Future<CoreProcessLease> start({
    required String sessionId,
    required String address,
  }) async {
    try {
      return await primary.start(sessionId: sessionId, address: address);
    } on HelperException catch (error) {
      if (!_preSpawnHelperErrors.contains(error.code)) rethrow;
      commonPrint.log(
        'Helper could not start the Core ($error); '
        'falling back to direct Core',
        logLevel: LogLevel.warning,
      );
      return fallback.start(sessionId: sessionId, address: address);
    }
  }
}

typedef HelperReadinessProbe = Future<HelperReadiness> Function();

final class HelperLauncherResolver implements DesktopCoreLauncherResolver {
  final bool hasHelper;
  final CoreProcessLauncher directLauncher;
  final CoreProcessLauncher helperLauncher;
  final HelperReadinessProbe helperReady;

  const HelperLauncherResolver({
    required this.hasHelper,
    required this.directLauncher,
    required this.helperLauncher,
    required this.helperReady,
  });

  @override
  Future<CoreProcessLauncher> resolve() async {
    if (!hasHelper) return directLauncher;
    final readiness = await helperReady();
    if (readiness == HelperReadiness.ready) {
      return FallbackCoreLauncher(
        primary: helperLauncher,
        fallback: directLauncher,
      );
    }
    return directLauncher;
  }
}

final class HelperCoreLease implements CoreProcessLease {
  @override
  final String sessionId;

  @override
  final int pid;

  final HelperClient _client;
  final ProcessLivenessProbe _livenessProbe;
  Future<CoreProcessStopResult>? _stopOperation;

  HelperCoreLease({
    required this.sessionId,
    required this.pid,
    required HelperClient client,
    ProcessLivenessProbe livenessProbe = isProcessAlive,
  }) : _client = client,
       _livenessProbe = livenessProbe;

  @override
  CoreProcessOwner get owner => CoreProcessOwner.helper;

  @override
  Future<CoreProcessStopResult> stop(Duration timeout) {
    final stopOperation = _stopOperation;
    if (stopOperation != null) {
      return stopOperation;
    }
    final nextOperation = _stop().onError((
      Object error,
      StackTrace stackTrace,
    ) {
      _stopOperation = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
    _stopOperation = nextOperation;
    return nextOperation;
  }

  // A dead Helper takes its Core with it; the OS is then the only witness.
  Future<CoreProcessStopResult> _stop() async {
    final HelperStopResponse response;
    try {
      response = await _client.stop(sessionId);
    } on HelperException catch (error) {
      if (error.code != 'transportError' || await _livenessProbe(pid)) {
        rethrow;
      }
      commonPrint.log(
        'Helper is unreachable and Core $pid has already exited; '
        'its session is released',
        logLevel: LogLevel.warning,
      );
      return const CoreProcessStopResult(stopped: false, exitConfirmed: true);
    }
    return CoreProcessStopResult(
      stopped: response.stopped,
      exitConfirmed: true,
    );
  }
}

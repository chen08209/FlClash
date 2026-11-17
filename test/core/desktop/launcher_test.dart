import 'dart:async';
import 'dart:io';

import 'package:fl_clash/core/desktop/launcher.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('createCoreSessionId returns lowercase 128-bit hex', () {
    expect(createCoreSessionId(), matches(RegExp(r'^[0-9a-f]{32}$')));
  });

  test('direct lease kills and confirms the owned process exit', () async {
    final process = _FakeProcess(pid: 42, exitCode: Future.value(0));
    String? executable;
    List<String>? arguments;
    final launcher = DirectCoreLauncher(
      startProcess: (value, valueArguments) async {
        executable = value;
        arguments = valueArguments;
        return process;
      },
      corePath: 'FlClashCore',
    );

    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );
    final result = await lease.stop(const Duration(seconds: 1));

    expect(lease.owner, CoreProcessOwner.direct);
    expect(lease.pid, 42);
    expect(executable, 'FlClashCore');
    expect(arguments, ['test-address']);
    expect(process.stdinText, '0123456789abcdef0123456789abcdef\n');
    expect(process.stdinClosed, isTrue);
    expect(process.killed, isTrue);
    expect(
      result,
      const CoreProcessStopResult(stopped: true, exitConfirmed: true),
    );
  });

  test(
    'the session token goes to stdin only, never argv or a log line',
    () async {
      const sessionId = '0123456789abcdef0123456789abcdef';
      final process = _FakeProcess(pid: 42, exitCode: Future.value(0));
      List<String>? arguments;
      final launcher = DirectCoreLauncher(
        startProcess: (_, valueArguments) async {
          arguments = valueArguments;
          return process;
        },
        corePath: 'FlClashCore',
      );

      await launcher.start(sessionId: sessionId, address: 'test-address');

      expect(arguments!.join(' '), isNot(contains(sessionId)));
      expect(process.stdinText, '$sessionId\n');
    },
  );

  test('a Core that closed stdin early does not fail the launch', () async {
    final process = _FakeProcess(pid: 42, exitCode: Future.value(1))
      .._stdin.failOnClose = true;
    final launcher = DirectCoreLauncher(
      startProcess: (_, _) async => process,
      corePath: 'FlClashCore',
    );

    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );

    expect(lease.pid, 42);
  });

  test('direct lease reports an unconfirmed exit after timeout', () async {
    final process = _FakeProcess(pid: 42, exitCode: Completer<int>().future);
    final launcher = DirectCoreLauncher(
      startProcess: (_, _) async => process,
      corePath: 'FlClashCore',
    );
    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );

    final result = await lease.stop(Duration.zero);

    expect(result.stopped, isTrue);
    expect(result.exitConfirmed, isFalse);
  });

  test('direct lease rechecks exit after an unconfirmed timeout', () async {
    final exitCode = Completer<int>();
    final process = _FakeProcess(pid: 42, exitCode: exitCode.future);
    final launcher = DirectCoreLauncher(
      startProcess: (_, _) async => process,
      corePath: 'FlClashCore',
    );
    final lease = await launcher.start(
      sessionId: '0123456789abcdef0123456789abcdef',
      address: 'test-address',
    );

    final firstResult = await lease.stop(Duration.zero);
    exitCode.complete(0);
    final secondResult = await lease.stop(const Duration(seconds: 1));

    expect(firstResult.exitConfirmed, isFalse);
    expect(secondResult.exitConfirmed, isTrue);
  });
}

class _FakeProcess implements Process {
  @override
  final int pid;

  @override
  final Future<int> exitCode;

  @override
  final Stream<List<int>> stdout = const Stream.empty();

  @override
  final Stream<List<int>> stderr = const Stream.empty();

  bool killed = false;

  // ignore: close_sinks
  final _stdin = _RecordingSink();

  @override
  IOSink get stdin => _stdin;

  String get stdinText => _stdin.text;

  bool get stdinClosed => _stdin.closed;

  _FakeProcess({required this.pid, required this.exitCode});

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _RecordingSink implements IOSink {
  final StringBuffer _text = StringBuffer();
  bool closed = false;
  bool failOnClose = false;

  String get text => _text.toString();

  @override
  void writeln([Object? object = '']) => _text.writeln(object);

  @override
  Future<void> close() async {
    if (failOnClose) {
      throw const SocketException('Broken pipe');
    }
    closed = true;
  }

  @override
  Future<void> get done => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

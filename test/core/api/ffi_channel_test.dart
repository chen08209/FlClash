import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_clash/core/api/channels/ffi_channel.dart';
import 'package:fl_clash/core/api/frame_channel.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLibrary implements ConcordLibrary {
  final sent = <(int, List<int>)>[];
  final closed = <int>[];
  final ports = <int, SendPort>{};
  bool ready = true;
  bool refuseOpen = false;
  bool refuseSend = false;
  int initializations = 0;
  int _next = 0;

  @override
  bool initialize() {
    initializations++;
    return ready;
  }

  @override
  int open(SendPort port) {
    if (refuseOpen) {
      return 0;
    }
    ports[++_next] = port;
    return _next;
  }

  @override
  bool send(int session, Uint8List frame) {
    sent.add((session, frame));
    return !refuseSend;
  }

  @override
  void close(int session) => closed.add(session);

  void post(int session, List<int> frame) =>
      ports[session]!.send(Uint8List.fromList(frame));
}

void main() {
  late _FakeLibrary library;
  late List<int> reported;
  late FfiFrameChannel channel;

  setUp(() {
    library = _FakeLibrary();
    reported = [];
    channel = FfiFrameChannel(library: () => library, onSession: reported.add);
  });

  tearDown(() => channel.close());

  test('has no generation until it connects', () async {
    expect(channel.generation, isNull);
    final events = <ChannelEvent>[];
    channel.events.listen(events.add);

    channel.connect();
    await pumpEventQueue();

    expect(channel.generation, 1);
    expect(events.single, isA<ChannelConnected>());
    expect((events.single as ChannelConnected).generation, 1);
    expect(library.initializations, 1);
  });

  test('connecting twice opens one session', () {
    channel.connect();
    channel.connect();

    expect(library.ports, hasLength(1));
    expect(reported, [1]);
  });

  test('frames the Core posts arrive in order', () async {
    final seen = <List<int>>[];
    channel.frames.listen(seen.add);
    channel.connect();

    library.post(1, [1, 2]);
    library.post(1, [3]);
    await pumpEventQueue();

    expect(seen, [
      [1, 2],
      [3],
    ]);
  });

  test('a frame goes to the session it was opened on', () {
    channel.connect();

    channel.send([7, 8, 9]);

    expect(library.sent.single.$1, 1);
    expect(library.sent.single.$2, [7, 8, 9]);
  });

  test('disconnecting closes the session, the port and reports none', () async {
    final events = <ChannelEvent>[];
    channel.events.listen(events.add);
    final seen = <List<int>>[];
    channel.frames.listen(seen.add);
    channel.connect();

    channel.disconnect();
    library.post(1, [1]);
    await pumpEventQueue();

    expect(library.closed, [1]);
    expect(reported, [1, 0]);
    expect(channel.generation, isNull);
    expect(events.last, isA<ChannelDisconnected>());
    expect(seen, isEmpty);
    expect(() => channel.send([1]), throwsStateError);

    channel.disconnect();
    expect(library.closed, [1]);
  });

  test('a new session after a disconnect is a new generation', () async {
    channel.connect();
    channel.disconnect();
    channel.connect();

    expect(channel.generation, 2);
    expect(reported, [1, 0, 2]);
    expect(library.initializations, 1);
  });

  test('a send the Core refuses ends the session with that error', () async {
    final events = <ChannelEvent>[];
    channel.events.listen(events.add);
    channel.connect();
    library.refuseSend = true;

    channel.send([1]);
    await pumpEventQueue();

    expect(channel.generation, isNull);
    expect(library.closed, [1]);
    final ended = events.whereType<ChannelDisconnected>().single;
    expect(ended.error, isA<StateError>());
  });

  test('a Core that refuses a session leaves the channel closed', () {
    library.refuseOpen = true;

    expect(channel.connect, throwsStateError);
    expect(channel.generation, isNull);
    expect(reported, isEmpty);
  });

  test('a Dart API that cannot be linked fails the connect', () {
    library.ready = false;

    expect(channel.connect, throwsStateError);
    expect(library.ports, isEmpty);
  });

  test('waiting resolves once a session is live', () async {
    final waiting = channel.waitUntilConnected(const Duration(seconds: 5));
    channel.connect();

    expect(await waiting, 1);
    expect(await channel.waitUntilConnected(Duration.zero), 1);
  });

  test('waiting times out without a session', () {
    expect(
      channel.waitUntilConnected(const Duration(milliseconds: 20)),
      throwsA(isA<TimeoutException>()),
    );
  });
}

import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingListener with CoreEventListener {
  _RecordingListener({this.onLoadedCallback});

  final void Function()? onLoadedCallback;
  final List<String> loaded = [];
  final List<String> dialerLoops = [];
  final List<Map<String, RequestTraffic>> requestTraffic = [];
  final List<Set<String>> requestsClosed = [];
  final List<TrackerInfo> requests = [];

  @override
  void onLoaded(String providerName) {
    loaded.add(providerName);
    onLoadedCallback?.call();
  }

  @override
  void onDialerLoop(String proxyName) {
    dialerLoops.add(proxyName);
  }

  @override
  void onRequestTraffic(Map<String, RequestTraffic> traffic) {
    requestTraffic.add(traffic);
  }

  @override
  void onRequest(TrackerInfo connection) {
    requests.add(connection);
  }

  @override
  void onRequestsClosed(Set<String> ids) {
    requestsClosed.add(ids);
  }
}

void main() {
  test(
    'a listener may unregister itself while an event is dispatched',
    () async {
      late _RecordingListener first;
      final second = _RecordingListener();
      first = _RecordingListener(
        onLoadedCallback: () => coreEventManager.removeListener(first),
      );

      coreEventManager.addListener(first);
      coreEventManager.addListener(second);
      addTearDown(() {
        coreEventManager.removeListener(first);
        coreEventManager.removeListener(second);
      });

      coreEventManager.sendEvent(
        const CoreEvent(type: CoreEventType.loaded, data: 'provider-a'),
      );
      await pumpEventQueue();

      expect(first.loaded, ['provider-a']);
      expect(second.loaded, ['provider-a']);

      coreEventManager.sendEvent(
        const CoreEvent(type: CoreEventType.loaded, data: 'provider-b'),
      );
      await pumpEventQueue();

      expect(first.loaded, ['provider-a']);
      expect(second.loaded, ['provider-a', 'provider-b']);
    },
  );

  test('a dialer loop the core stopped reaches the listeners', () async {
    final listener = _RecordingListener();
    coreEventManager.addListener(listener);
    addTearDown(() => coreEventManager.removeListener(listener));

    coreEventsFromData({
      'type': 'dialerLoop',
      'data': 'Front',
    }).forEach(coreEventManager.sendEvent);
    await pumpEventQueue();

    expect(listener.dialerLoops, ['Front']);
  });

  test(
    'the traffic and the close of requests reach the listeners by id',
    () async {
      final listener = _RecordingListener();
      coreEventManager.addListener(listener);
      addTearDown(() => coreEventManager.removeListener(listener));

      coreEventsFromData({
        'type': 'requestTraffic',
        'data': [
          {'id': 'a', 'upload': 460, 'download': 257835, 'closed': false},
          {'id': 'b', 'upload': 0, 'download': 12, 'closed': true},
          {'id': 'c', 'upload': 1, 'download': 1},
        ],
      }).forEach(coreEventManager.sendEvent);
      await pumpEventQueue();

      expect(listener.requestTraffic, [
        {
          'a': (upload: 460, download: 257835),
          'b': (upload: 0, download: 12),
          'c': (upload: 1, download: 1),
        },
      ]);
      expect(listener.requestsClosed, [
        {'b'},
      ]);
    },
  );

  test('a connection whose dial failed arrives closed when the Core says, '
      'with why, in one event', () async {
    final listener = _RecordingListener();
    coreEventManager.addListener(listener);
    addTearDown(() => coreEventManager.removeListener(listener));
    Map<String, Object?> failed(String id, String kind) => {
      'id': id,
      'start': '2026-11-21T08:00:00Z',
      'metadata': {'network': 'tcp', 'host': 'example.com'},
      'chains': ['HK-01', 'Proxy'],
      'rule': 'Match',
      'rulePayload': '',
      'closedAt': '2026-11-21T08:00:00Z',
      'failure': {'kind': kind, 'message': 'connect: connection refused'},
    };

    for (final data in [failed('a', 'refused'), failed('b', 'quota')]) {
      coreEventsFromData({
        'type': 'request',
        'data': data,
      }).forEach(coreEventManager.sendEvent);
    }
    await pumpEventQueue();

    expect(
      listener.requests.map((request) => (request.id, request.failure?.kind)),
      [
        ('a', ConnectionFailureKind.refused),
        ('b', ConnectionFailureKind.other),
      ],
    );
    expect(
      listener.requests.first.failure!.message,
      'connect: connection refused',
    );
    expect(
      listener.requests.map((request) => request.closedAt),
      everyElement(DateTime.utc(2026, 11, 21, 8)),
    );
    expect(listener.requestsClosed, isEmpty);
  });
}

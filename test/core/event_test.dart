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

  test('the traffic of requests reaches the listeners by id', () async {
    final listener = _RecordingListener();
    coreEventManager.addListener(listener);
    addTearDown(() => coreEventManager.removeListener(listener));

    coreEventsFromData({
      'type': 'requestTraffic',
      'data': [
        {'id': 'a', 'upload': 460, 'download': 257835},
        {'id': 'b', 'upload': 0, 'download': 12},
      ],
    }).forEach(coreEventManager.sendEvent);
    await pumpEventQueue();

    expect(listener.requestTraffic, [
      {'a': (upload: 460, download: 257835), 'b': (upload: 0, download: 12)},
    ]);
  });
}

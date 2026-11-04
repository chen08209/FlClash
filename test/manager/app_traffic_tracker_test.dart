import 'package:fl_clash/manager/app_traffic_tracker.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TrackerInfo connection({
    required String id,
    required int upload,
    required int download,
    String process = 'Google Chrome Helper',
    String processPath =
        '/Applications/Google Chrome.app/Contents/Frameworks/Google Chrome Helper',
    List<String> chains = const ['Proxy A', 'Selector'],
    List<String> providerChains = const ['Provider A', ''],
  }) {
    return TrackerInfo(
      id: id,
      upload: upload,
      download: download,
      start: DateTime(2026),
      metadata: Metadata(process: process, processPath: processPath),
      chains: chains,
      providerChains: providerChains,
      rule: 'MATCH',
      rulePayload: '',
    );
  }

  test('tracks live deltas and the final close delta exactly once', () async {
    final persisted = <AppTrafficDelta>[];
    final tracker = AppTrafficTracker(
      persist: (deltas) async => persisted.addAll(deltas),
      resolveProfile: () =>
          const AppTrafficProfileContext(id: 7, label: 'My plan'),
    );

    tracker.observeStart(connection(id: 'a', upload: 0, download: 0));
    await tracker.observeSnapshot([
      connection(id: 'a', upload: 100, download: 200),
    ]);
    await tracker.observeSnapshot([
      connection(id: 'a', upload: 100, download: 200),
    ]);
    await tracker.observeClosed(
      connection(id: 'a', upload: 140, download: 260),
    );
    await tracker.observeClosed(
      connection(id: 'a', upload: 140, download: 260),
    );

    expect(persisted, hasLength(2));
    expect(persisted.map((delta) => delta.upload), [100, 40]);
    expect(persisted.map((delta) => delta.download), [200, 60]);
    expect(persisted.first.applicationLabel, 'Google Chrome');
    expect(persisted.first.applicationId, '/Applications/Google Chrome.app/');
    expect(persisted.first.provider, 'Provider A');
    expect(persisted.first.proxy, 'Proxy A');
  });

  test('excludes direct traffic and groups missing process metadata', () async {
    final persisted = <AppTrafficDelta>[];
    final tracker = AppTrafficTracker(
      persist: (deltas) async => persisted.addAll(deltas),
      resolveProfile: () => const AppTrafficProfileContext(id: 0, label: ''),
    );

    await tracker.observeClosed(
      connection(
        id: 'direct',
        upload: 100,
        download: 200,
        chains: const ['DIRECT'],
      ),
    );
    await tracker.observeClosed(
      connection(
        id: 'proxy',
        upload: 5,
        download: 7,
        process: '',
        processPath: '',
      ),
    );

    expect(persisted, hasLength(1));
    expect(persisted.single.applicationId, 'unknown');
    expect(persisted.single.total, 12);
  });

  test('keeps the subscription that owned the connection at start', () async {
    var profile = const AppTrafficProfileContext(id: 1, label: 'First');
    final persisted = <AppTrafficDelta>[];
    final tracker = AppTrafficTracker(
      persist: (deltas) async => persisted.addAll(deltas),
      resolveProfile: () => profile,
    );

    tracker.observeStart(connection(id: 'a', upload: 0, download: 0));
    profile = const AppTrafficProfileContext(id: 2, label: 'Second');
    await tracker.observeClosed(connection(id: 'a', upload: 10, download: 20));

    expect(persisted.single.profileId, 1);
    expect(persisted.single.profileLabel, 'First');
  });

  test('excludes renamed direct outbounds reported by the core', () async {
    final persisted = <AppTrafficDelta>[];
    final tracker = AppTrafficTracker(
      persist: (deltas) async => persisted.addAll(deltas),
      resolveProfile: () =>
          const AppTrafficProfileContext(id: 1, label: 'Plan'),
    );
    await tracker.observeClosed(
      connection(
        id: 'direct',
        upload: 120,
        download: 340,
      ).copyWith(chains: const ['Local network', 'Selector'], direct: true),
    );
    expect(persisted, isEmpty);
  });
}

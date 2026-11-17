import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/core_mocks.dart';
import '../helpers/probe_dtos.dart';

final _answer = outboundIpOf(
  url: 'https://www.cloudflare.com/cdn-cgi/trace',
  body: 'ip=2.2.2.2\nloc=US\n',
  chains: const ['HK-01'],
);

void main() {
  late CoreMocks mocks;

  setUp(() => mocks = coreMocks());

  ProviderContainer build({bool proxied = true}) {
    final container = ProviderContainer(
      overrides: [
        routeTrackerProvider.overrideWithBuild(
          (_, _) => RouteState(
            coreEpoch: 1,
            routeVersion: 1,
            hostEpoch: 1,
            proxied: proxied,
            synced: true,
            live: true,
          ),
        ),
        coreHandlerProvider.overrideWithValue(mocks.controller),
      ],
    );
    addTearDown(container.dispose);
    container.listen(outboundIpProbeProvider, (_, _) {});
    return container;
  }

  late List<OutboundAsk> asks;

  setUp(() => asks = []);

  void answer(OutboundIp result) => stubOutboundIp(mocks.api, (ask) async {
    asks.add(ask);
    return result;
  });

  Future<OutboundAsk> asked() async {
    await pumpEventQueue();
    return asks.single;
  }

  test(
    'asks the Core for the address the current route exits through',
    () async {
      answer(_answer);
      final container = build();

      container.read(outboundIpProbeProvider.notifier).watch(routedOutbound);

      final params = await asked();
      expect(params.proxy, isEmpty);
      expect(params.urls, ipInfoSources.keys.toList());
      final entry = container
          .read(outboundIpProbeProvider)
          .entryOf(routedOutbound);
      expect(entry.phase, ProbePhase.fresh);
      expect(entry.value?.ip, '2.2.2.2');
    },
  );

  test('pins the direct outbound while the proxy is off', () async {
    answer(_answer);
    final container = build(proxied: false);

    container.read(outboundIpProbeProvider.notifier).watch(routedOutbound);

    expect((await asked()).proxy, directOutbound);
  });

  test('looks a node up through itself', () async {
    answer(_answer);
    final container = build();

    container.read(outboundIpProbeProvider.notifier).watch('HK-01');

    expect((await asked()).proxy, 'HK-01');
    expect(
      container.read(outboundIpProbeProvider).valueOf('HK-01')?.countryCode,
      'US',
    );
  });

  test('the routed answer fills in the node it left through', () async {
    answer(
      outboundIpOf(
        url: 'https://www.cloudflare.com/cdn-cgi/trace',
        body: 'ip=2.2.2.2\nloc=US\n',
        chains: const ['HK-01', 'Balance', 'Proxy'],
        hits: const [
          RouteHitDto(host: 'www.cloudflare.com:443', exit: 'Balance'),
        ],
        nodeHits: const [
          RouteHitDto(
            host: 'www.cloudflare.com:443',
            proxy: 'HK-01',
            exit: 'HK-01',
          ),
        ],
      ),
    );
    final container = build();
    final probe = container.read(outboundIpProbeProvider.notifier);

    probe.watch(routedOutbound);
    await pumpEventQueue();
    probe.watch('HK-01');
    await pumpEventQueue();

    verifyOutboundIp(mocks.api).called(1);
    final entry = container.read(outboundIpProbeProvider).entryOf('HK-01');
    expect(entry.phase, ProbePhase.fresh);
    expect(entry.value?.ip, '2.2.2.2');
    expect(entry.stamp?.hits, const [
      RouteHit(host: 'www.cloudflare.com:443', proxy: 'HK-01', exit: 'HK-01'),
    ]);
  });

  test('a Core error is a failure until it is refreshed', () async {
    answer(outboundIpOf(error: 'timeout'));
    final container = build();
    final probe = container.read(outboundIpProbeProvider.notifier);

    probe.watch(routedOutbound);
    await pumpEventQueue();

    expect(
      container.read(outboundIpProbeProvider).entryOf(routedOutbound).phase,
      ProbePhase.failed,
    );
    verifyOutboundIp(mocks.api).called(1);

    probe.refresh([routedOutbound]);
    await pumpEventQueue();

    verifyOutboundIp(mocks.api).called(1);
  });
}

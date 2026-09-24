import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

const _answer = OutboundIpResult(
  url: 'https://www.cloudflare.com/cdn-cgi/trace',
  body: 'ip=2.2.2.2\nloc=US\n',
  chains: ['HK-01'],
  coreEpoch: 1,
  picksVersion: 1,
);

void main() {
  setUpAll(() => registerFallbackValue(const OutboundIpParams(timeout: 0)));

  late _MockCore core;

  setUp(() => core = _MockCore());

  ProviderContainer build({bool proxied = true}) {
    final container = ProviderContainer(
      overrides: [
        routeTrackerProvider.overrideWithBuild(
          (_, _) => RouteState(
            coreEpoch: 1,
            picksVersion: 1,
            hostEpoch: 1,
            proxied: proxied,
            synced: true,
            live: true,
          ),
        ),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(outboundIpProbeProvider, (_, _) {});
    return container;
  }

  Future<OutboundIpParams> asked() async {
    await pumpEventQueue();
    return verify(() => core.outboundIp(captureAny())).captured.single
        as OutboundIpParams;
  }

  test(
    'asks the Core for the address the current route exits through',
    () async {
      when(() => core.outboundIp(any())).thenAnswer((_) async => _answer);
      final container = build();

      container.read(outboundIpProbeProvider.notifier).watch(routedOutbound);

      final params = await asked();
      expect(params.proxyName, isEmpty);
      expect(params.urls, ipInfoSources.keys.toList());
      final entry = container
          .read(outboundIpProbeProvider)
          .entryOf(routedOutbound);
      expect(entry.phase, ProbePhase.fresh);
      expect(entry.value?.ip, '2.2.2.2');
    },
  );

  test('pins the direct outbound while the proxy is off', () async {
    when(() => core.outboundIp(any())).thenAnswer((_) async => _answer);
    final container = build(proxied: false);

    container.read(outboundIpProbeProvider.notifier).watch(routedOutbound);

    expect((await asked()).proxyName, directOutbound);
  });

  test('looks a node up through itself', () async {
    when(() => core.outboundIp(any())).thenAnswer((_) async => _answer);
    final container = build();

    container.read(outboundIpProbeProvider.notifier).watch('HK-01');

    expect((await asked()).proxyName, 'HK-01');
    expect(
      container.read(outboundIpProbeProvider).valueOf('HK-01')?.countryCode,
      'US',
    );
  });

  test('the routed answer fills in the node it left through', () async {
    when(() => core.outboundIp(any())).thenAnswer(
      (_) async => const OutboundIpResult(
        url: 'https://www.cloudflare.com/cdn-cgi/trace',
        body: 'ip=2.2.2.2\nloc=US\n',
        chains: ['HK-01', 'Proxy'],
        coreEpoch: 1,
        picksVersion: 1,
      ),
    );
    final container = build();
    final probe = container.read(outboundIpProbeProvider.notifier);

    probe.watch(routedOutbound);
    await pumpEventQueue();
    probe.watch('HK-01');
    await pumpEventQueue();

    verify(() => core.outboundIp(any())).called(1);
    final entry = container.read(outboundIpProbeProvider).entryOf('HK-01');
    expect(entry.phase, ProbePhase.fresh);
    expect(entry.value?.ip, '2.2.2.2');
  });

  test('a Core error is a failure until it is retried', () async {
    when(() => core.outboundIp(any())).thenAnswer(
      (_) async => const OutboundIpResult(
        error: 'timeout',
        coreEpoch: 1,
        picksVersion: 1,
      ),
    );
    final container = build();
    final probe = container.read(outboundIpProbeProvider.notifier);

    probe.watch(routedOutbound);
    await pumpEventQueue();

    expect(
      container.read(outboundIpProbeProvider).entryOf(routedOutbound).phase,
      ProbePhase.failed,
    );
    verify(() => core.outboundIp(any())).called(1);

    probe.retry(routedOutbound);
    await pumpEventQueue();

    verify(() => core.outboundIp(any())).called(1);
  });
}

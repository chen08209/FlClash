import 'dart:convert';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/core_mocks.dart';
import '../helpers/probe_dtos.dart';

void main() {
  late CoreMocks mocks;
  late CoreController controller;

  setUp(() {
    mocks = coreMocks();
    controller = mocks.controller;
  });

  group('ServiceProbeStatus', () {
    test('maps every status the Core can report', () {
      for (final status in ServiceProbeStatus.values) {
        expect(ServiceProbeStatus.byId(status.id), status);
      }
    });

    test('an unknown status reads as a failure rather than throwing', () {
      expect(ServiceProbeStatus.byId('brand-new'), ServiceProbeStatus.failed);
    });
  });

  group('ServiceTarget', () {
    test('ids are unique', () {
      final ids = ServiceTarget.values.map((target) => target.id).toSet();
      expect(ids, hasLength(ServiceTarget.values.length));
    });

    test('resolves an id back to its target', () {
      expect(ServiceTarget.byId('disney-plus'), ServiceTarget.disneyPlus);
      expect(ServiceTarget.byId('nope'), isNull);
    });
  });

  group('orderServiceTargets', () {
    test('an empty order keeps the declared one', () {
      expect(orderServiceTargets(const []), ServiceTarget.values);
    });

    test('drops unknown and repeated ids and appends the missing', () {
      final ordered = orderServiceTargets(const [
        'netflix',
        'retired',
        'google',
        'netflix',
      ]);

      expect(ordered.take(2), [ServiceTarget.netflix, ServiceTarget.google]);
      expect(ordered.skip(2), [
        for (final target in ServiceTarget.values)
          if (target != ServiceTarget.netflix && target != ServiceTarget.google)
            target,
      ]);
    });
  });

  group('ServiceCheck.of', () {
    test('carries the region, address, node and check time across', () {
      final check = ServiceCheck.of(
        const ServiceCheckItem(
          name: 'netflix',
          status: 'originals-only',
          region: 'JP',
          ip: '198.51.100.9',
          delay: 87,
          chains: ['JP-02', 'auto'],
          checkedAt: 1700000000000,
          coreEpoch: 7,
          routeVersion: 42,
          hits: [RouteHit(host: 'www.netflix.com:443', exit: 'JP-02')],
        ),
      );

      expect(check.status, ServiceProbeStatus.originalsOnly);
      expect(check.region, 'JP');
      expect(check.ip, '198.51.100.9');
      expect(check.delay, 87);
      expect(check.node, 'JP-02');
      expect(check.chains, ['JP-02', 'auto']);
      expect(check.coreEpoch, 7);
      expect(check.routeVersion, 42);
      expect(check.hits, const [
        RouteHit(host: 'www.netflix.com:443', exit: 'JP-02'),
      ]);
      expect(
        check.checkedAt,
        DateTime.fromMillisecondsSinceEpoch(1700000000000),
      );
    });

    test('drops the placeholders the Core sends for absent values', () {
      final check = ServiceCheck.of(
        const ServiceCheckItem(name: 'google', status: 'failed'),
      );

      expect(check.status, ServiceProbeStatus.failed);
      expect(check.delay, isNull);
      expect(check.region, isNull);
      expect(check.ip, isNull);
      expect(check.node, isNull);
      expect(check.checkedAt, isNull);
    });
  });

  group('checkServices', () {
    test(
      'asks the Core for the named targets and keys the answers back',
      () async {
        late ServiceSweep sent;
        stubCheckServices(mocks.api, (sweep) async {
          sent = sweep;
          return [
            serviceItem('claude', delay: 40, ip: '198.51.100.9'),
            serviceItem('gemini', status: 'unsupported-region'),
          ];
        });

        final checks = await checkServices(
          controller,
          proxyName: 'HK-01',
          targets: const [ServiceTarget.claude, ServiceTarget.gemini],
        );

        expect(sent.proxy, 'HK-01');
        expect(sent.names, ['claude', 'gemini']);
        expect(sent.timeout, probeTimeoutDuration.inMilliseconds);
        expect(
          checks[ServiceTarget.claude]?.status,
          ServiceProbeStatus.available,
        );
        expect(
          checks[ServiceTarget.gemini]?.status,
          ServiceProbeStatus.unsupportedRegion,
        );
        expect(checks[ServiceTarget.claude]?.ip, '198.51.100.9');
        expect(checks[ServiceTarget.gemini]?.ip, isNull);
      },
    );

    test('an empty target list asks for every service', () async {
      late ServiceSweep sent;
      stubCheckServices(mocks.api, (sweep) async {
        sent = sweep;
        return const [];
      });

      await checkServices(controller);

      expect(sent.names, isEmpty);
      expect(sent.proxy, isEmpty);
    });

    test('skips a name this build does not know', () async {
      stubCheckServices(
        mocks.api,
        (_) async => [serviceItem('someday-tv'), serviceItem('spotify')],
      );

      final checks = await checkServices(controller);

      expect(checks.keys, [ServiceTarget.spotify]);
    });
  });

  group('lookupOutboundIp', () {
    test('hands the Core every source and parses the one that won', () async {
      late OutboundAsk sent;
      stubOutboundIp(mocks.api, (ask) async {
        sent = ask;
        return outboundIpOf(
          url: 'https://www.cloudflare.com/cdn-cgi/trace',
          body: 'fl=1\nip=203.0.113.7\nloc=US\n',
        );
      });

      final ipInfo = parseOutboundIp(
        await lookupOutboundIp(controller, 'HK-01'),
      );

      expect(sent.urls, ipInfoSources.keys.toList());
      expect(sent.proxy, 'HK-01');
      expect(sent.timeout, outboundIpTimeoutDuration.inMilliseconds);
      expect(ipInfo, const IpInfo(ip: '203.0.113.7', countryCode: 'US'));
    });

    test('parses whichever source answered, not just the first', () async {
      stubOutboundIp(
        mocks.api,
        (_) async => outboundIpOf(
          url: 'https://api.country.is',
          body: jsonEncode({'ip': '198.51.100.4', 'country': 'DE'}),
        ),
      );

      final ipInfo = parseOutboundIp(
        await lookupOutboundIp(controller, 'DE-01'),
      );

      expect(ipInfo, const IpInfo(ip: '198.51.100.4', countryCode: 'DE'));
    });

    test('gives up on an error, an empty body or an unparseable one', () async {
      final answers = <OutboundIp>[
        outboundIpOf(error: 'timeout'),
        outboundIpOf(url: 'https://api.country.is'),
        outboundIpOf(url: 'https://api.country.is', body: 'garbage'),
        outboundIpOf(url: 'https://unknown.example', body: 'ip=1.2.3.4'),
      ];
      stubOutboundIp(mocks.api, (_) async => answers.removeAt(0));

      for (var attempt = 0; attempt < 4; attempt++) {
        expect(
          parseOutboundIp(await lookupOutboundIp(controller, 'HK-01')),
          isNull,
        );
      }
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/core/desktop/model.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCoreHandler extends CoreHandlerInterface {
  final Map<CoreMethod, Object?> calls = {};

  @override
  Future<CoreLifecycleResult> start() async => const CoreLifecycleResult(
    revision: 1,
    outcome: CoreLifecycleOutcome.applied,
  );

  @override
  Future<CoreLifecycleResult> restart() => start();

  @override
  Future<CoreLifecycleResult> stop() => start();

  @override
  Future<CoreLifecycleResult> close() => start();

  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    calls[method] = arguments;
    final result = switch (method) {
      CoreMethod.initClash => true as T,
      CoreMethod.getTraffic ||
      CoreMethod.getTotalTraffic => {'up': 12, 'down': 34},
      CoreMethod.asyncTestDelay => {
        'name': 'DIRECT',
        'url': 'https://example.com',
        'value': 42,
      },
      CoreMethod.probe => {
        'status-code': 204,
        'delay': 17,
        'body': '',
        'url': 'https://example.com/',
        'chains': ['DIRECT'],
        'rule': 'Match',
        'rule-payload': '',
      },
      CoreMethod.getConnections => {
        'connections': [
          {
            'id': 'connection-1',
            'metadata': {'network': 'tcp'},
            'upload': 0,
            'download': 0,
            'start': '2024-01-01',
            'chains': ['DIRECT'],
            'rule': 'DIRECT',
            'rulePayload': '',
          },
        ],
      },
      CoreMethod.getExternalProviders => [
        {
          'name': 'provider-1',
          'type': 'Proxy',
          'count': 1,
          'vehicle-type': 'HTTP',
          'update-at': '2024-01-01T00:00:00.000Z',
        },
      ],
      CoreMethod.getExternalProvider => {
        'name': 'provider-1',
        'type': 'Proxy',
        'count': 1,
        'vehicle-type': 'HTTP',
        'update-at': '2024-01-01T00:00:00.000Z',
      },
      CoreMethod.getConfig => {
        'mode': 'rule',
        'rule': ['MATCH,DIRECT'],
      },
      CoreMethod.getProfileOutbounds => {
        'proxies': [
          {'name': 'a', 'type': 'ss'},
        ],
        'proxy-groups': <Object>[],
      },
      CoreMethod.getProxyDefinition when arguments == 'a' => {
        'name': 'a',
        'type': 'ss',
        'plugin-opts': {'mode': 'websocket'},
      },
      CoreMethod.getProxyDefinition => null,
      CoreMethod.buildProfile => '/home/responses/1.yaml',
      CoreMethod.getProfileBase => {
        'config': {'mode': 'rule', 'rule': null},
        'digest': 'abc',
        'match-rules': ['MATCH,DIRECT'],
        'proxies': 2,
        'proxy-groups': 1,
        'rules': 3,
      },
      CoreMethod.getMemoryStats => {
        'rss': 2048,
        'heapInuse': 1024,
        'heapIdle': 256,
        'stackInuse': 64,
        'runtimeOther': 32,
      },
      CoreMethod.changeProxy => {'message': '', 'changed': true},
      CoreMethod.compileRuleSet => {'behavior': 'ipcidr', 'format': 'text'},
      CoreMethod.getConnectionCount => 3,
      CoreMethod.validateFilters => ['', 'missing closing )'],
      CoreMethod.watchRoute => {'core-epoch': 1, 'route-version': 0},
      CoreMethod.checkRoutes => {
        'core-epoch': 1,
        'route-version': 3,
        'held': [true, false],
      },
      _ => '',
    };
    return result as T?;
  }
}

class _FailingConfigCoreHandler extends _RecordingCoreHandler {
  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    if (method == CoreMethod.getConfig) {
      throw const CoreMethodException(
        code: 'core_error',
        message: 'config not found',
        details: {'path': '/missing.yaml'},
      );
    }
    return super.invokeMethod(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

class _EmptyConfigCoreHandler extends _RecordingCoreHandler {
  @override
  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    if (method == CoreMethod.getConfig) {
      return null;
    }
    return super.invokeMethod(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
  }
}

void main() {
  test('method call keeps structured arguments', () async {
    final fixture =
        json.decode(
              await File('test/fixtures/core_protocol.json').readAsString(),
            )
            as Map<String, dynamic>;
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from(fixture['methodCall'] as Map),
    );

    expect(call.method, CoreMethod.updateConfig);
    expect(call.arguments, isA<Map<String, dynamic>>());
    expect((call.arguments as Map)['mixed-port'], 7890);
    expect(call.toJson(), containsPair('arguments', call.arguments));
    expect(call.toJson(), isNot(contains('data')));
  });

  test('core interface sends structured request parameters', () async {
    final handler = _RecordingCoreHandler();

    await handler.init(const InitParams(homeDir: '/tmp/flclash', version: 35));
    await handler.setupConfig(
      const SetupParams(selectedMap: {'GLOBAL': 'DIRECT'}, testUrl: 'test'),
    );
    final switched = await handler.changeProxy(
      const ChangeProxyParams(groupName: 'GLOBAL', proxyName: 'DIRECT'),
    );
    expect(switched, const ChangeProxyResult(changed: true));
    final route = await handler.watchRoute(true);
    expect(route, const RouteSnapshot(coreEpoch: 1));
    expect(handler.calls[CoreMethod.watchRoute], isTrue);
    final check = await handler.checkRoutes(
      const CheckRoutesParams(
        routes: [
          [RouteHit(host: 'example.com:443', proxy: 'DIRECT', exit: 'x')],
          [],
        ],
      ),
    );
    expect(
      check,
      const RouteCheck(coreEpoch: 1, routeVersion: 3, held: [true, false]),
    );
    expect(jsonDecode(jsonEncode(handler.calls[CoreMethod.checkRoutes])), {
      'routes': [
        [
          {'host': 'example.com:443', 'proxy': 'DIRECT', 'exit': 'x'},
        ],
        <Object?>[],
      ],
    });
    await handler.sideLoadExternalProvider(providerName: 'provider', data: 'x');
    await handler.asyncTestDelay(
      'https://example.com',
      'DIRECT',
      const Duration(seconds: 8),
    );
    await handler.probe(
      const ProbeParams(
        url: 'https://example.com',
        proxyName: 'DIRECT',
        timeout: 1000,
        maxBody: 64,
      ),
    );
    await handler.clearEffect(42);

    for (final method in [
      CoreMethod.initClash,
      CoreMethod.setupConfig,
      CoreMethod.changeProxy,
      CoreMethod.sideLoadExternalProvider,
      CoreMethod.asyncTestDelay,
      CoreMethod.probe,
    ]) {
      expect(handler.calls[method], isA<Map>());
    }
    expect(handler.calls[CoreMethod.probe], {
      'url': 'https://example.com',
      'proxy-name': 'DIRECT',
      'headers': <String, String>{},
      'timeout': 1000,
      'max-body': 64,
    });
    expect(handler.calls[CoreMethod.clearEffect], 42);
  });

  test('validateFilters sends the filters and reads one error each', () async {
    final handler = _RecordingCoreHandler();

    final errors = await handler.validateFilters(['hk`jp', '(hk']);

    expect(handler.calls[CoreMethod.validateFilters], ['hk`jp', '(hk']);
    expect(errors, ['', 'missing closing )']);
  });

  test('dumpRuleSet sends the rule set path', () async {
    final handler = _RecordingCoreHandler();

    await handler.dumpRuleSet('/rules.mrs');

    expect(handler.calls[CoreMethod.dumpRuleSet], '/rules.mrs');
  });

  test('decryptConfig sends the path and the age key', () async {
    final handler = _RecordingCoreHandler();

    await handler.decryptConfig('/profile.yaml', 'AGE-SECRET-KEY-1A');

    expect(handler.calls[CoreMethod.decryptConfig], {
      'path': '/profile.yaml',
      'age-secret-key': 'AGE-SECRET-KEY-1A',
    });
  });

  test(
    'compileRuleSet names a cached file and reads what the Core found',
    () async {
      final handler = _RecordingCoreHandler();

      final info = await handler.compileRuleSet(
        'abc',
        url: 'https://example.com/r.list',
      );

      expect(handler.calls[CoreMethod.compileRuleSet], {
        'name': 'abc',
        'url': 'https://example.com/r.list',
      });
      expect(info, (
        behavior: RuleProviderBehavior.ipcidr,
        format: RuleProviderFormat.text,
      ));
    },
  );

  test('event contract accepts batches and legacy single events', () async {
    final fixture =
        json.decode(
              await File('test/fixtures/core_protocol.json').readAsString(),
            )
            as Map<String, dynamic>;
    final call = CoreMethodCall.fromJson(
      Map<String, Object?>.from(fixture['eventCall'] as Map),
    );

    final events = coreEventsFromData(call.arguments);
    expect(events, hasLength(2));
    expect(events.first.type, CoreEventType.loaded);
    expect(events.last.type, CoreEventType.delay);

    final legacy = coreEventsFromData({'type': 'loaded', 'data': 'provider-b'});
    expect(legacy.single.data, 'provider-b');
  });

  test('event contract decodes the dns query the Core sends', () {
    final events = coreEventsFromData([
      {
        'type': 'dns',
        'data': {
          'domain': 'www.example.com',
          'type': 'A',
          'initiator': 'app',
          'answers': ['93.184.216.34'],
          'rcode': 'NOERROR',
          'delay': 0,
          'time': '2026-09-18T12:30:01.123456789+08:00',
        },
      },
      {
        'type': 'dns',
        'data': {
          'domain': 'missing.test',
          'type': 'AAAA',
          'initiator': 'unknown-initiator',
          'upstream': 'tls://1.1.1.1:853',
          'cached': true,
          'answers': <String>[],
          'error': 'i/o timeout',
          'delay': 5000,
          'time': '2026-09-18T04:30:02Z',
        },
      },
    ]);

    expect(events.map((event) => event.type), [
      CoreEventType.dns,
      CoreEventType.dns,
    ]);
    final queries = [
      for (final event in events)
        DnsQuery.fromJson(Map<String, Object?>.from(event.data as Map)),
    ];
    expect(queries.first.initiator, DnsQueryInitiator.app);
    expect(queries.first.upstream, isEmpty);
    expect(queries.first.cached, isFalse);
    expect(queries.first.answers, ['93.184.216.34']);
    expect(
      queries.first.time.toUtc(),
      DateTime.utc(2026, 9, 18, 4, 30, 1, 123, 456),
    );
    expect(queries.first.isFailed, isFalse);
    expect(queries.last.initiator, isNull);
    expect(queries.last.upstream, 'tls://1.1.1.1:853');
    expect(queries.last.cached, isTrue);
    expect(queries.last.rcode, isEmpty);
    expect(queries.last.isFailed, isTrue);
  });

  test('event contract skips malformed entries without dropping the batch', () {
    final events = coreEventsFromData([
      {'type': 'loaded', 'data': 'provider-a'},
      {'type': 'invalid-event', 'data': null},
      {'type': 'loaded', 'data': 'provider-b'},
    ]);

    expect(events.map((event) => event.data), ['provider-a', 'provider-b']);
  });

  test('core interface converts structured method results', () async {
    final handler = _RecordingCoreHandler();

    expect(await handler.getTraffic(false), const Traffic(up: 12, down: 34));
    expect(
      await handler.getTotalTraffic(false),
      const Traffic(up: 12, down: 34),
    );
    expect(
      await handler.asyncTestDelay(
        'https://example.com',
        'DIRECT',
        const Duration(seconds: 8),
      ),
      const Delay(name: 'DIRECT', url: 'https://example.com', value: 42),
    );
    expect(
      await handler.probe(
        const ProbeParams(url: 'https://example.com', timeout: 1000),
      ),
      const ProbeResult(
        statusCode: 204,
        delay: 17,
        url: 'https://example.com/',
        chains: ['DIRECT'],
        rule: 'Match',
      ),
    );
    expect((await handler.getConnections()).single.id, 'connection-1');
    expect(await handler.getConnectionCount(), 3);
    expect((await handler.getExternalProviders()).single.name, 'provider-1');
    expect(
      (await handler.getExternalProvider('provider-1'))?.name,
      'provider-1',
    );
    expect(await handler.getConfig('/config.yaml'), {
      'mode': 'rule',
      'rule': ['MATCH,DIRECT'],
    });
    final memory = await handler.getMemoryStats();
    expect(memory?.rss, 2048);
    expect(memory?.runtimeTotal, 1024 + 256 + 64 + 32);
  });

  test('getProfileBase sends the path and reads what the Core kept', () async {
    final handler = _RecordingCoreHandler();

    final base = await handler.getProfileBase('/profiles/1.yaml');

    expect(handler.calls[CoreMethod.getProfileBase], '/profiles/1.yaml');
    expect(
      base,
      const ProfileBase(
        config: {'mode': 'rule', 'rule': null},
        digest: 'abc',
        matchRules: ['MATCH,DIRECT'],
        proxies: 2,
        proxyGroups: 1,
        rules: 3,
      ),
    );
  });

  test('the outbounds and the built profile cross as plain JSON', () async {
    final handler = _RecordingCoreHandler();
    const base = SetupBase(path: '/profiles/1.yaml', overlay: 'mode: rule');

    final outbounds = await handler.getProfileOutbounds('/profiles/1.yaml');
    final built = await handler.buildProfile(base);

    expect(handler.calls[CoreMethod.getProfileOutbounds], '/profiles/1.yaml');
    expect(outbounds['proxies'], [
      {'name': 'a', 'type': 'ss'},
    ]);
    expect(handler.calls[CoreMethod.buildProfile], base.toJson());
    expect(built, '/home/responses/1.yaml');
  });

  test('a proxy definition crosses as a nested mapping or null', () async {
    final handler = _RecordingCoreHandler();

    final definition = await handler.getProxyDefinition('a');
    final missing = await handler.getProxyDefinition('from-provider');

    expect(handler.calls[CoreMethod.getProxyDefinition], 'from-provider');
    expect(definition, {
      'name': 'a',
      'type': 'ss',
      'plugin-opts': {'mode': 'websocket'},
    });
    expect(missing, isNull);
  });

  test('setupConfig names a base only when the Core applies one', () async {
    final handler = _RecordingCoreHandler();
    const params = SetupParams(selectedMap: {}, testUrl: 'test');
    Object? sent() =>
        json.decode(json.encode(handler.calls[CoreMethod.setupConfig]));

    await handler.setupConfig(params);
    expect(sent(), isNot(contains('base')));

    await handler.setupConfig(
      params.copyWith(
        base: const SetupBase(path: '/profiles/1.yaml', overlay: 'mode: rule'),
      ),
    );
    expect((sent()! as Map)['base'], {
      'path': '/profiles/1.yaml',
      'overlay': 'mode: rule',
    });
  });

  test('getConfig preserves structured core errors', () async {
    final handler = _FailingConfigCoreHandler();

    await expectLater(
      handler.getConfig('/missing.yaml'),
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'core_error')
            .having((error) => error.details, 'details', {
              'path': '/missing.yaml',
            }),
      ),
    );
  });

  test('getConfig rejects empty transport results', () async {
    final handler = _EmptyConfigCoreHandler();

    await expectLater(
      handler.getConfig('/config.yaml'),
      throwsA(
        isA<CoreMethodException>().having(
          (error) => error.code,
          'code',
          'empty_result',
        ),
      ),
    );
  });

  test('method response separates result and structured errors', () async {
    final fixture =
        json.decode(
              await File('test/fixtures/core_protocol.json').readAsString(),
            )
            as Map<String, dynamic>;
    final success = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['successResponse'] as Map),
    );
    final structured = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['structuredResponse'] as Map),
    );
    final failure = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['errorResponse'] as Map),
    );
    final spilled = CoreMethodResponse.fromJson(
      Map<String, Object?>.from(fixture['spilledResponse'] as Map),
    );

    expect(success.unwrap<String>(), '');
    expect(success.toJson(), containsPair('result', ''));
    expect(structured.result, isA<Map>());
    expect(structured.result, isNot(isA<String>()));
    expect(structured.unwrap<Map<String, dynamic>>()?['up'], 12);
    expect(
      () => failure.unwrap<Object?>(),
      throwsA(
        isA<CoreMethodException>()
            .having((error) => error.code, 'code', 'core_error')
            .having((error) => error.message, 'message', 'config not found'),
      ),
    );
    expect(failure.toJson(), contains('error'));
    expect(failure.toJson(), isNot(contains('code')));
    expect(failure.file, isNull);
    expect(failure.toJson(), isNot(contains('file')));
    expect(spilled.file, '/home/responses/1234.json');
    expect(spilled.toJson(), containsPair('file', '/home/responses/1234.json'));
  });
}

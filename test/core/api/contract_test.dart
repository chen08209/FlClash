import 'dart:async';

import 'package:fl_clash/core/api/core_api.dart';
import 'package:fl_clash/core/api/core_client.dart';
import 'package:fl_clash/core/api/dto.dart';
import 'package:fl_clash/core/api/rpc_core_api.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_channel.dart';
import 'schema_core.dart';

/// Methods of the schema this app never calls: the Kotlin service owns the
/// first three, and the rest serve the views of a dashboard on the external
/// controller.
const _notCalledByDart = {
  'core.setPressure',
  'tun.start',
  'tun.stop',
  'dns.flushFakeIp',
  'dns.query',
  'provider.healthCheck',
  'proxy.states',
};

/// The schema types its answer as optional where the core always fills it, so
/// an answer without it is not one the app is asked to read.
const _alwaysFilled = {'mitm.generateCertificate'};

typedef _Call = Future<Object?> Function(CoreApi api);

Future<Object?> _first<T>(Stream<T> stream) =>
    stream.first.timeout(const Duration(seconds: 2));

/// One call per `CoreApi` method, with arguments that exercise every optional
/// parameter the Dart side can send.
final Map<String, _Call> _calls = {
  'core.hello': (api) => (api as RpcCoreApi).client.ready(),
  'core.init': (api) => api.init(home: '/home', sdkInt: 34),
  'core.releaseMemory': (api) => api.releaseMemory(),
  'core.stats': (api) => api.stats(),
  'core.capabilities': (api) => api.capabilities(),
  'core.lastWarnings': (api) => api.lastWarnings(),
  'debug.crash': (api) => api.debugCrash(),
  'engine.state': (api) => api.engineStatus(),
  'engine.start': (api) => api.startEngine(),
  'engine.stop': (api) => api.stopEngine(),
  'config.apply': (api) => api.applyConfig(
    profilePath: '/profile.yaml',
    overlay: const {'rules': <Object?>[]},
    selection: const {'g': 'p'},
    options: const CoreOptionsArg(
      testUrl: 'http://t',
      skipCertVerify: true,
      delayTestTimeout: 3000,
      mitmCapture: true,
    ),
    host: const {
      'externalController': '127.0.0.1:9090',
      'secret': 's',
      'externalControllerCors': {
        'allowOrigins': ['*'],
        'allowPrivateNetwork': true,
      },
      'hostCredential': 'h:s',
    },
  ),
  'config.patch': (api) => api.patchConfig(
    const ConfigPatch(
      tun: TunPatchArg(enable: true, device: 'd', autoRoute: true),
      allowLan: true,
      mixedPort: 7890,
      findProcessMode: 'strict',
      mode: 'rule',
      logLevel: LogLevel.info,
      ipv6: true,
      tcpConcurrent: true,
      externalController: '127.0.0.1:9090',
      secret: 's',
      externalControllerCors: ControllerCorsArg(
        allowOrigins: ['*'],
        allowPrivateNetwork: true,
      ),
      unifiedDelay: true,
      authentication: ['u:p'],
      hostCredential: 'h:s',
      geoAutoUpdate: true,
      geoUpdateInterval: 24,
      geoxUrl: {'geoip': 'http://g'},
      options: CoreOptionsArg(testUrl: 'http://t'),
    ),
  ),
  'config.general': (api) => api.general(),
  'config.validate': (api) => api.validateConfig('/p.yaml'),
  'config.decrypt': (api) => api.decryptConfig('/p.yaml', 'key'),
  'config.read': (api) => api.readConfig('/p.yaml'),
  'profile.inspect': (api) => api.inspectProfile('/p.yaml'),
  'profile.outbounds': (api) => api.profileOutbounds('/p.yaml'),
  'profile.build': (api) => api.buildProfile('/p.yaml', const {'rules': []}),
  'profile.clearEffect': (api) => api.clearEffect(1),
  'proxy.groups': (api) => api.proxyGroups(),
  'proxy.watch': (api) => _first(api.watchProxies()),
  'proxy.select': (api) => api.selectProxy('g', 'p'),
  'proxy.definition': (api) => api.proxyDefinition('p'),
  'delay.test': (api) => api.testDelay('p', url: 'http://u', timeout: 1000),
  'delay.run': (api) => api
      .runDelays(['a', 'b'], url: 'http://u', timeout: 1000, concurrency: 4)
      .toList(),
  'validate.proxies': (api) => api.validateProxies([
    {'name': 'a'},
  ]),
  'validate.filters': (api) => api.validateFilters(['x']),
  'convert.subscription': (api) => api.convertSubscription('/p.yaml'),
  'convert.encodeLinks': (api) => api.encodeLinks([
    {'name': 'a'},
  ]),
  'convert.decodeLinks': (api) => api.decodeLinks(['ss://x']),
  'provider.list': (api) => api.providers(),
  'provider.get': (api) => api.provider('p'),
  'provider.update': (api) => api.updateProvider('p'),
  'provider.sideLoad': (api) => api.sideLoadProvider('p', 'data'),
  'ruleSet.dump': (api) => api.dumpRuleSet('/p.yaml', outputFile: '/out'),
  'rule.list': (api) => api.ruleList(),
  'ruleSet.compile': (api) => api.compileRuleSet('r', url: 'http://u'),
  'geo.update': (api) => api.updateGeo('geoip'),
  'traffic.watch': (api) =>
      _first(api.watchTraffic(intervalMs: 1000, onlyProxy: true)),
  'traffic.reset': (api) => api.resetTraffic(),
  'connection.watch': (api) => _first(api.watchConnections(maxBatchMs: 250)),
  'connection.close': (api) async {
    await api.closeConnections(ids: [1, 2]);
    return api.closeConnections();
  },
  'network.reset': (api) => api.resetNetwork(),
  'network.update': (api) =>
      api.updateNetwork(dnsServers: ['1.1.1.1'], interfaceChanged: true),
  'dns.clearCache': (api) => api.clearDnsCache(),
  'log.watch': (api) => _first(api.watchLogs(level: LogLevel.info)),
  'dns.watch': (api) => _first(api.watchDns()),
  'route.watch': (api) => _first(api.watchRoute()),
  'events.watch': (api) => api
      .watchEvents(delays: true, state: true)
      .first
      .timeout(const Duration(seconds: 2)),
  'route.check': (api) => api.checkRoutes([
    [const RouteHitDto(host: 'h', proxy: 'p', exit: 'e')],
  ], timeout: const Duration(seconds: 5)),
  'probe.outboundIp': (api) => api.outboundIp(
    'p',
    ['http://u'],
    timeout: 3000,
    guard: const Duration(seconds: 5),
  ),
  'probe.services': (api) => api.checkServices(
    'p',
    ['google'],
    timeout: 3000,
    guard: const Duration(seconds: 5),
  ),
  'mitm.certificate': (api) => api.mitmCertificate(),
  'mitm.generateCertificate': (api) => api.generateMitmCertificate(),
  'mitm.validate': (api) => api.validateMitm({'hostname': <String>[]}),
  'mitm.issueCertificate': (api) => api.issueMitmCertificate('h'),
  'mitm.runScript': (api) =>
      api.runMitmScript('s', guard: const Duration(seconds: 5)),
  'mitm.exchanges': (api) => api.mitmExchanges(1),
  'mitm.query': (api) => api.mitmQuery(
    filter: const MitmFilter(
      statuses: [MitmStatus.clientError, MitmStatus.failed],
      methods: ['GET'],
      kinds: [MitmKind.json],
      hosts: ['example.com'],
      apps: [''],
      rewritten: true,
      slowMs: 1,
      text: 'a',
      from: 1,
      to: 2,
    ),
    before: 1,
    limit: 1,
    since: 1,
    facets: true,
    rateFrom: 1,
  ),
  'mitm.exchange': (api) => api.mitmExchange(1),
  'mitm.body': (api) async {
    await api.mitmBody(1, response: true);
    return api.mitmBody(1, response: false);
  },
  'mitm.readModule': (api) => api.readMitmModule(
    '[Rule]',
    arguments: const {'a': '1'},
    attachments: const {'a.js': 'f.js'},
    language: 'zh-Hans',
  ),
  'mitm.moduleStatus': (api) => api.mitmModuleStatus(),
  'mitm.fetchModule': (api) async {
    await api.fetchMitmModule();
    return api.fetchMitmModule(name: 'm');
  },
};

void main() {
  final schema = ApiSchema.load();

  test('every method of the schema is called by Dart or named as not', () {
    final names = schema.methods.map((method) => method['name']).toSet();
    expect(
      names.difference({..._calls.keys, ..._notCalledByDart}),
      isEmpty,
      reason: 'a method the schema gained that Dart neither calls nor lists',
    );
    expect(
      {..._calls.keys}.difference(names),
      isEmpty,
      reason: 'a call for a method the schema does not have',
    );
    expect(_notCalledByDart.difference(names), isEmpty);
  });

  for (final full in [true, false]) {
    group(full ? 'against full answers' : 'against minimal answers', () {
      for (final MapEntry(key: name, value: call) in _calls.entries) {
        if (!full && _alwaysFilled.contains(name)) {
          continue;
        }
        test(name, () async {
          final channel = FakeFrameChannel();
          final core = SchemaCore(channel, schema, full: full);
          final client = CoreClient(channel, debug: true);
          final api = RpcCoreApi(client);
          channel.connect();
          addTearDown(() async {
            await client.close();
            await channel.close();
          });
          await call(api).timeout(const Duration(seconds: 5));
          expect(core.problems, isEmpty);
          expect(
            core.called,
            contains(name),
            reason: 'the call did not reach $name',
          );
        });
      }
    });
  }

  test('an answer that breaks the schema is noticed', () {
    expect(
      schema.validate(
        {'state': 'nonsense'},
        {r'$ref': '#/\$defs/EngineStatus'},
      ),
      isNotEmpty,
    );
    expect(
      schema.validate({'extra': 1}, {r'$ref': '#/\$defs/ConnectionCounter'}),
      isNotEmpty,
    );
  });
}

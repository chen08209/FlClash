import 'package:fl_clash/common/application_proxy.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

final _time = DateTime.utc(2026, 10, 22);

ApplicationConnection _connection(
  String id, {
  String path = '/apps/browser',
  String process = 'browser',
  String? outbound = 'Proxy',
  int upload = 0,
  int download = 0,
  DateTime? start,
}) => (
  id: id,
  path: path,
  process: process,
  outbound: outbound,
  start: start ?? _time.subtract(const Duration(minutes: 1)),
  upload: upload,
  download: download,
);

ApplicationProxySnapshot _snapshot(
  List<ApplicationConnection> connections, {
  List<Rule> rules = const [],
  bool windows = false,
  DateTime? at,
  ApplicationProxySnapshot? previous,
}) => aggregateApplicationProxies((
  connections: connections,
  rules: rules,
  sampledAt: at ?? _time,
  previousSamples: previous?.samples ?? const {},
  previousAt: previous?.sampledAt,
  windows: windows,
));

void main() {
  test('Windows paths ignore casing and separators, but keep installs apart', () {
    final snapshot = _snapshot([
      _connection('1', path: r'C:\Apps\Browser.exe'),
      _connection('2', path: 'c:/apps/browser.exe'),
      _connection('3', path: r'D:\Apps\Browser.exe'),
    ], windows: true);

    expect(snapshot.applications, hasLength(2));
    expect(snapshot.applications.first.connections, 2);
    expect(snapshot.applications.first.identity!.name, 'Browser.exe');
    expect(
      _snapshot([
        _connection('1', path: '/apps/Browser'),
        _connection('2', path: '/apps/browser'),
      ]).applications,
      hasLength(2),
    );
  });

  test('actual routes distinguish mixed, blocked, unknown and named proxies', () {
    final snapshot = _snapshot([
      _connection('1'),
      _connection('2', outbound: 'DIRECT'),
      _connection('3', path: '/apps/blocked', outbound: 'REJECT-DROP'),
      _connection('4', path: '/apps/unknown', outbound: null),
      _connection('5', path: '/apps/custom', outbound: 'direct'),
      _connection('6', path: '/apps/direct', outbound: 'COMPATIBLE'),
    ]);
    ApplicationRoute route(String path) => snapshot.applications
        .singleWhere((row) => row.identity?.content == path)
        .route;

    expect(route('/apps/browser'), ApplicationRoute.mixed);
    expect(route('/apps/blocked'), ApplicationRoute.blocked);
    expect(route('/apps/unknown'), ApplicationRoute.unknown);
    expect(route('/apps/custom'), ApplicationRoute.proxy);
    expect(route('/apps/direct'), ApplicationRoute.direct);
  });

  test('configured apps stay visible while idle and source rules are excluded', () {
    final snapshot = _snapshot([], rules: [
      const Rule(
        ruleAction: RuleAction.PROCESS_PATH,
        content: '/apps/browser',
        ruleTarget: 'DIRECT',
      ),
      const Rule(
        ruleAction: RuleAction.PROCESS_NAME,
        content: 'ignored',
        ruleTarget: 'DIRECT',
        src: true,
      ),
      const Rule(
        ruleAction: RuleAction.DOMAIN,
        content: 'example.test',
        ruleTarget: 'Proxy',
      ),
    ]);

    final row = snapshot.applications.single;
    expect(row.identity!.content, '/apps/browser');
    expect(row.target, 'DIRECT');
    expect(row.route, ApplicationRoute.idle);
  });

  test('the first matching process rule wins across names and paths', () {
    const byName = Rule(
      ruleAction: RuleAction.PROCESS_NAME,
      content: 'browser',
      ruleTarget: 'Proxy',
    );
    const byPath = Rule(
      ruleAction: RuleAction.PROCESS_PATH,
      content: '/apps/browser',
      ruleTarget: 'DIRECT',
    );
    final connection = _connection('1');

    for (final rules in [
      [byName, byPath],
      [byPath, byName],
    ]) {
      final row = _snapshot([connection], rules: rules).applications.first;
      expect(row.target, rules.first.ruleTarget);
      expect(row.identity!.action, rules.first.ruleAction);
    }
  });

  test('missing process paths fall back to names; unknown apps cannot be edited', () {
    final snapshot = _snapshot([
      _connection('1', path: '', process: 'browser'),
      _connection('2', path: '', process: '', outbound: null),
    ]);

    expect(
      snapshot.applications
          .singleWhere((row) => row.identity != null)
          .identity!
          .action,
      RuleAction.PROCESS_NAME,
    );
    final unknown = snapshot.applications.singleWhere((row) => row.identity == null);
    expect(unknown.route, ApplicationRoute.unknown);
    final fallback = _snapshot([
      _connection('3', path: '/apps/vendor, inc/browser'),
    ]).applications.single.identity!;
    expect(fallback.action, RuleAction.PROCESS_NAME);
    expect(fallback.canRoute, isTrue);
    for (final content in ['', 'app,other', 'app\nother']) {
      expect(
        ApplicationIdentity(
          action: RuleAction.PROCESS_NAME,
          content: content,
          windows: false,
        ).canRoute,
        isFalse,
      );
    }
  });

  test('speeds use counter deltas and the elapsed sample time', () {
    final first = _snapshot([_connection('1', upload: 100, download: 200)]);
    expect(first.applications.single.downloadSpeed, 0);
    final next = _snapshot([
      _connection('1', upload: 400, download: 800),
      _connection(
        '2',
        upload: 40,
        download: 80,
        start: _time.add(const Duration(seconds: 1)),
      ),
      _connection('3', upload: 10000, download: 20000),
    ], at: _time.add(const Duration(seconds: 2)), previous: first);

    final row = next.applications.single;
    expect(row.uploadSpeed, 170);
    expect(row.downloadSpeed, 340);
    expect(row.upload, 10440);
    expect(row.download, 20880);
  });

  test('a rule refresh at the same sample keeps the last speed', () {
    final connections = [_connection('1', download: 1200)];
    final first = _snapshot([_connection('1', download: 200)]);
    final next = _snapshot(
      connections,
      at: _time.add(const Duration(seconds: 1)),
      previous: first,
    );
    final refreshed = _snapshot(
      connections,
      at: next.sampledAt,
      previous: next,
      rules: [
        const Rule(
          ruleAction: RuleAction.PROCESS_PATH,
          content: '/apps/browser',
          ruleTarget: 'DIRECT',
        ),
      ],
    );

    expect(refreshed.applications.single.downloadSpeed, 1000);
    expect(refreshed.applications.single.target, 'DIRECT');
    expect(refreshed.applications.single.route, ApplicationRoute.proxy);
  });

  test('resets, reused IDs and resumed polling do not create speed spikes', () {
    final first = _snapshot([_connection('1', download: 1000)]);
    for (final seconds in [-1, 20]) {
      final next = _snapshot(
        [_connection('1', download: 100000)],
        at: _time.add(Duration(seconds: seconds)),
        previous: first,
      );
      expect(next.applications.single.downloadSpeed, 0);
    }
    final reset = _snapshot(
      [_connection('1', download: 10)],
      at: _time.add(const Duration(seconds: 1)),
      previous: first,
    );
    expect(reset.applications.single.downloadSpeed, 0);
    final reused = _snapshot(
      [_connection('1', start: _time, download: 10000)],
      at: _time.add(const Duration(seconds: 1)),
      previous: first,
    );
    expect(reused.applications.single.downloadSpeed, 0);
    expect(
      _snapshot([], at: _time, previous: first).samples,
      isEmpty,
    );
  });
}

import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/mitm_modules.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prism_ui/checkbox.dart';
import 'package:prism_ui/color.dart';
import 'package:prism_ui/context.dart';
import 'package:prism_ui/list.dart';
import 'package:prism_ui/loading.dart';
import 'package:prism_ui/switch.dart';

import '../helpers/core_mocks.dart';
import '../helpers/module_reads.dart';
import '../helpers/test_app.dart';

const _module =
    r'''
#!name=Sample
#!desc=Rewrites samples
#!arguments=Toggle:true
[MITM]
hostname = %APPEND% *.example.com
[URL Rewrite]
^https://example\.com/a _ reject
bad line
[General]
skip-proxy = example.com
hijack-dns = 8.8.8.8:53
[Script]
'''
    '$_adsScript\n$_dailyScript\n';

const _adsScript =
    r'Sample = type=http-response,pattern=^https://example\.com/b,script-path=https://example.com/sample.js';
const _dailyScript =
    'cron "0 8 * * *" script-path=https://example.com/daily.js, tag=Daily';

JsonMap _read({Map<String, List<JsonMap>> views = const {}}) => moduleRead(
  meta: const {'name': 'Sample', 'desc': 'Rewrites samples'},
  arguments: const [
    {
      'name': 'Toggle',
      'kind': {'type': 'switch'},
      'number': false,
      'default': 'true',
      'line': 3,
    },
  ],
  resources: [
    scriptResource('https://example.com/sample.js', 13),
    scriptResource('https://example.com/daily.js', 14),
  ],
  declaredScripts: const [13, 14],
  asksConsent: true,
  issues: {
    'url-rewrite': [lineIssue(8, 'unknown type')],
  },
  views: {
    'hostname': [
      lineEntry(
        5,
        const MitmLineView.hosts(
          entries: [MitmHostEntry(host: '*.example.com')],
        ),
      ),
    ],
    'url-rewrite': [
      lineEntry(
        7,
        const MitmLineView.urlRewrite(
          pattern: r'^https://example\.com/a',
          action: 'reject',
        ),
      ),
    ],
    ...views,
  },
  network: const {
    'bypassDomain': {
      'replace': true,
      'before': ['example.com'],
      'after': <String>[],
    },
    'lines': [10],
  },
  ignored: const [
    {'line': 11, 'text': 'hijack-dns = 8.8.8.8:53', 'reason': 'setting'},
  ],
);

/// Every update and new value brings what the module was never agreed to.
class _TurningOff extends MitmModulesAction {
  MitmModule _off(MitmModule module) {
    final off = module.copyWith(enabled: false, accepted: null, scripts: 1);
    putModule(off);
    return off;
  }

  @override
  Future<MitmModule> updateModule(MitmModule module) async => _off(module);

  @override
  Future<MitmModule?> setArguments(
    MitmModule module,
    Map<String, String> arguments,
  ) async => _off(module.copyWith(arguments: arguments));
}

/// Records the URL a module is moved to instead of downloading it.
class _ChangingUrl extends MitmModulesAction {
  final changed = <String>[];

  @override
  Future<MitmModule> changeUrl(MitmModule module, String url) async {
    changed.add(url);
    final moved = module.copyWith(url: url);
    putModule(moved);
    return moved;
  }
}

/// Takes new values without reading the module file, which a widget test
/// cannot reach.
class _SavingArguments extends MitmModulesAction {
  @override
  Future<MitmModule?> setArguments(
    MitmModule module,
    Map<String, String> arguments,
  ) async {
    final changed = module.copyWith(arguments: arguments);
    putModule(changed);
    return changed;
  }
}

final _remote = MitmModule(
  id: 1,
  name: 'Sample',
  description: 'Rewrites samples',
  url: 'https://example.com/sample.sgmodule',
  lastUpdateTime: DateTime(2026, 10, 24),
  order: 0,
);

final _local = MitmModule(
  id: 2,
  name: 'Mine',
  enabled: false,
  scripts: 1,
  accepted: false,
  resources: const {'own.js': 'h1.js'},
  lastUpdateTime: DateTime(2026, 10, 24),
  order: 1,
);

void main() {
  late Database testDatabase;
  late ProviderContainer container;

  setUp(() {
    testDatabase = Database(NativeDatabase.memory());
    database = testDatabase;
  });

  tearDown(() => testDatabase.close());

  Future<List<MitmModule>> stored() => database.mitmModulesDao.query().get();

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    CoreController? core,
    MitmModulesAction Function()? action,
    MitmModuleDetails? remoteContent,
    Future<MitmModuleDetails?> Function()? localContent,
    Map<String, MitmModuleStatus> statuses = const {},
    List<MitmModule>? modules,
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await database.mitmModulesDao.putAll([
      for (final module in modules ?? [_remote, _local]) module.toCompanion(),
    ]);
    final content = remoteContent ?? moduleDetails(_module, _read());
    container = ProviderContainer(
      overrides: [
        if (core != null) coreHandlerProvider.overrideWithValue(core),
        if (action != null) mitmModulesActionProvider.overrideWith(action),
        mitmModuleStatusProvider.overrideWith((ref) async => statuses),
        mitmModuleContentProvider(
          _remote.id,
        ).overrideWith((ref) async => content),
        mitmModuleContentProvider(
          _local.id,
        ).overrideWith((ref) => localContent?.call() ?? Future.value()),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1000, 2000));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the list shows each module and turns one off', (tester) async {
    await pump(tester, const MitmModulesView());

    expect(find.text('Sample'), findsOneWidget);
    expect(find.text(currentAppLocalizations.remote), findsOneWidget);
    expect(find.text('Mine'), findsOneWidget);
    expect(find.text(currentAppLocalizations.local), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final modules = await stored();
    expect(modules.first.enabled, isFalse);
    expect(modules.last.enabled, isFalse);
  });

  testWidgets('a module with scripts asks before it turns on', (tester) async {
    await pump(
      tester,
      const MitmModulesView(),
      localContent: () async =>
          moduleDetails('', moduleRead(declaredScripts: const [1])),
    );

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.mitmScriptRiskTitle),
      findsOneWidget,
    );
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect((await stored()).last.enabled, isFalse);
    expect((await stored()).last.accepted, isFalse);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.turnOn));
    await tester.pumpAndSettle();
    expect((await stored()).last.enabled, isTrue);
    expect((await stored()).last.accepted, isTrue);
  });

  testWidgets('turning on asks by what the file asks now', (tester) async {
    await pump(tester, const MitmModulesView());
    container
        .read(mitmModulesActionProvider.notifier)
        .putModule(_remote.copyWith(enabled: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    final title = find.text(currentAppLocalizations.mitmModuleRiskTitle);
    expect(title, findsOneWidget);
    Navigator.of(tester.element(title)).pop();
    await tester.pumpAndSettle();
    expect((await stored()).first.enabled, isFalse);
    expect((await stored()).first.accepted, isNull);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.turnOn));
    await tester.pumpAndSettle();
    final ads = (await stored()).first;
    expect(ads.enabled, isTrue);
    expect(ads.accepted, isTrue);
    expect(ads.asksConsent, isTrue);
  });

  testWidgets('turning on names the scripts the file declares now', (
    tester,
  ) async {
    await pump(tester, const MitmModulesView());
    container
        .read(mitmModulesActionProvider.notifier)
        .putModule(_remote.copyWith(enabled: false, scripts: 0));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    final risk = find.textContaining(
      currentAppLocalizations.mitmScriptRisk,
      findRichText: true,
    );
    expect(risk, findsOneWidget);
    Navigator.of(tester.element(risk)).pop();
    await tester.pumpAndSettle();
  });

  for (final (reason, content) in [
    ('is gone', () async => null),
    ('does not parse', () => Future<MitmModuleDetails?>.error(Exception())),
  ]) {
    testWidgets('turning on asks when the module file $reason', (tester) async {
      await pump(tester, const MitmModulesView(), localContent: content);
      container
          .read(mitmModulesActionProvider.notifier)
          .putModule(_local.copyWith(scripts: 0, accepted: null));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();

      expect(
        find.text(currentAppLocalizations.mitmModuleRiskTitle),
        findsOneWidget,
      );
      expect(
        find.text(
          currentAppLocalizations.mitmModuleUnreadableRisk,
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect((await stored()).last.enabled, isFalse);
    });
  }

  group('a change that turns a module off for consent', () {
    Future<void> expectAsked(WidgetTester tester) async {
      expect(
        find.text(currentAppLocalizations.mitmModuleRiskTitle),
        findsOneWidget,
      );
      await tester.tap(find.text(currentAppLocalizations.turnOn));
      await tester.pumpAndSettle();
      final ads = (await stored()).first;
      expect(ads.enabled, isTrue);
      expect(ads.accepted, isTrue);
      expect(container.read(mitmModulesToAgreeProvider), isEmpty);
    }

    testWidgets('asks at once after a manual update', (tester) async {
      await pump(
        tester,
        MitmModuleView(id: _remote.id),
        action: _TurningOff.new,
      );

      await tester.tap(find.text(currentAppLocalizations.update));
      await tester.pumpAndSettle();

      await expectAsked(tester);
    });

    testWidgets('asks at once after a new value', (tester) async {
      await pump(
        tester,
        MitmModuleView(id: _remote.id),
        action: _TurningOff.new,
      );

      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();

      await expectAsked(tester);
    });

    testWidgets('waits on the list until the user declines', (tester) async {
      await pump(tester, const MitmModulesView());
      container
          .read(mitmModulesActionProvider.notifier)
          .putModule(_remote.copyWith(enabled: false, scripts: 1));
      await tester.pumpAndSettle();
      expect(container.read(mitmModulesToAgreeProvider), hasLength(1));

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(currentAppLocalizations.cancel));
      await tester.pumpAndSettle();

      expect((await stored()).first.enabled, isFalse);
      expect((await stored()).first.accepted, isFalse);
      expect(container.read(mitmModulesToAgreeProvider), isEmpty);
    });
  });

  testWidgets('the details show what the module adds and leaves out', (
    tester,
  ) async {
    await pump(tester, MitmModuleView(id: _remote.id));

    expect(find.text('Rewrites samples'), findsOneWidget);
    expect(find.text('Toggle'), findsOneWidget);
    expect(find.text(MitmList.hostname.label), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.invalidOfCount(1, 2)),
      findsOneWidget,
    );

    await tester.tap(find.text(currentAppLocalizations.mitmIgnoredLines));
    await tester.pumpAndSettle();

    expect(find.text('hijack-dns = 8.8.8.8:53'), findsOneWidget);
    expect(find.text(currentAppLocalizations.mitmSkipSetting), findsOneWidget);
  });

  testWidgets('the details list the network settings it changes', (
    tester,
  ) async {
    await pump(tester, MitmModuleView(id: _remote.id));

    expect(
      find.text(currentAppLocalizations.mitmNetworkChanges),
      findsOneWidget,
    );
    expect(find.text(currentAppLocalizations.bypassDomain), findsOneWidget);
    expect(
      find.text(
        '${currentAppLocalizations.mitmChangeReplace('example.com')}\n'
        '${currentAppLocalizations.mitmChangeOverridesYours}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the network settings stay listed when a later module cannot '
      'be read', (tester) async {
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      modules: [_remote, _local.copyWith(enabled: true, accepted: true)],
      localContent: () => Future.error(StateError('unreadable')),
    );

    expect(find.text(currentAppLocalizations.bypassDomain), findsOneWidget);
  });

  testWidgets('a cron script runs from its menu and shows what it wrote', (
    tester,
  ) async {
    final mocks = coreMocks();
    final run = Completer<Object?>();
    when(
      () => mocks.api.runMitmScript('Daily', guard: any(named: 'guard')),
    ).thenAnswer((_) => run.future);
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      core: mocks.controller,
      remoteContent: moduleDetails(
        _module,
        _read(
          views: {
            'script': [
              lineEntry(
                13,
                const MitmLineView.script(
                  name: 'Sample',
                  kind: 'httpResponse',
                  pattern: r'^https://example\.com/b',
                ),
              ),
              lineEntry(
                14,
                const MitmLineView.script(
                  name: 'Daily',
                  kind: 'cron',
                  cronexp: '0 8 * * *',
                ),
              ),
            ],
          },
        ),
      ),
    );
    container.listen(patchClashConfigProvider, (_, _) {});
    container.read(patchClashConfigProvider.notifier).value =
        const PatchClashConfig(mitm: Mitm(enable: true));

    await tester.tap(find.text(MitmList.script.label));
    await tester.pumpAndSettle();
    await tester.longPress(find.text('Sample'));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.mitmRunScript), findsNothing);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Daily'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.mitmRunScript));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ActivityIndicator), findsOneWidget);
    await tester.longPress(find.text('Daily'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(currentAppLocalizations.mitmRunScript), findsNothing);

    run.complete({
      'logs': ['checked in'],
      'result': '{"title":"Points","content":"+3"}',
    });
    await tester.pumpAndSettle();

    verify(
      () => mocks.api.runMitmScript('Daily', guard: any(named: 'guard')),
    ).called(1);
    expect(find.byType(ActivityIndicator), findsNothing);
    expect(
      find.text('Points\n+3\nchecked in', findRichText: true),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('routing rules read like the rule pages and stay read-only', (
    tester,
  ) async {
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      remoteContent: moduleDetails(
        '',
        moduleRead(
          rules: [
            moduleRule(1, 'DOMAIN-SUFFIX,ads.example.com', 'REJECT'),
            moduleRule(2, 'IP-CIDR,10.0.0.0/8', 'DIRECT', noResolve: true),
            moduleRule(
              3,
              'DOMAIN,proxied.example.com',
              'PROXY',
              builtin: false,
            ),
            moduleRule(4, 'PROTOCOL,UDP', 'REJECT'),
            moduleRule(5, 'RULE-SET,mitm-0123456789ab', 'REJECT'),
            moduleRule(6, 'SCRIPT,pick', 'PROXY', requiresResolve: true),
          ],
          ruleSets: const [
            {
              'name': 'mitm-0123456789ab',
              'domain': false,
              'source': {
                'type': 'url',
                'url': 'https://example.com/sample.list',
              },
            },
          ],
        ),
      ),
    );
    final l10n = currentAppLocalizations;
    expect(find.text(l10n.invalidOfCount(1, 6)), findsOneWidget);

    await tester.tap(find.text(l10n.mitmRoutingRules));
    await tester.pumpAndSettle();

    expect(find.byType(RuleItem), findsNWidgets(4));
    for (final (action, content, target) in [
      (RuleAction.DOMAIN_SUFFIX, 'ads.example.com', 'REJECT'),
      (RuleAction.IP_CIDR, '10.0.0.0/8', 'DIRECT'),
      (RuleAction.DOMAIN, 'proxied.example.com', 'PROXY'),
      (RuleAction.RULE_SET, 'https://example.com/sample.list', 'REJECT'),
    ]) {
      final row = find.ancestor(
        of: find.text(content),
        matching: find.byType(RuleItem),
      );
      expect(
        find.descendant(of: row, matching: find.text(action.name)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text(target)),
        findsOneWidget,
      );
      expect(tester.getSize(row).height, ruleItemHeight);
    }

    final colorScheme = tester.element(find.byType(RuleItem).first).colorScheme;
    Color? colorOf(String target) =>
        tester.widget<Text>(find.text(target).first).style?.color;
    expect(colorOf('REJECT'), colorScheme.warning);
    expect(colorOf('DIRECT'), colorScheme.success);
    expect(colorOf('PROXY'), colorScheme.tertiary);

    expect(find.text('PROTOCOL,UDP,REJECT'), findsOneWidget);
    expect(
      tester
          .widget<DecorationListItem>(
            find.ancestor(
              of: find.text('SCRIPT,pick,PROXY,requires-resolve'),
              matching: find.byType(DecorationListItem),
            ),
          )
          .invalid,
      isFalse,
    );
    expect(find.text(l10n.mitmSkipRule), findsOneWidget);

    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.text('ads.example.com'));
    await tester.pumpAndSettle();
    expect(find.byType(RuleForm), findsNothing);
    expect(
      find.text('DOMAIN-SUFFIX,ads.example.com,REJECT', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PROTOCOL,UDP,REJECT'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'PROTOCOL,UDP,REJECT\n\n${l10n.mitmSkipRule}',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('routing rules say which ask for extended matching', (
    tester,
  ) async {
    Future<void> show(List<JsonMap> rules) => pump(
      tester,
      MitmModuleView(id: _remote.id),
      remoteContent: moduleDetails('', moduleRead(rules: rules)),
    );
    final note = currentAppLocalizations.mitmExtendedMatchingNote(1);

    await show([
      moduleRule(1, 'DOMAIN-SUFFIX,ads.example.com', 'REJECT'),
      moduleRule(2, 'DOMAIN,a.example.com', 'REJECT', extendedMatching: true),
    ]);
    expect(find.textContaining(note), findsOneWidget);

    await show([moduleRule(1, 'DOMAIN-SUFFIX,ads.example.com', 'REJECT')]);
    expect(find.textContaining(note), findsNothing);
  });

  testWidgets('a line the Core reads shows what it matches and what it does', (
    tester,
  ) async {
    const url = r'^https://example\.com/old https://example.com/new 302';
    const hosts = '*.example.com, -login.example.com:8443, bad host';
    const script = 'Daily = type=cron,cronexp="0 8 * * *",script-path=d.js';
    const mapLocal =
        r'^https://example\.com/a data="a.json" header="X-A:1|X-B:2"';
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      remoteContent: moduleDetails(
        '[URL Rewrite]\n$url\n[MITM]\nhostname = $hosts\n'
        '[Script]\n$script\n[Map Local]\n$mapLocal\n',
        moduleRead(
          issues: {
            'hostname': [lineIssue(4, 'unsupported character')],
          },
          views: {
            'url-rewrite': [
              lineEntry(
                2,
                const MitmLineView.urlRewrite(
                  pattern: r'^https://example\.com/old',
                  action: '302',
                  replacement: 'https://example.com/new',
                ),
              ),
            ],
            'hostname': [
              lineEntry(
                4,
                const MitmLineView.hosts(
                  entries: [
                    MitmHostEntry(host: '*.example.com'),
                    MitmHostEntry(
                      host: 'login.example.com',
                      port: 8443,
                      exclude: true,
                    ),
                  ],
                ),
              ),
            ],
            'script': [
              lineEntry(
                6,
                const MitmLineView.script(
                  name: 'Daily',
                  kind: 'cron',
                  path: 'd.js',
                  cronexp: '0 8 * * *',
                  requiresBody: true,
                  timeoutMs: 1500,
                ),
              ),
              lineEntry(
                7,
                const MitmLineView.script(
                  name: 'Pick',
                  kind: 'dns',
                  path: 'p.js',
                ),
              ),
            ],
            'map-local': [
              lineEntry(
                8,
                const MitmLineView.mapLocal(
                  pattern: r'^https://example\.com/a',
                  dataType: 'file',
                  data: 'a.json',
                  status: 200,
                  headers: [
                    MitmHeader(name: 'X-A', value: '1'),
                    MitmHeader(name: 'X-B', value: '2'),
                  ],
                  contentType: 'application/json',
                ),
              ),
            ],
          },
        ),
      ),
    );
    final l10n = currentAppLocalizations;
    Future<void> back() async {
      globalState.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text(MitmList.urlRewrite.label));
    await tester.pumpAndSettle();
    expect(find.text(r'^https://example\.com/old'), findsOneWidget);
    expect(find.text('→ https://example.com/new'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('302')).style?.color,
      tester.element(find.text('302')).colorScheme.tertiary,
    );
    await tester.tap(find.text(r'^https://example\.com/old'));
    await tester.pumpAndSettle();
    expect(find.text(url, findRichText: true), findsOneWidget);
    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();
    await back();

    await tester.tap(find.text(MitmList.hostname.label));
    await tester.pumpAndSettle();
    const shown = '*.example.com, -login.example.com:8443';
    expect(find.text(shown), findsOneWidget);
    expect(find.text('unsupported character'), findsOneWidget);
    expect(
      tester
          .widget<DecorationListItem>(
            find.ancestor(
              of: find.text(shown),
              matching: find.byType(DecorationListItem),
            ),
          )
          .invalid,
      isFalse,
    );
    await back();

    await tester.tap(find.text(MitmList.script.label));
    await tester.pumpAndSettle();
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('0 8 * * *'), findsOneWidget);
    expect(find.text('d.js'), findsOneWidget);
    expect(find.text('requires-body  timeout 1.5s'), findsOneWidget);
    expect(find.text(l10n.mitmScriptCron), findsOneWidget);
    expect(find.text(l10n.mitmScriptDns), findsOneWidget);
    await back();

    await tester.tap(find.text(MitmList.mapLocal.label));
    await tester.pumpAndSettle();
    expect(find.text(r'^https://example\.com/a'), findsOneWidget);
    expect(find.text('a.json'), findsOneWidget);
    expect(find.text('Content-Type: application/json'), findsOneWidget);
    expect(find.text('X-A: 1  +1'), findsOneWidget);
  });

  testWidgets('a line opens in full, its issue below it', (tester) async {
    await pump(tester, MitmModuleView(id: _remote.id));
    final l10n = currentAppLocalizations;

    await tester.tap(find.text(MitmList.urlRewrite.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text('bad line'));
    await tester.pumpAndSettle();

    expect(
      find.text('bad line\n\nunknown type', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();
    expect(find.text('bad line'), findsOneWidget);
  });

  testWidgets('of two lines alike only the one the Core flags shows it', (
    tester,
  ) async {
    const same = r'^https://example\.com/a _ reject';
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      remoteContent: moduleDetails(
        '#!name=Sample\n[URL Rewrite]\n$same\n$same\n',
        moduleRead(
          issues: {
            'url-rewrite': [lineIssue(4, 'unknown type')],
          },
          views: {
            'url-rewrite': [
              lineEntry(
                3,
                const MitmLineView.urlRewrite(
                  pattern: r'^https://example\.com/a',
                  action: 'reject',
                ),
              ),
            ],
          },
        ),
      ),
    );

    await tester.tap(find.text(MitmList.urlRewrite.label));
    await tester.pumpAndSettle();

    expect(find.text(r'^https://example\.com/a'), findsOneWidget);
    expect(find.text(same), findsOneWidget);
    expect(find.text('unknown type'), findsOneWidget);
  });

  testWidgets('a module the Core cannot read says why', (tester) async {
    await pump(
      tester,
      MitmModuleView(id: _local.id),
      localContent: () => Future.error(
        const CoreMethodException(code: 'core_unavailable', message: ''),
      ),
    );

    expect(
      find.text(currentAppLocalizations.coreUnavailableTip),
      findsOneWidget,
    );
  });

  testWidgets('remote files show their state and download again', (
    tester,
  ) async {
    final mocks = coreMocks();
    when(
      () => mocks.api.fetchMitmModule(name: any(named: 'name')),
    ).thenAnswer((_) async {});
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      core: mocks.controller,
      statuses: {
        '${_remote.id}': MitmModuleStatus.fromJson({
          'name': '${_remote.id}',
          'inForce': true,
          'resources': [
            {'url': 'https://example.com/ads.js', 'state': 'ok'},
            {
              'url': 'https://example.com/daily.js',
              'state': 'failed',
              'error': {'reason': 'http', 'status': 404, 'detail': ''},
            },
            {'url': 'https://example.com/more.js', 'state': 'missing'},
          ],
        }),
      },
    );
    final l10n = currentAppLocalizations;

    expect(find.text(l10n.mitmResourceOk), findsOneWidget);
    expect(find.text(l10n.mitmFetchHttp(404)), findsOneWidget);
    expect(find.text(l10n.mitmResourceMissing), findsOneWidget);

    await tester.tap(find.text(l10n.mitmResourcesFetch));
    await tester.pumpAndSettle();
    verify(() => mocks.api.fetchMitmModule(name: '${_remote.id}')).called(1);
  });

  testWidgets('an argument is saved on the module', (tester) async {
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      action: _SavingArguments.new,
    );

    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();

    expect((await stored()).first.arguments, {'Toggle': 'false'});
  });

  testWidgets('only a local module is edited and takes attachments', (
    tester,
  ) async {
    await pump(tester, MitmModuleView(id: _local.id));

    expect(find.text(currentAppLocalizations.edit), findsOneWidget);
    expect(find.text(currentAppLocalizations.mitmAttachments), findsOneWidget);
    expect(find.text('own.js'), findsOneWidget);
    expect(find.text(currentAppLocalizations.update), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: MitmModuleView(id: _remote.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.edit), findsNothing);
    expect(find.text(currentAppLocalizations.mitmAttachments), findsNothing);
    expect(find.text(currentAppLocalizations.update), findsOneWidget);
  });

  testWidgets('a remote module moves to a URL typed for its source', (
    tester,
  ) async {
    final action = _ChangingUrl();
    await pump(tester, MitmModuleView(id: _remote.id), action: () => action);

    await tester.tap(find.text(_remote.url!));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(EditableText),
      'https://example.com/moved.sgmodule',
    );
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(action.changed, ['https://example.com/moved.sgmodule']);
    expect((await stored()).first.url, 'https://example.com/moved.sgmodule');
  });

  testWidgets('a URL another module has is turned down', (tester) async {
    final action = _ChangingUrl();
    await database.mitmModulesDao.putAll([
      MitmModule(
        id: 3,
        name: 'Other',
        url: 'https://example.com/other.sgmodule',
        lastUpdateTime: DateTime(2026, 10, 24),
        order: 2,
      ).toCompanion(),
    ]);
    await pump(tester, MitmModuleView(id: _remote.id), action: () => action);

    await tester.tap(find.text(_remote.url!));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(EditableText),
      'https://example.com/other.sgmodule',
    );
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(action.changed, isEmpty);
    expect((await stored()).first.url, _remote.url);
  });

  testWidgets('only a remote module offers its URL in the menu', (
    tester,
  ) async {
    await pump(tester, const MitmModulesView());

    await tester.longPress(find.text('Sample'));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.url), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Mine'));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.url), findsNothing);
  });

  testWidgets('removing an attachment asks first', (tester) async {
    await pump(tester, MitmModuleView(id: _local.id));

    await tester.longPress(find.text('own.js'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();
    expect((await stored()).last.resources, _local.resources);

    await tester.longPress(find.text('own.js'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.delete).last);
    await tester.pumpAndSettle();
    expect((await stored()).last.resources, isEmpty);
  });

  testWidgets('an install link resolves to the module it names', (
    tester,
  ) async {
    await pump(tester, const MitmModulesView());
    final l10n = currentAppLocalizations;

    await tester.tap(find.byTooltip(l10n.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.importUrl));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(EditableText),
      'surge:///install-module?url=${Uri.encodeComponent(_remote.url!)}',
    );
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.existsTip(l10n.mitmModule)), findsOneWidget);
    expect(await stored(), hasLength(2));
  });

  testWidgets('a module can be written from the add menu', (tester) async {
    await pump(tester, const MitmModulesView());

    await tester.tap(find.byTooltip(currentAppLocalizations.add));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.mitmNewModule), findsOneWidget);
  });
}

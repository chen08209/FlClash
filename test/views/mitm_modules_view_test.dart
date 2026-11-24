import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
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

import '../helpers/test_app.dart';

const _module = r'''
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
Sample = type=http-response,pattern=^https://example\.com/b,script-path=https://example.com/sample.js
cron "0 8 * * *" script-path=https://example.com/daily.js, tag=Daily
''';

const _resources = {
  'https://example.com/sample.js': 'sample.js',
  'https://example.com/daily.js': 'daily.js',
};

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

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
    MitmModuleContent? remoteContent,
    Future<MitmModuleContent?> Function()? localContent,
    Map<MitmList, Map<String, String>> issues = const {
      MitmList.urlRewrite: {'bad line': 'unknown type'},
    },
    Map<MitmList, Map<String, MitmLineView>> views = const {},
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await database.mitmModulesDao.putAll([
      _remote.toCompanion(),
      _local.toCompanion(),
    ]);
    final content =
        remoteContent ?? parseMitmModule(_module, resources: _resources);
    container = ProviderContainer(
      overrides: [
        if (core != null) coreHandlerProvider.overrideWithValue(core),
        if (action != null) mitmModulesActionProvider.overrideWith(action),
        mitmModuleContentProvider(
          _remote.id,
        ).overrideWith((ref) async => content),
        mitmModuleContentProvider(
          _local.id,
        ).overrideWith((ref) => localContent?.call() ?? Future.value()),
        mitmModuleDetailsProvider(_remote.id).overrideWith(
          (ref) async => (content: content, issues: issues, views: views),
        ),
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
      localContent: () async => MitmModuleContent(),
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

  for (final (reason, content) in [
    ('is gone', () async => null),
    ('does not parse', () => Future<MitmModuleContent?>.error(Exception())),
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

  testWidgets('a cron script runs from its menu and shows what it wrote', (
    tester,
  ) async {
    final core = _MockCoreHandlerInterface();
    final run = Completer<MitmScriptOutput>();
    when(() => core.runMitmScript('Daily')).thenAnswer((_) => run.future);
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      core: CoreController.scoped(core),
    );
    container.listen(patchClashConfigProvider, (_, _) {});
    container.read(patchClashConfigProvider.notifier).value =
        const PatchClashConfig(mitm: Mitm(enable: true));

    await tester.tap(find.text(MitmList.script.label));
    await tester.pumpAndSettle();
    await tester.longPress(find.textContaining('Sample = '));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.mitmRunScript), findsNothing);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();

    await tester.longPress(find.textContaining('Daily = '));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.mitmRunScript));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ActivityIndicator), findsOneWidget);
    await tester.longPress(find.textContaining('Daily = '));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(currentAppLocalizations.mitmRunScript), findsNothing);

    run.complete(
      const MitmScriptOutput(
        logs: ['checked in'],
        result: '{"title":"Points","content":"+3"}',
      ),
    );
    await tester.pumpAndSettle();

    verify(() => core.runMitmScript('Daily')).called(1);
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
      remoteContent: MitmModuleContent(
        rules: [
          'DOMAIN-SUFFIX,ads.example.com,REJECT',
          'IP-CIDR,10.0.0.0/8,DIRECT,no-resolve',
          'DOMAIN,proxied.example.com,PROXY',
          'PROTOCOL,UDP,REJECT',
          'RULE-SET,mitm-0123456789ab,REJECT',
        ],
        ruleProviders: {
          'mitm-0123456789ab': {
            'type': 'http',
            'url': 'https://example.com/sample.list',
          },
        },
      ),
    );
    final l10n = currentAppLocalizations;
    expect(find.text(l10n.invalidOfCount(1, 5)), findsOneWidget);

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
        find.descendant(of: row, matching: find.text(action.value)),
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

  testWidgets('a line the Core reads shows what it matches and what it does', (
    tester,
  ) async {
    const url = r'^https://example\.com/old https://example.com/new 302';
    const hosts = '*.example.com, -login.example.com:8443, bad host';
    const script = 'Daily = type=cron,cronexp="0 8 * * *",script-path=d.js';
    await pump(
      tester,
      MitmModuleView(id: _remote.id),
      remoteContent: MitmModuleContent(
        urlRewrite: [url],
        hostname: [hosts],
        script: [script],
      ),
      issues: {
        MitmList.hostname: {hosts: 'unsupported character'},
      },
      views: {
        MitmList.urlRewrite: {
          url: const MitmLineView.urlRewrite(
            pattern: r'^https://example\.com/old',
            action: '302',
            replacement: 'https://example.com/new',
          ),
        },
        MitmList.hostname: {
          hosts: const MitmLineView.hosts(
            entries: [
              MitmHostEntry(host: '*.example.com'),
              MitmHostEntry(
                host: 'login.example.com',
                port: 8443,
                exclude: true,
              ),
            ],
          ),
        },
        MitmList.script: {
          script: const MitmLineView.script(
            name: 'Daily',
            kind: 'cron',
            cronexp: '0 8 * * *',
          ),
        },
      },
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
    expect(find.text(l10n.mitmScriptCron), findsOneWidget);
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

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/custom/custom_proxies.dart';
import 'package:fl_clash/views/profiles/custom/rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingRules extends ProfileRules {
  final List<Rule> initial;
  final replaced = <List<Rule>>[];

  _RecordingRules(this.initial);

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void setAll(List<Rule> rules) => replaced.add(rules);
}

class _RecordingCustomProxies extends CustomProxies {
  final List<CustomProxy> initial;
  final saved = <CustomProxy>[];
  final replaced = <List<CustomProxy>>[];

  _RecordingCustomProxies(this.initial);

  @override
  Stream<List<CustomProxy>> build() => Stream.value(initial);

  @override
  void put(CustomProxy proxy) => saved.add(proxy);

  @override
  void setAll(List<CustomProxy> proxies) => replaced.add(proxies);
}

class _MockCore extends Mock implements CoreHandlerInterface {}

class _IdleClashProvidersAction extends ClashProvidersAction {
  @override
  Future<void> applyIfReferenced(
    ProviderKind kind,
    Set<String> labels, {
    bool force = false,
  }) async {}
}

void _setViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// The editor's loading indicator schedules its next morph past unmount.
Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

Future<({EditorPage editor, BuildContext context})> _openEditor(
  WidgetTester tester,
  Finder button,
) async {
  await tester.tap(button);
  await tester.pumpAndSettle();
  return (
    editor: tester.widget<EditorPage>(find.byType(EditorPage)),
    context: tester.element(find.byType(EditorPage)),
  );
}

Finder _menuItem(String label) => find.descendant(
  of: find.byType(CommonPopupMenu),
  matching: find.text(label),
);

Future<({EditorPage editor, BuildContext context})> _openListEditor(
  WidgetTester tester,
) async {
  await tester.tap(find.byTooltip(currentAppLocalizations.add));
  await tester.pumpAndSettle();
  return _openEditor(tester, _menuItem(currentAppLocalizations.quickEdit));
}

void main() {
  setUpAll(() {
    registerFallbackValue(<Map<String, dynamic>>[]);
    registerFallbackValue(<String>[]);
  });

  group('rule list', () {
    Future<_RecordingRules> pumpRules(WidgetTester tester) async {
      _setViewport(tester);
      final profile = Profile.custom();
      final notifier = _RecordingRules([
        Rule.parse('DOMAIN,a.com,DIRECT', id: 1).copyWith(order: '1'),
        Rule.parse('MATCH,DIRECT', id: 2).copyWith(order: '2'),
      ]);
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileRulesProvider.overrideWith2((_) => notifier),
          customProfileDataProvider(
            profile.id,
          ).overrideWithValue(const CustomProfileData(ruleTargets: {'DIRECT'})),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(child: CustomRulesView(profile.id)),
        ),
      );
      await tester.pump();
      return notifier;
    }

    testWidgets('opens every rule as a YAML list and applies it on exit', (
      tester,
    ) async {
      final notifier = await pumpRules(tester);
      final (:editor, :context) = await _openListEditor(tester);

      expect(editor.content, '- DOMAIN,a.com,DIRECT\n- MATCH,DIRECT\n');

      final popped = await editor.onPop!(
        context,
        editor.title,
        '- DOMAIN,b.com,DIRECT\n${editor.content}',
      );

      expect(popped, isTrue);
      final rules = notifier.replaced.single;
      expect(rules.map((rule) => rule.rawValue), [
        'DOMAIN,b.com,DIRECT',
        'DOMAIN,a.com,DIRECT',
        'MATCH,DIRECT',
      ]);
      expect(rules.skip(1).map((rule) => rule.id), [1, 2]);
    });

    testWidgets('drops the SUB-RULE lines', (tester) async {
      final notifier = await pumpRules(tester);
      final (:editor, :context) = await _openListEditor(tester);

      final popped = await editor.onPop!(
        context,
        editor.title,
        '- SUB-RULE,(NETWORK,tcp),streaming\n${editor.content}',
      );

      expect(popped, isTrue);
      expect(notifier.replaced.single.map((rule) => rule.rawValue), [
        'DOMAIN,a.com,DIRECT',
        'MATCH,DIRECT',
      ]);
    });

    testWidgets('names the line of a rule the form would refuse', (
      tester,
    ) async {
      final notifier = await pumpRules(tester);
      final (:editor, :context) = await _openListEditor(tester);

      final popped = editor.onPop!(
        context,
        editor.title,
        '- MATCH,DIRECT\n- DST-PORT,http,DIRECT\n',
      );
      await tester.pump();

      expect(
        find.textContaining(
          currentAppLocalizations.lineIssueTip(
            2,
            currentAppLocalizations.invalidRangeContent,
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(currentAppLocalizations.cancel));
      await tester.pump();
      expect(await popped, isFalse);
      expect(notifier.replaced, isEmpty);
    });

    testWidgets('a single rule has no quick edit of its own', (tester) async {
      await pumpRules(tester);
      await tester.tap(find.byType(RuleItem).first);
      await tester.pumpAndSettle();

      final form = find.byType(NestedFormSheet<Rule>);
      expect(
        find.descendant(
          of: form,
          matching: find.widgetWithText(
            TextButton,
            currentAppLocalizations.save,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: form,
          matching: find.byTooltip(currentAppLocalizations.quickEdit),
        ),
        findsNothing,
      );
    });
  });

  group('custom proxies', () {
    late _MockCore core;

    setUp(() {
      core = _MockCore();
      when(() => core.validateProxies(any())).thenAnswer(
        (invocation) async => [
          for (final _ in invocation.positionalArguments.first as List) '',
        ],
      );
    });

    void decodesTo(Map<String, List<Map<String, dynamic>>> proxiesByLink) {
      when(() => core.decodeShareLinks(any())).thenAnswer(
        (invocation) async => [
          for (final link in invocation.positionalArguments.first as List)
            proxiesByLink[link] ?? const [],
        ],
      );
    }

    Future<_RecordingCustomProxies> pumpProxies(
      WidgetTester tester,
      List<CustomProxy> initial,
    ) async {
      _setViewport(tester);
      final proxies = _RecordingCustomProxies(initial);
      final container = ProviderContainer(
        overrides: [
          coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
          customGroupNamesProvider.overrideWith(
            (_) => Stream.value(const <String>{}),
          ),
          customProxiesProvider.overrideWith(() => proxies),
          clashProvidersActionProvider.overrideWith(
            _IdleClashProvidersAction.new,
          ),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(500, 1000));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: CustomProxiesView()),
        ),
      );
      await tester.pump();
      return proxies;
    }

    CustomProxy readForm(WidgetTester tester) {
      return ProviderScope.containerOf(
        tester.element(
          find.byType(NestedFormSheet<CustomProxy>, skipOffstage: false),
        ),
      ).read(customProxyProvider);
    }

    Finder formQuickEdit() => find.descendant(
      of: find.byType(NestedFormSheet<CustomProxy>),
      matching: find.byTooltip(currentAppLocalizations.quickEdit),
    );

    Finder linkField() => find.descendant(
      of: find.byType(CommonDialog),
      matching: find.byType(TextField),
    );

    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(find.text(currentAppLocalizations.confirm));
      await tester.pumpAndSettle();
    }

    testWidgets('the list edits every proxy as share links in the editor and '
        'keeps the ones whose link is unchanged', (tester) async {
      const home = CustomProxy(
        id: 1,
        definition: {'name': 'Home', 'type': 'ss', 'server': 'a.example'},
      );
      const wireGuard = CustomProxy(
        id: 2,
        definition: {'name': 'WG', 'type': 'wireguard'},
      );
      when(
        () => core.encodeShareLinks(any()),
      ).thenAnswer((_) async => ['ss://home#Home', '']);
      decodesTo({
        'vless://new#New': [
          {'name': 'New', 'type': 'vless', 'server': 'n.example', 'port': 1},
        ],
      });
      final proxies = await pumpProxies(tester, const [home, wireGuard]);
      final (:editor, :context) = await _openListEditor(tester);

      expect(editor.content, 'ss://home#Home');

      final popped = await editor.onPop!(
        context,
        editor.title,
        'ss://home#Home\nvless://new#New',
      );

      expect(popped, isTrue);
      final next = proxies.replaced.single;
      expect(next.map((proxy) => proxy.name), ['Home', 'WG', 'New']);
      expect(next.take(2), [home, wireGuard]);
      verify(() => core.decodeShareLinks(['vless://new#New'])).called(1);

      await _unmount(tester);
    });

    testWidgets('a renamed line asks before it drops the proxy it replaces', (
      tester,
    ) async {
      const home = CustomProxy(
        id: 1,
        definition: {'name': 'Home', 'type': 'ss', 'server': 'a.example'},
      );
      when(
        () => core.encodeShareLinks(any()),
      ).thenAnswer((_) async => ['ss://home#Home']);
      decodesTo({
        'ss://home#Away': [
          {'name': 'Away', 'type': 'ss', 'server': 'a.example'},
        ],
      });
      final proxies = await pumpProxies(tester, const [home]);
      final (:editor, :context) = await _openListEditor(tester);
      final prompt = currentAppLocalizations.proxiesReplacedTip('Home', 'Away');

      var popped = editor.onPop!(context, editor.title, 'ss://home#Away');
      await tester.pumpAndSettle();
      expect(find.text(prompt), findsOneWidget);
      await tester.tap(find.text(currentAppLocalizations.cancel));
      await tester.pumpAndSettle();
      expect(await popped, isFalse);
      expect(proxies.replaced, isEmpty);

      popped = editor.onPop!(context, editor.title, 'ss://home#Away');
      await tester.pumpAndSettle();
      await tester.tap(find.text(currentAppLocalizations.confirm));
      await tester.pumpAndSettle();
      expect(await popped, isTrue);
      expect(proxies.replaced.single.map((proxy) => proxy.name), ['Away']);

      await _unmount(tester);
    });

    testWidgets('a line the core cannot read is named and nothing is stored', (
      tester,
    ) async {
      when(() => core.encodeShareLinks(any())).thenAnswer((_) async => []);
      decodesTo({});
      final proxies = await pumpProxies(tester, const []);
      final (:editor, :context) = await _openListEditor(tester);

      final popped = editor.onPop!(context, editor.title, '\nhello');
      await tester.pump();
      await tester.pump();

      expect(
        find.textContaining(
          currentAppLocalizations.lineIssueTip(
            2,
            currentAppLocalizations.shareLinksInvalid,
          ),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text(currentAppLocalizations.cancel));
      await tester.pump();
      expect(await popped, isFalse);
      expect(proxies.replaced, isEmpty);

      await _unmount(tester);
    });

    testWidgets('a new proxy fills its form from a link in quick edit', (
      tester,
    ) async {
      when(() => core.encodeShareLinks(any())).thenAnswer((_) async => ['']);
      decodesTo({
        'vless://u-1@b.example:443': [
          {
            'name': '',
            'type': 'vless',
            'server': 'b.example',
            'port': 443,
            'uuid': 'u-1',
          },
        ],
        'c3M6Ly9h': [
          {'name': 'a', 'type': 'ss'},
          {'name': 'b', 'type': 'ss'},
        ],
      });
      await pumpProxies(tester, const []);
      await tester.tap(find.byTooltip(currentAppLocalizations.add));
      await tester.pumpAndSettle();
      await tester.tap(_menuItem(currentAppLocalizations.add));
      await tester.pumpAndSettle();
      await tester.tap(formQuickEdit());
      await tester.pumpAndSettle();

      expect(find.byType(EditorPage), findsNothing);
      expect(tester.widget<TextField>(linkField()).controller!.text, isEmpty);

      await tester.enterText(linkField(), 'c3M6Ly9h');
      await confirm(tester);
      expect(
        find.text(currentAppLocalizations.singleShareLinkOnly),
        findsOneWidget,
      );

      await tester.enterText(linkField(), ' vless://u-1@b.example:443\n');
      await confirm(tester);

      expect(find.byType(CommonDialog), findsNothing);
      expect(readForm(tester).id, -1);
      expect(readForm(tester).definition, {
        'name': 'b.example',
        'type': 'vless',
        'server': 'b.example',
        'port': 443,
        'uuid': 'u-1',
      });
      expect(find.text('u-1'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('an existing proxy opens its own link, keeps itself when the '
        'link is left alone, and keeps its name for a link without one', (
      tester,
    ) async {
      const mine = CustomProxy(
        id: 1,
        definition: {
          'name': 'Mine',
          'type': 'socks5',
          'server': 'a.example',
          'port': 1080,
          'dialer-proxy': 'Relay',
        },
      );
      when(
        () => core.encodeShareLinks(any()),
      ).thenAnswer((_) async => ['socks5://a.example:1080#Mine']);
      decodesTo({
        'trojan://pw@c.example:443': [
          {
            'name': '',
            'type': 'trojan',
            'server': 'c.example',
            'port': 443,
            'password': 'pw',
          },
        ],
      });
      await pumpProxies(tester, const [mine]);
      await tester.tap(find.text('Mine'));
      await tester.pumpAndSettle();
      await tester.tap(formQuickEdit());
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(linkField()).controller!.text,
        'socks5://a.example:1080#Mine',
      );
      await confirm(tester);

      expect(find.byType(CommonDialog), findsNothing);
      expect(readForm(tester), mine);
      verifyNever(() => core.decodeShareLinks(any()));

      await tester.tap(formQuickEdit());
      await tester.pumpAndSettle();
      await tester.enterText(linkField(), 'trojan://pw@c.example:443');
      await confirm(tester);

      expect(readForm(tester).id, 1);
      expect(readForm(tester).definition, {
        'name': 'Mine',
        'type': 'trojan',
        'server': 'c.example',
        'port': 443,
        'password': 'pw',
      });

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the form asks for the credentials its type reads', (
      tester,
    ) async {
      final proxies = await pumpProxies(tester, const [
        CustomProxy(
          id: 1,
          definition: {
            'name': 'Sock',
            'type': 'socks5',
            'server': 'a.example',
            'port': 1080,
            'username': 'me',
          },
        ),
      ]);
      await tester.tap(find.text('Sock'));
      await tester.pumpAndSettle();
      final password = find.descendant(
        of: find.widgetWithText(FormRow, currentAppLocalizations.password),
        matching: find.byType(EditableText),
      );

      expect(find.text('me'), findsOneWidget);
      expect(find.text('UUID'), findsNothing);
      expect(tester.widget<EditableText>(password).obscureText, isTrue);

      await tester.ensureVisible(
        find.byTooltip(currentAppLocalizations.showPassword),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(currentAppLocalizations.showPassword));
      await tester.pump();
      expect(tester.widget<EditableText>(password).obscureText, isFalse);

      await tester.enterText(password, 'secret');
      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      expect(
        proxies.saved.single.definition,
        allOf(
          containsPair('username', 'me'),
          containsPair('password', 'secret'),
        ),
      );
    });

    testWidgets('a vmess proxy asks for a UUID and no password', (
      tester,
    ) async {
      await pumpProxies(tester, const [
        CustomProxy(id: 1, definition: {'name': 'Vm', 'type': 'vmess'}),
      ]);
      await tester.tap(find.text('Vm'));
      await tester.pumpAndSettle();

      expect(find.text('UUID'), findsOneWidget);
      expect(find.text(currentAppLocalizations.password), findsNothing);
      expect(find.text(currentAppLocalizations.username), findsNothing);
    });

    testWidgets('the form picks the values a type requires and adds the '
        'options it reads one at a time', (tester) async {
      final proxies = await pumpProxies(tester, const [
        CustomProxy(
          id: 1,
          definition: {
            'name': 'Ss',
            'type': 'ss',
            'server': 'a.example',
            'port': 8388,
            'password': 'pw',
          },
        ),
      ]);
      tester.view.physicalSize = const Size(1400, 2600);
      final l10n = currentAppLocalizations;
      Finder row(String title) =>
          find.ancestor(of: find.text(title), matching: find.byType(FormRow));
      Finder offered(String title) => find.descendant(
        of: find.byWidgetPredicate((widget) => widget is SelectionSheet),
        matching: find.text(title),
      );
      Future<void> tapRow(String title) async {
        await tester.ensureVisible(row(title).first);
        await tester.tap(row(title).first);
        await tester.pumpAndSettle();
      }

      Future<void> add(String title) async {
        await tapRow(l10n.addSettingEntry);
        await tester.tap(offered(title));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Ss'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: row(l10n.cipher),
          matching: find.text(l10n.required),
        ),
        findsOneWidget,
      );
      await tapRow(l10n.cipher);
      await tester.tap(find.text('aes-256-gcm'));
      await tester.pumpAndSettle();
      expect(readForm(tester).definition['cipher'], 'aes-256-gcm');

      await tapRow(l10n.addSettingEntry);
      expect(offered('UDP over TCP'), findsOneWidget);
      expect(offered(l10n.network), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await add('UDP over TCP');
      expect(readForm(tester).definition['udp-over-tcp'], isTrue);

      await tapRow(l10n.proxyType);
      await tester.tap(find.text('vless'));
      await tester.pumpAndSettle();
      expect(row(l10n.cipher), findsNothing);
      expect(row('UDP over TCP'), findsNothing);
      expect(
        readForm(tester).definition.keys,
        isNot(anyOf(contains('cipher'), contains('udp-over-tcp'))),
      );

      await add(l10n.network);
      expect(readForm(tester).definition['network'], 'tcp');
      await tapRow(l10n.addSettingEntry);
      expect(offered('WebSocket Path'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapRow(l10n.network);
      await tester.tap(find.text('ws'));
      await tester.pumpAndSettle();
      expect(row('WebSocket Path'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: row('WebSocket Host'),
          matching: find.byType(EditableText),
        ),
        'cdn.example',
      );
      expect(readForm(tester).definition['ws-opts'], {
        'headers': {'Host': 'cdn.example'},
      });

      await tapRow(l10n.network);
      await tester.tap(find.text('grpc'));
      await tester.pumpAndSettle();
      expect(row('WebSocket Host'), findsNothing);
      expect(readForm(tester).definition.containsKey('ws-opts'), isFalse);
      await tester.tap(
        find.descendant(
          of: row('gRPC Service Name'),
          matching: find.byTooltip(l10n.remove),
        ),
      );
      await tester.pumpAndSettle();
      expect(row('gRPC Service Name'), findsNothing);

      await tester.tap(find.byTooltip(l10n.save));
      await tester.pumpAndSettle();
      expect(
        proxies.saved.single.definition,
        allOf(
          containsPair('type', 'vless'),
          containsPair('network', 'grpc'),
          isNot(contains('ws-opts')),
        ),
      );
    });

    testWidgets('an option emptied after holding a value is dropped on save', (
      tester,
    ) async {
      const definition = {
        'name': 'Gate',
        'type': 'trojan',
        'server': 'a.example',
        'port': 443,
        'password': 'pw',
      };
      final proxies = await pumpProxies(tester, const [
        CustomProxy(
          id: 1,
          definition: {...definition, 'sni': 'b.example'},
          emptyOptions: {ProxyField.alpn},
        ),
      ]);
      tester.view.physicalSize = const Size(1400, 2600);
      Finder row(String title) =>
          find.ancestor(of: find.text(title), matching: find.byType(FormRow));

      await tester.tap(find.text('Gate'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(of: row('SNI'), matching: find.byType(EditableText)),
        '',
      );
      await tester.pump();
      expect(row('SNI'), findsOneWidget);
      await tester.tap(find.byTooltip(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      expect(proxies.saved.single.definition, definition);
      expect(proxies.saved.single.emptyOptions, {ProxyField.alpn});
    });

    testWidgets('options added without a value stay after reopening and a '
        'link edit, which keeps what the link cannot carry', (tester) async {
      const titles = ['SNI', 'ALPN'];
      const definition = {
        'name': 'Gate',
        'type': 'trojan',
        'server': 'a.example',
        'port': 443,
        'password': 'pw',
        'tfo': true,
      };
      final linked = {...definition}..remove('tfo');
      Finder row(String title) =>
          find.ancestor(of: find.text(title), matching: find.byType(FormRow));
      Future<_RecordingCustomProxies> open(List<CustomProxy> initial) async {
        final proxies = await pumpProxies(tester, initial);
        tester.view.physicalSize = const Size(1400, 2600);
        await tester.tap(find.text('Gate'));
        await tester.pumpAndSettle();
        return proxies;
      }

      final proxies = await open(const [
        CustomProxy(id: 1, definition: definition),
      ]);
      final l10n = currentAppLocalizations;
      for (final title in titles) {
        await tester.ensureVisible(row(l10n.addSettingEntry).first);
        await tester.tap(row(l10n.addSettingEntry).first);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byWidgetPredicate((widget) => widget is SelectionSheet),
            matching: find.text(title),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byTooltip(l10n.save));
      await tester.pumpAndSettle();

      final saved = proxies.saved.single;
      expect(saved.definition, definition);
      expect(saved.emptyOptions, {ProxyField.sni, ProxyField.alpn});

      await tester.pumpWidget(const SizedBox.shrink());
      await open([saved]);
      for (final title in titles) {
        expect(row(title), findsOneWidget, reason: title);
      }

      when(
        () => core.encodeShareLinks(any()),
      ).thenAnswer((_) async => ['trojan://pw@a.example:443#Gate']);
      decodesTo({
        'trojan://pw@b.example:443#Gate': [
          {...linked, 'server': 'b.example'},
        ],
        'trojan://pw@a.example:443#Gate': [linked],
      });
      await tester.tap(formQuickEdit());
      await tester.pumpAndSettle();
      await tester.enterText(linkField(), 'trojan://pw@b.example:443#Gate');
      await confirm(tester);

      expect(readForm(tester).definition, {
        ...definition,
        'server': 'b.example',
      });
      for (final title in titles) {
        expect(row(title), findsOneWidget, reason: title);
      }

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

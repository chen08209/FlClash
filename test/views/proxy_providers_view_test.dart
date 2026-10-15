import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' hide context;

import '../helpers/context_menu.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../plugins/code_forge/support.dart' show initEditorNative;

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _ProvidersSection extends ConsumerWidget {
  const _ProvidersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ExternalProvidersSliver(providers: ref.watch(providersProvider)),
        ],
      ),
    );
  }
}

ExternalProvider _provider(
  String name, {
  String type = 'Proxy',
  String vehicleType = 'HTTP',
  int count = 3,
  DateTime? updateAt,
  SubscriptionInfo? subscriptionInfo,
  String? path,
}) {
  return ExternalProvider(
    name: name,
    type: type,
    count: count,
    vehicleType: vehicleType,
    updateAt: updateAt ?? DateTime.utc(2026, 1, 1),
    subscriptionInfo: subscriptionInfo,
    path: path,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCoreHandlerInterface core;
  late Directory home;

  setUpAll(() async {
    await initEditorNative();
    core = _MockCoreHandlerInterface();
    home = Directory.systemTemp.createTempSync('flclash-providers-');
  });

  setUp(() => reset(core));

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  File providerFile(String name, String content) {
    return File(join(home.path, '$name.yaml'))..writeAsStringSync(content);
  }

  ProviderContainer containerFor(
    WidgetTester tester,
    List<ExternalProvider> providers,
  ) {
    const size = Size(1400, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);
    // providersProvider is autoDispose; hold a listener so the seeded list
    // survives until the widget subscribes.
    final subscription = container.listen(
      providersProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    container.read(providersProvider.notifier).value = providers;
    return container;
  }

  Future<void> pump(
    WidgetTester tester,
    ProviderContainer container, {
    bool withStatusManager = false,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          withStatusManager: withStatusManager,
          child: const _ProvidersSection(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester, String name) async {
    await rightClick(tester, find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> closeMenu(WidgetTester tester) async {
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
  }

  Future<void> settleTrailing(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  // The editor blinks its caret for as long as it is open, so a page holding
  // it never settles.
  Future<void> pumpTransitions(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  // Reading and writing the provider file runs on the real event loop,
  // outside fake-async, so pump in rounds until the flow it feeds arrives.
  Future<void> pumpUntil(
    WidgetTester tester,
    Finder finder, {
    bool found = true,
  }) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty == found) {
        await pumpTransitions(tester);
        return;
      }
    }
    fail('timed out waiting for $finder to be ${found ? 'shown' : 'gone'}');
  }

  // A row probes its file on the real event loop before it offers edit.
  Future<void> openMenuWithEdit(WidgetTester tester, String name) async {
    for (var i = 0; i < 100; i++) {
      await openMenu(tester, name);
      if (find.text(currentAppLocalizations.edit).evaluate().isNotEmpty) {
        return;
      }
      await closeMenu(tester);
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();
    }
    fail('$name never offered the edit entry');
  }

  Future<EditorPage> openEditor(WidgetTester tester, String name) async {
    await openMenuWithEdit(tester, name);
    await tester.tap(find.text(currentAppLocalizations.edit));
    await pumpUntil(
      tester,
      find.byWidgetPredicate(
        (widget) => widget is EditorView && widget.content?.isNotEmpty == true,
      ),
    );
    return tester.widget<EditorPage>(find.byType(EditorPage));
  }

  testWidgets('lists proxy and rule providers under one header', (
    tester,
  ) async {
    final container = containerFor(tester, [
      _provider('proxy-a'),
      _provider('rule-a', type: 'Rule'),
    ]);
    await pump(tester, container);

    expect(find.byType(ListHeader), findsOne);
    expect(
      find.widgetWithText(ListHeader, currentAppLocalizations.providers),
      findsOne,
    );
    expect(find.text('proxy-a'), findsOne);
    expect(find.text('rule-a'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('builds only the rows in view', (tester) async {
    final providers = List.generate(50, (i) => _provider('proxy-$i'));
    final container = containerFor(tester, providers);
    await pump(tester, container);

    expect(find.byType(SliverList), findsOneWidget);
    expect(find.text('proxy-0'), findsOneWidget);
    expect(find.text('proxy-49'), findsNothing);
  });

  testWidgets('shows a subscription expiry beside the name', (tester) async {
    final container = containerFor(tester, [
      _provider('without-expiry'),
      _provider(
        'with-expiry',
        subscriptionInfo: SubscriptionInfo(
          total: 100,
          expire: DateTime(2099).millisecondsSinceEpoch ~/ 1000,
        ),
      ),
    ]);
    await pump(tester, container);

    expect(find.byType(ExpireChip), findsOne);
    expect(
      find.ancestor(
        of: find.byType(ExpireChip),
        matching: find.widgetWithText(ChipTitle, 'with-expiry'),
      ),
      findsOne,
    );
  });

  testWidgets('puts the compact count below the name and the time at the end', (
    tester,
  ) async {
    final container = containerFor(tester, [
      _provider('proxy-with-count', count: 7),
      _provider('rule-with-count', type: 'Rule', count: 9),
      _provider('proxy-with-many', count: 12345),
      _provider('rule-with-many', type: 'Rule', count: 2500000),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    final updated = DateTime.utc(2026, 1, 1).getLastUpdateTimeDesc(
      tester.element(find.text('proxy-with-count')),
      compact: true,
    );
    expect(find.text(updated), findsNWidgets(4));
    for (final (name, count) in [
      ('proxy-with-count', l10n.proxiesCount(7, '7')),
      ('rule-with-count', l10n.rulesCount(9, '9')),
      ('proxy-with-many', l10n.proxiesCount(12345, '12.3K')),
      ('rule-with-many', l10n.rulesCount(2500000, '2.5M')),
    ]) {
      final row = find.ancestor(
        of: find.text(name),
        matching: find.byType(DecorationListItem),
      );
      final subtitle = find.descendant(of: row, matching: find.text(count));
      final time = find.descendant(of: row, matching: find.text(updated));
      expect(
        tester.getTopLeft(subtitle).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.text(name)).dy),
      );
      expect(
        tester.getTopLeft(time).dx,
        greaterThan(tester.getTopRight(find.text(name)).dx),
      );
      expect(
        tester.getCenter(time).dy,
        moreOrLessEquals(tester.getCenter(row).dy, epsilon: 1),
      );
    }
    expect(find.byType(TonalChip), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('offers sync only for HTTP-backed providers', (tester) async {
    final container = containerFor(tester, [
      _provider('http-one'),
      _provider('file-one', vehicleType: 'File'),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    await openMenu(tester, 'http-one');
    expect(find.text(l10n.upload), findsOne);
    expect(find.text(l10n.sync), findsOne);
    await closeMenu(tester);

    await openMenu(tester, 'file-one');
    expect(find.text(l10n.upload), findsOne);
    expect(find.text(l10n.sync), findsNothing);
  });

  testWidgets('offers subscription info only when the provider has one', (
    tester,
  ) async {
    final container = containerFor(tester, [
      _provider(
        'with-subscription',
        subscriptionInfo: const SubscriptionInfo(
          upload: 1,
          download: 2,
          total: 100,
        ),
      ),
      _provider('without-subscription'),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.byType(SubscriptionInfoView), findsNothing);

    await openMenu(tester, 'with-subscription');
    expect(find.text(l10n.subscriptionInfo), findsOne);
    await closeMenu(tester);

    await openMenu(tester, 'without-subscription');
    expect(find.text(l10n.subscriptionInfo), findsNothing);
  });

  testWidgets('the subscription info item opens the usage dialog', (
    tester,
  ) async {
    final container = containerFor(tester, [
      _provider(
        'with-subscription',
        subscriptionInfo: const SubscriptionInfo(
          upload: 1,
          download: 2,
          total: 100,
        ),
      ),
    ]);
    await pump(tester, container);

    await openMenu(tester, 'with-subscription');
    await tester.tap(find.text(currentAppLocalizations.subscriptionInfo));
    await tester.pumpAndSettle();

    expect(find.byType(SubscriptionInfoDetailView), findsOne);
  });

  testWidgets('shows a spinner and holds back the menu while updating', (
    tester,
  ) async {
    final provider = _provider('http-one');
    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    expect(find.byType(CommonCircleLoading), findsNothing);

    final updating = container.read(updatingKeysProvider.notifier);
    updating.start(provider.updatingKey);
    await settleTrailing(tester);
    await rightClick(tester, find.text('http-one'));
    await settleTrailing(tester);

    expect(find.byType(CommonCircleLoading), findsOne);
    expect(find.byType(CommonPopupMenu), findsNothing);
  });

  testWidgets('keeps loading state for virtualized offscreen rows', (
    tester,
  ) async {
    final providers = List.generate(50, (i) => _provider('proxy-$i'));
    final offscreenProvider = providers.last;
    final container = containerFor(tester, providers);
    await pump(tester, container);

    expect(find.text(offscreenProvider.name), findsNothing);

    final updating = container.read(updatingKeysProvider.notifier);
    final operation = updating.start(offscreenProvider.updatingKey);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text(offscreenProvider.name),
      500,
      scrollable: find.byType(Scrollable),
    );
    await settleTrailing(tester);

    final providerRow = find.ancestor(
      of: find.text(offscreenProvider.name),
      matching: find.byType(DecorationListItem),
    );
    expect(
      find.descendant(
        of: providerRow,
        matching: find.byType(CommonCircleLoading),
      ),
      findsOneWidget,
    );

    updating.stop(offscreenProvider.updatingKey, operation);
    await tester.pump();
  });

  testWidgets('the header action refreshes every provider', (tester) async {
    final container = containerFor(tester, [
      _provider('proxy-a'),
      _provider('rule-a', type: 'Rule'),
    ]);
    final completer = Completer<String>();
    when(
      () => core.updateExternalProvider('proxy-a'),
    ).thenAnswer((_) => completer.future);
    when(
      () => core.updateExternalProvider('rule-a'),
    ).thenAnswer((_) async => '');
    when(() => core.getExternalProvider(any())).thenAnswer(
      (invocation) async =>
          _provider(invocation.positionalArguments.first as String),
    );
    when(
      () => core.getProxies(),
    ).thenAnswer((_) async => const ProxiesData(proxies: {}, all: []));
    await pump(tester, container);

    await tester.tap(find.byGlyph(AppGlyphs.sync));
    await tester.pump();

    final header = find.byType(ListHeader);
    final pendingRow = find.ancestor(
      of: find.text('proxy-a'),
      matching: find.byType(DecorationListItem),
    );
    for (final pending in [header, pendingRow]) {
      expect(
        find.descendant(
          of: pending,
          matching: find.byType(CommonCircleLoading),
        ),
        findsOne,
      );
    }
    await tester.tap(find.byTooltip(currentAppLocalizations.update));
    await tester.pump();

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(CommonCircleLoading), findsNothing);
    expect(find.byGlyph(AppGlyphs.sync), findsOne);
    verify(() => core.updateExternalProvider('proxy-a')).called(1);
    verify(() => core.updateExternalProvider('rule-a')).called(1);
  });

  testWidgets('the header action classifies Core request failures', (
    tester,
  ) async {
    final container = containerFor(tester, [_provider('proxy-a')]);
    when(() => core.updateExternalProvider('proxy-a')).thenThrow(
      const CoreMethodException(
        code: 'request_bad_response',
        message: '503 Service Unavailable',
      ),
    );
    when(
      () => core.getProxies(),
    ).thenAnswer((_) async => const ProxiesData(proxies: {}, all: []));
    await pump(tester, container, withStatusManager: true);

    await tester.tap(find.byGlyph(AppGlyphs.sync));
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    expect(
      find.text(l10n.failedItem('proxy-a', l10n.networkServerError(503))),
      findsOneWidget,
    );
    expect(find.textContaining('503 Service Unavailable'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('offers edit only for providers backed by a text file', (
    tester,
  ) async {
    final mrs = File(join(home.path, 'compressed.mrs'))
      ..writeAsBytesSync([0x28, 0xB5, 0x2F, 0xFD, 0x00, 0x01]);
    final container = containerFor(tester, [
      _provider(
        'with-file',
        path: providerFile('with-file', 'payload:\n').path,
      ),
      _provider('compressed', type: 'Rule', path: mrs.path),
      _provider('without-file'),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    // The text row offering edit proves every row has finished probing.
    await openMenuWithEdit(tester, 'with-file');
    expect(find.text(l10n.upload), findsOne);
    await closeMenu(tester);
    expect(find.byGlyph(AppGlyphs.edit), findsNothing);
    expect(find.byType(DisclosureIndicator), findsNothing);

    await openMenu(tester, 'compressed');
    expect(find.text(l10n.edit), findsNothing);
    expect(find.text(l10n.upload), findsOne);
    await closeMenu(tester);

    await openMenu(tester, 'without-file');
    expect(find.text(l10n.edit), findsNothing);
  });

  testWidgets('the edit item opens the provider file and side-loads it', (
    tester,
  ) async {
    final file = providerFile('editable', 'payload:\n  - old\n');
    final provider = _provider('editable', path: file.path);
    when(
      () => core.sideLoadExternalProvider(
        providerName: 'editable',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => '');
    when(
      () => core.getExternalProvider('editable'),
    ).thenAnswer((_) async => provider);
    when(
      () => core.getProxies(),
    ).thenAnswer((_) async => const ProxiesData(proxies: {}, all: []));

    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    final editor = await openEditor(tester, 'editable');
    expect(
      tester.widget<EditorView>(find.byType(EditorView)).content,
      'payload:\n  - old\n',
    );

    editor.onSave!(
      tester.element(find.byType(EditorPage)),
      'editable',
      'payload:\n  - new\n',
    );
    await pumpUntil(tester, find.byType(EditorPage), found: false);

    expect(file.readAsStringSync(), 'payload:\n  - new\n');
    verify(
      () => core.sideLoadExternalProvider(
        providerName: 'editable',
        data: 'payload:\n  - new\n',
      ),
    ).called(1);
    expect(find.byType(EditorPage), findsNothing);

    await tester.pump(const Duration(milliseconds: 700));
  });

  testWidgets('a text-backed row previews on tap and edits from its menu', (
    tester,
  ) async {
    final container = containerFor(tester, [
      _provider('tapped', path: providerFile('tapped', 'payload:\n').path),
      _provider('without-file'),
    ]);
    await pump(tester, container);
    await openMenuWithEdit(tester, 'tapped');
    await closeMenu(tester);
    final loaded = find.byWidgetPredicate(
      (widget) => widget is EditorView && widget.content == 'payload:\n',
    );

    await tester.tap(find.text('without-file'));
    await tester.pumpAndSettle();
    expect(find.byType(EditorPage), findsNothing);
    expect(find.byTooltip(currentAppLocalizations.edit), findsNothing);

    await tester.tap(find.text('tapped'));
    await pumpUntil(tester, loaded);
    expect(tester.widget<EditorPage>(find.byType(EditorPage)).onSave, isNull);
    await tester.binding.handlePopRoute();
    await pumpUntil(tester, find.byType(EditorPage), found: false);

    await openMenu(tester, 'tapped');
    await tester.tap(find.text(currentAppLocalizations.edit));
    await pumpUntil(tester, loaded);
    expect(
      tester.widget<EditorPage>(find.byType(EditorPage)).onSave,
      isNotNull,
    );
  });

  testWidgets('a rejected side-load keeps the editor open', (tester) async {
    final file = providerFile('rejected', 'payload:\n');
    final provider = _provider('rejected', path: file.path);
    when(
      () => core.sideLoadExternalProvider(
        providerName: 'rejected',
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async => 'invalid payload');

    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    final editor = await openEditor(tester, 'rejected');
    editor.onSave!(
      tester.element(find.byType(EditorPage)),
      'rejected',
      'payload: broken\n',
    );
    await pumpUntil(tester, find.text('invalid payload'));

    expect(find.text('invalid payload'), findsOneWidget);
    await tester.tap(find.text(currentAppLocalizations.confirm));
    await pumpTransitions(tester);
    expect(find.byType(EditorPage), findsOneWidget);
    verifyNever(() => core.getExternalProvider('rejected'));
  });

  testWidgets('leaving an edited provider offers to save the changes', (
    tester,
  ) async {
    final file = providerFile('leaving', 'payload:\n');
    final provider = _provider('leaving', path: file.path);

    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    final editor = await openEditor(tester, 'leaving');
    final context = tester.element(find.byType(EditorPage));
    expect(await editor.onPop!(context, 'leaving', 'payload:\n'), isTrue);

    final popped = editor.onPop!(context, 'leaving', 'payload: changed\n');
    await pumpTransitions(tester);
    expect(find.text(currentAppLocalizations.saveChanges), findsOneWidget);
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await pumpTransitions(tester);

    expect(await popped, isTrue);
    expect(file.readAsStringSync(), 'payload:\n');
    verifyNever(
      () => core.sideLoadExternalProvider(
        providerName: any(named: 'providerName'),
        data: any(named: 'data'),
      ),
    );
  });

  testWidgets('a file that only the full read rejects closes the editor', (
    tester,
  ) async {
    final file = File(join(home.path, 'invalid-utf8'))
      ..writeAsBytesSync([0xff, 0xfe, 0x41]);
    final container = containerFor(tester, [
      _provider('invalid-utf8', type: 'Rule', path: file.path),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    await openMenuWithEdit(tester, 'invalid-utf8');
    await tester.tap(find.text(l10n.edit));
    await pumpUntil(tester, find.text(l10n.nonTextProviderFile));

    expect(find.byType(EditorPage), findsNothing);
    expect(find.textContaining('FileSystemException'), findsNothing);

    await tester.tap(find.text(l10n.confirm));
    await tester.pumpAndSettle();
  });

  testWidgets('the menu sync item shows a spinner during the update', (
    tester,
  ) async {
    final provider = _provider('http-one');
    final completer = Completer<String>();
    when(
      () => core.updateExternalProvider('http-one'),
    ).thenAnswer((_) => completer.future);
    when(
      () => core.getExternalProvider('http-one'),
    ).thenAnswer((_) async => provider);
    when(
      () => core.getProxies(),
    ).thenAnswer((_) async => const ProxiesData(proxies: {}, all: []));

    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    expect(find.byType(CommonCircleLoading), findsNothing);

    await openMenu(tester, 'http-one');
    await tester.tap(find.text(currentAppLocalizations.sync));
    await settleTrailing(tester);

    expect(find.byType(CommonCircleLoading), findsOne);

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(CommonCircleLoading), findsNothing);
  });
}

import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' hide context;

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

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

  setUpAll(() {
    core = _MockCoreHandlerInterface();
    CoreController.resetInstance();
    CoreController.test(core);
    home = Directory.systemTemp.createTempSync('flclash-providers-');
  });

  setUp(() => reset(core));

  tearDownAll(() {
    CoreController.resetInstance();
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

    final container = ProviderContainer();
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

  Future<void> pump(WidgetTester tester, ProviderContainer container) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ProvidersView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openMenu(WidgetTester tester, String name) async {
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text(name),
          matching: find.byType(DecorationListItem),
        ),
        matching: find.byGlyph(AppGlyphs.more),
      ),
    );
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
      await tester.pumpAndSettle();
      if (finder.evaluate().isNotEmpty == found) {
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
        (widget) => widget is EditorPage && widget.content?.isNotEmpty == true,
      ),
    );
    return tester.widget<EditorPage>(find.byType(EditorPage));
  }

  testWidgets('splits providers into proxy and rule sections', (tester) async {
    final container = containerFor(tester, [
      _provider('proxy-a'),
      _provider('rule-a', type: 'Rule'),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.proxies), findsOne);
    expect(find.text(l10n.rules), findsOne);
    expect(find.text('proxy-a'), findsOne);
    expect(find.text('rule-a'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets(
    'renders virtualized list using CustomScrollView and SliverList',
    (tester) async {
      final providers = List.generate(50, (i) => _provider('proxy-$i'));
      final container = containerFor(tester, providers);
      await pump(tester, container);

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(SliverList), findsOneWidget);
      expect(find.text('proxy-0'), findsOneWidget);
      expect(find.text('proxy-49'), findsNothing);
    },
  );

  testWidgets('shows typed provider counts in compact metadata chips', (
    tester,
  ) async {
    final container = containerFor(tester, [
      _provider('proxy-with-count', count: 7),
      _provider('rule-with-count', type: 'Rule', count: 9),
      _provider('proxy-without-count', count: 0),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.proxiesCount(7)), findsOneWidget);
    expect(find.text(l10n.rulesCount(9)), findsOneWidget);
    expect(find.text(l10n.proxiesCount(0)), findsNothing);
    expect(find.text(l10n.entriesCount(7)), findsNothing);
    expect(find.textContaining(' · '), findsNothing);
    final countChip = find.ancestor(
      of: find.text(l10n.proxiesCount(7)),
      matching: find.byType(MetaChip),
    );
    expect(countChip, findsOneWidget);
    expect(tester.getSize(countChip).height, lessThanOrEqualTo(20));
    expect(
      tester.getTopLeft(countChip).dy -
          tester.getBottomLeft(find.text('proxy-with-count')).dy,
      greaterThanOrEqualTo(4),
    );
    expect(
      find.ancestor(
        of: countChip,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == const EdgeInsets.only(top: 4, bottom: 2),
        ),
      ),
      findsOneWidget,
    );
    expect(find.byType(Chip), findsNothing);
    final decoratedBox = find.descendant(
      of: countChip,
      matching: find.byType(DecoratedBox),
    );
    final decoration =
        tester.widget<DecoratedBox>(decoratedBox).decoration as ShapeDecoration;
    final padding = tester.widget<Padding>(
      find.descendant(of: countChip, matching: find.byType(Padding)),
    );
    final colorScheme = Theme.of(tester.element(countChip)).colorScheme;
    expect(decoration.color, colorScheme.surfaceContainerHighest);
    expect(
      decoration.shape,
      AppShape.sm.copyWith(side: BorderSide(color: colorScheme.outlineVariant)),
    );
    expect(
      padding.padding,
      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
    expect(
      tester.widget<Text>(find.text(l10n.proxiesCount(7))).style?.color,
      colorScheme.onSurfaceVariant,
    );
    expect(find.byType(MetaChip), findsNWidgets(5));
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

  testWidgets('replaces the more menu with a spinner while updating', (
    tester,
  ) async {
    final provider = _provider('http-one');
    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    expect(find.byGlyph(AppGlyphs.more), findsOne);

    final updating = container.read(updatingKeysProvider.notifier);
    updating.start(provider.updatingKey);
    await settleTrailing(tester);

    expect(find.byGlyph(AppGlyphs.more), findsNothing);
    expect(find.byType(CommonCircleLoading), findsOne);
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

  testWidgets('the toolbar action refreshes every provider', (tester) async {
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

    expect(find.byType(CommonCircleLoading), findsOne);

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    verify(() => core.updateExternalProvider('proxy-a')).called(1);
    verify(() => core.updateExternalProvider('rule-a')).called(1);
  });

  testWidgets('the toolbar classifies Core request failures', (tester) async {
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
    await pump(tester, container);

    await tester.tap(find.byGlyph(AppGlyphs.sync));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.networkException), findsOneWidget);
    expect(find.text('503 Service Unavailable'), findsNothing);

    await tester.tap(find.text(currentAppLocalizations.confirm));
    await tester.pumpAndSettle();
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
    expect(editor.content, 'payload:\n  - old\n');

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
    await tester.pumpAndSettle();
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
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.saveChanges), findsOneWidget);
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();

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

    expect(find.byGlyph(AppGlyphs.more), findsNothing);
    expect(find.byType(CommonCircleLoading), findsOne);

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byGlyph(AppGlyphs.more), findsOne);
    expect(find.byType(CommonCircleLoading), findsNothing);
  });
}

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

ExternalProvider _provider(
  String name, {
  String type = 'Proxy',
  String vehicleType = 'HTTP',
  int count = 3,
  DateTime? updateAt,
  SubscriptionInfo? subscriptionInfo,
}) {
  return ExternalProvider(
    name: name,
    type: type,
    count: count,
    vehicleType: vehicleType,
    updateAt: updateAt ?? DateTime.utc(2026, 1, 1),
    subscriptionInfo: subscriptionInfo,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockCoreHandlerInterface core;

  setUpAll(() {
    core = _MockCoreHandlerInterface();
    CoreController.resetInstance();
    CoreController.test(core);
  });

  setUp(() => reset(core));

  tearDownAll(CoreController.resetInstance);

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
        matching: find.byIcon(Icons.more_vert),
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
      matching: find.byType(ListItemMetaChip),
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
              widget.padding == const EdgeInsets.symmetric(vertical: 4),
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
    expect(decoration.color, colorScheme.secondary);
    expect(decoration.shape, AppShape.sm);
    expect(
      padding.padding,
      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
    expect(
      tester.widget<Text>(find.text(l10n.proxiesCount(7))).style?.color,
      colorScheme.onSecondary,
    );
    final tones = tester
        .widgetList<ListItemMetaChip>(find.byType(ListItemMetaChip))
        .map((chip) => chip.tone)
        .toList();
    expect(
      tones.where((tone) => tone == ListItemMetaChipTone.secondary),
      hasLength(2),
    );
    expect(
      tones.where((tone) => tone == ListItemMetaChipTone.tertiary),
      hasLength(3),
    );
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

    expect(find.byIcon(Icons.more_vert), findsOne);

    final updating = container.read(updatingKeysProvider.notifier);
    updating.start(provider.updatingKey);
    await settleTrailing(tester);

    expect(find.byIcon(Icons.more_vert), findsNothing);
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

    await tester.tap(find.byIcon(Icons.sync));
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

    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.networkException), findsOneWidget);
    expect(find.text('503 Service Unavailable'), findsNothing);

    await tester.tap(find.text(currentAppLocalizations.confirm));
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

    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.byType(CommonCircleLoading), findsOne);

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byIcon(Icons.more_vert), findsOne);
    expect(find.byType(CommonCircleLoading), findsNothing);
  });
}

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxies/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
}) {
  return ExternalProvider(
    name: name,
    type: type,
    count: count,
    vehicleType: vehicleType,
    updateAt: updateAt ?? DateTime.utc(2026, 1, 1),
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

  testWidgets('splits providers into proxy and rule sections', (tester) async {
    final container = containerFor(tester, [
      _provider('proxy-a'),
      _provider('rule-a', type: 'Rule'),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.proxyProviders), findsOne);
    expect(find.text(l10n.ruleProviders), findsOne);
    expect(find.text('proxy-a'), findsOne);
    expect(find.text('rule-a'), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('shows the entry count only when it is non-zero', (tester) async {
    final container = containerFor(tester, [
      _provider('with-count', count: 7),
      _provider('without-count', count: 0),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.textContaining(l10n.entriesCount(7)), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('offers sync only for HTTP-backed providers', (tester) async {
    final container = containerFor(tester, [
      _provider('http-one'),
      _provider('file-one', vehicleType: 'File'),
    ]);
    await pump(tester, container);

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.upload), findsNWidgets(2));
    expect(find.text(l10n.sync), findsOne);
  });

  testWidgets('replaces the sync chip with a spinner while updating', (
    tester,
  ) async {
    final provider = _provider('http-one');
    final container = containerFor(tester, [provider]);
    await pump(tester, container);

    expect(find.text(currentAppLocalizations.sync), findsOne);

    container.read(isUpdatingProvider(provider.updatingKey).notifier).value =
        true;
    await tester.pump();

    expect(find.text(currentAppLocalizations.sync), findsNothing);
    expect(find.byType(CommonCircleLoading), findsOne);
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

    // Per-row chips use the same icon, so target the toolbar's IconButton.
    await tester.tap(
      find
          .descendant(
            of: find.byType(IconButton),
            matching: find.byIcon(Icons.sync),
          )
          .first,
    );
    await tester.pump();

    expect(find.byType(CommonCircleLoading), findsOne);

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    verify(() => core.updateExternalProvider('proxy-a')).called(1);
    verify(() => core.updateExternalProvider('rule-a')).called(1);
  });

  testWidgets('tapping sync chip shows loading spinner during update', (
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

    expect(find.text(currentAppLocalizations.sync), findsOne);
    expect(find.byType(CommonCircleLoading), findsNothing);

    await tester.tap(find.text(currentAppLocalizations.sync));
    await tester.pump();

    expect(find.text(currentAppLocalizations.sync), findsNothing);
    expect(find.byType(CommonCircleLoading), findsOne);

    completer.complete('');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text(currentAppLocalizations.sync), findsOne);
    expect(find.byType(CommonCircleLoading), findsNothing);
  });
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

Future<ProviderContainer> _pumpGeoResourceAction(
  WidgetTester tester,
  CoreHandlerInterface coreInterface,
) async {
  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(
        CoreController.scoped(coreInterface),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return StatusManager(child: child!);
        },
        home: const SizedBox(),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('passive updates change progress without surfacing messages', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;
    final subscription = container.listen<bool>(
      isUpdatingProvider(key),
      (_, _) {},
    );
    addTearDown(subscription.close);

    action.handleCoreUpdate('MMDB', true, false, null);

    expect(container.read(isUpdatingProvider(key)), isTrue);

    action.handleCoreUpdate('MMDB', false, false, 'background failure');
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);
    expect(find.text('background failure'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a manually skipped update is shown as info', (tester) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async => '');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await action.updateGeoResource(GeoResource.MMDB);

    expect(container.read(isUpdatingProvider(key)), isTrue);

    action.handleCoreUpdate('MMDB', false, true, null);
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);
    expect(
      find.text(currentAppLocalizations.geoSkipped(GeoResource.MMDB.name)),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.byIcon(Icons.error_outline), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a rejected manual request clears progress', (tester) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(
      () => coreInterface.updateGeoData('MMDB'),
    ).thenAnswer((_) async => 'unknown geo resource');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await expectLater(
      action.updateGeoResource(GeoResource.MMDB),
      throwsA(
        isA<MessageException>().having(
          (error) => error.message,
          'message',
          'unknown geo resource',
        ),
      ),
    );

    expect(container.read(isUpdatingProvider(key)), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a repeated manual request stays one operation', (tester) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async => '');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await action.updateGeoResource(GeoResource.MMDB);
    action.handleCoreUpdate('MMDB', true, false, null);
    await action.updateGeoResource(GeoResource.MMDB);

    expect(container.read(isUpdatingProvider(key)), isTrue);

    action.handleCoreUpdate('MMDB', false, false, null);
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a core disconnect drops the pending geo operation', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async => '');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await action.updateGeoResource(GeoResource.MMDB);

    expect(container.read(isUpdatingProvider(key)), isTrue);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);

    action.handleCoreUpdate('MMDB', false, false, null);
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the stale sweep preserves late manual completion', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async => '');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    container.read(updatingActionProvider.notifier);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await action.updateGeoResource(GeoResource.MMDB);
    await tester.pump(updatingStaleTimeout + updatingSweepInterval);

    expect(container.read(isUpdatingProvider(key)), isFalse);

    action.handleCoreUpdate('MMDB', false, false, null);
    await tester.pump();

    expect(
      find.text(currentAppLocalizations.geoUpdated(GeoResource.MMDB.name)),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a structured failure is left to the Core log path', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async => '');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);

    await action.updateGeoResource(GeoResource.MMDB);
    action.handleCoreUpdate('MMDB', false, false, 'download failed');
    await tester.pump();

    expect(find.text('download failed'), findsNothing);
    expect(find.byIcon(Icons.error_outline), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('leaving the connected Core clears manual feedback', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async => '');
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    final action = container.read(geoResourceActionProvider.notifier);

    await action.updateGeoResource(GeoResource.MMDB);
    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    action.handleCoreUpdate('MMDB', false, false, null);
    await tester.pump();

    expect(
      find.text(currentAppLocalizations.geoUpdated(GeoResource.MMDB.name)),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

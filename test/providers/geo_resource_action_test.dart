import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

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
      child: HostApp(
        navigatorKey: globalState.navigatorKey,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          return BannerHost(stacked: false, topInset: 0, child: child!);
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
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {});
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
    expect(find.byGlyph(AppGlyphs.checkCircle), findsNothing);
    expect(find.byGlyph(AppGlyphs.error), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a rejected manual request clears progress', (tester) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer(
      (_) async => throw const CoreMethodException(
        code: 'core_error',
        message: 'unknown geo resource',
      ),
    );
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await expectLater(
      action.updateGeoResource(GeoResource.MMDB),
      throwsA(
        isA<CoreMethodException>().having(
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
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {});
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

  testWidgets('a request the Core turns down leaves a running update be', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    var requests = 0;
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {
      if (requests++ > 0) {
        throw const CoreMethodException(
          code: 'core_error',
          message: 'geo update already in progress',
        );
      }
    });
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await action.updateGeoResource(GeoResource.MMDB);
    await expectLater(
      action.updateGeoResource(GeoResource.MMDB, announceSuccess: false),
      throwsA(isA<CoreMethodException>()),
    );

    expect(container.read(isUpdatingProvider(key)), isTrue);

    action.handleCoreUpdate('MMDB', false, false, null);
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);
    expect(
      find.text(currentAppLocalizations.geoUpdated(GeoResource.MMDB.name)),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a core disconnect drops the pending geo operation', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {});
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
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {});
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

  testWidgets('a manual update failure is surfaced as an error', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {});
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);

    await action.updateGeoResource(GeoResource.MMDB);
    action.handleCoreUpdate('MMDB', false, false, 'download failed');
    await tester.pump();

    expect(find.text('download failed'), findsOneWidget);
    final banner = find
        .ancestor(
          of: find.text('download failed'),
          matching: find.byType(Surface),
        )
        .first;
    expect(
      tester.widget<Surface>(banner).color,
      Theme.of(tester.element(banner)).colorScheme.errorContainer,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an update that announces no success still reports failure', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData(any())).thenAnswer((_) async {});
    final container = await _pumpGeoResourceAction(tester, coreInterface);
    final action = container.read(geoResourceActionProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;

    await action.updateGeoResource(GeoResource.MMDB, announceSuccess: false);
    await action.updateGeoResource(GeoResource.ASN, announceSuccess: false);
    action.handleCoreUpdate('MMDB', false, false, null);
    action.handleCoreUpdate('ASN', false, false, 'download failed');
    await tester.pump();

    expect(container.read(isUpdatingProvider(key)), isFalse);
    expect(
      find.text(currentAppLocalizations.geoUpdated(GeoResource.MMDB.name)),
      findsNothing,
    );
    expect(find.text('download failed'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('leaving the connected Core clears manual feedback', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.updateGeoData('MMDB')).thenAnswer((_) async {});
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

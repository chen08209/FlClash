import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
  });

  tearDown(() => container.dispose());

  Future<void> pumpHost(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (context, child) {
            globalState.measure = Measure.of(context, 1);
            globalState.theme = CommonTheme.of(context, 1);
            return StatusManager(child: child!);
          },
          home: const SizedBox(key: Key('child')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('safeRun', () {
    testWidgets('returns the value and brackets it with start/end', (
      tester,
    ) async {
      await pumpHost(tester);
      final events = <String>[];

      final result = await globalState.safeRun<int>(
        () async {
          events.add('run');
          return 42;
        },
        onStart: () => events.add('start'),
        onEnd: () => events.add('end'),
      );
      await tester.pumpAndSettle();

      expect(result, 42);
      expect(events, ['start', 'run', 'end']);
    });

    testWidgets('swallows the error, returns null, and still calls onEnd', (
      tester,
    ) async {
      await pumpHost(tester);
      final events = <String>[];

      final result = await globalState.safeRun<int>(
        () async => throw StateError('boom'),
        onStart: () => events.add('start'),
        onEnd: () => events.add('end'),
      );
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(events, ['start', 'end']);
    });

    testWidgets('surfaces a silent failure through the notifier', (
      tester,
    ) async {
      await pumpHost(tester);

      await globalState.safeRun<int>(
        () async => throw StateError('quiet failure'),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('quiet failure'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('surfaces a loud failure through a dialog', (tester) async {
      await pumpHost(tester);

      await globalState.safeRun<int>(
        () async => throw StateError('loud failure'),
        title: 'Backup',
        silence: false,
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('loud failure'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('accepts a synchronous function', (tester) async {
      await pumpHost(tester);

      final result = await globalState.safeRun<String>(() => 'sync');

      expect(result, 'sync');
    });
  });

  group('loadingRun', () {
    testWidgets('raises and clears the loading flag around the work', (
      tester,
    ) async {
      await pumpHost(tester);
      const tag = LoadingTag.backup_restore;
      bool? loadingDuringRun;

      final result = await globalState.loadingRun<int>(() async {
        loadingDuringRun = container.read(loadingProvider(tag));
        return 7;
      }, tag: tag);
      await tester.pumpAndSettle();

      expect(result, 7);
      expect(loadingDuringRun, isTrue);
      expect(
        container.read(loadingProvider(tag)),
        isTrue,
        reason: 'the flag is held for a minimum duration to avoid flicker',
      );

      await tester.pump(const Duration(milliseconds: 1100));
      expect(container.read(loadingProvider(tag)), isFalse);
    });

    testWidgets('clears the loading flag when the work throws', (tester) async {
      await pumpHost(tester);
      const tag = LoadingTag.backup_restore;

      final result = await globalState.loadingRun<int>(
        () async => throw StateError('failed'),
        tag: tag,
      );
      await tester.pumpAndSettle();

      expect(result, isNull);
      await tester.pump(const Duration(milliseconds: 1100));
      expect(container.read(loadingProvider(tag)), isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('runs without a tag', (tester) async {
      await pumpHost(tester);

      final result = await globalState.loadingRun<int>(
        () async => 1,
        tag: null,
      );

      expect(result, 1);
    });
  });

  group('batchRun', () {
    testWidgets('caps the work in flight and reports failures in one message', (
      tester,
    ) async {
      await pumpHost(tester);
      const tag = LoadingTag.profiles;
      final gates = List.generate(5, (_) => Completer<void>());
      var active = 0;
      var peak = 0;

      final run = globalState.batchRun<int>(
        [0, 1, 2, 3, 4],
        (index) async {
          active++;
          peak = active > peak ? active : peak;
          try {
            await gates[index].future;
            if (index.isOdd) {
              throw StateError('failed $index');
            }
          } finally {
            active--;
          }
        },
        label: (index) => 'item $index',
        concurrency: 2,
        tag: tag,
      );
      await tester.pump();
      expect(active, 2);
      expect(container.read(loadingProvider(tag)), isTrue);

      for (final gate in gates) {
        gate.complete();
        await tester.pump();
        expect(container.read(loadingProvider(tag)), isTrue);
      }
      await run;
      await tester.pumpAndSettle();

      expect(peak, 2);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('2 items failed'), findsOneWidget);

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      expect(find.text('2 items failed'), findsNothing);
      expect(find.text('Error details'), findsOneWidget);
      expect(find.text('item 1'), findsOneWidget);
      expect(find.text('item 3'), findsOneWidget);
      expect(find.textContaining('failed 3'), findsOneWidget);
      expect(find.text('item 0'), findsNothing);
      expect(
        tester.getTopLeft(find.text('item 1')).dy,
        lessThan(tester.getTopLeft(find.text('item 3')).dy),
      );

      await tester.pump(const Duration(milliseconds: 1100));
      expect(container.read(loadingProvider(tag)), isFalse);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('names a lone failure and its reason in the message', (
      tester,
    ) async {
      await pumpHost(tester);

      await globalState.batchRun<int>(
        [0, 1],
        (index) async {
          if (index == 1) {
            throw StateError('failed 1');
          }
        },
        label: (index) => 'item $index',
        concurrency: 2,
        tag: null,
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining(RegExp(r'^item 1: .*failed 1')),
        findsOneWidget,
      );
      expect(find.text('View'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('canCrashCoreFor', () {
    test('is allowed in debug builds and on the dev channel', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: true, appEnv: 'stable'),
        isTrue,
      );
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'dev'),
        isTrue,
      );
    });

    test('is refused for release stable and pre builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'stable'),
        isFalse,
      );
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'pre'),
        isFalse,
      );
    });
  });
}

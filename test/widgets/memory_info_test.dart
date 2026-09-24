import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/views/dashboard/widgets/memory_info.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

void main() {
  testWidgets('MemoryInfo refreshes only while the app is resumed', (
    tester,
  ) async {
    var readCount = 0;

    Future<MemorySnapshot> readMemory() async {
      readCount++;
      return MemorySnapshot(app: readCount);
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: MemoryInfo(memoryReader: readMemory),
        homeBuilder: (child) => Scaffold(body: child),
      ),
    );
    await tester.pump();

    expect(readCount, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(readCount, 1);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(readCount, 2);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 4));

    expect(readCount, 2);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(readCount, 3);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('MemoryInfo ignores a request completed in the background', (
    tester,
  ) async {
    final requests = <Completer<MemorySnapshot>>[];

    Future<MemorySnapshot> readMemory() {
      final request = Completer<MemorySnapshot>();
      requests.add(request);
      return request.future;
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: MemoryInfo(memoryReader: readMemory),
        homeBuilder: (child) => Scaffold(body: child),
      ),
    );
    await tester.pump();

    expect(requests, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    requests.first.complete(const MemorySnapshot(app: 1));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(requests, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(requests, hasLength(2));

    requests.last.complete(const MemorySnapshot(app: 2));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('MemoryInfo keeps polling after a failed read', (tester) async {
    var readCount = 0;

    Future<MemorySnapshot> readMemory() async {
      readCount++;
      if (readCount == 1) {
        throw StateError('core unavailable');
      }
      return MemorySnapshot(app: readCount);
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: MemoryInfo(memoryReader: readMemory),
        homeBuilder: (child) => Scaffold(body: child),
      ),
    );
    await tester.pump();

    expect(readCount, 1);
    expect(tester.takeException(), null);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(readCount, 2);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('MemoryInfo refreshes only while the page is active', (
    tester,
  ) async {
    var readCount = 0;

    Future<MemorySnapshot> readMemory() async {
      readCount++;
      return MemorySnapshot(app: readCount);
    }

    Widget buildApp({required bool isPageActive}) {
      return TestApp(
        wrapInProviderScope: true,
        child: PageActivityScope(
          isActive: isPageActive,
          child: MemoryInfo(memoryReader: readMemory),
        ),
        homeBuilder: (child) => Scaffold(body: child),
      );
    }

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(buildApp(isPageActive: false));
    await tester.pump(const Duration(seconds: 4));

    expect(readCount, 0);

    await tester.pumpWidget(buildApp(isPageActive: true));
    await tester.pump();

    expect(readCount, 1);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(readCount, 2);

    await tester.pumpWidget(buildApp(isPageActive: false));
    await tester.pump(const Duration(seconds: 4));

    expect(readCount, 2);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the default reader adds Core memory while connected', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(
      () => coreInterface.getMemoryStats(),
    ).thenAnswer((_) async => const CoreMemoryStats(rss: 4096));
    final container = _containerWith(coreInterface, CoreStatus.connected);
    addTearDown(container.dispose);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(homeBuilder: _scaffoldBody, child: MemoryInfo()),
      ),
    );
    await tester.pump();
    await tester.pump();

    verify(
      () => coreInterface.getMemoryStats(),
    ).called(greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the default reader skips Core memory while disconnected', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(
      () => coreInterface.getMemoryStats(),
    ).thenAnswer((_) async => const CoreMemoryStats(rss: 4096));
    final container = _containerWith(coreInterface, CoreStatus.disconnected);
    addTearDown(container.dispose);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(homeBuilder: _scaffoldBody, child: MemoryInfo()),
      ),
    );
    await tester.pump();
    await tester.pump();

    verifyNever(() => coreInterface.getMemoryStats());

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a remounted card never reuses a disposed notifier', (
    tester,
  ) async {
    var readCount = 0;

    Future<MemorySnapshot> readMemory() async {
      readCount++;
      return MemorySnapshot(app: readCount);
    }

    Widget app() => TestApp(
      wrapInProviderScope: true,
      homeBuilder: _scaffoldBody,
      child: MemoryInfo(memoryReader: readMemory),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(app());
    await tester.pump();

    expect(readCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(readCount, greaterThan(1));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('MemorySnapshot.resolve', () {
    const core = CoreMemoryStats(
      rss: 4096,
      heapInuse: 1000,
      heapIdle: 500,
      stackInuse: 200,
      runtimeOther: 100,
    );

    test('adds a separate Core process on top of the app', () {
      final snapshot = MemorySnapshot.resolve(
        rss: 10000,
        core: core,
        coreInProcess: false,
      );
      expect(snapshot.app, 10000);
      expect(snapshot.coreTotal, 4096);
      expect(snapshot.total, 14096);
      expect(snapshot.coreOther, 4096 - 1800);
    });

    test('carves an in-process Core out of the shared RSS', () {
      final snapshot = MemorySnapshot.resolve(
        rss: 10000,
        core: core,
        coreInProcess: true,
      );
      expect(snapshot.app, 10000 - 1800);
      expect(snapshot.coreTotal, 1800);
      expect(snapshot.total, 10000);
      expect(snapshot.coreOther, 0);
    });

    test('never reports a negative app share', () {
      final snapshot = MemorySnapshot.resolve(
        rss: 100,
        core: core,
        coreInProcess: true,
      );
      expect(snapshot.app, 0);
      expect(snapshot.total, 1800);
    });

    test('a stopped Core leaves only the app', () {
      final snapshot = MemorySnapshot.resolve(
        rss: 10000,
        core: null,
        coreInProcess: false,
      );
      expect(snapshot.core, isNull);
      expect(snapshot.coreTotal, 0);
      expect(snapshot.total, 10000);
    });

    test('a stopped in-process Core still marks the process as shared', () {
      final snapshot = MemorySnapshot.resolve(
        rss: 10000,
        core: null,
        coreInProcess: true,
      );
      expect(snapshot.coreInProcess, isTrue);
      expect(snapshot.app, 10000);
    });
  });

  group('memory detail sheet', () {
    const stats = CoreMemoryStats(
      rss: 4 * 1024 * 1024,
      heapInuse: 2 * 1024 * 1024,
      heapIdle: 1024 * 1024,
      stackInuse: 512 * 1024,
      runtimeOther: 256 * 1024,
    );

    Future<void> openSheet(
      WidgetTester tester, {
      required Future<MemorySnapshot> Function() reader,
      CoreHandlerInterface? coreInterface,
    }) async {
      final container = _containerWith(
        coreInterface ?? _MockCoreHandlerInterface(),
        CoreStatus.connected,
      );
      addTearDown(container.dispose);
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            homeBuilder: _scaffoldBody,
            child: MemoryInfo(memoryReader: reader),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byType(CommonCard));
      await tester.pumpAndSettle();
    }

    testWidgets('tapping the card lists the Core breakdown', (tester) async {
      await openSheet(
        tester,
        reader: () async => MemorySnapshot.resolve(
          rss: 12 * 1024 * 1024,
          core: stats,
          coreInProcess: false,
        ),
      );

      expect(find.byType(MemoryDetailSheet), findsOneWidget);
      expect(find.text('App'), findsOneWidget);
      expect(find.text('12MB'), findsOneWidget);
      expect(find.text('Resident memory'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Core'), findsOneWidget);
      expect(find.text('4MB'), findsOneWidget);
      expect(find.text('Heap in use'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Heap idle'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('Goroutine stacks'), findsOneWidget);
      expect(find.text('12.5%'), findsOneWidget);
      expect(find.text('Runtime overhead'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('Core is not running'), findsNothing);
      expect(find.text(_estimateDesc), findsOneWidget);
      expect(find.text('App & shared'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('an in-process Core labels the app share as shared', (
      tester,
    ) async {
      await openSheet(
        tester,
        reader: () async => MemorySnapshot.resolve(
          rss: 12 * 1024 * 1024,
          core: stats,
          coreInProcess: true,
        ),
      );

      expect(find.text('App & shared'), findsOneWidget);
      expect(find.text('App'), findsNothing);
      expect(find.text(_estimateSharedDesc), findsOneWidget);
      expect(find.text(_estimateDesc), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('starting the Core cross-fades its rows in', (tester) async {
      CoreMemoryStats? core;
      await openSheet(
        tester,
        reader: () async => MemorySnapshot.resolve(
          rss: 8 * 1024 * 1024,
          core: core,
          coreInProcess: false,
        ),
      );

      expect(find.text('Core is not running'), findsOneWidget);

      core = stats;
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Core is not running'), findsOneWidget);
      expect(find.text('Heap in use'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Core is not running'), findsNothing);
      expect(find.text('Heap in use'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a stopped Core is reported instead of an empty list', (
      tester,
    ) async {
      await openSheet(
        tester,
        reader: () async => const MemorySnapshot(app: 1024 * 1024),
      );

      expect(find.text('Core is not running'), findsOneWidget);
      expect(find.text('Heap in use'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the sheet follows later polls', (tester) async {
      var heapInuse = 1536 * 1024;
      await openSheet(
        tester,
        reader: () async => MemorySnapshot.resolve(
          rss: 8 * 1024 * 1024,
          core: stats.copyWith(heapInuse: heapInuse),
          coreInProcess: false,
        ),
      );

      expect(find.text('37.5%'), findsOneWidget);
      expect(find.text('75%'), findsNothing);

      heapInuse = 3 * 1024 * 1024;
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('75%'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the release action asks the Core to collect', (tester) async {
      final coreInterface = _MockCoreHandlerInterface();
      when(() => coreInterface.forceGc()).thenAnswer((_) async => true);
      await openSheet(
        tester,
        reader: () async => const MemorySnapshot(app: 1024),
        coreInterface: coreInterface,
      );

      await tester.tap(find.byTooltip('Release memory'));
      await tester.pump();

      verify(() => coreInterface.forceGc()).called(1);
      expect(find.byType(CommonCircleLoading), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      expect(find.byType(CommonCircleLoading), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

const _estimateDesc =
    'Estimated from process resident memory; it may differ from what the '
    'system reports.';
const _estimateSharedDesc =
    'The Core runs inside the app process. Its share is estimated from '
    'runtime stats, and the rest counts as app and shared memory.';

Widget _scaffoldBody(Widget child) => Scaffold(body: child);

ProviderContainer _containerWith(
  CoreHandlerInterface coreInterface,
  CoreStatus status,
) {
  final container = ProviderContainer(
    overrides: [
      coreHandlerProvider.overrideWithValue(
        CoreController.scoped(coreInterface),
      ),
    ],
  );
  container.read(coreStatusProvider.notifier).value = status;
  return container;
}

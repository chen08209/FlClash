import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/views/dashboard/widgets/memory_info.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/material.dart';
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

    Future<num> readMemory() async {
      readCount++;
      return readCount;
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
    final requests = <Completer<num>>[];

    Future<num> readMemory() {
      final request = Completer<num>();
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
    requests.first.complete(1);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(requests, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(requests, hasLength(2));

    requests.last.complete(2);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('MemoryInfo keeps polling after a failed read', (tester) async {
    var readCount = 0;

    Future<num> readMemory() async {
      readCount++;
      if (readCount == 1) {
        throw StateError('core unavailable');
      }
      return readCount;
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

    Future<num> readMemory() async {
      readCount++;
      return readCount;
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
    when(() => coreInterface.getMemory()).thenAnswer((_) async => 4096);
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

    verify(() => coreInterface.getMemory()).called(greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the default reader skips Core memory while disconnected', (
    tester,
  ) async {
    final coreInterface = _MockCoreHandlerInterface();
    when(() => coreInterface.getMemory()).thenAnswer((_) async => 4096);
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

    verifyNever(() => coreInterface.getMemory());

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a remounted card never reuses a disposed notifier', (
    tester,
  ) async {
    var readCount = 0;

    Future<num> readMemory() async {
      readCount++;
      return readCount;
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
}

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

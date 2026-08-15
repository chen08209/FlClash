import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/memory_info.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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
      _TestApp(child: MemoryInfo(memoryReader: readMemory)),
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
      _TestApp(child: MemoryInfo(memoryReader: readMemory)),
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
      _TestApp(child: MemoryInfo(memoryReader: readMemory)),
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
      return _TestApp(
        child: PageActivityScope(
          isActive: isPageActive,
          child: MemoryInfo(memoryReader: readMemory),
        ),
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
}

class _TestApp extends StatelessWidget {
  final Widget child;

  const _TestApp({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalState.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.measure = Measure.of(context, 1);
        globalState.theme = CommonTheme.of(context, 1);
        return child!;
      },
      home: Scaffold(body: child),
    );
  }
}

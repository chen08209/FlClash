import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/developer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

ProviderContainer _containerFor(WidgetTester tester) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

Future<void> _pumpDeveloperView(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: DeveloperView()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    // canCrashCore reads appEnv, which only the real app bootstrap populates.
    // 'dev' also enables the crash-test row.
    globalState.appEnv = 'dev';
  });

  testWidgets('toggles developer mode through the header switch', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    final initial = container.read(appSettingProvider).developerMode;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(container.read(appSettingProvider).developerMode, !initial);
    expect(tester.takeException(), null);
  });

  testWidgets('logs test fills the log buffer', (tester) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    expect(container.read(logsProvider).list, isEmpty);

    await tester.tap(find.text(currentAppLocalizations.logsTest));
    await tester.pumpAndSettle();

    expect(container.read(logsProvider).list, isNotEmpty);
    expect(tester.takeException(), null);
  });

  testWidgets('clear data asks for confirmation and aborts on cancel', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.clearData));
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.confirmClearAllData), findsOne);

    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.confirmClearAllData),
      findsNothing,
    );
    expect(tester.takeException(), null);
  });

  testWidgets('message test surfaces a notification', (tester) async {
    final container = _containerFor(tester);
    await _pumpDeveloperView(tester, container);

    await tester.tap(find.text(currentAppLocalizations.messageTest));
    await tester.pumpAndSettle();

    expect(tester.takeException(), null);
  });
}

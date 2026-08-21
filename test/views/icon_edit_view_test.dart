import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/icon.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _recordUrl = 'https://example.com/icon.png';

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

// Holds the route result, which only arrives after the view pops.
class _PopResult {
  String? value;
}

Future<_PopResult> _pumpIconEditView(
  WidgetTester tester,
  ProviderContainer container, {
  String? value,
}) async {
  final result = _PopResult();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result.value = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => IconEditView(value)),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  late Database testDatabase;

  setUp(() {
    testDatabase = Database(NativeDatabase.memory());
    // The view reads the process-wide handle; swap in an in-memory executor.
    database = testDatabase;
  });

  tearDown(() async {
    await testDatabase.close();
  });

  testWidgets('shows the empty state when no icon record matches', (
    tester,
  ) async {
    final container = _containerFor(tester);
    await _pumpIconEditView(tester, container);

    expect(find.byType(NullStatus), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('lists stored icon records for the current input', (
    tester,
  ) async {
    await testDatabase.iconRecordsDao.put(_recordUrl);
    final container = _containerFor(tester);

    await _pumpIconEditView(tester, container, value: 'example.com');

    expect(find.text(_recordUrl), findsOne);
    expect(find.byType(NullStatus), findsNothing);
    expect(tester.takeException(), null);
  });

  testWidgets('picking a record closes the view and returns its url', (
    tester,
  ) async {
    await testDatabase.iconRecordsDao.put(_recordUrl);
    final container = _containerFor(tester);
    final result = await _pumpIconEditView(
      tester,
      container,
      value: 'example.com',
    );

    expect(result.value, isNull, reason: 'still open');

    await tester.tap(find.text(_recordUrl));
    await tester.pumpAndSettle();

    expect(find.byType(IconEditView), findsNothing);
    expect(result.value, _recordUrl);
    expect(tester.takeException(), null);
  });
}

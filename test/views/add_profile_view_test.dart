import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:material_ui/material_ui.dart';
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

void main() {
  testWidgets('lists the QR code, file, and URL import entries', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => AddProfileView(context: context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.qrcode), findsOne);
    expect(find.text(l10n.file), findsOne);
    expect(find.text(l10n.url), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('URL import dialog rejects an empty value and keeps the sheet', (
    tester,
  ) async {
    final container = _containerFor(tester);
    String? popped;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  popped = await showDialog<String>(
                    context: context,
                    builder: (_) => const URLFormDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(URLFormDialog), findsOne);

    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(
      find.byType(URLFormDialog),
      findsOne,
      reason: 'an empty URL must not close the dialog',
    );
    expect(popped, isNull);
    expect(tester.takeException(), null);
  });

  testWidgets('URL import dialog returns the entered value', (tester) async {
    final container = _containerFor(tester);
    String? popped;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  popped = await showDialog<String>(
                    context: context,
                    builder: (_) => const URLFormDialog(),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'https://example.com/profile',
    );
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(find.byType(URLFormDialog), findsNothing);
    expect(popped, 'https://example.com/profile');
    expect(tester.takeException(), null);
  });
}

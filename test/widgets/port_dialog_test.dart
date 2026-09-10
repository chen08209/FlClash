import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

Future<ProviderContainer> _openPortDialog(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1000, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [profilesProvider.overrideWith(TestProfiles.new)],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container
      .read(viewSizeProvider.notifier)
      .update((_) => const Size(1000, 900));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Scaffold(body: ListView(children: const [PortItem()])),
      ),
    ),
  );
  await tester.pump();

  await tester.tap(find.byType(PortItem));
  await tester.pumpAndSettle();
  return container;
}

Future<void> _expandMore(WidgetTester tester) async {
  await tester.tap(find.byType(IconButton).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('opens with the mixed port and hides the rest until expanded', (
    tester,
  ) async {
    final container = await _openPortDialog(tester);
    final config = container.read(patchClashConfigProvider);

    expect(find.byType(TextFormField), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).controller?.text,
      config.mixedPort.toString(),
    );

    await _expandMore(tester);
    expect(find.byType(TextFormField), findsNWidgets(5));
  });

  testWidgets('rejects a mixed port outside the allowed range', (tester) async {
    await _openPortDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, '80');
    await tester.pumpAndSettle();

    expect(find.textContaining('1024'), findsWidgets);
  });

  testWidgets('rejects zero for the mixed port but accepts it elsewhere', (
    tester,
  ) async {
    await _openPortDialog(tester);
    await _expandMore(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), '0');
    await tester.pumpAndSettle();
    final errorsWithDisabledPort = find
        .textContaining('1024')
        .evaluate()
        .length;

    await tester.enterText(fields.first, '0');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1024').evaluate().length,
      greaterThan(errorsWithDisabledPort),
    );
  });

  testWidgets('reports a conflict when two ports share a value', (
    tester,
  ) async {
    await _openPortDialog(tester);
    await _expandMore(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '7890');
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(1), '7890');
    await tester.pumpAndSettle();

    expect(find.text('Please enter a different port'), findsWidgets);
  });

  testWidgets('submitting valid ports writes them to the patch config', (
    tester,
  ) async {
    final container = await _openPortDialog(tester);
    await _expandMore(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '7891');
    await tester.enterText(fields.at(1), '7892');
    await tester.enterText(fields.at(2), '7893');
    await tester.enterText(fields.at(3), '0');
    await tester.enterText(fields.at(4), '0');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    final config = container.read(patchClashConfigProvider);
    expect(config.mixedPort, 7891);
    expect(config.port, 7892);
    expect(config.socksPort, 7893);
    expect(config.redirPort, 0);
    expect(config.tproxyPort, 0);
  });
}

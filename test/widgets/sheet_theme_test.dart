import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

ThemeData _theme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: brightness,
  ),
);

Future<ValueNotifier<ThemeMode>> _openFromPage(
  WidgetTester tester, {
  required Size size,
  required void Function(BuildContext context) open,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final mode = ValueNotifier(ThemeMode.light);
  addTearDown(mode.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
      child: ValueListenableBuilder(
        valueListenable: mode,
        builder: (_, themeMode, _) => TestApp(
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          themeMode: themeMode,
          child: CommonScaffold(
            title: 'Page',
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => open(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return mode;
}

Color? _sheetColor(WidgetTester tester) => tester
    .widget<Material>(
      find
          .ancestor(of: find.text('sheet'), matching: find.byType(Material))
          .first,
    )
    .color;

void main() {
  final darkSheetColor = SurfaceLevel.page.colorOf(
    _theme(Brightness.dark).colorScheme,
  );

  for (final (kind, size, type, show) in [
    ('bottom sheet', const Size(400, 800), SheetType.bottomSheet, showSheet),
    ('side sheet', const Size(1200, 800), SheetType.sideSheet, showSheet),
    ('form sheet', const Size(1200, 800), SheetType.formSheet, showFormSheet),
  ]) {
    testWidgets('an open $kind takes a new app theme', (tester) async {
      final mode = await _openFromPage(
        tester,
        size: size,
        open: (context) =>
            show<void>(context: context, builder: (_) => const Text('sheet')),
      );
      expect(SheetProvider.of(tester.element(find.text('sheet')))?.type, type);
      expect(_sheetColor(tester), isNot(darkSheetColor));

      mode.value = ThemeMode.dark;
      await tester.pumpAndSettle();

      expect(_sheetColor(tester), darkSheetColor);
    });
  }
}

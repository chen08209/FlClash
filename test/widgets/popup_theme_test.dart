import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

ThemeData _theme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: colorScheme,
    extensions: [
      if (brightness == Brightness.dark)
        ElevatedColorScheme(colorScheme.elevated),
    ],
  );
}

Color _floatingFill(ColorScheme colorScheme) =>
    SurfaceLevel.floatingOf(colorScheme).colorOf(colorScheme);

Future<ValueNotifier<ThemeMode>> _pumpPage(
  WidgetTester tester, {
  required WidgetBuilder body,
}) async {
  const size = Size(400, 800);
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
            body: Builder(builder: body),
          ),
        ),
      ),
    ),
  );
  return mode;
}

void main() {
  late PopupOpen open;
  final popupBox = CommonPopupBox(
    targetBuilder: (value) {
      open = value;
      return const SizedBox(width: 40, height: 40);
    },
    popupBuilder: (_) =>
        const CommonPopupMenu(items: [CommonPopupMenuItem(label: 'item')]),
  );

  Color fillOf(WidgetTester tester) =>
      tester.widget<PopupMenuCard>(find.byType(PopupMenuCard)).fill;

  final light = _theme(Brightness.light);
  final dark = _theme(Brightness.dark);

  testWidgets('an open popup takes a new app theme', (tester) async {
    final mode = await _pumpPage(tester, body: (_) => Center(child: popupBox));
    open();
    await tester.pumpAndSettle();
    expect(fillOf(tester), _floatingFill(light.colorScheme));

    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();

    expect(fillOf(tester), _floatingFill(dark.colorScheme));
  });

  testWidgets('a popup opened in a sheet keeps its lift in a new app theme', (
    tester,
  ) async {
    final mode = await _pumpPage(
      tester,
      body: (context) => TextButton(
        onPressed: () => showSheet<void>(
          context: context,
          builder: (_) => Center(child: popupBox),
        ),
        child: const Text('open'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    open();
    await tester.pumpAndSettle();
    expect(fillOf(tester), _floatingFill(light.colorScheme));

    mode.value = ThemeMode.dark;
    await tester.pumpAndSettle();

    final elevated = dark.extension<ElevatedColorScheme>()!.colorScheme;
    expect(_floatingFill(elevated), isNot(_floatingFill(dark.colorScheme)));
    expect(fillOf(tester), _floatingFill(elevated));
  });
}

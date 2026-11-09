import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

void _noop() {}

final _theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
);

final _darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF007AFF),
    brightness: Brightness.dark,
  ),
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    TestApp(
      theme: theme ?? _theme,
      child: HostScaffold(body: Center(child: child)),
    ),
  );
}

Color? _iconColor(WidgetTester tester, Glyph glyph) =>
    IconTheme.of(tester.element(find.byGlyph(glyph))).color;

double? _iconSize(WidgetTester tester, Glyph glyph) =>
    IconTheme.of(tester.element(find.byGlyph(glyph))).size;

Iterable<OpacityLayer> _tints(WidgetTester tester) => tester.layers
    .whereType<OpacityLayer>()
    .where((layer) => layer.alpha == 191);

void main() {
  group('IconButton', () {
    testWidgets('lays out and colors itself as a Material 3 icon button', (
      tester,
    ) async {
      await _pump(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'plain',
              onPressed: _noop,
              icon: GlyphIcon(AppGlyphs.sync),
            ),
            IconButton(
              tooltip: 'selected',
              isSelected: true,
              onPressed: _noop,
              icon: GlyphIcon(AppGlyphs.sort),
              selectedIcon: GlyphIcon(AppGlyphs.check),
            ),
            IconButton(
              tooltip: 'disabled',
              onPressed: null,
              icon: GlyphIcon(AppGlyphs.delete),
            ),
          ],
        ),
      );
      final colors = _theme.colorScheme;

      expect(
        tester.getSize(find.widgetWithGlyph(IconButton, AppGlyphs.sync)),
        const Size.square(48),
      );
      expect(_iconSize(tester, AppGlyphs.sync), 24);
      expect(_iconColor(tester, AppGlyphs.sync), colors.onSurfaceVariant);
      expect(find.byGlyph(AppGlyphs.sort), findsNothing);
      expect(_iconColor(tester, AppGlyphs.check), colors.primary);
      expect(
        _iconColor(tester, AppGlyphs.delete),
        colors.onSurface.withAlpha(97),
      );
    });

    testWidgets('a compact tap target leaves the 40 dp button', (tester) async {
      await _pump(
        tester,
        const IconButton(
          tooltip: 'plain',
          onPressed: _noop,
          icon: GlyphIcon(AppGlyphs.sync),
        ),
        theme: _theme.copyWith(tapTargetSize: TapTargetSize.shrinkWrap),
      );

      expect(tester.getSize(find.byType(IconButton)), const Size.square(40));
    });

    testWidgets('its style wins over the theme, the theme over an icon theme', (
      tester,
    ) async {
      const red = Color(0xFFFF0000);
      const green = Color(0xFF00FF00);
      const blue = Color(0xFF0000FF);
      await _pump(
        tester,
        IconTheme.merge(
          data: const IconThemeData(color: blue, size: 18),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const IconButton(
                tooltip: 'ambient',
                onPressed: _noop,
                icon: GlyphIcon(AppGlyphs.sync),
              ),
              ButtonTheme(
                data: ButtonThemeData(
                  icon: ButtonStyle.from(foregroundColor: green),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const IconButton(
                      tooltip: 'themed',
                      onPressed: _noop,
                      icon: GlyphIcon(AppGlyphs.sort),
                    ),
                    IconButton(
                      tooltip: 'own',
                      onPressed: _noop,
                      style: ButtonStyle.from(foregroundColor: red),
                      icon: const GlyphIcon(AppGlyphs.check),
                    ),
                    IconButton(
                      tooltip: 'disabled',
                      onPressed: null,
                      style: ButtonStyle.from(foregroundColor: red),
                      icon: const GlyphIcon(AppGlyphs.delete),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      expect(_iconColor(tester, AppGlyphs.sync), blue);
      expect(_iconSize(tester, AppGlyphs.sync), 18);
      expect(_iconColor(tester, AppGlyphs.sort), green);
      expect(_iconColor(tester, AppGlyphs.check), red);
      expect(
        _iconColor(tester, AppGlyphs.delete),
        _theme.colorScheme.onSurface.withAlpha(97),
      );
    });

    testWidgets('reads as one button named by its tooltip', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        const IconButton(
          tooltip: 'Refresh',
          onPressed: _noop,
          icon: GlyphIcon(AppGlyphs.sync),
        ),
      );

      expect(
        tester.getSemantics(find.byType(CardSurface)),
        isSemantics(
          tooltip: 'Refresh',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('a hover reaches its states and an overlay shows it', (
      tester,
    ) async {
      const overlay = Color(0x33000000);
      await _pump(
        tester,
        const IconButton(
          tooltip: 'hover',
          onPressed: _noop,
          style: ButtonStyle(
            overlayColor: WidgetStateMapper({WidgetState.hovered: overlay}),
          ),
          icon: GlyphIcon(AppGlyphs.sync),
        ),
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byTooltip('hover')));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CardSurface>(find.byType(CardSurface)).fill,
        overlay,
      );

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(
        tester.widget<CardSurface>(find.byType(CardSurface)).fill,
        Colors.transparent,
      );
    });

    testWidgets('a background spans the button and clips to its shape', (
      tester,
    ) async {
      const key = Key('background');
      await _pump(
        tester,
        IconButton(
          tooltip: 'pane',
          onPressed: _noop,
          style: ButtonStyle(
            backgroundBuilder: (_, _, child) =>
                ColoredBox(key: key, color: Colors.black, child: child),
          ),
          icon: const GlyphIcon(AppGlyphs.sync),
        ),
        theme: _theme.copyWith(tapTargetSize: TapTargetSize.shrinkWrap),
      );

      expect(tester.getSize(find.byKey(key)), const Size.square(40));
      expect(
        tester.getCenter(find.byGlyph(AppGlyphs.sync)),
        tester.getCenter(find.byKey(key)),
      );
      expect(tester.renderObject(find.byType(CardSurface)), paints..clipPath());
    });
  });

  group('a held button', () {
    Future<TestGesture> hold(WidgetTester tester, Widget button) async {
      await _pump(tester, button);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CardSurface)),
      );
      await tester.pump();
      return gesture;
    }

    testWidgets('fades to three quarters in a light scheme', (tester) async {
      final gesture = await hold(
        tester,
        const IconButton(
          tooltip: 'held',
          onPressed: _noop,
          icon: GlyphIcon(AppGlyphs.sync),
        ),
      );

      expect(_tints(tester), hasLength(1));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_tints(tester), isEmpty);
    });

    testWidgets('mixes a fifth of white into a dark scheme', (tester) async {
      await _pump(
        tester,
        const IconButton(
          tooltip: 'held',
          onPressed: _noop,
          icon: GlyphIcon(AppGlyphs.sync),
        ),
        theme: _darkTheme,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CardSurface)),
      );
      await tester.pump();

      final layer = tester.layers.whereType<ColorFilterLayer>().single;
      expect(
        layer.colorFilter,
        const ColorFilter.matrix([
          0.8, 0, 0, 0, 51, //
          0, 0.8, 0, 0, 51, //
          0, 0, 0.8, 0, 51, //
          0, 0, 0, 1, 0, //
        ]),
      );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.layers.whereType<ColorFilterLayer>(), isEmpty);
    });

    testWidgets('left to something around it lets go at release', (
      tester,
    ) async {
      final states = <Set<WidgetState>>[];
      final gesture = await hold(
        tester,
        IconButton(
          tooltip: 'held',
          onPressed: _noop,
          style: ButtonStyle(
            pressLook: PressLook.none,
            backgroundBuilder: (_, state, child) {
              states.add({...state});
              return child!;
            },
          ),
          icon: const GlyphIcon(AppGlyphs.sync),
        ),
      );

      expect(states.last, contains(WidgetState.pressed));
      expect(_tints(tester), isEmpty);

      await gesture.up();
      await tester.pump();
      expect(states.last, isNot(contains(WidgetState.pressed)));
    });
  });

  testWidgets('a selected card that fills its selection inks in onPrimary', (
    tester,
  ) async {
    await _pump(
      tester,
      const SizedBox(
        width: 120,
        height: 64,
        child: Card(
          isSelected: true,
          fillsSelection: true,
          onPressed: _noop,
          child: Text('Card'),
        ),
      ),
    );
    final surface = tester.widget<CardSurface>(find.byType(CardSurface));
    expect(surface.fill, _theme.colorScheme.primary);
    expect(surface.look, PressLook.ink);
    expect(
      surface.inkColor,
      _theme.colorScheme.onPrimary.withValues(alpha: 0.1),
    );
  });
}

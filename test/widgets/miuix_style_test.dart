import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

const _miuix = InterfaceStyleTheme(style: InterfaceStyle.miuix);
const _material = InterfaceStyleTheme();

final _light = miuixColorScheme(Brightness.light);

Widget _styled(
  Widget child, {
  InterfaceStyleTheme style = _miuix,
  Brightness brightness = Brightness.light,
}) {
  return TestApp(
    wrapInProviderScope: true,
    homeBuilder: (child) => Theme(
      data: ThemeData(
        colorScheme: miuixColorScheme(brightness),
      ).withAppShapes.withInterfaceStyle(style),
      child: Material(child: child),
    ),
    child: child,
  );
}

Widget _flippable(Widget child, ValueNotifier<InterfaceStyleTheme> style) {
  return TestApp(
    overrides: [isMobileViewProvider.overrideWithValue(true)],
    homeBuilder: (child) => ValueListenableBuilder(
      valueListenable: style,
      builder: (_, value, child) => Theme(
        data: ThemeData(
          colorScheme: _light,
        ).withAppShapes.withInterfaceStyle(value),
        child: Material(child: child),
      ),
      child: child,
    ),
    child: child,
  );
}

class _Toggle extends StatefulWidget {
  const _Toggle({this.enabled = true});

  final bool enabled;

  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool value = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CommonSwitch(
        value: value,
        onChanged: widget.enabled
            ? (next) => setState(() => value = next)
            : null,
      ),
    );
  }
}

Finder get _track => find.descendant(
  of: find.byType(CommonSwitch),
  matching: find.byType(CustomPaint),
);

bool _toggleValue(WidgetTester tester) =>
    tester.state<_ToggleState>(find.byType(_Toggle)).value;

Widget _rows({int count = 40}) => Column(
  children: [
    for (var i = 0; i < count; i++) SizedBox(height: 50, child: Text('$i')),
  ],
);

Finder get _header => find.byType(LargeTitleHeader);

double _barHeight(WidgetTester tester) => tester
    .getSize(find.descendant(of: _header, matching: find.byType(AbsorbPointer)))
    .height;

Finder _largeTitle(String title) => find.descendant(
  of: find.descendant(of: _header, matching: find.byType(ExcludeSemantics)),
  matching: find.text(title),
);

Finder _smallTitle(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));

double _opacityOf(WidgetTester tester, Finder finder) => tester
    .widget<Opacity>(
      find.ancestor(of: finder, matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  group('theme', () {
    test('Miuix themes the components and Material keeps the stock ones', () {
      final base = ThemeData(colorScheme: _light);
      final miuix = base.withInterfaceStyle(_miuix);

      expect(miuix.splashFactory, NoSplash.splashFactory);
      expect(miuix.highlightColor, _light.onSurface.withValues(alpha: 0.1));
      expect(miuix.scaffoldBackgroundColor, _light.surface);
      expect(miuix.canvasColor, _light.surface);
      expect(miuix.cardTheme.elevation, 0);
      expect(miuix.dialogTheme.backgroundColor, _light.surfaceContainer);
      expect(miuix.dialogTheme.shape, AppShape.all(32));
      expect(miuix.bottomSheetTheme.backgroundColor, _light.surfaceContainer);
      expect(miuix.dividerTheme.thickness, 0.75);
      expect(miuix.dividerTheme.color, _light.outlineVariant);
      expect(
        miuix.switchTheme.trackColor!.resolve({WidgetState.selected}),
        _light.primary,
      );
      expect(miuix.switchTheme.trackColor!.resolve({}), _light.secondary);

      final material = base.withInterfaceStyle(_material);
      expect(material.splashFactory, base.splashFactory);
      expect(material.dialogTheme, base.dialogTheme);
      expect(material.switchTheme, base.switchTheme);
      expect(material.dividerTheme, base.dividerTheme);
    });

    test('switch colors follow the stock palette or Monet', () {
      expect(miuixSwitchColors(_light, selected: true, monet: false), (
        track: _light.primary,
        thumb: _light.onPrimary,
      ));
      expect(miuixSwitchColors(_light, selected: false, monet: false), (
        track: const Color(0xFFE6E6E6),
        thumb: const Color(0xFFFFFFFF),
      ));
      expect(miuixSwitchColors(_light, selected: false, monet: true), (
        track: _light.outlineVariant,
        thumb: _light.onSurface.withValues(alpha: 0.38),
      ));
      expect(
        miuixSwitchColors(
          _light,
          selected: true,
          monet: false,
          enabled: false,
        ).track,
        Color.alphaBlend(
          _light.primary.withValues(alpha: 0.38),
          _light.surface,
        ),
      );
    });

    test('the extension compares its Monet flag', () {
      expect(_miuix.copyWith(miuixMonet: true), isNot(_miuix));
      expect(
        _miuix.copyWith(miuixMonet: true),
        const InterfaceStyleTheme(
          style: InterfaceStyle.miuix,
          miuixMonet: true,
        ),
      );
    });
  });

  group('CommonSwitch', () {
    testWidgets('stays the Material switch outside Miuix', (tester) async {
      await tester.pumpWidget(_styled(const _Toggle(), style: _material));

      expect(find.byType(Switch), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(_toggleValue(tester), isTrue);
    });

    testWidgets('is a 49x28 capsule whose thumb springs from 4 to 25', (
      tester,
    ) async {
      await tester.pumpWidget(_styled(const _Toggle()));

      expect(find.byType(Switch), findsNothing);
      expect(tester.getSize(_track), const Size(49, 28));
      expect(tester.getSize(find.byType(CommonSwitch)), const Size(57, 48));
      expect(
        _track,
        paints
          ..rsuperellipse(color: _light.secondary)
          ..circle(x: 14, y: 14, radius: 10, color: _light.onSecondary),
      );

      await tester.tap(find.byType(CommonSwitch));
      await tester.pumpAndSettle();

      expect(_toggleValue(tester), isTrue);
      expect(
        _track,
        paints
          ..rsuperellipse(color: _light.primary)
          ..circle(x: 35, y: 14, radius: 10, color: _light.onPrimary),
      );
    });

    testWidgets('takes taps across its padded box', (tester) async {
      await tester.pumpWidget(_styled(const _Toggle()));
      final box = tester.getRect(find.byType(CommonSwitch));

      await tester.tapAt(Offset(box.center.dx, box.top + 4));
      await tester.pumpAndSettle();
      expect(_toggleValue(tester), isTrue);

      await tester.tapAt(Offset(box.left + 2, box.center.dy));
      await tester.pumpAndSettle();
      expect(_toggleValue(tester), isFalse);

      await tester.tapAt(Offset(box.center.dx, box.bottom - 4));
      await tester.pumpAndSettle();
      expect(_toggleValue(tester), isTrue);
    });

    testWidgets('reports the height it shrink-wraps to in both styles', (
      tester,
    ) async {
      for (final style in [_material, _miuix]) {
        late double reported;
        await tester.pumpWidget(
          _styled(
            Center(
              child: Builder(
                builder: (context) {
                  reported = CommonSwitch.shrinkWrappedHeightOf(context);
                  return CommonSwitch(
                    value: false,
                    onChanged: (_) {},
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
              ),
            ),
            style: style,
          ),
        );
        expect(
          tester.getSize(find.byType(CommonSwitch)).height,
          reported,
          reason: '${style.style}',
        );
      }
      expect(tester.getSize(_track).height, 28);
    });

    testWidgets('swells its thumb while pressed', (tester) async {
      await tester.pumpWidget(_styled(const _Toggle()));

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CommonSwitch)),
      );
      await tester.pump(kPressTimeout);
      await tester.pumpAndSettle();
      expect(_track, paints..circle(radius: 10 * 1.127));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(_track, paints..circle(radius: 10));
    });

    testWidgets('follows a drag past halfway and the keyboard', (tester) async {
      await tester.pumpWidget(_styled(const _Toggle()));

      await tester.drag(find.byType(CommonSwitch), const Offset(60, 0));
      await tester.pumpAndSettle();
      expect(_toggleValue(tester), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_toggleValue(tester), isFalse);
    });

    testWidgets('reports a toggle and dims and ignores taps when disabled', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_styled(const _Toggle()));
      expect(
        tester.getSemantics(find.byType(CommonSwitch)),
        isSemantics(
          hasToggledState: true,
          isToggled: false,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      await tester.pumpWidget(_styled(const _Toggle(enabled: false)));
      await tester.tap(find.byType(CommonSwitch));
      await tester.pumpAndSettle();

      expect(_toggleValue(tester), isFalse);
      expect(
        tester.getSemantics(find.byType(CommonSwitch)),
        isSemantics(isEnabled: false, hasTapAction: false),
      );
      expect(
        _track,
        paints..rsuperellipse(
          color: Color.alphaBlend(
            _light.secondary.withValues(alpha: 0.38),
            _light.surface,
          ),
        ),
      );
      semantics.dispose();
    });

    testWidgets('takes the outline track under Monet', (tester) async {
      await tester.pumpWidget(
        _styled(const _Toggle(), style: _miuix.copyWith(miuixMonet: true)),
      );

      expect(_track, paints..rsuperellipse(color: _light.outlineVariant));
    });
  });

  group('cards', () {
    ButtonStyle styleOf(WidgetTester tester, String label) => tester
        .widget<ButtonStyleButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
          ),
        )
        .style!;

    Widget cards() => Column(
      children: [
        CommonCard(
          radius: AppCorner.xl,
          onPressed: () {},
          child: const Text('plain'),
        ),
        CommonCard(
          isSelected: true,
          onPressed: () {},
          child: const Text('selected'),
        ),
        CommonCard(
          type: CommonCardType.filled,
          radius: AppCorner.sm,
          onPressed: () {},
          child: const Text('filled'),
        ),
      ],
    );

    testWidgets('Miuix cards are borderless surfaceContainer cards', (
      tester,
    ) async {
      await tester.pumpWidget(_styled(cards()));

      final plain = styleOf(tester, 'plain');
      expect(plain.backgroundColor!.resolve({}), _light.surfaceContainer);
      expect(plain.side!.resolve({}), BorderSide.none);
      expect(plain.side!.resolve({WidgetState.hovered}), BorderSide.none);
      expect(plain.shape!.resolve({}), AppShape.all(AppCorner.md));
      expect(
        styleOf(tester, 'selected').backgroundColor!.resolve({}),
        Color.alphaBlend(
          _light.primary.withValues(alpha: 0.12),
          _light.surfaceContainer,
        ),
      );
      final filled = styleOf(tester, 'filled');
      expect(filled.backgroundColor!.resolve({}), _light.surfaceContainer);
      expect(filled.shape!.resolve({}), AppShape.all(AppCorner.sm));
    });

    testWidgets('Miuix cards on a bottom sheet stand off the sheet', (
      tester,
    ) async {
      Widget onSheet(SheetType type) => _styled(
        SheetProvider(
          type: type,
          child: CommonScaffold(title: 'Sheet', body: cards()),
        ),
      );

      await tester.pumpWidget(onSheet(SheetType.bottomSheet));
      final plain = styleOf(tester, 'plain');
      expect(plain.backgroundColor!.resolve({}), _light.secondaryContainer);
      expect(plain.side!.resolve({}), BorderSide.none);
      expect(
        styleOf(tester, 'selected').backgroundColor!.resolve({}),
        Color.alphaBlend(
          _light.primary.withValues(alpha: 0.12),
          _light.secondaryContainer,
        ),
      );

      await tester.pumpWidget(onSheet(SheetType.sideSheet));
      expect(
        styleOf(tester, 'plain').backgroundColor!.resolve({}),
        _light.surfaceContainer,
      );
    });

    testWidgets('Material cards keep their outline and corners', (
      tester,
    ) async {
      await tester.pumpWidget(_styled(cards(), style: _material));

      final plain = styleOf(tester, 'plain');
      expect(plain.backgroundColor!.resolve({}), _light.surfaceContainerLow);
      expect(
        plain.side!.resolve({}),
        BorderSide(color: _light.surfaceContainerHighest),
      );
      expect(plain.shape!.resolve({}), AppShape.all(AppCorner.xl));
      expect(
        styleOf(tester, 'selected').backgroundColor!.resolve({}),
        _light.secondaryContainer,
      );
    });
  });

  group('lists', () {
    Widget section() => ListView(
      children: [
        generateSectionV3(
          title: 'Section',
          items: [
            ListItem(
              leading: const GlyphIcon(AppGlyphs.language),
              title: const Text('First'),
              onTap: () {},
            ),
            ListItem.next(title: const Text('Second'), widget: const Text('')),
            ListItem.toggle(
              title: const Text('Third'),
              value: true,
              onChanged: (_) {},
            ),
          ],
        ),
      ],
    );

    ShapeBorder? shapeOf(WidgetTester tester, String label) => tester
        .widget<FilledButton>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(FilledButton),
          ),
        )
        .style!
        .shape!
        .resolve({});

    testWidgets('Miuix groups rows into 16dp cards without dividers', (
      tester,
    ) async {
      await tester.pumpWidget(_styled(section()));

      expect(find.byType(Divider), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(find.byType(CommonSwitch), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.chevronForward), findsOneWidget);
      expect(shapeOf(tester, 'First'), AppShape.vertical(top: AppCorner.md));
      expect(shapeOf(tester, 'Third'), AppShape.vertical(bottom: AppCorner.md));
      final tile = tester.widget<ListTile>(
        find.ancestor(of: find.text('First'), matching: find.byType(ListTile)),
      );
      expect(tile.minTileHeight, 56);
      expect(tile.horizontalTitleGap, 14);
      expect(tile.iconColor, _light.onSurface);
      expect(tile.titleTextStyle?.fontSize, 17);
      expect(tile.titleTextStyle?.fontWeight, FontWeight.w500);
      expect(tester.getSize(find.byType(ListTile).first).height, 56);
      final header = tester.widget<Text>(find.text('Section')).style!;
      expect(header.fontSize, 14);
      expect(header.fontWeight, FontWeight.w700);
      expect(header.color, const Color(0xFF8C93B0));
    });

    testWidgets('Material keeps the divided xl group', (tester) async {
      await tester.pumpWidget(_styled(section(), style: _material));

      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.chevronForward), findsNothing);
      expect(shapeOf(tester, 'First'), AppShape.vertical(top: AppCorner.xl));
      final tile = tester.widget<ListTile>(
        find.ancestor(of: find.text('First'), matching: find.byType(ListTile)),
      );
      expect(tile.titleTextStyle, isNull);
      expect(tile.minTileHeight, 54);
    });

    testWidgets('a toggle without onChanged is a disabled row', (tester) async {
      Widget toggles({required bool grouped}) {
        final items = [
          ListItem.toggle(title: const Text('Off'), value: false),
          ListItem.toggle(
            title: const Text('On'),
            value: true,
            onChanged: (_) {},
          ),
        ];
        return ListView(
          children: grouped
              ? [generateSectionV3(title: 'Section', items: items)]
              : items,
        );
      }

      bool enabledOf(String label) => tester
          .widget<ListTile>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(ListTile),
            ),
          )
          .enabled;

      for (final style in [_miuix, _material]) {
        for (final grouped in [true, false]) {
          await tester.pumpWidget(
            _styled(toggles(grouped: grouped), style: style),
          );
          expect(enabledOf('Off'), isFalse);
          expect(enabledOf('On'), isTrue);
        }
      }
    });

    testWidgets('section titles take the Monet primary and dark variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        _styled(section(), style: _miuix.copyWith(miuixMonet: true)),
      );
      expect(
        tester.widget<Text>(find.text('Section')).style!.color,
        _light.primary,
      );

      await tester.pumpWidget(_styled(section(), brightness: Brightness.dark));
      expect(
        tester.widget<Text>(find.text('Section')).style!.color,
        const Color(0xFF787E96),
      );
    });

    Widget flatSection() => ListView(
      children: generateSection(
        title: 'Flat',
        items: [
          ListItem(title: const Text('A'), onTap: () {}),
          ListItem(title: const Text('B'), onTap: () {}),
        ],
      ),
    );

    testWidgets('Miuix sets a flat section into a card inside the margin', (
      tester,
    ) async {
      await tester.pumpWidget(_styled(flatSection()));

      expect(find.byType(Divider), findsNothing);
      expect(find.byType(DecorationListItem), findsNWidgets(2));
      expect(tester.getTopLeft(find.byType(DecorationListItem).first).dx, 12);
      expect(tester.getTopLeft(find.text('Flat')).dx, 28);
    });

    testWidgets('Material keeps a flat section edge to edge', (tester) async {
      await tester.pumpWidget(_styled(flatSection(), style: _material));

      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(DecorationListItem), findsNothing);
      expect(tester.getTopLeft(find.text('Flat')).dx, 16);
    });

    testWidgets('a style switch keeps the rows and their open container', (
      tester,
    ) async {
      final style = ValueNotifier(_material);
      addTearDown(style.dispose);
      await tester.pumpWidget(
        _flippable(
          CommonScaffold(
            title: 'Tools',
            body: Builder(
              builder: (context) => ListView(
                padding: EdgeInsets.only(top: context.appBarInset),
                children: generateSection(
                  title: 'Settings',
                  items: [
                    ListItem(title: const Text('Language'), onTap: () {}),
                    ListItem.open(
                      title: const Text('Theme'),
                      widget: const SizedBox(),
                    ),
                    for (var i = 0; i < 12; i++)
                      ListItem(title: Text('Row $i'), onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
          style,
        ),
      );
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      scrollable.position.jumpTo(60);
      await tester.pump();
      final openContainer = tester.state(find.byType(OpenContainer<dynamic>));

      for (final next in [_miuix, _material]) {
        style.value = next;
        await tester.pumpAndSettle();

        expect(
          find.byType(DecorationListItem),
          next.isMiuix ? findsWidgets : findsNothing,
        );
        expect(tester.state(find.byType(Scrollable)), same(scrollable));
        expect(scrollable.position.pixels, 60);
        expect(
          tester.state(find.byType(OpenContainer<dynamic>)),
          same(openContainer),
        );
      }
    });
  });

  group('large title', () {
    testWidgets('collapses into the bar as the body scrolls', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      late double inset;
      late double fallback;
      await tester.pumpWidget(
        _styled(
          Builder(
            builder: (context) {
              fallback = context.appBarInset;
              return CommonScaffold(
                title: 'Page',
                body: Builder(
                  builder: (context) {
                    inset = context.appBarInset;
                    return ListView(
                      controller: controller,
                      padding: EdgeInsets.only(top: context.appBarInset),
                      children: [_rows()],
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(inset, 96);
      expect(fallback, 96);
      expect(_barHeight(tester), 96);
      expect(tester.getSize(_largeTitle('Page')).height, 40);
      expect(tester.getTopLeft(_largeTitle('Page')), const Offset(26, 52));
      expect(tester.getTopLeft(find.text('0')).dy, 96);
      expect(_opacityOf(tester, _largeTitle('Page')), 1);
      expect(_opacityOf(tester, _smallTitle('Page')), 0);

      controller.jumpTo(8);
      await tester.pump();
      expect(_barHeight(tester), 88);
      expect(tester.getTopLeft(_largeTitle('Page')).dy, 44);
      expect(_opacityOf(tester, _largeTitle('Page')), closeTo(0.4, 1e-9));
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, _smallTitle('Page')), 0);

      controller.jumpTo(20);
      await tester.pump();
      expect(_barHeight(tester), 76);
      expect(_opacityOf(tester, _largeTitle('Page')), 0);
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, _smallTitle('Page')), 1);

      controller.jumpTo(300);
      await tester.pump();
      expect(_barHeight(tester), 56);

      controller.jumpTo(0);
      await tester.pumpAndSettle();
      expect(_barHeight(tester), 96);
      expect(_opacityOf(tester, _largeTitle('Page')), 1);
      expect(_opacityOf(tester, _smallTitle('Page')), 0);
    });

    testWidgets('reads a reversed list from its visual top', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _styled(
          CommonScaffold(
            title: 'Page',
            body: Builder(
              builder: (context) => ListView(
                reverse: true,
                controller: controller,
                padding: EdgeInsets.only(top: context.appBarInset),
                children: [_rows()],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(_barHeight(tester), 56);

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      expect(_barHeight(tester), 96);
    });

    testWidgets('keeps the body mounted as the style switches', (tester) async {
      final style = ValueNotifier(_material);
      addTearDown(style.dispose);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _flippable(
          CommonScaffold(
            title: 'Page',
            body: Builder(
              builder: (context) => ListView(
                controller: controller,
                padding: EdgeInsets.only(top: context.appBarInset),
                children: [_rows()],
              ),
            ),
          ),
          style,
        ),
      );
      controller.jumpTo(600);
      await tester.pump();
      final scrollable = tester.state(find.byType(Scrollable));

      style.value = _miuix;
      await tester.pump();
      expect(_barHeight(tester), 56);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(Scrollable)), same(scrollable));
      expect(controller.offset, 600);

      style.value = _material;
      await tester.pumpAndSettle();
      expect(_header, findsNothing);
      expect(tester.state(find.byType(Scrollable)), same(scrollable));
      expect(controller.offset, 600);
    });

    testWidgets('stays expanded for a body held clear of the bar', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _styled(
          CommonScaffold(
            title: 'Page',
            body: AppBarClearance(
              child: ListView(controller: controller, children: [_rows()]),
            ),
          ),
        ),
      );

      controller.jumpTo(100);
      await tester.pump();
      expect(_barHeight(tester), 96);
    });

    testWidgets('expands a title a replaced list left collapsed', (
      tester,
    ) async {
      final cleared = ValueNotifier(false);
      addTearDown(cleared.dispose);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _styled(
          CommonScaffold(
            title: 'Page',
            body: ValueListenableBuilder(
              valueListenable: cleared,
              builder: (context, value, _) => value
                  ? AppBarClearance(child: ListView(children: [_rows()]))
                  : ListView(
                      controller: controller,
                      padding: EdgeInsets.only(top: context.appBarInset),
                      children: [_rows()],
                    ),
            ),
          ),
        ),
      );
      controller.jumpTo(600);
      await tester.pump();
      expect(_barHeight(tester), 56);

      cleared.value = true;
      await tester.pumpAndSettle();
      expect(_barHeight(tester), 96);
    });

    testWidgets('names the page once and keeps back working', (tester) async {
      final semantics = tester.ensureSemantics();
      var backs = 0;
      await tester.pumpWidget(
        _styled(
          CommonScaffold(
            title: 'Page',
            backAction: () => backs++,
            body: const SizedBox.expand(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Page'), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      expect(backs, 1);
      semantics.dispose();
    });

    testWidgets('search, modal sheets and Material keep the upstream bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        _styled(
          CommonScaffold(
            title: 'Page',
            searchState: AppBarSearchState(onSearch: (_) {}),
            body: const SizedBox.expand(),
          ),
        ),
      );
      await tester.tap(find.byGlyph(AppGlyphs.search));
      await tester.pumpAndSettle();
      expect(_header, findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.getSize(find.byType(AppBar)).height, 64);

      for (final type in [SheetType.bottomSheet, SheetType.sideSheet]) {
        await tester.pumpWidget(
          _styled(
            SheetProvider(
              type: type,
              child: const CommonScaffold(title: 'Sheet', body: SizedBox()),
            ),
          ),
        );
        expect(_header, findsNothing, reason: '$type');
      }

      await tester.pumpWidget(
        _styled(
          const SheetProvider(
            type: SheetType.page,
            child: CommonScaffold(title: 'Sheet', body: SizedBox.expand()),
          ),
        ),
      );
      expect(_header, findsOneWidget);

      late double inset;
      await tester.pumpWidget(
        _styled(
          CommonScaffold(
            title: 'Page',
            body: Builder(
              builder: (context) {
                inset = context.appBarInset;
                return const SizedBox.expand();
              },
            ),
          ),
          style: _material,
        ),
      );
      expect(_header, findsNothing);
      expect(find.text('Page'), findsOneWidget);
      expect(inset, 64);
    });

    testWidgets('a search bar takes the upstream height in the title slot', (
      tester,
    ) async {
      late double inset;
      await tester.pumpWidget(
        _styled(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 600),
              padding: EdgeInsets.only(top: 24),
            ),
            child: CommonScaffold(
              title: 'Page',
              isLoading: true,
              searchState: AppBarSearchState(onSearch: (_) {}),
              body: Builder(
                builder: (context) {
                  inset = context.appBarInset;
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byGlyph(AppGlyphs.search));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.getRect(find.byType(AppBar)).bottom, 24 + 64);
      expect(
        tester.getRect(find.byType(LinearProgressIndicator)).bottom,
        24 + 64,
      );
      expect(inset, 24 + 96);
    });

    testWidgets('the expanded bar grows with the text scale', (tester) async {
      late double inset;
      await tester.pumpWidget(
        _styled(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Builder(
              builder: (context) {
                inset = context.appBarInset;
                return const CommonScaffold(
                  title: 'Page',
                  body: SizedBox.expand(),
                );
              },
            ),
          ),
        ),
      );

      expect(inset, 52 + 32 * 1.5 * 1.25 + 4);
      expect(_barHeight(tester), inset);
    });
  });

  group('bar blur', () {
    Widget page(InterfaceStyleTheme style) => _styled(
      const CommonScaffold(title: 'Page', body: SizedBox.expand()),
      style: style,
    );

    testWidgets('blurs the bar only when enabled', (tester) async {
      await tester.pumpWidget(page(_miuix));
      expect(find.byType(BackdropFilter), findsNothing);

      await tester.pumpWidget(page(_miuix.copyWith(barBlur: true)));
      expect(
        find.descendant(of: _header, matching: find.byType(BackdropFilter)),
        findsOneWidget,
      );

      await tester.pumpWidget(page(_material));
      expect(find.byType(BackdropFilter), findsNothing);

      await tester.pumpWidget(page(_material.copyWith(barBlur: true)));
      final blur = find.descendant(
        of: find.byType(FloatingHeader),
        matching: find.byType(BackdropFilter),
      );
      expect(blur, findsOneWidget);
      expect(tester.getSize(blur).height, 64);
    });
  });
}

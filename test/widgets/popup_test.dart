import 'dart:typed_data';

import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/liquid_glass.dart';
import 'package:fl_clash/ui/navigation_dock.dart';
import 'package:fl_clash/ui/popup.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind, kPressTimeout;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final surfaces = find.byType(PopupMenuCard);

  PopupMenuCard cardOf(WidgetTester tester, Finder surface) =>
      tester.widget<PopupMenuCard>(surface);

  double shadowOf(WidgetTester tester, Finder surface) => cardOf(
    tester,
    surface,
  ).shadows.fold(0.0, (sum, shadow) => sum + shadow.color.a);

  Rect shrinkingContent(WidgetTester tester) {
    final content = tester.layers.whereType<ImageFilterLayer>().last;
    final transform = content.firstChild! as TransformLayer;
    final popup = tester.getRect(find.byKey(const Key('popup')));
    return MatrixUtils.transformRect(
      transform.transform!,
      Offset.zero & popup.size,
    ).shift(popup.topLeft);
  }

  Rect painted(WidgetTester tester, Finder press) {
    final resting = tester.getRect(press);
    Matrix4? transform;
    expect(
      tester.renderObject<RenderProxyBox>(press).child,
      paints..everything((method, arguments) {
        if (method == #transform) {
          transform ??= Matrix4.fromFloat64List(
            arguments.single as Float64List,
          );
        }
        return true;
      }),
    );
    final local = Offset.zero & resting.size;
    return (transform == null
            ? local
            : MatrixUtils.transformRect(transform!, local))
        .shift(resting.topLeft);
  }

  Future<PopupOpen> pumpBox(WidgetTester tester) async {
    late PopupOpen open;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CommonPopupBox(
              targetBuilder: (value) {
                open = value;
                return const SizedBox(width: 40, height: 40);
              },
              popupBuilder: (_) =>
                  const SizedBox(width: 80, height: 80, key: Key('popup')),
            ),
          ),
        ),
      ),
    );
    return open;
  }

  Future<PopupOpen> pumpMenu(
    WidgetTester tester,
    List<CommonPopupMenuItem> items, {
    int? maxVisibleItems,
  }) async {
    late PopupOpen open;
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: Center(child: child)),
        child: CommonPopupBox(
          targetBuilder: (value) {
            open = value;
            return const SizedBox(width: 40, height: 40);
          },
          popupBuilder: (_) =>
              CommonPopupMenu(items: items, maxVisibleItems: maxVisibleItems),
        ),
      ),
    );
    return open;
  }

  testWidgets('opening pushes the popup above the target', (tester) async {
    final open = await pumpBox(tester);

    open();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('popup')), findsOneWidget);
  });

  testWidgets('a menu over a button at the top covers the bar it stands in', (
    tester,
  ) async {
    late PopupOpen open;
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 40, height: 40, key: Key('neighbour')),
              CommonPopupBox(
                targetBuilder: (value) {
                  open = value;
                  return const SizedBox(width: 40, height: 40);
                },
                popupBuilder: (_) => CommonPopupMenu(
                  items: [CommonPopupMenuItem(label: 'one', onPressed: () {})],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    open();
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(PopupMenuCard)).top,
      lessThan(tester.getRect(find.byKey(const Key('neighbour'))).top),
    );
  });

  testWidgets('a popup fills from the elevated surface it opened on', (
    tester,
  ) async {
    const lifted = Color(0xFF505050);
    late PopupOpen open;
    await tester.pumpWidget(
      TestApp(
        theme: ThemeData(
          extensions: const [
            ElevatedColorScheme(ColorScheme.dark(surfaceContainerHigh: lifted)),
          ],
        ),
        homeBuilder: (child) => Scaffold(body: Center(child: child)),
        child: ElevatedSurfaceTheme(
          child: CommonPopupBox(
            targetBuilder: (value) {
              open = value;
              return const SizedBox(width: 40, height: 40);
            },
            popupBuilder: (_) => CommonPopupMenu(
              items: [CommonPopupMenuItem(label: 'one', onPressed: () {})],
            ),
          ),
        ),
      ),
    );

    open();
    await tester.pumpAndSettle();

    expect(cardOf(tester, find.byType(PopupMenuCard)).fill, lifted);
  });

  testWidgets('the popup is only built once it opens', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CommonPopupBox(
              targetBuilder: (_) => const SizedBox(width: 40, height: 40),
              popupBuilder: (_) {
                builds++;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(builds, 0);
  });

  testWidgets('the box can be removed while its popup is still up', (
    tester,
  ) async {
    // The box goes away under an open popup while the navigator carrying that
    // popup stays; the route then holds an anchor it can no longer measure.
    final showBox = ValueNotifier<bool>(true);
    addTearDown(showBox.dispose);
    late PopupOpen open;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: showBox,
              builder: (_, visible, _) {
                if (!visible) {
                  return const SizedBox.shrink();
                }
                return CommonPopupBox(
                  targetBuilder: (value) {
                    open = value;
                    return const SizedBox(width: 40, height: 40);
                  },
                  popupBuilder: (_) =>
                      const SizedBox(width: 80, height: 80, key: Key('popup')),
                );
              },
            ),
          ),
        ),
      ),
    );

    open();
    await tester.pumpAndSettle();

    showBox.value = false;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('popup')), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('popup')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a point placement opens the popup from that point', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.expand();
          },
        ),
      ),
    );

    Navigator.of(context).push(
      CommonPopupRoute<void>(
        barrierLabel: 'Dismiss',
        placement: PopupPlacement.belowPoint,
        anchorOf: () => const Offset(100, 120) & Size.zero,
        builder: (_) =>
            const SizedBox(width: 80, height: 80, key: Key('popup')),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byKey(const Key('popup'))),
      const Offset(100, 120),
    );
  });

  for (final (name, point, avoid, top) in [
    ('flips above a point too close to the bottom', 560.0, null, 480.0),
    (
      'sits above the rect it avoids',
      250.0,
      const Rect.fromLTRB(0, 200, 800, 300),
      112.0,
    ),
    (
      'drops below the rect it avoids when above is full',
      250.0,
      const Rect.fromLTRB(0, 40, 800, 300),
      308.0,
    ),
  ]) {
    testWidgets('a point placement $name', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox.expand();
            },
          ),
        ),
      );

      Navigator.of(context).push(
        CommonPopupRoute<void>(
          barrierLabel: 'Dismiss',
          placement: PopupPlacement.belowPoint,
          anchorOf: () => Offset(100, point) & Size.zero,
          avoid: avoid,
          builder: (_) =>
              const SizedBox(width: 80, height: 80, key: Key('popup')),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.byKey(const Key('popup'))).dy, top);
    });
  }

  testWidgets(
    'a point placement flips above a point the keyboard would cover',
    (tester) async {
      tester.view.viewInsets = const FakeViewPadding(bottom: 900);
      addTearDown(tester.view.resetViewInsets);
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const SizedBox.expand();
            },
          ),
        ),
      );

      Navigator.of(context).push(
        CommonPopupRoute<void>(
          barrierLabel: 'Dismiss',
          placement: PopupPlacement.belowPoint,
          anchorOf: () => const Offset(100, 250) & Size.zero,
          builder: (_) =>
              const SizedBox(width: 80, height: 80, key: Key('popup')),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getBottomLeft(find.byKey(const Key('popup'))).dy, 250);
    },
  );

  testWidgets('a non-modal popup lets touches and focus stay on the page', (
    tester,
  ) async {
    var taps = 0;
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return Focus(
              focusNode: focusNode,
              autofocus: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    Navigator.of(context).push(
      CommonPopupRoute<void>(
        barrierLabel: 'Dismiss',
        placement: PopupPlacement.belowPoint,
        modal: false,
        anchorOf: () => const Offset(100, 120) & Size.zero,
        builder: (_) =>
            const SizedBox(width: 80, height: 80, key: Key('popup')),
      ),
    );
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(taps, 1);
    expect(find.byKey(const Key('popup')), findsNothing);
    expect(focusNode.hasFocus, isTrue);
  });

  testWidgets('only a checked item carries a check', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'on', checked: true),
      const CommonPopupMenuItem(label: 'off', checked: false),
      const CommonPopupMenuItem(label: 'plain'),
    ]);
    open();
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.ancestor(of: find.text('on'), matching: find.byType(Row)),
        matching: find.byGlyph(AppGlyphs.check),
      ),
      findsOneWidget,
    );
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
  });

  testWidgets('a subtitle stands under its label, capped menu or not', (
    tester,
  ) async {
    for (final maxVisibleItems in [null, 7]) {
      final open = await pumpMenu(tester, [
        const CommonPopupMenuItem(
          label: 'Access',
          subtitle: 'Selected 2',
          checked: true,
        ),
        const CommonPopupMenuItem(label: 'Plain'),
      ], maxVisibleItems: maxVisibleItems);
      open();
      await tester.pumpAndSettle();

      final label = tester.getRect(find.text('Access'));
      final subtitle = tester.getRect(find.text('Selected 2'));
      expect(subtitle.top, greaterThanOrEqualTo(label.bottom));
      expect(subtitle.left, label.left);
      expect(
        tester.getRect(find.text('Plain')).top,
        greaterThanOrEqualTo(subtitle.bottom),
      );

      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('a section sets its items apart under its title', (tester) async {
    final taps = <String>[];
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(
        label: 'On',
        checked: true,
        section: const CommonPopupMenuSection(title: 'Power'),
        onPressed: () => taps.add('On'),
      ),
      CommonPopupMenuItem(label: 'Off', onPressed: () => taps.add('Off')),
      CommonPopupMenuItem(
        label: 'Settings',
        section: const CommonPopupMenuSection(),
        onPressed: () => taps.add('Settings'),
      ),
    ], maxVisibleItems: 7);
    open();
    await tester.pumpAndSettle();

    final dividers = find.descendant(
      of: find.byType(CommonPopupMenu),
      matching: find.byType(Divider),
    );
    expect(dividers, findsOneWidget);
    final title = tester.getRect(find.text('Power'));
    final on = tester.getRect(find.text('On'));
    final divider = tester.getRect(dividers);
    expect(title.bottom, lessThanOrEqualTo(on.top));
    expect(title.left, on.left);
    expect(
      divider.top,
      greaterThanOrEqualTo(tester.getRect(find.text('Off')).bottom),
    );
    expect(
      divider.bottom,
      lessThanOrEqualTo(tester.getRect(find.text('Settings')).top),
    );

    await tester.tap(find.text('Power'));
    await tester.pumpAndSettle();
    expect(taps, isEmpty);
    expect(find.byType(CommonPopupMenu), findsOneWidget);

    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
    expect(taps, ['Off']);
  });

  testWidgets('the popup grows out of its anchor and closes back into it', (
    tester,
  ) async {
    final open = await pumpBox(tester);
    final anchor = tester.getRect(find.byType(CommonPopupBox));
    double sourceOpacity() => tester
        .widget<Opacity>(
          find.descendant(
            of: find.byType(CommonPopupBox),
            matching: find.byType(Opacity),
          ),
        )
        .opacity;
    Rect? platter() {
      final clips = tester.layers.whereType<ClipPathLayer>();
      return clips.isEmpty ? null : clips.last.clipPath!.getBounds();
    }

    open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final opening = platter()!;
    final popup = tester.getRect(find.byKey(const Key('popup')));
    expect(opening.width, lessThan(popup.width));
    expect(opening.height, lessThan(popup.height));
    expect(opening.overlaps(anchor), isTrue);

    await tester.pumpAndSettle();
    expect(platter(), isNull);
    expect(sourceOpacity(), 0);

    Navigator.of(tester.element(find.byKey(const Key('popup')))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final closing = shrinkingContent(tester);
    expect(closing.width, lessThan(popup.width));
    expect(closing.overlaps(anchor), isTrue);

    await tester.pumpAndSettle();
    expect(find.byKey(const Key('popup')), findsNothing);
    expect(sourceOpacity(), 1);
  });

  testWidgets('the platter flies to the popup center on an arc', (
    tester,
  ) async {
    final open = await pumpBox(tester);
    final anchor = tester.getRect(find.byType(CommonPopupBox)).center;
    Offset platter() => tester.layers
        .whereType<ClipPathLayer>()
        .last
        .clipPath!
        .getBounds()
        .center;

    open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final opening = platter();
    final popup = tester.getRect(find.byKey(const Key('popup'))).center;
    final across = (opening.dx - anchor.dx) / (popup.dx - anchor.dx);
    final down = (opening.dy - anchor.dy) / (popup.dy - anchor.dy);
    expect(across, greaterThan(0));
    expect(down, greaterThan(across + 0.1));

    await tester.pumpAndSettle();
    Navigator.of(tester.element(find.byKey(const Key('popup')))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final closing = shrinkingContent(tester).center;
    final back = (popup.dx - closing.dx) / (popup.dx - anchor.dx);
    final up = (popup.dy - closing.dy) / (popup.dy - anchor.dy);
    expect(back, greaterThan(up + 0.1));
    await tester.pumpAndSettle();
  });

  testWidgets('a popup from a point shrinks toward it as it fades', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    const point = Offset(100, 120);
    Navigator.of(context).push(
      CommonPopupRoute<void>(
        barrierLabel: 'Dismiss',
        placement: PopupPlacement.belowPoint,
        anchorOf: () => point & Size.zero,
        builder: (_) =>
            const SizedBox(width: 80, height: 80, key: Key('popup')),
      ),
    );
    await tester.pumpAndSettle();

    Navigator.of(context).pop();
    await tester.pump();
    var alpha = 255;
    var faded = false;
    while (find.byKey(const Key('popup')).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 16));
      final opacity = tester.layers
          .whereType<OpacityLayer>()
          .where((layer) => layer.parent is TransformLayer)
          .lastOrNull;
      if (opacity == null) {
        continue;
      }
      final transform = (opacity.parent! as TransformLayer).transform!;
      final scale = transform.entry(0, 0);
      expect(scale, greaterThanOrEqualTo(0.8));
      expect(
        MatrixUtils.transformPoint(transform, point),
        offsetMoreOrLessEquals(point),
      );
      expect(
        1 - opacity.alpha! / 255,
        moreOrLessEquals((1 - scale) / 0.2, epsilon: 0.01),
      );
      expect(tester.layers.whereType<ImageFilterLayer>(), isEmpty);
      expect(opacity.alpha!, lessThanOrEqualTo(alpha));
      alpha = opacity.alpha!;
      faded = faded || alpha < 64;
    }
    expect(faded, isTrue);
  });

  testWidgets('dismissing the barrier closes the popup', (tester) async {
    final open = await pumpBox(tester);
    open();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('popup')), findsNothing);
  });

  testWidgets('a sub menu opens above the level that owns it', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    expect(find.byGlyph(AppGlyphs.chevronForward), findsOneWidget);

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsOneWidget);
    expect(surfaces, findsNWidgets(2));
    expect(find.text('parent'), findsNWidgets(2));
  });

  testWidgets('a sub menu opened mid-flight is not held in the platter', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    bool inPlatter() => tester.layers.whereType<ImageFilterLayer>().isNotEmpty;

    open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(inPlatter(), isTrue);

    await tester.tap(find.text('parent'), warnIfMissed: false);
    await tester.pump();

    expect(inPlatter(), isFalse);
    await tester.pumpAndSettle();
  });

  testWidgets('the sub menu header lands exactly on the opening item', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'first'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final itemTop = tester.getTopLeft(find.text('parent')).dy;

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('parent').last).dy, itemTop);
  });

  testWidgets('the menu stays between its min and max width', (tester) async {
    Future<double> widthOf(String label) async {
      final open = await pumpMenu(tester, [CommonPopupMenuItem(label: label)]);
      open();
      await tester.pumpAndSettle();
      final width = tester.getSize(surfaces).width;
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      return width;
    }

    expect(await widthOf('a'), 160);
    expect(
      await widthOf('a label far too long to ever fit inside a menu'),
      280,
    );
  });

  testWidgets('only a sub menu carries a divider, under its header', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'first'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    expect(find.byType(Divider), findsNothing);

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsOneWidget);
    final header = find.ancestor(
      of: find.text('parent').last,
      matching: find.byType(InkWell),
    );
    final divider = find.byType(Divider);
    expect(tester.getTopLeft(divider).dy, tester.getBottomLeft(header).dy);
    expect(tester.getSize(divider).height, 17);
    expect(
      tester.getTopLeft(find.text('child')).dy -
          tester.getBottomLeft(divider).dy,
      greaterThanOrEqualTo(12),
    );
  });

  testWidgets('the header folds the sub menu back into its item', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsOneWidget);
  });

  testWidgets('a sub menu can be opened again after it was folded back', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('back walks one level up and leaves the popup open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsOneWidget);
  });

  testWidgets('a tap outside closes every level at once', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsNothing);
  });

  testWidgets('picking an item runs it and closes the popup', (tester) async {
    var pressed = 0;
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'run', onPressed: () => pressed++),
      const CommonPopupMenuItem(label: 'disabled'),
    ]);
    open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('disabled'));
    await tester.pumpAndSettle();
    expect(find.text('run'), findsOneWidget);

    await tester.tap(find.text('run'));
    await tester.pumpAndSettle();

    expect(pressed, 1);
    expect(find.text('run'), findsNothing);
  });

  testWidgets('a menu swells under a press and stretches only past its edges', (
    tester,
  ) async {
    var pressed = 0;
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'one', onPressed: () => pressed++),
      CommonPopupMenuItem(label: 'two', onPressed: () => pressed++),
    ]);
    open();
    await tester.pumpAndSettle();
    final press = find.descendant(
      of: find.byType(CommonPopupMenu),
      matching: find.byType(ElasticPress),
    );
    final resting = tester.getRect(press);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('one')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final swollen = painted(tester, press);
    expect(swollen.width, greaterThan(resting.width + 4));
    expect(swollen.center.dx, moreOrLessEquals(resting.center.dx));

    await gesture.moveTo(tester.getCenter(find.text('two')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      painted(tester, press).center.dx,
      moreOrLessEquals(swollen.center.dx),
    );
    expect(
      painted(tester, press).center.dy,
      moreOrLessEquals(swollen.center.dy),
    );

    await gesture.moveTo(Offset(resting.left - 80, resting.center.dy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final pulled = painted(tester, press);
    expect(pulled.center.dx, lessThan(resting.center.dx - 4));
    expect(
      pulled.width / pulled.height,
      greaterThan(resting.width / resting.height),
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(painted(tester, press), resting);
    expect(pressed, 0);
    expect(find.text('one'), findsOneWidget);
  });

  bool pressedRow(WidgetTester tester, String label) {
    final box = tester.widget<DecoratedBox>(
      find
          .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
          .first,
    );
    return (box.decoration as ShapeDecoration).color != null;
  }

  List<Object?> recordHaptics(WidgetTester tester) {
    final haptics = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return haptics;
  }

  testWidgets('a press follows the finger and picks the item let go on', (
    tester,
  ) async {
    final clicks = recordHaptics(tester);
    final picked = <String>[];
    final open = await pumpMenu(tester, [
      for (final label in ['one', 'two', 'three'])
        CommonPopupMenuItem(label: label, onPressed: () => picked.add(label)),
    ]);
    open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('one')),
    );
    await tester.pump();
    expect(pressedRow(tester, 'one'), isTrue);

    await gesture.moveTo(tester.getCenter(find.text('three')));
    await tester.pump();
    expect(pressedRow(tester, 'one'), isFalse);
    expect(pressedRow(tester, 'three'), isTrue);
    expect(clicks, ['HapticFeedbackType.selectionClick']);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(picked, ['three']);
    expect(find.text('one'), findsNothing);
  });

  testWidgets('a press let go off the items picks nothing', (tester) async {
    final picked = <String>[];
    final open = await pumpMenu(tester, [
      for (final label in ['one', 'two'])
        CommonPopupMenuItem(label: label, onPressed: () => picked.add(label)),
    ]);
    open();
    await tester.pumpAndSettle();
    final menu = tester.getRect(find.byType(CommonPopupMenu));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('one')),
    );
    await tester.pump();
    await gesture.moveTo(Offset(menu.left - 60, menu.center.dy));
    await tester.pump();
    expect(pressedRow(tester, 'one'), isFalse);
    expect(pressedRow(tester, 'two'), isFalse);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(picked, isEmpty);
    expect(find.text('one'), findsOneWidget);
  });

  testWidgets('a drag that scrolls a long menu lets go of the press', (
    tester,
  ) async {
    final picked = <String>[];
    final open = await pumpMenu(tester, [
      for (var index = 0; index < 30; index++)
        CommonPopupMenuItem(
          label: 'item $index',
          onPressed: () => picked.add('item $index'),
        ),
    ]);
    open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('item 3')),
    );
    await tester.pump();
    for (var step = 0; step < 5; step++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump();
    }
    expect(pressedRow(tester, 'item 3'), isFalse);
    expect(
      tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels,
      greaterThan(0),
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(picked, isEmpty);
    expect(find.text('item 3'), findsOneWidget);
  });

  Future<List<String>> pumpButtonMenu(
    WidgetTester tester, {
    bool enabled = true,
  }) async {
    final picked = <String>[];
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: Center(child: child)),
        child: CommonPopupBox(
          targetBuilder: (open) => TextButton(
            onPressed: enabled ? open : null,
            child: const Text('menu'),
          ),
          popupBuilder: (_) => CommonPopupMenu(
            items: [
              for (final label in ['one', 'two', 'three'])
                CommonPopupMenuItem(
                  label: label,
                  onPressed: () => picked.add(label),
                ),
            ],
          ),
        ),
      ),
    );
    return picked;
  }

  testWidgets('a press on the button opens its menu to slide on into', (
    tester,
  ) async {
    final picked = await pumpButtonMenu(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('menu')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CommonPopupMenu), findsOneWidget);

    await gesture.moveTo(tester.getCenter(find.text('two')));
    await tester.pump();
    expect(pressedRow(tester, 'two'), isTrue);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(picked, ['two']);
    expect(find.byType(CommonPopupMenu), findsNothing);
  });

  testWidgets('a press let go where it went down leaves the menu open', (
    tester,
  ) async {
    final picked = await pumpButtonMenu(tester);

    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();

    expect(find.byType(CommonPopupMenu), findsOneWidget);
    expect(picked, isEmpty);
  });

  testWidgets('a pick runs once the popup has returned into its button', (
    tester,
  ) async {
    final picked = await pumpButtonMenu(tester);
    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('two'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CommonPopupMenu), findsOneWidget);
    expect(picked, isEmpty);

    await tester.pumpAndSettle();
    expect(picked, ['two']);
  });

  testWidgets('a pick from a popup at a point runs at once', (tester) async {
    late BuildContext context;
    final picked = <String>[];
    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    Navigator.of(context).push(
      CommonPopupRoute<void>(
        barrierLabel: 'Dismiss',
        placement: PopupPlacement.belowPoint,
        anchorOf: () => const Offset(100, 120) & Size.zero,
        builder: (_) => CommonPopupMenu(
          items: [
            CommonPopupMenuItem(
              label: 'one',
              onPressed: () => picked.add('one'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('one'));
    await tester.pump();
    expect(picked, ['one']);
    await tester.pumpAndSettle();
  });

  testWidgets('a popup value fades across as its width eases over', (
    tester,
  ) async {
    Widget value(String text) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: PopupValueText(text, alignment: AlignmentDirectional.centerEnd),
      ),
    );
    await tester.pumpWidget(value('short'));
    final from = tester.getSize(find.byType(PopupValueText)).width;

    await tester.pumpWidget(value('a much longer value'));
    final to = tester
        .getSize(find.text('a much longer value', skipOffstage: false))
        .width;
    await tester.pump(const Duration(milliseconds: 100));
    final easing = tester.getSize(find.byType(PopupValueText)).width;
    expect(easing, greaterThan(from));
    expect(easing, lessThan(to));
    expect(find.text('short'), findsOneWidget);
    expect(
      tester
          .widgetList<ImageFiltered>(find.byType(ImageFiltered))
          .where((filter) => filter.enabled),
      hasLength(2),
    );

    await tester.pumpAndSettle();
    expect(find.text('short'), findsNothing);
    expect(tester.getSize(find.byType(PopupValueText)).width, to);
    expect(
      tester
          .widgetList<ImageFiltered>(find.byType(ImageFiltered))
          .where((filter) => filter.enabled),
      isEmpty,
    );
  });

  testWidgets('a disabled button opens nothing under a press', (tester) async {
    await pumpButtonMenu(tester, enabled: false);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('menu')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CommonPopupMenu), findsNothing);
    await gesture.up();
  });

  testWidgets('a press resting on an item opens its sub menu to slide into', (
    tester,
  ) async {
    final clicks = recordHaptics(tester);
    final picked = <String>[];
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'other', onPressed: () => picked.add('other')),
      CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(
            label: 'child',
            onPressed: () => picked.add('child'),
          ),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('other')),
    );
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('parent')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('child'), findsNothing);
    expect(clicks, hasLength(1));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
    expect(clicks, hasLength(2));

    await gesture.moveTo(tester.getCenter(find.text('child')));
    await tester.pump();
    expect(clicks, hasLength(3));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(picked, ['child']);
  });

  testWidgets('a press resting on the header folds its sub menu back', (
    tester,
  ) async {
    final clicks = recordHaptics(tester);
    final picked = <String>[];
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(
            label: 'child',
            onPressed: () => picked.add('child'),
          ),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final header = tester.getCenter(find.text('parent'));
    final gesture = await tester.startGesture(header);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await gesture.moveTo(tester.getCenter(find.text('child')));
    await tester.pump();
    await gesture.moveTo(header);
    await tester.pump();
    expect(clicks, hasLength(3));

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsNothing);
    expect(clicks, hasLength(4));
    expect(pressedRow(tester, 'parent'), isTrue);

    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsOneWidget);
    expect(picked, isEmpty);
  });

  testWidgets('a tap that folds a sub menu back gives no click', (
    tester,
  ) async {
    final clicks = recordHaptics(tester);
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(clicks, isEmpty);
  });

  testWidgets('a press let go where its sub menu opened keeps it open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('parent')),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('a press held on the button keeps its tooltip down', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: Center(child: child)),
        child: CommonPopupBox(
          targetBuilder: (open) => IconButton(
            tooltip: 'tip',
            onPressed: open,
            icon: const GlyphIcon(AppGlyphs.more),
          ),
          popupBuilder: (_) => CommonPopupMenu(
            items: [CommonPopupMenuItem(label: 'one', onPressed: () {})],
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(IconButton)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('one'), findsOneWidget);
    await gesture.up();
    await tester.pump();

    expect(find.text('tip'), findsNothing);
  });

  Future<List<String>> pumpScrollingButtonMenu(WidgetTester tester) async {
    final picked = <String>[];
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: child),
        child: ListView(
          children: [
            const SizedBox(height: 200),
            Center(
              child: CommonPopupBox(
                targetBuilder: (open) =>
                    TextButton(onPressed: open, child: const Text('menu')),
                popupBuilder: (_) => CommonPopupMenu(
                  items: [
                    for (final label in ['one', 'two', 'three'])
                      CommonPopupMenuItem(
                        label: label,
                        onPressed: () => picked.add(label),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    );
    return picked;
  }

  testWidgets('in a scroll view a drag from the button scrolls instead', (
    tester,
  ) async {
    await pumpScrollingButtonMenu(tester);
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('menu')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
    expect(find.byType(CommonPopupMenu), findsNothing);
  });

  testWidgets('in a scroll view a press held on the button opens its menu', (
    tester,
  ) async {
    await pumpScrollingButtonMenu(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('menu')),
    );
    await tester.pump(kPressTimeout ~/ 2);
    expect(find.byType(CommonPopupMenu), findsNothing);
    await tester.pump(kPressTimeout);
    await tester.pumpAndSettle();
    expect(find.byType(CommonPopupMenu), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(CommonPopupMenu), findsOneWidget);
  });

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('in a scroll view a ${kind.name} press held on the button '
        'slides on into its menu', (tester) async {
      final picked = await pumpScrollingButtonMenu(tester);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('menu')),
        kind: kind,
      );
      await tester.pump(kPressTimeout);
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.text('two')));
      await tester.pump();
      expect(pressedRow(tester, 'two'), isTrue);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(picked, ['two']);
      expect(find.byType(CommonPopupMenu), findsNothing);
    });
  }

  testWidgets('in a scroll view a tap on the button opens its menu', (
    tester,
  ) async {
    await pumpScrollingButtonMenu(tester);

    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();

    expect(find.byType(CommonPopupMenu), findsOneWidget);
  });

  testWidgets('a press carried in from the button stretches the menu', (
    tester,
  ) async {
    await pumpButtonMenu(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('menu')),
    );
    await tester.pumpAndSettle();
    final press = find.descendant(
      of: find.byType(CommonPopupMenu),
      matching: find.byType(ElasticPress),
    );
    final resting = tester.getRect(press);

    await gesture.moveTo(Offset(resting.left - 80, resting.center.dy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final pulled = painted(tester, press);
    expect(pulled.center.dx, lessThan(resting.center.dx - 4));
    expect(pulled.width, greaterThan(resting.width));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(painted(tester, press), resting);
  });

  testWidgets('a press carried in while the menu opens stretches it only '
      'once the platter steps aside', (tester) async {
    await pumpButtonMenu(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('menu')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final press = find.descendant(
      of: find.byType(CommonPopupMenu),
      matching: find.byType(ElasticPress),
    );
    final resting = tester.getRect(press);

    await gesture.moveTo(Offset(resting.left - 80, resting.center.dy));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(painted(tester, press), resting);

    await tester.pumpAndSettle();
    await gesture.moveBy(const Offset(-1, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(painted(tester, press).center.dx, lessThan(resting.center.dx - 4));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a capped menu opens on its checked item and cuts a row at '
      'its foot', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final open = await pumpMenu(tester, [
      for (var i = 0; i < 30; i++)
        CommonPopupMenuItem(
          label: 'Item $i',
          checked: i == 20,
          onPressed: () {},
        ),
    ], maxVisibleItems: 5);
    open();
    await tester.pumpAndSettle();

    final menu = tester.getRect(find.byType(PopupMenuCard));
    final checked = tester.getRect(find.text('Item 20'));
    final cut = tester.getRect(find.text('Item 23'));
    expect(checked.top, greaterThan(menu.top));
    expect(checked.bottom, lessThan(menu.bottom));
    expect(
      tester.getRect(find.text('Item 17', skipOffstage: false)).bottom,
      lessThan(menu.top),
    );
    expect(cut.top, lessThan(menu.bottom));
    expect(cut.bottom, greaterThan(menu.bottom));
  });

  testWidgets('a long menu caps itself well short of a tall window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final open = await pumpMenu(tester, [
      for (var i = 0; i < 30; i++)
        CommonPopupMenuItem(label: 'Item $i', onPressed: () {}),
    ]);
    open();
    await tester.pumpAndSettle();

    final menu = tester.getRect(find.byType(PopupMenuCard));
    final cut = tester.getRect(find.text('Item 7'));
    expect(menu.height, lessThan(800));
    expect(cut.top, lessThan(menu.bottom));
    expect(cut.bottom, greaterThan(menu.bottom));
  });

  testWidgets('a capped menu is as wide as its rows laid out in full', (
    tester,
  ) async {
    final items = [
      CommonPopupMenuItem(label: '🇭🇰 HK', onPressed: () {}),
      CommonPopupMenuItem(label: 'Fallback', checked: true, onPressed: () {}),
      for (var i = 0; i < 12; i++)
        CommonPopupMenuItem(label: 'Group $i', onPressed: () {}),
    ];
    Future<double> widthOf(int? maxVisibleItems) async {
      final open = await pumpMenu(
        tester,
        items,
        maxVisibleItems: maxVisibleItems,
      );
      open();
      await tester.pumpAndSettle();
      final width = tester.getSize(find.byType(PopupMenuCard)).width;
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      return width;
    }

    final full = await widthOf(null);
    expect(full, inExclusiveRange(160, 280));
    expect(await widthOf(5), moreOrLessEquals(full, epsilon: 0.5));
  });

  testWidgets('a danger item keeps the error color off its background', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'plain', onPressed: () {}),
      CommonPopupMenuItem(
        glyph: AppGlyphs.delete,
        label: 'delete',
        danger: true,
        onPressed: () {},
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final colorScheme = Theme.of(
      tester.element(find.text('delete')),
    ).colorScheme;

    expect(
      tester.widget<Text>(find.text('delete')).style?.color,
      colorScheme.error,
    );
    expect(
      tester.widget<GlyphIcon>(find.byGlyph(AppGlyphs.delete)).color,
      colorScheme.error,
    );
    expect(
      find.ancestor(of: find.text('delete'), matching: find.byType(Ink)),
      findsNothing,
    );
    expect(
      tester
          .widget<InkWell>(
            find.ancestor(
              of: find.text('delete'),
              matching: find.byType(InkWell),
            ),
          )
          .hoverColor,
      colorScheme.error.withValues(alpha: 0.1),
    );
    expect(
      tester.widget<Text>(find.text('plain')).style?.color,
      colorScheme.onSurface,
    );
    expect(
      tester
          .widget<InkWell>(
            find.ancestor(
              of: find.text('plain'),
              matching: find.byType(InkWell),
            ),
          )
          .hoverColor,
      isNull,
    );
  });

  testWidgets('a sub menu is at least as wide as its parent', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'a label long enough to widen the parent menu',
      ),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'x')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(surfaces, findsNWidgets(2));
    final parentWidth = tester.getSize(surfaces.first).width;
    final childWidth = tester.getSize(surfaces.last).width;
    expect(childWidth, greaterThanOrEqualTo(parentWidth));
  });

  testWidgets('the open sub menu casts the stronger shadow', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(surfaces, findsNWidgets(2));
    expect(
      shadowOf(tester, surfaces.first),
      lessThan(shadowOf(tester, surfaces.last)),
    );
  });

  testWidgets('a sub menu settles wider than the parent it opened from', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final parentWidth = tester.getSize(surfaces).width;

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(surfaces.last).width,
      closeTo(parentWidth * 1.12, 0.01),
    );
  });

  testWidgets('a sub menu grows out of its item instead of snapping open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final parentWidth = tester.getSize(surfaces).width;

    await tester.tap(find.text('parent'));
    await tester.pump();

    final active = surfaces.last;
    expect(tester.getSize(active).width, parentWidth);
    expect(shadowOf(tester, active), 0);

    await tester.pump(const Duration(milliseconds: 40));
    final midWidth = tester.getSize(active).width;
    expect(midWidth, greaterThan(parentWidth));
    expect(midWidth, lessThan(parentWidth * 1.12));

    await tester.pumpAndSettle();
    expect(tester.getSize(active).width, closeTo(parentWidth * 1.12, 0.01));
  });

  testWidgets('a sub menu settles its width before it finishes unfolding', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(label: 'first child'),
          CommonPopupMenuItem(label: 'second child'),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final parentWidth = tester.getSize(surfaces).width;

    await tester.tap(find.text('parent'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    final active = surfaces.last;
    final midWidth = tester.getSize(active).width;
    expect(midWidth, greaterThanOrEqualTo(parentWidth * 1.12));
    expect(cardOf(tester, active).grow, lessThan(1));

    await tester.pumpAndSettle();
    expect(tester.getSize(active).width, midWidth);
    expect(cardOf(tester, active).grow, 1);
  });

  testWidgets('a sub menu widening as it unfolds keeps its rows unclipped', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'a label long enough to widen the parent menu',
      ),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    Rect clipOf(Finder surface) {
      Rect? clip;
      expect(
        tester.renderObject(surface),
        paints..everything((method, arguments) {
          if (method == #clipPath) {
            clip ??= (arguments.first as Path).getBounds();
          }
          return true;
        }),
      );
      return clip!.shift(tester.getTopLeft(surface));
    }

    Rect rowOf(Finder label) => tester.getRect(
      find.ancestor(of: label, matching: find.byType(InkWell)).first,
    );

    await tester.tap(find.text('parent'));
    await tester.pump();
    final active = surfaces.last;
    for (var frame = 0; frame < 20; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      final left = clipOf(active).left;
      expect(left, lessThanOrEqualTo(rowOf(find.text('parent').last).left));
      expect(left, lessThanOrEqualTo(rowOf(find.text('child')).left));
    }
    await tester.pumpAndSettle();
  });

  testWidgets('folding back lands on the item without a jump at the end', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'plain item'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(label: 'first child'),
          CommonPopupMenuItem(label: 'second child'),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent'));
    await tester.pump();
    final foldedWidth = tester.getSize(surfaces.last).width;
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent').last);
    late PopupMenuCard last;
    late double lastWidth;
    var frames = 0;
    while (surfaces.evaluate().length > 1) {
      last = cardOf(tester, surfaces.last);
      lastWidth = tester.getSize(surfaces.last).width;
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
      expect(frames, lessThan(60));
    }

    expect(lastWidth, closeTo(foldedWidth, 1));
    expect(last.grow, closeTo(0, 0.01));
    expect(shadowOf(tester, surfaces), greaterThan(0));
    await tester.pumpAndSettle();
  });

  testWidgets('a fold caught mid-unfold turns back from where it stands', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(label: 'first child'),
          CommonPopupMenuItem(label: 'second child'),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final caught = cardOf(tester, surfaces.last).grow;
    expect(caught, inExclusiveRange(0, 1));

    await tester.tap(find.text('parent').last, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(cardOf(tester, surfaces.last).grow, closeTo(caught, 0.15));

    await tester.pumpAndSettle();
    expect(surfaces, findsOneWidget);
  });

  testWidgets('the item tapped again while its sub menu folds opens it back', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(label: 'first child'),
          CommonPopupMenuItem(label: 'second child'),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();

    expect(find.text('first child'), findsOneWidget);
    expect(surfaces, findsNWidgets(2));
    expect(cardOf(tester, surfaces.last).grow, 1);
  });

  testWidgets('a tap on the menu behind a sub menu folds it back', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'plain item'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('plain item'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('plain item'), findsOneWidget);
  });

  testWidgets('a tap on a card between its items keeps the menu open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'item', onPressed: () {}),
    ]);
    open();
    await tester.pumpAndSettle();

    await tester.tapAt(tester.getTopLeft(surfaces) + const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.text('item'), findsOneWidget);
  });

  testWidgets('the item a sub menu stands on hides under its header', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    double opacityOf(Finder label) => tester
        .widget<Opacity>(
          find.ancestor(of: label, matching: find.byType(Opacity)).first,
        )
        .opacity;
    open();
    await tester.pumpAndSettle();
    expect(opacityOf(find.text('parent')), 1);

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    expect(opacityOf(find.text('parent').first), 0);

    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();
    expect(opacityOf(find.text('parent')), 1);
  });

  testWidgets('a sub menu unfolds without moving the menu it opens from', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.expand();
          },
        ),
      ),
    );

    Navigator.of(context).push(
      CommonPopupRoute<void>(
        barrierLabel: 'Dismiss',
        placement: PopupPlacement.belowPoint,
        anchorOf: () => const Offset(100, 250) & Size.zero,
        avoid: const Rect.fromLTRB(0, 200, 800, 300),
        builder: (_) => const CommonPopupMenu(
          items: [
            CommonPopupMenuItem(label: 'plain item'),
            CommonPopupMenuItem(
              label: 'parent',
              subItems: [
                CommonPopupMenuItem(label: 'first child'),
                CommonPopupMenuItem(label: 'second child'),
                CommonPopupMenuItem(label: 'third child'),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final menu = find.byType(CommonPopupMenu);
    final corner = tester.getTopRight(menu);
    final foldedHeight = tester.getSize(menu).height;
    expect(tester.getBottomRight(menu).dy, lessThan(200));

    await tester.tap(find.text('parent'));
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.getTopRight(menu), offsetMoreOrLessEquals(corner));
    }
    await tester.pumpAndSettle();

    expect(tester.getTopRight(menu), offsetMoreOrLessEquals(corner));
    expect(tester.getSize(menu).height, greaterThan(foldedHeight));
  });

  testWidgets('the parent hands its shadow over without a step', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final restingShadow = shadowOf(tester, surfaces);

    await tester.tap(find.text('parent'));
    await tester.pump();
    expect(shadowOf(tester, surfaces.first), restingShadow);
    expect(shadowOf(tester, surfaces.last), 0);

    await tester.pumpAndSettle();
    expect(shadowOf(tester, surfaces.first), lessThan(restingShadow));
    expect(shadowOf(tester, surfaces.last), restingShadow);

    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();
    expect(shadowOf(tester, surfaces), restingShadow);
  });

  testWidgets('a parent keeps its scroll offset while a sub menu is open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      for (var index = 0; index < 4; index++)
        CommonPopupMenuItem(label: 'item $index'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
      for (var index = 4; index < 30; index++)
        CommonPopupMenuItem(label: 'item $index'),
    ]);
    open();
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    scrollable.position.jumpTo(100);
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    expect(find.text('child'), findsOneWidget);
    final parentScrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(identical(parentScrollable, scrollable), isTrue);
    expect(parentScrollable.position.pixels, 100);

    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();
    expect(
      identical(
        tester.state<ScrollableState>(find.byType(Scrollable)),
        scrollable,
      ),
      isTrue,
    );
    expect(scrollable.position.pixels, 100);
  });

  testWidgets('on glass a card stands bare while the platter carries it', (
    tester,
  ) async {
    late PopupOpen open;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => LiquidGlassScope(enabled: true, child: child!),
        home: Scaffold(
          body: Center(
            child: CommonPopupBox(
              targetBuilder: (value) {
                open = value;
                return const SizedBox(width: 40, height: 40);
              },
              popupBuilder: (_) => const CommonPopupMenu(
                items: [CommonPopupMenuItem(label: 'item')],
              ),
            ),
          ),
        ),
      ),
    );
    bool bare() => cardOf(tester, surfaces).bare;

    open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(bare(), isTrue);

    await tester.pumpAndSettle();
    expect(bare(), isFalse);

    await tester.tapAt(Offset.zero);
    await tester.pump();
    expect(bare(), isTrue);
  });

  testWidgets('a menu returns its open sub menu alone into the button', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'first'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    final morph = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_PopupMorph',
    );
    double opacityOf(Finder card) => tester
        .widget<Opacity>(
          find.ancestor(of: card, matching: find.byType(Opacity)).first,
        )
        .opacity;
    Rect platter() {
      Rect? shadow;
      expect(
        tester.renderObject(morph),
        paints..everything((method, arguments) {
          if (method == #drawRSuperellipse) {
            shadow ??= (arguments.first as RSuperellipse).outerRect;
          }
          return true;
        }),
      );
      return shadow!.shift(
        -menuShadows(const ColorScheme.light()).single.offset,
      );
    }

    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    final subMenu = tester
        .getRect(surfaces.last)
        .shift(-tester.getTopLeft(morph));
    expect(subMenu.size, isNot(tester.getSize(morph)));

    await tester.tapAt(Offset.zero);
    await tester.pump();

    expect(opacityOf(surfaces.first), 0);
    expect(opacityOf(surfaces.last), 1);
    expect(platter(), rectMoreOrLessEquals(subMenu));
    await tester.pumpAndSettle();
  });
}

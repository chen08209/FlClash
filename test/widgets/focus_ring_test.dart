import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

final _theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
).withAppShapes.withAppSurfaces;

Color get _primary => _theme.colorScheme.primary;

Future<List<FocusNode>> _pump(
  WidgetTester tester,
  List<Widget Function(FocusNode node)> builders,
) async {
  final nodes = [for (final _ in builders) FocusNode()];
  for (final node in nodes) {
    addTearDown(node.dispose);
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: _theme,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              for (final (index, builder) in builders.indexed)
                builder(nodes[index]),
            ],
          ),
        ),
      ),
    ),
  );
  // A key press puts focus highlights in the traditional mode a remote uses.
  await tester.sendKeyEvent(LogicalKeyboardKey.shift);
  await tester.pumpAndSettle();
  return nodes;
}

Future<void> _focus(WidgetTester tester, FocusNode node) async {
  node.requestFocus();
  await tester.pumpAndSettle();
}

BorderSide _buttonSide(WidgetTester tester, Key key) {
  final material = tester.widget<Material>(
    find.descendant(of: find.byKey(key), matching: find.byType(Material)).first,
  );
  return (material.shape! as OutlinedBorder).side;
}

BorderSide _ringSide(WidgetTester tester, Key key) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(of: find.byKey(key), matching: find.byType(DecoratedBox))
        .first,
  );
  return ((box.decoration as ShapeDecoration).shape as OutlinedBorder).side;
}

Matcher _ring({required bool standsOff}) => isA<BorderSide>()
    .having((side) => side.color, 'color', _primary)
    .having((side) => side.width, 'width', 2)
    .having(
      (side) => side.strokeAlign,
      'strokeAlign',
      standsOff ? greaterThan(1) : BorderSide.strokeAlignInside,
    );

void main() {
  testWidgets('themed buttons ring their edge, a filled one stands off', (
    tester,
  ) async {
    const icon = Key('icon');
    const text = Key('text');
    const filled = Key('filled');
    const outlined = Key('outlined');
    final nodes = await _pump(tester, [
      (node) => IconButton(
        key: icon,
        focusNode: node,
        tooltip: 'icon',
        onPressed: () {},
        icon: const GlyphIcon(AppGlyphs.add),
      ),
      (node) => TextButton(
        key: text,
        focusNode: node,
        onPressed: () {},
        child: const Text('text'),
      ),
      (node) => FilledButton(
        key: filled,
        focusNode: node,
        onPressed: () {},
        child: const Text('filled'),
      ),
      (node) => OutlinedButton(
        key: outlined,
        focusNode: node,
        onPressed: () {},
        child: const Text('outlined'),
      ),
    ]);

    for (final key in [icon, text, filled]) {
      expect(_buttonSide(tester, key).style, BorderStyle.none);
    }
    expect(_buttonSide(tester, outlined).width, 1);
    await _focus(tester, nodes[0]);
    expect(_buttonSide(tester, icon), _ring(standsOff: false));
    await _focus(tester, nodes[1]);
    expect(_buttonSide(tester, text), _ring(standsOff: false));
    expect(_buttonSide(tester, icon).style, BorderStyle.none);
    await _focus(tester, nodes[2]);
    expect(_buttonSide(tester, filled), _ring(standsOff: true));
    await _focus(tester, nodes[3]);
    expect(_buttonSide(tester, outlined), _ring(standsOff: false));
  });

  testWidgets('tonal bar buttons keep the ring their own theme replaces', (
    tester,
  ) async {
    const icon = Key('icon');
    const filled = Key('filled');
    final nodes = await _pump(tester, [
      (node) => TonalButtonTheme(
        child: IconButton(
          key: icon,
          focusNode: node,
          tooltip: 'icon',
          onPressed: () {},
          icon: const GlyphIcon(AppGlyphs.add),
        ),
      ),
      (node) => TonalButtonTheme(
        child: FilledButton(
          key: filled,
          focusNode: node,
          onPressed: () {},
          child: const Text('filled'),
        ),
      ),
    ]);

    await _focus(tester, nodes[0]);
    expect(_buttonSide(tester, icon), _ring(standsOff: false));
    await _focus(tester, nodes[1]);
    expect(_buttonSide(tester, filled), _ring(standsOff: true));
  });

  testWidgets('a focus ring follows focus into its ink control', (
    tester,
  ) async {
    const plain = Key('plain');
    const standing = Key('standing');
    final nodes = await _pump(tester, [
      for (final (key, standsOff) in [(plain, false), (standing, true)])
        (node) => FocusRing(
          key: key,
          shape: AppShape.full,
          standsOff: standsOff,
          child: InkWell(
            focusNode: node,
            customBorder: AppShape.full,
            onTap: () {},
            child: const SizedBox(width: 80, height: 40),
          ),
        ),
    ]);

    expect(_ringSide(tester, plain).style, BorderStyle.none);
    await _focus(tester, nodes[0]);
    expect(_ringSide(tester, plain), _ring(standsOff: false));
    await _focus(tester, nodes[1]);
    expect(_ringSide(tester, plain).style, BorderStyle.none);
    expect(_ringSide(tester, standing), _ring(standsOff: true));
  });

  testWidgets('a segment keeps focus as it selects, ringed off its pill', (
    tester,
  ) async {
    var value = 'a';
    await _pump(tester, [
      (_) => StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 240,
          child: SegmentedControl<String>(
            segments: const [('a', 'a'), ('b', 'b')],
            value: value,
            onChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    ]);
    BorderSide ringOf(String label) {
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.ancestor(
                of: find.text(label),
                matching: find.byType(FocusRing),
              ),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return ((box.decoration as ShapeDecoration).shape as OutlinedBorder).side;
    }

    final node = Focus.of(tester.element(find.text('b')));
    await _focus(tester, node);
    expect(ringOf('b'), _ring(standsOff: false));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(value, 'b');
    expect(node.hasPrimaryFocus, isTrue);
    expect(ringOf('b'), _ring(standsOff: true));
    expect(ringOf('a').style, BorderStyle.none);
  });

  Future<void> pumpRow(WidgetTester tester, {required bool remote}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme,
        home: RemoteFocusAdapter(
          enabled: remote,
          child: Scaffold(
            body: Column(
              children: [
                const TextField(key: Key('before')),
                generateSection(
                  items: [
                    const DecorationListItem(
                      key: Key('row'),
                      title: TextField(key: Key('field')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a row rings a field a key moved focus to, not one tapped', (
    tester,
  ) async {
    const row = Key('row');
    await pumpRow(tester, remote: false);

    await tester.tap(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    expect(_buttonSide(tester, row).style, BorderStyle.none);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_buttonSide(tester, row).style, BorderStyle.none);

    await tester.tap(find.byKey(const Key('before')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_buttonSide(tester, row), _ring(standsOff: false));

    await tester.tap(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    expect(_buttonSide(tester, row).style, BorderStyle.none);
  });

  testWidgets('a row rings any focus while a remote drives it', (tester) async {
    await pumpRow(tester, remote: true);

    await tester.showKeyboard(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    expect(_buttonSide(tester, const Key('row')), _ring(standsOff: false));
  });
}

import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

final _theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009688)),
);

Color get _primary => _theme.colorScheme.primary;

Future<List<FocusNode>> _pump(
  WidgetTester tester,
  List<Widget Function(FocusNode node)> builders, {
  bool remote = false,
}) async {
  final nodes = [for (final _ in builders) FocusNode()];
  for (final node in nodes) {
    addTearDown(node.dispose);
  }
  await tester.pumpWidget(
    HostApp(
      theme: _theme,
      home: RemoteFocusAdapter(
        enabled: remote,
        child: HostScaffold(
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

BorderSide _cardSide(WidgetTester tester, Key key) => tester
    .widget<CardSurface>(
      find.descendant(of: find.byKey(key), matching: find.byType(CardSurface)),
    )
    .side;

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
          child: PressRegion(
            onTap: () {},
            child: Focus(
              focusNode: node,
              child: const SizedBox(width: 80, height: 40),
            ),
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
    BorderSide ringOf(String label) => tester
        .widget<CardSurface>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(CardSurface),
          ),
        )
        .side;

    final node = Focus.of(tester.element(find.text('b')));
    await _focus(tester, Focus.of(tester.element(find.text('a'))));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(node.hasPrimaryFocus, isTrue);
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
      HostApp(
        theme: _theme,
        home: RemoteFocusAdapter(
          enabled: remote,
          child: HostScaffold(
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
    expect(_cardSide(tester, row).style, BorderStyle.none);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_cardSide(tester, row).style, BorderStyle.none);

    await tester.tap(find.byKey(const Key('before')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_cardSide(tester, row), _ring(standsOff: false));

    await tester.tap(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    expect(_cardSide(tester, row).style, BorderStyle.none);
  });

  testWidgets('a row rings any focus while a remote drives it', (tester) async {
    await pumpRow(tester, remote: true);

    await tester.showKeyboard(find.byKey(const Key('field')));
    await tester.pumpAndSettle();
    expect(_cardSide(tester, const Key('row')), _ring(standsOff: false));
  });
}

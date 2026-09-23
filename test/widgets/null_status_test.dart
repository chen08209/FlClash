import 'package:fl_clash/widgets/null_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _reducedMotion = MediaQueryData(disableAnimations: true);

Widget _switcher({required bool isEmpty, MediaQueryData? mediaQuery}) {
  final switcher = NullStatusSwitcher(
    isEmpty: isEmpty,
    nullStatus: const NullStatus(label: 'Nothing here'),
    child: const Text('content', key: ValueKey('content')),
  );
  return MaterialApp(
    home: mediaQuery == null
        ? switcher
        : MediaQuery(data: mediaQuery, child: switcher),
  );
}

void main() {
  testWidgets('renders every semantic illustration with an M3E background', (
    tester,
  ) async {
    for (final illustration in NullStatusIllustration.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: NullStatus(label: 'Nothing here', illustration: illustration),
        ),
      );
      await tester.pumpAndSettle();

      final background = find.byKey(ValueKey(illustration));
      expect(background, findsOneWidget);
      expect(tester.getSize(background), const Size.square(200));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('keeps data as the default illustration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NullStatus(label: 'Nothing here')),
    );

    expect(
      find.byKey(const ValueKey(NullStatusIllustration.data)),
      findsOneWidget,
    );
  });

  testWidgets('staggers its entrance when shown on its own', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NullStatus(label: 'Nothing here', action: Text('Retry')),
      ),
    );

    final fades = find.descendant(
      of: find.byType(NullStatus),
      matching: find.byType(FadeTransition),
    );
    expect(fades, findsNWidgets(3));
    for (final fade in tester.widgetList<FadeTransition>(fades)) {
      expect(fade.opacity.value, 0);
    }

    await tester.pumpAndSettle();
    for (final fade in tester.widgetList<FadeTransition>(fades)) {
      expect(fade.opacity.value, 1);
    }
  });

  testWidgets('staggers its entrance when hosted by a switcher', (
    tester,
  ) async {
    await tester.pumpWidget(_switcher(isEmpty: true));

    final fades = find.descendant(
      of: find.byType(NullStatus),
      matching: find.byType(FadeTransition),
    );
    expect(fades, findsNWidgets(2));

    await tester.pumpAndSettle();
    for (final fade in tester.widgetList<FadeTransition>(fades)) {
      expect(fade.opacity.value, 1);
    }
  });

  testWidgets('skips its own fade while the route is still animating in', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const NullStatus(label: 'Nothing here'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.descendant(
        of: find.byType(NullStatus),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('skips the entrance fade under reduced motion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: _reducedMotion,
          child: NullStatus(label: 'Nothing here', action: Text('Retry')),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(NullStatus),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(find.text('Nothing here'), findsOneWidget);
  });

  testWidgets('fades between the empty state and content', (tester) async {
    await tester.pumpWidget(_switcher(isEmpty: true));
    await tester.pumpAndSettle();
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);

    await tester.pumpWidget(_switcher(isEmpty: false));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.byType(ScaleTransition), findsNWidgets(2));

    await tester.pumpAndSettle();
    expect(find.text('Nothing here'), findsNothing);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exits the empty state faster than it enters', (tester) async {
    await tester.pumpWidget(_switcher(isEmpty: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_switcher(isEmpty: false));
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pump();

    expect(find.text('Nothing here'), findsNothing);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('gives the content the full body size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 500,
            child: NullStatusSwitcher(
              isEmpty: false,
              nullStatus: NullStatus(label: 'Nothing here'),
              child: ColoredBox(key: ValueKey('content'), color: Colors.red),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey('content'))),
      const Size(300, 500),
    );
  });

  testWidgets('switches immediately under reduced motion', (tester) async {
    await tester.pumpWidget(
      _switcher(isEmpty: true, mediaQuery: _reducedMotion),
    );
    await tester.pump();

    await tester.pumpWidget(
      _switcher(isEmpty: false, mediaQuery: _reducedMotion),
    );
    await tester.pump();

    expect(find.text('Nothing here'), findsNothing);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
  });
}

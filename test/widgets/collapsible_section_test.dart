import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  Future<void> pumpSection(WidgetTester tester, int count) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        child: Material(
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleSection(
                label: 'Nodes',
                itemCount: count,
                itemBuilder: (_, index) =>
                    SizedBox(height: 64, child: Text('n$index')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double opacityOf(WidgetTester tester, String text) {
    final fades = find.ancestor(
      of: find.text(text),
      matching: find.descendant(
        of: find.byType(SliverCollapsibleSection),
        matching: find.byType(FadeTransition),
      ),
    );
    if (fades.evaluate().isEmpty) {
      return 1;
    }
    return tester.widget<FadeTransition>(fades.first).opacity.value;
  }

  testWidgets('shows its count and folds away from its header', (tester) async {
    await pumpSection(tester, 3);
    expect(find.text('Nodes (3)'), findsOneWidget);

    await tester.tap(find.text('Nodes (3)'));
    await tester.pumpAndSettle();
    expect(find.text('n0'), findsNothing);

    await tester.tap(find.text('Nodes (3)'));
    await tester.pumpAndSettle();
    expect(opacityOf(tester, 'n0'), 1);
  });

  testWidgets('starts collapsed when asked to', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: Material(
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleSection(
                label: 'Nodes',
                initiallyExpanded: false,
                itemCount: 1,
                itemBuilder: _firstEntry,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Nodes (1)'), findsOneWidget);
    expect(find.text('n0'), findsNothing);
  });

  testWidgets('a long list unfolds with its first entry visible but faint '
      'until the middle of the screen has faded in', (tester) async {
    await pumpSection(tester, 40);
    final top = tester.getTopLeft(find.text('n6')).dy;

    await tester.tap(find.text('Nodes (40)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nodes (40)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(find.text('n6')).dy, lessThan(top));
    expect(opacityOf(tester, 'n6'), 1);
    expect(opacityOf(tester, 'n0'), lessThan(0.5));

    await tester.pump(const Duration(milliseconds: 60));
    final later = opacityOf(tester, 'n0');
    expect(later, greaterThan(0.5));
    expect(later, lessThan(1));

    await tester.pumpAndSettle();
    expect(opacityOf(tester, 'n0'), 1);
    expect(tester.getTopLeft(find.text('n6')).dy, top);
  });

  testWidgets('builds only the entries in view, open or unfolding', (
    tester,
  ) async {
    await pumpSection(tester, 1000);
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n100'), findsNothing);

    await tester.tap(find.text('Nodes (1000)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nodes (1000)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n100'), findsNothing);
  });
}

Widget _firstEntry(BuildContext context, int index) => const Text('n0');

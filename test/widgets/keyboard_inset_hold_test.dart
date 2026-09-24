import 'dart:async';

import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/keyboard_inset_hold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _InsetProbe extends StatelessWidget {
  const _InsetProbe(this.builds);

  final List<double> builds;

  @override
  Widget build(BuildContext context) {
    builds.add(MediaQuery.viewInsetsOf(context).bottom);
    return const Material(
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(width: 200, child: TextField()),
      ),
    );
  }
}

void main() {
  late List<double> builds;

  setUp(() => builds = []);

  void useKeyboardView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
  }

  double shownInset(WidgetTester tester) {
    return MediaQuery.viewInsetsOf(
      tester.element(find.byType(_InsetProbe)),
    ).bottom;
  }

  Future<void> setKeyboard(WidgetTester tester, double height) async {
    tester.view.viewInsets = FakeViewPadding(bottom: height);
    await tester.pump();
  }

  Future<void> openDialog(WidgetTester tester) async {
    useKeyboardView(tester);
    await tester.pumpWidget(
      MaterialApp(home: KeyboardInsetHold(child: _InsetProbe(builds))),
    );
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(_InsetProbe)),
        builder: (_) => const Center(child: Text('dialog')),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a page under a dialog sits out the keyboard it raises', (
    tester,
  ) async {
    await openDialog(tester);
    builds.clear();

    for (final height in [100.0, 200.0, 300.0]) {
      await setKeyboard(tester, height);
    }

    expect(builds, isEmpty);
    expect(shownInset(tester), 0);
  });

  testWidgets('an uncovered page waits for the keyboard to come down to it', (
    tester,
  ) async {
    await openDialog(tester);
    await setKeyboard(tester, 300);

    Navigator.of(tester.element(find.text('dialog'))).pop();
    await tester.pump();
    expect(shownInset(tester), 0);

    await setKeyboard(tester, 150);
    expect(shownInset(tester), 0);

    await setKeyboard(tester, 0);
    await setKeyboard(tester, 300);
    expect(shownInset(tester), 300);
  });

  testWidgets('an uncovered page takes the keyboard once focus is inside', (
    tester,
  ) async {
    await openDialog(tester);
    await setKeyboard(tester, 300);

    Navigator.of(tester.element(find.text('dialog'))).pop();
    await tester.pumpAndSettle();
    expect(shownInset(tester), 0);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(shownInset(tester), 300);
  });

  testWidgets('an inactive tab sits out the keyboard until it comes down', (
    tester,
  ) async {
    Widget tab({required bool isActive}) {
      return MaterialApp(
        home: PageActivityScope(
          isActive: isActive,
          child: KeyboardInsetHold(child: _InsetProbe(builds)),
        ),
      );
    }

    useKeyboardView(tester);
    await tester.pumpWidget(tab(isActive: false));
    await setKeyboard(tester, 300);
    expect(shownInset(tester), 0);

    await tester.pumpWidget(tab(isActive: true));
    expect(shownInset(tester), 0);

    await setKeyboard(tester, 0);
    await setKeyboard(tester, 300);
    expect(shownInset(tester), 300);
  });
}

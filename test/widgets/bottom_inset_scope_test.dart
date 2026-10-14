import 'package:fl_clash/ui/button.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/inherited.dart';
import 'package:fl_clash/ui/models.dart';
import 'package:fl_clash/ui/scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

final _addAction = IconButtonData(
  glyph: AppGlyphs.add,
  tooltip: 'add',
  onPressed: () {},
);

Widget _floating(Widget child) =>
    PrimaryActionInBarScope(inBar: false, child: child);

void main() {
  const navigationInset = 92.0;
  const fabInset = BottomInsetScope.floatingActionButtonInset;

  double? contentInset;

  Widget contentProbe() {
    return Builder(
      builder: (context) {
        contentInset = BottomInsetScope.of(context);
        return Container(key: const ValueKey('body'));
      },
    );
  }

  setUp(() {
    contentInset = null;
  });

  testWidgets('lifts the FAB above the reserved bottom space', (tester) async {
    Widget buildWith({double? inset}) {
      final scaffold = CommonScaffold(
        title: 'title',
        body: const SizedBox(),
        primaryAction: _addAction,
      );
      return TestApp(
        wrapInProviderScope: true,
        includeNavigatorKey: false,
        child: _floating(
          inset == null
              ? scaffold
              : BottomInsetScope(inset: inset, child: scaffold),
        ),
      );
    }

    await tester.pumpWidget(buildWith());
    final baseBottom = tester
        .getRect(find.byType(CommonFloatingActionButton))
        .bottom;

    await tester.pumpWidget(buildWith(inset: navigationInset));
    final liftedBottom = tester
        .getRect(find.byType(CommonFloatingActionButton))
        .bottom;

    expect(baseBottom - liftedBottom, navigationInset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not shrink the body for the reserved bottom space', (
    tester,
  ) async {
    Widget buildWith({double inset = 0, bool withFab = false}) {
      return TestApp(
        wrapInProviderScope: true,
        includeNavigatorKey: false,
        child: _floating(
          BottomInsetScope(
            inset: inset,
            child: CommonScaffold(
              title: 'title',
              body: contentProbe(),
              primaryAction: withFab ? _addAction : null,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWith());
    final baseBottom = tester
        .getRect(find.byKey(const ValueKey('body')))
        .bottom;

    await tester.pumpWidget(buildWith(inset: navigationInset));
    expect(
      tester.getRect(find.byKey(const ValueKey('body'))).bottom,
      baseBottom,
    );

    await tester.pumpWidget(buildWith(inset: navigationInset, withFab: true));
    expect(
      tester.getRect(find.byKey(const ValueKey('body'))).bottom,
      baseBottom,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds the FAB inset to the content inset of the body', (
    tester,
  ) async {
    Widget buildWith({double inset = 0, bool withFab = false}) {
      return TestApp(
        wrapInProviderScope: true,
        includeNavigatorKey: false,
        child: _floating(
          BottomInsetScope(
            inset: inset,
            child: CommonScaffold(
              title: 'title',
              body: contentProbe(),
              primaryAction: withFab ? _addAction : null,
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWith(inset: navigationInset));
    expect(contentInset, navigationInset);

    await tester.pumpWidget(buildWith(inset: navigationInset, withFab: true));
    expect(contentInset, navigationInset + fabInset);

    await tester.pumpWidget(buildWith(withFab: true));
    expect(contentInset, fabInset);
    expect(tester.takeException(), isNull);
  });
}

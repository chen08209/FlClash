import 'package:fl_clash/ui/context.dart';
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

void main() {
  const navigationInset = 92.0;

  double? contentInset;

  Widget contentProbe() {
    return Builder(
      builder: (context) {
        contentInset = BottomInsetScope.of(context);
        return Container(key: const ValueKey('body'));
      },
    );
  }

  Widget buildWith({double inset = 0, IconButtonData? primaryAction}) {
    return TestApp(
      wrapInProviderScope: true,
      includeNavigatorKey: false,
      child: BottomInsetScope(
        inset: inset,
        child: CommonScaffold(
          title: 'title',
          body: contentProbe(),
          primaryAction: primaryAction,
        ),
      ),
    );
  }

  setUp(() {
    contentInset = null;
  });

  testWidgets('does not shrink the body for the reserved bottom space', (
    tester,
  ) async {
    await tester.pumpWidget(buildWith());
    final baseBottom = tester
        .getRect(find.byKey(const ValueKey('body')))
        .bottom;

    await tester.pumpWidget(buildWith(inset: navigationInset));
    expect(
      tester.getRect(find.byKey(const ValueKey('body'))).bottom,
      baseBottom,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a primary action adds nothing to the content inset', (
    tester,
  ) async {
    await tester.pumpWidget(buildWith(inset: navigationInset));
    expect(contentInset, navigationInset);

    await tester.pumpWidget(
      buildWith(inset: navigationInset, primaryAction: _addAction),
    );
    expect(contentInset, navigationInset);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('runs the body under the system bar and leaves it to the end '
      'of the content, read above the scaffold or below it', (tester) async {
    const systemBar = 24.0;
    tester.view
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(bottom: systemBar);
    addTearDown(tester.view.reset);
    double? aboveInset;
    double? belowInset;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        includeNavigatorKey: false,
        child: Builder(
          builder: (context) {
            aboveInset = context.bottomInset;
            return CommonScaffold(
              title: 'title',
              body: Builder(
                builder: (context) {
                  belowInset = context.bottomInset;
                  return Container(key: const ValueKey('body'));
                },
              ),
            );
          },
        ),
      ),
    );

    expect(
      tester.getRect(find.byKey(const ValueKey('body'))).bottom,
      tester.view.physicalSize.height,
    );
    expect(aboveInset, systemBar);
    expect(belowInset, systemBar);
    expect(tester.takeException(), isNull);
  });
}

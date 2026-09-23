import 'package:fl_clash/widgets/float_layout.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

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
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      );
      return TestApp(
        includeNavigatorKey: false,
        child: inset == null
            ? scaffold
            : BottomInsetScope(inset: inset, child: scaffold),
      );
    }

    await tester.pumpWidget(buildWith());
    final baseBottom = tester.getRect(find.byType(FloatingActionButton)).bottom;

    await tester.pumpWidget(buildWith(inset: navigationInset));
    final liftedBottom = tester
        .getRect(find.byType(FloatingActionButton))
        .bottom;

    expect(baseBottom - liftedBottom, navigationInset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not shrink the body for the reserved bottom space', (
    tester,
  ) async {
    Widget buildWith({double inset = 0, bool withFab = false}) {
      return TestApp(
        includeNavigatorKey: false,
        child: BottomInsetScope(
          inset: inset,
          child: CommonScaffold(
            title: 'title',
            body: contentProbe(),
            floatingActionButton: withFab
                ? FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  )
                : null,
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
        includeNavigatorKey: false,
        child: BottomInsetScope(
          inset: inset,
          child: CommonScaffold(
            title: 'title',
            body: contentProbe(),
            floatingActionButton: withFab
                ? FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  )
                : null,
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

  testWidgets('does not reserve FAB space on TV', (tester) async {
    await tester.pumpWidget(
      TestApp(
        includeNavigatorKey: false,
        child: BottomInsetScope(
          inset: navigationInset,
          child: CommonScaffold(
            title: 'title',
            isTV: true,
            body: contentProbe(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );

    expect(contentInset, navigationInset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('float layout stacks its own inset on the inherited one', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        includeNavigatorKey: false,
        child: BottomInsetScope(
          inset: navigationInset,
          child: Scaffold(
            body: FloatLayout(
              isTV: false,
              floatingWidget: FloatWrapper(
                child: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.save),
                ),
              ),
              child: contentProbe(),
            ),
          ),
        ),
      ),
    );

    expect(contentInset, navigationInset + fabInset);
    final stackBottom = tester.getRect(find.byType(FloatLayout)).bottom;
    final fabBottom = tester.getRect(find.byType(FloatWrapper)).bottom;
    expect(stackBottom - fabBottom, navigationInset);
    expect(tester.takeException(), isNull);
  });
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Widget _list({ScrollController? controller}) {
  return ListView.builder(
    controller: controller,
    itemCount: 100,
    itemBuilder: (_, index) => SizedBox(height: 40, child: Text('$index')),
  );
}

Widget _sheet(Widget body) {
  return TestApp(
    wrapInProviderScope: true,
    child: SheetProvider(
      type: SheetType.bottomSheet,
      child: CommonScaffold(title: 'title', body: body),
    ),
  );
}

final _desktop = TargetPlatformVariant.only(TargetPlatform.macOS);
const _everyPlatform = TargetPlatformVariant({
  TargetPlatform.macOS,
  TargetPlatform.android,
});

void main() {
  testWidgets(
    'a padded scroll bar insets its own track only',
    variant: _desktop,
    (tester) async {
      const viewPadding = EdgeInsets.only(top: 20, bottom: 8);
      late EdgeInsets childPadding;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: viewPadding),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: CommonScrollBar(
              controller: ScrollController(),
              padding: const EdgeInsets.only(top: sheetAppBarHeight),
              child: Builder(
                builder: (context) {
                  childPadding = MediaQuery.paddingOf(context);
                  return _list();
                },
              ),
            ),
          ),
        ),
      );

      final scrollBarContext = tester.element(find.byType(Scrollbar).first);
      expect(
        MediaQuery.paddingOf(scrollBarContext),
        viewPadding.copyWith(top: viewPadding.top + sheetAppBarHeight),
      );
      expect(childPadding, viewPadding);
    },
  );

  testWidgets(
    'a bottom sheet keeps the scroll bar below its floating header',
    variant: _everyPlatform,
    (tester) async {
      await tester.pumpWidget(_sheet(_list()));
      await tester.pumpAndSettle();

      final scrollBar = tester.widget<CommonScrollBar>(
        find.byType(CommonScrollBar),
      );
      expect(scrollBar.padding, const EdgeInsets.only(top: sheetAppBarHeight));
    },
  );

  testWidgets(
    'a floating scroll bar is the only bar its list gets',
    variant: _everyPlatform,
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _sheet(
          FloatingScrollbar(
            controller: controller,
            hintBuilder: (_) => 'hint',
            child: _list(controller: controller),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CommonScrollBar), findsOneWidget);
      final scrollBar = tester.widget<CommonScrollBar>(
        find.byType(CommonScrollBar),
      );
      expect(scrollBar.padding, const EdgeInsets.only(top: sheetAppBarHeight));
    },
  );

  testWidgets('a sheet header lets what scrolls under it read through', (
    tester,
  ) async {
    await tester.pumpWidget(_sheet(_list()));
    await tester.pumpAndSettle();

    final cover = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.ancestor(
              of: find.byType(SheetToolBar),
              matching: find.byType(FloatingHeader),
            ),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final gradient = (cover.decoration as BoxDecoration).gradient;
    expect(gradient, isA<LinearGradient>());
    expect(gradient!.colors.map((color) => color.a), everyElement(lessThan(1)));
  });

  for (final type in [null, SheetType.page, SheetType.sideSheet]) {
    testWidgets(
      '${type?.name ?? 'a page'} floats its bar over the list under it',
      variant: _everyPlatform,
      (tester) async {
        final scaffold = CommonScaffold(title: 'title', body: _list());
        await tester.pumpWidget(
          TestApp(
            wrapInProviderScope: true,
            child: type == null
                ? scaffold
                : SheetProvider(type: type, child: scaffold),
          ),
        );
        await tester.pumpAndSettle();

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.forceMaterialTransparency, isTrue);
        expect(
          find.ancestor(
            of: find.byType(AppBar),
            matching: find.byType(FloatingHeader),
          ),
          findsOneWidget,
        );
        final barBottom = tester.getRect(find.byType(AppBar)).bottom;
        expect(tester.getRect(find.text('0')).top, barBottom);

        await tester.drag(find.byType(Scrollable), const Offset(0, -100));
        await tester.pumpAndSettle();

        expect(tester.getRect(find.text('2')).top, lessThan(barBottom));
      },
    );
  }

  testWidgets('a page with a title widget floats its bar as a titled one', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: CommonScaffold(titleWidget: const TextField(), body: _list()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(TextField),
      ),
      findsOneWidget,
    );

    expect(
      find.ancestor(
        of: find.byType(AppBar),
        matching: find.byType(FloatingHeader),
      ),
      findsOneWidget,
    );
    final barBottom = tester.getRect(find.byType(AppBar)).bottom;
    expect(tester.getRect(find.text('0')).top, barBottom);

    await tester.drag(find.text('0'), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.text('2')).top, lessThan(barBottom));
  });

  testWidgets(
    'keyboard focus moving up clears the floating bar',
    variant: _everyPlatform,
    (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: CommonScaffold(
            title: 'title',
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (_, index) =>
                  Focus(child: SizedBox(height: 40, child: Text('$index'))),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable), const Offset(0, -410));
      await tester.pumpAndSettle();

      final barBottom = tester.getRect(find.byType(AppBar)).bottom;
      var below = 0;
      while (find.text('$below').evaluate().isEmpty ||
          tester.getRect(find.text('$below')).top < barBottom) {
        below++;
      }
      final above = find.text('${below - 1}');
      expect(tester.getRect(above).top, lessThan(barBottom));

      Focus.of(tester.element(find.text('$below'))).requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(
        FocusManager.instance.primaryFocus,
        Focus.of(tester.element(above)),
      );
      expect(tester.getRect(above).top, moreOrLessEquals(barBottom));
    },
  );
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Widget _list() {
  return ListView.builder(
    itemCount: 100,
    itemBuilder: (_, index) => SizedBox(height: 40, child: Text('$index')),
  );
}

final _desktop = TargetPlatformVariant.only(TargetPlatform.macOS);
final _everyPlatform = TargetPlatformVariant(const {
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
    'a transparent tool bar keeps the scroll bar below the header',
    variant: _everyPlatform,
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: SheetProvider(
            type: SheetType.bottomSheet,
            child: AdaptiveSheetScaffold(
              title: 'title',
              sheetTransparentToolBar: true,
              body: _list(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollBar = tester.widget<CommonScrollBar>(
        find.byType(CommonScrollBar),
      );
      expect(scrollBar.padding, const EdgeInsets.only(top: sheetAppBarHeight));
    },
  );

  testWidgets(
    'an opaque tool bar shows the scroll bar without an inset',
    variant: _everyPlatform,
    (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: SheetProvider(
            type: SheetType.bottomSheet,
            child: AdaptiveSheetScaffold(title: 'title', body: _list()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scrollBar = tester.widget<CommonScrollBar>(
        find.byType(CommonScrollBar),
      );
      expect(scrollBar.padding, EdgeInsets.zero);
    },
  );
}

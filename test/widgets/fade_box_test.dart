import 'package:fl_clash/widgets/fade_box.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {required bool disableAnimations}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: child,
      ),
    );
  }

  for (final (name, box) in [
    ('FadeSlideEnterBox', const FadeSlideEnterBox(child: SizedBox())),
    ('FadeScaleEnterBox', const FadeScaleEnterBox(child: SizedBox())),
  ]) {
    testWidgets('$name animates its entrance', (tester) async {
      await tester.pumpWidget(host(box, disableAnimations: false));

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('$name never ticks when animations are disabled', (
      tester,
    ) async {
      await tester.pumpWidget(host(box, disableAnimations: true));

      expect(tester.hasRunningAnimations, isFalse);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  }
}

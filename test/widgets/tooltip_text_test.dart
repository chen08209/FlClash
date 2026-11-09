import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

const _long = 'a run of text far too long for the box it is given';

void main() {
  Future<void> pumpText(WidgetTester tester, double width) async {
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: const TooltipText(text: Text(_long, maxLines: 1)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a text cut short gains a tooltip of its whole string', (
    tester,
  ) async {
    await pumpText(tester, 2000);
    expect(find.byType(Tooltip), findsNothing);

    await pumpText(tester, 80);
    expect(find.byTooltip(_long), findsOneWidget);

    await pumpText(tester, 2000);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('a hover tooltip waits for a pointer', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      TestApp(
        child: HostScaffold(
          body: Center(
            child: HoverTooltip(
              message: 'Test delay',
              child: GestureDetector(
                onTap: () {},
                child: const SizedBox(width: 24, height: 24),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Tooltip), findsNothing);
    expect(
      find.semantics.byPredicate((node) => node.tooltip == 'Test delay'),
      findsOne,
    );

    final touch = await tester.startGesture(
      tester.getCenter(find.byType(HoverTooltip)),
    );
    await tester.pump(const Duration(seconds: 1));
    await touch.up();
    await tester.pumpAndSettle();
    expect(find.text('Test delay'), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(HoverTooltip)));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Test delay'), findsOneWidget);
    handle.dispose();
  });
}

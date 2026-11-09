import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';
import '../helpers/test_app.dart';

void main() {
  testWidgets('ActivateBox blocks pointer events when inactive', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      HostApp(
        home: ActivateBox(
          active: false,
          child: TextButton(onPressed: () => taps++, child: const Text('tap')),
        ),
      ),
    );

    await tester.tap(find.text('tap'), warnIfMissed: false);

    expect(taps, 0);
  });

  testWidgets('ActivateBox allows pointer events when active', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      HostApp(
        home: ActivateBox(
          active: true,
          child: TextButton(onPressed: () => taps++, child: const Text('tap')),
        ),
      ),
    );

    await tester.tap(find.text('tap'));

    expect(taps, 1);
  });

  testWidgets('DisabledMask applies filter only when status is true', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HostApp(home: DisabledMask(status: true, child: Text('disabled'))),
    );

    expect(find.byType(ColorFiltered), findsOneWidget);

    await tester.pumpWidget(
      const HostApp(home: DisabledMask(status: false, child: Text('enabled'))),
    );

    expect(find.byType(ColorFiltered), findsNothing);
  });
}

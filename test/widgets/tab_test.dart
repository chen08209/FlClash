import 'package:fl_clash/widgets/tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CommonTabBar selects enabled segments and ignores disabled ones',
    (tester) async {
      var selected = 0;
      late StateSetter setState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setter) {
                  setState = setter;
                  return CommonTabBar<int>(
                    groupValue: selected,
                    disabledChildren: const {2},
                    thumbColor: Colors.blue,
                    backgroundColor: Colors.grey,
                    children: const {
                      0: Text('One'),
                      1: Text('Two'),
                      2: Text('Three'),
                    },
                    onValueChanged: (value) {
                      setState(() => selected = value!);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(selected, 0);
      await tester.tap(find.text('Two').first);
      await tester.pump(const Duration(milliseconds: 500));
      expect(selected, 1);

      await tester.tap(find.text('Three').first);
      await tester.pump();
      expect(selected, 1);

      setState(() => selected = 0);
      await tester.pump();
      expect(tester.takeException(), null);
    },
  );

  testWidgets('CommonTabBar commits the pressed segment after a drag', (
    tester,
  ) async {
    var selected = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return CommonTabBar<int>(
                  groupValue: selected,
                  thumbColor: Colors.red,
                  children: const {
                    0: Text('First'),
                    1: Text('Selected'),
                    2: Text('Last'),
                  },
                  onValueChanged: (value) {
                    setState(() => selected = value!);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(
        find
            .ancestor(
              of: find.text('First').first,
              matching: find.byKey(const ValueKey<int>(0)),
            )
            .first,
      ),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(
      tester.getCenter(
        find
            .ancestor(
              of: find.text('Last').first,
              matching: find.byKey(const ValueKey<int>(2)),
            )
            .first,
      ),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));

    expect(selected, 0);
    expect(tester.takeException(), null);
  });

  testWidgets('CommonTabBar lays out proportional RTL segments and updates', (
    tester,
  ) async {
    var selected = 0;
    var proportional = true;
    var color = Colors.green;
    late StateSetter setState;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: StatefulBuilder(
                    builder: (context, setter) {
                      setState = setter;
                      return CommonTabBar<int>(
                        groupValue: selected,
                        proportionalWidth: proportional,
                        thumbColor: color,
                        children: const {
                          0: Text('Short'),
                          1: Text('A much longer segment'),
                          2: Text('End'),
                        },
                        onValueChanged: (value) {
                          setState(() => selected = value!);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CommonTabBar<int>)).height,
      greaterThan(0),
    );
    await tester.tap(find.text('End').first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(selected, 2);

    setState(() {
      proportional = false;
      color = Colors.purple;
    });
    await tester.pump();
    expect(tester.takeException(), null);
  });
}

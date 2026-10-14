import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Widget _scaffold(String name, {Widget? body}) {
  return CommonScaffold(
    title: name,
    actions: [TextButton(onPressed: () {}, child: Text('$name action'))],
    body: body ?? const SizedBox.expand(),
  );
}

Widget _opener(String label, WidgetBuilder builder) {
  return Builder(
    builder: (context) => Center(
      child: FilledButton(
        onPressed: () => showSheet<void>(context: context, builder: builder),
        child: Text(label),
      ),
    ),
  );
}

Future<void> _pump(WidgetTester tester, Size size, Widget home) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final container = ProviderContainer(
    overrides: [viewSizeProvider.overrideWithBuild((_, _) => size)],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(child: home),
    ),
  );
}

double _opacityOf(WidgetTester tester, Finder finder) {
  return tester
      .widgetList<FadeTransition>(
        find.ancestor(of: finder, matching: find.byType(FadeTransition)),
      )
      .fold(1.0, (opacity, fade) => opacity * fade.opacity.value);
}

void main() {
  for (final (kind, size) in const [
    ('bottom sheet', Size(400, 800)),
    ('side sheet', Size(1000, 800)),
  ]) {
    testWidgets('a page under a $kind hides its bar actions', (tester) async {
      await _pump(
        tester,
        size,
        _scaffold('Page', body: _opener('open', (_) => _scaffold('Sheet'))),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        _opacityOf(tester, find.text('Page action')),
        inExclusiveRange(0, 1),
      );

      await tester.pumpAndSettle();
      expect(_opacityOf(tester, find.text('Page action')), 0);
      expect(_opacityOf(tester, find.text('Page')), 1);
      expect(_opacityOf(tester, find.text('Sheet action')), 1);

      Navigator.of(tester.element(find.text('Sheet'))).pop();
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, find.text('Page action')), 1);
    });

    testWidgets('a $kind under another hides its bar actions', (tester) async {
      await _pump(
        tester,
        size,
        _opener(
          'open outer',
          (_) => _scaffold(
            'Outer',
            body: _opener('open inner', (_) => _scaffold('Inner')),
          ),
        ),
      );
      await tester.tap(find.text('open outer'));
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, find.text('Outer action')), 1);

      await tester.tap(find.text('open inner'));
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, find.text('Outer action')), 0);
      expect(_opacityOf(tester, find.text('Inner action')), 1);
    });
  }

  testWidgets('a page under a sheet keeps its back button', (tester) async {
    await _pump(
      tester,
      const Size(400, 800),
      Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => BaseNavigator.push(
              context,
              _scaffold(
                'Page',
                body: _opener('open', (_) => _scaffold('Sheet')),
              ),
            ),
            child: const Text('push'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, find.text('Page action')), 0);
    expect(find.byType(BackButton), findsOneWidget);
    expect(_opacityOf(tester, find.byType(BackButton)), 1);
  });

  testWidgets('a sheet page steps back with the sheet it is on', (
    tester,
  ) async {
    await _pump(
      tester,
      const Size(400, 800),
      Builder(
        builder: (context) => Center(
          child: FilledButton(
            onPressed: () => showSheet<void>(
              context: context,
              props: nestedPagedSheetProps,
              builder: (_) => NestedPagedSheet(
                builder: (_) => _scaffold(
                  'Page',
                  body: _opener('open', (_) => _scaffold('Sheet')),
                ),
              ),
            ),
            child: const Text('open paged'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open paged'));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, find.text('Page action')), 1);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(_opacityOf(tester, find.text('Page action')), 0);
  });
}

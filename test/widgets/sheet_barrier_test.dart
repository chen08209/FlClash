import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

Future<void> _pumpStackedSheets(WidgetTester tester, Size size) async {
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
      child: TestApp(
        child: HostScaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () {
                showSheet<void>(
                  context: context,
                  builder: (_) => Builder(
                    builder: (context) => FilledButton(
                      onPressed: () {
                        showSheet<void>(
                          context: context,
                          builder: (_) => const Text('inner'),
                        );
                      },
                      child: const Text('open inner'),
                    ),
                  ),
                );
              },
              child: const Text('open outer'),
            ),
          ),
        ),
      ),
    ),
  );
}

Color? _barrierColorAround(WidgetTester tester, String text) {
  return ModalRoute.of(tester.element(find.text(text)))!.barrierColor;
}

void main() {
  for (final (kind, size) in const [
    ('side sheet', Size(1000, 800)),
    ('bottom sheet', Size(400, 800)),
  ]) {
    testWidgets('a $kind stacked on a sheet brings its own scrim', (
      tester,
    ) async {
      await _pumpStackedSheets(tester, size);

      await tester.tap(find.text('open outer'));
      await tester.pumpAndSettle();
      final scrim = tester
          .element(find.text('open inner'))
          .colorScheme
          .modalScrim;
      expect(_barrierColorAround(tester, 'open inner'), scrim);

      await tester.tap(find.text('open inner'));
      await tester.pumpAndSettle();
      expect(
        _barrierColorAround(tester, 'inner'),
        kind == 'bottom sheet' ? scrim.withValues(alpha: scrim.a * 0.6) : scrim,
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });
  }
}

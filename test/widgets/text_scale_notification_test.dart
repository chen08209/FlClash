import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/notification.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> pumpNotification(
    WidgetTester tester,
    void Function(TextScale) onNotification,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: TextScaleNotification(
            onNotification: onNotification,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void setTextScale(TextScale scale) {
    container
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(textScale: scale));
  }

  testWidgets('renders the child and stays quiet until the scale moves', (
    tester,
  ) async {
    final seen = <TextScale>[];

    await pumpNotification(tester, seen.add);

    expect(find.byType(SizedBox), findsWidgets);
    expect(seen, isEmpty);
  });

  testWidgets('notifies once per text scale change', (tester) async {
    final seen = <TextScale>[];

    await pumpNotification(tester, seen.add);

    const next = TextScale(enable: true, scale: 1.5);
    setTextScale(next);
    await tester.pump();

    expect(seen, [next]);

    const third = TextScale(enable: true, scale: 2.0);
    setTextScale(third);
    await tester.pump();

    expect(seen, [next, third]);
  });

  testWidgets('re-setting the same scale does not notify again', (
    tester,
  ) async {
    final seen = <TextScale>[];

    await pumpNotification(tester, seen.add);

    const next = TextScale(enable: true, scale: 1.5);
    setTextScale(next);
    await tester.pump();
    setTextScale(next);
    await tester.pump();

    expect(seen, [next]);
  });
}

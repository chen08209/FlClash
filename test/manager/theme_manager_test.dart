import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('following the system picks up a font scale changed while the '
      'app runs', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    double? scaled;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ThemeManager(
            child: Builder(
              builder: (context) {
                scaled = MediaQuery.textScalerOf(context).scale(10);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(scaled, 10);

    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pump();

    expect(scaled, closeTo(13, 1e-9));
  });

  testWidgets('a theme setting the theme does not read keeps the same theme', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final themes = <ThemeData>[];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            ref.watch(themeSettingProvider);
            themes.add(watchAppTheme(ref, Brightness.dark));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    void update(ThemeProps Function(ThemeProps props) change) {
      final notifier = container.read(themeSettingProvider.notifier);
      notifier.value = change(notifier.value);
    }

    update((props) => props.copyWith(sidebarBlur: !props.sidebarBlur));
    await tester.pump();
    update((props) => props.copyWith(pureBlack: !props.pureBlack));
    await tester.pump();

    expect(themes, hasLength(3));
    expect(themes[1], same(themes[0]));
    expect(themes[2], isNot(same(themes[1])));
  });
}

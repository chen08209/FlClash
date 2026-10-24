import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the font weight setting thickens the theme', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final weights = <FontWeight?>[];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            ref.watch(themeSettingProvider);
            final theme = watchAppTheme(ref, Brightness.dark);
            weights.add(theme.textTheme.bodyLarge?.fontWeight);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    void update(ThemeProps Function(ThemeProps props) change) {
      final notifier = container.read(themeSettingProvider.notifier);
      notifier.value = change(notifier.value);
    }

    expect(weights.last, FontWeight.w400);

    update(
      (props) => props.copyWith(fontWeightAdjustment: maxFontWeightAdjustment),
    );
    await tester.pump();

    expect(weights.last, FontWeight.w800);

    update(
      (props) => props.copyWith(fontWeightAdjustment: minFontWeightAdjustment),
    );
    await tester.pump();

    expect(weights.last, FontWeight.w200);
  });
}

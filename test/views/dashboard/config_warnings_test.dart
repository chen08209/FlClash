import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/config_warnings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/host_scaffold.dart';
import '../../helpers/test_app.dart';

const _removed = ConfigWarning(
  level: ConfigWarningLevel.warning,
  path: 'proxies[12]',
  message: 'masque is not supported, the proxy was removed',
);

const _ignored = ConfigWarning(
  level: ConfigWarningLevel.info,
  path: 'experimental',
  message: 'ignored',
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpSlot(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('en'),
          child: HostScaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 380,
                child: DashboardDensityScope(
                  density: DashboardDensity.mobile,
                  scale: 1,
                  child: ConfigWarningsSlot(gap: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void report(List<ConfigWarning> warnings) {
    container.read(configWarningsStateProvider.notifier).value = warnings;
  }

  testWidgets('shows nothing without warnings', (tester) async {
    await pumpSlot(tester);

    expect(find.text('Config warnings'), findsNothing);
    expect(tester.getSize(find.byType(ConfigWarningsSlot)).height, 0);
  });

  testWidgets('notes of the info level alone show nothing', (tester) async {
    report(const [_ignored]);
    await pumpSlot(tester);

    expect(find.text('Config warnings'), findsNothing);
  });

  testWidgets('counts the warnings and lists them on a tap', (tester) async {
    report(const [_removed, _ignored]);
    await pumpSlot(tester);
    await tester.pumpAndSettle();

    expect(find.text('Config warnings'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text(_removed.message), findsNothing);

    await tester.tap(find.text('Config warnings'));
    await tester.pumpAndSettle();

    expect(find.text(_removed.message), findsOneWidget);
    expect(find.text('proxies[12]'), findsOneWidget);
    expect(find.text(_ignored.message), findsNothing);

    await tester.tap(find.text('Config warnings'));
    await tester.pumpAndSettle();

    expect(find.text(_removed.message), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaves with the warnings', (tester) async {
    report(const [_removed]);
    await pumpSlot(tester);
    await tester.pumpAndSettle();

    report(const []);
    await tester.pumpAndSettle();

    expect(find.text('Config warnings'), findsNothing);
  });
}

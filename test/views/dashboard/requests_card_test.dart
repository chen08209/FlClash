import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/requests.dart';
import 'package:fl_clash/views/dashboard/widgets/requests.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

const _mobileSize = Size(400, 800);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    Size size = const Size(1200, 1000),
  }) async {
    container.read(viewSizeProvider.notifier).value = size;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(body: ListView(children: const [RequestsCard()])),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the request count and follows it', (tester) async {
    await pumpCard(tester);

    expect(find.text('Recent requests'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    container.read(requestCountProvider.notifier).value = 42;
    await tester.pump();

    // The count repaints on the throttled cadence, not per request.
    expect(find.text('0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 301));

    expect(find.text('42'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping the card opens the requests in a sheet', (tester) async {
    await pumpCard(tester, size: _mobileSize);

    await tester.tap(find.byType(RequestsCard));
    await tester.pumpAndSettle();

    expect(find.byType(RequestsView), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(SheetDragHandle)).dy,
      closeTo(_mobileSize.height * 0.5, 1),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}

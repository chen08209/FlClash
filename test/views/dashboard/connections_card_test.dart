import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/connection/connections.dart';
import 'package:fl_clash/views/dashboard/widgets/connections.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCoreHandlerInterface core;
  late ProviderContainer container;

  setUpAll(() {
    core = MockCoreHandlerInterface();
    CoreController.resetInstance();
    CoreController.test(core);
  });

  tearDownAll(CoreController.resetInstance);

  setUp(() {
    reset(core);
    when(() => core.getConnections()).thenAnswer((_) async => const []);
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(1200, 1000);
  });

  tearDown(() => container.dispose());

  Future<void> pumpCard(
    WidgetTester tester, {
    Size size = const Size(1200, 1000),
    Future<int> Function()? countReader,
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
          child: Scaffold(
            body: ListView(
              children: [ConnectionsCard(countReader: countReader)],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Future<void> teardownCard(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('counts what the Core is holding open', (tester) async {
    var count = 2;
    await pumpCard(tester, countReader: () async => count);

    expect(find.text('Live connections'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    count = 1;
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    await teardownCard(tester);
  });

  testWidgets('tapping the card opens the connections in a sheet', (
    tester,
  ) async {
    await pumpCard(
      tester,
      size: const Size(400, 800),
      countReader: () async => 0,
    );

    await tester.tap(find.byType(ConnectionsCard));
    await tester.pumpAndSettle();

    expect(find.byType(ConnectionsView), findsOneWidget);

    await teardownCard(tester);
  });
}

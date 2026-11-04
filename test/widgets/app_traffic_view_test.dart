import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/traffic/app_traffic.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  late Database database;
  late ProviderContainer container;

  setUp(() async {
    database = Database(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        profilesProvider.overrideWith(
          () => TestProfiles([
            const Profile(
              id: 1,
              label: 'Test plan',
              autoUpdateDuration: Duration.zero,
            ),
          ]),
        ),
      ],
    );
    final now = DateTime.now();
    await database.appTrafficDao.addAll([
      AppTrafficDelta(
        day: DateTime(now.year, now.month, now.day),
        profileId: 1,
        profileLabel: 'Test plan',
        applicationId: 'browser',
        applicationLabel: 'Google Chrome',
        processPath: '',
        proxy: 'Proxy A',
        provider: 'Provider A',
        upload: 100,
        download: 200,
      ),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  testWidgets('renders preserved usage with the current app components', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: AppTrafficView(trafficDao: database.appTrafficDao),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Google Chrome'), findsOneWidget);
    expect(find.text('Test plan').hitTestable(), findsOneWidget);
    expect(find.text('App Traffic'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

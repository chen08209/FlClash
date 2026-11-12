import 'package:drift/native.dart';
import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/core_mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.Database testDatabase;
  late ProviderContainer container;
  late Map<String, int> requests;

  setUpAll(() => loadAppLocalizations(const Locale('en')));

  setUp(() {
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    requests = {};
    final mocks = coreMocks();
    when(() => mocks.api.updateGeo(any())).thenAnswer((invocation) async {
      final name = invocation.positionalArguments.single as String;
      final count = requests[name] = (requests[name] ?? 0) + 1;
      if (count > 1) {
        throw const CoreMethodException(
          code: 'rejected',
          message: 'geo update already in progress',
        );
      }
    });
    container = ProviderContainer(
      overrides: [coreHandlerProvider.overrideWithValue(mocks.controller)],
    );
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  test(
    'an update all that overlaps one running skips what that one runs',
    () async {
      final action = container.read(resourcesActionProvider.notifier);

      final failures = await Future.wait([
        action.updateAll(),
        action.updateAll(),
      ]);

      expect(failures.expand((items) => items), isEmpty);
      expect(requests, {
        for (final geoResource in GeoResource.values) geoResource.name: 1,
      });
    },
  );
}

import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/resources.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' hide context;

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory home;
  final supportDirectory = AppPath.supportDirectory;
  final temporaryDirectory = AppPath.temporaryDirectory;
  final cacheDirectory = AppPath.cacheDirectory;

  setUpAll(() async {
    home = Directory.systemTemp.createTempSync('flclash-resources-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    await appPath.homeDirPath;
  });

  tearDownAll(() {
    AppPath.supportDirectory = supportDirectory;
    AppPath.temporaryDirectory = temporaryDirectory;
    AppPath.cacheDirectory = cacheDirectory;
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  // `getFileInfo` stats the file on the real event loop, outside fake-async.
  Future<void> settle(WidgetTester tester, {int rounds = 1}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100; i++) {
      await settle(tester);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('timed out waiting for $finder');
  }

  testWidgets('uses decorated sections without displaying resource URLs', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DecorationListItem), findsNWidgets(6));
    expect(find.byType(ItemPositionProvider), findsNWidgets(4));
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsNWidgets(4));
    expect(find.byType(FutureBuilder<FileInfo?>), findsNWidgets(4));
    for (final url in defaultGeoXUrl.values) {
      expect(find.text(url), findsNothing);
    }

    final mmdbItem = find.ancestor(
      of: find.text(GeoResource.MMDB.name),
      matching: find.byType(DecorationListItem),
    );
    await tester.tap(
      find.descendant(of: mmdbItem, matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle();

    expect(find.text(currentAppLocalizations.edit), findsOneWidget);
    expect(find.text(currentAppLocalizations.sync), findsOneWidget);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('refreshes the file info once the core finishes updating', (
    tester,
  ) async {
    const size = Size(1000, 1000);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final file = File(join(home.path, MMDB))..writeAsBytesSync([0]);
    addTearDown(file.deleteSync);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: ResourcesView()),
      ),
    );
    await pumpUntilFound(tester, find.text(1.traffic.show));

    final updatingKeys = container.read(updatingKeysProvider.notifier);
    final key = GeoResource.MMDB.updatingKey;
    final operation = updatingKeys.start(key, scope: UpdatingScope.core);
    await settle(tester);
    file.writeAsBytesSync(List.filled(2048, 0));
    await settle(tester, rounds: 5);
    expect(find.text(1.traffic.show), findsOneWidget);

    updatingKeys.stop(key, operation);
    await pumpUntilFound(tester, find.text(2048.traffic.show));

    expect(find.text(1.traffic.show), findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

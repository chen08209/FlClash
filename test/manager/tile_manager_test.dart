import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/tile_manager.dart';
import 'package:fl_clash/plugins/tile.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_profiles.dart';

class _RecordingSetupAction extends SetupAction {
  static final requests = <bool>[];

  @override
  Future<void> setRunning(bool running, {bool initialize = false}) async {
    requests.add(running);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    _RecordingSetupAction.requests.clear();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
      ],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<TileListener> pumpTileManager(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TileManager(child: SizedBox.shrink())),
      ),
    );
    await tester.pump();
    return tester.state(find.byType(TileManager)) as TileListener;
  }

  void markStarted() {
    container.read(runTimeProvider.notifier).value = 1;
  }

  testWidgets('renders its child untouched', (tester) async {
    await pumpTileManager(tester);

    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('a tile start request starts a stopped core', (tester) async {
    final listener = await pumpTileManager(tester);

    listener.onStart();
    await tester.pumpAndSettle();

    expect(_RecordingSetupAction.requests, [true]);
  });

  testWidgets('a tile start request is ignored once already connected', (
    tester,
  ) async {
    final listener = await pumpTileManager(tester);
    markStarted();
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();

    listener.onStart();
    await tester.pumpAndSettle();

    expect(_RecordingSetupAction.requests, isEmpty);
  });

  testWidgets('a tile start request still runs while the core reconnects', (
    tester,
  ) async {
    final listener = await pumpTileManager(tester);
    markStarted();
    container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
    await tester.pump();

    listener.onStart();
    await tester.pumpAndSettle();

    expect(_RecordingSetupAction.requests, [true]);
  });

  testWidgets('a tile stop request stops a running core', (tester) async {
    final listener = await pumpTileManager(tester);
    markStarted();
    await tester.pump();

    listener.onStop();
    await tester.pumpAndSettle();

    expect(_RecordingSetupAction.requests, [false]);
  });

  testWidgets('a tile stop request is ignored when nothing is running', (
    tester,
  ) async {
    final listener = await pumpTileManager(tester);

    listener.onStop();
    await tester.pumpAndSettle();

    expect(_RecordingSetupAction.requests, isEmpty);
  });
}

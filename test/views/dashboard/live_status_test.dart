import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/widgets/live_status.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/host_scaffold.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

final _profile = Profile.normal(label: 'My subscription');

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([_profile])),
      ],
    );
    globalState.container = container;
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash',
      version: '0.9.3',
      buildNumber: '1',
    );
    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
  });

  tearDown(() => container.dispose());

  // The resource rows spin, so the deck never settles on its own.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> pumpButton(
    WidgetTester tester, {
    bool separateCore = false,
    Size size = const Size(800, 900),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          locale: const Locale('en'),
          child: HostScaffold(
            body: Padding(
              padding: const EdgeInsets.only(left: 400, top: 40),
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  height: 44,
                  child: LiveStatusButton(separateCore: separateCore),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Live status'));
    await settle(tester);
  }

  Finder front(String text) => find.text(text).hitTestable();

  testWidgets('is gone while nothing is happening', (tester) async {
    await pumpButton(tester);

    expect(find.byTooltip('Live status'), findsNothing);
  });

  testWidgets('wears the most important status and counts the rest', (
    tester,
  ) async {
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);

    expect(find.text('25%'), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await settle(tester);

    expect(find.textContaining('Core stopped'), findsOneWidget);
    expect(find.textContaining('+1'), findsOneWidget);
  });

  testWidgets('opens the deck on the top status and steps through it', (
    tester,
  ) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);

    expect(front('Restart core'), findsOneWidget);
    expect(front('Cancel'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);

    expect(front('Cancel'), findsOneWidget);
    expect(front('Restart core'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await settle(tester);

    expect(front('Restart core'), findsOneWidget);
  });

  testWidgets('a drag down brings the next card forward', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);

    await tester.drag(find.text('Core stopped').last, const Offset(0, 120));
    await settle(tester);

    expect(front('Cancel'), findsOneWidget);
  });

  testWidgets('keeps the shown card as the statuses change under it', (
    tester,
  ) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await settle(tester);

    expect(front('Cancel'), findsOneWidget);

    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateReady('v0.9.4', '/tmp/update');
    await settle(tester);

    expect(front('Install update'), findsOneWidget);
    expect(find.text('0.9.3'), findsOneWidget);
  });

  testWidgets('cancels a download from its card', (tester) async {
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);

    expect(
      find.text('${25.traffic.show} / ${100.traffic.show}'),
      findsOneWidget,
    );
    await tester.tap(front('Cancel'));
    await settle(tester);
  });

  testWidgets('lists the resources that are updating', (tester) async {
    final keys = container.read(updatingKeysProvider.notifier);
    keys.start(_profile.updatingKey);
    keys.start(GeoResource.GEOIP.updatingKey);
    await pumpButton(tester);
    await open(tester);

    expect(find.text('My subscription'), findsOneWidget);
    expect(find.text('GEOIP'), findsOneWidget);
    expect(find.text('2 items updating'), findsOneWidget);
    expect(find.text('View all'), findsNothing);
  });

  testWidgets('opens a long resource list in place and closes it', (
    tester,
  ) async {
    final keys = container.read(updatingKeysProvider.notifier);
    keys.start(_profile.updatingKey);
    for (final resource in GeoResource.values) {
      keys.start(resource.updatingKey);
    }
    for (final name in ['rejections', 'direct', 'streaming', 'ads']) {
      keys.start('provider_$name');
    }
    await pumpButton(tester);
    await open(tester);
    final card = find.byKey(const ValueKey<Object>(ResourcesStatus)).last;

    expect(find.text('rejections'), findsNothing);
    expect(tester.getSize(card).height, 300);

    await tester.tap(front('View all'));
    await settle(tester);

    expect(find.text('rejections'), findsOneWidget);
    expect(
      find.text('${GeoResource.values.length + 5} items updating'),
      findsOneWidget,
    );
    expect(front('Collapse'), findsOneWidget);
    final opened = tester.getRect(card);
    expect(opened.height, greaterThan(300));
    expect(opened.height, lessThanOrEqualTo(460));
    expect(opened.center.dy, closeTo(450, 0.5));

    await tester.tap(front('Collapse'));
    await settle(tester);

    expect(find.text('rejections'), findsNothing);
    expect(tester.getSize(card).height, 300);
  });

  testWidgets('drops a desktop deck under the bar at the right edge', (
    tester,
  ) async {
    container.read(viewSizeProvider.notifier).value = const Size(1200, 900);
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpButton(tester, size: const Size(1200, 900));
    final anchor = tester.getRect(find.byType(LiveStatusButton));
    await open(tester);

    final card = tester.getRect(
      find.byKey(const ValueKey<Object>(CoreLiveStatus)).last,
    );
    expect(card.right, 1200 - 16 - 24);
    expect(card.top, anchor.bottom + 56);
  });

  testWidgets('closes once nothing is left', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpButton(tester);
    await open(tester);

    expect(find.text('The app lost its connection to the core'), findsOne);

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await settle(tester);

    expect(find.text('The app lost its connection to the core'), findsNothing);
  });

  testWidgets('a tap outside the deck closes it', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpButton(tester);
    await open(tester);

    await tester.tapAt(const Offset(20, 880));
    await settle(tester);

    expect(find.text('Restart core'), findsNothing);
  });

  testWidgets('centers the front card where an alert sits', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpButton(tester);
    await open(tester);

    expect(
      tester.getCenter(find.byKey(const ValueKey<Object>(CoreLiveStatus)).last),
      const Offset(400, 450),
    );
  });

  group('a separate core', () {
    testWidgets('alone shrinks the button to a check that opens its card', (
      tester,
    ) async {
      await pumpButton(tester, separateCore: true);

      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);

      await open(tester);

      expect(find.text('Core running'), findsOneWidget);
      expect(front('Force restart'), findsOneWidget);
    });

    testWidgets('running comes last and is left out of the count', (
      tester,
    ) async {
      container.read(updateDownloadStateProvider.notifier).value =
          const UpdateDownloading('v0.9.4', received: 25, total: 100);
      await pumpButton(tester, separateCore: true);

      expect(find.text('25%'), findsOneWidget);
      expect(find.textContaining('+1'), findsNothing);

      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      expect(front('Force restart'), findsOneWidget);
    });

    testWidgets('asks before a force restart', (tester) async {
      await pumpButton(tester, separateCore: true);
      await open(tester);

      await tester.tap(front('Force restart'));
      await settle(tester);

      expect(
        find.text('Are you sure you want to force restart the core?'),
        findsOneWidget,
      );
    });

    testWidgets('holds starting for the minimum after a fast restart', (
      tester,
    ) async {
      await pumpButton(tester, separateCore: true);
      final status = container.read(coreStatusProvider.notifier);

      status.value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Connecting…'), findsOneWidget);

      status.value = CoreStatus.connected;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 199));
      expect(find.text('Connecting…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Connecting…'), findsNothing);
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    });

    testWidgets('shows a failed start at once', (tester) async {
      await pumpButton(tester, separateCore: true);
      final status = container.read(coreStatusProvider.notifier);

      status.value = CoreStatus.connecting;
      await tester.pump();
      status.value = CoreStatus.disconnected;
      await tester.pump();

      expect(find.textContaining('Core stopped'), findsOneWidget);
    });
  });
}

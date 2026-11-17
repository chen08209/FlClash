import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
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
import '../../helpers/module_reads.dart';
import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

final _profile = Profile.normal(label: 'My subscription');

void main() {
  late ProviderContainer container;
  var toAgree = <MitmModule>[];

  setUp(() {
    toAgree = [];
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([_profile])),
        mitmModulesToAgreeProvider.overrideWith((ref) => toAgree),
      ],
    );
    container.listen(appSettingProvider, (_, _) {});
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

  // A starting core spins, so the deck never settles on its own.
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

  Finder badge(String label) => find.byWidgetPredicate(
    (widget) => widget is Semantics && widget.properties.label == label,
  );

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

    expect(badge('Downloading update, 25%'), findsOneWidget);

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await settle(tester);

    expect(badge('Core stopped, 2'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('shows an update in progress and a finished one as full', (
    tester,
  ) async {
    final download = container.read(updateDownloadStateProvider.notifier);
    download.value = const UpdateDownloading(
      'v0.9.4',
      received: 25,
      total: 100,
    );
    await pumpButton(tester);

    expect(find.text('25%'), findsOneWidget);

    download.value = const UpdateReady('v0.9.4', '/tmp/update');
    await settle(tester);

    expect(badge('Update ready, 100%'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
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

  testWidgets('steps round from either end of the deck', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await settle(tester);

    expect(front('Cancel'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await settle(tester);

    expect(front('Cancel'), findsOneWidget);
    expect(front('Restart core'), findsNothing);
  });

  testWidgets('a card stepped past drops into the rear from behind it', (
    tester,
  ) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);
    final card = find.byKey(const ValueKey<Object>(CoreLiveStatus)).last;
    Offset topOf() => tester.getTopLeft(find.text('Core stopped').last);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    final arriving = topOf();
    await settle(tester);

    expect(card, findsOneWidget);
    expect(arriving.dy, lessThan(topOf().dy));
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

    expect(find.text('Stop downloading the update?'), findsOneWidget);
    expect(front('Stop'), findsOneWidget);

    await tester.tap(front('Cancel'));
    await settle(tester);

    expect(find.text('Stop downloading the update?'), findsNothing);
    expect(front('Cancel'), findsOneWidget);
    expect(front('Stop'), findsNothing);
  });

  testWidgets('names the modules an update turned off', (tester) async {
    MitmModule module(int id, String name) => MitmModule(
      id: id,
      name: name,
      enabled: false,
      lastUpdateTime: DateTime(2026, 11, 17),
    );
    toAgree = [module(1, 'Ads')];
    await pumpButton(tester);

    expect(badge('Modules turned off'), findsOneWidget);
    await open(tester);

    expect(front('Ads'), findsOneWidget);
    expect(
      find.text(
        'An update to Ads brought scripts or network changes you have not '
        'agreed to',
      ),
      findsOneWidget,
    );
    expect(front('View'), findsOneWidget);

    toAgree = [module(1, 'Ads'), module(2, 'Tracker'), module(3, 'Video')];
    container.invalidate(mitmModulesToAgreeProvider);
    await settle(tester);

    expect(front('+1'), findsOneWidget);
    expect(
      find.text(
        '3 modules got updates with scripts or network changes you have not '
        'agreed to',
      ),
      findsOneWidget,
    );
  });

  group('with modules stored', () {
    late Database testDatabase;

    setUp(() {
      testDatabase = Database(NativeDatabase.memory());
      database = testDatabase;
    });

    // The modules provider holds a query open until its container goes.
    tearDown(() {
      container.dispose();
      return testDatabase.close();
    });

    testWidgets('the module card asks about each module in turn', (
      tester,
    ) async {
      MitmModule module(int id, String name) => MitmModule(
        id: id,
        name: name,
        enabled: false,
        scripts: 1,
        order: id,
        lastUpdateTime: DateTime(2026, 11, 17),
      );
      await testDatabase.mitmModulesDao.putAll([
        module(1, 'Ads').toCompanion(),
        module(2, 'Tracker').toCompanion(),
      ]);
      container.dispose();
      container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([_profile])),
          for (final id in [1, 2])
            mitmModuleContentProvider(id).overrideWith(
              (ref) async =>
                  moduleDetails('', moduleRead(declaredScripts: const [1])),
            ),
        ],
      );
      globalState.container = container;
      container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
      await pumpButton(tester);
      await open(tester);

      await tester.tap(front('View'));
      for (final _ in [1, 2]) {
        await settle(tester);
        expect(
          find.text(currentAppLocalizations.mitmScriptRiskTitle),
          findsOneWidget,
        );
        await tester.tap(find.text(currentAppLocalizations.cancel));
      }
      await settle(tester);

      final stored = await testDatabase.mitmModulesDao.query().get();
      expect([for (final item in stored) item.accepted], [false, false]);
      expect(container.read(mitmModulesToAgreeProvider), isEmpty);
      expect(
        find.text(currentAppLocalizations.mitmScriptRiskTitle),
        findsNothing,
      );
      expect(badge('Modules turned off'), findsNothing);
    });
  });

  testWidgets('leaves updating resources out', (tester) async {
    container.read(updatingKeysProvider.notifier)
      ..start(_profile.updatingKey)
      ..start(GeoResource.GEOSITE.updatingKey);
    await pumpButton(tester);

    expect(find.byTooltip('Live status'), findsNothing);
  });

  testWidgets('fades in a card that arrives behind the shown one', (
    tester,
  ) async {
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);
    final card = find.byKey(const ValueKey<Object>(CoreLiveStatus)).last;
    double opacityOf() => tester
        .widget<Opacity>(
          find.ancestor(of: card, matching: find.byType(Opacity)).first,
        )
        .opacity;

    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    final arriving = opacityOf();
    await settle(tester);

    expect(arriving, greaterThan(0));
    expect(arriving, lessThan(opacityOf()));
    expect(front('Cancel'), findsOneWidget);
  });

  testWidgets('brings the next card up as the shown one goes', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    container.read(updateDownloadStateProvider.notifier).value =
        const UpdateDownloading('v0.9.4', received: 25, total: 100);
    await pumpButton(tester);
    await open(tester);
    final core = find.byKey(const ValueKey<Object>(CoreLiveStatus));
    Offset topOf() => tester.getTopLeft(
      find.byKey(const ValueKey<Object>(UpdateStatus)).last,
    );

    container.read(coreStatusProvider.notifier).value = CoreStatus.connected;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    final rising = topOf();

    expect(core, findsWidgets);

    await settle(tester);

    expect(core, findsNothing);
    expect(rising.dy, lessThan(topOf().dy));
    expect(front('Cancel'), findsOneWidget);
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

  group('config warnings', () {
    setUp(() {
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        openLogs: true,
      );
    });
    const removed = ConfigWarning(
      level: ConfigWarningLevel.warning,
      path: 'proxies[12]',
      message: 'masque is not supported, the proxy was removed',
    );
    const ignored = ConfigWarning(
      level: ConfigWarningLevel.info,
      path: 'experimental',
      message: 'ignored',
    );

    void report(List<ConfigWarning> warnings) {
      container.read(configWarningsStateProvider.notifier).value = warnings;
    }

    testWidgets('follow the logs setting in both the deck and hotspot count', (
      tester,
    ) async {
      final settings = container.read(appSettingProvider.notifier);
      settings.value = const AppSettingProps(openLogs: false);
      container.read(coreStatusProvider.notifier).value = CoreStatus.connecting;
      report(const [removed]);
      await pumpButton(tester, separateCore: true);

      expect(badge('Connecting…'), findsOneWidget);
      expect(find.text('2'), findsNothing);
      await open(tester);
      expect(find.byKey(const ValueKey<Object>(WarningsStatus)), findsNothing);

      settings.value = settings.value.copyWith(openLogs: true);
      await settle(tester);
      expect(badge('Connecting…, 2'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      expect(front('View all'), findsOneWidget);
      expect(find.text(removed.message), findsOneWidget);

      settings.value = settings.value.copyWith(openLogs: false);
      await settle(tester);
      expect(badge('Connecting…'), findsOneWidget);
      expect(find.byKey(const ValueKey<Object>(WarningsStatus)), findsNothing);
      expect(front('View all'), findsNothing);
      expect(container.read(configWarningsStateProvider), const [removed]);
    });

    testWidgets('alone stay hidden while logs are off', (tester) async {
      container.read(appSettingProvider.notifier).value = const AppSettingProps(
        openLogs: false,
      );
      report(const [removed]);
      await pumpButton(tester);
      expect(find.byTooltip('Live status'), findsNothing);
    });

    testWidgets('alone count the warnings on the button', (tester) async {
      report(const [
        removed,
        ConfigWarning(
          level: ConfigWarningLevel.warning,
          path: 'rules[3]',
          message: 'rule 3 was dropped',
        ),
      ]);
      await pumpButton(tester);

      expect(badge('Config warnings, 2'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('notes of the info level alone show nothing', (tester) async {
      report(const [ignored]);
      await pumpButton(tester);

      expect(find.byTooltip('Live status'), findsNothing);
    });

    testWidgets('come after an update', (tester) async {
      report(const [removed]);
      container.read(updateDownloadStateProvider.notifier).value =
          const UpdateDownloading('v0.9.4', received: 25, total: 100);
      await pumpButton(tester);

      expect(badge('Downloading update, 25%'), findsOneWidget);

      await open(tester);

      expect(front('Cancel'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      expect(front('View all'), findsOneWidget);
    });

    testWidgets('leave with the core', (tester) async {
      report(const [removed]);
      await pumpButton(tester);

      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      await settle(tester);

      expect(badge('Core stopped'), findsOneWidget);
    });

    testWidgets('list the first on their card and open it in place to all', (
      tester,
    ) async {
      report([
        removed,
        ignored,
        for (var i = 1; i <= 6; i++)
          ConfigWarning(
            level: ConfigWarningLevel.warning,
            path: 'rules[$i]',
            message: 'rule $i was dropped',
          ),
      ]);
      container.read(updateDownloadStateProvider.notifier).value =
          const UpdateDownloading('v0.9.4', received: 25, total: 100);
      await pumpButton(tester);
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);
      final card = find.byKey(const ValueKey<Object>(WarningsStatus)).last;
      final route = ModalRoute.of(tester.element(card));

      expect(find.text(removed.message), findsOneWidget);
      expect(find.text('proxies[12]'), findsOneWidget);
      expect(find.text('rule 2 was dropped'), findsOneWidget);
      expect(find.text('rule 3 was dropped'), findsNothing);
      expect(find.text('7 warnings from loading the config'), findsOneWidget);
      expect(find.text(ignored.message), findsNothing);
      expect(tester.getSize(card).height, 300);

      await tester.tap(front('View all'));
      await settle(tester);

      expect(ModalRoute.of(tester.element(card)), same(route));
      expect(route!.isCurrent, isTrue);
      expect(tester.getSize(card).height, greaterThan(300));
      expect(tester.getSize(card).height, lessThanOrEqualTo(460));
      expect(front('Collapse'), findsOneWidget);
      expect(
        find.text('7 warnings from loading the config').hitTestable(),
        findsNothing,
      );
      expect(find.text('rule 3 was dropped').hitTestable(), findsOneWidget);
      expect(find.text('rules[3]').hitTestable(), findsOneWidget);
      expect(find.text(ignored.message), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      expect(front('Collapse'), findsOneWidget);

      await tester.tap(front('Collapse'));
      await settle(tester);

      expect(tester.getSize(card).height, 300);
      expect(front('View all'), findsOneWidget);
      expect(find.text('rule 3 was dropped'), findsNothing);
    });

    testWidgets('opened to all lay out only the rows in view', (tester) async {
      report([
        for (var i = 1; i <= 500; i++)
          ConfigWarning(
            level: ConfigWarningLevel.warning,
            path: 'rules[$i]',
            message: 'rule $i was dropped',
          ),
      ]);
      container.read(updateDownloadStateProvider.notifier).value =
          const UpdateDownloading('v0.9.4', received: 25, total: 100);
      await pumpButton(tester);
      await open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await settle(tester);

      await tester.tap(front('View all'));
      await settle(tester);

      expect(find.text('rule 3 was dropped').hitTestable(), findsOneWidget);
      expect(
        find.text('rule 500 was dropped', skipOffstage: false),
        findsNothing,
      );
    });
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

      expect(badge('Downloading update, 25%'), findsOneWidget);

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

      expect(find.text('Force restart the core?'), findsOneWidget);
      expect(front('Restart'), findsOneWidget);
      expect(find.byType(LiveStatusButton), findsOneWidget);
      expect(
        find.text('Are you sure you want to force restart the core?'),
        findsNothing,
      );
    });

    testWidgets('holds starting for the minimum after a fast restart', (
      tester,
    ) async {
      await pumpButton(tester, separateCore: true);
      final status = container.read(coreStatusProvider.notifier);
      const step = Duration(milliseconds: 400);
      final rest = HeldCoreStatus.minimumStart - step;

      status.value = CoreStatus.connecting;
      await tester.pump();
      await tester.pump(step);
      expect(badge('Connecting…'), findsOneWidget);

      status.value = CoreStatus.connected;
      await tester.pump();
      await tester.pump(rest - const Duration(milliseconds: 1));
      expect(badge('Connecting…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(step);
      expect(badge('Connecting…'), findsNothing);
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    });

    testWidgets('an open deck shows a fast restart for the minimum', (
      tester,
    ) async {
      final status = container.read(coreStatusProvider.notifier);
      await pumpButton(tester, separateCore: true);
      await open(tester);

      status.value = CoreStatus.connecting;
      await tester.pump();
      status.value = CoreStatus.connected;
      await tester.pump();
      await tester.pump(HeldCoreStatus.minimumStart ~/ 2);

      expect(find.text('Starting core'), findsOneWidget);

      await tester.pump(HeldCoreStatus.minimumStart);
      await settle(tester);

      expect(find.text('Starting core'), findsNothing);
      expect(front('Force restart'), findsOneWidget);
    });

    testWidgets('shows a failed start at once', (tester) async {
      await pumpButton(tester, separateCore: true);
      final status = container.read(coreStatusProvider.notifier);

      status.value = CoreStatus.connecting;
      await tester.pump();
      status.value = CoreStatus.disconnected;
      await tester.pump();

      expect(badge('Core stopped'), findsOneWidget);
    });

    testWidgets('the stopped card says why the core stopped', (tester) async {
      container.read(coreStatusProvider.notifier).value =
          CoreStatus.disconnected;
      container.read(coreStopReasonProvider.notifier).value =
          'The core could not be launched';
      await pumpButton(tester, separateCore: true);

      await open(tester);

      expect(front('The core could not be launched'), findsOneWidget);
      expect(
        find.text('The app lost its connection to the core'),
        findsNothing,
      );
    });
  });
}

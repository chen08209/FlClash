import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/plugins/app_icon.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/detail_tabs.dart';
import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';
import '../helpers/record_lines.dart';

TrackerInfo _tracker({
  String rule = 'DOMAIN-SUFFIX',
  String rulePayload = '',
  String process = '',
  String processPath = '',
  int uid = 0,
  String sourceIP = '',
  String sourcePort = '',
  String destinationIP = '',
  String destinationPort = '',
  String host = '',
  List<String> chains = const [],
}) {
  return TrackerInfo(
    id: '1',
    start: DateTime(2026, 1, 1, 10, 30),
    metadata: Metadata(
      network: 'tcp',
      process: process,
      processPath: processPath,
      uid: uid,
      sourceIP: sourceIP,
      sourcePort: sourcePort,
      destinationIP: destinationIP,
      destinationPort: destinationPort,
      host: host,
    ),
    chains: chains,
    rule: rule,
    rulePayload: rulePayload,
  );
}

void main() {
  testWidgets('TrackerInfoDetailView renders formatted connection fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: _tracker(
              rule: 'DOMAIN-SUFFIX',
              rulePayload: 'example.com',
              process: 'chrome',
              uid: 1000,
              sourceIP: '1.2.3.4',
              sourcePort: '8080',
              destinationIP: '5.6.7.8',
              destinationPort: '443',
              host: 'example.com',
              chains: const ['DIRECT'],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await openDetailTab(tester, 'Info');

    expect(find.text('DOMAIN-SUFFIX,example.com'), findsOneWidget);
    expect(find.text('chrome'), findsOneWidget);
    expect(findRecordLine('Process [UID 1000]'), findsOneWidget);
    expect(find.text('1.2.3.4:8080'), findsOneWidget);
    expect(find.text('5.6.7.8:443'), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('DIRECT'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('DIRECT'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });

  for (final (width, columns, platform) in [
    (1000.0, 2, TargetPlatform.macOS),
    (700.0, 1, TargetPlatform.macOS),
    (400.0, 1, TargetPlatform.android),
  ]) {
    testWidgets('at $width wide the info sets its address in $columns '
        'column${columns == 1 ? '' : 's'} with the route', (tester) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          homeBuilder: (child) => HostScaffold(body: child),
          child: SheetProvider(
            type: SheetType.page,
            child: TrackerInfoDetailView(
              trackerInfo: _tracker(
                sourceIP: '1.2.3.4',
                sourcePort: '8080',
                chains: const ['DIRECT'],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await openDetailTab(tester, 'Info');

      final path = tester.getTopLeft(find.text('Path'));
      final traffic = tester.getTopLeft(find.text('Traffic'));
      final address = tester.getTopLeft(find.text('Address'));
      if (columns == 2) {
        expect(address.dy, path.dy);
        expect(address.dx, greaterThan(path.dx + width / 3));
      } else {
        expect(address.dx, path.dx);
        expect(address.dy, greaterThan(traffic.dy));
      }
      expect(
        tester
            .getSize(
              find.ancestor(
                of: find.text('1.2.3.4:8080'),
                matching: find.byType(ListRow),
              ),
            )
            .height,
        listRowExtent(titleHeight: 20),
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 5));
    });
  }

  testWidgets('a failed connection says so in red in its head, and leads its '
      'info with the failure under an error glyph, its traffic without speed', (
    tester,
  ) async {
    final failed = _tracker(process: 'curl', chains: const ['Proxy']).copyWith(
      closedAt: DateTime(2026, 1, 1, 10, 30, 3),
      download: 2048,
      downloadSpeed: 512,
      failure: const ConnectionFailure(
        kind: ConnectionFailureKind.timeout,
        message: 'i/o timeout',
      ),
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: failed,
            header: TrackerInfoHeader(trackerInfo: failed),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(recordLinesIn(tester, find.byType(TrackerInfoHeader)), [
      'curl [Proxy] [!Failed] [3 s]',
    ]);

    await openDetailTab(tester, 'Info');
    final failure = find.ancestor(
      of: find.text('i/o timeout'),
      matching: find.byType(DetailRow),
    );
    expect(
      find.descendant(of: failure, matching: find.byGlyph(AppGlyphs.error)),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('Timeout')).dy,
      lessThan(tester.getTopLeft(find.text('i/o timeout')).dy),
    );
    expect(find.text(2048.traffic.show), findsOneWidget);
    expect(find.textContaining('/s'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('TrackerInfoDetailView omits empty fields', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(trackerInfo: _tracker()),
        ),
      ),
    );
    await tester.pump();
    await openDetailTab(tester, 'Info');

    expect(find.textContaining('('), findsNothing);
    expect(find.text('tcp'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a failed connection says why, in its row and its detail', (
    tester,
  ) async {
    final failed = _tracker(host: 'example.com').copyWith(
      closedAt: DateTime(2026, 1, 1, 10, 31),
      failure: const ConnectionFailure(
        kind: ConnectionFailureKind.timeout,
        message: 'dial tcp 1.2.3.4:443: i/o timeout',
      ),
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: TrackerInfoItem(trackerInfo: failed, detailTitle: 'detail'),
      ),
    );
    await tester.pump();
    expect(recordLinesIn(tester), ['[!Timeout]']);

    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(trackerInfo: failed),
        ),
      ),
    );
    await tester.pump();
    await openDetailTab(tester, 'Info');
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('dial tcp 1.2.3.4:443: i/o timeout'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Closed at'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Closed at'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  Future<void> pumpItem(WidgetTester tester, TrackerInfo trackerInfo) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [packageIconSourceProvider.overrideWithValue(null)],
        homeBuilder: (child) => HostScaffold(body: child),
        child: TrackerInfoItem(
          key: ValueKey(trackerInfo),
          trackerInfo: trackerInfo,
          detailTitle: 'detail',
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('TrackerInfoItem reads its host, then its app, exit and age', (
    tester,
  ) async {
    final opened = DateTime.now().subtract(const Duration(seconds: 75));
    await pumpItem(
      tester,
      _tracker(
        process: 'chrome',
        destinationIP: '5.6.7.8',
        destinationPort: '443',
        host: 'example.com',
        chains: const ['Node', 'Group'],
      ).copyWith(start: opened),
    );

    expect(find.text('example.com'), findsOneWidget);
    expect(recordLinesIn(tester), ['[Group] [1:15]']);
    expect(find.text('chrome'), findsNothing);
    expect(find.text('C'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await pumpItem(
      tester,
      _tracker(destinationIP: '5.6.7.8', destinationPort: '443'),
    );
    expect(find.text('5.6.7.8:443'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem shows the speed of an open connection, and '
      'what a closed one moved', (tester) async {
    final open = _tracker(
      host: 'example.com',
    ).copyWith(uploadSpeed: 2048, downloadSpeed: 2048, download: 3072);
    Finder dot() => find.descendant(
      of: find.byType(TrackerAppWell),
      matching: find.byType(PositionedDirectional),
    );

    await pumpItem(tester, open);
    expect(_figure('4KB/s'), findsOneWidget);
    expect(_figure('3KB'), findsOneWidget);
    expect(dot(), findsOneWidget);

    final closedAt = open.start.add(const Duration(seconds: 6));
    await pumpItem(tester, open.copyWith(closedAt: closedAt));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is PlainTextLines &&
            widget.lines.any((line) => line.text.contains('/s')),
      ),
      findsNothing,
    );
    expect(_figure('3KB'), findsOneWidget);
    expect(find.textContaining('6 s'), findsOneWidget);
    expect(dot(), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a screen reader hears an open connection called active, and '
      'a closed one not', (tester) async {
    final semantics = tester.ensureSemantics();
    final open = _tracker(host: 'example.com');
    final active = find.bySemanticsLabel(RegExp(r'\bActive\b'));

    await pumpItem(tester, open);
    expect(active, findsOneWidget);

    await pumpItem(
      tester,
      open.copyWith(closedAt: open.start.add(const Duration(seconds: 6))),
    );
    expect(active, findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    semantics.dispose();
  });

  testWidgets('TrackerInfoDetailView lists the path from the app and rule '
      'through the group to the node, each hop with what it is', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        overrides: [
          groupsProvider.overrideWithBuild(
            (_, _) => const [
              Group(
                type: GroupType.URLTest,
                name: 'Auto',
                testUrl: 'https://group.test',
                all: [Proxy(name: 'Tokyo 01', type: 'Trojan')],
              ),
            ],
          ),
          delayProvider(
            proxyName: 'Tokyo 01',
            testUrl: 'https://group.test',
          ).overrideWithValue(38),
        ],
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: _tracker(
              process: 'chrome',
              rulePayload: 'example.com',
              chains: const ['Tokyo 01', 'Auto'],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await openDetailTab(tester, 'Info');

    double topOf(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(topOf('chrome'), lessThan(topOf('DOMAIN-SUFFIX,example.com')));
    expect(topOf('DOMAIN-SUFFIX,example.com'), lessThan(topOf('Auto')));
    expect(topOf('Auto'), lessThan(topOf('Tokyo 01')));
    expect(findRecordLine('Proxy group [URLTest]'), findsOneWidget);
    expect(findRecordLine('Node [Trojan]'), findsOneWidget);
    expect(find.text('38 ms'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('a connection without a host copies its address, an IPv6 one in '
      'brackets', () {
    expect(
      trackerCopyText(
        _tracker(destinationIP: '2001:db8::1', destinationPort: '443'),
      ),
      '[2001:db8::1]:443',
    );
    expect(
      trackerCopyText(
        _tracker(destinationIP: '1.2.3.4', destinationPort: '443'),
      ),
      '1.2.3.4:443',
    );
  });

  testWidgets('a target cell keeps its labels beside the host and cuts them '
      'off in a column too narrow for them', (tester) async {
    final failed = _tracker(host: 'example.com', destinationPort: '443')
        .copyWith(
          failure: const ConnectionFailure(
            kind: ConnectionFailureKind.unreachable,
          ),
        );
    Future<void> pumpAt(double width) => tester.pumpWidget(
      TestApp(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: width,
            height: 20,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TrackerTargetText(failed),
            ),
          ),
        ),
      ),
    );

    await pumpAt(400);
    final label = find.byType(RecordLabel);
    expect(
      tester.getTopLeft(label).dx,
      tester.getTopRight(find.byType(RichText).first).dx + 6,
    );
    await pumpAt(30);
    expect(tester.takeException(), isNull);
    expect(label, findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('a closed connection lasts until the Core says it ended', () {
    final start = DateTime(2026, 1, 1, 10, 30);
    final closed = _tracker().copyWith(
      closedAt: start.add(const Duration(seconds: 9)),
    );

    expect(trackerLifetimeText(closed, start), '9 s');
    expect(
      trackerLifetimeText(
        closed.copyWith(
          end: ConnectionEnd(
            reason: ConnectionEndReason.local,
            endedAt: start.add(const Duration(seconds: 4)),
          ),
        ),
        start,
      ),
      '4 s',
    );
  });

  group('the app icon of a connection', () {
    const channel = MethodChannel('$packageName/app');
    late Directory icons;
    late List<String> requested;
    late Map<String, Completer<void>> held;

    setUp(() {
      icons = Directory.systemTemp.createTempSync('icons');
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      );
      for (final name in ['com.own', 'default']) {
        File('${icons.path}/$name.png').writeAsBytesSync(png);
      }
      App().clearPackageIconCache();
      requested = [];
      held = {};
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            final name = call.arguments['packageName'] as String;
            requested.add(name);
            await held[name]?.future;
            return '${icons.path}/${name == 'com.own' ? name : 'default'}.png';
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      App().clearPackageIconCache();
      icons.deleteSync(recursive: true);
    });

    Future<void> pumpRow(
      WidgetTester tester,
      String process, {
      App? source,
    }) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(source)],
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoItem(
            trackerInfo: _tracker(process: process, host: 'example.com'),
            detailTitle: 'detail',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    Size wellSize(WidgetTester tester) =>
        tester.getSize(find.byType(TrackerAppWell));

    testWidgets('draws the icon an app gives as it is, with no well of its '
        'own under it', (tester) async {
      await pumpRow(tester, 'com.own', source: App());

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('C'), findsNothing);
      expect(wellSize(tester), const Size.square(40));
      expect(tester.getSize(find.byType(Image)), const Size.square(40));
      expect(
        find.descendant(
          of: find.byType(TrackerAppWell),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is ClipPath ||
                widget is ColoredBox ||
                widget is DecoratedBox &&
                    (widget.decoration as ShapeDecoration).shape
                        is! CircleBorder,
          ),
        ),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a letter stands as large as the icons the platform draws, '
        'with the live dot on its corner', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: Center(
            child: TrackerAppWell(
              trackerInfo: _tracker(host: 'example.com'),
              size: 40,
              iconBody: 0.8,
            ),
          ),
        ),
      );
      final appWell = find.byType(TrackerAppWell);
      final well = tester.getRect(appWell);
      final tile = tester.getRect(
        find.descendant(
          of: appWell,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                (widget.decoration as ShapeDecoration).shape is! CircleBorder,
          ),
        ),
      );
      final dot = tester.getRect(
        find.descendant(of: appWell, matching: find.byType(Container)),
      );

      expect(find.text('E'), findsOneWidget);
      expect(tile.size, const Size.square(32));
      expect(tile.center, well.center);
      expect(dot.right, tile.right + 2);
      expect(dot.bottom, tile.bottom + 2);
    });

    testWidgets('shows the initial of an app where no icon can be read, or '
        'of one already known to have none of its own', (tester) async {
      await pumpRow(tester, 'com.own');
      expect(find.byType(Image), findsNothing);
      expect(find.text('C'), findsOneWidget);

      await tester.runAsync(() => App().getOwnPackageIcon('com.plain'));
      await pumpRow(tester, 'com.plain', source: App());
      expect(find.byType(Image), findsNothing);
      expect(find.text('C'), findsOneWidget);
      expect(wellSize(tester), const Size.square(40));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a well keeps its size while an icon loads, and takes the '
        'letter where none of its own arrives, as it does once that is '
        'known', (tester) async {
      for (final (process, icon) in [
        ('com.own', 'com.own.png'),
        ('com.plain', null),
      ]) {
        held[process] = Completer();
        await pumpRow(tester, process, source: App());
        expect(find.byType(Image), findsNothing, reason: process);
        expect(find.text('C'), findsNothing, reason: process);
        expect(wellSize(tester), const Size.square(40), reason: process);

        held[process]!.complete();
        await tester.pump();
        await tester.pump();
        if (icon == null) {
          expect(find.byType(Image), findsNothing, reason: process);
          expect(find.text('C'), findsOneWidget, reason: process);
        } else {
          expect(
            (tester.widget<Image>(find.byType(Image)).image as FileImage)
                .file
                .path,
            endsWith(icon),
            reason: process,
          );
        }
        expect(wellSize(tester), const Size.square(40), reason: process);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('rows of one app ask Android for its icon once', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(App())],
          homeBuilder: (child) => HostScaffold(body: child),
          child: Column(
            children: [
              for (var index = 0; index < 3; index++)
                TrackerInfoItem(
                  trackerInfo: _tracker(process: 'com.own'),
                  detailTitle: 'detail',
                ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(Image), findsNWidgets(3));
      expect(requested.where((name) => name == 'com.own'), hasLength(1));
      expect(requested.where((name) => name.isEmpty), hasLength(1));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a row gone before its icon loads takes no update', (
      tester,
    ) async {
      held['com.own'] = Completer();
      await pumpRow(tester, 'com.own', source: App());
      await tester.pumpWidget(const SizedBox.shrink());

      held['com.own']!.complete();
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a row moved to another app does not take the icon its last '
        'app loads late', (tester) async {
      held['com.own'] = Completer();
      await pumpRow(tester, 'com.own', source: App());
      await pumpRow(tester, 'com.plain', source: App());

      held['com.own']!.complete();
      await tester.pump();
      await tester.pump();

      expect(find.byType(Image), findsNothing);
      expect(find.text('C'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a row of an app whose icon is cached shows it in its first '
        'frame', (tester) async {
      final app = App();
      await tester.runAsync(() => app.getOwnPackageIcon('com.own'));
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(app)],
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoItem(
            trackerInfo: _tracker(process: 'com.own'),
            detailTitle: 'detail',
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a desktop app icon is rendered with a pixel for each one '
        'of the largest well that draws it', (tester) async {
      const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Chrome';
      final rendered = <int>[];
      final source = DesktopAppIconSource(
        cacheDir: Future.value(icons.path),
        render: (path, size, _) async {
          rendered.add(size);
          return '${icons.path}/${path.isEmpty ? 'default' : 'com.own'}.png';
        },
      );
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          overrides: [
            packageIconSourceProvider.overrideWithValue(source),
            viewSizeProvider.overrideWithBuild(
              (_, _) => const Size(1400, 1000),
            ),
          ],
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoHeader(
            trackerInfo: _tracker(process: 'Chrome', processPath: chrome),
            showsMenu: false,
          ),
        ),
      );
      await tester.runAsync(() => source.getOwnPackageIcon(chrome));
      await tester.pump();
      await tester.pump();

      final shown = tester.getSize(find.byType(Image).first);
      expect(shown.width, 48);
      expect(
        rendered,
        everyElement(
          greaterThanOrEqualTo(shown.width * tester.view.devicePixelRatio),
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a desktop row shows the icon of the executable, not of the '
        'process name', (tester) async {
      const helper =
          '/Applications/Google Chrome.app/Contents/Frameworks/Helpers/'
          'Google Chrome Helper.app/Contents/MacOS/Google Chrome Helper';
      final rendered = <String>[];
      final source = DesktopAppIconSource(
        cacheDir: Future.value(icons.path),
        render: (path, _, _) async {
          rendered.add(path);
          return '${icons.path}/${path.isEmpty ? 'default' : 'com.own'}.png';
        },
      );
      final tracker = _tracker(
        process: 'Google Chrome Helper',
        processPath: helper,
      );
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(source)],
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoItem(trackerInfo: tracker, detailTitle: 'detail'),
        ),
      );
      await tester.runAsync(() => source.getOwnPackageIcon(helper));
      await tester.pump();
      await tester.pump();

      expect(rendered, unorderedEquals([helper, '']));
      final shown = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as FileImage).file.path);
      expect(shown, isNotEmpty);
      expect(shown, everyElement(endsWith('com.own.png')));

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

Finder _figure(String text) => find.byWidgetPredicate(
  (widget) =>
      widget is PlainTextLines && widget.lines.any((line) => line.text == text),
);

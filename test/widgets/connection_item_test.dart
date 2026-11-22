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
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/host_scaffold.dart';

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

    expect(find.text('DOMAIN-SUFFIX(example.com)'), findsOneWidget);
    expect(find.text('chrome'), findsOneWidget);
    expect(find.text('Process · UID 1000'), findsOneWidget);
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
    expect(find.widgetWithText(TonalChip, 'Timeout'), findsOneWidget);

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
    expect(find.text('chrome · Node · 1:15'), findsOneWidget);
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
    expect(find.text('4KB/s'), findsOneWidget);
    expect(find.text('3KB'), findsOneWidget);
    expect(dot(), findsOneWidget);

    final closedAt = open.start.add(const Duration(seconds: 6));
    await pumpItem(tester, open.copyWith(closedAt: closedAt));
    expect(find.textContaining('/s'), findsNothing);
    expect(find.text('3KB'), findsOneWidget);
    expect(find.textContaining('6 s'), findsOneWidget);
    expect(dot(), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
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

    double topOf(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(topOf('chrome'), lessThan(topOf('DOMAIN-SUFFIX(example.com)')));
    expect(topOf('DOMAIN-SUFFIX(example.com)'), lessThan(topOf('Auto')));
    expect(topOf('Auto'), lessThan(topOf('Tokyo 01')));
    expect(find.text('Proxy group · URLTest'), findsOneWidget);
    expect(find.text('Node · Trojan'), findsOneWidget);
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

  testWidgets('the status bar sets what it trails at its end', (tester) async {
    tester.view.physicalSize = const Size(800, 100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const end = Key('end');
    await tester.pumpWidget(
      const TestApp(
        wrapInProviderScope: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConnectionStatusBar(
            shown: 3,
            active: 1,
            selected: false,
            trailing: [SizedBox(key: end, width: 40, height: 20)],
          ),
        ),
      ),
    );

    expect(tester.getTopRight(find.byKey(end)).dx, 800 - 16);

    await tester.pumpWidget(const SizedBox.shrink());
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

    testWidgets('shows the icon an app draws in its well', (tester) async {
      await pumpRow(tester, 'com.own', source: App());

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('C'), findsNothing);
      expect(wellSize(tester), const Size.square(36));

      await tester.pumpWidget(const SizedBox.shrink());
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
      expect(wellSize(tester), const Size.square(36));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('a well keeps its size while an icon loads, and takes the '
        'generic app icon where none of its own arrives', (tester) async {
      for (final (process, icon) in [
        ('com.own', 'com.own.png'),
        ('com.plain', 'default.png'),
      ]) {
        held[process] = Completer();
        await pumpRow(tester, process, source: App());
        expect(find.byType(Image), findsNothing, reason: process);
        expect(wellSize(tester), const Size.square(36), reason: process);

        held[process]!.complete();
        await tester.pump();
        await tester.pump();
        expect(
          (tester.widget<Image>(find.byType(Image)).image as FileImage)
              .file
              .path,
          endsWith(icon),
          reason: process,
        );
        expect(wellSize(tester), const Size.square(36), reason: process);
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

      expect(
        (tester.widget<Image>(find.byType(Image)).image as FileImage).file.path,
        endsWith('default.png'),
      );
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

    testWidgets('a desktop row and its app group show the icon of the '
        'executable, not of the process name', (tester) async {
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
          child: Column(
            children: [
              TrackerInfoItem(trackerInfo: tracker, detailTitle: 'detail'),
              Expanded(
                child: TrackerInfoGroupedList(
                  groups: [
                    RecordGroup('Google Chrome Helper', [tracker]),
                  ],
                  grouping: RecordGrouping.app,
                  detailTitle: 'detail',
                ),
              ),
            ],
          ),
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

    Future<void> pumpGroups(WidgetTester tester) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(App())],
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoGroupedList(
            groups: [
              RecordGroup('com.own', [_tracker(process: 'com.own')]),
              RecordGroup('com.plain', [_tracker(process: 'com.plain')]),
              RecordGroup('', [_tracker(process: '')]),
            ],
            grouping: RecordGrouping.app,
            detailTitle: 'detail',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    Finder header(String label) => find.ancestor(
      of: find.textContaining(label).first,
      matching: find.byType(CollapsibleHeader),
    );

    String otherLabel(WidgetTester tester) => tester
        .element(find.byType(TrackerInfoGroupedList))
        .appLocalizations
        .other;

    double labelStart(WidgetTester tester, String label) =>
        tester.getTopLeft(find.textContaining(label).first).dx;

    testWidgets('an app group heads with its icon, or the generic one where '
        'the app has none, leaving no room for connections of no app', (
      tester,
    ) async {
      await pumpGroups(tester);

      expect(
        find.descendant(of: header('com.own'), matching: find.byType(Image)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header('com.plain'), matching: find.byType(Image)),
        findsOneWidget,
      );
      final bare = labelStart(tester, otherLabel(tester));
      expect(labelStart(tester, 'com.plain'), bare + 24 + 8);
      expect(labelStart(tester, 'com.own'), bare + 24 + 8);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('an app\'s icon arriving rebuilds nothing but the icon in '
        'its own group\'s header', (tester) async {
      held['com.own'] = Completer();
      final built = Expando<bool>();
      final rebuilt = <Element>[];
      debugOnRebuildDirtyWidget = (element, _) {
        if (built[element] ?? false) {
          rebuilt.add(element);
        }
        built[element] = true;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      await pumpGroups(tester);
      expect(
        find.descendant(of: header('com.own'), matching: find.byType(Image)),
        findsNothing,
      );
      rebuilt.clear();

      held['com.own']!.complete();
      await tester.pump();
      await tester.pump();

      expect(rebuilt.map((element) => element.widget.runtimeType), [
        OwnPackageIcon,
      ]);
      expect(
        find.descendant(
          of: header('com.own'),
          matching: find.byWidget(rebuilt.single.widget),
        ),
        findsOneWidget,
      );
      expect(
        labelStart(tester, 'com.own'),
        labelStart(tester, otherLabel(tester)) + 24 + 8,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/app.dart';
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
    expect(find.text('chrome(1000)'), findsOneWidget);
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

  testWidgets('TrackerInfoItem shows all chains and filters by them', (
    tester,
  ) async {
    final clicked = <RecordFilter>[];
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: RecordFilterScope(
          onFilter: clicked.add,
          child: TrackerInfoItem(
            trackerInfo: _tracker(chains: const ['Proxy A', 'Proxy B']),
            detailTitle: 'detail',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Proxy A'), findsOneWidget);
    expect(find.text('Proxy B'), findsOneWidget);

    await tester.tap(find.text('Proxy A'));
    await tester.pump();
    await tester.tap(find.text('Proxy B'));
    await tester.pump();

    expect(clicked, const [
      RecordFilter(RecordFacetKind.proxy, 'Proxy A'),
      RecordFilter(RecordFacetKind.proxy, 'Proxy B'),
    ]);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem reads from the rule to the node', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: TrackerInfoItem(
          trackerInfo: _tracker(
            rulePayload: 'example.com',
            process: 'chrome',
            uid: 1000,
            sourceIP: '1.2.3.4',
            sourcePort: '8080',
            destinationIP: '5.6.7.8',
            destinationPort: '443',
            host: 'example.com',
            chains: const ['Node', 'Group'],
          ),
          detailTitle: 'detail',
        ),
      ),
    );
    await tester.pump();

    final rule = tester.getCenter(find.text('DOMAIN-SUFFIX(example.com)'));
    final group = tester.getCenter(find.text('Group'));
    final node = tester.getCenter(find.text('Node'));
    expect(rule.dx, lessThan(group.dx));
    expect(group.dx, lessThan(node.dx));
    expect(find.text('example.com:443  5.6.7.8'), findsOneWidget);
    expect(find.text('chrome(1000)  ·  1.2.3.4:8080'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoItem shows speed only for a live connection', (
    tester,
  ) async {
    Future<void> pumpItem({required bool isLive}) async {
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoItem(
            key: ValueKey(isLive),
            trackerInfo: _tracker(
              host: 'example.com',
            ).copyWith(uploadSpeed: 2048, downloadSpeed: 4096),
            isLive: isLive,
            detailTitle: 'detail',
          ),
        ),
      );
      await tester.pump();
    }

    await pumpItem(isLive: false);
    expect(find.text(DateTime(2026, 1, 1, 10, 30).showFull), findsOneWidget);
    expect(find.textContaining('4KB/s'), findsNothing);

    await pumpItem(isLive: true);
    expect(find.text(DateTime(2026, 1, 1, 10, 30).showFull), findsNothing);
    expect(find.textContaining('4KB/s'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('TrackerInfoDetailView lists the chain from group to node', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        homeBuilder: (child) => HostScaffold(body: child),
        child: SheetProvider(
          type: SheetType.page,
          child: TrackerInfoDetailView(
            trackerInfo: _tracker(chains: const ['Node', 'Group']),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Node'),
      100,
      scrollable: find.byType(Scrollable),
    );

    expect(
      tester.getCenter(find.text('Group')).dx,
      lessThan(tester.getCenter(find.text('Node')).dx),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('the app icon of a connection', () {
    const channel = MethodChannel('$packageName/app');
    late Directory icons;

    setUp(() {
      icons = Directory.systemTemp.createTempSync('icons');
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      );
      for (final name in ['com.own', 'default']) {
        File('${icons.path}/$name.png').writeAsBytesSync(png);
      }
      App().clearPackageIconCache();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            final name = call.arguments['packageName'] as String;
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
      ValueChanged<RecordFilter>? onFilter,
    }) async {
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(source)],
          homeBuilder: (child) => HostScaffold(body: child),
          child: RecordFilterScope(
            onFilter: onFilter ?? (_) {},
            child: TrackerInfoItem(
              trackerInfo: _tracker(process: process, host: 'example.com'),
              detailTitle: 'detail',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
    }

    double titleInset(WidgetTester tester) =>
        tester.getTopLeft(find.textContaining('example.com')).dx -
        tester.getTopLeft(find.byType(RecordListItem)).dx;

    testWidgets('shows the icon an app draws and filters by its app', (
      tester,
    ) async {
      await pumpRow(tester, '', source: App());
      final bare = titleInset(tester);
      final clicked = <RecordFilter>[];
      await pumpRow(tester, 'com.own', source: App(), onFilter: clicked.add);

      expect(find.byType(Image), findsOneWidget);
      expect(titleInset(tester), bare + 24 + 8);
      await tester.tap(find.byType(Image));
      expect(clicked, const [RecordFilter(RecordFacetKind.app, 'com.own')]);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('leaves no room for an app without its own icon, or where no '
        'icon can be read', (tester) async {
      await pumpRow(tester, '', source: App());
      final bare = titleInset(tester);

      await pumpRow(tester, 'com.plain', source: App());
      expect(find.byType(Image), findsNothing);
      expect(titleInset(tester), bare);

      await pumpRow(tester, 'com.own');
      expect(find.byType(Image), findsNothing);
      expect(titleInset(tester), bare);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('an app group heads with its icon only where the app has '
        'one', (tester) async {
      final groups = [
        RecordGroup('com.own', [_tracker(process: 'com.own')]),
        RecordGroup('com.plain', [_tracker(process: 'com.plain')]),
      ];
      await tester.pumpWidget(
        TestApp(
          overrides: [packageIconSourceProvider.overrideWithValue(App())],
          homeBuilder: (child) => HostScaffold(body: child),
          child: TrackerInfoGroupedList(
            groups: groups,
            grouping: RecordGrouping.app,
            isLive: false,
            detailTitle: 'detail',
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      Finder header(String app) => find.ancestor(
        of: find.textContaining(app).first,
        matching: find.byType(CollapsibleHeader),
      );
      expect(
        find.descendant(of: header('com.own'), matching: find.byType(Image)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header('com.plain'), matching: find.byType(Image)),
        findsNothing,
      );

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

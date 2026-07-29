import 'dart:async';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:fl_clash/views/proxies/tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sourceAProxies = [
    Proxy(name: 'source-a-1', type: 'ss'),
    Proxy(name: 'source-a-2', type: 'ss'),
  ];
  const sourceBProxies = [
    Proxy(name: 'source-b-1', type: 'vmess'),
    Proxy(name: 'source-b-2', type: 'vmess'),
    Proxy(name: 'source-b-3', type: 'vmess'),
  ];

  Widget buildDelayButtonApp(Future<void> Function() onClick) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: Scaffold(floatingActionButton: DelayTestButton(onClick: onClick)),
    );
  }

  test('current visible category resolves to only that category node list', () {
    final groups = [
      const Group(
        type: GroupType.Selector,
        name: '来源 Source A',
        all: sourceAProxies,
      ),
      const Group(
        type: GroupType.Selector,
        name: '来源 Source B',
        all: sourceBProxies,
      ),
    ];

    final selected = resolveCurrentDelayTestGroup(
      groups: groups,
      activeIndex: 1,
      selectedGroupName: '来源 Source A',
    );

    expect(selected?.name, '来源 Source B');
    expect(selected?.all.map((proxy) => proxy.name), [
      'source-b-1',
      'source-b-2',
      'source-b-3',
    ]);
  });

  test('invalid or empty category never falls back to an aggregate group', () {
    final groups = [
      const Group(
        type: GroupType.Selector,
        name: 'FREE-NODES',
        all: [...sourceAProxies, ...sourceBProxies],
      ),
      const Group(
        type: GroupType.Selector,
        name: '来源 Source A',
        all: sourceAProxies,
      ),
    ];

    expect(
      resolveCurrentDelayTestGroup(
        groups: groups,
        activeIndex: null,
        selectedGroupName: '不存在的分类',
      ),
      isNull,
    );
    expect(
      resolveCurrentDelayTestGroup(
        groups: const [],
        activeIndex: 0,
        selectedGroupName: '来源 Source A',
      ),
      isNull,
    );
  });

  test(
    'category delay batches are lazy, bounded, and test every node',
    () async {
      var active = 0;
      var maxActive = 0;
      final testedNames = <String>[];

      await runProxyDelayTestBatches(
        proxies: sourceBProxies,
        batchSize: 2,
        testProxy: (proxy, _) async {
          active++;
          if (active > maxActive) maxActive = active;
          testedNames.add(proxy.name);
          await Future<void>.delayed(const Duration(milliseconds: 5));
          active--;
        },
      );

      expect(testedNames, ['source-b-1', 'source-b-2', 'source-b-3']);
      expect(testedNames, isNot(contains('source-a-1')));
      expect(maxActive, 2);
    },
  );

  test(
    'a failed node does not skip the rest of the current category',
    () async {
      final testedNames = <String>[];

      await expectLater(
        runProxyDelayTestBatches(
          proxies: sourceBProxies,
          batchSize: 2,
          testProxy: (proxy, _) async {
            testedNames.add(proxy.name);
            if (proxy.name == 'source-b-1') {
              throw StateError('simulated delay failure');
            }
          },
        ),
        throwsStateError,
      );

      expect(testedNames, ['source-b-1', 'source-b-2', 'source-b-3']);
    },
  );

  test('empty category performs no delay requests', () async {
    var calls = 0;

    await runProxyDelayTestBatches(
      proxies: const [],
      testProxy: (_, _) async {
        calls++;
      },
    );

    expect(calls, 0);
  });

  test('timeout-like delay failure becomes a final timeout state', () async {
    final delay = await requestProxyDelayWithFallback(
      testUrl: 'https://probe.example.com',
      proxyName: 'source-b-1',
      requestDelay: (_, _) async {
        throw TimeoutException('simulated timeout');
      },
    );

    expect(delay.name, 'source-b-1');
    expect(delay.url, 'https://probe.example.com');
    expect(delay.value, -1);
  });

  testWidgets(
    'delay button ignores repeated taps until its request completes',
    (tester) async {
      var calls = 0;
      var currentRun = Completer<void>();
      await tester.pumpWidget(
        buildDelayButtonApp(() {
          calls++;
          return currentRun.future;
        }),
      );

      await tester.tap(find.byIcon(Icons.network_ping));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byIcon(Icons.network_ping));
      await tester.pump();

      expect(calls, 1);

      currentRun.complete();
      await tester.pumpAndSettle();
      currentRun = Completer<void>();
      await tester.tap(find.byIcon(Icons.network_ping));
      await tester.pump();

      expect(calls, 2);

      currentRun.complete();
      await tester.pumpAndSettle();
    },
  );

  testWidgets('delay button resets after a failed request', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      buildDelayButtonApp(() async {
        calls++;
        if (calls == 1) throw StateError('simulated request failure');
      }),
    );

    await tester.tap(find.byIcon(Icons.network_ping));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.network_ping));
    await tester.pumpAndSettle();

    expect(calls, 2);
  });
}

import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/providers/route_state.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/service_status.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widget_registry.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/views/dashboard/widgets/service_status.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

ServiceCheckItem _item(
  String name,
  ServiceProbeStatus status, {
  int delay = 0,
  List<String> chains = const [],
  String region = '',
  int coreEpoch = 1,
}) => ServiceCheckItem(
  name: name,
  status: status.id,
  delay: delay,
  chains: chains,
  region: region,
  checkedAt: 1700000000000,
  coreEpoch: coreEpoch,
  picksVersion: 1,
);

OutboundIpResult _address(String ip, String country) => OutboundIpResult(
  url: 'https://www.cloudflare.com/cdn-cgi/trace',
  body: 'ip=$ip\nloc=$country\n',
  coreEpoch: 1,
  picksVersion: 1,
);

void main() {
  setUpAll(() {
    registerFallbackValue(const ServiceCheckParams(timeout: 0));
    registerFallbackValue(const OutboundIpParams(timeout: 0));
  });

  late _MockCore core;

  setUp(() => core = _MockCore());

  void answer(
    FutureOr<List<ServiceCheckItem>> Function(ServiceCheckParams params) check,
  ) {
    when(() => core.serviceCheck(any())).thenAnswer(
      (invocation) async =>
          check(invocation.positionalArguments.single as ServiceCheckParams),
    );
  }

  Widget app({
    FutureOr<OutboundIpResult?> Function(OutboundIpParams params)? outboundIp,
    bool started = true,
    AppSettingProps settings = const AppSettingProps(),
    double width = 360,
    DashboardDensity density = DashboardDensity.mobile,
    Locale locale = const Locale('en'),
    Widget body = const ServiceStatusCard(),
    IpQuality? ipQuality,
  }) {
    when(() => core.outboundIp(any())).thenAnswer((invocation) async {
      if (outboundIp == null) return Completer<OutboundIpResult?>().future;
      return outboundIp(
        invocation.positionalArguments.single as OutboundIpParams,
      );
    });
    return TestApp(
      locale: locale,
      overrides: [
        viewSizeProvider.overrideWithBuild((_, _) => const Size(400, 800)),
        appSettingProvider.overrideWithBuild((_, _) => settings),
        runTimeProvider.overrideWithBuild((_, _) => started ? 1 : null),
        routeTrackerProvider.overrideWithBuild(
          (ref, _) => RouteState(
            coreEpoch: 1,
            picksVersion: 1,
            hostEpoch: 1,
            proxied: ref.watch(isStartProvider),
            synced: true,
            live: true,
          ),
        ),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        ipQualityProvider.overrideWith(
          (_, _) => ipQuality != null
              ? Future.value(ipQuality)
              : Completer<IpQuality>().future,
        ),
      ],
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: density.isDesktop ? 176 : null,
            child: DashboardDensityScope(
              density: density,
              scale: 1,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  /// The card shows the first four enabled services.
  final shownIds = [
    for (final target in ServiceTarget.values.take(4)) target.id,
  ];

  AppSettingProps only(List<ServiceTarget> targets) => AppSettingProps(
    disabledServices: [
      for (final target in ServiceTarget.values)
        if (!targets.contains(target)) target.id,
    ],
  );

  Finder tile(ServiceTarget target) => find.descendant(
    of: find.byType(ServiceStatusCard),
    matching: find.text(target.label),
  );

  test('service status is registered as a dashboard card', () {
    expect(DashboardWidget.serviceStatus.card, isA<ServiceStatusCard>());
  });

  testWidgets('holds the latency with a skeleton until checked', (
    tester,
  ) async {
    final completion = Completer<List<ServiceCheckItem>>();
    answer((_) => completion.future);
    await tester.pumpWidget(app(settings: only([ServiceTarget.google])));
    await tester.pump();
    await tester.pump(commonDuration);
    expect(find.byType(SkeletonText), findsOneWidget);

    completion.complete([
      _item('google', ServiceProbeStatus.available, delay: 123),
    ]);
    await tester.pumpAndSettle();
    expect(find.byType(SkeletonText), findsNothing);
    expect(find.text('123 ms'), findsOneWidget);
    expect(find.text('All available'), findsOneWidget);
  });

  testWidgets('checks the first four services, and only those', (tester) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available, delay: 45),
      ];
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(asked, unorderedEquals(shownIds));
    for (final target in ServiceTarget.values.take(4)) {
      expect(tile(target), findsOneWidget);
    }
    expect(tile(ServiceTarget.values[4]), findsNothing);
    expect(find.text('45 ms'), findsNWidgets(4));
  });

  testWidgets('a desktop card checks the same four services', (tester) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return const [];
    });
    await tester.pumpWidget(
      app(width: 320, density: DashboardDensity.standard),
    );
    await tester.pumpAndSettle();

    expect(asked, unorderedEquals(shownIds));
    expect(find.byTooltip('Check all'), findsOneWidget);
    expect(find.text('Check all'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  double cellWidth(WidgetTester tester, ServiceTarget target) => tester
      .getSize(
        find.ancestor(of: tile(target), matching: find.byType(DashboardBlock)),
      )
      .width;

  double rowWidth(WidgetTester tester) =>
      tester.getSize(find.byType(DashboardCardHeader)).width;

  testWidgets('a lone last service takes the whole row', (tester) async {
    answer((_) => const []);
    final [first, second, third, ...] = ServiceTarget.values;
    await tester.pumpWidget(app(settings: only([first, second, third])));
    await tester.pumpAndSettle();

    expect(cellWidth(tester, first), lessThan(rowWidth(tester) / 2));
    expect(cellWidth(tester, third), rowWidth(tester));
  });

  testWidgets('a desktop card grows a single row of services into tiles', (
    tester,
  ) async {
    answer((_) => const []);
    final [first, second, ...] = ServiceTarget.values;
    await tester.pumpWidget(
      app(
        settings: only([first, second]),
        width: 320,
        density: DashboardDensity.standard,
      ),
    );
    await tester.pumpAndSettle();

    Rect cell(ServiceTarget target) => tester.getRect(
      find.ancestor(of: tile(target), matching: find.byType(DashboardBlock)),
    );
    expect(cell(first).top, cell(second).top);
    expect(cell(first).height, 46 * 2 + 8);
    expect(
      cell(second).right - cell(first).left,
      closeTo(rowWidth(tester), 0.01),
    );
    expect(
      tester.getTopLeft(tile(first)).dy,
      greaterThan(cell(first).center.dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the desktop header buttons stay round', (tester) async {
    answer((_) => const []);
    await tester.pumpWidget(
      app(width: 320, density: DashboardDensity.standard),
    );
    await tester.pumpAndSettle();

    final button = tester.getSize(
      find.ancestor(
        of: find.byTooltip('Check all'),
        matching: find.byType(IconButton),
      ),
    );
    expect(button.width, button.height);
  });

  testWidgets('a problem keeps its place and counts in the verdict', (
    tester,
  ) async {
    answer(
      (params) => [
        for (final name in params.names)
          _item(
            name,
            name == 'youtube'
                ? ServiceProbeStatus.unsupportedRegion
                : ServiceProbeStatus.available,
            delay: 30,
          ),
      ],
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    final youtube = tester.getTopLeft(tile(ServiceTarget.youtube));
    final google = tester.getTopLeft(tile(ServiceTarget.google));
    expect(youtube.dy, greaterThan(google.dy));
    expect(youtube.dx, google.dx);
    expect(find.text('Region not supported'), findsOneWidget);
    expect(find.text('1 issue'), findsOneWidget);
    expect(find.text('All available'), findsNothing);
  });

  testWidgets('checks the shown service directly while the proxy is off', (
    tester,
  ) async {
    final asked = <ServiceCheckParams>[];
    answer((params) {
      asked.add(params);
      return [_item('google', ServiceProbeStatus.available, delay: 45)];
    });
    await tester.pumpWidget(
      app(started: false, settings: only([ServiceTarget.google])),
    );
    await tester.pumpAndSettle();

    expect(asked.single.proxyName, directOutbound);
    expect(find.text('45 ms'), findsOneWidget);
  });

  Future<Finder> openCheckedSheet(
    WidgetTester tester, {
    required FutureOr<OutboundIpResult?> Function(OutboundIpParams params)
    outboundIp,
  }) async {
    answer(
      (params) => [
        for (final name in params.names)
          _item(
            name,
            ServiceProbeStatus.available,
            region: 'JP',
            chains: ['HK-01'],
          ),
      ],
    );
    await tester.pumpWidget(app(outboundIp: outboundIp));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Check all'));
    await tester.pumpAndSettle();
    return find.byType(ServiceStatusSheet);
  }

  testWidgets(
    'the sheet shows the flag and the address each node leaves from',
    (tester) async {
      final outboundIps = <String>[];
      final sheet = await openCheckedSheet(
        tester,
        outboundIp: (params) {
          outboundIps.add(params.proxyName);
          return _address('203.0.113.7', 'US');
        },
      );

      expect(outboundIps, ['HK-01']);
      expect(
        find.descendant(of: sheet, matching: find.text('203.0.113.7')),
        findsWidgets,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('\u{1F1FA}\u{1F1F8}')),
        findsWidgets,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('HK-01')),
        findsNothing,
      );
    },
  );

  testWidgets('an address in the sheet opens its quality as a page of it', (
    tester,
  ) async {
    final sheet = await openCheckedSheet(
      tester,
      outboundIp: (_) => _address('203.0.113.7', 'US'),
    );

    await tester.tap(
      find.descendant(of: sheet, matching: find.text('203.0.113.7')).first,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(commonDuration * 2);
    final title = find.text('Outbound IP');
    expect(title, findsOneWidget);
    expect(find.byType(ServiceStatusSheet), findsNothing);
    expect(
      Navigator.of(tester.element(title)).widget,
      isA<SheetPagesNavigator>(),
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(commonDuration * 2);
    expect(find.byType(ServiceStatusSheet), findsOneWidget);
    expect(title, findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  const quality = IpQuality(
    ip: '203.0.113.7',
    source: IpQualitySource.ipApiIs,
    type: IpType.residential,
    organization: 'Example Broadband',
    asn: 64500,
  );

  for (final loaded in [false, true]) {
    testWidgets(
      'a quality page settles the sheet once at the short sheet height '
      '${loaded ? 'when loaded' : 'while loading'}',
      (tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        answer(
          (params) => [
            for (final name in params.names)
              _item(name, ServiceProbeStatus.available, chains: ['HK-01']),
          ],
        );
        await tester.pumpWidget(
          app(
            outboundIp: (_) => _address('203.0.113.7', 'US'),
            ipQuality: loaded ? quality : null,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ServiceStatusCard));
        await tester.pumpAndSettle();
        final sheet = find.byType(ServiceStatusSheet);
        double height() => tester.getSize(find.byType(PagedSheet)).height;

        await tester.tap(
          find.descendant(of: sheet, matching: find.text('203.0.113.7')).first,
        );
        final heights = <double>[];
        for (var frame = 0; frame < 12; frame++) {
          await tester.pump(const Duration(milliseconds: 50));
          heights.add(height());
        }
        for (var i = 1; i < heights.length; i++) {
          expect(heights[i], lessThanOrEqualTo(heights[i - 1]));
        }
        expect(heights.last, 800 * snapSheetDetents.first);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }

  testWidgets('the address sheet is as tall loading as loaded', (tester) async {
    tester.view.physicalSize = const Size(600, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<double> heightOf(IpQuality? ipQuality) async {
      answer(
        (_) => [
          _item('google', ServiceProbeStatus.available, chains: ['HK-01']),
        ],
      );
      await tester.pumpWidget(
        app(
          outboundIp: (_) => _address('203.0.113.7', 'US'),
          ipQuality: ipQuality,
          settings: only([ServiceTarget.google]),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ServiceStatusCard));
      await tester.pumpAndSettle();
      await tester.tap(find.text('\u{1F1FA}\u{1F1F8}').first);
      await tester.pump();
      await tester.pump(commonDuration * 2);
      final height = tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Outbound IP'),
                  matching: find.byType(CommonScaffold),
                )
                .first,
          )
          .height;
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      return height;
    }

    final loading = await heightOf(null);
    expect(find.text('Residential'), findsNothing);
    expect(await heightOf(quality), loading);
  });

  testWidgets('a sheet row falls back to the node without an address', (
    tester,
  ) async {
    final sheet = await openCheckedSheet(tester, outboundIp: (_) => null);

    expect(
      find.descendant(of: sheet, matching: find.text('HK-01')),
      findsWidgets,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('\u{1F1EF}\u{1F1F5}')),
      findsWidgets,
    );
  });

  testWidgets('tapping the card lists every service in a sheet', (
    tester,
  ) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available, delay: 30),
      ];
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();

    expect(find.byType(ServiceStatusSheet), findsOneWidget);
    expect(asked, unorderedEquals(shownIds));
    expect(find.text('Not checked'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(ServiceStatusSheet),
        matching: find.text(ServiceTarget.github.label),
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        DateTime.fromMillisecondsSinceEpoch(1700000000000).showTime.trim(),
      ),
      findsWidgets,
    );
    final list = tester.widget<SliverList>(
      find.descendant(
        of: find.byType(ServiceStatusSheet),
        matching: find.byType(SliverList),
      ),
    );
    final delegate = list.delegate as SliverChildBuilderDelegate;
    expect(delegate.childCount, ServiceTarget.values.length);
    for (final tooltip in ['Check all', 'Manage services']) {
      expect(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.descendant(
            of: find.byType(AppBar),
            matching: find.byType(TonalButtonGroup),
          ),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('the sheet is only as tall as the services it lists', (
    tester,
  ) async {
    answer((params) => const []);
    await tester.pumpWidget(
      app(
        settings: AppSettingProps(
          disabledServices: [
            for (final target in ServiceTarget.values)
              if (target != ServiceTarget.google) target.id,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();

    final sheet = tester.getSize(find.byType(ServiceStatusSheet)).height;
    final row = tester.getSize(find.byType(ListTile)).height;
    expect(sheet, lessThan(sheetAppBarHeight + row * 3));
  });

  Finder checkAllButton() => find.ancestor(
    of: find.byTooltip('Check all'),
    matching: find.byType(IconButton),
  );

  testWidgets('the sheet checks every service, each on its own', (
    tester,
  ) async {
    final asked = <List<String>>[];
    final sweep = Completer<void>();
    answer((params) async {
      asked.add(params.names);
      if (asked.length > 4) await sweep.future;
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available, delay: 30),
      ];
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();
    expect(asked.expand((names) => names), unorderedEquals(shownIds));

    await tester.tap(checkAllButton());
    await tester.pump();
    expect(asked.skip(4), [
      for (final target in ServiceTarget.values) [target.id],
    ]);
    expect(tester.widget<IconButton>(checkAllButton()).onPressed, isNull);

    sweep.complete();
    await tester.pumpAndSettle();
    expect(asked, hasLength(ServiceTarget.values.length + 4));
    expect(find.text('Not checked'), findsNothing);
    expect(tester.widget<IconButton>(checkAllButton()).onPressed, isNotNull);
  });

  testWidgets('tapping a sheet row checks its service again', (tester) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available, delay: 30),
      ];
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(ServiceStatusSheet),
        matching: find.text(ServiceTarget.chatgpt.label),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ServiceStatusSheet), findsOneWidget);
    expect(asked.skip(4), [ServiceTarget.chatgpt.id]);
  });
  testWidgets('a route change checks the shown service again once', (
    tester,
  ) async {
    final asked = <String>[];
    var epoch = 1;
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available, coreEpoch: epoch),
      ];
    });
    await tester.pumpWidget(app(settings: only([ServiceTarget.google])));
    await tester.pumpAndSettle();
    expect(asked, ['google']);

    epoch = 2;
    ProviderScope.containerOf(tester.element(find.byType(ServiceStatusCard)))
        .read(routeTrackerProvider.notifier)
        .applySnapshot(const RouteSnapshot(coreEpoch: 2, picksVersion: 1));
    await tester.pumpAndSettle();

    expect(asked, ['google', 'google']);
    expect(find.text('Available'), findsOneWidget);
  });

  testWidgets('a row re-checks its service on its own button', (tester) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available, delay: 30),
      ];
    });
    await tester.pumpWidget(
      app(settings: only([ServiceTarget.google, ServiceTarget.github])),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();
    expect(asked, unorderedEquals(['google', 'github']));

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, ServiceTarget.github.label),
        matching: find.byTooltip('Check'),
      ),
    );
    await tester.pumpAndSettle();
    expect(asked, hasLength(3));
    expect(asked.last, 'github');
  });

  testWidgets('a row keeps its height through a check', (tester) async {
    final claude = Completer<void>();
    answer((params) async {
      if (params.names.contains('claude')) await claude.future;
      return [
        for (final name in params.names)
          _item(
            name,
            ServiceProbeStatus.available,
            delay: 30,
            chains: const ['Node A'],
          ),
      ];
    });
    await tester.pumpWidget(
      app(
        outboundIp: (_) => _address('203.0.113.7', 'US'),
        settings: only(ServiceTarget.values.take(5).toList()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();

    final row = find.widgetWithText(ListTile, ServiceTarget.claude.label);
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    final unchecked = tester.getSize(row).height;
    await tester.tap(
      find.descendant(of: row, matching: find.byTooltip('Check')),
    );
    await tester.pump();
    expect(tester.getSize(row).height, unchecked);

    claude.complete();
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: row, matching: find.text('203.0.113.7')),
      findsOne,
    );
    expect(tester.getSize(row).height, unchecked);
  });

  testWidgets('the sheet still offers checks while the proxy is off', (
    tester,
  ) async {
    answer((params) => const []);
    await tester.pumpWidget(app(started: false));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();

    final buttons = tester.widgetList<IconButton>(
      find.ancestor(
        of: find.byGlyph(AppGlyphs.refresh),
        matching: find.byType(IconButton),
      ),
    );
    expect(buttons, isNotEmpty);
    expect(buttons.every((button) => button.onPressed != null), isTrue);
    expect(tester.widget<IconButton>(checkAllButton()).onPressed, isNotNull);
  });

  AppSettingProps settingsOf(WidgetTester tester) => ProviderScope.containerOf(
    tester.element(find.byType(ServiceStatusCard)),
  ).read(appSettingProvider);

  Future<void> openManage(WidgetTester tester) async {
    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Manage services'));
    await tester.pumpAndSettle();
  }

  Finder switchOf(ServiceTarget target) => find.descendant(
    of: find.widgetWithText(DecorationListItem, target.label),
    matching: find.byType(Switch),
  );

  testWidgets('the tile and the sheet follow the saved order', (tester) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available),
      ];
    });
    await tester.pumpWidget(
      app(
        settings: const AppSettingProps(
          serviceOrder: ['claude', 'google'],
          disabledServices: ['github'],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(asked, ['claude', 'google', 'youtube', 'chatgpt']);
    expect(
      tester.getCenter(tile(ServiceTarget.claude)).dx,
      lessThan(tester.getCenter(tile(ServiceTarget.google)).dx),
    );

    await tester.tap(find.byType(ServiceStatusCard));
    await tester.pumpAndSettle();
    final labels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(ServiceStatusSheet),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  ServiceTarget.values.any(
                    (target) => target.label == widget.data,
                  ),
            ),
          ),
        )
        .map((text) => text.data)
        .take(3);
    expect(labels, ['Claude', 'Google', 'YouTube']);
    expect(find.text(ServiceTarget.github.label), findsNothing);
  });

  testWidgets('services are turned off from a page pushed inside the sheet', (
    tester,
  ) async {
    answer((params) => const []);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await openManage(tester);

    expect(find.text('Manage services'), findsOneWidget);
    expect(find.byType(ServiceStatusSheet), findsNothing);
    await tester.tap(switchOf(ServiceTarget.youtube));
    await tester.pumpAndSettle();
    expect(settingsOf(tester).disabledServices, ['youtube']);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceStatusSheet), findsOneWidget);
    expect(find.text(ServiceTarget.youtube.label), findsNothing);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceStatusSheet), findsNothing);
    expect(find.byType(ServiceStatusCard), findsOneWidget);
  });

  testWidgets('the manage page marks the services the card shows', (
    tester,
  ) async {
    answer((params) => const []);
    await tester.pumpWidget(
      app(settings: const AppSettingProps(disabledServices: ['github'])),
    );
    await tester.pumpAndSettle();
    await openManage(tester);

    Finder marked(ServiceTarget target) => find.descendant(
      of: find.widgetWithText(DecorationListItem, target.label),
      matching: find.text('Shown on the dashboard'),
    );
    for (final target in [
      ServiceTarget.google,
      ServiceTarget.youtube,
      ServiceTarget.chatgpt,
      ServiceTarget.claude,
    ]) {
      expect(marked(target), findsOneWidget, reason: target.label);
    }
    expect(marked(ServiceTarget.github), findsNothing);
    expect(marked(ServiceTarget.gemini), findsNothing);
  });

  testWidgets('the last enabled service cannot be turned off', (tester) async {
    answer((params) => const []);
    await tester.pumpWidget(
      app(
        settings: AppSettingProps(
          disabledServices: [
            for (final target in ServiceTarget.values)
              if (target != ServiceTarget.google) target.id,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await openManage(tester);

    expect(
      tester.widget<Switch>(switchOf(ServiceTarget.google)).onChanged,
      isNull,
    );
    expect(
      tester.widget<Switch>(switchOf(ServiceTarget.github)).onChanged,
      isNotNull,
    );
  });

  testWidgets('long pressing a service in the manage page drags it', (
    tester,
  ) async {
    answer((params) => const []);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await openManage(tester);

    expect(find.byGlyph(AppGlyphs.dragHandle), findsNothing);
    final row = find.widgetWithText(
      DecorationListItem,
      ServiceTarget.google.label,
    );
    final rowHeight = tester.getSize(row).height;
    final gesture = await tester.startGesture(
      tester.getCenter(
        find.descendant(
          of: row,
          matching: find.text(ServiceTarget.google.label),
        ),
      ),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(Offset(0, rowHeight * 0.3));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(settingsOf(tester).serviceOrder.take(2), ['github', 'google']);
  });

  testWidgets('a turned off service leaves the tiles to the next one', (
    tester,
  ) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available),
      ];
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(asked, unorderedEquals(shownIds));

    ProviderScope.containerOf(
      tester.element(find.byType(ServiceStatusCard)),
    ).read(appSettingProvider.notifier).value = const AppSettingProps(
      disabledServices: ['google'],
    );
    await tester.pumpAndSettle();

    expect(tile(ServiceTarget.google), findsNothing);
    expect(asked.skip(4), [ServiceTarget.values[4].id]);
  });

  testWidgets('an unexpected error shows the check as failed', (tester) async {
    answer(
      (params) => [
        for (final name in params.names) _item(name, ServiceProbeStatus.failed),
      ],
    );
    await tester.pumpWidget(app(settings: only([ServiceTarget.google])));
    await tester.pumpAndSettle();
    expect(find.text('Check failed'), findsOneWidget);
  });

  testWidgets('a check without a node keeps the title in place', (
    tester,
  ) async {
    final completion = Completer<List<ServiceCheckItem>>();
    answer((_) => completion.future);
    await tester.pumpWidget(app(settings: only([ServiceTarget.google])));
    await tester.pump();
    await tester.pump(commonDuration);
    final title = find.text(ServiceTarget.google.label);
    final checking = tester.getTopLeft(title).dy;

    completion.complete([_item('google', ServiceProbeStatus.failed)]);
    await tester.pumpAndSettle();
    expect(find.text('Check failed'), findsOneWidget);
    expect(tester.getTopLeft(title).dy, checking);
  });

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(ServiceStatusCard)));

  void setStarted(WidgetTester tester, bool started) {
    final runTime = containerOf(tester).read(runTimeProvider.notifier);
    runTime.value = started ? 1 : null;
  }

  ProbePhase checkPhase(WidgetTester tester) => containerOf(
    tester,
  ).read(serviceStatusProvider).entryOf(ServiceTarget.google).phase;

  testWidgets('a check that fails as the proxy starts shows as checking', (
    tester,
  ) async {
    var epoch = 1;
    answer(
      (params) => [
        for (final name in params.names)
          _item(
            name,
            params.proxyName == directOutbound || epoch > 1
                ? ServiceProbeStatus.available
                : ServiceProbeStatus.failed,
            coreEpoch: epoch,
          ),
      ],
    );
    await tester.pumpWidget(
      app(started: false, settings: only([ServiceTarget.google])),
    );
    await tester.pumpAndSettle();

    setStarted(tester, true);
    await tester.pump();
    await tester.pump(commonDuration);
    expect(checkPhase(tester), ProbePhase.failed);
    expect(find.text('Check failed'), findsNothing);
    expect(find.byType(SkeletonText), findsWidgets);

    epoch = 2;
    containerOf(tester)
        .read(routeTrackerProvider.notifier)
        .applySnapshot(const RouteSnapshot(coreEpoch: 2, picksVersion: 1));
    await tester.pump();
    await tester.pump(commonDuration);
    expect(find.text('Available'), findsOneWidget);
    expect(find.byType(SkeletonText), findsNothing);
  });

  testWidgets('a failure that outlasts the start is shown', (tester) async {
    answer(
      (params) => [
        for (final name in params.names)
          _item(
            name,
            params.proxyName == directOutbound
                ? ServiceProbeStatus.available
                : ServiceProbeStatus.failed,
          ),
      ],
    );
    await tester.pumpWidget(
      app(started: false, settings: only([ServiceTarget.google])),
    );
    await tester.pumpAndSettle();

    setStarted(tester, true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(checkPhase(tester), ProbePhase.failed);
    expect(find.text('Check failed'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Check failed'), findsOneWidget);
  });

  testWidgets('stopping the proxy shows a failure without waiting', (
    tester,
  ) async {
    answer(
      (params) => [
        for (final name in params.names) _item(name, ServiceProbeStatus.failed),
      ],
    );
    await tester.pumpWidget(
      app(started: false, settings: only([ServiceTarget.google])),
    );
    await tester.pumpAndSettle();

    setStarted(tester, true);
    await tester.pump();
    await tester.pump(commonDuration);
    expect(checkPhase(tester), ProbePhase.failed);
    expect(find.text('Check failed'), findsNothing);

    setStarted(tester, false);
    await tester.pump();
    await tester.pump(commonDuration);
    expect(find.text('Check failed'), findsOneWidget);
  });

  testWidgets('leaving the dashboard releases the shown services', (
    tester,
  ) async {
    final asked = <String>[];
    answer((params) {
      asked.addAll(params.names);
      return [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.available),
      ];
    });
    await tester.pumpWidget(app(settings: only([ServiceTarget.google])));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ServiceStatusCard)),
    );

    await tester.pumpWidget(app(body: const SizedBox.shrink()));
    container.read(routeTrackerProvider.notifier).bumpHostEpoch();
    await tester.pump();

    expect(asked, ['google']);
    expect(container.read(serviceStatusProvider).entries, isEmpty);
  });

  testWidgets('fits its card at narrow and wide sizes in every locale', (
    tester,
  ) async {
    answer(
      (params) => [
        for (final name in params.names)
          _item(name, ServiceProbeStatus.unsupportedRegion, delay: 1234),
      ],
    );
    for (final locale in [
      const Locale('en'),
      const Locale('zh', 'CN'),
      const Locale('ja'),
      const Locale('ru'),
    ]) {
      for (final (width, density) in [
        (288.0, DashboardDensity.mobile),
        (552.0, DashboardDensity.mobile),
        (252.0, DashboardDensity.compact),
        (290.0, DashboardDensity.standard),
      ]) {
        await tester.pumpWidget(
          app(width: width, density: density, locale: locale),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$locale at $width');
      }
    }
  });
}

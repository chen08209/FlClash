import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/common/service_probe.dart'
    show directOutbound, routedOutbound;
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/views/dashboard/widgets/current_outbound.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';

const _ip = '203.0.113.9';

const _profile = Profile(id: 1, autoUpdateDuration: Duration.zero);

const _residential = IpQuality(
  ip: _ip,
  source: IpQualitySource.ipLocate,
  type: IpType.residential,
  organization: 'Example Broadband',
  asn: 64500,
);

class _MockCore extends Mock implements CoreHandlerInterface {}

class _RecordingSetupAction extends SetupAction {
  final requests = <bool>[];

  @override
  Future<bool> setRunning(bool running, {bool initialize = false}) {
    requests.add(running);
    ref.read(runTimeProvider.notifier).value = running ? 1 : null;
    return Future.value(true);
  }
}

class _Ips extends OutboundIpProbe {
  @override
  RoutedProbeState<String, IpInfo> build() => const RoutedProbeState({
    routedOutbound: ProbeEntry(
      phase: ProbePhase.fresh,
      value: IpInfo(ip: _ip, countryCode: 'GB'),
    ),
  });

  @override
  void watch(String target) {}

  @override
  void unwatch(String target) {}
}

OutboundIpResult _address({int coreEpoch = 1}) => OutboundIpResult(
  url: 'https://www.cloudflare.com/cdn-cgi/trace',
  body: 'ip=$_ip\nloc=GB\n',
  coreEpoch: coreEpoch,
  routeVersion: 1,
);

Widget _card({DashboardDensity density = DashboardDensity.standard}) =>
    Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: density.isDesktop ? 600 : 380,
          height: density.isDesktop ? 208 : null,
          child: DashboardDensityScope(
            density: density,
            scale: 1,
            child: const CurrentOutboundCard(),
          ),
        ),
      ),
    );

Widget _app(
  Future<IpQuality> Function(Ref ref, String ip) quality, {
  DashboardDensity density = DashboardDensity.standard,
}) {
  return TestApp(
    locale: const Locale('en'),
    overrides: [
      profilesProvider.overrideWithValue(const [_profile]),
      suspendProvider.overrideWithValue(false),
      outboundIpProbeProvider.overrideWithBuild(
        (_, _) => const RoutedProbeState({
          routedOutbound: ProbeEntry(
            phase: ProbePhase.fresh,
            value: IpInfo(ip: _ip, countryCode: 'GB'),
          ),
        }),
      ),
      ipQualityProvider.overrideWith(quality),
    ],
    child: _card(density: density),
  );
}

Widget _probingApp(
  CoreHandlerInterface core, {
  Future<IpQuality> Function(Ref ref, String ip)? quality,
}) {
  return TestApp(
    locale: const Locale('en'),
    overrides: [
      profilesProvider.overrideWithValue(const [_profile]),
      routeTrackerProvider.overrideWithBuild(
        (ref, _) => RouteState(
          coreEpoch: 1,
          routeVersion: 1,
          hostEpoch: 1,
          proxied: ref.watch(isStartProvider),
          synced: true,
          live: true,
        ),
      ),
      coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ipQualityProvider.overrideWith(quality ?? (_, _) async => _residential),
    ],
    child: _card(),
  );
}

void _useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Finder _clover() => find.ancestor(
  of: find.byType(ShapeBadge),
  matching: find.byWidgetPredicate(
    (widget) => widget is InkResponse && widget.runtimeType == InkResponse,
  ),
);

double _cloverTurn(WidgetTester tester) => tester
    .widget<ShapeBadge>(
      find.descendant(of: _clover(), matching: find.byType(ShapeBadge)),
    )
    .rotation;

DashboardChip _chip(WidgetTester tester, String label) =>
    tester.widget<DashboardChip>(
      find.ancestor(of: find.text(label), matching: find.byType(DashboardChip)),
    );

void main() {
  setUpAll(() => registerFallbackValue(const OutboundIpParams(timeout: 0)));

  group('the exit address', () {
    testWidgets('shows with its country, type, quality and organization', (
      tester,
    ) async {
      await tester.pumpWidget(_app((_, _) async => _residential));
      await tester.pump();

      expect(find.text(_ip), findsOneWidget);
      expect(find.text('GB'), findsOneWidget);
      expect(find.text('Residential'), findsOneWidget);
      expect(_chip(tester, 'Quality Good').tone, DashboardChipTone.ok);
      expect(find.text('Example Broadband'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.refresh), findsNothing);
    });

    testWidgets('a little wider than its card shrinks to fit', (tester) async {
      await tester.pumpWidget(_app((_, _) async => _residential));
      await tester.pump();

      expect(tester.widget<Text>(find.text(_ip)).overflow, isNull);
      expect(
        find.ancestor(of: find.text(_ip), matching: find.byType(FittedBox)),
        findsOneWidget,
      );
    });

    testWidgets('a risky one shows its quality in the warning tone', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app((_, _) async => _residential.copyWith(isTor: true)),
      );
      await tester.pump();

      expect(_chip(tester, 'Quality Risky').tone, DashboardChipTone.warn);
    });

    testWidgets('says its type is unknown when no type was found', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app((_, _) async => throw const IpQualityLookupException([])),
      );
      await tester.pump();

      expect(find.text('GB'), findsOneWidget);
      expect(find.text('Not running'), findsOneWidget);
      expect(_chip(tester, 'Unknown type').tone, DashboardChipTone.idle);
      expect(find.byType(DashboardChip), findsNWidgets(2));
      expect(find.text('Example Broadband'), findsNothing);
    });

    testWidgets('holds the place of its quality while it loads', (
      tester,
    ) async {
      final quality = Completer<IpQuality>();
      await tester.pumpWidget(
        TestApp(
          locale: const Locale('en'),
          overrides: [
            profilesProvider.overrideWithValue(const [_profile]),
            suspendProvider.overrideWithValue(false),
            outboundIpProbeProvider.overrideWith(_Ips.new),
            ipQualityProvider.overrideWith((_, _) => quality.future),
          ],
          child: _card(),
        ),
      );
      await tester.pump();

      expect(find.byType(SkeletonPill), findsNWidgets(3));
      expect(find.byType(SkeletonText), findsOneWidget);
      expect(tester.widget<InkResponse>(_clover()).onTap, isNull);
      final turn = _cloverTurn(tester);
      await tester.pump(const Duration(milliseconds: 300));
      expect(_cloverTurn(tester), isNot(turn));

      quality.complete(_residential);
      await tester.pumpAndSettle();

      expect(find.byType(SkeletonPill), findsNothing);
      expect(find.text('Residential'), findsOneWidget);
      expect(_cloverTurn(tester) % (math.pi / 2), closeTo(0, 1e-9));
      expect(tester.widget<InkResponse>(_clover()).onTap, isNotNull);
    });

    testWidgets('checks a failed quality again from its clover', (
      tester,
    ) async {
      final core = _MockCore();
      when(() => core.outboundIp(any())).thenAnswer((_) async => _address());
      var calls = 0;
      await tester.pumpWidget(
        _probingApp(
          core,
          quality: (_, _) async {
            calls++;
            throw const IpQualityLookupException([]);
          },
        ),
      );
      await tester.pump();
      await tester.pump(commonDuration);
      expect(find.text('Unknown type'), findsOneWidget);

      await tester.tap(find.byTooltip('Retry'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      verify(() => core.outboundIp(any())).called(2);
    });

    testWidgets('names its network by ASN when the organization is unknown', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app((_, _) async => _residential.copyWith(organization: null)),
      );
      await tester.pump();

      expect(find.text('AS64500'), findsOneWidget);
    });

    testWidgets('fits a phone', (tester) async {
      await tester.pumpWidget(
        _app((_, _) async => _residential, density: DashboardDensity.mobile),
      );
      await tester.pump();

      expect(find.text(_ip), findsOneWidget);
      expect(find.text('Residential'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('opens its details from the address, not the card', (
      tester,
    ) async {
      _useTallView(tester);
      await tester.pumpWidget(_app((_, _) async => _residential));
      await tester.pump();

      await tester.tap(find.text('Example Broadband'));
      await tester.pumpAndSettle();
      expect(find.text('iplocate.io'), findsNothing);

      await tester.tap(find.text(_ip));
      await tester.pumpAndSettle();

      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Residential'), findsNWidgets(2));
      final organization = tester.widget<RichText>(
        find.descendant(
          of: find.text('Example Broadband').last,
          matching: find.byType(RichText),
        ),
      );
      expect(organization.textAlign, TextAlign.end);
      expect(find.text('AS64500'), findsOneWidget);
      expect(find.text('iplocate.io'), findsOneWidget);
    });

    testWidgets('lists every source when none found a type and checks again', (
      tester,
    ) async {
      _useTallView(tester);
      var calls = 0;
      await tester.pumpWidget(
        _app((_, _) async {
          calls++;
          throw const IpQualityLookupException([
            (
              source: IpQualitySource.identMe,
              status: IpQualitySourceStatus.ipMismatch,
            ),
            (
              source: IpQualitySource.ipLocate,
              status: IpQualitySourceStatus.rateLimited,
            ),
          ]);
        }),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Outbound IP details'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't determine the IP type"), findsOneWidget);
      expect(find.text('Different outbound IP'), findsOneWidget);
      expect(find.text('Rate limited'), findsOneWidget);

      await tester.tap(find.byTooltip('Check again'));
      await tester.pumpAndSettle();

      expect(calls, 2);
    });

    testWidgets('is masked everywhere once hidden', (tester) async {
      _useTallView(tester);
      await tester.pumpWidget(_app((_, _) async => _residential));
      await tester.pump();

      await tester.tap(find.byTooltip('Outbound IP details'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Hide IP'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide IP'));
      await tester.pumpAndSettle();

      expect(find.text(_ip), findsNothing);
      expect(find.text('*****'), findsNWidgets(2));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CurrentOutboundCard)),
      );
      expect(container.read(appSettingProvider).hideIp, isTrue);
    });

    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(
          tester.element(find.byType(CurrentOutboundCard)),
        );

    void start(WidgetTester tester) {
      containerOf(tester).read(runTimeProvider.notifier).value = 1;
    }

    ProbePhase phaseOf(WidgetTester tester) => containerOf(
      tester,
    ).read(outboundIpProbeProvider).entryOf(routedOutbound).phase;

    testWidgets('that fails as the proxy starts shows as checking', (
      tester,
    ) async {
      final core = _MockCore();
      var epoch = 1;
      when(() => core.outboundIp(any())).thenAnswer((invocation) async {
        final params =
            invocation.positionalArguments.single as OutboundIpParams;
        final failing = params.proxyName != directOutbound && epoch == 1;
        return failing ? null : _address(coreEpoch: epoch);
      });
      await tester.pumpWidget(_probingApp(core));
      await tester.pump();
      await tester.pump(commonDuration);
      expect(find.text(_ip), findsOneWidget);

      start(tester);
      await tester.pump();
      await tester.pump(probeSettleDuration);
      expect(phaseOf(tester), ProbePhase.failed);
      expect(find.text('Check failed'), findsNothing);
      expect(find.byType(SkeletonText), findsNWidgets(2));

      epoch = 2;
      containerOf(tester)
          .read(routeTrackerProvider.notifier)
          .applySnapshot(const RouteSnapshot(coreEpoch: 2, routeVersion: 1));
      await tester.pump(probeSettleDuration);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text(_ip), findsOneWidget);
      expect(find.byType(SkeletonText), findsNothing);
    });

    testWidgets('that fails past the start is shown, then checked again', (
      tester,
    ) async {
      final core = _MockCore();
      final asked = <String>[];
      when(() => core.outboundIp(any())).thenAnswer((invocation) async {
        final params =
            invocation.positionalArguments.single as OutboundIpParams;
        asked.add(params.proxyName);
        return params.proxyName == directOutbound ? _address() : null;
      });
      await tester.pumpWidget(_probingApp(core));
      await tester.pump();
      await tester.pump(commonDuration);

      start(tester);
      await tester.pump();
      await tester.pump(probeSettleDuration);
      await tester.tap(find.byTooltip('Retry'));
      await tester.pump();
      expect(phaseOf(tester), ProbePhase.failed);
      expect(find.text('Check failed'), findsNothing);
      expect(asked, [directOutbound, routedOutbound]);

      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Check failed'), findsOneWidget);
      expect(find.text('Tap the icon to retry'), findsOneWidget);
      await tester.tap(find.byTooltip('Retry'));
      await tester.pump();
      expect(asked, [directOutbound, routedOutbound, routedOutbound]);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Check failed'), findsOneWidget);
      expect(find.byType(SkeletonText), findsNothing);
    });
  });

  group('the start button', () {
    late ProviderContainer container;

    ProviderContainer containerWith({
      List<Profile> profiles = const [_profile],
      bool suspended = false,
    }) => ProviderContainer(
      overrides: [
        initProvider.overrideWithBuild((_, _) => true),
        profilesProvider.overrideWithValue(profiles),
        outboundIpProbeProvider.overrideWith(_Ips.new),
        ipQualityProvider.overrideWith((_, _) async => _residential),
        setupActionProvider.overrideWith(_RecordingSetupAction.new),
        suspendProvider.overrideWithValue(suspended),
      ],
    );

    tearDown(() => container.dispose());

    Future<void> pumpCard(
      WidgetTester tester, {
      DashboardDensity density = DashboardDensity.standard,
      bool glass = false,
    }) async {
      globalState.container = container;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(
            child: LiquidGlassScope(
              enabled: glass,
              child: _card(density: density),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    Finder startButton() => find
        .byWidgetPredicate((widget) => widget.runtimeType == InkResponse)
        .last;

    testWidgets('dispatches each toggle through the shared running state', (
      tester,
    ) async {
      container = containerWith();
      container.read(runTimeProvider.notifier).value = 1;
      await pumpCard(tester);
      final action =
          container.read(setupActionProvider.notifier) as _RecordingSetupAction;

      await tester.tap(startButton());
      expect(action.requests, [false]);
      expect(container.read(isStartProvider), isFalse);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Start'), findsOneWidget);

      await tester.tap(startButton());
      expect(action.requests, [false, true]);
      expect(container.read(isStartProvider), isTrue);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Stop'), findsOneWidget);
    });

    testWidgets('a suspended tunnel swaps in the Wi-Fi off glyph and says so', (
      tester,
    ) async {
      container = containerWith(suspended: true);
      container.read(runTimeProvider.notifier).value = 1;
      await pumpCard(tester);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(CurrentOutboundCard));
      expect(
        find.byTooltip(context.appLocalizations.suspended),
        findsOneWidget,
      );
      expect(find.text(context.appLocalizations.suspended), findsOneWidget);
      expect(find.byGlyph(AppGlyphs.wifiOff), findsOneWidget);
    });

    testWidgets('swells under a press and on glass bends within its shape', (
      tester,
    ) async {
      container = containerWith();
      container.read(runTimeProvider.notifier).value = 1;
      await pumpCard(tester, glass: true);
      await tester.pumpAndSettle();
      final glass = tester.widget<LiquidGlass>(
        find.descendant(of: startButton(), matching: find.byType(LiquidGlass)),
      );
      expect(glass.clipper, isNotNull);

      final press = find.descendant(
        of: startButton(),
        matching: find.byType(ElasticPress),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(startButton()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.renderObject<RenderProxyBox>(press).child!.debugLayer,
        isA<TransformLayer>(),
      );
      await gesture.cancel();
      await tester.pumpAndSettle();
    });

    testWidgets('is off without a profile', (tester) async {
      container = containerWith(profiles: const []);
      await pumpCard(tester, density: DashboardDensity.mobile);

      final toggle = tester.widget<InkResponse>(startButton());
      expect(toggle.onTap, isNull);
      expect(tester.takeException(), isNull);
    });
  });
}

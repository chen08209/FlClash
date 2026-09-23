import 'package:fl_clash/common/color.dart';
import 'package:fl_clash/common/ip_quality.dart';
import 'package:fl_clash/common/service_probe.dart' show routedOutbound;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_quality.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/network_detection.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';

const _ip = '203.0.113.9';

const _residential = IpQuality(
  ip: _ip,
  source: IpQualitySource.ipLocate,
  type: IpType.residential,
  organization: 'Example Broadband',
  asn: 64500,
);

Widget _app(Future<IpQuality> Function(Ref ref, String ip) quality) {
  return TestApp(
    locale: const Locale('en'),
    overrides: [
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
    child: Scaffold(
      body: Center(
        child: SizedBox(
          width: 220,
          child: DashboardWidgetMetrics(
            unitHeight: 84,
            child: const NetworkDetection(),
          ),
        ),
      ),
    ),
  );
}

void _useTallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

final _ipText = find.byWidgetPredicate(
  (widget) => widget is Text && widget.data == _ip,
);

Color? _ipColor(WidgetTester tester) {
  return tester.widget<Text>(_ipText).style?.color;
}

ColorScheme _scheme(WidgetTester tester) {
  return Theme.of(tester.element(_ipText)).colorScheme;
}

void main() {
  testWidgets('shows a good address in the success color', (tester) async {
    await tester.pumpWidget(_app((_, _) async => _residential));
    await tester.pump();

    expect(_ipColor(tester), _scheme(tester).success.opacity80);
    expect(find.byTooltip(_ip), findsOneWidget);
  });

  testWidgets('shows a risky address in the error color', (tester) async {
    await tester.pumpWidget(
      _app((_, _) async => _residential.copyWith(isTor: true)),
    );
    await tester.pump();

    expect(_ipColor(tester), _scheme(tester).error.opacity80);
  });

  testWidgets('keeps the default color when no type was found', (tester) async {
    await tester.pumpWidget(
      _app((_, _) async => throw const IpQualityLookupException([])),
    );
    await tester.pump();

    final scheme = _scheme(tester);
    expect(_ipColor(tester), isNot(anyOf(scheme.success, scheme.error)));
    expect(find.byTooltip(_ip), findsOneWidget);
  });

  testWidgets('shows the address at full opacity while hovered', (
    tester,
  ) async {
    await tester.pumpWidget(_app((_, _) async => _residential));
    await tester.pump();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text(_ip)));
    await tester.pump();

    final success = _scheme(tester).success;
    expect(_ipColor(tester), success);

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();

    expect(_ipColor(tester), success.opacity80);
  });

  testWidgets('opens the details from the address only', (tester) async {
    _useTallView(tester);
    await tester.pumpWidget(_app((_, _) async => _residential));
    await tester.pump();

    await tester.tap(find.text('Network detection'));
    await tester.pumpAndSettle();

    expect(find.text('Outbound IP'), findsNothing);

    await tester.tap(find.text(_ip));
    await tester.pumpAndSettle();

    expect(find.text('Outbound IP'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Residential'), findsOneWidget);
    expect(find.text('Example Broadband'), findsOneWidget);
    final organization = tester.widget<RichText>(
      find.descendant(
        of: find.text('Example Broadband'),
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

    await tester.tap(find.text(_ip));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't determine the IP type"), findsOneWidget);
    expect(find.text('Different outbound IP'), findsOneWidget);
    expect(find.text('Rate limited'), findsOneWidget);

    await tester.tap(find.byTooltip('Check again'));
    await tester.pumpAndSettle();

    expect(calls, 2);
  });

  testWidgets('masks the address everywhere once hidden', (tester) async {
    _useTallView(tester);
    await tester.pumpWidget(_app((_, _) async => _residential));
    await tester.pump();

    await tester.tap(find.text(_ip));
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
    expect(find.byTooltip('*****'), findsNWidgets(2));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NetworkDetection)),
    );
    expect(container.read(appSettingProvider).hideIp, isTrue);
  });
}

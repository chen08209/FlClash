import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/connection/tracker_info_item.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/common_button.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

TrackerInfo _tracker({
  String network = 'tcp',
  String host = 'app.example.com',
  bool mitm = false,
  bool mitmRefused = false,
}) {
  return TrackerInfo(
    id: 'id',
    upload: 0,
    download: 0,
    start: DateTime.utc(2026),
    metadata: Metadata(
      network: network,
      host: host,
      destinationIP: '1.1.1.1',
      destinationPort: '443',
      mitm: mitm,
      mitmRefused: mitmRefused,
    ),
    chains: const ['DIRECT'],
    rule: 'Match',
    rulePayload: '',
  );
}

void main() {
  setUp(() {
    mitmFeature = true;
    addTearDown(() => mitmFeature = false);
  });

  late ProviderContainer container;

  Mitm saved() => container.read(patchClashConfigProvider).mitm;

  Future<void> pumpDetail(
    WidgetTester tester,
    TrackerInfo trackerInfo, {
    Mitm mitm = const Mitm(enable: true),
  }) async {
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(patchClashConfigProvider, (_, _) {});
    container.read(patchClashConfigProvider.notifier).value = PatchClashConfig(
      mitm: mitm,
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: TrackerInfoDetailView(trackerInfo: trackerInfo)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester, String row) async {
    await tester.tap(find.text(row));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(TextButton, currentAppLocalizations.confirm),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no MITM section shows while the feature is off', (tester) async {
    mitmFeature = false;
    await pumpDetail(
      tester,
      _tracker(),
      mitm: const Mitm(enable: true, hostname: ['other.example.com']),
    );

    expect(find.text(currentAppLocalizations.mitmDecryptHost), findsNothing);
  });

  testWidgets('a host not yet listed is added ahead of the list', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _tracker(),
      mitm: const Mitm(enable: true, hostname: ['other.example.com']),
    );

    await confirm(tester, currentAppLocalizations.mitmDecryptHost);

    expect(saved().hostname, ['app.example.com', 'other.example.com']);
    expect(find.text(currentAppLocalizations.mitmExcludeHost), findsOneWidget);
  });

  testWidgets('a refused host says so and is excluded ahead of the list', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      _tracker(mitmRefused: true),
      mitm: const Mitm(enable: true, hostname: ['*.example.com']),
    );

    expect(
      find.text(currentAppLocalizations.mitmClientRefusedCertificate),
      findsOneWidget,
    );
    await confirm(tester, currentAppLocalizations.mitmExcludeHost);

    expect(saved().hostname, ['-app.example.com', '*.example.com']);
  });

  testWidgets('an excluded host can be decrypted again', (tester) async {
    await pumpDetail(
      tester,
      _tracker(mitm: true),
      mitm: const Mitm(enable: true, hostname: ['-app.example.com']),
    );

    await confirm(tester, currentAppLocalizations.mitmDecryptHost);

    expect(saved().hostname, ['app.example.com']);
  });

  testWidgets('nothing is offered without MITM, a host, or TCP', (
    tester,
  ) async {
    for (final (tracker, mitm) in [
      (_tracker(), const Mitm()),
      (_tracker(host: ''), const Mitm(enable: true)),
      (_tracker(network: 'udp'), const Mitm(enable: true)),
    ]) {
      await pumpDetail(tester, tracker, mitm: mitm);
      expect(find.text(currentAppLocalizations.mitmDecryptHost), findsNothing);
      expect(find.text(currentAppLocalizations.mitmExcludeHost), findsNothing);
    }
  });
}

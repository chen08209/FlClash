import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/connection/tracker_info_detail.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  testWidgets('a sheet dragged to another height at the same width lays the '
      'connection info out again without building it again', (tester) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    final height = ValueNotifier(900.0);
    addTearDown(height.dispose);
    final trackerInfo = TrackerInfo(
      id: 'id',
      start: DateTime.utc(2026),
      metadata: const Metadata(
        network: 'tcp',
        host: 'app.example.com',
        destinationIP: '1.1.1.1',
        destinationPort: '443',
      ),
      chains: const ['DIRECT'],
      rule: 'Match',
      rulePayload: '',
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: ValueListenableBuilder(
            valueListenable: height,
            builder: (_, value, detail) => Align(
              alignment: Alignment.topCenter,
              child: SizedBox(height: value, child: detail),
            ),
            child: TrackerInfoDetailView(trackerInfo: trackerInfo),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.connectionInfo));
    await tester.pumpAndSettle();
    var built = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is ListView) {
        built++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);

    for (final value in [800.0, 700.0, 600.0]) {
      height.value = value;
      await tester.pump();
    }
    debugOnRebuildDirtyWidget = null;

    expect(built, 0);
    expect(find.text('1.1.1.1:443'), findsWidgets);
  });

  testWidgets('a node on the path sets its delay in figures of one width', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(TestProfiles.new),
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
    );
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: TrackerPathSection(
            trackerInfo: TrackerInfo(
              id: 'id',
              start: DateTime.utc(2026),
              metadata: const Metadata(network: 'tcp', host: 'example.com'),
              chains: const ['Tokyo 01', 'Auto'],
              rule: 'Match',
              rulePayload: '',
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('38 ms')).style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}

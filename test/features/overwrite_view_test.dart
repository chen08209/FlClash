import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/overwrite.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _TestProfileCustomRules extends ProfileCustomRules {
  final List<Rule> initial;

  _TestProfileCustomRules(this.initial);

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _TestProxyGroups extends ProxyGroups {
  final List<ProxyGroup> initial;

  _TestProxyGroups(this.initial);

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);

  @override
  void order(int oldIndex, int newIndex) {}
}

class _RecordingSetupAction extends SetupAction {
  int autoApplyCalls = 0;

  @override
  void autoApplyProfile() {
    autoApplyCalls++;
  }
}

void main() {
  testWidgets(
    'unmounting OverwriteView applies the profile without using ref',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profile = Profile.normal().copyWith(
        overwriteType: OverwriteType.custom,
      );
      final container = ProviderContainer(
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestProfileCustomRules([]),
          ),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups([])),
          clashConfigProvider(profile.id).overrideWithValue(
            const AsyncData(
              ClashConfig(
                proxies: [Proxy(name: 'DIRECT', type: 'Direct')],
                proxyProviders: ['provider'],
              ),
            ),
          ),
          customOverwriteDateProvider(profile.id).overrideWithValue(
            const CustomOverwriteDate(ruleTargets: {'DIRECT'}),
          ),
          setupActionProvider.overrideWith(_RecordingSetupAction.new),
        ],
      );
      addTearDown(container.dispose);
      globalState.container = container;
      container
          .read(viewSizeProvider.notifier)
          .update((_) => const Size(1400, 1000));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TestApp(child: OverwriteView(profileId: profile.id)),
        ),
      );
      await tester.pump();
      expect(find.byType(OverwriteView), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        (container.read(setupActionProvider.notifier) as _RecordingSetupAction)
            .autoApplyCalls,
        1,
      );
    },
  );
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  Future<void> pumpView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            const Profile(
              id: _profileId,
              type: ProfileType.custom,
              autoUpdateDuration: Duration.zero,
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: TunView(_profileId)),
      ),
    );
    await tester.pump();
  }

  ProfileOverrides config() =>
      container.read(profilesProvider).getProfile(_profileId)!.overrides;

  testWidgets('offers the TUN keys and lists a picked one at its default', (
    tester,
  ) async {
    await pumpView(tester);
    final l = currentAppLocalizations;
    expect(find.text(l.nullTip(l.settingEntries)), findsOneWidget);

    await tester.tap(find.text(l.addSettingEntry));
    await tester.pumpAndSettle();
    expect(find.text(l.excludeInterface), findsOneWidget);
    await tester.tap(find.text(l.disableIcmpForwarding));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    expect(config().tunOverrideKeys, {TunOverrideKey.disableIcmpForwarding});
    expect(config().tun, defaultProfileTun);
    expect(find.text(l.disableIcmpForwardingDesc), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(config().tun.disableIcmpForwarding, isTrue);
  });

  testWidgets('offers no quick edit for a part of the TUN section', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.byTooltip(currentAppLocalizations.quickEdit), findsNothing);
  });
}

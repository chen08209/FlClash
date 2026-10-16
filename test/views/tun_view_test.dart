import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/tun.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

const _profileId = 1;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  Future<void> pumpWidget(WidgetTester tester, Widget child) async {
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
        child: TestApp(child: child),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpView(
    WidgetTester tester, {
    bool isLinux = true,
    bool isWindows = false,
  }) => pumpWidget(
    tester,
    TunView(_profileId, isLinux: isLinux, isWindows: isWindows),
  );

  ProfileOverrides overrides() =>
      container.read(profilesProvider).getProfile(_profileId)!.overrides;

  void setKeys(Set<TunOverrideKey> keys) {
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          _profileId,
          (profile) => profile.copyWith.overrides(tunOverrideKeys: keys),
        );
  }

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

    expect(overrides().tunOverrideKeys, {TunOverrideKey.disableIcmpForwarding});
    expect(overrides().tun, defaultProfileTun);
    expect(find.text(l.disableIcmpForwardingDesc), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(overrides().tun.disableIcmpForwarding, isTrue);
  });

  testWidgets('offers no quick edit for a part of the TUN section', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.byTooltip(currentAppLocalizations.quickEdit), findsNothing);
  });

  testWidgets('offers the keys only Linux routing reads on Linux alone', (
    tester,
  ) async {
    await pumpView(tester, isLinux: false);
    final l = currentAppLocalizations;

    await tester.tap(find.text(l.addSettingEntry));
    await tester.pumpAndSettle();

    expect(find.text('MTU'), findsOneWidget);
    expect(find.text(l.dnsHijacking), findsOneWidget);
    expect(find.text(l.udpTimeout), findsOneWidget);
    expect(find.text(l.strictRoute), findsNothing);
    expect(find.text('GSO'), findsNothing);
    expect(find.text(l.excludeInterface), findsNothing);
    expect(find.text(l.includeUid), findsNothing);
    expect(find.text(l.excludeDstPort), findsNothing);
  });

  testWidgets('offers strict route where sing-tun enforces it', (tester) async {
    await pumpView(tester, isLinux: false, isWindows: true);
    final l = currentAppLocalizations;

    await tester.tap(find.text(l.addSettingEntry));
    await tester.pumpAndSettle();

    expect(find.text(l.strictRoute), findsOneWidget);
    expect(find.text(l.excludeInterface), findsNothing);
  });

  testWidgets('a custom profile says its keys win over the app-wide ones', (
    tester,
  ) async {
    await pumpView(tester);

    expect(
      find.text(currentAppLocalizations.profileTunSettingsDesc),
      findsOneWidget,
    );
  });

  testWidgets('a port list takes whole ports and writes them as numbers', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({TunOverrideKey.excludeDstPort});
    await tester.pump();
    final l = currentAppLocalizations;
    final ports = find.ancestor(
      of: find.text(l.excludeDstPort),
      matching: find.byType(ConfigListEditItem),
    );
    final item = tester.widget<ConfigListEditItem>(ports);

    expect(item.itemValidator!('443', l), isNull);
    expect(item.itemValidator!('70000', l), isNotNull);
    expect(item.itemValidator!('https', l), isNotNull);

    item.onChanged(tester.element(ports) as WidgetRef, const ['443', ' 8443']);
    await tester.pump();
    expect(overrides().tun.excludeDstPort, [443, 8443]);
    expect(overrides().tun.overrideJson(overrides().tunOverrideKeys), {
      'exclude-dst-port': [443, 8443],
    });
  });
}

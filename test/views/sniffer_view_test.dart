import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/sniffer.dart';
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
        child: TestApp(child: SnifferView(_profileId)),
      ),
    );
    await tester.pump();
  }

  ProfileOverrides config() =>
      container.read(profilesProvider).getProfile(_profileId)!.overrides;

  void setKeys(Set<SnifferOverrideKey> keys) {
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          _profileId,
          (profile) => profile.copyWith.overrides(snifferOverrideKeys: keys),
        );
  }

  String emptyLabel() =>
      currentAppLocalizations.nullTip(currentAppLocalizations.settingEntries);

  testWidgets('a fresh profile lists no entry', (tester) async {
    await pumpView(tester);

    expect(config().snifferOverrideKeys, isEmpty);
    expect(find.text(emptyLabel()), findsOneWidget);
  });

  testWidgets('a protocol picked from the sheet leaves its ports to mihomo', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text(currentAppLocalizations.addSettingEntry));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.sniffProtocols), findsOneWidget);

    await tester.tap(find.text('QUIC'));
    await tester.pumpAndSettle();

    expect(config().snifferOverrideKeys, {SnifferOverrideKey.sniffQuic});
    expect(
      config().sniffer.sniffOf(SnifferOverrideKey.sniffQuic),
      const SnifferConfig(),
    );
    expect(find.text(emptyLabel()), findsNothing);
    expect(find.text(currentAppLocalizations.defaultText), findsOneWidget);
  });

  testWidgets('a toggle entry writes its value and can be removed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({SnifferOverrideKey.enable});
    await tester.pump();

    expect(find.text(currentAppLocalizations.status), findsOneWidget);
    await tester.tap(find.byType(Switch).last);
    await tester.pump();
    expect(config().sniffer.enable, isTrue);

    await tester.tap(find.byTooltip(currentAppLocalizations.remove));
    await tester.pumpAndSettle();
    expect(config().snifferOverrideKeys, isEmpty);
    expect(find.text(emptyLabel()), findsOneWidget);
  });

  testWidgets('a protocol page sets its own override destination', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({SnifferOverrideKey.sniffTls});
    await tester.pump();

    await tester.tap(find.text('TLS'));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.ports), findsOneWidget);
    expect(find.text(currentAppLocalizations.defaultText), findsNWidgets(2));

    await tester.tap(find.text(currentAppLocalizations.overrideDestination));
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.disabled));
    await tester.pumpAndSettle();

    expect(
      config().sniffer.sniffOf(SnifferOverrideKey.sniffTls),
      const SnifferConfig(overrideDest: false),
    );
    expect(find.text(currentAppLocalizations.disabled), findsOneWidget);
  });

  testWidgets('quick edit opens the override document and applies it on exit', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({SnifferOverrideKey.parsePureIp});
    await tester.pump();

    await tester.tap(find.byTooltip(currentAppLocalizations.quickEdit));
    await tester.pumpAndSettle();
    final editor = tester.widget<EditorPage>(find.byType(EditorPage));
    expect(editor.content, contains('parse-pure-ip: true'));
    expect(editor.schema, EditorSchema.sniffer);

    final context = tester.element(find.byType(EditorPage));
    final popped = await editor.onPop!(
      context,
      currentAppLocalizations.sniffer,
      'sniff:\n  http:\n    ports: [80]\n',
    );
    expect(popped, isTrue);
    expect(config().snifferOverrideKeys, {SnifferOverrideKey.sniffHttp});
    expect(
      config().sniffer.sniffOf(SnifferOverrideKey.sniffHttp),
      const SnifferConfig(ports: ['80']),
    );
  });
}

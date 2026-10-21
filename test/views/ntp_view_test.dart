import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/ntp.dart';
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

  Future<void> pumpView(
    WidgetTester tester, {
    CustomProfileIssues issues = const CustomProfileIssues(),
  }) async {
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
        customProfileIssuesProvider(_profileId).overrideWithValue(issues),
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
        child: TestApp(child: NtpView(_profileId)),
      ),
    );
    await tester.pump();
  }

  ProfileOverrides config() =>
      container.read(profilesProvider).getProfile(_profileId)!.overrides;

  void setKeys(Set<NtpOverrideKey> keys) {
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          _profileId,
          (profile) => profile.copyWith.overrides(ntpOverrideKeys: keys),
        );
  }

  String emptyLabel() =>
      currentAppLocalizations.nullTip(currentAppLocalizations.settingEntries);

  Future<void> openAddSheet(WidgetTester tester) async {
    await tester.tap(find.text(currentAppLocalizations.addSettingEntry));
    await tester.pumpAndSettle();
  }

  Future<void> addKey(WidgetTester tester, String label) async {
    await openAddSheet(tester);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh profile lists no entry', (tester) async {
    await pumpView(tester);

    expect(config().ntpOverrideKeys, isEmpty);
    expect(find.text(emptyLabel()), findsOneWidget);
  });

  testWidgets('flags a dialer the profile does not have above its entries', (
    tester,
  ) async {
    await pumpView(
      tester,
      issues: const CustomProfileIssues(
        ntp: [CustomIssue.missingDialer('Gone')],
      ),
    );

    setKeys({NtpOverrideKey.dialerProxy});
    await tester.pumpAndSettle();

    expect(
      find.text(currentAppLocalizations.customIssueMissingDialer('Gone')),
      findsOneWidget,
    );
  });

  testWidgets('lists a key picked from the sheet at its default', (
    tester,
  ) async {
    await pumpView(tester);

    await openAddSheet(tester);
    expect(
      find.descendant(
        of: find.byType(SelectionSheet<NtpOverrideKey>),
        matching: find.text(currentAppLocalizations.addSettingEntry),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(currentAppLocalizations.server));
    await tester.pumpAndSettle();

    expect(config().ntpOverrideKeys, {NtpOverrideKey.server});
    expect(config().ntp.server, defaultNtp.server);
    expect(find.text(emptyLabel()), findsNothing);
    expect(find.text(currentAppLocalizations.server), findsOneWidget);
  });

  testWidgets('a toggle key is added at its default without asking', (
    tester,
  ) async {
    await pumpView(tester);

    await addKey(tester, currentAppLocalizations.writeToSystem);

    expect(find.byType(CommonDialog), findsNothing);
    expect(config().ntpOverrideKeys, {NtpOverrideKey.writeToSystem});
    expect(config().ntp.writeToSystem, defaultNtp.writeToSystem);
  });

  testWidgets('a number key is added at its default without asking', (
    tester,
  ) async {
    await pumpView(tester);

    await addKey(tester, currentAppLocalizations.port);

    expect(find.byType(TextField), findsNothing);
    expect(config().ntpOverrideKeys, {NtpOverrideKey.port});
    expect(config().ntp.port, defaultNtp.port);
    expect(find.text('${defaultNtp.port}'), findsOneWidget);
  });

  testWidgets('an entry with nothing to show takes a single line', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.server, NtpOverrideKey.dialerProxy});
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          _profileId,
          (profile) => profile.copyWith.overrides(
            ntp: const Ntp(server: 'ntp.aliyun.com'),
          ),
        );
    await tester.pump();

    double heightOf(String title) => tester
        .getSize(
          find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
        )
        .height;
    expect(config().ntp.dialerProxy, isEmpty);
    expect(
      heightOf(currentAppLocalizations.dialerProxy),
      lessThan(heightOf(currentAppLocalizations.server)),
    );
  });

  testWidgets('a toggle entry writes its value and can be removed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.enable});
    await tester.pump();

    expect(find.text(currentAppLocalizations.status), findsOneWidget);
    await tester.tap(find.byType(CommonSwitch).last);
    await tester.pump();
    expect(config().ntp.enable, isTrue);

    await tester.tap(find.byTooltip(currentAppLocalizations.remove));
    await tester.pumpAndSettle();
    expect(config().ntpOverrideKeys, isEmpty);
    expect(find.text(emptyLabel()), findsOneWidget);
  });

  testWidgets('the add sheet stays open while keys are picked from it', (
    tester,
  ) async {
    final l = currentAppLocalizations;
    await pumpView(tester);
    await openAddSheet(tester);
    final sheet = find.byType(SelectionSheet<NtpOverrideKey>);
    Finder offered(String label) =>
        find.descendant(of: sheet, matching: find.text(label));

    await tester.tap(offered(l.server));
    await tester.pumpAndSettle();
    await tester.tap(offered(l.writeToSystem));
    await tester.pumpAndSettle();

    expect(sheet, findsOneWidget);
    expect(offered(l.server), findsNothing);
    expect(config().ntpOverrideKeys, {
      NtpOverrideKey.server,
      NtpOverrideKey.writeToSystem,
    });
  });

  testWidgets('a removed entry collapses out after its key is dropped', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.enable, NtpOverrideKey.server});
    await tester.pump();
    final status = find.text(currentAppLocalizations.status);

    await tester.tap(
      find.descendant(
        of: find.ancestor(of: status, matching: find.byType(ListTile)),
        matching: find.byTooltip(currentAppLocalizations.remove),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(config().ntpOverrideKeys, {NtpOverrideKey.server});
    expect(status, findsOneWidget);

    await tester.pumpAndSettle();
    expect(status, findsNothing);
  });

  testWidgets('a number entry writes the integer it is given', (tester) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.interval});
    await tester.pump();

    await tester.tap(find.text(currentAppLocalizations.ntpInterval));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '120');
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(config().ntp.interval, 120);
    expect(find.text('120'), findsOneWidget);
  });

  testWidgets('an entry emptied after holding a value is taken off', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({
      NtpOverrideKey.server,
      NtpOverrideKey.interval,
      NtpOverrideKey.dialerProxy,
    });
    await tester.pump();
    final l = currentAppLocalizations;
    Future<void> submit(String title, [String? text]) async {
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      if (text != null) {
        await tester.enterText(find.byType(TextField), text);
      }
      await tester.tap(find.text(l.submit));
      await tester.pumpAndSettle();
    }

    await submit(l.dialerProxy);
    expect(config().ntpOverrideKeys, hasLength(3));

    await submit(l.server, 'pool.ntp.org');
    await submit(l.server, '');
    await submit(l.ntpInterval, ' ');
    expect(config().ntpOverrideKeys, {NtpOverrideKey.dialerProxy});
    expect(config().ntp, defaultNtp);
    expect(find.text(l.server), findsNothing);
    expect(find.text(l.ntpInterval), findsNothing);
  });

  testWidgets('the add button disables while every key is listed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys(NtpOverrideKey.values.toSet());
    await tester.pump();

    final add = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip(currentAppLocalizations.addSettingEntry),
        matching: find.byType(IconButton),
      ),
    );
    expect(add.onPressed, isNull);
  });

  Future<EditorPage> openQuickEdit(WidgetTester tester) async {
    await tester.tap(find.byTooltip(currentAppLocalizations.quickEdit));
    await tester.pumpAndSettle();
    return tester.widget<EditorPage>(find.byType(EditorPage));
  }

  testWidgets('quick edit opens the override document and applies it on exit', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.enable});
    await tester.pump();

    final editor = await openQuickEdit(tester);
    expect(editor.content, contains('enable: false'));
    expect(editor.readOnly, isFalse);

    final context = tester.element(find.byType(EditorPage));
    final popped = await editor.onPop!(
      context,
      'NTP',
      const EditorContent.text('port: 1230'),
    );
    expect(popped, isTrue);
    expect(config().ntpOverrideKeys, {NtpOverrideKey.port});
    expect(config().ntp.port, 1230);
  });

  testWidgets('quick edit takes off and resets a key it empties or drops', (
    tester,
  ) async {
    await pumpView(tester);
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          _profileId,
          (profile) => profile.copyWith.overrides(
            ntp: defaultNtp.copyWith(port: 1230),
            ntpOverrideKeys: {
              NtpOverrideKey.enable,
              NtpOverrideKey.server,
              NtpOverrideKey.port,
            },
          ),
        );
    await tester.pump();

    final editor = await openQuickEdit(tester);
    final context = tester.element(find.byType(EditorPage));
    expect(
      await editor.onPop!(
        context,
        'NTP',
        const EditorContent.text("enable: true\nserver: ''\n"),
      ),
      isTrue,
    );
    expect(config().ntpOverrideKeys, {NtpOverrideKey.enable});
    expect(config().ntp, defaultNtp.copyWith(enable: true));
  });

  testWidgets('quick edit keeps a key added without a value', (tester) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.enable, NtpOverrideKey.dialerProxy});
    await tester.pump();

    final editor = await openQuickEdit(tester);
    expect(editor.content, isNot(contains('dialer-proxy')));

    final context = tester.element(find.byType(EditorPage));
    expect(
      await editor.onPop!(
        context,
        'NTP',
        const EditorContent.text('enable: true'),
      ),
      isTrue,
    );
    expect(config().ntpOverrideKeys, {
      NtpOverrideKey.enable,
      NtpOverrideKey.dialerProxy,
    });
    expect(config().ntp.enable, isTrue);
  });

  testWidgets('a rejected quick edit can only be discarded or kept open', (
    tester,
  ) async {
    await pumpView(tester);
    final editor = await openQuickEdit(tester);
    final context = tester.element(find.byType(EditorPage));

    final popped = editor.onPop!(
      context,
      'NTP',
      const EditorContent.text('bogus: 1'),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining(currentAppLocalizations.discardChanges),
      findsOneWidget,
    );
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pump();
    expect(await popped, isFalse);
    expect(config().ntpOverrideKeys, isEmpty);
  });
}

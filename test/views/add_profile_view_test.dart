import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingProfilesAction extends ProfilesAction {
  final batches = <List<String>>[];
  final singles = <String>[];
  final ageSecretKeys = <String>[];

  @override
  Future<void> addProfileFromLink(
    String link, {
    String? label,
    String ageSecretKey = '',
  }) async {
    singles.add(link);
    ageSecretKeys.add(ageSecretKey);
  }

  @override
  Future<void> addProfilesFromLinks(List<String> links) async =>
      batches.add(links);
}

ProviderContainer _containerFor(
  WidgetTester tester, {
  ProfilesAction? profilesAction,
  List<Profile> profiles = const [],
}) {
  const size = Size(1400, 1000);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles(profiles)),
      if (profilesAction != null)
        profilesActionProvider.overrideWith(() => profilesAction),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  return container;
}

void main() {
  testWidgets('lists the QR code, file, link, and custom entries', (
    tester,
  ) async {
    final container = _containerFor(tester);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) =>
                  AddProfileView(context: context, origin: context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    expect(find.text(l10n.qrcode), findsOne);
    expect(find.text(l10n.file), findsOne);
    expect(find.text(l10n.link), findsOne);
    expect(find.text(l10n.customProfile), findsOne);
    expect(tester.takeException(), null);
  });

  testWidgets('a batch link import skips existing profiles and adds the rest', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(
      tester,
      profilesAction: action,
      profiles: [Profile.normal(url: 'https://example.com/old')],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) =>
                  AddProfileView(context: context, origin: context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.batchImport));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'https://example.com/a\nhttps://example.com/old\nhttps://example.com/b',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.batches, [
      ['https://example.com/a', 'https://example.com/b'],
    ]);
    expect(tester.takeException(), null);
  });

  testWidgets('the link import takes a proxy share link', (tester) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) =>
                  AddProfileView(context: context, origin: context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.link),
      'trojan://pass@example.com:443#HK',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.singles, ['trojan://pass@example.com:443#HK']);
    expect(tester.takeException(), null);
  });

  testWidgets('the link import passes the age secret key along', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) =>
                  AddProfileView(context: context, origin: context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.link),
      'https://example.com/sub',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.ageSecretKey),
      ' AGE-SECRET-KEY-1A ',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(action.singles, ['https://example.com/sub']);
    expect(action.ageSecretKeys, ['AGE-SECRET-KEY-1A']);
    expect(tester.takeException(), null);
  });

  testWidgets('the link import rejects what is neither kind of link', (
    tester,
  ) async {
    final action = _RecordingProfilesAction();
    final container = _containerFor(tester, profilesAction: action);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) =>
                  AddProfileView(context: context, origin: context),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = currentAppLocalizations;
    await tester.tap(find.text(l10n.link));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, l10n.link),
      'wireguard://key@example.com:51820',
    );
    await tester.pump();
    await tester.tap(find.text(l10n.submit));
    await tester.pumpAndSettle();

    expect(find.text(l10n.invalidLinkTip), findsOne);
    expect(action.singles, isEmpty);
    expect(tester.takeException(), null);
  });
}

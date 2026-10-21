import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../helpers/app_paths.dart';
import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

/// The edit page disposes the profile by scheduling an auto-apply; keep that a
/// no-op so the setup machinery never runs in a widget test.
class _NoopSetupAction extends SetupAction {
  @override
  void autoApplyProfile() {}
}

Profile _urlProfile() =>
    Profile.normal(label: 'test', url: 'https://example.com/sub');

/// Pumps [EditProfileView] inside a page route (as `showExtend` does), with an
/// outside focus node so escape behavior can be asserted.
Future<FocusNode> pumpEditProfile(
  WidgetTester tester, {
  Profile? profile,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(900, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      setupActionProvider.overrideWith(() => _NoopSetupAction()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  // Unmount the widget tree before the container is disposed so State.dispose
  // (which reads a provider) runs against a live container. Teardowns run LIFO,
  // so this must be registered after `container.dispose`.
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
  });
  globalState.container = container;
  container.read(viewSizeProvider.notifier).value = const Size(900, 800);

  final outsideFocus = FocusNode();
  addTearDown(outsideFocus.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: globalState.navigatorKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          AppUiLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          return wrapAppScopes(context, child!);
        },
        home: Scaffold(
          body: Column(
            children: [
              Focus(focusNode: outsideFocus, child: const SizedBox()),
              Expanded(
                child: Navigator(
                  pages: [
                    MaterialPage(
                      child: Builder(
                        builder: (context) => Scaffold(
                          body: EditProfileView(
                            profile: profile ?? _urlProfile(),
                          ),
                        ),
                      ),
                    ),
                  ],
                  onDidRemovePage: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();

  outsideFocus.requestFocus();
  await tester.pump();
  return outsideFocus;
}

bool _isInAppBar() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<AppBar>() != null;
}

bool _isTextFieldFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<EditableText>() != null;
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('edit_profile_focus_test');
    await useAppPaths(tempDir);
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  testWidgets('tabbing into the edit page reaches the form past its bar', (
    tester,
  ) async {
    final outsideFocus = await pumpEditProfile(tester);
    expect(FocusManager.instance.primaryFocus, outsideFocus);

    for (var i = 0; i < 4 && !_isTextFieldFocused(); i++) {
      if (i > 0) {
        expect(_isInAppBar(), isTrue);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(_isTextFieldFocused(), isTrue);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byTooltip('Save'), findsOneWidget);
  });

  testWidgets(
    'the profile file row shows its size and update time without chips',
    (tester) async {
      await pumpEditProfile(tester);
      final row = find.widgetWithText(
        DecorationListItem,
        currentAppLocalizations.profile,
      );
      for (var i = 0; i < 20 && row.evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(row, findsOneWidget);
      expect(
        find.descendant(of: row, matching: find.byType(LastUpdateTimeText)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: row, matching: find.text(0.traffic.show)),
        findsOneWidget,
      );
      expect(find.byType(MetaChip), findsNothing);
    },
  );

  testWidgets('saving with auto update off ignores an emptied interval', (
    tester,
  ) async {
    final profile = _urlProfile();
    await pumpEditProfile(
      tester,
      profile: profile,
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles([profile])),
      ],
    );
    final interval = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller?.text == '${profile.autoUpdateDuration.inMinutes}',
    );

    await tester.enterText(interval, '');
    await tester.tap(find.byType(CommonSwitch));
    await tester.pump();
    await tester.tap(find.byTooltip('Save'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final saved = globalState.container.read(profilesProvider).single;
    expect(saved.autoUpdate, isFalse);
    expect(saved.autoUpdateDuration, profile.autoUpdateDuration);
  });
}

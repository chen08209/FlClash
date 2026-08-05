import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

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
}) async {
  tester.view.physicalSize = const Size(900, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [setupActionProvider.overrideWith(() => _NoopSetupAction())],
  );
  addTearDown(container.dispose);
  // Unmount the widget tree before the container is disposed so State.dispose
  // (which reads a provider) runs against a live container. Teardowns run LIFO,
  // so this must be registered after `container.dispose`.
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
  });
  globalState.container = container;

  final outsideFocus = FocusNode();
  addTearDown(outsideFocus.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        builder: (context, child) {
          globalState.measure = Measure.of(context, 1);
          globalState.theme = CommonTheme.of(context, 1);
          return child!;
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
                            context: context,
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

bool _isFabFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<FloatingActionButton>() != null;
}

bool _isTextFieldFocused() {
  final context = FocusManager.instance.primaryFocus?.context;
  return context?.findAncestorWidgetOfExactType<EditableText>() != null;
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('edit_profile_focus_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDownAll(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  testWidgets('tabbing into the edit page starts with the form', (
    tester,
  ) async {
    final outsideFocus = await pumpEditProfile(tester);
    expect(FocusManager.instance.primaryFocus, outsideFocus);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(_isTextFieldFocused(), isTrue);
    expect(_isFabFocused(), isFalse);
  });
}

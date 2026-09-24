import 'dart:ui' show Tristate;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/ntp.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  Future<void> pumpView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1000));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: NtpView()),
      ),
    );
    await tester.pump();
  }

  PatchClashConfig config() => container.read(patchClashConfigProvider);

  void setKeys(Set<NtpOverrideKey> keys) {
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(ntpOverrideKeys: keys));
  }

  String emptyLabel() =>
      currentAppLocalizations.nullTip(currentAppLocalizations.overrideEntries);

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip(currentAppLocalizations.more));
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh config lists no entry', (tester) async {
    await pumpView(tester);

    expect(config().ntpOverrideKeys, isEmpty);
    expect(find.text(emptyLabel()), findsOneWidget);
  });

  testWidgets('lists a key picked from the sheet', (tester) async {
    await pumpView(tester);

    await openMenu(tester);
    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.addOverrideEntry), findsOneWidget);

    await tester.tap(find.text(currentAppLocalizations.server));
    await tester.pumpAndSettle();

    expect(config().ntpOverrideKeys, {NtpOverrideKey.server});
    expect(find.text(emptyLabel()), findsNothing);
    expect(find.text(defaultNtp.server), findsOneWidget);
  });

  testWidgets('a toggle entry writes its value and can be removed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({NtpOverrideKey.enable});
    await tester.pump();

    expect(find.text(currentAppLocalizations.status), findsOneWidget);
    await tester.tap(find.byType(Switch).last);
    await tester.pump();
    expect(config().ntp.enable, isTrue);

    await tester.tap(find.byTooltip(currentAppLocalizations.remove));
    await tester.pumpAndSettle();
    expect(config().ntpOverrideKeys, isEmpty);
    expect(find.text(emptyLabel()), findsOneWidget);
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

  testWidgets('the add item disables while every key is listed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys(NtpOverrideKey.values.toSet());
    await tester.pump();

    await openMenu(tester);
    final semantics = tester.getSemantics(
      find.text(currentAppLocalizations.add),
    );
    expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
  });

  testWidgets('the override switch writes the override provider', (
    tester,
  ) async {
    await pumpView(tester);

    expect(container.read(overrideNtpProvider), isFalse);
    await tester.tap(find.text(currentAppLocalizations.overrideNtp));
    await tester.pump();
    expect(container.read(overrideNtpProvider), isTrue);
  });

  Future<EditorPage> openQuickEdit(WidgetTester tester) async {
    await openMenu(tester);
    await tester.tap(find.text(currentAppLocalizations.quickEdit));
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
    final popped = await editor.onPop!(context, 'NTP', 'port: 1230');
    expect(popped, isTrue);
    expect(config().ntpOverrideKeys, {NtpOverrideKey.port});
    expect(config().ntp.port, 1230);
  });

  testWidgets('a rejected quick edit can only be discarded or kept open', (
    tester,
  ) async {
    await pumpView(tester);
    final editor = await openQuickEdit(tester);
    final context = tester.element(find.byType(EditorPage));

    final popped = editor.onPop!(context, 'NTP', 'bogus: 1');
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

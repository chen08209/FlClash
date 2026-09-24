import 'dart:ui' show Tristate;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/dns.dart';
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
        child: const TestApp(child: DnsView()),
      ),
    );
    await tester.pump();
  }

  PatchClashConfig config() => container.read(patchClashConfigProvider);

  void setKeys(Set<DnsOverrideKey> keys) {
    container
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(dnsOverrideKeys: keys));
  }

  String emptyLabel() =>
      currentAppLocalizations.nullTip(currentAppLocalizations.overrideEntries);

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip(currentAppLocalizations.more));
    await tester.pumpAndSettle();
  }

  testWidgets('lists a key picked from the sheet', (tester) async {
    await pumpView(tester);
    setKeys({});
    await tester.pump();
    expect(find.text(emptyLabel()), findsOneWidget);

    await openMenu(tester);
    await tester.tap(find.text(currentAppLocalizations.add));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.addOverrideEntry), findsOneWidget);

    await tester.tap(find.text(currentAppLocalizations.listen));
    await tester.pumpAndSettle();

    expect(config().dnsOverrideKeys, {DnsOverrideKey.listen});
    expect(find.text(emptyLabel()), findsNothing);
    expect(find.text(currentAppLocalizations.listen), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('a toggle entry writes its value and can be removed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({DnsOverrideKey.ipv6});
    await tester.pump();

    expect(find.text('IPv6'), findsOneWidget);
    await tester.tap(find.byType(Switch).last);
    await tester.pump();
    expect(config().dns.ipv6, isTrue);

    await tester.tap(find.byTooltip(currentAppLocalizations.remove));
    await tester.pumpAndSettle();
    expect(config().dnsOverrideKeys, isEmpty);
    expect(find.text('IPv6'), findsNothing);
    expect(find.text(emptyLabel()), findsOneWidget);
  });

  testWidgets('groups fallback filter entries under their own header', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({DnsOverrideKey.fallbackFilterDomain, DnsOverrideKey.enable});
    await tester.pump();

    final l = currentAppLocalizations;
    final status = tester.getTopLeft(find.text(l.status));
    final header = tester.getTopLeft(find.text(l.fallbackFilter));
    final domain = tester.getTopLeft(find.text(l.domain));
    expect(find.text(l.options), findsOneWidget);
    expect(status.dy, lessThan(header.dy));
    expect(header.dy, lessThan(domain.dy));
  });

  testWidgets('a list entry without a description summarises its items', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({
      DnsOverrideKey.fallbackFilterDomain,
      DnsOverrideKey.fallbackFilterGeosite,
    });
    container
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith.dns.fallbackFilter(
            domain: ['+.a.com', '+.b.com'],
            geosite: [],
          ),
        );
    await tester.pump();

    expect(find.text('+.a.com, +.b.com'), findsOneWidget);
    expect(find.text(currentAppLocalizations.none), findsOneWidget);
  });

  testWidgets('a number entry writes the integer it is given', (tester) async {
    await pumpView(tester);
    setKeys({DnsOverrideKey.ipv6Timeout});
    await tester.pump();

    await tester.tap(find.text(currentAppLocalizations.ipv6Timeout));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '300');
    await tester.tap(find.text(currentAppLocalizations.submit));
    await tester.pumpAndSettle();

    expect(config().dns.ipv6Timeout, 300);
    expect(find.text('300'), findsOneWidget);
  });

  testWidgets('the DNS mode options leave out hosts', (tester) async {
    await pumpView(tester);
    setKeys({DnsOverrideKey.enhancedMode});
    await tester.pump();

    await tester.tap(find.text(currentAppLocalizations.dnsMode));
    await tester.pumpAndSettle();

    expect(find.text(DnsMode.redirHost.name), findsOneWidget);
    expect(find.text(DnsMode.hosts.name), findsNothing);
  });

  testWidgets('the add item disables while every key is listed', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys(DnsOverrideKey.values.toSet());
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

    expect(container.read(overrideDnsProvider), isFalse);
    await tester.tap(find.text(currentAppLocalizations.overrideDns));
    await tester.pump();
    expect(container.read(overrideDnsProvider), isTrue);
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
    setKeys({DnsOverrideKey.ipv6});
    await tester.pump();

    final editor = await openQuickEdit(tester);
    expect(editor.content, contains('ipv6: false'));
    expect(editor.readOnly, isFalse);
    expect(editor.onSave, isNull);

    final context = tester.element(find.byType(EditorPage));
    final popped = await editor.onPop!(context, 'DNS', 'listen: :53');
    expect(popped, isTrue);
    expect(config().dnsOverrideKeys, {DnsOverrideKey.listen});
    expect(config().dns.listen, ':53');
  });

  testWidgets('a rejected quick edit can only be discarded or kept open', (
    tester,
  ) async {
    await pumpView(tester);
    setKeys({});
    await tester.pump();
    final editor = await openQuickEdit(tester);
    final context = tester.element(find.byType(EditorPage));

    final popped = editor.onPop!(context, 'DNS', 'bogus: 1');
    await tester.pump();
    expect(
      find.textContaining(currentAppLocalizations.discardChanges),
      findsOneWidget,
    );
    await tester.tap(find.text(currentAppLocalizations.cancel));
    await tester.pump();
    expect(await popped, isFalse);
    expect(config().dnsOverrideKeys, isEmpty);
  });
}

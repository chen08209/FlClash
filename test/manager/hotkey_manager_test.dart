import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/manager/hotkey_manager.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/models/common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rust_api/rust_api.dart';

void main() {
  group('KeyboardModifierExt', () {
    test('maps keyboard modifiers to hotkey modifiers', () {
      expect(KeyboardModifier.alt.toHotKeyModifier(), HotKeyModifier.alt);
      expect(
        KeyboardModifier.capsLock.toHotKeyModifier(),
        HotKeyModifier.capsLock,
      );
      expect(
        KeyboardModifier.control.toHotKeyModifier(),
        HotKeyModifier.control,
      );
      expect(KeyboardModifier.fn.toHotKeyModifier(), HotKeyModifier.fn);
      expect(KeyboardModifier.meta.toHotKeyModifier(), HotKeyModifier.meta);
      expect(KeyboardModifier.shift.toHotKeyModifier(), HotKeyModifier.shift);
    });

    test('covers every keyboard modifier', () {
      for (final modifier in KeyboardModifier.values) {
        expect(modifier.toHotKeyModifier(), isA<HotKeyModifier>());
      }
    });
  });

  group('HotKeyActionExt', () {
    test('builds a spec keyed by the action index and the HID usage', () {
      final spec = HotKeyAction(
        action: HotAction.tun,
        key: PhysicalKeyboardKey.keyT.usbHidUsage,
        modifiers: {KeyboardModifier.control, KeyboardModifier.shift},
      ).toHotKeySpec();

      expect(spec?.id, HotAction.tun.index);
      expect(spec?.key, PhysicalKeyboardKey.keyT.usbHidUsage);
      expect(
        spec?.modifiers,
        unorderedEquals([HotKeyModifier.control, HotKeyModifier.shift]),
      );
    });

    test('skips an action without a key or without modifiers', () {
      expect(
        const HotKeyAction(
          action: HotAction.start,
          modifiers: {KeyboardModifier.control},
        ).toHotKeySpec(),
        isNull,
      );
      expect(
        HotKeyAction(
          action: HotAction.start,
          key: PhysicalKeyboardKey.keyS.usbHidUsage,
        ).toHotKeySpec(),
        isNull,
      );
    });
  });

  group('HotKeyManager', () {
    final action = HotKeyAction(
      action: HotAction.view,
      key: PhysicalKeyboardKey.keyV.usbHidUsage,
      modifiers: const {KeyboardModifier.control},
    );

    Future<(ProviderContainer, List<List<HotKeySpec>>)> pump(
      WidgetTester tester, {
      bool safeMode = false,
      Future<List<HotKeyFailure>> Function()? respond,
    }) async {
      final registrations = <List<HotKeySpec>>[];
      final container = ProviderContainer(
        overrides: [
          safeModeProvider.overrideWithValue(safeMode),
          hotKeyActionsProvider.overrideWithValue([action]),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: HotKeyManager(
            registerHotKeys: ({required specs}) async {
              registrations.add(specs);
              return respond?.call() ?? const [];
            },
            hotKeyEventSource: () => const Stream<int>.empty(),
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (container, registrations);
    }

    testWidgets('registers the configured shortcuts with the OS', (
      tester,
    ) async {
      final (container, registrations) = await pump(tester);

      expect(registrations, hasLength(1));
      expect(registrations.single.single.id, HotAction.view.index);
      expect(container.read(hotKeyFailuresProvider), isEmpty);
    });

    testWidgets('a safe mode build registers nothing', (tester) async {
      final (_, registrations) = await pump(tester, safeMode: true);

      expect(registrations, isEmpty);
    });

    testWidgets('publishes the shortcuts the OS refused', (tester) async {
      final (container, _) = await pump(
        tester,
        respond: () async => [
          HotKeyFailure(id: HotAction.view.index, reason: 'taken'),
        ],
      );

      expect(container.read(hotKeyFailuresProvider), {HotAction.view: 'taken'});
    });

    testWidgets('marks every shortcut failed when registration throws', (
      tester,
    ) async {
      final (container, _) = await pump(
        tester,
        respond: () => Future.error(StateError('no backend')),
      );

      expect(container.read(hotKeyFailuresProvider).keys, [HotAction.view]);
    });

    testWidgets('releases every shortcut while one is being recorded', (
      tester,
    ) async {
      final (container, registrations) = await pump(
        tester,
        respond: () async => [
          HotKeyFailure(id: HotAction.view.index, reason: 'taken'),
        ],
      );

      container.read(hotKeyRecordingProvider.notifier).value = true;
      await tester.pumpAndSettle();

      expect(registrations.last, isEmpty);
      expect(container.read(hotKeyFailuresProvider), {
        HotAction.view: 'taken',
      }, reason: 'an empty registration says nothing about the bindings');

      container.read(hotKeyRecordingProvider.notifier).value = false;
      await tester.pumpAndSettle();

      expect(registrations, hasLength(3));
      expect(registrations.last.single.id, HotAction.view.index);
    });
  });
}

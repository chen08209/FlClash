import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _labels = ShortcutLabels(isMacOS: false, isWindows: true);

final _keyA = PhysicalKeyboardKey.keyA.usbHidUsage;
final _keyB = PhysicalKeyboardKey.keyB.usbHidUsage;

ProviderContainer _containerFor(
  WidgetTester tester, {
  List<HotKeyAction> hotKeyActions = const [],
}) {
  const size = Size(1400, 1400);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  globalState.container = container;
  container.read(viewSizeProvider.notifier).update((_) => size);
  // hotKeyActionsProvider is autoDispose: without a live listener the seeded
  // value is discarded before the assertions read it back.
  final subscription = container.listen(
    hotKeyActionsProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(subscription.close);
  container.read(hotKeyActionsProvider.notifier).value = hotKeyActions;
  return container;
}

Future<void> _pumpView(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const TestApp(child: HotKeyView()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpRecorder(
  WidgetTester tester,
  ProviderContainer container,
  HotKeyAction action,
) async {
  // Pushed as a route so the recorder's Navigator.pop has something to pop,
  // matching how the view opens it as a dialog.
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestApp(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: HotKeyRecorder(hotKeyAction: action, labels: _labels),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _press(
  WidgetTester tester,
  PhysicalKeyboardKey key,
  LogicalKeyboardKey logicalKey, {
  List<(PhysicalKeyboardKey, LogicalKeyboardKey)> holding = const [],
}) async {
  for (final (physical, logical) in holding) {
    await simulateKeyDownEvent(logical, physicalKey: physical);
  }
  await simulateKeyDownEvent(logicalKey, physicalKey: key);
  await tester.pumpAndSettle();
  await simulateKeyUpEvent(logicalKey, physicalKey: key);
  for (final (physical, logical) in holding.reversed) {
    await simulateKeyUpEvent(logical, physicalKey: physical);
  }
  await tester.pumpAndSettle();
}

const _control = (
  PhysicalKeyboardKey.controlLeft,
  LogicalKeyboardKey.controlLeft,
);

Future<void> _pressControlA(WidgetTester tester) {
  return _press(
    tester,
    PhysicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyA,
    holding: const [_control],
  );
}

TextButton _button(WidgetTester tester, String label) {
  return tester.widget<TextButton>(find.widgetWithText(TextButton, label));
}

void main() {
  group('HotKeyView', () {
    testWidgets('lists every action, bound or not', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );
      await _pumpView(tester, container);

      for (final action in HotAction.values) {
        await tester.scrollUntilVisible(find.text(action.label), 100);
        expect(find.text(action.label), findsOne, reason: action.name);
      }
      expect(
        find.text(currentAppLocalizations.hotkeyNotSet),
        findsAtLeastNWidgets(1),
      );
      expect(tester.takeException(), null);
    });

    testWidgets('shows a binding as key caps and clears it in place', (
      tester,
    ) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.shift},
          ),
        ],
      );
      await _pumpView(tester, container);

      final labels = ShortcutLabels.host();
      expect(find.text(labels.modifier(KeyboardModifier.shift)), findsOne);
      expect(find.text(labels.key(_keyA)), findsOne);

      await tester.tap(find.byTooltip(currentAppLocalizations.remove));
      await tester.pumpAndSettle();

      expect(container.read(hotKeyActionsProvider), isEmpty);
      expect(find.text(labels.key(_keyA)), findsNothing);
    });

    testWidgets('flags a binding the OS refused', (tester) async {
      final container = _containerFor(
        tester,
        hotKeyActions: [
          HotKeyAction(
            action: HotAction.view,
            key: _keyA,
            modifiers: const {KeyboardModifier.control},
          ),
        ],
      );
      container.read(hotKeyFailuresProvider.notifier).value = {
        HotAction.view: 'already registered',
      };
      await _pumpView(tester, container);

      expect(find.text(currentAppLocalizations.hotkeyUnavailable), findsOne);
      expect(find.byTooltip('already registered'), findsOne);
    });
  });

  group('HotKeyRecorder', () {
    testWidgets('pauses global hotkeys while it is open', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      expect(container.read(hotKeyRecordingProvider), isTrue);

      await tester.tap(find.text(currentAppLocalizations.cancel));
      await tester.pumpAndSettle();

      expect(container.read(hotKeyRecordingProvider), isFalse);
    });

    testWidgets('previews held modifiers until a key completes it', (
      tester,
    ) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      expect(find.text(currentAppLocalizations.pressKeyboard), findsOne);

      await simulateKeyDownEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();

      expect(find.text('Ctrl'), findsOne);
      expect(find.text('…'), findsOne);
      expect(_button(tester, currentAppLocalizations.save).onPressed, isNull);

      await simulateKeyDownEvent(
        LogicalKeyboardKey.keyA,
        physicalKey: PhysicalKeyboardKey.keyA,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.keyA,
        physicalKey: PhysicalKeyboardKey.keyA,
      );
      await simulateKeyUpEvent(
        LogicalKeyboardKey.controlLeft,
        physicalKey: PhysicalKeyboardKey.controlLeft,
      );
      await tester.pumpAndSettle();

      expect(find.text('…'), findsNothing);
      expect(find.text('Ctrl'), findsOne);
      expect(find.text('A'), findsOne);
      expect(tester.takeException(), null);
    });

    testWidgets('save stores a modifier plus key combination', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _pressControlA(tester);
      await tester.tap(find.text(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      final stored = container.read(hotKeyActionsProvider);
      expect(stored, hasLength(1));
      expect(stored.single.action, HotAction.mode);
      expect(stored.single.key, _keyA);
      expect(stored.single.modifiers, {KeyboardModifier.control});
    });

    testWidgets('a bare key cannot be saved and says why', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _press(tester, PhysicalKeyboardKey.keyA, LogicalKeyboardKey.keyA);

      expect(_button(tester, currentAppLocalizations.save).onPressed, isNull);
      expect(
        find.text(
          currentAppLocalizations.hotkeyNeedsModifier('Ctrl, Alt, Shift, Win'),
        ),
        findsOne,
      );
      expect(container.read(hotKeyActionsProvider), isEmpty);
    });

    testWidgets('saving a taken combination moves it from the other action', (
      tester,
    ) async {
      final taken = HotKeyAction(
        action: HotAction.start,
        key: _keyA,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [taken]);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _pressControlA(tester);

      expect(
        find.text(
          currentAppLocalizations.hotkeyConflictWith(HotAction.start.label),
        ),
        findsOne,
      );

      await tester.tap(find.text(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      final stored = container.read(hotKeyActionsProvider);
      expect(stored, hasLength(1));
      expect(stored.single.action, HotAction.mode);
      expect(stored.single.key, _keyA);
    });

    testWidgets('save replaces the binding for the same action', (
      tester,
    ) async {
      final existing = HotKeyAction(
        action: HotAction.mode,
        key: _keyB,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [existing]);
      await _pumpRecorder(tester, container, existing);

      await _pressControlA(tester);
      await tester.tap(find.text(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      final stored = container.read(hotKeyActionsProvider);
      expect(stored, hasLength(1), reason: 'replaces rather than appends');
      expect(stored.single.key, _keyA);
    });

    testWidgets('remove clears the binding for the action', (tester) async {
      final existing = HotKeyAction(
        action: HotAction.mode,
        key: _keyB,
        modifiers: const {KeyboardModifier.control},
      );
      final other = HotKeyAction(
        action: HotAction.tun,
        key: _keyA,
        modifiers: const {KeyboardModifier.control},
      );
      final container = _containerFor(tester, hotKeyActions: [existing, other]);
      await _pumpRecorder(tester, container, existing);

      await tester.tap(find.text(currentAppLocalizations.remove));
      await tester.pumpAndSettle();

      expect(container.read(hotKeyActionsProvider), [other]);
    });

    testWidgets('remove is offered only for a bound action', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      expect(find.text(currentAppLocalizations.remove), findsNothing);
    });

    testWidgets('a bare Escape closes without saving', (tester) async {
      final container = _containerFor(tester);
      await _pumpRecorder(
        tester,
        container,
        const HotKeyAction(action: HotAction.mode),
      );

      await _press(
        tester,
        PhysicalKeyboardKey.escape,
        LogicalKeyboardKey.escape,
      );

      expect(find.byType(HotKeyRecorder), findsNothing);
      expect(container.read(hotKeyActionsProvider), isEmpty);
    });
  });
}

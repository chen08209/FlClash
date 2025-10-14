import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/list.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

extension IntlExt on Intl {
  static String actionMessage(String messageText) =>
      Intl.message('action_$messageText');
}

class HotKeyView extends StatelessWidget {
  const HotKeyView({super.key});

  String getSubtitle(HotKeyAction hotKeyAction) {
    final key = hotKeyAction.key;
    if (key == null) {
      return appLocalizations.noHotKey;
    }
    final modifierLabels = hotKeyAction.modifiers.map(
      (item) => item.physicalKeys.first.label,
    );
    var text = '';
    if (modifierLabels.isNotEmpty) {
      text += "${modifierLabels.join(" ")}+";
    }
    text += PhysicalKeyboardKey(key).label;
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: appLocalizations.hotkeyManagement,
      body: ListView.builder(
        itemCount: HotAction.values.length,
        itemBuilder: (_, index) {
          final hotAction = HotAction.values[index];
          return Consumer(
            builder: (_, ref, _) {
              final hotKeyAction = ref.watch(
                getHotKeyActionProvider(hotAction),
              );
              return ListItem(
                title: Text(IntlExt.actionMessage(hotAction.name)),
                subtitle: Text(
                  getSubtitle(hotKeyAction),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                ),
                onTap: () {
                  globalState.showCommonDialog(
                    child: HotKeyRecorder(hotKeyAction: hotKeyAction),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class HotKeyRecorder extends StatefulWidget {
  final HotKeyAction hotKeyAction;

  const HotKeyRecorder({super.key, required this.hotKeyAction});

  @override
  State<HotKeyRecorder> createState() => _HotKeyRecorderState();
}

class _HotKeyRecorderState extends State<HotKeyRecorder> {
  late ValueNotifier<HotKeyAction> hotKeyActionNotifier;

  @override
  void initState() {
    super.initState();
    hotKeyActionNotifier = ValueNotifier<HotKeyAction>(
      widget.hotKeyAction.copyWith(),
    );
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent keyEvent) {
    if (keyEvent is KeyUpEvent) return false;
    final keys = HardwareKeyboard.instance.physicalKeysPressed;

    final key = keyEvent.physicalKey;

    final modifiers = KeyboardModifier.values
        .where(
          (e) =>
              e.physicalKeys.any(keys.contains) &&
              !e.physicalKeys.contains(key),
        )
        .toSet();
    hotKeyActionNotifier.value = hotKeyActionNotifier.value.copyWith(
      modifiers: modifiers,
      key: key.usbHidUsage,
    );
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  void _handleRemove() {
    Navigator.of(context).pop();
    globalState.appController.updateOrAddHotKeyAction(
      hotKeyActionNotifier.value.copyWith(modifiers: {}, key: null),
    );
  }

  void _handleConfirm() {
    Navigator.of(context).pop();
    final config = globalState.config;
    final currentHotkeyAction = hotKeyActionNotifier.value;
    if (currentHotkeyAction.key == null ||
        currentHotkeyAction.modifiers.isEmpty) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.inputCorrectHotkey),
      );
      return;
    }
    final hotKeyActions = config.hotKeyActions;
    final index = hotKeyActions.indexWhere(
      (item) =>
          item.key == currentHotkeyAction.key &&
          keyboardModifierListEquality.equals(
            item.modifiers,
            currentHotkeyAction.modifiers,
          ),
    );
    if (index != -1) {
      globalState.showMessage(
        title: appLocalizations.tip,
        message: TextSpan(text: appLocalizations.hotkeyConflict),
      );
      return;
    }
    globalState.appController.updateOrAddHotKeyAction(currentHotkeyAction);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: appLocalizations.hotkeyManagement,
      body: Focus(
        onKeyEvent: (_, _) {
          return KeyEventResult.handled;
        },
        autofocus: true,
        child: CommonDialog(
          title: IntlExt.actionMessage(widget.hotKeyAction.action.name),
          actions: [
            TextButton(
              onPressed: () {
                _handleRemove();
              },
              child: Text(appLocalizations.remove),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                _handleConfirm();
              },
              child: Text(appLocalizations.confirm),
            ),
          ],
          child: ValueListenableBuilder(
            valueListenable: hotKeyActionNotifier,
            builder: (_, hotKeyAction, _) {
              final key = hotKeyAction.key;
              final modifiers = hotKeyAction.modifiers;
              return SizedBox(
                width: dialogCommonWidth,
                child: key != null
                    ? Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final modifier in modifiers)
                            KeyboardKeyBox(
                              keyboardKey: modifier.physicalKeys.first,
                            ),
                          if (modifiers.isNotEmpty)
                            Text('+', style: context.textTheme.titleMedium),
                          KeyboardKeyBox(keyboardKey: PhysicalKeyboardKey(key)),
                        ],
                      )
                    : Text(
                        appLocalizations.pressKeyboard,
                        style: context.textTheme.titleMedium,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class KeyboardKeyBox extends StatelessWidget {
  final KeyboardKey keyboardKey;

  const KeyboardKeyBox({super.key, required this.keyboardKey});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      type: CommonCardType.filled,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(keyboardKey.label, style: const TextStyle(fontSize: 16)),
      ),
      onPressed: () {},
    );
  }
}

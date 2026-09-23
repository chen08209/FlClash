import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Glyph _glyphOf(HotAction action) {
  return switch (action) {
    HotAction.view => AppGlyphs.eye,
    HotAction.start => AppGlyphs.playPause(0),
    HotAction.exit => AppGlyphs.close,
    HotAction.mode => AppGlyphs.split,
    HotAction.ruleMode => AppGlyphs.rules,
    HotAction.globalMode => AppGlyphs.language,
    HotAction.directMode => AppGlyphs.target,
    HotAction.proxy => AppGlyphs.shuffle,
    HotAction.tun => AppGlyphs.vpn,
    HotAction.copyEnv => AppGlyphs.code,
    HotAction.delayTest => AppGlyphs.bolt,
    HotAction.updateProfiles => AppGlyphs.sync,
  };
}

List<(String, List<HotAction>)> _sections(AppLocalizations appLocalizations) {
  return [
    (
      appLocalizations.general,
      const [HotAction.view, HotAction.start, HotAction.exit],
    ),
    (
      appLocalizations.outboundMode,
      const [
        HotAction.mode,
        HotAction.ruleMode,
        HotAction.globalMode,
        HotAction.directMode,
      ],
    ),
    (
      appLocalizations.network,
      const [HotAction.proxy, HotAction.tun, HotAction.copyEnv],
    ),
    (
      appLocalizations.proxies,
      const [HotAction.delayTest, HotAction.updateProfiles],
    ),
  ];
}

bool _sameCombination(HotKeyAction a, HotKeyAction b) {
  return a.key != null &&
      a.key == b.key &&
      keyboardModifierListEquality.equals(a.modifiers, b.modifiers);
}

HotKeyAction? _conflictOf(List<HotKeyAction> actions, HotKeyAction binding) {
  for (final item in actions) {
    if (item.action != binding.action && _sameCombination(item, binding)) {
      return item;
    }
  }
  return null;
}

/// Stores [binding] for its action, or clears the action when it has no key.
/// Another action holding the same combination loses it.
List<HotKeyAction> _withBinding(
  List<HotKeyAction> actions,
  HotKeyAction binding,
) {
  final isBound = binding.key != null;
  var isPlaced = false;
  final result = <HotKeyAction>[];
  for (final item in actions) {
    if (item.action == binding.action) {
      isPlaced = true;
      if (isBound) {
        result.add(binding);
      }
    } else if (!(isBound && _sameCombination(item, binding))) {
      result.add(item);
    }
  }
  if (isBound && !isPlaced) {
    result.add(binding);
  }
  return result;
}

void _saveBinding(WidgetRef ref, HotKeyAction binding) {
  final notifier = ref.read(hotKeyActionsProvider.notifier);
  notifier.value = _withBinding(notifier.value, binding);
}

class HotKeyView extends StatelessWidget {
  const HotKeyView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final labels = ShortcutLabels.host();
    return BaseScaffold(
      title: appLocalizations.hotkeyManagement,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ).copyWith(top: context.appBarInset + 8, bottom: 20),
        children: [
          const _HotKeyIntro(),
          for (final (title, actions) in _sections(appLocalizations))
            generateSectionV3(
              title: title,
              items: [
                for (final action in actions)
                  _HotKeyItem(action: action, labels: labels),
              ],
            ),
        ],
      ),
    );
  }
}

class _HotKeyIntro extends StatelessWidget {
  const _HotKeyIntro();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: ShapeDecoration(
        color: colorScheme.secondaryContainer.opacity50,
        shape: AppShape.xl,
      ),
      child: Row(
        spacing: 14,
        children: [
          GlyphIcon(
            AppGlyphs.keyboard,
            color: colorScheme.onSecondaryContainer,
          ),
          Expanded(
            child: Text(
              context.appLocalizations.hotkeyDesc,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotKeyItem extends ConsumerWidget {
  const _HotKeyItem({required this.action, required this.labels});

  final HotAction action;
  final ShortcutLabels labels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final hotKeyAction = ref.watch(getHotKeyActionProvider(action));
    final failure = ref.watch(
      hotKeyFailuresProvider.select((state) => state[action]),
    );
    final key = hotKeyAction.key;
    return DecorationListItem(
      contentPadding: EdgeInsets.only(left: 16, right: key == null ? 16 : 6),
      leading: GlyphIcon(_glyphOf(action)),
      title: Text(action.label, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: failure == null
          ? null
          : Tooltip(
              message: failure,
              child: Text(
                appLocalizations.hotkeyUnavailable,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
      trailing: key == null
          ? Text(
              appLocalizations.hotkeyNotSet,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                _KeyCaps(
                  parts: labels.parts(hotKeyAction.modifiers, key),
                  isError: failure != null,
                ),
                IconButton(
                  tooltip: appLocalizations.remove,
                  onPressed: () {
                    _saveBinding(ref, HotKeyAction(action: action));
                  },
                  icon: const GlyphIcon(AppGlyphs.close, size: 20),
                ),
              ],
            ),
      onPressed: () {
        dialogs.showCommonDialog(
          child: HotKeyRecorder(hotKeyAction: hotKeyAction, labels: labels),
        );
      },
    );
  }
}

class _KeyCaps extends StatelessWidget {
  const _KeyCaps({
    required this.parts,
    this.isLarge = false,
    this.isError = false,
  });

  final List<String> parts;
  final bool isLarge;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: isLarge ? 8 : 4,
      runSpacing: isLarge ? 8 : 4,
      alignment: WrapAlignment.center,
      children: [
        for (final part in parts)
          _KeyCap(label: part, isLarge: isLarge, isError: isError),
      ],
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.label,
    this.isLarge = false,
    this.isError = false,
    this.isPlaceholder = false,
  });

  final String label;
  final bool isLarge;
  final bool isError;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final side = isLarge ? 44.0 : 26.0;
    final foregroundColor = isError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;
    final textStyle = isLarge
        ? context.textTheme.titleMedium
        : context.textTheme.labelMedium;
    return Container(
      constraints: BoxConstraints(minWidth: side, minHeight: side),
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 7),
      decoration: ShapeDecoration(
        color: isPlaceholder
            ? Colors.transparent
            : colorScheme.surfaceContainerHighest,
        shape: (isLarge ? AppShape.md : AppShape.sm).copyWith(
          side: BorderSide(
            color: isError ? colorScheme.error : colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Align(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          label,
          style: textStyle?.copyWith(
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

class HotKeyRecorder extends ConsumerStatefulWidget {
  const HotKeyRecorder({
    super.key,
    required this.hotKeyAction,
    required this.labels,
  });

  final HotKeyAction hotKeyAction;
  final ShortcutLabels labels;

  @override
  ConsumerState<HotKeyRecorder> createState() => _HotKeyRecorderState();
}

class _HotKeyRecorderState extends ConsumerState<HotKeyRecorder> {
  late final HotKeyRecording _recording;
  Set<KeyboardModifier> _modifiers = const {};
  int? _key;

  HotKeyAction get _draft =>
      widget.hotKeyAction.copyWith(modifiers: _modifiers, key: _key);

  @override
  void initState() {
    super.initState();
    _recording = ref.read(hotKeyRecordingProvider.notifier);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _recording.value = true;
      }
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    final recording = _recording;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recording.value = false;
    });
    super.dispose();
  }

  Set<KeyboardModifier> _heldModifiers({PhysicalKeyboardKey? except}) {
    final pressed = HardwareKeyboard.instance.physicalKeysPressed;
    return {
      for (final modifier in KeyboardModifier.values)
        if (modifier.physicalKeys.any(pressed.contains) &&
            !modifier.physicalKeys.contains(except))
          modifier,
    };
  }

  bool _handleKeyEvent(KeyEvent event) {
    final physicalKey = event.physicalKey;
    if (isModifierKey(physicalKey)) {
      if (event is KeyDownEvent || (event is KeyUpEvent && _key == null)) {
        setState(() {
          _key = null;
          _modifiers = _heldModifiers();
        });
      }
      return false;
    }
    if (event is KeyUpEvent) {
      return false;
    }
    final modifiers = _heldModifiers(except: physicalKey);
    if (physicalKey == PhysicalKeyboardKey.escape && modifiers.isEmpty) {
      Navigator.of(context).pop();
      return false;
    }
    setState(() {
      _modifiers = modifiers;
      _key = physicalKey.usbHidUsage;
    });
    return false;
  }

  void _handleSave() {
    Navigator.of(context).pop();
    _saveBinding(ref, _draft);
  }

  void _handleRemove() {
    Navigator.of(context).pop();
    _saveBinding(ref, HotKeyAction(action: widget.hotKeyAction.action));
  }

  Widget _buildCapture(BuildContext context, {required bool isError}) {
    final colorScheme = context.colorScheme;
    final key = _key;
    final Widget content;
    if (key != null) {
      content = _KeyCaps(
        parts: widget.labels.parts(_modifiers, key),
        isLarge: true,
        isError: isError,
      );
    } else if (_modifiers.isNotEmpty) {
      content = Wrap(
        spacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final part in widget.labels.modifierParts(_modifiers))
            _KeyCap(label: part, isLarge: true),
          const _KeyCap(label: '…', isLarge: true, isPlaceholder: true),
        ],
      );
    } else {
      content = Text(
        context.appLocalizations.pressKeyboard,
        textAlign: TextAlign.center,
        style: context.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: colorScheme.surfaceContainerLow,
        shape: AppShape.md.copyWith(
          side: BorderSide(
            color: isError ? colorScheme.error : colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
      child: content,
    );
  }

  Widget? _buildStatus(
    BuildContext context, {
    required bool isInvalid,
    required HotKeyAction? conflict,
  }) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final (text, color) = switch ((isInvalid, conflict)) {
      (true, _) => (
        appLocalizations.hotkeyNeedsModifier(
          widget.labels
              .modifierParts(primaryHotKeyModifiers)
              .join(widget.labels.isMacOS ? ' ' : ', '),
        ),
        colorScheme.error,
      ),
      (false, final HotKeyAction conflict) => (
        appLocalizations.hotkeyConflictWith(conflict.action.label),
        colorScheme.tertiary,
      ),
      _ => (null, null),
    };
    if (text == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final draft = _draft;
    final isComplete = draft.key != null;
    final isValid = isValidHotKey(draft.modifiers, draft.key);
    final isInvalid = isComplete && !isValid;
    final conflict = isValid
        ? _conflictOf(ref.watch(hotKeyActionsProvider), draft)
        : null;
    final status = _buildStatus(
      context,
      isInvalid: isInvalid,
      conflict: conflict,
    );
    return Focus(
      onKeyEvent: (_, _) {
        return KeyEventResult.handled;
      },
      autofocus: true,
      child: CommonDialog(
        title: widget.hotKeyAction.action.label,
        actions: [
          if (widget.hotKeyAction.key != null)
            TextButton(
              onPressed: _handleRemove,
              child: Text(appLocalizations.remove),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(appLocalizations.cancel),
          ),
          TextButton(
            onPressed: isValid ? _handleSave : null,
            child: Text(appLocalizations.save),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCapture(context, isError: isInvalid),
            AnimatedSize(
              duration: commonDuration,
              alignment: Alignment.topCenter,
              child: status ?? const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

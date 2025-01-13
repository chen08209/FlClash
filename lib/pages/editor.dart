import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

import '../models/common.dart';

typedef EditingValueChangeBuilder = Widget Function(CodeLineEditingValue value);

class EditorPage extends StatefulWidget {
  final String title;
  final String content;
  final Function(BuildContext context, String text)? onSave;
  final Future<bool> Function(BuildContext context, String text)? onPop;

  const EditorPage({
    super.key,
    required this.title,
    required this.content,
    this.onSave,
    this.onPop,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late CodeLineEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = CodeLineEditingController.fromText(widget.content);
    if (system.isDesktop) {
      return;
    }
    _focusNode.onKeyEvent = ((_, event) {
      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      final key = event.logicalKey;
      if (!keys.contains(key)) {
        return KeyEventResult.ignored;
      }
      if (key == LogicalKeyboardKey.arrowUp) {
        _controller.moveCursor(AxisDirection.up);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _controller.moveCursor(AxisDirection.down);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        _controller.selection.endIndex;
        _controller.moveCursor(AxisDirection.left);
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _controller.moveCursor(AxisDirection.right);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _wrapController(EditingValueChangeBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (_, value, ___) {
        return builder(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (widget.onPop != null) {
          final res = await widget.onPop!(context, _controller.text);
          if (res && context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }
        Navigator.of(context).pop();
      },
      child: CommonScaffold(
        actions: [
          _wrapController(
            (value) => IconButton(
              onPressed: _controller.canUndo ? _controller.undo : null,
              icon: const Icon(Icons.undo),
            ),
          ),
          _wrapController(
            (value) => IconButton(
              onPressed: _controller.canRedo ? _controller.redo : null,
              icon: const Icon(Icons.redo),
            ),
          ),
          if (widget.onSave != null)
            _wrapController(
              (value) => IconButton(
                onPressed: _controller.text == widget.content
                    ? null
                    : () {
                        widget.onSave!(context, _controller.text);
                      },
                icon: const Icon(Icons.save_sharp),
              ),
            ),
        ],
        body: CodeEditor(
          focusNode: _focusNode,
          scrollbarBuilder: (context, child, details) {
            return Scrollbar(
              controller: details.controller,
              thickness: 8,
              radius: const Radius.circular(2),
              interactive: true,
              child: child,
            );
          },
          toolbarController: ContextMenuControllerImpl(),
          indicatorBuilder: (
            context,
            editingController,
            chunkController,
            notifier,
          ) {
            return Row(
              children: [
                DefaultCodeLineNumber(
                  controller: editingController,
                  notifier: notifier,
                ),
                DefaultCodeChunkIndicator(
                  width: 20,
                  controller: chunkController,
                  notifier: notifier,
                )
              ],
            );
          },
          shortcutsActivatorsBuilder: DefaultCodeShortcutsActivatorsBuilder(),
          controller: _controller,
          style: CodeEditorStyle(
            fontSize: 14,
            codeTheme: CodeHighlightTheme(
              languages: {
                'yaml': CodeHighlightThemeMode(
                  mode: langYaml,
                )
              },
              theme: atomOneLightTheme,
            ),
          ),
        ),
        title: widget.title,
      ),
    );
  }
}

class ContextMenuControllerImpl implements SelectionToolbarController {
  OverlayEntry? _overlayEntry;
  bool _isFirstRender = true;

  _removeOverLayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isFirstRender = true;
  }

  @override
  void hide(BuildContext context) {
    _removeOverLayEntry();
  }

  @override
  void show({
    required context,
    required controller,
    required anchors,
    renderRect,
    required layerLink,
    required ValueNotifier<bool> visibility,
  }) {
    _removeOverLayEntry();
    _overlayEntry ??= OverlayEntry(
      builder: (context) => CodeEditorTapRegion(
        child: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, __, child) {
            final isNotEmpty = controller.selectedText.isNotEmpty;
            final isAllSelected = controller.isAllSelected;
            final hasSelected = controller.selectedText.isNotEmpty;
            List<ActionItemData> menus = [
              if (isNotEmpty)
                ActionItemData(
                  label: appLocalizations.copy,
                  onPressed: controller.copy,
                ),
              ActionItemData(
                label: appLocalizations.paste,
                onPressed: controller.paste,
              ),
              if (isNotEmpty)
                ActionItemData(
                  label: appLocalizations.cut,
                  onPressed: controller.cut,
                ),
              if (hasSelected && !isAllSelected)
                ActionItemData(
                  label: appLocalizations.selectAll,
                  onPressed: controller.selectAll,
                ),
            ];
            if (_isFirstRender) {
              _isFirstRender = false;
            } else if (controller.selectedText.isEmpty) {
              _removeOverLayEntry();
            }
            return TextSelectionToolbar(
              anchorAbove: anchors.primaryAnchor,
              anchorBelow: anchors.secondaryAnchor ?? Offset.zero,
              children: menus.asMap().entries.map(
                (MapEntry<int, ActionItemData> entry) {
                  return TextSelectionToolbarTextButton(
                    padding: TextSelectionToolbarTextButton.getPadding(
                      entry.key,
                      menus.length,
                    ),
                    alignment: AlignmentDirectional.centerStart,
                    onPressed: () {
                      entry.value.onPressed();
                    },
                    child: Text(entry.value.label),
                  );
                },
              ).toList(),
            );
          },
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
}

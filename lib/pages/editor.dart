import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

typedef EditingValueChangeBuilder = Widget Function(CodeLineEditingValue value);
typedef TextEditingValueChangeBuilder = Widget Function(TextEditingValue value);

class EditorPage extends ConsumerStatefulWidget {
  final String title;
  final String content;
  final List<Language> languages;
  final bool supportRemoteDownload;
  final bool titleEditable;
  final Function(BuildContext context, String title, String content)? onSave;
  final Future<bool> Function(
      BuildContext context, String title, String content)? onPop;

  const EditorPage({
    super.key,
    required this.title,
    required this.content,
    this.titleEditable = false,
    this.onSave,
    this.onPop,
    this.supportRemoteDownload = false,
    this.languages = const [
      Language.yaml,
    ],
  });

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  late CodeLineEditingController _controller;
  late CodeFindController _findController;
  late TextEditingController _titleController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = CodeLineEditingController.fromText(widget.content);
    _findController = CodeFindController(_controller);
    _titleController = TextEditingController(text: widget.title);
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
    _findController.dispose();
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

  Widget _wrapTitleController(TextEditingValueChangeBuilder builder) {
    return ValueListenableBuilder(
      valueListenable: _titleController,
      builder: (_, value, ___) {
        return builder(value);
      },
    );
  }

  void _handleSearch() {
    _findController.findMode();
  }

  Future<void> _handleImport() async {
    final option = await globalState.showCommonDialog<ImportOption>(
      child: _ImportOptionsDialog(),
    );
    if (option == null) {
      return;
    }
    if (option == ImportOption.file) {
      final file = await picker.pickerFile();
      if (file == null) {
        return;
      }
      final res = String.fromCharCodes(file.bytes?.toList() ?? []);
      _controller.text = res;
      return;
    }
    final url = await globalState.showCommonDialog(
      child: InputDialog(
        title: '导入',
        value: '',
        labelText: appLocalizations.url,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.value);
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip(appLocalizations.value);
          }
          return null;
        },
      ),
    );
    if (url == null) {
      return;
    }
    final res = await request.getTextResponseForUrl(url);
    _controller.text = res.data;
  }

  @override
  Widget build(BuildContext context) {
    final isMobileView = ref.watch(isMobileViewProvider);
    return CommonPopScope(
      onPop: () async {
        if (widget.onPop == null) {
          return true;
        }
        final res = await widget.onPop!(
          context,
          _titleController.text,
          _controller.text,
        );
        if (res && context.mounted) {
          return true;
        }
        return false;
      },
      child: CommonScaffold(
        appBar: AppBar(
          title: TextField(
            enabled: widget.titleEditable,
            controller: _titleController,
            decoration: InputDecoration(
              border: _NoInputBorder(),
              hintText: appLocalizations.unnamed,
            ),
            style: context.textTheme.titleLarge,
            autofocus: false,
          ),
          actions: genActions([
            if (widget.onSave != null)
              _wrapController(
                (value) => _wrapTitleController(
                  (value) => IconButton(
                    onPressed: _controller.text != widget.content ||
                            _titleController.text != widget.title
                        ? () {
                            widget.onSave!(
                              context,
                              _titleController.text,
                              _controller.text,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.save_sharp),
                  ),
                ),
              ),
            if (widget.supportRemoteDownload)
              IconButton(
                onPressed: _handleImport,
                icon: Icon(
                  Icons.arrow_downward,
                ),
              ),
            _wrapController(
              (value) => CommonPopupBox(
                targetBuilder: (open) {
                  return IconButton(
                    onPressed: () {
                      open(
                        offset: Offset(-20, 20),
                      );
                    },
                    icon: const Icon(Icons.more_vert),
                  );
                },
                popup: CommonPopupMenu(
                  items: [
                    PopupMenuItemData(
                      icon: Icons.search,
                      label: appLocalizations.search,
                      onPressed: _handleSearch,
                    ),
                    PopupMenuItemData(
                      icon: Icons.undo,
                      label: appLocalizations.undo,
                      onPressed: _controller.canUndo ? _controller.undo : null,
                    ),
                    PopupMenuItemData(
                      icon: Icons.redo,
                      label: appLocalizations.redo,
                      onPressed: _controller.canRedo ? _controller.redo : null,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
        body: CodeEditor(
          findController: _findController,
          findBuilder: (context, controller, readOnly) => FindPanel(
            controller: controller,
            readOnly: readOnly,
            isMobileView: isMobileView,
          ),
          padding: EdgeInsets.only(
            right: 16,
          ),
          autocompleteSymbols: true,
          focusNode: _focusNode,
          scrollbarBuilder: (context, child, details) {
            return CommonScrollBar(
              controller: details.controller,
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
            fontSize: context.textTheme.bodyLarge?.fontSize?.ap,
            fontFamily: FontFamily.jetBrainsMono.value,
            codeTheme: CodeHighlightTheme(
              languages: {
                if (widget.languages.contains(Language.yaml))
                  'yaml': CodeHighlightThemeMode(
                    mode: langYaml,
                  ),
                if (widget.languages.contains(Language.javaScript))
                  'javascript': CodeHighlightThemeMode(
                    mode: langJavascript,
                  ),
              },
              theme: atomOneLightTheme,
            ),
          ),
        ),
      ),
    );
  }
}

const double _kDefaultFindPanelHeight = 52;

class FindPanel extends StatelessWidget implements PreferredSizeWidget {
  final CodeFindController controller;
  final bool readOnly;
  final bool isMobileView;
  final double height;

  const FindPanel({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.isMobileView,
  }) : height = (isMobileView
                ? _kDefaultFindPanelHeight * 2
                : _kDefaultFindPanelHeight) +
            8;

  @override
  Size get preferredSize => Size(
        double.infinity,
        controller.value == null ? 0 : height,
      );

  @override
  Widget build(BuildContext context) {
    if (controller.value == null) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      margin: EdgeInsets.only(
        bottom: 8,
      ),
      color: context.colorScheme.surface,
      alignment: Alignment.centerLeft,
      height: height,
      child: _buildFindInputView(context),
    );
  }

  Widget _buildFindInputView(BuildContext context) {
    final CodeFindValue value = controller.value!;
    final String result;
    if (value.result == null) {
      result = appLocalizations.none;
    } else {
      result = '${value.result!.index + 1}/${value.result!.matches.length}';
    }
    final bar = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isMobileView) ...[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360),
            child: _buildFindInput(context, value),
          ),
          SizedBox(
            width: 12,
          ),
        ],
        Text(
          result,
          style: context.textTheme.bodyMedium,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              _buildIconButton(
                onPressed: value.result == null
                    ? null
                    : () {
                        controller.previousMatch();
                      },
                icon: Icons.arrow_upward,
              ),
              _buildIconButton(
                onPressed: value.result == null
                    ? null
                    : () {
                        controller.nextMatch();
                      },
                icon: Icons.arrow_downward,
              ),
              SizedBox(
                width: 2,
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                onPressed: controller.close,
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.all(0),
                  ),
                ),
                icon: Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (isMobileView) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bar,
          SizedBox(
            height: 4,
          ),
          _buildFindInput(context, value),
        ],
      );
    }
    return bar;
  }

  Stack _buildFindInput(BuildContext context, CodeFindValue value) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildTextField(
          context: context,
          onSubmitted: () {
            if (value.result == null) {
              return;
            }
            controller.nextMatch();
            controller.findInputFocusNode.requestFocus();
          },
          controller: controller.findInputController,
          focusNode: controller.findInputFocusNode,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 8,
          children: [
            _buildCheckText(
              context: context,
              text: 'Aa',
              isSelected: value.option.caseSensitive,
              onPressed: () {
                controller.toggleCaseSensitive();
              },
            ),
            _buildCheckText(
              context: context,
              text: '.*',
              isSelected: value.option.regex,
              onPressed: () {
                controller.toggleRegex();
              },
            ),
            SizedBox(
              width: 4,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSubmitted,
  }) {
    return TextField(
      maxLines: 1,
      focusNode: focusNode,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
        ),
      ),
      onSubmitted: (_) {
        onSubmitted();
      },
      controller: controller,
    );
  }

  Widget _buildCheckText({
    required BuildContext context,
    required String text,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: isSelected
            ? IconButton.filledTonal(
                onPressed: onPressed,
                padding: EdgeInsets.all(2),
                icon: Text(text, style: context.textTheme.bodySmall),
              )
            : IconButton(
                onPressed: onPressed,
                padding: EdgeInsets.all(2),
                icon: Text(
                  text,
                  style: context.textTheme.bodySmall,
                ),
              ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(0))),
      icon: Icon(
        icon,
        size: 16,
      ),
    );
  }
}

class ContextMenuControllerImpl implements SelectionToolbarController {
  OverlayEntry? _overlayEntry;
  bool _isFirstRender = true;

  void _removeOverLayEntry() {
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
            List<PopupMenuItemData> menus = [
              if (isNotEmpty)
                PopupMenuItemData(
                  label: appLocalizations.copy,
                  onPressed: controller.copy,
                ),
              PopupMenuItemData(
                label: appLocalizations.paste,
                onPressed: controller.paste,
              ),
              if (isNotEmpty)
                PopupMenuItemData(
                  label: appLocalizations.cut,
                  onPressed: controller.cut,
                ),
              if (hasSelected && !isAllSelected)
                PopupMenuItemData(
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
                (MapEntry<int, PopupMenuItemData> entry) {
                  return TextSelectionToolbarTextButton(
                    padding: TextSelectionToolbarTextButton.getPadding(
                      entry.key,
                      menus.length,
                    ),
                    alignment: AlignmentDirectional.centerStart,
                    onPressed: () {
                      if (entry.value.onPressed == null) {
                        return;
                      }
                      entry.value.onPressed!();
                      _removeOverLayEntry();
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

class _NoInputBorder extends InputBorder {
  const _NoInputBorder() : super(borderSide: BorderSide.none);

  @override
  _NoInputBorder copyWith({BorderSide? borderSide}) => const _NoInputBorder();

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  _NoInputBorder scale(double t) => const _NoInputBorder();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paintInterior(Canvas canvas, Rect rect, Paint paint,
      {TextDirection? textDirection}) {
    canvas.drawRect(rect, paint);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {}
}

class _ImportOptionsDialog extends StatefulWidget {
  const _ImportOptionsDialog();

  @override
  State<_ImportOptionsDialog> createState() => _ImportOptionsDialogState();
}

class _ImportOptionsDialogState extends State<_ImportOptionsDialog> {
  void _handleOnTab(ImportOption value) {
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.import,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      child: Wrap(
        children: [
          ListItem(
            onTap: () {
              _handleOnTab(ImportOption.url);
            },
            title: Text(appLocalizations.importUrl),
          ),
          ListItem(
            onTap: () {
              _handleOnTab(ImportOption.file);
            },
            title: Text(appLocalizations.importFile),
          )
        ],
      ),
    );
  }
}

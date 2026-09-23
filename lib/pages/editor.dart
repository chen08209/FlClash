import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_forge/code_forge.dart'
    show
        CodeForge,
        CodeForgeContextMenuRequest,
        CodeForgeController,
        CodeForgeKeyboardShortcuts,
        CodeSelectionStyle,
        FindController,
        RustLib,
        UndoRedoController;
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';

Future<void>? _codeForgeInit;

Future<void> _initCodeForge() {
  return _codeForgeInit ??= RustLib.init().onError<Object>((error, stack) {
    _codeForgeInit = null;
    Error.throwWithStackTrace(error, stack);
  });
}

class EditorPage extends ConsumerStatefulWidget {
  final String title;
  final String? content;
  final Language language;
  final bool titleEditable;
  final Function(BuildContext context, String title, String content)? onSave;
  final Future<bool> Function(
    BuildContext context,
    String title,
    String content,
  )?
  onPop;
  final bool? readOnly;

  const EditorPage({
    super.key,
    required this.title,
    required this.content,
    this.titleEditable = false,
    this.onSave,
    this.onPop,
    this.readOnly,
    this.language = Language.yaml,
  });

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _editorKey = GlobalKey<EditorViewState>();
  late UndoRedoController _undoController;
  late TextEditingController _titleController;
  late bool readOnly = false;

  EditorViewState? get _editor => _editorKey.currentState;

  String get _content => _editor?.content ?? widget.content ?? '';

  CodeForgeKeyboardShortcuts get _shortcuts =>
      CodeForgeKeyboardShortcuts.forPlatform(defaultTargetPlatform);

  SingleActivator get _saveShortcut => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => const SingleActivator(
      LogicalKeyboardKey.keyS,
      meta: true,
    ),
    _ => const SingleActivator(LogicalKeyboardKey.keyS, control: true),
  };

  bool get _isDirty =>
      _content != widget.content || _titleController.text != widget.title;

  @override
  void initState() {
    super.initState();
    readOnly = widget.readOnly ?? widget.onSave == null;
    _undoController = UndoRedoController();
    _titleController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _undoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _handleSearch({bool replace = false}) {
    _editor?.search(replace: replace);
  }

  void _handleSave() {
    final onSave = widget.onSave;
    if (onSave == null || readOnly || !_isDirty) {
      return;
    }
    onSave(context, _titleController.text, _content);
  }

  Future<bool> _handlePop(BuildContext context) async {
    final onPop = widget.onPop;
    if (onPop == null) {
      return true;
    }
    final res = await onPop(context, _titleController.text, _content);
    return res && context.mounted;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _editor?.controller;
    final menu = _EditorMenuAction(
      undoController: _undoController,
      onSearch: controller == null ? null : _handleSearch,
    );
    return CommonPopScope(
      onPop: _handlePop,
      child: CallbackShortcuts(
        bindings: {
          _saveShortcut: _handleSave,
          _shortcuts.showFindBar: _handleSearch,
          _shortcuts.showFindAndReplaceBar: () => _handleSearch(replace: true),
        },
        child: Focus(
          autofocus: true,
          child: CommonScaffold(
            appBar: AppBar(
              clipBehavior: Clip.none,
              title: _EditorTitleField(
                controller: _titleController,
                enabled: widget.titleEditable,
              ),
              actions: genActions([
                if (widget.onSave != null)
                  TonalButtonGroup(
                    children: [
                      _EditorSaveAction(
                        listenable: Listenable.merge([
                          if (controller != null)
                            _CodeForgeListenable(controller),
                          _titleController,
                        ]),
                        isDirty: () => _isDirty,
                        onSave: _handleSave,
                      ),
                      menu,
                    ],
                  )
                else
                  ElasticPress(child: menu),
              ], edge: AppBarActionEdge.container),
            ),
            body: EditorView(
              key: _editorKey,
              content: widget.content,
              language: widget.language,
              readOnly: readOnly,
              undoController: _undoController,
              onReady: () => setState(() {}),
            ),
          ),
        ),
      ),
    );
  }
}

/// The code editor without page chrome, so it can fill a page or one pane
/// of it. The native library loads once per process and the editor mounts
/// after the enclosing route has settled.
class EditorView extends ConsumerStatefulWidget {
  final String? content;
  final Language language;
  final bool readOnly;
  final UndoRedoController? undoController;
  final VoidCallback? onReady;

  const EditorView({
    super.key,
    required this.content,
    this.language = Language.yaml,
    this.readOnly = false,
    this.undoController,
    this.onReady,
  });

  @override
  ConsumerState<EditorView> createState() => EditorViewState();
}

class EditorViewState extends ConsumerState<EditorView> {
  CodeForgeController? _controller;
  FindController? _findController;
  UndoRedoController? _ownedUndoController;
  Object? _initError;
  late String _pendingContent;
  Animation<double>? _routeAnimation;
  final _routeSettled = Completer<void>();

  CodeForgeController? get controller => _controller;

  String get content => _controller?.text ?? _pendingContent;

  UndoRedoController get _undoController =>
      widget.undoController ?? (_ownedUndoController ??= UndoRedoController());

  @override
  void initState() {
    super.initState();
    _pendingContent = widget.content ?? '';
    _routeSettled.future
        .then((_) => _initCodeForge())
        .then(
          (_) {
            if (!mounted) {
              return;
            }
            final controller = CodeForgeController();
            _loadContent(controller, _pendingContent);
            setState(() {
              _controller = controller;
              _findController = FindController(controller);
            });
            widget.onReady?.call();
          },
          onError: (Object error) {
            if (!mounted) {
              return;
            }
            setState(() {
              _initError = error;
            });
          },
        );
  }

  // Loading or mounting CodeForge mid-transition drops frames, so both wait.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeSettled.isCompleted || _routeAnimation != null) {
      return;
    }
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      _routeSettled.complete();
      return;
    }
    _routeAnimation = animation..addStatusListener(_handleRouteStatus);
  }

  void _handleRouteStatus(AnimationStatus status) {
    if (!status.isAnimating && !_routeSettled.isCompleted) {
      _routeSettled.complete();
    }
  }

  @override
  void didUpdateWidget(covariant EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final content = widget.content;
      if (!mounted || content == null || oldWidget.content == content) {
        return;
      }
      final controller = _controller;
      if (controller == null) {
        setState(() {
          _pendingContent = content;
        });
        return;
      }
      _loadContent(controller, content);
      _undoController.clear();
    });
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_handleRouteStatus);
    _findController?.dispose();
    _controller?.dispose();
    _ownedUndoController?.dispose();
    super.dispose();
  }

  void _loadContent(CodeForgeController controller, String content) {
    controller
      ..text = content
      ..selection = const TextSelection.collapsed(offset: 0);
  }

  void search({bool replace = false}) {
    final findController = _findController;
    if (findController == null) {
      return;
    }
    if (findController.isActive) {
      findController.findInputFocusNode.requestFocus();
    }
    findController
      ..isActive = true
      ..isReplaceMode = replace && !widget.readOnly;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return _EditorBody(
      controller: controller,
      findController: _findController,
      undoController: _undoController,
      readOnly: widget.readOnly,
      language: widget.language,
      error: _initError,
      isLoading:
          _initError == null && (widget.content == null || controller == null),
    );
  }
}

class _CodeForgeListenable implements Listenable {
  const _CodeForgeListenable(this.controller);

  final CodeForgeController controller;

  @override
  void addListener(VoidCallback listener) {
    controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    controller.removeListener(listener);
  }
}

class _EditorTitleField extends StatelessWidget {
  const _EditorTitleField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: TextInputLimits.name,
      enabled: enabled,
      controller: controller,
      decoration: InputDecoration(
        border: const NoInputBorder(),
        counter: const SizedBox(),
        hintText: context.appLocalizations.unnamed,
      ),
      style: context.textTheme.titleLarge,
      autofocus: false,
    );
  }
}

class _EditorSaveAction extends StatelessWidget {
  const _EditorSaveAction({
    required this.listenable,
    required this.isDirty,
    required this.onSave,
  });

  final Listenable listenable;
  final bool Function() isDirty;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        return IconButton(
          tooltip: context.appLocalizations.save,
          onPressed: isDirty() ? onSave : null,
          icon: const GlyphIcon(AppGlyphs.save),
        );
      },
    );
  }
}

class _EditorMenuAction extends ConsumerWidget {
  const _EditorMenuAction({
    required this.undoController,
    required this.onSearch,
  });

  final UndoRedoController undoController;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return ListenableBuilder(
      listenable: undoController,
      builder: (_, _) {
        return CommonPopupBox(
          targetBuilder: (open) {
            return IconButton(
              tooltip: context.appLocalizations.more,
              onPressed: () {
                final isMobile = ref.read(isMobileViewProvider);
                open(offset: Offset(0, isMobile ? 0 : 20));
              },
              icon: const GlyphIcon(AppGlyphs.more),
            );
          },
          popupBuilder: (_) => CommonPopupMenu(
            items: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.search,
                label: appLocalizations.search,
                onPressed: onSearch,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.undo,
                label: appLocalizations.undo,
                onPressed: undoController.canUndo ? undoController.undo : null,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.redo,
                label: appLocalizations.redo,
                onPressed: undoController.canRedo ? undoController.redo : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.controller,
    required this.findController,
    required this.undoController,
    required this.readOnly,
    required this.language,
    required this.error,
    required this.isLoading,
  });

  final CodeForgeController? controller;
  final FindController? findController;
  final UndoRedoController undoController;
  final bool readOnly;
  final Language language;
  final Object? error;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final findController = this.findController;
    final error = this.error;
    return Stack(
      children: [
        if (error != null)
          NullStatus(
            label: context.appLocalizations.editorUnavailable,
            description: '$error',
            illustration: NullStatusIllustration.error,
          )
        else if (controller != null && findController != null)
          _CodeEditor(
            controller: controller,
            findController: findController,
            undoController: undoController,
            readOnly: readOnly,
            language: language,
          ),
        FadeBox(
          child: isLoading
              ? Container(
                  color: context.colorScheme.surface,
                  alignment: Alignment.center,
                  child: const SizedBox.square(
                    dimension: 200,
                    child: CommonCircleLoading(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CodeEditor extends ConsumerStatefulWidget {
  const _CodeEditor({
    required this.controller,
    required this.findController,
    required this.undoController,
    required this.readOnly,
    required this.language,
  });

  final CodeForgeController controller;
  final FindController findController;
  final UndoRedoController undoController;
  final bool readOnly;
  final Language language;

  @override
  ConsumerState<_CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends ConsumerState<_CodeEditor> {
  // CodeForge compares these by identity and rebuilds its whole layout and
  // highlighter on any change, so each is rebuilt only when its inputs change.
  ColorScheme? _colorScheme;
  Map<String, TextStyle> _editorTheme = const {};
  CodeSelectionStyle? _selectionStyle;
  TextStyle? _textStyle;

  void _updateStyles(BuildContext context) {
    final colorScheme = context.colorScheme;
    if (colorScheme != _colorScheme) {
      _colorScheme = colorScheme;
      _editorTheme = _highlightTheme(colorScheme, widget.language);
      _selectionStyle = CodeSelectionStyle(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.opacity30,
        cursorBubbleColor: colorScheme.primary,
      );
    }
    final textStyle = TextStyle(
      fontSize: context.textTheme.bodyLarge?.fontSize?.ap,
      fontFamily: FontFamily.jetBrainsMono.value,
    );
    if (textStyle != _textStyle) {
      _textStyle = textStyle;
    }
  }

  void _showContextMenu(
    BuildContext context,
    CodeForgeContextMenuRequest request,
  ) {
    final appLocalizations = context.appLocalizations;
    final items = [
      if (request.hasSelection && !request.readOnly)
        CommonPopupMenuItem(
          glyph: AppGlyphs.cut,
          label: appLocalizations.cut,
          onPressed: request.cut,
        ),
      if (request.hasSelection)
        CommonPopupMenuItem(
          glyph: AppGlyphs.copy,
          label: appLocalizations.copy,
          onPressed: request.copy,
        ),
      if (!request.readOnly)
        CommonPopupMenuItem(
          glyph: AppGlyphs.paste,
          label: appLocalizations.paste,
          onPressed: request.paste,
        ),
      if (!request.isAllSelected)
        CommonPopupMenuItem(
          glyph: AppGlyphs.selectAll,
          label: appLocalizations.selectAll,
          onPressed: request.selectAll,
        ),
    ];
    final navigator = Navigator.of(context);
    final navigatorBox = navigator.context.findRenderObject();
    if (items.isEmpty || navigatorBox is! RenderBox) {
      return;
    }
    final point = navigatorBox.globalToLocal(request.globalPosition);
    navigator.push(
      CommonPopupRoute<void>(
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        placement: PopupPlacement.belowPoint,
        anchorOf: () => point & Size.zero,
        builder: (_) => CommonPopupMenu(items: items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateStyles(context);
    final isMobileView = ref.watch(isMobileViewProvider);
    return CodeForge(
      // Its gutter and popup styles are fixed at initState from the theme.
      key: ObjectKey(_editorTheme),
      controller: widget.controller,
      findController: widget.findController,
      undoController: widget.undoController,
      readOnly: widget.readOnly,
      language: switch (widget.language) {
        Language.yaml => langYaml,
        Language.javaScript => langJavascript,
        Language.json => langJson,
      },
      editorTheme: _editorTheme,
      tabSize: 2,
      useSpaceAsTab: true,
      selectionStyle: _selectionStyle,
      textStyle: _textStyle,
      innerPadding: const EdgeInsets.only(right: 16),
      onContextMenu: _showContextMenu,
      scrollbarBuilder: (context, details, child) => FloatingScrollbar(
        controller: details.controller,
        hintBuilder: (_) =>
            '${details.firstVisibleLine.value} / ${widget.controller.lineCount}',
        child: child,
      ),
      finderBuilder: (context, findController) => FindPanel(
        controller: findController,
        readOnly: widget.readOnly,
        isMobileView: isMobileView,
      ),
    );
  }
}

// atom-one colours keys and numbers alike and has no entry for several scopes
// highlight.js emits, which then render as plain text. Mapping them onto the
// palette gives each kind of token one colour in every language.
Map<String, TextStyle> _highlightTheme(
  ColorScheme colorScheme,
  Language language,
) {
  final palette = colorScheme.brightness == Brightness.dark
      ? atomOneDarkTheme
      : atomOneLightTheme;
  return {
    ...palette,
    'attr': palette['name']!,
    'property': palette['name']!,
    'title.function': palette['title']!,
    'title.class': palette['title.class_']!,
    'title.class.inherited': palette['title.class_']!,
    'variable.language': palette['built_in']!,
    // The JSON grammar nests `true`, `false` and `null` as keywords in a literal.
    if (language == Language.json) 'keyword': palette['literal']!,
    'root': TextStyle(
      color: colorScheme.onSurface,
      backgroundColor: colorScheme.surface,
    ),
  };
}

const double _kDefaultFindPanelHeight = 52;

class FindPanel extends StatelessWidget implements PreferredSizeWidget {
  final FindController controller;
  final bool readOnly;
  final bool isMobileView;

  const FindPanel({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.isMobileView,
  });

  bool get _showReplace => controller.isReplaceMode && !readOnly;

  double get height {
    final rows = (isMobileView ? 2 : 1) + (_showReplace ? 1 : 0);
    return _kDefaultFindPanelHeight * rows + 8;
  }

  @override
  Size get preferredSize => Size(double.infinity, height);

  void _close() {
    controller.isReplaceMode = false;
    controller.isActive = false;
  }

  @override
  Widget build(BuildContext context) {
    // On macOS a focused text field hands Escape to the input method, which
    // comes back as a DismissIntent rather than a key event.
    return Actions(
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) => _close()),
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _close,
          const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {
            if (controller.matchCount > 0) {
              controller.previous();
            }
          },
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          color: context.colorScheme.surface,
          alignment: Alignment.centerLeft,
          height: height,
          child: _buildFindInputView(context),
        ),
      ),
    );
  }

  Widget _buildFindInputView(BuildContext context) {
    final hasMatches = controller.matchCount > 0;
    final String result;
    if (!hasMatches) {
      result = context.appLocalizations.none;
    } else {
      result = '${controller.currentMatchIndex + 1}/${controller.matchCount}';
    }
    final bar = CommonMinIconButtonTheme(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMobileView) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _buildFindInput(context),
            ),
            const SizedBox(width: 12),
          ],
          Text(result, style: context.textTheme.bodyMedium),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 2,
              children: [
                _buildIconButton(
                  onPressed: hasMatches ? controller.previous : null,
                  icon: const GlyphIcon(AppGlyphs.arrowUp, size: 16),
                  tooltip: context.appLocalizations.previousMatch,
                ),
                _buildIconButton(
                  onPressed: hasMatches ? controller.next : null,
                  icon: const GlyphIcon(AppGlyphs.arrowDown, size: 16),
                  tooltip: context.appLocalizations.nextMatch,
                ),
                if (!readOnly)
                  _buildIconButton(
                    onPressed: controller.toggleReplaceMode,
                    icon: const GlyphIcon(AppGlyphs.findReplace, size: 16),
                    tooltip: context.appLocalizations.replace,
                    isSelected: _showReplace,
                  ),
                const SizedBox(width: 2),
                ElasticButton(
                  child: IconButton.filledTonal(
                    tooltip: context.appLocalizations.close,
                    onPressed: _close,
                    icon: const GlyphIcon(AppGlyphs.close, size: 16, fill: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    final replaceInput = _buildReplaceInput(context, hasMatches);
    if (isMobileView) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          bar,
          const SizedBox(height: 12),
          _buildFindInput(context),
          if (_showReplace) ...[const SizedBox(height: 12), replaceInput],
        ],
      );
    }
    if (!_showReplace) {
      return bar;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        bar,
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: replaceInput,
          ),
        ),
      ],
    );
  }

  Widget _buildFindInput(BuildContext context) {
    return _buildInputRow(
      field: _buildTextField(
        context: context,
        onSubmitted: () {
          if (controller.matchCount == 0) {
            return;
          }
          controller.next();
          controller.findInputFocusNode.requestFocus();
        },
        controller: controller.findInputController,
        focusNode: controller.findInputFocusNode,
      ),
      actions: [
        _buildIconButton(
          icon: Text('Aa', style: context.textTheme.bodySmall),
          isSelected: controller.caseSensitive,
          onPressed: controller.toggleCaseSensitive,
        ),
        _buildIconButton(
          icon: Text('.*', style: context.textTheme.bodySmall),
          isSelected: controller.isRegex,
          onPressed: controller.toggleRegex,
        ),
      ],
    );
  }

  Widget _buildReplaceInput(BuildContext context, bool hasMatches) {
    return _buildInputRow(
      field: _buildTextField(
        context: context,
        onSubmitted: () {
          if (controller.matchCount == 0) {
            return;
          }
          controller.replace();
          controller.replaceInputFocusNode.requestFocus();
        },
        controller: controller.replaceInputController,
        focusNode: controller.replaceInputFocusNode,
      ),
      actions: [
        _buildIconButton(
          onPressed: hasMatches ? controller.replace : null,
          icon: const GlyphIcon(AppGlyphs.check, size: 16),
          tooltip: context.appLocalizations.replace,
        ),
        _buildIconButton(
          onPressed: hasMatches ? controller.replaceAll : null,
          icon: const GlyphIcon(AppGlyphs.checkDouble, size: 16),
          tooltip: context.appLocalizations.replaceAll,
        ),
      ],
    );
  }

  Widget _buildInputRow({
    required Widget field,
    required List<Widget> actions,
  }) {
    return CommonMinIconButtonTheme(
      child: Row(
        spacing: 8,
        children: [
          Flexible(child: field),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onSubmitted,
  }) {
    return SizedBox(
      height: globalState.measure.bodyMediumHeight + 8 * 2,
      child: TextField(
        maxLines: 1,
        focusNode: focusNode,
        inputFormatters: TextInputLimits.limit(TextInputLimits.search),
        style: context.textTheme.bodyMedium,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
        onSubmitted: (_) {
          onSubmitted();
        },
        controller: controller,
      ),
    );
  }

  Widget _buildIconButton({
    required Widget icon,
    String? tooltip,
    VoidCallback? onPressed,
    bool isSelected = false,
  }) {
    if (isSelected) {
      return ElasticButton(
        enabled: onPressed != null,
        child: IconButton.filledTonal(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: IconTheme.merge(
            data: const IconThemeData(fill: 1),
            child: icon,
          ),
        ),
      );
    }
    return IconButton(tooltip: tooltip, onPressed: onPressed, icon: icon);
  }
}

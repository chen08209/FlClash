import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/editor/editor.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_forge/code_forge.dart'
    show
        CodeForge,
        CodeForgeContextMenuRequest,
        CodeForgeCompletionSource,
        CodeForgeController,
        CodeForgeKeyboardShortcuts,
        CodeSelectionStyle,
        FindController,
        UndoRedoController;
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:rust_api/rust_api.dart' show isRustLibInitialized;

export 'package:fl_clash/features/editor/editor.dart' show EditorSchema;

void _requireRustLib() {
  if (!isRustLibInitialized) {
    throw StateError('RustLib is not initialized');
  }
}

/// [load] runs after the route settles; read files in it via [readTextFileTask].
class EditorPage extends ConsumerStatefulWidget {
  final String title;
  final String? content;
  final Future<String> Function()? load;
  final Language language;
  final bool titleEditable;

  /// A returned future is the save still running: until it completes the
  /// page takes no second save and no pointer.
  final FutureOr<void> Function(
    BuildContext context,
    String title,
    String content,
  )?
  onSave;
  final Future<bool> Function(
    BuildContext context,
    String title,
    String content,
  )?
  onPop;
  final bool? readOnly;
  final EditorSchema schema;

  const EditorPage({
    super.key,
    required this.title,
    this.content,
    this.load,
    this.titleEditable = false,
    this.onSave,
    this.onPop,
    this.readOnly,
    this.language = Language.yaml,
    this.schema = EditorSchema.config,
  }) : assert(content == null || load == null);

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _editorKey = GlobalKey<EditorViewState>();
  late UndoRedoController _undoController;
  late TextEditingController _titleController;
  late bool readOnly = false;
  String? _loaded;
  bool _loadStarted = false, _saving = false;
  ({bool isDirty, bool canUndo, bool canRedo}) _barState = (
    isDirty: false,
    canUndo: false,
    canRedo: false,
  );

  EditorViewState? get _editor => _editorKey.currentState;

  String? get _original {
    if (widget.load != null) {
      return _loaded;
    }
    final content = widget.content;
    return content == null
        ? null
        : CodeForgeController.normalizeLineBreaks(content);
  }

  String get _content => _editor?.content ?? _original ?? '';

  CodeForgeKeyboardShortcuts get _shortcuts =>
      CodeForgeKeyboardShortcuts.forPlatform(defaultTargetPlatform);

  SingleActivator get _saveShortcut => switch (defaultTargetPlatform) {
    TargetPlatform.macOS || TargetPlatform.iOS => const SingleActivator(
      LogicalKeyboardKey.keyS,
      meta: true,
      includeRepeats: false,
    ),
    _ => const SingleActivator(
      LogicalKeyboardKey.keyS,
      control: true,
      includeRepeats: false,
    ),
  };

  bool get _isDirty =>
      _original != null &&
      ((_editor?.isModified ?? false) || _titleController.text != widget.title);

  @override
  void initState() {
    super.initState();
    readOnly = widget.readOnly ?? widget.onSave == null;
    _undoController = UndoRedoController()..addListener(_syncBarState);
    _titleController = TextEditingController(text: widget.title)
      ..addListener(_syncBarState);
  }

  ({bool isDirty, bool canUndo, bool canRedo}) get _currentBarState => (
    isDirty: _isDirty,
    canUndo:
        _undoController.canUndo ||
        (_editor?.controller?.isComposingActive ?? false),
    canRedo: _undoController.canRedo,
  );

  void _syncBarState() {
    final next = _currentBarState;
    if (next != _barState) {
      setState(() => _barState = next);
    }
  }

  void _handleReady() {
    _editor?.controller?.addListener(_syncBarState);
    setState(() => _barState = _currentBarState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final load = widget.load;
    if (load == null || _loadStarted) {
      return;
    }
    _loadStarted = true;
    unawaited(_load(load));
  }

  Future<void> _load(Future<String> Function() load) async {
    await whenRouteSettled(context);
    if (!mounted) {
      return;
    }
    final content = await globalState.safeRun(() async {
      try {
        return await load();
      } catch (_) {
        if (!mounted) return null;
        rethrow;
      }
    }, silence: false);
    if (!mounted) {
      return;
    }
    if (content == null) {
      // The error dialog is on top, so pop() would close it instead.
      final route = ModalRoute.of(context);
      if (route != null) {
        Navigator.of(context).removeRoute(route);
      }
      return;
    }
    setState(() {
      _loaded = CodeForgeController.normalizeLineBreaks(content);
      _barState = _currentBarState;
    });
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

  void _commitComposing() {
    _editor?.controller?.commitComposition();
  }

  void _handleSave() {
    final onSave = widget.onSave;
    if (onSave == null || readOnly || _saving) {
      return;
    }
    _commitComposing();
    if (!_isDirty) {
      return;
    }
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      Navigator.of(context).popUntil((above) => above == route);
    }
    final saved = onSave(context, _titleController.text, _content);
    if (saved is! Future<void>) {
      return;
    }
    setState(() => _saving = true);
    unawaited(
      saved.whenComplete(() {
        if (mounted) setState(() => _saving = false);
      }),
    );
  }

  Future<bool> _handlePop(BuildContext context) async {
    final onPop = widget.onPop;
    _commitComposing();
    if (onPop == null || !_isDirty) {
      return true;
    }
    final res = await onPop(context, _titleController.text, _content);
    return res && context.mounted;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final isReady = _editor?.controller != null;
    final lineWrap = ref.watch(
      appSettingProvider.select((state) => state.editorLineWrap),
    );
    final fontSize = ref.watch(
      appSettingProvider.select((state) => state.editorFontSize),
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
            titleWidget: _EditorTitleField(
              controller: _titleController,
              enabled: widget.titleEditable,
            ),
            iconActions: [
              IconButtonData(
                glyph: AppGlyphs.search,
                tooltip: appLocalizations.search,
                onPressed: isReady ? _handleSearch : null,
              ),
              if (widget.onSave != null)
                IconButtonData(
                  glyph: AppGlyphs.check,
                  tooltip: appLocalizations.save,
                  onPressed: _barState.isDirty && !_saving ? _handleSave : null,
                ),
            ],
            menuItems: [
              CommonPopupMenuItem(
                glyph: AppGlyphs.undo,
                label: appLocalizations.undo,
                onPressed: _barState.canUndo ? _undoController.undo : null,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.redo,
                label: appLocalizations.redo,
                onPressed: _barState.canRedo ? _undoController.redo : null,
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.textSize,
                label: appLocalizations.fontSize,
                subItems: [
                  for (final size in EditorFontSize.values)
                    CommonPopupMenuItem(
                      label: switch (size) {
                        EditorFontSize.standard => appLocalizations.standard,
                        EditorFontSize.large => appLocalizations.large,
                        EditorFontSize.extraLarge =>
                          appLocalizations.extraLarge,
                      },
                      checked: size == fontSize,
                      onPressed: () => ref
                          .read(appSettingProvider.notifier)
                          .update(
                            (state) => state.copyWith(editorFontSize: size),
                          ),
                    ),
                ],
              ),
              CommonPopupMenuItem(
                glyph: AppGlyphs.wrap,
                label: appLocalizations.lineWrap,
                checked: lineWrap,
                onPressed: () => ref
                    .read(appSettingProvider.notifier)
                    .update(
                      (state) => state.copyWith(editorLineWrap: !lineWrap),
                    ),
              ),
            ],
            body: AbsorbPointer(
              absorbing: _saving,
              child: EditorView(
                key: _editorKey,
                content: _original,
                language: widget.language,
                schema: widget.schema,
                readOnly: readOnly,
                undoController: _undoController,
                onReady: _handleReady,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The code editor without page chrome, so it can fill a page or one pane
/// of it. The editor mounts after the enclosing route has settled and shows
/// its unavailable state when `main` did not initialise `RustLib`.
class EditorView extends ConsumerStatefulWidget {
  final String? content;
  final Language language;
  final EditorSchema schema;
  final bool readOnly;
  final UndoRedoController? undoController;
  final VoidCallback? onReady;

  const EditorView({
    super.key,
    required this.content,
    this.language = Language.yaml,
    this.schema = EditorSchema.config,
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
  String? _pendingContent;
  bool _canCreateController = false;
  bool _routeWaitStarted = false;

  CodeForgeController? get controller => _controller;

  String get content => _controller?.text ?? _pendingContent ?? '';

  int _loadedLength = 0;

  /// Whether the document differs from [EditorView.content]. A length change
  /// answers without copying the whole document out of the rope.
  bool get isModified {
    final controller = _controller;
    final original = widget.content;
    if (controller == null || original == null) {
      return false;
    }
    return controller.isComposingActive ||
        controller.length != _loadedLength ||
        controller.text != original;
  }

  UndoRedoController get _undoController =>
      widget.undoController ?? (_ownedUndoController ??= UndoRedoController());

  @override
  void initState() {
    super.initState();
    _pendingContent = widget.content;
  }

  // Loading or mounting CodeForge mid-transition drops frames, so both wait.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeWaitStarted) {
      return;
    }
    _routeWaitStarted = true;
    whenRouteSettled(context)
        .then((_) => _requireRustLib())
        .then(
          (_) {
            if (!mounted) {
              return;
            }
            _canCreateController = true;
            _createController();
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

  // Filling the controller before CodeForge mounts spares it laying out an
  // empty document only to replace it.
  void _createController() {
    final content = _pendingContent;
    if (!_canCreateController || _controller != null || content == null) {
      return;
    }
    final controller = CodeForgeController();
    _loadContent(controller, content);
    setState(() {
      _controller = controller;
      _findController = FindController(controller);
    });
    widget.onReady?.call();
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
        _pendingContent = content;
        _createController();
        return;
      }
      _loadContent(controller, content);
      _undoController.clear();
    });
  }

  @override
  void dispose() {
    _findController?.dispose();
    _controller?.dispose();
    _ownedUndoController?.dispose();
    super.dispose();
  }

  void _loadContent(CodeForgeController controller, String content) {
    controller
      ..text = content
      ..selection = const TextSelection.collapsed(offset: 0);
    _loadedLength = controller.length;
  }

  void search({bool replace = false}) {
    _findController?.show(replace: replace && !widget.readOnly);
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
      schema: widget.schema,
      error: _initError,
      isLoading:
          _initError == null && (widget.content == null || controller == null),
    );
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

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.controller,
    required this.findController,
    required this.undoController,
    required this.readOnly,
    required this.language,
    required this.schema,
    required this.error,
    required this.isLoading,
  });

  final CodeForgeController? controller;
  final FindController? findController;
  final UndoRedoController undoController;
  final bool readOnly;
  final Language language;
  final EditorSchema schema;
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
            schema: schema,
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
    required this.schema,
  });

  final CodeForgeController controller;
  final FindController findController;
  final UndoRedoController undoController;
  final bool readOnly;
  final Language language;
  final EditorSchema schema;

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
  TextStyle? _lineNumberStyle;
  EdgeInsets _innerPadding = const EdgeInsets.only(right: 16);
  late bool _findActive = widget.findController.isActive;
  late CodeForgeCompletionSource? _completionSource = editorCompletionSource(
    widget.language,
    widget.schema,
  );

  @override
  void initState() {
    super.initState();
    widget.findController.addListener(_handleFindChanged);
  }

  @override
  void didUpdateWidget(covariant _CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.findController != widget.findController) {
      oldWidget.findController.removeListener(_handleFindChanged);
      widget.findController.addListener(_handleFindChanged);
      _handleFindChanged();
    }
    if (oldWidget.language != widget.language ||
        oldWidget.schema != widget.schema) {
      _completionSource = editorCompletionSource(
        widget.language,
        widget.schema,
      );
    }
  }

  @override
  void dispose() {
    widget.findController.removeListener(_handleFindChanged);
    super.dispose();
  }

  void _handleFindChanged() {
    final isActive = widget.findController.isActive;
    if (isActive != _findActive) {
      setState(() {
        _findActive = isActive;
      });
    }
  }

  // The bar floats over the text, which scrolls under it from a first line
  // held clear of it; an open find panel takes that clearance instead.
  void _updateInnerPadding(BuildContext context) {
    final top = _findActive ? 0.0 : context.appBarInset;
    if (top != _innerPadding.top) {
      _innerPadding = EdgeInsets.only(top: top, right: 16);
    }
  }

  void _updateStyles(BuildContext context, EditorFontSize fontSize) {
    final colorScheme = context.colorScheme;
    final schemeChanged = colorScheme != _colorScheme;
    if (schemeChanged) {
      _colorScheme = colorScheme;
      _editorTheme = _highlightTheme(colorScheme, widget.language);
      _selectionStyle = CodeSelectionStyle(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.opacity30,
        cursorBubbleColor: colorScheme.primary,
      );
    }
    final textStyle = TextStyle(
      fontSize: fontSize.value,
      fontFamily: FontFamily.jetBrainsMono.value,
    );
    if (textStyle != _textStyle) {
      _textStyle = textStyle;
    }
    final appFont = context.textTheme.bodySmall;
    _lineNumberStyle = TextStyle(
      fontSize: 12,
      fontFamily: appFont?.fontFamily,
      fontFamilyFallback: appFont?.fontFamilyFallback,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  void _showClipboardWriteFailed() {
    if (!mounted) {
      return;
    }
    dialogs.showNotifier(
      context.appLocalizations.clipboardWriteFailed,
      level: MessageLevel.error,
    );
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
    final selectionRect = request.selectionRect;
    final route = CommonPopupRoute<void>(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      placement: PopupPlacement.belowPoint,
      modal: false,
      anchorOf: () => point & Size.zero,
      avoid: system.isDesktop || selectionRect == null
          ? null
          : Rect.fromPoints(
              navigatorBox.globalToLocal(selectionRect.topLeft),
              navigatorBox.globalToLocal(selectionRect.bottomRight),
            ),
      builder: (_) => CommonPopupMenu(items: items),
    );
    final controller = widget.controller;
    final selection = controller.selection;
    final version = controller.contentVersion;
    final composition = controller.imeComposition;
    final focusNode = controller.focusNode;
    final hadFocus = focusNode?.hasFocus ?? false;
    // Typing or a focus change reaches the editor with no pointer down.
    void closeOnceOutdated() {
      final outdated =
          controller.selection != selection ||
          controller.contentVersion != version ||
          controller.imeComposition != composition ||
          hadFocus && !focusNode!.hasFocus;
      if (outdated && route.isCurrent) navigator.pop();
    }

    controller.addListener(closeOnceOutdated);
    focusNode?.addListener(closeOnceOutdated);
    navigator.push(route).whenComplete(() {
      controller.removeListener(closeOnceOutdated);
      focusNode?.removeListener(closeOnceOutdated);
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateStyles(
      context,
      ref.watch(appSettingProvider.select((state) => state.editorFontSize)),
    );
    _updateInnerPadding(context);
    final isMobileView = ref.watch(isMobileViewProvider);
    final lineWrap = ref.watch(
      appSettingProvider.select((state) => state.editorLineWrap),
    );
    widget.controller
      ..enableLocalSuggestions = !widget.readOnly
      ..completionSource = widget.readOnly ? null : _completionSource
      ..onClipboardWriteFailed = _showClipboardWriteFailed;
    return CodeForge(
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
      suggestionPopupBuilder: (_, details) => CustomSingleChildLayout(
        delegate: CaretPopupLayout(
          caretRect: details.caretRect,
          padding: EdgeInsets.only(top: _innerPadding.top),
        ),
        child: EditorCompletionPopup(details: details, textStyle: _textStyle!),
      ),
      magnifierBuilder: (context, controller, magnifierInfo) => TextLoupe(
        controller: controller,
        magnifierInfo: magnifierInfo,
        borderColor: context.colorScheme.primary,
      ),
      textStyle: _textStyle,
      lineWrap: lineWrap,
      lineNumberStyle: _lineNumberStyle,
      innerPadding: _innerPadding,
      onContextMenu: _showContextMenu,
      scrollbarBuilder: (context, details, child) => FloatingScrollbar(
        controller: details.controller,
        thumbVisibility: true,
        hintBuilder: (_) =>
            '${details.firstVisibleLine.value} / ${widget.controller.lineCount}',
        child: _NoMouseDragScroll(child: child),
      ),
      finderBuilder: (context, findController) => FindPanel(
        controller: findController,
        topInset: context.appBarInset,
        readOnly: widget.readOnly,
        isMobileView: isMobileView,
      ),
    );
  }
}

// The app's desktop behavior would also pan the view on a mouse drag-select.
class _NoMouseDragScroll extends StatelessWidget {
  const _NoMouseDragScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: {...behavior.dragDevices}..remove(PointerDeviceKind.mouse),
      ),
      child: child,
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
  final double topInset;

  const FindPanel({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.isMobileView,
    this.topInset = 0,
  });

  bool get _showReplace => controller.isReplaceMode && !readOnly;

  double get height {
    final rows = (isMobileView ? 2 : 1) + (_showReplace ? 1 : 0);
    return _kDefaultFindPanelHeight * rows + 8;
  }

  @override
  Size get preferredSize => Size(double.infinity, height + topInset);

  @override
  Widget build(BuildContext context) {
    // On macOS a focused text field hands Escape to the input method, which
    // comes back as a DismissIntent rather than a key event.
    return Actions(
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (_) => controller.hide(),
        ),
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): controller.hide,
          const SingleActivator(LogicalKeyboardKey.enter, shift: true):
              controller.previous,
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          margin: EdgeInsets.only(top: topInset, bottom: 8),
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
                    onPressed: controller.hide,
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

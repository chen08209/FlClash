import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:rust_api/editor.dart';

import '../code_forge.dart';
import 'text_offsets.dart';
import 'view_line_layout.dart';
import 'word_chars.dart';

part 'code_area/editor_state.dart';
part 'code_area/editor_state_keyboard.dart';
part 'code_area/editor_state_overlays.dart';
part 'code_area/renderer.dart';
part 'code_area/renderer_layout.dart';
part 'code_area/renderer_folding.dart';
part 'code_area/renderer_caret.dart';
part 'code_area/renderer_gutter.dart';
part 'code_area/renderer_highlights.dart';

const int kExactWrappedHeightThreshold = 512;
const int kWrappedHeightSampleSize = 64;

/// FlClash's code editor, with syntax highlighting, code folding, a line
/// number gutter, auto-indentation, bracket pairing, undo/redo, word
/// completion and search.
class CodeForge extends StatefulWidget {
  /// The controller for managing the editor's text content and selection.
  final CodeForgeController controller;

  /// The finder controller for managing search functionality.
  ///
  /// If not provided, an internal finder controller will be created.
  final FindController? findController;

  /// The controller for managing undo/redo operations.
  final UndoRedoController? undoController;

  /// The syntax highlighting theme as a map of token types to [TextStyle].
  final Map<String, TextStyle> editorTheme;

  /// The programming language mode for syntax highlighting.
  ///
  /// Determines which language syntax rules to apply.
  final Mode language;

  /// The base text style for the editor content.
  ///
  /// Defines the font family, size, and other text properties.
  final TextStyle? textStyle;

  /// Padding inside the editor content area.
  final EdgeInsets? innerPadding;

  /// Styling options for text selection and cursor.
  final CodeSelectionStyle? selectionStyle;

  /// Whether the editor is in read-only mode.
  ///
  /// When true, the user cannot modify the text content.
  final bool readOnly;

  /// Whether to wrap long lines.
  ///
  /// When true, lines wrap at the editor boundary. When false,
  /// horizontal scrolling is enabled.
  final bool lineWrap;

  /// Custom tabSize for the editor.
  /// Defaults to 1 if using `\t`,
  /// or 2 if using space, by setting the [useSpaceAsTab] to `true`
  final int? tabSize;

  /// Use space instead of the `\t` character for tab key press.
  final bool useSpaceAsTab;

  /// Builder for a custom Finder widget.
  ///
  /// This builder is called to create the finder/search widget. It provides
  /// the [FindController] which can be used to control search functionality.
  /// The returned widget should implement [PreferredSizeWidget].
  final PreferredSizeWidget Function(
    BuildContext context,
    FindController findController,
  )?
  finderBuilder;

  final void Function(BuildContext context, CodeForgeContextMenuRequest request)
  onContextMenu;

  final Widget Function(
    BuildContext context,
    CodeForgeScrollbarDetails details,
    Widget child,
  )
  scrollbarBuilder;

  /// The popup is laid over the whole editor and positions itself against
  /// [CodeForgeSuggestionDetails.caretRect]; it is not built while the caret
  /// is scrolled out of view. The editor keeps the arrow keys, Enter, Tab and
  /// Escape.
  final Widget Function(
    BuildContext context,
    CodeForgeSuggestionDetails details,
  )
  suggestionPopupBuilder;

  /// Builds the loupe shown while a touch drags the caret, a selection handle
  /// or a selection. The editor shows it in the root overlay, feeds it the
  /// caret's [MagnifierInfo] in global coordinates and hides it through the
  /// controller when the drag ends. No loupe is shown when null.
  final MagnifierBuilder? magnifierBuilder;

  final int _tabSize;

  /// Creates a [CodeForge] code editor widget.
  const CodeForge({
    super.key,
    required this.controller,
    required this.editorTheme,
    required this.language,
    required this.onContextMenu,
    required this.scrollbarBuilder,
    required this.suggestionPopupBuilder,
    this.undoController,
    this.findController,
    this.textStyle,
    this.innerPadding,
    this.readOnly = false,
    this.lineWrap = false,
    this.tabSize,
    this.useSpaceAsTab = false,
    this.selectionStyle,
    this.finderBuilder,
    this.magnifierBuilder,
  }) : _tabSize = tabSize ?? (useSpaceAsTab ? 2 : 1);

  @override
  State<CodeForge> createState() => _CodeForgeState();
}

class _CodeField extends LeafRenderObjectWidget {
  final CodeForgeController controller;
  final Map<String, TextStyle> editorTheme;
  final Mode language;
  final EdgeInsets? innerPadding;
  final ScrollController vscrollController, hscrollController;
  final FocusNode focusNode;
  final bool readOnly, isMobile, lineWrap;
  final AnimationController caretBlinkController;
  final AnimationController lineHighlightController;
  final TextStyle? textStyle;
  final GutterStyle gutterStyle;
  final CodeSelectionStyle selectionStyle;
  final ValueNotifier<bool> selectionActiveNotifier;
  final ValueNotifier<Rect?> caretRectNotifier;
  final ValueChanged<Offset> onContextMenuRequest;
  final ValueNotifier<List<CodeForgeSuggestion>?> suggestionNotifier;
  final ValueNotifier<MagnifierInfo?> magnifierNotifier;

  const _CodeField({
    super.key,
    required this.controller,
    required this.editorTheme,
    required this.language,
    required this.vscrollController,
    required this.hscrollController,
    required this.focusNode,
    required this.readOnly,
    required this.caretBlinkController,
    required this.lineHighlightController,
    required this.gutterStyle,
    required this.selectionStyle,
    required this.isMobile,
    required this.selectionActiveNotifier,
    required this.onContextMenuRequest,
    required this.caretRectNotifier,
    required this.suggestionNotifier,
    required this.magnifierNotifier,
    required this.lineWrap,
    this.textStyle,
    this.innerPadding,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CodeFieldRenderer(
      controller: controller,
      editorTheme: editorTheme,
      language: language,
      innerPadding: innerPadding,
      vscrollController: vscrollController,
      hscrollController: hscrollController,
      focusNode: focusNode,
      readOnly: readOnly,
      caretBlinkController: caretBlinkController,
      lineHighlightController: lineHighlightController,
      textStyle: textStyle,
      gutterStyle: gutterStyle,
      selectionStyle: selectionStyle,
      isMobile: isMobile,
      selectionActiveNotifier: selectionActiveNotifier,
      onContextMenuRequest: onContextMenuRequest,
      lineWrap: lineWrap,
      caretRectNotifier: caretRectNotifier,
      suggestionNotifier: suggestionNotifier,
      magnifierNotifier: magnifierNotifier,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _CodeFieldRenderer renderObject,
  ) {
    renderObject
      ..editorTheme = editorTheme
      ..language = language
      ..textStyle = textStyle
      ..innerPadding = innerPadding
      ..readOnly = readOnly
      ..lineWrap = lineWrap
      ..gutterStyle = gutterStyle
      ..selectionStyle = selectionStyle;
  }
}

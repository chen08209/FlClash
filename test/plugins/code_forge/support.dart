import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;
import 'package:flutter_test/flutter_test.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:rust_api/rust_api.dart' show RustLib;

const _libraryStem = 'rust_api';

String get _libraryFile {
  if (Platform.isWindows) return '$_libraryStem.dll';
  if (Platform.isMacOS) return 'lib$_libraryStem.dylib';
  return 'lib$_libraryStem.so';
}

// `flutter test` runs the build hooks and copies their output to
// build/native_assets/<os>/; other flutter commands leave it in .dart_tool/lib.
List<String> get _libraryCandidates => [
  'build/native_assets/${Platform.operatingSystem}/$_libraryFile',
  '.dart_tool/lib/$_libraryFile',
];

Future<void>? _nativeInit;

Future<void> initEditorNative() => _nativeInit ??= () async {
  final overrideDir =
      Platform.environment['FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR'];
  if (overrideDir != null) return RustLib.init();
  final path = _libraryCandidates.firstWhere(
    (path) => File(path).existsSync(),
    orElse: () => throw StateError(
      'Editor native library not found; tried ${_libraryCandidates.join(', ')}'
      ' from ${Directory.current.path}. Keep the rust_api build_assets'
      ' user-define on, or set FRB_DART_LOAD_EXTERNAL_LIBRARY_NATIVE_LIB_DIR'
      ' to a directory holding the library.',
    ),
  );
  await RustLib.init(
    externalLibrary: ExternalLibrary.open(File(path).absolute.path),
  );
}();

Future<void> settle(WidgetTester tester, [int rounds = 6]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

const editorLineHeight = 20.0;
const editorTopPadding = 8.0;

Future<void> pumpEditor(
  WidgetTester tester,
  CodeForgeController controller, {
  UndoRedoController? undoController,
  FindController? findController,
  bool lineWrap = false,
  bool readOnly = false,
  bool enableLocalSuggestions = false,
  Widget Function(BuildContext, CodeForgeSuggestionDetails)?
  suggestionPopupBuilder,
  Widget Function(BuildContext, CodeForgeScrollbarDetails, Widget)?
  scrollbarBuilder,
  PreferredSizeWidget Function(BuildContext, FindController)? finderBuilder,
  void Function(BuildContext, CodeForgeContextMenuRequest)? onContextMenu,
  Widget Function(Widget editor)? wrap,
  Key? key,
  Map<String, TextStyle> editorTheme = atomOneLightTheme,
  CodeSelectionStyle? selectionStyle,
  Size size = const Size(400, 600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  controller.enableLocalSuggestions = enableLocalSuggestions;
  final editor = CodeForge(
    key: key,
    controller: controller,
    undoController: undoController,
    findController: findController,
    language: langYaml,
    editorTheme: editorTheme,
    selectionStyle: selectionStyle,
    textStyle: const TextStyle(fontSize: 16, height: editorLineHeight / 16),
    innerPadding: const EdgeInsets.only(top: editorTopPadding),
    lineWrap: lineWrap,
    readOnly: readOnly,
    onContextMenu: onContextMenu ?? (_, _) {},
    suggestionPopupBuilder:
        suggestionPopupBuilder ?? (_, _) => const SizedBox.shrink(),
    scrollbarBuilder: scrollbarBuilder ?? (_, _, child) => child,
    finderBuilder: finderBuilder,
  );
  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: wrap?.call(editor) ?? editor)),
  );
  await settle(tester);
}

Map<String, Object> textDelta(String oldText, String text, int start, int end) {
  final caret = start + text.length;
  return {
    'oldText': oldText,
    'deltaText': text,
    'deltaStart': start,
    'deltaEnd': end,
    'selectionBase': caret,
    'selectionExtent': caret,
    'selectionAffinity': 'TextAffinity.downstream',
    'selectionIsDirectional': false,
    'composingBase': -1,
    'composingExtent': -1,
  };
}

// Delivers [deltas] as one batch on the connection the focused editor opened.
Future<void> sendDeltas(
  WidgetTester tester,
  List<Map<String, Object>> deltas,
) async {
  final setClient = tester.testTextInput.log.lastWhere(
    (call) => call.method == 'TextInput.setClient',
    orElse: () => throw StateError('The editor opened no input connection'),
  );
  final client = (setClient.arguments as List)[0] as int;
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.textInput.name,
    SystemChannels.textInput.codec.encodeMethodCall(
      MethodCall('TextInputClient.updateEditingStateWithDeltas', [
        client,
        {'deltas': deltas},
      ]),
    ),
    (_) {},
  );
  await tester.pump();
}

Future<void> typeText(
  WidgetTester tester,
  CodeForgeController controller,
  String text,
) async {
  for (final char in text.split('')) {
    final value = controller.currentTextEditingValue ?? TextEditingValue.empty;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    await sendDeltas(tester, [
      textDelta(value.text, char, selection.start, selection.end),
    ]);
  }
  await settle(tester, 2);
}

String visibleText(CodeForgeController controller) => [
  for (var line = 0; line < controller.lineCount; line++)
    if (!controller.isLineInFoldedRegion(line)) controller.getLineText(line),
].join('\n');

Future<void> focusEditor(WidgetTester tester) async {
  await tester.tapAt(
    tester.getTopRight(find.byType(CodeForge)) + const Offset(-8, 4),
  );
  await settle(tester, 2);
}

class MockClipboard {
  String? text;
}

MockClipboard mockClipboard(WidgetTester tester) {
  final clipboard = MockClipboard();
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    switch (call.method) {
      case 'Clipboard.setData':
        clipboard.text = (call.arguments as Map)['text'] as String;
      case 'Clipboard.getData':
        return {'text': clipboard.text};
    }
    return null;
  });
  addTearDown(
    () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
  );
  return clipboard;
}

import 'package:code_forge/code_forge.dart' show CodeForgeCompletionSource;
import 'package:fl_clash/enum/enum.dart';

import 'clash_completion.dart';
import 'clash_schema.dart';
import 'script_completion.dart';

CodeForgeCompletionSource? editorCompletionSource(
  Language language,
  EditorSchema schema,
) => switch (language) {
  Language.yaml => ClashCompletionSource(schema.root).call,
  Language.javaScript => ScriptCompletionSource().call,
  Language.json => null,
};

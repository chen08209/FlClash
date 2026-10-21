import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

IconButtonData customQuickEditAction(
  BuildContext context, {
  required VoidCallback onPressed,
}) {
  return IconButtonData(
    glyph: AppGlyphs.compose,
    onPressed: onPressed,
    tooltip: context.appLocalizations.quickEdit,
  );
}

IconButtonData customSaveAction(
  BuildContext context, {
  required VoidCallback onPressed,
}) {
  return IconButtonData(
    glyph: AppGlyphs.check,
    onPressed: onPressed,
    tooltip: context.appLocalizations.save,
  );
}

/// Thrown by an `apply` the user called off, which keeps the editor open.
class QuickEditCancelled implements Exception {
  const QuickEditCancelled();
}

/// Edits a list as text; a [FormatException] from [apply] reads as
/// [invalidMessage].
Future<void> showCustomQuickEdit(
  BuildContext context, {
  required String title,
  required String content,
  required EditorSchema schema,
  required String invalidMessage,
  required FutureOr<void> Function(String content) apply,
}) {
  final page = EditorPage(
    title: title,
    content: content,
    readOnly: false,
    schema: schema,
    onPop: (_, _, edited) async {
      final next = await edited.readText();
      if (next == content) {
        return true;
      }
      try {
        await apply(next);
        return true;
      } on QuickEditCancelled {
        return false;
      } catch (error) {
        final message = error is FormatException
            ? invalidMessage
            : compactError(error);
        final res = await dialogs.showMessage(
          message: TextSpan(
            text: '$message\n\n${currentAppLocalizations.discardChanges}',
          ),
          destructive: true,
        );
        return res == true;
      }
    },
  );
  return sheetNavigatorOf(context).push(
    context.isMobileView
        ? CommonRoute(builder: (_) => page)
        : CommonDesktopRoute(builder: (_) => page),
  );
}

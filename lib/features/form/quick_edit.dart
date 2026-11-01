import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:flutter/widgets.dart';

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
Future<void> showQuickEdit(
  BuildContext context, {
  required String title,
  required String content,
  Language language = Language.yaml,
  EditorSchema schema = EditorSchema.config,
  String? invalidMessage,
  required FutureOr<void> Function(String content) apply,
}) {
  final page = EditorPage(
    title: title,
    content: content,
    readOnly: false,
    language: language,
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
        final message = error is FormatException && invalidMessage != null
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
        ? CardPageRoute(builder: (_) => page)
        : FadePageRoute(builder: (_) => page),
  );
}

void _throwIssues<T>(
  ParsedInput<T> parsed,
  String Function(InputIssue issue) messageOf,
) {
  if (parsed.isValid) {
    return;
  }
  throw MessageException(
    parsed.issues
        .take(BatchInput.maxShownIssues)
        .map(
          (issue) => currentAppLocalizations.lineIssueTip(
            issue.line,
            messageOf(issue),
          ),
        )
        .join('\n'),
  );
}

/// One item a line.
Future<void> showListQuickEdit(
  BuildContext context, {
  required String title,
  required List<String> items,
  int? itemMaxLength,
  String? Function(String item)? itemValidator,
  required ValueChanged<List<String>> onChanged,
}) {
  return showQuickEdit(
    context,
    title: title,
    content: items.join('\n'),
    language: Language.text,
    apply: (content) {
      final appLocalizations = currentAppLocalizations;
      final parsed = parseListInput(
        content,
        maxLength: itemMaxLength,
        isValid: itemValidator == null
            ? null
            : (item) => itemValidator(item) == null,
      );
      _throwIssues(
        parsed,
        (issue) => switch (issue.kind) {
          InputIssueKind.invalidValue => itemValidator!(issue.raw)!,
          _ => appLocalizations.maxLengthTip(
            appLocalizations.value,
            itemMaxLength!,
          ),
        },
      );
      onChanged(parsed.entries);
    },
  );
}

/// One `key: value` a line. [reservedKeys] belong to other fields, so an
/// entry may not take one.
Future<void> showMapQuickEdit(
  BuildContext context, {
  required String title,
  required Iterable<MapEntry<String, String>> entries,
  int? keyMaxLength,
  int? valueMaxLength,
  bool ignoreKeyCase = false,
  Set<String> reservedKeys = const {},
  required ValueChanged<List<MapEntry<String, String>>> onChanged,
}) {
  return showQuickEdit(
    context,
    title: title,
    content: entries.map((entry) => '${entry.key}: ${entry.value}').join('\n'),
    language: Language.text,
    apply: (content) {
      final appLocalizations = currentAppLocalizations;
      final parsed = parseMapInput(
        content,
        keyMaxLength: keyMaxLength,
        valueMaxLength: valueMaxLength,
        ignoreKeyCase: ignoreKeyCase,
      );
      _throwIssues(
        parsed,
        (issue) => switch (issue.kind) {
          InputIssueKind.keyTooLong => appLocalizations.maxLengthTip(
            appLocalizations.key,
            keyMaxLength!,
          ),
          InputIssueKind.valueTooLong => appLocalizations.maxLengthTip(
            appLocalizations.value,
            valueMaxLength!,
          ),
          InputIssueKind.missingValue ||
          InputIssueKind.invalidUrl ||
          InputIssueKind.invalidValue => appLocalizations.emptyTip(
            appLocalizations.value,
          ),
        },
      );
      String fold(String key) => ignoreKeyCase ? key.toLowerCase() : key;
      final reserved = reservedKeys.map(fold).toSet();
      for (final entry in parsed.entries) {
        if (reserved.contains(fold(entry.key))) {
          throw MessageException(appLocalizations.existsTip(entry.key));
        }
      }
      onChanged(parsed.entries);
    },
  );
}

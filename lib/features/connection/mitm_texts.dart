import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

String httpMillisText(int milliseconds) {
  if (milliseconds < 1000) {
    return '$milliseconds ms';
  }
  return '${(milliseconds / 1000).toStringAsFixed(1)} s';
}

String exchangePathOf(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasAuthority) {
    return url;
  }
  final path = uri.path.isEmpty ? '/' : uri.path;
  return uri.hasQuery ? '$path?${uri.query}' : path;
}

String httpStatusText(int status, String reason) =>
    reason.isEmpty ? '$status' : '$status $reason';

Color? httpStatusColor(ColorScheme colorScheme, int status) => switch (status) {
  >= 400 => colorScheme.error,
  >= 200 && < 300 => colorScheme.success,
  _ => null,
};

TextSpan joinedSpan(List<(String text, Color? color)> parts) => TextSpan(
  children: [
    for (final (index, (text, color)) in parts.indexed) ...[
      if (index > 0) const TextSpan(text: ' · '),
      TextSpan(
        text: text,
        style: color == null ? null : TextStyle(color: color),
      ),
    ],
  ],
);

/// How a request ended, or that it has not: its status, then its error, or
/// that it is still in progress, or [finished].
List<(String, Color?)> outcomeParts(
  BuildContext context, {
  required int status,
  required String error,
  required bool pending,
  required List<String> finished,
  String reason = '',
}) {
  final colorScheme = context.colorScheme;
  return [
    if (status != 0)
      (httpStatusText(status, reason), httpStatusColor(colorScheme, status)),
    if (error.isNotEmpty)
      (error, colorScheme.error)
    else if (pending)
      (context.appLocalizations.inProgress, null)
    else
      for (final part in finished) (part, null),
  ];
}

String mitmActionLabel(AppLocalizations appLocalizations, String kind) =>
    switch (kind) {
      'url-rewrite' => appLocalizations.urlRewrite,
      'header-rewrite' => appLocalizations.headerRewrite,
      'body-rewrite' => appLocalizations.bodyRewrite,
      'request-body-mock' => appLocalizations.requestBodyMock,
      'map-local' => appLocalizations.mapLocal,
      'script' => appLocalizations.script,
      _ => kind,
    };

String? exchangeMark(
  AppLocalizations appLocalizations,
  MitmExchangeSummary exchange,
) {
  final (answer, answerKind) = switch (exchange.answer) {
    '' => (null, null),
    'reject' => (appLocalizations.httpAnswerReject, 'url-rewrite'),
    'redirect' => (appLocalizations.httpAnswerRedirect, 'url-rewrite'),
    'map-local' => (appLocalizations.mapLocal, 'map-local'),
    'script' => (appLocalizations.httpAnswerScript, 'script'),
    final other => (other, null),
  };
  final kinds = exchange.actionKinds;
  final label =
      answer ??
      (kinds.isEmpty ? null : mitmActionLabel(appLocalizations, kinds.first));
  if (label == null) {
    return null;
  }
  final others = answer == null
      ? kinds.length - 1
      : kinds.where((kind) => kind != answerKind).length;
  return others > 0 ? '$label +$others' : label;
}

/// A header rewrite's detail leads with its line's keyword, put in words here.
String mitmActionDetail(AppLocalizations appLocalizations, MitmAction action) {
  final detail = action.detail;
  final space = detail.indexOf(' ');
  if (action.kind != 'header-rewrite' || space < 0) {
    return detail;
  }
  final verb = switch (detail.substring(0, space)) {
    'header-add' => appLocalizations.add,
    'header-del' => appLocalizations.delete,
    'header-replace' => appLocalizations.replace,
    'header-replace-regex' ||
    'header-text-replace' => appLocalizations.regexReplace,
    _ => null,
  };
  return verb == null ? detail : '$verb ${detail.substring(space + 1)}';
}

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
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

Color? httpStatusColor(ColorScheme colorScheme, int status) =>
    switch (httpStatusTone(status)) {
      RecordTone.error => colorScheme.error,
      RecordTone.success => colorScheme.success,
      RecordTone.warning => colorScheme.warning,
      RecordTone.neutral => null,
    };

RecordTone httpStatusTone(int status) => switch (status) {
  >= 400 => RecordTone.error,
  >= 200 && < 300 => RecordTone.success,
  _ => RecordTone.neutral,
};

/// How a request ended, or that it has not: its status, then its error, or
/// that it is still in progress, or [finished], each a label.
List<Widget> outcomeLabels(
  BuildContext context, {
  required int status,
  required String error,
  required bool pending,
  required List<String> finished,
  String reason = '',
}) => [
  if (status != 0)
    RecordLabel(
      label: httpStatusText(status, reason),
      tone: httpStatusTone(status),
    ),
  if (error.isNotEmpty)
    RecordLabel(label: error, tone: RecordTone.error)
  else if (pending)
    RecordLabel(label: context.appLocalizations.inProgress)
  else
    for (final part in finished) RecordLabel(label: part),
];

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

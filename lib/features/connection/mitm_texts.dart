import 'package:fl_clash/common/common.dart';
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
}) {
  final colorScheme = context.colorScheme;
  return [
    if (status != 0) ('$status', httpStatusColor(colorScheme, status)),
    if (error.isNotEmpty)
      (error, colorScheme.error)
    else if (pending)
      (context.appLocalizations.inProgress, null)
    else
      for (final part in finished) (part, null),
  ];
}

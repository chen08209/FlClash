import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

void showMitmLine(String title, String line, String? issue, Color? issueColor) {
  dialogs.showAlert(
    title: title,
    message: TextSpan(
      children: [
        TextSpan(text: line, style: const TextStyle().toJetBrainsMono),
        if (issue != null)
          TextSpan(
            text: '\n\n$issue',
            style: TextStyle(color: issueColor),
          ),
      ],
    ),
  );
}

class MitmHostRowItem extends StatelessWidget {
  const MitmHostRowItem(this.row, {super.key, required this.title});

  final MitmHostRow row;

  /// Heads the dialog an invalid row opens.
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final issue = row.issue;
    return DecorationListItem(
      invalid: issue != null,
      title: Text(
        row.host,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle().toJetBrainsMono,
      ),
      subtitle: issue == null
          ? null
          : Text(
              issue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colorScheme.error),
            ),
      trailing: row.exclude
          ? Text(
              context.appLocalizations.mitmExcluded,
              style: TextStyle(color: colorScheme.warning),
            )
          : null,
      onPressed: issue == null
          ? null
          : () => showMitmLine(title, row.host, issue, colorScheme.error),
    );
  }
}

class MitmUnreadHostsItem extends StatelessWidget {
  const MitmUnreadHostsItem(this.error, {super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return DecorationListItem(
      invalid: true,
      title: Text(appLocalizations.mitmModuleHostsUnread),
      subtitle: Text(
        userFacingErrorMessage(error, appLocalizations),
        style: TextStyle(color: context.colorScheme.error),
      ),
    );
  }
}

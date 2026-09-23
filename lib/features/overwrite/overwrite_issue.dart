import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';

import 'overwrite_form_row.dart';

extension OverwriteIssueExt on OverwriteIssue {
  String getMessage(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return switch (this) {
      EmptyNameIssue() => appLocalizations.overwriteIssueEmptyName,
      ReservedNameIssue(:final name) =>
        appLocalizations.overwriteIssueReservedName(name),
      DuplicateNameIssue(:final name) =>
        appLocalizations.overwriteIssueDuplicateName(name),
      CoreRejectedIssue(:final message) =>
        appLocalizations.overwriteIssueCoreRejected(message),
      MissingProxiesIssue(:final names) =>
        appLocalizations.overwriteIssueMissingProxies(names.join(', ')),
      MissingProvidersIssue(:final names) =>
        appLocalizations.overwriteIssueMissingProviders(names.join(', ')),
      NoProxySourceIssue() => appLocalizations.overwriteIssueNoProxySource,
      GroupLoopIssue(:final names) => appLocalizations.overwriteIssueGroupLoop(
        names.join(' › '),
      ),
      InvalidPayloadIssue(:final error) => error.getMessage(context),
      MissingRuleSetIssue(:final name) => appLocalizations.invalidRuleSet(name),
      MissingSubRuleIssue(:final name) => appLocalizations.invalidSubRule(name),
      MissingTargetIssue(:final name) => appLocalizations.invalidPolicy(name),
    };
  }
}

extension OverwriteIssuesExt on Iterable<OverwriteIssue> {
  String getMessage(BuildContext context) {
    if (length == 1) {
      return first.getMessage(context);
    }
    return map((issue) => '• ${issue.getMessage(context)}').join('\n');
  }
}

class OverwriteIssueButton extends StatelessWidget {
  final List<OverwriteIssue> issues;

  const OverwriteIssueButton({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return InfoMessageButton(message: issues.getMessage(context));
  }
}

class OverwriteIssuesBanner extends StatelessWidget {
  final List<OverwriteIssue> issues;

  const OverwriteIssuesBanner({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return OverwriteErrorBanner(
      message: issues.isEmpty ? null : issues.getMessage(context),
    );
  }
}

class OverwriteErrorBanner extends StatelessWidget {
  final String? message;

  const OverwriteErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final message = this.message;
    return AnimatedSize(
      duration: commonDuration,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: colorScheme.errorContainer,
                shape: AppShape.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  GlyphIcon(
                    AppGlyphs.error,
                    size: 20.ap,
                    color: colorScheme.onErrorContainer,
                  ),
                  Expanded(
                    child: Text(
                      message,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

Future<void> showOverwriteIssues(
  BuildContext context,
  List<OverwriteIssue> issues,
) async {
  await dialogs.showMessage(
    message: TextSpan(text: issues.getMessage(context)),
    cancelable: false,
  );
}

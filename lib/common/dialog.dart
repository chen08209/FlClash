import 'dart:async';

import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Dialogs {
  Dialogs._();

  BuildContext get _context => rootNavigatorKey.currentContext!;

  Future<T?> showCommonDialog<T>({
    required Widget child,
    BuildContext? context,
    bool? dismissible,
  }) async {
    final host = context ?? _context;
    return showModal<T>(
      useRootNavigator: false,
      context: host,
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: host.colorScheme.modalScrim,
        barrierDismissible: dismissible ?? true,
      ),
      builder: (_) => child,
    );
  }

  Future<bool?> showMessage({
    required InlineSpan message,
    BuildContext? context,
    String? title,
    String? confirmText,
    String? cancelText,
    bool cancelable = true,
    bool? dismissible,
  }) async {
    return showCommonDialog<bool>(
      context: context,
      dismissible: dismissible,
      child: Builder(
        builder: (context) {
          final appLocalizations = context.appLocalizations;
          return CommonDialog(
            title: title ?? appLocalizations.tip,
            actions: [
              if (cancelable)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(cancelText ?? appLocalizations.cancel),
                ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(confirmText ?? appLocalizations.confirm),
              ),
            ],
            child: Container(
              width: 300,
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: SelectableText.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.labelLarge,
                    children: [message],
                  ),
                  style: const TextStyle(overflow: TextOverflow.visible),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> showFailureDetails(List<UpdatingMessage> failures) {
    return showSheet(
      context: _context,
      builder: (_) => _FailureDetailsSheet(failures: failures),
    );
  }

  Future<String?> showUrlInput({required String title, String value = ''}) {
    final appLocalizations = currentAppLocalizations;
    return showCommonDialog<String>(
      child: InputDialog(
        title: title,
        value: value,
        labelText: appLocalizations.url,
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.value);
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip(appLocalizations.value);
          }
          return null;
        },
      ),
    );
  }

  Future<String?> showPasswordInput({required String title}) {
    return showCommonDialog<String>(
      child: InputDialog(
        title: title,
        value: '',
        labelText: currentAppLocalizations.password,
        obscureText: true,
      ),
    );
  }

  Future<String?> showAgeSecretKeyInput() {
    final appLocalizations = currentAppLocalizations;
    return showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.ageEncryptedProfile,
        value: '',
        labelText: appLocalizations.ageSecretKey,
        obscureText: true,
        validator: (value) => value == null || value.trim().isEmpty
            ? appLocalizations.emptyTip(appLocalizations.ageSecretKey)
            : null,
      ),
    );
  }

  Future<NamedUrl?> showNamedUrlInput({
    required String title,
    String label = '',
    String url = '',
    FormFieldValidator<String>? labelValidator,
    FormFieldValidator<String>? urlValidator,
  }) async {
    final res = await showCommonDialog<List<NamedUrl>>(
      child: NamedUrlDialog(
        title: title,
        label: label,
        url: url,
        labelValidator: labelValidator,
        urlValidator: urlValidator,
      ),
    );
    return res?.single;
  }

  /// A batch skips the urls in [existingUrls].
  Future<List<NamedUrl>?> showNamedUrlsInput({
    required String title,
    String? urlLabel,
    String? batchTip,
    FormFieldValidator<String>? labelValidator,
    FormFieldValidator<String>? urlValidator,
    Set<String> existingUrls = const {},
    bool withAgeSecretKey = false,
  }) {
    return showCommonDialog<List<NamedUrl>>(
      child: NamedUrlDialog(
        title: title,
        urlLabel: urlLabel,
        batchTip: batchTip,
        labelValidator: labelValidator,
        urlValidator: urlValidator,
        batch: true,
        existingUrls: existingUrls,
        withAgeSecretKey: withAgeSecretKey,
      ),
    );
  }

  void showNotifier(
    String text, {
    MessageLevel level = MessageLevel.info,
    MessageActionState? actionState,
  }) {
    rootNavigatorKey.currentContext?.showNotifier(
      text,
      level: level,
      actionState: actionState,
    );
  }

  void showFailures(List<UpdatingMessage> failures) {
    final appLocalizations = currentAppLocalizations;
    switch (failures) {
      case []:
        return;
      case [final failure]:
        showNotifier(
          appLocalizations.failedItem(failure.label, failure.message),
          level: MessageLevel.error,
        );
      default:
        showNotifier(
          appLocalizations.failedCount(failures.length),
          level: MessageLevel.error,
          actionState: MessageActionState(
            actionText: appLocalizations.view,
            action: () {
              unawaited(showFailureDetails(failures));
            },
          ),
        );
    }
  }

  Future<void> openUrl(String url) async {
    final res = await showMessage(
      message: TextSpan(text: url),
      title: currentAppLocalizations.externalLink,
      confirmText: currentAppLocalizations.go,
    );
    if (res != true) {
      return;
    }
    unawaited(launchUrl(Uri.parse(url)));
  }
}

class _FailureDetailsSheet extends StatelessWidget {
  final List<UpdatingMessage> failures;

  const _FailureDetailsSheet({required this.failures});

  @override
  Widget build(BuildContext context) {
    final labelsByMessage = <String, List<String>>{};
    for (final failure in failures) {
      (labelsByMessage[failure.message] ??= []).add(failure.label);
    }
    final groups = labelsByMessage.entries.toList();
    return CommonScaffold(
      title: context.appLocalizations.errorDetails,
      body: SelectionArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(top: context.contentTopPadding, bottom: 20),
          itemCount: groups.length,
          separatorBuilder: (_, _) => SizedBox(height: 24.mAp),
          itemBuilder: (_, index) {
            final MapEntry(key: message, value: labels) = groups[index];
            return generateSectionV3(
              items: [
                for (final label in labels)
                  DecorationListItem(
                    title: TooltipText(
                      text: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
              footer: message,
            );
          },
        ),
      ),
    );
  }
}

final dialogs = Dialogs._();

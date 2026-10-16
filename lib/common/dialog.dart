import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Dialogs {
  Dialogs._();

  // Focus sits in the route the user acts in, so an alert raised from a form
  // sheet, or a page pushed inside one, opens over it, beside the navigation
  // as the sheet sits.
  BuildContext get _context {
    var context = FocusManager.instance.primaryFocus?.context;
    while (context != null) {
      final route = ModalRoute.of(context);
      if (route is AlertHostRoute) {
        final host = route.navigator;
        if (host != null && host.mounted) {
          return host.context;
        }
        break;
      }
      context = route?.navigator?.context;
    }
    return rootNavigatorKey.currentContext!;
  }

  Future<T?> showCommonDialog<T>({
    required Widget child,
    BuildContext? context,
    bool? dismissible,
  }) async {
    return showFloatingDialog<T>(
      context: context ?? _context,
      child: child,
      dismissible: dismissible ?? true,
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
    bool destructive = false,
  }) async {
    return showCommonDialog<bool>(
      context: context,
      dismissible: dismissible,
      child: Builder(
        builder: (context) {
          final appLocalizations = context.appLocalizations;
          return CommonDialog(
            title: title ?? appLocalizations.tip,
            destructive: destructive,
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
            child: SelectableText.rich(
              TextSpan(children: [message]),
              style: const TextStyle(overflow: TextOverflow.visible),
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
          separatorBuilder: (_, _) => SizedBox(height: 24.mAp(context)),
          itemBuilder: (_, index) {
            final MapEntry(key: message, value: labels) = groups[index];
            return generateSection(
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

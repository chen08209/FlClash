import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

/// A null [profileId] edits something app-level, outside any profile.
Future<void> showNestedFormSheet<T>({
  required BuildContext context,
  required int? profileId,
  required List<Override> overrides,
  required T Function(WidgetRef ref) currentOf,
  required WidgetBuilder formBuilder,
}) {
  return showSheet(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) {
      final sheet = ProviderScope(
        overrides: overrides,
        child: NestedFormSheet<T>(
          currentOf: currentOf,
          formBuilder: formBuilder,
        ),
      );
      if (profileId == null) {
        return sheet;
      }
      return ProfileIdProvider(profileId: profileId, child: sheet);
    },
  );
}

class NestedFormSheet<T> extends ConsumerStatefulWidget {
  final T Function(WidgetRef ref) currentOf;
  final WidgetBuilder formBuilder;

  const NestedFormSheet({
    super.key,
    required this.currentOf,
    required this.formBuilder,
  });

  /// Answers save in the prompt on leaving with the form's own save action,
  /// which closes the sheet once saved and otherwise shows the form why not.
  static void bindSave(BuildContext context, FutureOr<void> Function() save) {
    context.findAncestorStateOfType<_NestedFormSheetState>()?._save = save;
  }

  @override
  ConsumerState<NestedFormSheet<T>> createState() => _NestedFormSheetState<T>();
}

class _NestedFormSheetState<T> extends ConsumerState<NestedFormSheet<T>> {
  late final T _origin;
  FutureOr<void> Function()? _save;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _origin = widget.currentOf(ref);
  }

  bool get _changed => _origin != widget.currentOf(ref);

  Future<void> _handleDismiss(bool hasPushedPages) async {
    if (_closing) return;
    _closing = true;
    try {
      if (hasPushedPages && !_changed) {
        final res = await dialogs.showMessage(
          message: TextSpan(text: context.appLocalizations.confirmExitWindow),
        );
        if (res != true) {
          return;
        }
      }
      if (context.mounted) {
        await _handleExit();
      }
    } finally {
      _closing = false;
    }
  }

  Future<void> _handleExit() async {
    if (_changed) {
      final res = await dialogs.showMessage(
        message: TextSpan(text: context.appLocalizations.saveChanges),
      );
      if (res == null || !mounted) {
        return;
      }
      if (res) {
        await _save?.call();
        return;
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return NestedPagedSheet(
      builder: widget.formBuilder,
      onExit: () => unawaited(_handleDismiss(false)),
      onDismiss: _handleDismiss,
    );
  }
}

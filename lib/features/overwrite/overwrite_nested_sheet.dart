import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show Override;

import 'overwrite_stage_flow.dart';

Future<void> showOverwriteNestedSheet<T>({
  required BuildContext context,
  required int profileId,
  required List<Override> overrides,
  required T Function(WidgetRef ref) currentOf,
  required bool Function(BuildContext context, WidgetRef ref) save,
  required WidgetBuilder formBuilder,
}) {
  return showSheet(
    context: context,
    props: nestedPagedSheetProps,
    builder: (_) {
      return ProfileIdProvider(
        profileId: profileId,
        child: ProviderScope(
          overrides: overrides,
          child: OverwriteNestedSheet<T>(
            currentOf: currentOf,
            save: save,
            formBuilder: formBuilder,
          ),
        ),
      );
    },
  );
}

class OverwriteNestedSheet<T> extends ConsumerStatefulWidget {
  final T Function(WidgetRef ref) currentOf;
  final bool Function(BuildContext context, WidgetRef ref) save;
  final WidgetBuilder formBuilder;

  const OverwriteNestedSheet({
    super.key,
    required this.currentOf,
    required this.save,
    required this.formBuilder,
  });

  @override
  ConsumerState<OverwriteNestedSheet<T>> createState() =>
      _OverwriteNestedSheetState<T>();
}

class _OverwriteNestedSheetState<T>
    extends ConsumerState<OverwriteNestedSheet<T>> {
  late final T _origin;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _origin = widget.currentOf(ref);
  }

  Future<void> _handleDismiss(bool hasPushedPages) async {
    if (_closing) return;
    _closing = true;
    try {
      if (hasPushedPages) {
        final res = await dialogs.showMessage(
          message: TextSpan(text: context.appLocalizations.confirmExitWindow),
        );
        if (res != true) {
          return;
        }
      }
      if (context.mounted) {
        unawaited(_handleExit());
      }
    } finally {
      _closing = false;
    }
  }

  Future<void> _handleExit() async {
    flushPendingOverwriteStages();
    final current = widget.currentOf(ref);
    if (_origin == current) {
      Navigator.of(context).pop();
      return;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.dataChangedSave),
    );
    if (!mounted) {
      return;
    }
    if (res != true) {
      Navigator.of(context).pop();
      return;
    }
    if (widget.save(context, ref)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedPagedSheet(
      builder: widget.formBuilder,
      onExit: () => unawaited(_handleExit()),
      onDismiss: (hasPushedPages) => unawaited(_handleDismiss(hasPushedPages)),
    );
  }
}

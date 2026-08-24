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
    props: const SheetProps(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      maxWidth: double.maxFinite,
    ),
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
  final GlobalKey<NavigatorState> _nestedNavigatorKey = GlobalKey();
  late final T _origin;

  @override
  void initState() {
    super.initState();
    _origin = widget.currentOf(ref);
  }

  Future<void> _handleClose() async {
    final state = _nestedNavigatorKey.currentState;
    if (state != null && state.canPop()) {
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

  Future<void> _handlePop() async {
    final state = _nestedNavigatorKey.currentState;
    if (state != null && state.canPop()) {
      state.pop();
    } else {
      unawaited(_handleExit());
    }
  }

  @override
  Widget build(BuildContext context) {
    final nestedNavigator = Navigator(
      key: _nestedNavigatorKey,
      onGenerateInitialRoutes: (navigator, initialRoute) {
        return [
          PagedSheetRoute(builder: (context) => widget.formBuilder(context)),
        ];
      },
    );
    final sheetProvider = SheetProvider.of(context);
    return CommonPopScope(
      onPop: (_) async {
        unawaited(_handlePop());
        return false;
      },
      child: sheetProvider!.copyWith(
        nestedNavigatorPop: ([data]) {
          Navigator.of(context).pop(data);
        },
        child: SizedBox(
          width: sheetProvider.type == SheetType.sideSheet ? 400 : null,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () async {
                    await _handleClose();
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: PagedSheet(child: nestedNavigator),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

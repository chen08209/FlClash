import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'overwrite_form_row.dart';

class OverwriteDismissItem extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final bool Function(WidgetRef ref, int profileId, String title) isValidOf;
  final String Function(BuildContext context, String title) invalidMessageOf;
  final bool dismiss;
  final ItemPosition position;
  final VoidCallback onRemove;
  final VoidCallback onDismissed;
  final int index;
  final double dragIconPadding;

  const OverwriteDismissItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.isValidOf,
    required this.invalidMessageOf,
    required this.dismiss,
    required this.position,
    required this.onRemove,
    required this.onDismissed,
    required this.index,
    this.dragIconPadding = 12,
  });

  @override
  Widget build(BuildContext context, ref) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final isValid = isValidOf(ref, profileId, title);
    return ExternalDismissible(
      dismiss: dismiss,
      key: ValueKey(title),
      onDismissed: onDismissed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: DecorationListItem(
            invalid: !isValid,
            minVerticalPadding: 8,
            title: TooltipText(
              text: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            subtitle: subtitle != null ? Text(subtitle!) : null,
            contentPadding: const EdgeInsets.only(left: 16, right: 0),
            leading: CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.remove,
                onPressed: onRemove,
                icon: const Icon(Icons.remove, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isValid)
                  InfoMessageButton(message: invalidMessageOf(context, title)),
                ReorderableDelayedDragStartListener(
                  index: index,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.all(dragIconPadding),
                    child: const Icon(Icons.drag_handle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final Set<String> _pendingStageTags = {};

void flushPendingOverwriteStages() {
  for (final tag in _pendingStageTags.toList()) {
    debouncer.flush(tag);
  }
}

mixin OverwriteStageFlowMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String get key;

  final Set<String> _ownStageTags = {};

  @override
  void deactivate() {
    for (final tag in _ownStageTags.toList()) {
      debouncer.flush(tag);
      _pendingStageTags.remove(tag);
    }
    super.deactivate();
  }

  void handleStage(String id, [String? scene]) {
    final realKey = scene == null ? key : '${key}_$scene';
    ref.read(itemsProvider(realKey).notifier).update((state) {
      final newSet = Set<dynamic>.from(state);
      newSet.add(id);
      return newSet;
    });
  }

  void handleRealStage({
    required String tag,
    String? scene,
    required ProxyGroup Function(ProxyGroup state, Set<dynamic> staged) apply,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    final realKey = scene == null ? key : '${key}_$scene';
    _pendingStageTags.add(tag);
    _ownStageTags.add(tag);
    debouncer.call(tag, () {
      _pendingStageTags.remove(tag);
      if (!ref.context.mounted) {
        return;
      }
      final staged = ref.read(itemsProvider(realKey));
      ref.read(proxyGroupProvider.notifier).update((state) {
        return apply(state, staged);
      });
      ref.read(itemsProvider(realKey).notifier).update((state) => <dynamic>{});
    }, duration: duration);
  }

  void listenForStageChanges({
    required String tag,
    String? scene,
    required ProxyGroup Function(ProxyGroup state, Set<dynamic> staged) apply,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    final realKey = scene == null ? key : '${key}_$scene';
    ref.listenManual(itemsProvider(realKey), (prev, next) {
      if (next.isNotEmpty && !const SetEquality().equals(prev, next)) {
        handleRealStage(
          tag: tag,
          scene: scene,
          apply: apply,
          duration: duration,
        );
      }
    });
  }
}

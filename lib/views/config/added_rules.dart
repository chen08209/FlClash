import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedRulesView extends ConsumerStatefulWidget {
  const AddedRulesView({super.key});

  @override
  ConsumerState<AddedRulesView> createState() => _AddedRulesViewState();
}

class _AddedRulesViewState extends ConsumerState<AddedRulesView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final res = await globalState.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null) {
      return;
    }
    ref.read(rulesProvider.notifier).update((state) => state.updateWith(res));
  }

  void _handleSelected(String ruleId) {
    ref.read(selectedIdsProvider.notifier).update((selectedRules) {
      final newSelectedRules = Set<String>.from(selectedRules)
        ..addOrRemove(ruleId);
      return newSelectedRules;
    });
  }

  void _handleSelectAll() {
    final ids = ref.read(rulesProvider).map((item) => item.id).toSet();
    ref.read(selectedIdsProvider.notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete() async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(selectedIdsProvider);
    ref.read(rulesProvider.notifier).update((rules) {
      final newRules = List<Rule>.from(
        rules.where((item) => !selectedRules.contains(item.id)),
      );
      return newRules;
    });
    ref.read(selectedIdsProvider.notifier).value = {};
  }

  @override
  Widget build(BuildContext context) {
    final rules = ref.watch(rulesProvider);
    final selectedRules = ref.watch(selectedIdsProvider);
    return BaseScaffold(
      title: appLocalizations.addedRules,
      actions: [
        if (selectedRules.isNotEmpty) ...[
          CommonMinIconButtonTheme(
            child: IconButton.filledTonal(
              onPressed: _handleDelete,
              icon: Icon(Icons.delete),
            ),
          ),
          SizedBox(width: 2),
        ],
        CommonMinFilledButtonTheme(
          child: selectedRules.isNotEmpty
              ? FilledButton(
                  onPressed: _handleSelectAll,
                  child: Text(appLocalizations.selectAll),
                )
              : FilledButton.tonal(
                  onPressed: () {
                    _handleAddOrUpdate();
                  },
                  child: Text(appLocalizations.add),
                ),
        ),
        SizedBox(width: 8),
      ],
      body: rules.isEmpty
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.rule),
              illustration: RuleEmptyIllustration(),
            )
          : ReorderableList(
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return ReorderableDelayedDragStartListener(
                  key: ObjectKey(rule),
                  index: index,
                  child: RuleItem(
                    isEditing: selectedRules.isNotEmpty,
                    rule: rule,
                    isSelected: selectedRules.contains(rule.id),
                    onSelected: _handleSelected,
                    onEdit: (Rule rule) {
                      _handleAddOrUpdate(rule);
                    },
                  ),
                );
              },
              itemCount: rules.length,
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final newRules = List<Rule>.from(rules);
                final item = newRules.removeAt(oldIndex);
                newRules.insert(newIndex, item);
                ref.read(rulesProvider.notifier).value = newRules;
              },
            ),
    );
  }
}

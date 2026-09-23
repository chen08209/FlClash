import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/features.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/state.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedRulesView extends ConsumerStatefulWidget {
  const AddedRulesView({super.key});

  @override
  ConsumerState<AddedRulesView> createState() => _AddedRulesViewState();
}

class _AddedRulesViewState extends ConsumerState<AddedRulesView> {
  final _key = uniqueId;
  var _query = SearchQuery('');
  final _searchTexts = Expando<String>();

  List<Rule> _visibleRules(List<Rule> rules) {
    return rules
        .whereMatches(_query, (rule) => rule.searchFields, texts: _searchTexts)
        .toList();
  }

  void _handleSearch(String query) {
    setState(() {
      _query = SearchQuery(query);
    });
  }

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final res = await dialogs.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null || !mounted) {
      return;
    }
    ref.read(globalRulesProvider.notifier).put(res);
  }

  void _handleSelected(int ruleId) {
    ref.read(itemsProvider(_key).notifier).update((selectedRules) {
      final newSelectedRules = Set<int>.from(selectedRules)
        ..addOrRemove(ruleId);
      return newSelectedRules;
    });
  }

  void _handleSelectAll() {
    final ids = _visibleRules(
      ref.read(globalRulesProvider).value ?? [],
    ).map((item) => item.id).toSet();
    ref.read(itemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
    );
    if (res != true || !mounted) {
      return;
    }
    final selectedRules = ref.read(itemsProvider(_key));
    final deletedIds = _visibleRules(
      ref.read(globalRulesProvider).value ?? [],
    ).map((item) => item.id).where(selectedRules.contains).toSet();
    ref.read(globalRulesProvider.notifier).delAll(deletedIds);
    ref.read(itemsProvider(_key).notifier).value = selectedRules.difference(
      deletedIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final rulesState = ref.watch(globalRulesProvider);
    final rules = _visibleRules(rulesState.value ?? []);
    final isSearching = _query.isNotEmpty;
    final selectedRules = ref.watch(itemsProvider(_key));
    final isSelecting = selectedRules.isNotEmpty;
    final selectionActions = [
      IconButtonData(
        glyph: AppGlyphs.delete,
        onPressed: _handleDelete,
        tooltip: appLocalizations.delete,
      ),
      IconButtonData(
        glyph: AppGlyphs.selectAll,
        onPressed: _handleSelectAll,
        tooltip: appLocalizations.selectAll,
      ),
    ];
    return CommonPopScope(
      onPop: (_) {
        if (selectedRules.isNotEmpty) {
          ref.read(itemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },

      child: CommonScaffold(
        title: appLocalizations.addedRules,
        searchState: AppBarSearchState(onSearch: _handleSearch),
        actions: [
          if (!isSelecting)
            FilledButton.tonal(
              onPressed: () {
                _handleAddOrUpdate();
              },
              child: Text(appLocalizations.add),
            ),
        ],
        selectionActions: isSelecting ? selectionActions : const [],
        body: NullStatusSwitcher(
          isLoading: rulesState.isLoading,
          isEmpty: rules.isEmpty,
          isSearching: isSearching,
          nullStatus: NullStatus(
            label: appLocalizations.nullTip(appLocalizations.rule),
            illustration: NullStatusIllustration.rules,
          ),
          child: isSearching
              ? ListView.builder(
                  padding: _listPadding,
                  itemBuilder: (_, index) =>
                      _buildRuleItem(rules, index, selectedRules),
                  itemExtent: ruleItemHeight,
                  itemCount: rules.length,
                )
              : ReorderableList(
                  padding: _listPadding,
                  itemBuilder: (_, index) =>
                      ReorderableDelayedDragStartListener(
                        key: ObjectKey(rules[index]),
                        index: index,
                        child: _buildRuleItem(rules, index, selectedRules),
                      ),
                  itemExtent: ruleItemHeight,
                  itemCount: rules.length,
                  onReorderItem: ref.read(globalRulesProvider.notifier).order,
                ),
        ),
      ),
    );
  }

  EdgeInsets get _listPadding =>
      const EdgeInsets.all(16).copyWith(top: context.contentTopPadding);

  Widget _buildRuleItem(List<Rule> rules, int index, Set<dynamic> selected) {
    final rule = rules[index];
    return ItemPositionProvider(
      key: ObjectKey(rule),
      position: ItemPosition.get(index, rules.length),
      child: RuleItem(
        hasMatch: true,
        isEditing: selected.isNotEmpty,
        rule: rule,
        isSelected: selected.contains(rule.id),
        onSelected: () {
          _handleSelected(rule.id);
        },
        onEdit: (Rule rule) {
          _handleAddOrUpdate(rule);
        },
      ),
    );
  }
}

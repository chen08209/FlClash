import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'icon.dart';
import 'members.dart';
import 'quick_edit.dart';

const _defaultEmptyFallback = 'COMPATIBLE';

const _inUserHashKey = 'in-user';

/// What a group leaves to the core until it is added, starting from the
/// core's own default.
enum _GroupOption {
  emptyFallback,
  url,
  interval,
  timeout,
  maxFailedTimes,
  lazy,
  expectedStatus,
  tolerance,
  defaultSelected,
  strategy,
  hashKey,
  hidden,
  disableUDP;

  String label(AppLocalizations l) => switch (this) {
    emptyFallback => l.emptyFallback,
    url => l.testUrl,
    interval => l.testInterval,
    timeout => l.timeout,
    maxFailedTimes => l.maxFailedTimes,
    lazy => l.testWhenUsed,
    expectedStatus => l.expectedStatus,
    tolerance => l.tolerance,
    defaultSelected => l.defaultSelected,
    strategy => l.strategy,
    hashKey => l.hashByInUser,
    hidden => l.hideFromList,
    disableUDP => l.disableUDP,
  };

  String section(AppLocalizations l) => switch (this) {
    url ||
    interval ||
    timeout ||
    maxFailedTimes ||
    lazy ||
    expectedStatus ||
    tolerance => l.healthCheck,
    emptyFallback ||
    defaultSelected ||
    strategy ||
    hashKey ||
    hidden ||
    disableUDP => l.other,
  };

  bool appliesTo(GroupType type, LoadBalanceStrategy? strategy) =>
      switch (this) {
        tolerance => type == GroupType.URLTest,
        defaultSelected => type == GroupType.Selector,
        _GroupOption.strategy => type == GroupType.LoadBalance,
        hashKey =>
          type == GroupType.LoadBalance &&
              strategy != LoadBalanceStrategy.roundRobin,
        _ => true,
      };

  bool isSetIn(ProxyGroup group) => switch (this) {
    emptyFallback => group.emptyFallback?.isNotEmpty == true,
    url => group.url?.isNotEmpty == true,
    interval => group.interval != null,
    timeout => group.timeout != null,
    maxFailedTimes => group.maxFailedTimes != null,
    lazy => group.lazy != null,
    expectedStatus => group.expectedStatus?.isNotEmpty == true,
    tolerance => group.tolerance != null,
    defaultSelected => group.defaultSelected?.isNotEmpty == true,
    _GroupOption.strategy => group.strategy != null,
    hashKey => group.hashKey?.isNotEmpty == true,
    hidden => group.hidden != null,
    disableUDP => group.disableUDP != null,
  };

  ProxyGroup reset(ProxyGroup group) => switch (this) {
    url => group.copyWith(url: defaultTestUrl),
    interval => group.copyWith(interval: 300),
    timeout => group.copyWith(timeout: 5000),
    maxFailedTimes => group.copyWith(maxFailedTimes: 5),
    lazy => group.copyWith(lazy: true),
    expectedStatus => group.copyWith(expectedStatus: ''),
    tolerance => group.copyWith(tolerance: 0),
    _GroupOption.strategy => group.copyWith(
      strategy: LoadBalanceStrategy.consistentHashing,
    ),
    hidden => group.copyWith(hidden: false),
    disableUDP => group.copyWith(disableUDP: false),
    emptyFallback || defaultSelected || hashKey => clear(group),
  };

  ProxyGroup clear(ProxyGroup group) => switch (this) {
    emptyFallback => group.copyWith(emptyFallback: null),
    url => group.copyWith(url: null),
    interval => group.copyWith(interval: null),
    timeout => group.copyWith(timeout: null),
    maxFailedTimes => group.copyWith(maxFailedTimes: null),
    lazy => group.copyWith(lazy: null),
    expectedStatus => group.copyWith(expectedStatus: null),
    tolerance => group.copyWith(tolerance: null),
    defaultSelected => group.copyWith(defaultSelected: null),
    _GroupOption.strategy => group.copyWith(strategy: null),
    hashKey => group.copyWith(hashKey: null),
    hidden => group.copyWith(hidden: null),
    disableUDP => group.copyWith(disableUDP: null),
  };
}

double get _groupRowExtent => globalState.measure.listTwoLineRowHeight;

/// Keeps the actions on the groups in their own header, off the page bar,
/// which belongs to the whole profile.
class CustomProxyGroupsSection extends ConsumerStatefulWidget {
  final int profileId;

  const CustomProxyGroupsSection(this.profileId, {super.key});

  @override
  ConsumerState<CustomProxyGroupsSection> createState() =>
      _CustomProxyGroupsSectionState();
}

class _CustomProxyGroupsSectionState
    extends ConsumerState<CustomProxyGroupsSection> {
  var _selected = <int>{};
  var _sorting = false;

  void _toggleSorting() {
    setState(() {
      _sorting = !_sorting;
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref
        .read(proxyGroupsProvider(widget.profileId).notifier)
        .order(oldIndex, newIndex);
  }

  void _handleAddOrUpdate({ProxyGroup? proxyGroup}) {
    showNestedFormSheet<ProxyGroup>(
      context: context,
      profileId: widget.profileId,
      overrides: [
        proxyGroupProvider.overrideWithBuild(
          (_, _) =>
              proxyGroup ??
              const ProxyGroup(id: -1, name: '', type: GroupType.Selector),
        ),
      ],
      currentOf: (ref) => ref.read(proxyGroupProvider),
      formBuilder: (_) => const EditProxyGroupView(),
    );
  }

  void _handleToggleSelected(int id) {
    setState(() {
      _selected = {..._selected}..addOrRemove(id);
    });
  }

  void _handleSelectAll(Set<int> ids) {
    setState(() {
      _selected = _selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete(Set<int> ids, {required String message}) async {
    final appLocalizations = context.appLocalizations;
    final inUse = await ref
        .read(profilesActionProvider.notifier)
        .groupsInUse(widget.profileId, ids);
    if (!mounted) {
      return;
    }
    final res = await dialogs.showMessage(
      message: TextSpan(
        text: inUse.isEmpty
            ? message
            : appLocalizations.proxyGroupInUse(inUse.join(', ')),
      ),
    );
    if (res != true || !mounted) {
      return;
    }
    ref.read(proxyGroupsProvider(widget.profileId).notifier).delAll(ids);
    setState(() {
      _selected = {};
    });
  }

  void _handleDuplicate(Set<int> ids) {
    final notifier = ref.read(proxyGroupsProvider(widget.profileId).notifier);
    final proxyGroups = notifier.value;
    final taken = {
      ...reservedProxyNames,
      ...?ref.read(customProfileDataProvider(widget.profileId))?.proxies,
      for (final group in proxyGroups) group.name,
    };
    notifier.insertAfterEach({
      for (final proxyGroup in proxyGroups)
        if (ids.contains(proxyGroup.id))
          proxyGroup.id: proxyGroup.copyWith(
            id: snowflake.id,
            name: copiedProxyName(proxyGroup.name, taken),
          ),
    });
  }

  List<CommonPopupMenuItem> _menuItems(ProxyGroup proxyGroup) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.copy,
        label: appLocalizations.copy,
        onPressed: () => _handleDuplicate({proxyGroup.id}),
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.delete,
        label: appLocalizations.delete,
        danger: true,
        onPressed: () => _handleDelete({
          proxyGroup.id,
        }, message: appLocalizations.confirmDeleteProxyGroup),
      ),
    ];
  }

  List<Widget> _buildActions(Set<int> ids, Set<int> selected) {
    final appLocalizations = context.appLocalizations;
    if (selected.isNotEmpty) {
      return [
        TonalButtonGroup(
          size: TonalButtonSize.section,
          children: [
            IconButton(
              tooltip: appLocalizations.delete,
              onPressed: () => _handleDelete(
                selected,
                message: appLocalizations.deleteMultipTip(
                  appLocalizations.proxyGroup,
                ),
              ),
              icon: const GlyphIcon(AppGlyphs.delete),
            ),
            IconButton(
              tooltip: appLocalizations.selectAll,
              onPressed: () => _handleSelectAll(ids),
              icon: const GlyphIcon(AppGlyphs.selectAll),
            ),
          ],
        ),
      ];
    }
    return [
      if (_sorting || ids.length > 1)
        TonalButtonTheme(
          size: TonalButtonSize.section,
          child: ElasticPress(
            child: AppBarActionButton(
              data: sortModeAction(
                context,
                sorting: _sorting,
                onPressed: _toggleSorting,
              ),
            ),
          ),
        ),
      TonalButtonTheme(
        size: TonalButtonSize.section,
        child: ElasticPress(
          child: IconButton(
            tooltip: appLocalizations.add,
            onPressed: _handleAddOrUpdate,
            icon: const GlyphIcon(AppGlyphs.addCircle),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final proxyGroups = ref.watch(proxyGroupsProvider(widget.profileId)).value;
    final ids = {...?proxyGroups?.map((proxyGroup) => proxyGroup.id)};
    final selected = _selected.intersection(ids);
    Widget itemAt(int index) {
      final proxyGroup = proxyGroups![index];
      return SortableItem(
        key: ValueKey(proxyGroup.id),
        index: index,
        child: ContextMenuRegion(
          menuItems: selected.isEmpty ? _menuItems(proxyGroup) : null,
          child: ItemPositionProvider(
            position: ItemPosition.get(index, proxyGroups.length),
            child: _ProxyGroupItem(
              profileId: widget.profileId,
              proxyGroup: proxyGroup,
              isEditing: selected.isNotEmpty,
              isSelected: selected.contains(proxyGroup.id),
              onSelected: () => _handleToggleSelected(proxyGroup.id),
              onPressed: () => _handleAddOrUpdate(proxyGroup: proxyGroup),
            ),
          ),
        ),
      );
    }

    return CommonPopScope(
      onPop: selected.isEmpty && !_sorting
          ? null
          : (_) {
              setState(() {
                _selected = {};
                _sorting = false;
              });
              return false;
            },
      child: SortModeScope(
        sorting: _sorting,
        child: SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: ListHeader(
                title: appLocalizations.proxyGroup,
                actions: _buildActions(ids, selected),
              ),
            ),
            if (proxyGroups != null && proxyGroups.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: NullStatus(label: appLocalizations.proxyGroupEmpty),
                ),
              )
            else if (proxyGroups != null)
              SliverReorderableList(
                itemBuilder: (_, index) => itemAt(index),
                itemCount: proxyGroups.length,
                itemExtent: _groupRowExtent,
                proxyDecorator: (child, index, animation) =>
                    commonProxyDecorator(itemAt(index), index, animation),
                onReorderItem: _handleReorder,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProxyGroupItem extends ConsumerWidget {
  final int profileId;
  final ProxyGroup proxyGroup;
  final bool isEditing;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onPressed;

  const _ProxyGroupItem({
    required this.profileId,
    required this.proxyGroup,
    required this.isEditing,
    required this.isSelected,
    required this.onSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, ref) {
    final issues = ref
        .watch(
          customProfileIssuesProvider(profileId).select(
            (state) => SelectValue(
              state.proxyGroups[proxyGroup.id] ?? const <CustomIssue>[],
            ),
          ),
        )
        .value;
    return DecorationListItem(
      invalid: issues.isNotEmpty,
      isSelected: isSelected,
      onPressed: isEditing ? onSelected : onPressed,
      contentPadding: const EdgeInsets.only(left: 16),
      leading: SizedBox.square(
        dimension: 32,
        child: IconTheme.merge(
          data: const IconThemeData(size: 32),
          child: CommonTargetIcon(
            src: proxyGroup.icon ?? '',
            fallback: GroupMonogram(proxyGroup.name),
          ),
        ),
      ),
      title: TooltipText(
        text: Text(
          proxyGroup.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: Text(proxyGroup.type.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (issues.isNotEmpty) CustomIssueButton(issues: issues),
          CommonCheckBox(
            value: isSelected,
            isCircle: true,
            onChanged: (_) => onSelected(),
          ),
        ],
      ),
    );
  }
}

/// A missing member is left to the list to flag, since it usually appears when
/// the profile updates; these the core refuses whatever the profile holds.
bool _blocksSave(CustomIssue issue) => switch (issue) {
  EmptyNameIssue() ||
  ReservedNameIssue() ||
  DuplicateNameIssue() ||
  NoProxySourceIssue() ||
  GroupLoopIssue() ||
  DialerLoopIssue() ||
  InvalidEmptyFallbackIssue() => true,
  _ => false,
};

List<String> _filtersOf(ProxyGroup group) => [
  group.filter ?? '',
  group.excludeFilter ?? '',
];

List<CustomIssue> _filterIssues(
  AppLocalizations appLocalizations,
  List<String> errors,
) => [
  for (final (index, title) in [
    appLocalizations.filter,
    appLocalizations.excludeFilter,
  ].indexed)
    if (errors[index].isNotEmpty)
      CustomIssue.invalidFilter(title, errors[index]),
];

Future<bool> _handleSaveProxyGroup(BuildContext context, WidgetRef ref) async {
  final appLocalizations = context.appLocalizations;
  final proxyGroup = ref.read(proxyGroupProvider);
  final profileId = ProfileIdProvider.of(context)!.profileId;
  final profileData = ref.read(customProfileDataProvider(profileId));
  if (profileData == null) {
    return false;
  }
  final blocking = proxyGroupIssues(
    proxyGroup,
    profileData,
  ).where(_blocksSave).toList();
  final filterErrors = await checkFilters(ref, _filtersOf(proxyGroup));
  if (!context.mounted) {
    return false;
  }
  // The form stays editable while the core checks the filters.
  if (!identical(ref.read(proxyGroupProvider), proxyGroup)) {
    return _handleSaveProxyGroup(context, ref);
  }
  if (filterErrors != null) {
    blocking.addAll(_filterIssues(appLocalizations, filterErrors));
  }
  if (blocking.isNotEmpty) {
    await showSaveBlocked(context, blocking.getMessage(context));
    return false;
  }
  final ProxyGroup newProxyGroup;
  if (proxyGroup.id == -1) {
    newProxyGroup = proxyGroup.copyWith(id: snowflake.id);
  } else {
    newProxyGroup = proxyGroup;
  }
  final isRepeat = ref
      .read(proxyGroupsProvider(profileId).notifier)
      .put(newProxyGroup);
  if (isRepeat == false) {
    await showSaveBlocked(
      context,
      CustomIssue.duplicateName(newProxyGroup.name).getMessage(context),
    );
    return false;
  }
  // The closing form would otherwise take its stored copy for another group
  // with its name.
  ref.read(proxyGroupProvider.notifier).value = newProxyGroup;
  return true;
}

class EditProxyGroupView extends ConsumerStatefulWidget {
  const EditProxyGroupView({super.key});

  @override
  ConsumerState createState() => _EditProxyGroupViewState();
}

class _EditProxyGroupViewState extends ConsumerState<EditProxyGroupView> {
  static const _validateDelay = Duration(milliseconds: 400);

  late final bool _isNew;
  late Set<_GroupOption> _shown;
  final _removedFrom = <_GroupOption, ProxyGroup>{};
  int _revision = 0;
  bool _submitted = false;
  bool _saving = false;
  Timer? _filterTimer;
  int _filterRequest = 0;
  List<String> _filterErrors = const ['', ''];

  @override
  void initState() {
    super.initState();
    _isNew = ref.read(proxyGroupProvider).id == -1;
    _shown = _shownIn(ref.read(proxyGroupProvider));
    NestedFormSheet.bindSave(context, _handleSave);
    ref.listenManual(
      proxyGroupProvider.select((state) => (state.filter, state.excludeFilter)),
      (_, _) => _scheduleFilterCheck(),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _filterTimer?.cancel();
    super.dispose();
  }

  void _scheduleFilterCheck() {
    _filterTimer?.cancel();
    final request = ++_filterRequest;
    final filters = _filtersOf(ref.read(proxyGroupProvider));
    if (filters.every((filter) => filter.isEmpty)) {
      if (_filterErrors.any((error) => error.isNotEmpty)) {
        setState(() {
          _filterErrors = const ['', ''];
        });
      }
      return;
    }
    _filterTimer = Timer(_validateDelay, () async {
      final errors = await checkFilters(ref, filters);
      if (!mounted || request != _filterRequest) {
        return;
      }
      setState(() {
        _filterErrors = errors ?? const ['', ''];
      });
    });
  }

  Future<void> _showTypeOptions() async {
    final value = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => SelectionSheet<GroupType>(
          title: context.appLocalizations.proxyType,
          sections: [SelectionSection(items: GroupType.selectableValues)],
          labelBuilder: (item) => item.name,
          selectedOf: (ref) =>
              ref.watch(proxyGroupProvider.select((state) => state.type)),
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      ),
    );
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(type: value));
  }

  Future<void> _showStrategyOptions() async {
    final value = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => SelectionSheet<LoadBalanceStrategy>(
          title: context.appLocalizations.strategy,
          sections: const [SelectionSection(items: LoadBalanceStrategy.values)],
          labelBuilder: (item) => item.value,
          selectedOf: (ref) => ref.watch(
            proxyGroupProvider.select(
              (state) =>
                  state.strategy ?? LoadBalanceStrategy.consistentHashing,
            ),
          ),
          onSelected: (item) => Navigator.of(context).pop(item),
        ),
      ),
    );
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(strategy: value));
  }

  Future<void> _showEmptyFallbackOptions() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => Consumer(
          builder: (_, ref, _) {
            return SelectionSheet<String>(
              title: context.appLocalizations.emptyFallback,
              sections: [
                SelectionSection(
                  label: context.appLocalizations.basicStrategy,
                  items: reservedProxyNames.toList(),
                ),
              ],
              labelBuilder: (item) => item,
              selectedOf: (ref) => ref.watch(
                proxyGroupProvider.select(
                  (state) => state.emptyFallback ?? _defaultEmptyFallback,
                ),
              ),
              onSelected: (item) => Navigator.of(context).pop(item),
            );
          },
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update(
          (state) => state.copyWith(
            emptyFallback: res == _defaultEmptyFallback ? null : res,
          ),
        );
  }

  Future<void> _showDefaultSelectedOptions() async {
    final res = await Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => Consumer(
          builder: (_, ref, _) {
            final appLocalizations = context.appLocalizations;
            final proxies = ref.watch(
              proxyGroupProvider.select((state) => state.proxies),
            );
            return SelectionSheet<String>(
              title: appLocalizations.defaultSelected,
              sections: [
                const SelectionSection(items: ['']),
                SelectionSection(
                  label: appLocalizations.proxies,
                  items: proxies ?? const [],
                ),
              ],
              labelBuilder: (item) =>
                  item.isEmpty ? appLocalizations.defaultText : item,
              selectedOf: (ref) => ref.watch(
                proxyGroupProvider.select(
                  (state) => state.defaultSelected ?? '',
                ),
              ),
              onSelected: (item) => Navigator.of(context).pop(item),
            );
          },
        ),
      ),
    );
    if (res == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update(
          (state) => state.copyWith(defaultSelected: res.isEmpty ? null : res),
        );
  }

  Future<void> _showIconPicker(String? icon) async {
    final groupName = ref.read(proxyGroupProvider).name;
    final value = await Navigator.of(context).push<String>(
      PagedSheetRoute(
        builder: (context) => IconPickerView(value: icon, groupName: groupName),
      ),
    );
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(icon: value.value));
  }

  Widget _buildItem({
    required String title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    final VoidCallback? onPressed,
    bool invalid = false,
  }) {
    return FormRow(
      invalid: invalid,
      onPressed: onPressed,
      title: title,
      titleStyle: titleStyle,
      leading: leading,
      trailing: trailing,
    );
  }

  Widget _buildNumberItem({
    required String title,
    required int? value,
    required ProxyGroup Function(ProxyGroup state, int? value) apply,
    required Widget leading,
    String? suffix,
  }) {
    final appLocalizations = context.appLocalizations;
    final field = TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.number),
      textAlign: TextAlign.end,
      initialValue: value?.toString(),
      onChanged: (value) {
        ref
            .read(proxyGroupProvider.notifier)
            .update((state) => apply(state, int.tryParse(value)));
      },
      decoration: InputDecoration.collapsed(
        border: const NoInputBorder(),
        hintText: appLocalizations.optional,
      ),
    );
    return _buildItem(
      title: title,
      leading: leading,
      trailing: suffix == null
          ? field
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Flexible(child: field),
                Text(suffix, style: context.textTheme.bodyMedium),
              ],
            ),
    );
  }

  Widget _buildUrlItem(String? url, Widget leading) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.testUrl,
      leading: leading,
      trailing: TextFormField(
        keyboardType: TextInputType.url,
        inputFormatters: TextInputLimits.limit(TextInputLimits.url),
        textAlign: TextAlign.end,
        initialValue: url,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(url: value));
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildPickerItem({
    required String title,
    required String value,
    required VoidCallback onPressed,
    required Widget leading,
    List<CustomIssue> issues = const [],
  }) {
    final invalid = issues.isNotEmpty;
    return _buildItem(
      invalid: invalid,
      leading: leading,
      title: title,
      onPressed: onPressed,
      trailing: Row(
        spacing: 2,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (invalid) CustomIssueButton(issues: issues),
          Flexible(
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const GlyphIcon(AppGlyphs.chevronForward),
        ],
      ),
    );
  }

  Widget _buildHashKeyItem(String? hashKey, Widget leading) {
    final value = hashKey == _inUserHashKey;
    void handleChangeHashKey() {
      ref
          .read(proxyGroupProvider.notifier)
          .update(
            (state) => state.copyWith(hashKey: value ? null : _inUserHashKey),
          );
    }

    return _buildItem(
      title: context.appLocalizations.hashByInUser,
      leading: leading,
      onPressed: handleChangeHashKey,
      trailing: Switch(
        value: value,
        onChanged: (_) {
          handleChangeHashKey();
        },
      ),
    );
  }

  Widget _buildStrategyItem(LoadBalanceStrategy? strategy, Widget leading) {
    return _buildPickerItem(
      title: context.appLocalizations.strategy,
      value: (strategy ?? LoadBalanceStrategy.consistentHashing).value,
      onPressed: _showStrategyOptions,
      leading: leading,
    );
  }

  Widget _buildExpectedStatusItem(String? expectedStatus, Widget leading) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.expectedStatus,
      leading: leading,
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: expectedStatus,
        inputFormatters: TextInputLimits.limit(TextInputLimits.status),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(expectedStatus: value));
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildTypeItem(GroupType type) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.proxyType,
      onPressed: _showTypeOptions,
      trailing: Row(
        spacing: 2,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              type.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const GlyphIcon(AppGlyphs.chevronForward),
        ],
      ),
    );
  }

  Widget _buildIconItem(String? icon) {
    final appLocalizations = context.appLocalizations;
    final src = icon?.value;
    return _buildItem(
      title: appLocalizations.icon,
      onPressed: () {
        _showIconPicker(src);
      },
      trailing: Row(
        spacing: 2,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (src != null)
            SizedBox.square(
              dimension: 28,
              child: IconTheme.merge(
                data: const IconThemeData(size: 28),
                child: CommonTargetIcon(src: src),
              ),
            )
          else
            Text(
              appLocalizations.optional,
              style: context.listTitleStyle?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          const GlyphIcon(AppGlyphs.chevronForward),
        ],
      ),
    );
  }

  Widget _buildNameItem(String name, {bool invalid = false}) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      invalid: invalid,
      title: appLocalizations.name,
      trailing: TextFormField(
        initialValue: name,
        keyboardType: TextInputType.name,
        inputFormatters: TextInputLimits.policyName(TextInputLimits.groupName),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(name: value));
        },
        onFieldSubmitted: (_) {
          _handleSave();
        },
        textAlign: TextAlign.end,
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.inputProxyGroupName,
        ),
      ),
    );
  }

  Widget _buildHiddenItem(bool? hidden, Widget leading) {
    final appLocalizations = context.appLocalizations;
    void handleChangeHidden() {
      ref
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(hidden: !(hidden ?? false)));
    }

    return _buildItem(
      title: appLocalizations.hideFromList,
      leading: leading,
      onPressed: handleChangeHidden,
      trailing: Switch(
        value: hidden ?? false,
        onChanged: (_) {
          handleChangeHidden();
        },
      ),
    );
  }

  Widget _buildLazyItem(bool? lazy, Widget leading) {
    final appLocalizations = context.appLocalizations;
    // The core defaults lazy to true, so an untouched group already tests lazily.
    final value = lazy ?? true;
    void handleChangeLazy() {
      ref
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(lazy: !value));
    }

    return _buildItem(
      title: appLocalizations.testWhenUsed,
      leading: leading,
      onPressed: handleChangeLazy,
      trailing: Switch(
        value: value,
        onChanged: (_) {
          handleChangeLazy();
        },
      ),
    );
  }

  Widget _buildDisableUDPItem(bool? disableUDP, Widget leading) {
    final appLocalizations = context.appLocalizations;
    void handleChangeDisableUDP() {
      ref
          .read(proxyGroupProvider.notifier)
          .update(
            (state) => state.copyWith(disableUDP: !(disableUDP ?? false)),
          );
    }

    return _buildItem(
      title: appLocalizations.disableUDP,
      leading: leading,
      onPressed: handleChangeDisableUDP,
      trailing: Switch(
        value: disableUDP ?? false,
        onChanged: (_) {
          handleChangeDisableUDP();
        },
      ),
    );
  }

  Widget _field<S>(
    S Function(ProxyGroup state) selector,
    Widget Function(S value) builder,
  ) {
    return Consumer(
      builder: (_, ref, _) =>
          builder(ref.watch(proxyGroupProvider.select(selector))),
    );
  }

  /// A removed option is cleared at once, so while its row collapses it shows
  /// the value it had rather than the cleared one.
  Widget _optionField<S>(
    _GroupOption option,
    S Function(ProxyGroup state) selector,
    Widget Function(S value) builder,
  ) {
    return Consumer(
      builder: (_, ref, _) {
        final removedFrom = _shown.contains(option)
            ? null
            : _removedFrom[option];
        return builder(
          removedFrom != null
              ? selector(removedFrom)
              : ref.watch(proxyGroupProvider.select(selector)),
        );
      },
    );
  }

  Future<void> _handleDelete(int profileId) async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.confirmDeleteProxyGroup),
    );
    if (res == true && mounted) {
      final id = ref.read(proxyGroupProvider).id;
      ref.read(proxyGroupsProvider(profileId).notifier).delAll([id]);
      context.safeNestedPop();
    }
  }

  Future<void> _handleSave() async {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    if (_saving || ref.read(customProfileDataProvider(profileId)) == null) {
      return;
    }
    _saving = true;
    setState(() {
      _submitted = true;
    });
    try {
      if (await _handleSaveProxyGroup(context, ref) && mounted) {
        context.safeNestedPop();
      }
    } finally {
      _saving = false;
    }
  }

  Future<void> _handleQuickEdit() {
    final group = ref.read(proxyGroupProvider);
    return showCustomQuickEdit(
      context,
      title: group.name.isEmpty
          ? context.appLocalizations.quickEdit
          : group.name,
      content: group.definitionYaml,
      schema: EditorSchema.proxyGroup,
      invalidMessage: context.appLocalizations.definitionNotMap,
      apply: (content) {
        final group = readRelaxed(
          content,
          EditorSchema.proxyGroup,
          ref.read(proxyGroupProvider).withDefinitionYaml,
        );
        ref.read(proxyGroupProvider.notifier).value = group;
        if (mounted) {
          setState(() {
            _shown = _shownIn(group);
            _revision++;
          });
        }
      },
    );
  }

  static Set<_GroupOption> _shownIn(ProxyGroup group) => {
    for (final option in _GroupOption.values)
      if (option.isSetIn(group)) option,
  };

  void _handleAddOption(List<_GroupOption> options) {
    final appLocalizations = context.appLocalizations;
    final sections = <String, List<_GroupOption>>{};
    for (final option in options) {
      sections
          .putIfAbsent(option.section(appLocalizations), () => [])
          .add(option);
    }
    Navigator.of(context).push(
      PagedSheetRoute(
        builder: (_) => SelectionSheet<_GroupOption>(
          title: appLocalizations.addSettingEntry,
          sections: [
            for (final MapEntry(:key, :value) in sections.entries)
              SelectionSection(label: key, items: value),
          ],
          labelBuilder: (option) => option.label(appLocalizations),
          selectedOf: (_) => null,
          removeOnSelect: true,
          onSelected: _handleAddedOption,
        ),
      ),
    );
  }

  void _handleAddedOption(_GroupOption option) {
    if (!mounted) {
      return;
    }
    ref.read(proxyGroupProvider.notifier).update(option.reset);
    setState(() {
      _shown = {..._shown, option};
    });
  }

  void _handleRemoveOption(_GroupOption option) {
    _removedFrom[option] = ref.read(proxyGroupProvider);
    ref.read(proxyGroupProvider.notifier).update(option.clear);
    setState(() {
      _shown = {..._shown}..remove(option);
    });
  }

  Widget _buildOption(
    _GroupOption option, {
    required List<CustomIssue> emptyFallbackIssues,
  }) {
    final appLocalizations = context.appLocalizations;
    final leading = EntryButton.remove(
      onPressed: () => _handleRemoveOption(option),
    );
    return switch (option) {
      _GroupOption.emptyFallback => _optionField(
        option,
        (state) => state.emptyFallback,
        (value) => _buildPickerItem(
          title: appLocalizations.emptyFallback,
          value: value ?? _defaultEmptyFallback,
          leading: leading,
          issues: emptyFallbackIssues,
          onPressed: _showEmptyFallbackOptions,
        ),
      ),
      _GroupOption.url => _optionField(
        option,
        (state) => state.url,
        (value) => _buildUrlItem(value, leading),
      ),
      _GroupOption.interval => _optionField(
        option,
        (state) => state.interval,
        (value) => _buildNumberItem(
          title: appLocalizations.testInterval,
          value: value,
          leading: leading,
          suffix: 's',
          apply: (state, value) => state.copyWith(interval: value),
        ),
      ),
      _GroupOption.timeout => _optionField(
        option,
        (state) => state.timeout,
        (value) => _buildNumberItem(
          title: appLocalizations.timeout,
          value: value,
          leading: leading,
          suffix: 'ms',
          apply: (state, value) => state.copyWith(timeout: value),
        ),
      ),
      _GroupOption.maxFailedTimes => _optionField(
        option,
        (state) => state.maxFailedTimes,
        (value) => _buildNumberItem(
          title: appLocalizations.maxFailedTimes,
          value: value,
          leading: leading,
          apply: (state, value) => state.copyWith(maxFailedTimes: value),
        ),
      ),
      _GroupOption.lazy => _optionField(
        option,
        (state) => state.lazy,
        (value) => _buildLazyItem(value, leading),
      ),
      _GroupOption.expectedStatus => _optionField(
        option,
        (state) => state.expectedStatus,
        (value) => _buildExpectedStatusItem(value, leading),
      ),
      _GroupOption.tolerance => _optionField(
        option,
        (state) => state.tolerance,
        (value) => _buildNumberItem(
          title: appLocalizations.tolerance,
          value: value,
          leading: leading,
          suffix: 'ms',
          apply: (state, value) => state.copyWith(tolerance: value),
        ),
      ),
      _GroupOption.defaultSelected => _optionField(
        option,
        (state) => state.defaultSelected,
        (value) => _buildPickerItem(
          title: appLocalizations.defaultSelected,
          value: value ?? appLocalizations.defaultText,
          leading: leading,
          onPressed: _showDefaultSelectedOptions,
        ),
      ),
      _GroupOption.strategy => _optionField(
        option,
        (state) => state.strategy,
        (value) => _buildStrategyItem(value, leading),
      ),
      _GroupOption.hashKey => _optionField(
        option,
        (state) => state.hashKey,
        (value) => _buildHashKeyItem(value, leading),
      ),
      _GroupOption.hidden => _optionField(
        option,
        (state) => state.hidden,
        (value) => _buildHiddenItem(value, leading),
      ),
      _GroupOption.disableUDP => _optionField(
        option,
        (state) => state.disableUDP,
        (value) => _buildDisableUDPItem(value, leading),
      ),
    };
  }

  Widget _buildOptions({required List<CustomIssue> emptyFallbackIssues}) {
    final appLocalizations = context.appLocalizations;
    final (type, strategy) = ref.watch(
      proxyGroupProvider.select((state) => (state.type, state.strategy)),
    );
    final applicable = [
      for (final option in _GroupOption.values)
        if (option.appliesTo(type, strategy)) option,
    ];
    final shown = applicable.where(_shown.contains).toList();
    final remaining = [
      for (final option in applicable)
        if (!_shown.contains(option)) option,
    ];
    void handleAdd() => _handleAddOption(remaining);
    return generateAnimatedSection(
      title: appLocalizations.options,
      items: [
        for (final option in shown)
          KeyedSubtree(
            key: ValueKey(option),
            child: _buildOption(
              option,
              emptyFallbackIssues: emptyFallbackIssues,
            ),
          ),
        if (remaining.isNotEmpty)
          FormRow(
            key: const ValueKey(#add),
            leading: EntryButton.add(onPressed: handleAdd),
            title: appLocalizations.addSettingEntry,
            titleStyle: TextStyle(color: context.colorScheme.primary),
            onPressed: handleAdd,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final profileData = ref.watch(customProfileDataProvider(profileId));
    final showIncomplete = !_isNew || _submitted;
    final issues = [
      ...ref
          .watch(
            proxyGroupProvider.select(
              (state) => SelectValue(
                profileData == null
                    ? const <CustomIssue>[]
                    : proxyGroupIssues(state, profileData),
              ),
            ),
          )
          .value,
      ..._filterIssues(appLocalizations, _filterErrors),
    ].where((issue) => showIncomplete || !issue.isIncomplete).toList();
    final nameInvalid = issues.any(
      (issue) =>
          issue is EmptyNameIssue ||
          issue is ReservedNameIssue ||
          issue is DuplicateNameIssue,
    );
    final emptyFallbackIssues = issues
        .whereType<InvalidEmptyFallbackIssue>()
        .toList();
    return CommonScaffold(
      iconActions: customFormActions(
        context,
        onQuickEdit: _handleQuickEdit,
        onSave: _handleSave,
      ),
      body: CustomScrollView(
        key: ValueKey(_revision),
        slivers: [
          SliverCustomIssuesBanner(issues: issues),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                generateSectionV3(
                  title: appLocalizations.general,
                  items: [
                    _field(
                      (state) => state.name,
                      (value) => _buildNameItem(value, invalid: nameInvalid),
                    ),
                    _field((state) => state.type, _buildTypeItem),
                    _field((state) => state.icon, _buildIconItem),
                  ],
                ),
              ],
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: ProxyGroupMembersSliver(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 20),
            sliver: SliverList.list(
              children: [
                _buildOptions(emptyFallbackIssues: emptyFallbackIssues),
                generateSectionV3(
                  title: appLocalizations.action,
                  items: [
                    if (!_isNew)
                      _buildItem(
                        title: appLocalizations.delete,
                        titleStyle: TextStyle(color: context.colorScheme.error),
                        onPressed: () {
                          _handleDelete(profileId);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      title: _isNew
          ? appLocalizations.addProxyGroup
          : appLocalizations.editProxyGroup,
    );
  }
}

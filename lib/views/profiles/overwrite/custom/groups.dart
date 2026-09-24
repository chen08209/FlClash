import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxy_providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'icon.dart';
import 'proxies.dart';

class CustomProxyGroupsView extends ConsumerStatefulWidget {
  final int profileId;

  const CustomProxyGroupsView(this.profileId, {super.key});

  @override
  ConsumerState createState() => _CustomProxyGroupsViewState();
}

class _CustomProxyGroupsViewState extends ConsumerState<CustomProxyGroupsView> {
  void _handleReorder(int oldIndex, int newIndex) {
    ref
        .read(proxyGroupsProvider(widget.profileId).notifier)
        .order(oldIndex, newIndex);
  }

  void _handleAddOrUpdate({ProxyGroup? proxyGroup}) {
    showOverwriteNestedSheet<ProxyGroup>(
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
      save: _handleSaveProxyGroup,
      formBuilder: (_) => const EditProxyGroupView(),
    );
  }

  void _handleDelete(Set<int> proxyGroupIds) {
    ref
        .read(proxyGroupsProvider(widget.profileId).notifier)
        .delAll(proxyGroupIds);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return OverwriteEditorPage<ProxyGroup, int>(
      title: appLocalizations.proxyGroup,
      selectionEnabled: true,
      dragFromRow: true,
      idOf: (proxyGroup) => proxyGroup.id,
      itemsOf: (ref) {
        return ref.watch(proxyGroupsProvider(widget.profileId)).value;
      },
      itemBuilder:
          (
            context,
            ref,
            proxyGroup,
            index,
            isEditing,
            isSelected,
            onToggleSelected,
          ) {
            return _ProxyGroupItem(
              profileId: widget.profileId,
              proxyGroup: proxyGroup,
              isEditing: isEditing,
              isSelected: isSelected,
              onSelected: onToggleSelected,
              onPressed: () {
                _handleAddOrUpdate(proxyGroup: proxyGroup);
              },
            );
          },
      onReorder: _handleReorder,
      onAdd: _handleAddOrUpdate,
      onDelete: _handleDelete,
      searchFieldsOf: (proxyGroup) => [proxyGroup.name, proxyGroup.type.name],
      emptyLabel: appLocalizations.proxyGroupEmpty,
      itemExtent:
          globalState.measure.bodyLargeHeight +
          globalState.measure.bodyMediumHeight +
          16,
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
          customOverwriteIssuesProvider(profileId).select(
            (state) => SelectValue(
              state.proxyGroups[proxyGroup.id] ?? const <OverwriteIssue>[],
            ),
          ),
        )
        .value;
    return DecorationListItem(
      invalid: issues.isNotEmpty,
      isSelected: isSelected,
      onPressed: isEditing ? onSelected : onPressed,
      contentPadding: const EdgeInsets.only(left: 16),
      minVerticalPadding: 8,
      leading: SizedBox.square(
        dimension: 32,
        child: IconTheme.merge(
          data: const IconThemeData(size: 32),
          child: CommonTargetIcon(src: proxyGroup.icon ?? ''),
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
          if (issues.isNotEmpty) OverwriteIssueButton(issues: issues),
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
bool _blocksSave(OverwriteIssue issue) => switch (issue) {
  EmptyNameIssue() ||
  ReservedNameIssue() ||
  DuplicateNameIssue() ||
  NoProxySourceIssue() ||
  GroupLoopIssue() => true,
  _ => false,
};

bool _handleSaveProxyGroup(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  final proxyGroup = ref.read(proxyGroupProvider);
  final profileId = ProfileIdProvider.of(context)!.profileId;
  final blocking = proxyGroupIssues(
    proxyGroup,
    ref.read(customOverwriteDateProvider(profileId)),
  ).where(_blocksSave).toList();
  if (blocking.isNotEmpty) {
    showOverwriteIssues(context, blocking);
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
    dialogs.showMessage(
      message: TextSpan(text: appLocalizations.proxyGroupNameDuplicate),
      cancelable: false,
    );
    return false;
  } else {
    return true;
  }
}

class EditProxyGroupView extends ConsumerStatefulWidget {
  const EditProxyGroupView({super.key});

  @override
  ConsumerState createState() => _EditProxyGroupViewState();
}

class _EditProxyGroupViewState extends ConsumerState<EditProxyGroupView> {
  Future<void> _showTypeOptions(GroupType type) async {
    final value = await dialogs.showCommonDialog<GroupType>(
      child: OptionsDialog<GroupType>(
        title: context.appLocalizations.proxyType,
        options: GroupType.selectableValues,
        textBuilder: (item) => item.name,
        value: type,
      ),
    );
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(type: value));
  }

  Future<void> _showStrategyOptions(LoadBalanceStrategy? strategy) async {
    final value = await dialogs.showCommonDialog<LoadBalanceStrategy>(
      child: OptionsDialog<LoadBalanceStrategy>(
        title: context.appLocalizations.strategy,
        options: LoadBalanceStrategy.values,
        textBuilder: (item) => item.value,
        value: strategy ?? LoadBalanceStrategy.consistentHashing,
      ),
    );
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(strategy: value));
  }

  Future<void> _showIconEdit(String? icon) async {
    final value = await Navigator.of(
      context,
    ).push<String>(PagedSheetRoute(builder: (context) => IconEditView(icon)));
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(icon: value));
  }

  Widget _buildItem({
    required String title,
    TextStyle? titleStyle,
    Widget? trailing,
    final VoidCallback? onPressed,
    bool invalid = false,
  }) {
    return OverwriteFormRow(
      invalid: invalid,
      onPressed: onPressed,
      title: title,
      titleStyle: titleStyle,
      trailing: trailing,
    );
  }

  void _handleToProxiesView() {
    Navigator.of(
      context,
    ).push(PagedSheetRoute(builder: (context) => const EditProxiesView()));
  }

  void _handleToProvidersView() {
    Navigator.of(context).push(
      PagedSheetRoute(builder: (context) => const EditProxyProvidersView()),
    );
  }

  Widget _buildProvidersItem(
    bool includeAllProviders,
    List<String> use,
    List<OverwriteIssue> issues,
  ) {
    final appLocalizations = context.appLocalizations;
    final invalid = issues.isNotEmpty;
    return Consumer(
      builder: (_, ref, _) {
        return _buildItem(
          invalid: invalid,
          title: appLocalizations.selectProxyProviders,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              invalid
                  ? OverwriteIssueButton(issues: issues)
                  : (!includeAllProviders
                        ? _NumberCard(number: use.length)
                        : const _CheckIcon()),
              const GlyphIcon(AppGlyphs.chevronForward),
            ],
          ),
          onPressed: _handleToProvidersView,
        );
      },
    );
  }

  Widget _buildFilterItem(String? filter) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.proxyFilter,
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: filter,
        inputFormatters: TextInputLimits.limit(TextInputLimits.filter),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(filter: value));
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildNumberItem({
    required String title,
    required int? value,
    required ProxyGroup Function(ProxyGroup state, int? value) apply,
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

  Widget _buildUrlItem(String? url) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.testUrl,
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

  Widget _buildStrategyItem(LoadBalanceStrategy? strategy) {
    return _buildItem(
      title: context.appLocalizations.strategy,
      onPressed: () {
        _showStrategyOptions(strategy);
      },
      trailing: Text((strategy ?? LoadBalanceStrategy.consistentHashing).value),
    );
  }

  Widget _buildExcludeFilterItem(String? excludeFilter) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.excludeProxyFilter,
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: excludeFilter,
        inputFormatters: TextInputLimits.limit(TextInputLimits.filter),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(excludeFilter: value));
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildExcludeTypeItem(String? type) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.excludeType,
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: type,
        inputFormatters: TextInputLimits.limit(TextInputLimits.name),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(excludeType: value));
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildExpectedStatusItem(String? expectedStatus) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.expectedStatus,
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

  Widget _buildProxiesItem(
    bool includeAllProxies,
    List<String> proxies,
    List<OverwriteIssue> issues,
  ) {
    final appLocalizations = context.appLocalizations;
    final invalid = issues.isNotEmpty;
    return Consumer(
      builder: (_, ref, _) {
        return _buildItem(
          invalid: invalid,
          title: appLocalizations.selectProxies,
          trailing: Row(
            spacing: 2,
            mainAxisSize: MainAxisSize.min,
            children: [
              invalid
                  ? OverwriteIssueButton(issues: issues)
                  : (!includeAllProxies
                        ? _NumberCard(number: proxies.length)
                        : const _CheckIcon()),
              const GlyphIcon(AppGlyphs.chevronForward),
            ],
          ),
          onPressed: _handleToProxiesView,
        );
      },
    );
  }

  Widget _buildTypeItem(GroupType type) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.proxyType,
      onPressed: () {
        _showTypeOptions(type);
      },
      trailing: Text(type.name),
    );
  }

  Widget _buildIconItem(String? icon) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: appLocalizations.icon,
      onPressed: () {
        _showIconEdit(icon);
      },
      trailing: TooltipText(
        text: Text(
          icon?.value ?? appLocalizations.optional,
          maxLines: 1,
          style: context.textTheme.bodyLarge?.copyWith(
            color: icon == null ? context.colorScheme.onSurfaceVariant : null,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
        inputFormatters: TextInputLimits.limit(TextInputLimits.groupName),
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

  Widget _buildHiddenItem(bool? hidden) {
    final appLocalizations = context.appLocalizations;
    void handleChangeHidden() {
      ref
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(hidden: !(hidden ?? false)));
    }

    return _buildItem(
      title: appLocalizations.hideFromList,
      onPressed: handleChangeHidden,
      trailing: Switch(
        value: hidden ?? false,
        onChanged: (_) {
          handleChangeHidden();
        },
      ),
    );
  }

  Widget _buildLazyItem(bool? lazy) {
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
      onPressed: handleChangeLazy,
      trailing: Switch(
        value: value,
        onChanged: (_) {
          handleChangeLazy();
        },
      ),
    );
  }

  Widget _buildDisableUDPItem(bool? disableUDP) {
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
    if (_handleSaveProxyGroup(context, ref)) {
      context.safeNestedPop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final id = ref.watch(proxyGroupProvider.select((state) => state.id));
    final type = ref.watch(proxyGroupProvider.select((state) => state.type));
    final overwrite = ref.watch(customOverwriteDateProvider(profileId));
    final issues = ref
        .watch(
          proxyGroupProvider.select(
            (state) => SelectValue(proxyGroupIssues(state, overwrite)),
          ),
        )
        .value;
    final nameInvalid = issues.any(
      (issue) =>
          issue is EmptyNameIssue ||
          issue is ReservedNameIssue ||
          issue is DuplicateNameIssue,
    );
    final proxiesIssues = issues.whereType<MissingProxiesIssue>().toList();
    final providersIssues = issues.whereType<MissingProvidersIssue>().toList();
    final height = ref.sheetHeight(context, 0.65);
    return CommonScaffold(
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.check,
            onPressed: _handleSave,
            tooltip: context.appLocalizations.save,
          ),
        ),
      ],
      body: SizedBox(
        height: height,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 20, top: context.contentTopPadding),
          children: [
            OverwriteIssuesBanner(issues: issues),
            generateSectionV3(
              title: appLocalizations.general,
              items: [
                _field(
                  (state) => state.name,
                  (value) => _buildNameItem(value, invalid: nameInvalid),
                ),
                _field((state) => state.type, _buildTypeItem),
                _field((state) => state.icon, _buildIconItem),
                _field((state) => state.hidden, _buildHiddenItem),
                _field((state) => state.disableUDP, _buildDisableUDPItem),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.proxies,
              items: [
                _field(
                  (state) => (
                    state.includeAllProxies ?? false,
                    state.proxies ?? const <String>[],
                  ),
                  (value) =>
                      _buildProxiesItem(value.$1, value.$2, proxiesIssues),
                ),
                _field(
                  (state) => (
                    state.includeAllProviders ?? false,
                    state.use ?? const <String>[],
                  ),
                  (value) =>
                      _buildProvidersItem(value.$1, value.$2, providersIssues),
                ),
                _field((state) => state.filter, _buildFilterItem),
                _field((state) => state.excludeFilter, _buildExcludeFilterItem),
                _field((state) => state.excludeType, _buildExcludeTypeItem),
                _field(
                  (state) => state.expectedStatus,
                  _buildExpectedStatusItem,
                ),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.other,
              items: [
                _field((state) => state.url, _buildUrlItem),
                _field(
                  (state) => state.interval,
                  (value) => _buildNumberItem(
                    title: appLocalizations.testInterval,
                    value: value,
                    suffix: 's',
                    apply: (state, value) => state.copyWith(interval: value),
                  ),
                ),
                _field(
                  (state) => state.timeout,
                  (value) => _buildNumberItem(
                    title: appLocalizations.timeout,
                    value: value,
                    suffix: 'ms',
                    apply: (state, value) => state.copyWith(timeout: value),
                  ),
                ),
                _field(
                  (state) => state.maxFailedTimes,
                  (value) => _buildNumberItem(
                    title: appLocalizations.maxFailedTimes,
                    value: value,
                    apply: (state, value) =>
                        state.copyWith(maxFailedTimes: value),
                  ),
                ),
                _field((state) => state.lazy, _buildLazyItem),
                if (type == GroupType.URLTest)
                  _field(
                    (state) => state.tolerance,
                    (value) => _buildNumberItem(
                      title: appLocalizations.tolerance,
                      value: value,
                      suffix: 'ms',
                      apply: (state, value) => state.copyWith(tolerance: value),
                    ),
                  ),
                if (type == GroupType.LoadBalance)
                  _field((state) => state.strategy, _buildStrategyItem),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.action,
              items: [
                if (id != -1)
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
      title: id == -1
          ? appLocalizations.addProxyGroup
          : appLocalizations.editProxyGroup,
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: GlyphIcon(
        AppGlyphs.checkCircle,
        size: 20.ap,
        color: context.colorScheme.success,
      ),
    );
  }
}

class _NumberCard extends StatelessWidget {
  final int number;

  const _NumberCard({required this.number});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: AppShape.md,
      child: Container(
        constraints: const BoxConstraints(minWidth: 32),
        alignment: Alignment.center,
        height: globalState.measure.bodySmallHeight + 6,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Text(
          textAlign: TextAlign.center,
          '$number',
          style: context.textTheme.bodySmall,
        ),
      ),
    );
  }
}

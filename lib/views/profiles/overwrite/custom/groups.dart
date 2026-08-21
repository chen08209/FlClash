import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/overwrite.dart';
import 'package:fl_clash/models/models.dart' hide FileInfo;
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/proxy_providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

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
      formBuilder: (_) => const _EditProxyGroupView(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return OverwriteEditorPage<ProxyGroup>(
      title: appLocalizations.proxyGroup,
      idOf: (proxyGroup) => proxyGroup.id,
      itemsOf: (ref) {
        return ref
            .watch(
              customOverwriteDateProvider(
                widget.profileId,
              ).select((state) => SelectValue(state.proxyGroups)),
            )
            .value;
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
              key: ValueKey(proxyGroup.id),
              profileId: widget.profileId,
              proxyGroup: proxyGroup,
              index: index,
              onPressed: () {
                _handleAddOrUpdate(proxyGroup: proxyGroup);
              },
            );
          },
      onReorder: _handleReorder,
      onAdd: _handleAddOrUpdate,
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
  final int index;
  final VoidCallback onPressed;

  const _ProxyGroupItem({
    super.key,
    required this.profileId,
    required this.proxyGroup,
    required this.index,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final isValid = !ref.watch(
      invalidProxyGroupIdsProvider(
        profileId,
      ).select((state) => state.contains(proxyGroup.id)),
    );
    return DecorationListItem(
      invalid: !isValid,
      onPressed: onPressed,
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
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
          if (!isValid)
            InfoMessageButton(
              message: appLocalizations.proxyGroupDetectedAbnormal,
            ),
          ReorderableDelayedDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: const Icon(Icons.drag_handle),
            ),
          ),
        ],
      ),
    );
  }
}

bool _handleSaveProxyGroup(BuildContext context, WidgetRef ref) {
  final appLocalizations = context.appLocalizations;
  final proxyGroup = ref.read(proxyGroupProvider);
  if (proxyGroup.name.isEmpty) {
    dialogs.showMessage(
      message: TextSpan(text: appLocalizations.proxyGroupNameEmpty),
      cancelable: false,
    );
    return false;
  }
  final profileId = ProfileIdProvider.of(context)!.profileId;
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

class _EditProxyGroupView extends ConsumerStatefulWidget {
  const _EditProxyGroupView();

  @override
  ConsumerState createState() => _EditProxyGroupViewState();
}

class _EditProxyGroupViewState extends ConsumerState<_EditProxyGroupView> {
  Future<void> _showTypeOptions(GroupType type) async {
    final value = await dialogs.showCommonDialog<GroupType>(
      child: OptionsDialog<GroupType>(
        title: context.appLocalizations.proxyType,
        options: GroupType.values,
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
    required Widget title,
    Widget? trailing,
    final VoidCallback? onPressed,
    bool invalid = false,
  }) {
    return OverwriteFormRow(
      invalid: invalid,
      onPressed: onPressed,
      title: title,
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

  Widget _buildProvidersItem(bool includeAllProviders, List<String> use) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    return Consumer(
      builder: (_, ref, _) {
        final invalid = !ref.watch(
          customOverwriteUseIsValidProvider(profileId, use),
        );
        return _buildItem(
          invalid: invalid,
          title: Text(appLocalizations.selectProxyProviders),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              invalid
                  ? InfoMessageButton(
                      message: appLocalizations.proxyProviderDetectedAbnormal,
                    )
                  : (!includeAllProviders
                        ? _NumberCard(number: use.length)
                        : const _CheckIcon()),
              const Icon(Icons.arrow_forward_ios),
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
      title: Text(appLocalizations.proxyFilter),
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

  Widget _buildMaxFailedTimesItem(int? maxFailedTimes) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.maxFailedTimes),
      trailing: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.number),
        textAlign: TextAlign.end,
        initialValue: maxFailedTimes?.toString(),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update(
                (state) => state.copyWith(maxFailedTimes: int.tryParse(value)),
              );
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildUrlItem(String? url) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.testUrl),
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

  Widget _buildIntervalItem(int? interval) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.testInterval),
      trailing: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.interval),
        textAlign: TextAlign.end,
        initialValue: interval?.toString(),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(interval: int.tryParse(value)));
        },
        decoration: InputDecoration.collapsed(
          border: const NoInputBorder(),
          hintText: appLocalizations.optional,
        ),
      ),
    );
  }

  Widget _buildExcludeFilterItem(String? excludeFilter) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.excludeProxyFilter),
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
      title: Text(appLocalizations.excludeType),
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
      title: Text(appLocalizations.expectedStatus),
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

  Widget _buildProxiesItem(bool includeAllProxies, List<String> proxies) {
    final appLocalizations = context.appLocalizations;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    return Consumer(
      builder: (_, ref, _) {
        final invalid = !ref.watch(
          customOverwriteProxiesIsValidProvider(profileId, proxies),
        );
        return _buildItem(
          invalid: invalid,
          title: Text(appLocalizations.selectProxies),
          trailing: Row(
            spacing: 2,
            mainAxisSize: MainAxisSize.min,
            children: [
              invalid
                  ? InfoMessageButton(
                      message: appLocalizations.proxyDetectedAbnormal,
                    )
                  : (!includeAllProxies
                        ? _NumberCard(number: proxies.length)
                        : const _CheckIcon()),
              const Icon(Icons.arrow_forward_ios),
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
      title: Text(appLocalizations.proxyType),
      onPressed: () {
        _showTypeOptions(type);
      },
      trailing: Text(type.name),
    );
  }

  Widget _buildIconItem(String? icon) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.icon),
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

  Widget _buildNameItem(String name) {
    final appLocalizations = context.appLocalizations;
    return _buildItem(
      title: Text(appLocalizations.name),
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
      title: Text(appLocalizations.hideFromList),
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
    void handleChangeLazy() {
      ref
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(lazy: !(lazy ?? false)));
    }

    return _buildItem(
      title: Text(appLocalizations.testWhenUsed),
      onPressed: handleChangeLazy,
      trailing: Switch(
        value: lazy ?? false,
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
      title: Text(appLocalizations.disableUDP),
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
      final name = ref.read(proxyGroupProvider).name;
      ref.read(proxyGroupsProvider(profileId).notifier).del(name);
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
    final height = ref.sheetHeight(context, 0.65);
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      actions: [
        IconButtonData(
          icon: Icons.check,
          onPressed: _handleSave,
          tooltip: context.appLocalizations.save,
        ),
      ],
      body: SizedBox(
        height: height,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 20, top: context.sheetTopPadding),
          children: [
            generateSectionV3(
              title: appLocalizations.general,
              items: [
                _field((state) => state.name, _buildNameItem),
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
                  (value) => _buildProxiesItem(value.$1, value.$2),
                ),
                _field(
                  (state) => (
                    state.includeAllProviders ?? false,
                    state.use ?? const <String>[],
                  ),
                  (value) => _buildProvidersItem(value.$1, value.$2),
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
                  (state) => state.maxFailedTimes,
                  _buildMaxFailedTimesItem,
                ),
                _field((state) => state.lazy, _buildLazyItem),
                _field((state) => state.interval, _buildIntervalItem),
              ],
            ),
            generateSectionV3(
              title: appLocalizations.action,
              items: [
                if (id != -1)
                  _buildItem(
                    title: Text(
                      appLocalizations.delete,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
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
      child: Icon(
        Icons.check_circle_outline,
        size: 20.ap,
        color: Colors.greenAccent.harmonizeWith(context.colorScheme.primary),
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
      shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(14)),
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

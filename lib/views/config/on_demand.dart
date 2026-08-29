import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/permission.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/overwrite/custom/widgets.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class OnDemandView extends ConsumerStatefulWidget {
  const OnDemandView({super.key, this.isAndroid, this.isMacOS});

  final bool? isAndroid;
  final bool? isMacOS;

  @override
  ConsumerState createState() => _OnDemandViewState();
}

class _OnDemandViewState extends ConsumerState<OnDemandView>
    with UniqueKeyStateMixin {
  static const _authorizeButtonPadding = 12.0;
  static const _minAuthorizeButtonWidth = 80.0;
  static const _inlineActionMaxWidthFactor = 0.4;
  static const _descMaxLines = 4;

  /// Matches the horizontal content padding, so a stacked action keeps the same
  /// gap to the card edge as the text does.
  static const _prerequisiteVerticalPadding = 16.0;

  bool get _isAndroid => widget.isAndroid ?? system.isAndroid;

  bool get _isMacOS => widget.isMacOS ?? system.isMacOS;

  void _handlePermanentlyDeniedLocationPermission() {
    if (_isMacOS) {
      final appLocalizations = context.appLocalizations;
      dialogs.showMessage(
        title: appLocalizations.locationPermissionRequired,
        cancelable: false,
        message: TextSpan(
          style: context.textTheme.bodyMedium,
          text: appLocalizations.locationPermissionGuide(appName),
        ),
      );
    } else if (_isAndroid) {
      app?.openAppSettings();
    }
  }

  Future<void> _handleRequestLocationPermission() async {
    final appLocalizations = context.appLocalizations;
    final permission = ref.read(locationPermissionsProvider);
    if (permission == WifiSsidPermission.granted) {
      return;
    }
    if (permission == WifiSsidPermission.permanentlyDenied) {
      _handlePermanentlyDeniedLocationPermission();
      return;
    }
    final permissionsNotifier = ref.read(locationPermissionsProvider.notifier);
    final res = await wifiSsidManager.requestPermission();
    permissionsNotifier.value = res;
    if (!mounted) {
      return;
    }
    switch (getLocationPermissionFollowUp(res)) {
      case LocationPermissionFollowUp.none:
        return;
      case LocationPermissionFollowUp.openSettings:
        _handlePermanentlyDeniedLocationPermission();
        return;
      case LocationPermissionFollowUp.showDeniedMessage:
        break;
    }
    final needGo = await dialogs.showMessage(
      title: appLocalizations.locationPermissionRequired,
      message: TextSpan(text: appLocalizations.locationPermissionDeniedMessage),
      confirmText: appLocalizations.go,
    );
    if (needGo != true) {
      return;
    }
    unawaited(app?.openAppSettings());
  }

  void _handleOpenBatteryOptimizationSettings() {
    final isDisabled = ref.read(batteryOptimizationDisableProvider);
    if (isDisabled) {
      return;
    }
    permissions.needWaitingBatteryOptimizationSettings = true;
    app?.openBatteryOptimizationSettings();
  }

  Future<void> _handleAddOrUpdate([String? ssid]) async {
    final ssids = ref.read(excludeSSIDsProvider);
    final appLocalizations = context.appLocalizations;
    final newSSID = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: ssid == null
            ? appLocalizations.addSsid
            : appLocalizations.editSsid,
        value: ssid ?? '',
        maxLength: 32,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip('SSID').trim();
          }
          if (ssids.contains(value) && ssid != value) {
            return appLocalizations.existsTip('SSID').trim();
          }
          return null;
        },
      ),
    );
    if (newSSID == null || ssid == newSSID) {
      return;
    }
    ref.read(excludeSSIDsProvider.notifier).update((state) {
      final newSSIDS = state.toSet();
      if (ssid != null) {
        newSSIDS.remove(ssid);
      }
      return [...newSSIDS, newSSID];
    });
  }

  void _handleReorder(int oldIndex, newIndex) {
    ref.read(excludeSSIDsProvider.notifier).update((value) {
      return value.copyAndReorder(oldIndex, newIndex);
    });
  }

  Widget _buildItem({
    required String ssid,
    required int index,
    required int length,
    required bool isSelected,
    required bool isEditing,
  }) {
    final position = ItemPosition.get(index, length);
    return ReorderableDelayedDragStartListener(
      key: ValueKey(ssid),
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: SelectedDecorationListItem(
            isEditing: isEditing,
            minVerticalPadding: 8,
            title: TooltipText(
              text: Text(ssid, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            isSelected: isSelected,
            onSelected: () {
              ref.read(itemsProvider(key).notifier).update((state) {
                final newState = Set<String>.from(state)..addOrRemove(ssid);
                return newState;
              });
            },
            onPressed: () {
              _handleAddOrUpdate(ssid);
            },
          ),
        ),
      ),
    );
  }

  void _handleSelectAll() {
    final excludeSSIDs = ref.read(excludeSSIDsProvider).toSet();
    ref.read(itemsProvider(key).notifier).update((selected) {
      return selected.containsAll(excludeSSIDs) ? {} : excludeSSIDs;
    });
  }

  void _handleDelete() {
    final selectedItems = ref.read(itemsProvider(key));
    ref.read(excludeSSIDsProvider.notifier).update((excludeSSIDs) {
      return excludeSSIDs
          .where((item) => !selectedItems.contains(item))
          .toList();
    });
    ref.read(itemsProvider(key).notifier).value = {};
  }

  double _authorizeButtonWidth() {
    final appLocalizations = context.appLocalizations;
    final style = context.textTheme.labelLarge;
    final labelWidth =
        [appLocalizations.tapToAuthorize, appLocalizations.authorized]
            .map(
              (label) => globalState.measure
                  .computeTextSize(Text(label, style: style))
                  .width,
            )
            .reduce(math.max);
    return math.max(
      _minAuthorizeButtonWidth,
      labelWidth + _authorizeButtonPadding * 2,
    );
  }

  Widget _buildAuthorizeButton({
    required bool authorized,
    required VoidCallback onPressed,
  }) {
    final appLocalizations = context.appLocalizations;
    return CommonMinFilledButtonTheme(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: authorized ? null : context.colorScheme.error,
          padding: const EdgeInsets.symmetric(
            horizontal: _authorizeButtonPadding,
          ),
          minimumSize: const Size(_minAuthorizeButtonWidth, 40),
        ),
        onPressed: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ExcludeSemantics(
              child: Opacity(
                opacity: 0,
                child: Text(
                  authorized
                      ? appLocalizations.tapToAuthorize
                      : appLocalizations.authorized,
                ),
              ),
            ),
            Text(
              authorized
                  ? appLocalizations.authorized
                  : appLocalizations.tapToAuthorize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrerequisiteItem({
    required String title,
    required String desc,
    required Widget action,
  }) {
    return DecorationListItem(
      minVerticalPadding: _prerequisiteVerticalPadding,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final texts = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TooltipLabel(title),
              Text(
                desc,
                maxLines: _descMaxLines,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final isInline =
              _authorizeButtonWidth() <=
              constraints.maxWidth * _inlineActionMaxWidthFactor;
          if (isInline) {
            return Row(
              spacing: 16,
              children: [
                Expanded(child: texts),
                action,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              texts,
              Align(alignment: Alignment.centerRight, child: action),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBatteryOptimizationItem() {
    final appLocalizations = context.appLocalizations;
    final isStart = ref.watch(isStartProvider);
    final isLoading = ref.watch(
      loadingProvider(LoadingTag.batteryOptimization),
    );
    final disabled = ref.watch(batteryOptimizationDisableProvider);
    return _buildPrerequisiteItem(
      title: appLocalizations.ignoreBatteryOptimization,
      desc: appLocalizations.batteryOptimizationDesc,
      action: Stack(
        alignment: Alignment.centerRight,
        children: [
          Visibility(
            visible: !isLoading && !isStart,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: _buildAuthorizeButton(
              authorized: disabled,
              onPressed: _handleOpenBatteryOptimizationSettings,
            ),
          ),
          if (isStart)
            InfoMessageButton(
              message: appLocalizations.batteryOptimizationStatusTip,
            ),
          if (!isStart && isLoading)
            const SizedBox.square(dimension: 32, child: CommonCircleLoading()),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionItem() {
    final appLocalizations = context.appLocalizations;
    final granted = ref.watch(
      locationPermissionsProvider.select(
        (state) => state == WifiSsidPermission.granted,
      ),
    );
    return _buildPrerequisiteItem(
      title: appLocalizations.locationPermission,
      desc: appLocalizations.locationPermissionDesc,
      action: _buildAuthorizeButton(
        authorized: granted,
        onPressed: _handleRequestLocationPermission,
      ),
    );
  }

  Widget _buildPrerequisites() {
    return generateSectionV3(
      title: context.appLocalizations.prerequisites,
      items: [
        if (_isAndroid) _buildBatteryOptimizationItem(),
        if (_isAndroid || _isMacOS) _buildLocationPermissionItem(),
      ],
    );
  }

  Widget _buildExcludeSsidsHeader() {
    final appLocalizations = context.appLocalizations;
    final hasSelection = ref.watch(itemsProvider(key)).isNotEmpty;
    return ListHeader(
      title: appLocalizations.excludeSsids,
      subTitle: appLocalizations.excludeSsidsDesc,
      actions: [
        const SizedBox(width: 8),
        if (hasSelection)
          CommonMinIconButtonTheme(
            child: IconButton.filledTonal(
              tooltip: context.appLocalizations.delete,
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete),
            ),
          ),
        const SizedBox(width: 2),
        CommonMinFilledButtonTheme(
          child: hasSelection
              ? FilledButton(
                  onPressed: _handleSelectAll,
                  child: Text(appLocalizations.selectAll),
                )
              : FilledButton.tonal(
                  onPressed: _handleAddOrUpdate,
                  child: Text(appLocalizations.add),
                ),
        ),
      ],
    );
  }

  Widget _buildExcludeSsidsList(
    List<String> excludeSSIDs,
    Set<dynamic> selectedItems,
  ) {
    if (excludeSSIDs.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 48),
            child: NullStatus(label: context.appLocalizations.ssidsEmpty),
          ),
        ),
      );
    }
    Widget itemAt(int index) => _buildItem(
      isEditing: selectedItems.isNotEmpty,
      ssid: excludeSSIDs[index],
      index: index,
      isSelected: selectedItems.contains(excludeSSIDs[index]),
      length: excludeSSIDs.length,
    );
    return SliverPadding(
      padding: const EdgeInsets.only(top: 12),
      sliver: SliverReorderableList(
        itemBuilder: (_, index) => itemAt(index),
        proxyDecorator: (child, index, animation) =>
            commonProxyDecorator(itemAt(index), index, animation),
        itemCount: excludeSSIDs.length,
        onReorderItem: _handleReorder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final excludeSSIDs = ref.watch(excludeSSIDsProvider);
    final selectedItems = ref.watch(itemsProvider(key));
    return CommonScaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildPrerequisites()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildExcludeSsidsHeader()),
          ),
          _buildExcludeSsidsList(excludeSSIDs, selectedItems),
        ],
      ),
      title: context.appLocalizations.onDemand,
    );
  }
}

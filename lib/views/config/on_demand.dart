import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
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
    final WifiSsidPermission? res;
    try {
      res = await ref.read(locationPermissionsProvider.notifier).request();
    } on PlatformException catch (e) {
      commonPrint.log('requestPermission error $e', logLevel: LogLevel.warning);
      return;
    }
    if (res == null || !mounted) {
      return;
    }
    switch (res) {
      case WifiSsidPermission.granted:
        return;
      case WifiSsidPermission.permanentlyDenied:
        _handlePermanentlyDeniedLocationPermission();
        return;
      case WifiSsidPermission.denied:
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

  void _handleRequestIgnoreBatteryOptimization() {
    if (ref.read(batteryOptimizationIgnoredProvider).value == true) {
      return;
    }
    unawaited(ref.read(batteryOptimizationIgnoredProvider.notifier).request());
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

  Widget _buildAuthorizeButton({
    required bool authorized,
    required VoidCallback onPressed,
  }) {
    final appLocalizations = context.appLocalizations;
    return CommonMinFilledButtonTheme(
      child: ElasticButton(
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
      ),
    );
  }

  Widget _buildPrerequisiteItem({
    required String title,
    required Widget action,
  }) {
    return DecorationListItem(title: TooltipLabel(title), trailing: action);
  }

  Widget _buildBatteryOptimizationItem() {
    final appLocalizations = context.appLocalizations;
    final ignored = ref.watch(batteryOptimizationIgnoredProvider);
    final isLoading = ignored.isLoading;
    return _buildPrerequisiteItem(
      title: appLocalizations.ignoreBatteryOptimization,
      action: Stack(
        alignment: Alignment.centerRight,
        children: [
          Visibility(
            visible: !isLoading,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: _buildAuthorizeButton(
              authorized: ignored.value ?? false,
              onPressed: _handleRequestIgnoreBatteryOptimization,
            ),
          ),
          if (isLoading)
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
      action: _buildAuthorizeButton(
        authorized: granted,
        onPressed: _handleRequestLocationPermission,
      ),
    );
  }

  Widget _buildPrerequisites() {
    final appLocalizations = context.appLocalizations;
    return generateSectionV3(
      title: appLocalizations.prerequisites,
      items: [
        if (_isAndroid) _buildBatteryOptimizationItem(),
        if (_isAndroid || _isMacOS) _buildLocationPermissionItem(),
      ],
      footer: [
        if (_isAndroid) appLocalizations.batteryOptimizationDesc,
        if (_isAndroid || _isMacOS) appLocalizations.locationPermissionDesc,
      ].join('\n'),
    );
  }

  Widget _buildExcludeSsidsHeader() {
    final appLocalizations = context.appLocalizations;
    final hasSelection = ref.watch(itemsProvider(key)).isNotEmpty;
    return ListHeader(
      title: appLocalizations.excludeSsids,
      actions: [
        if (hasSelection)
          CommonMinIconButtonTheme(
            child: ElasticButton(
              child: IconButton.filledTonal(
                tooltip: context.appLocalizations.delete,
                onPressed: _handleDelete,
                icon: const GlyphIcon(AppGlyphs.delete, fill: 1),
              ),
            ),
          ),
        if (hasSelection)
          CommonMinFilledButtonTheme(
            child: ElasticButton(
              child: FilledButton(
                onPressed: _handleSelectAll,
                child: Text(appLocalizations.selectAll),
              ),
            ),
          )
        else
          CommonMinIconButtonTheme(
            child: ElasticButton(
              child: IconButton.filledTonal(
                tooltip: appLocalizations.add,
                onPressed: _handleAddOrUpdate,
                icon: const GlyphIcon(AppGlyphs.addCircle, fill: 1),
              ),
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
            child: NullStatus(
              label: context.appLocalizations.ssidsEmpty,
              illustration: NullStatusIllustration.wifi,
            ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.appBarInset),
            sliver: SliverToBoxAdapter(child: _buildPrerequisites()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildExcludeSsidsHeader()),
          ),
          _buildExcludeSsidsList(excludeSSIDs, selectedItems),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 16),
            sliver: SliverToBoxAdapter(
              child: ListFooter(
                text: context.appLocalizations.excludeSsidsDesc,
              ),
            ),
          ),
        ],
      ),
      title: context.appLocalizations.onDemand,
    );
  }
}

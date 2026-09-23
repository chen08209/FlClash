import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView> {
  late ScrollController _controller;
  List<String>? _pinedList;
  bool _isInit = false;
  bool _installedAppsPermissionGranted = true;

  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _completer.complete(_loadPackages());
    final accessControl = ref
        .read(vpnSettingProvider.select((state) => state.accessControlProps))
        .copyWith();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(accessControlStateProvider.notifier).value = accessControl;
      _isInit = true;
      _pinList();
    });
    ref.listenManual(
      accessControlStateProvider.select((state) => state.mode),
      (_, _) => _pinList(),
    );
  }

  Future<void> _loadPackages() async {
    final action = ref.read(systemActionProvider.notifier);
    final packages = await action.getPackages();
    final granted =
        packages.isNotEmpty || await action.isInstalledAppsPermissionGranted();
    if (!mounted || granted == _installedAppsPermissionGranted) {
      return;
    }
    setState(() {
      _installedAppsPermissionGranted = granted;
    });
  }

  Future<void> _handleGrantInstalledAppsPermission() async {
    final appLocalizations = context.appLocalizations;
    final granted = await ref
        .read(systemActionProvider.notifier)
        .requestInstalledAppsPermission();
    if (!mounted) {
      return;
    }
    if (!granted) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text: appLocalizations.installedAppsPermissionDeniedMessage,
        ),
        confirmText: appLocalizations.settings,
      );
      if (res == true) {
        await app?.openAppSettings();
      }
      return;
    }
    await globalState.loadingRun(_loadPackages, tag: LoadingTag.access);
  }

  void _pinList() {
    if (!_isInit || !mounted) {
      return;
    }
    setState(() {
      _pinedList = ref.read(accessControlStateProvider).currentList;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconButtonData _buildSelectAllAction({
    required bool isSelectedAll,
    required List<String> allValueList,
  }) {
    void onPressed() {
      ref.read(accessControlStateProvider.notifier).update((state) {
        final newSet = Set<String>.from(state.currentList);
        final isSelectedAll = newSet.containsAll(allValueList);
        if (isSelectedAll) {
          newSet.removeAll(allValueList);
        } else {
          newSet.addAll(allValueList);
        }
        return state.copyWithNewList(newSet.toList());
      });
    }

    final appLocalizations = context.appLocalizations;
    return isSelectedAll
        ? IconButtonData(
            glyph: AppGlyphs.deselect,
            tooltip: appLocalizations.cancelSelectAll,
            onPressed: onPressed,
          )
        : IconButtonData(
            glyph: AppGlyphs.selectAll,
            tooltip: appLocalizations.selectAll,
            onPressed: onPressed,
          );
  }

  Future<void> _intelligentSelected() async {
    final packageNames = ref.read(
      packagesProvider.select((state) => state.map((item) => item.packageName)),
    );
    if (packageNames.isEmpty) {
      return;
    }
    final selectedPackageNames =
        (await globalState.loadingRun<List<String>>(() async {
          return await app?.getChinaPackageNames() ?? [];
        }, tag: LoadingTag.access))?.toSet() ??
        {};
    final acceptList = packageNames
        .where((item) => !selectedPackageNames.contains(item))
        .toList();
    final rejectList = packageNames
        .where((item) => selectedPackageNames.contains(item))
        .toList();
    ref
        .read(accessControlStateProvider.notifier)
        .update(
          (state) =>
              state.copyWith(acceptList: acceptList, rejectList: rejectList),
        );
  }

  Future<void> _handleToSetting() async {
    await showSheet<int>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (context) {
        final appLocalizations = context.appLocalizations;
        return CommonScaffold(
          body: const AccessControlPanel(),
          title: appLocalizations.accessControlSettings,
        );
      },
    );
  }

  void _handleSelected(String packageName) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList)
        ..addOrRemove(packageName);
      return state.copyWithNewList(newSet.toList());
    });
  }

  void _handleToggle() {
    ref.read(accessControlStateProvider.notifier).update((state) {
      return state.copyWith(enable: !state.enable);
    });
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == true) {
      _handleSave();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  AccessControlProps _getRealAccessControlProps(
    AccessControlProps accessControl,
  ) {
    final packages = ref.read(packagesProvider);
    if (packages.isEmpty) {
      return accessControl;
    }
    final viewPackageNames = packages
        .whereVisible(
          isFilterSystemApp: accessControl.isFilterSystemApp,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
        )
        .map((item) => item.packageName)
        .toSet();
    return accessControl.copyWithNewList(
      accessControl.currentList
          .where((item) => viewPackageNames.contains(item))
          .toList()
        ..sort(),
    );
  }

  void _handleSave() {
    final accessControl = ref.read(accessControlStateProvider);
    ref
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            accessControlProps: _getRealAccessControlProps(accessControl),
          ),
        );
  }

  Future<void> _exportToClipboard() async {
    await globalState.safeRun(() {
      final currentList = ref.read(
        accessControlStateProvider.select((state) => state.currentList),
      );
      Clipboard.setData(ClipboardData(text: currentList.join('\n')));
    });
  }

  Future<void> _importFormClipboard() async {
    await globalState.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      final list = text.split('\n');
      ref
          .read(accessControlStateProvider.notifier)
          .update((state) => state.copyWithNewList(list.toSet().toList()));
    });
  }

  List<CommonPopupMenuItem> _buildMenuItems(
    BuildContext context, {
    required bool enable,
  }) {
    final appLocalizations = context.appLocalizations;
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.toggle,
        label: enable ? appLocalizations.turnOff : appLocalizations.turnOn,
        onPressed: _handleToggle,
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.sliders,
        label: appLocalizations.settings,
        onPressed: _handleToSetting,
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.moreCircle,
        label: appLocalizations.action,
        subItems: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.sparkle,
            label: appLocalizations.intelligentSelected,
            onPressed: _intelligentSelected,
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.copy,
            label: appLocalizations.clipboardExport,
            onPressed: _exportToClipboard,
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.paste,
            label: appLocalizations.clipboardImport,
            onPressed: _importFormClipboard,
          ),
        ],
      ),
    ];
  }

  Widget _buildContent({
    required List<Package> packages,
    required Set<String> selected,
    required bool isSearching,
  }) {
    return FutureBuilder(
      future: _completer.future,
      builder: (context, snapshot) {
        final appLocalizations = context.appLocalizations;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommonCircleLoading());
        }
        return NullStatusSwitcher(
          isEmpty: packages.isEmpty,
          isSearching: isSearching,
          nullStatus: NullStatus(
            label: appLocalizations.noData,
            illustration: NullStatusIllustration.apps,
          ),
          child: CommonScrollBar(
            controller: _controller,
            child: ListView.builder(
              controller: _controller,
              itemCount: packages.length,
              itemExtent: 72,
              itemBuilder: (_, index) {
                final package = packages[index];
                return PackageListItem(
                  key: Key(package.packageName),
                  package: package,
                  value: selected.contains(package.packageName),
                  onChanged: (value) {
                    _handleSelected(package.packageName);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstalledAppsPermissionStatus() {
    final appLocalizations = context.appLocalizations;
    return NullStatus(
      label: appLocalizations.installedAppsPermissionRequired,
      description: appLocalizations.installedAppsPermissionDesc,
      illustration: NullStatusIllustration.permission,
      action: FilledButton.tonalIcon(
        onPressed: _handleGrantInstalledAppsPermission,
        icon: const GlyphIcon(AppGlyphs.lockOpen, fill: 1),
        label: Text(appLocalizations.authorize),
      ),
    );
  }

  Widget _buildBannerBar({
    required bool enable,
    required AccessControlMode mode,
    required int count,
  }) {
    final appLocalizations = context.appLocalizations;
    if (!enable) {
      return MaterialBanner(
        leading: GlyphIcon(AppGlyphs.info, color: context.colorScheme.outline),
        content: Text(
          appLocalizations.accessControlDisabledDesc,
          style: TextStyle(color: context.colorScheme.onSurfaceVariant),
        ),
        actions: [
          CommonMinFilledButtonTheme(
            child: FilledButton.tonal(
              onPressed: _handleToggle,
              child: Text(appLocalizations.turnOn),
            ),
          ),
        ],
      );
    }
    final describe = mode == AccessControlMode.acceptSelected
        ? appLocalizations.accessControlAllowDesc
        : appLocalizations.accessControlNotAllowDesc;
    final textStyle = context.textTheme.labelLarge?.copyWith(
      color: context.colorScheme.onPrimary,
    );
    return MaterialBanner(
      content: Text(describe),
      actions: [
        Card.filled(
          color: context.colorScheme.primary,
          elevation: 0,
          shape: AppShape.md,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appLocalizations.selected, style: textStyle),
                const SizedBox(width: 4),
                Flexible(child: Text('$count', style: textStyle)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.access).notifier).value = value;
    _pinList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider(LoadingTag.access));
    final query = SearchQuery(ref.watch(queryProvider(QueryTag.access)));
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList ?? [],
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .whereMatches(query, (package) => [package.label, package.packageName])
        .toList();
    final mode = accessControl.mode;
    final currentList = accessControl.currentList;
    final viewPackageNameList = viewPackages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(viewPackageNameList);
    final needsInstalledAppsPermission =
        packages.isEmpty && !_installedAppsPermissionGranted;
    final selectAllAction =
        accessControl.enable &&
            !needsInstalledAppsPermission &&
            viewPackageNameList.isNotEmpty
        ? _buildSelectAllAction(
            isSelectedAll: valueList.length == viewPackageNameList.length,
            allValueList: viewPackageNameList,
          )
        : null;
    final hasChanges = ref.watch(
      vpnSettingProvider.select(
        (state) =>
            _getRealAccessControlProps(state.accessControlProps) !=
            _getRealAccessControlProps(accessControl),
      ),
    );
    return CommonPopScope(
      onPop: hasChanges
          ? (_) {
              _handleBack();
              return false;
            }
          : null,
      child: CommonScaffold(
        isLoading: isLoading,
        searchState: AppBarSearchState(onSearch: _onSearch),
        searchActions: [?selectAllAction],
        title: context.appLocalizations.appAccessControl,
        iconActions: [
          if (hasChanges)
            IconButtonData(
              glyph: AppGlyphs.check,
              onPressed: _handleSave,
              tooltip: context.appLocalizations.save,
            ),
        ],
        menuItems: [
          ..._buildMenuItems(context, enable: accessControl.enable),
          if (selectAllAction != null)
            CommonPopupMenuItem(
              glyph: selectAllAction.glyph,
              label: selectAllAction.tooltip!,
              onPressed: selectAllAction.onPressed,
            ),
        ],
        body: AppBarClearance(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBannerBar(
                enable: accessControl.enable,
                mode: mode,
                count: valueList.length,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: needsInstalledAppsPermission
                    ? _buildInstalledAppsPermissionStatus()
                    : DisabledMask(
                        status: !accessControl.enable,
                        child: _buildContent(
                          packages: viewPackages,
                          selected: valueList.toSet(),
                          isSearching: query.isNotEmpty,
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

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool value;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListItem.checkbox(
      leading: PackageIcon(packageName: package.packageName, size: 48),
      title: Text(
        package.label,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 1,
      ),
      subtitle: Text(
        package.packageName,
        style: const TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 1,
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class AccessControlPanel extends ConsumerStatefulWidget {
  const AccessControlPanel({super.key});

  @override
  ConsumerState createState() => _AccessControlPanelState();
}

class _AccessControlPanelState extends ConsumerState<AccessControlPanel> {
  Glyph _getIconWithAccessControlMode(AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => AppGlyphs.checkCircle,
      AccessControlMode.rejectSelected => AppGlyphs.block,
    };
  }

  String _getTextWithAccessControlMode(AccessControlMode mode) {
    final appLocalizations = context.appLocalizations;
    return switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
  }

  String _getTextWithAccessSortType(AccessSortType type) {
    final appLocalizations = context.appLocalizations;
    return switch (type) {
      AccessSortType.none => appLocalizations.defaultText,
      AccessSortType.name => appLocalizations.name,
      AccessSortType.time => appLocalizations.time,
    };
  }

  Glyph _getIconWithProxiesSortType(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => AppGlyphs.sort,
      AccessSortType.name => AppGlyphs.sortAlpha,
      AccessSortType.time => AppGlyphs.clock,
    };
  }

  List<Widget> _buildModeSetting() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      isFirst: true,
      title: appLocalizations.mode,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessControlMode = ref.watch(
                accessControlStateProvider.select((state) => state.mode),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in AccessControlMode.values)
                    SettingInfoCard(
                      Info(
                        label: _getTextWithAccessControlMode(item),
                        glyph: _getIconWithAccessControlMode(item),
                      ),
                      isSelected: accessControlMode == item,
                      onPressed: () {
                        ref
                            .read(accessControlStateProvider.notifier)
                            .update((state) => state.copyWith(mode: item));
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSortSetting() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.sort,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessSortType = ref.watch(
                accessControlStateProvider.select((state) => state.sort),
              );
              return Wrap(
                spacing: 16,
                children: [
                  for (final item in AccessSortType.values)
                    SettingInfoCard(
                      Info(
                        label: _getTextWithAccessSortType(item),
                        glyph: _getIconWithProxiesSortType(item),
                      ),
                      isSelected: accessSortType == item,
                      onPressed: () {
                        ref
                            .read(accessControlStateProvider.notifier)
                            .update((state) => state.copyWith(sort: item));
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSourceSetting() {
    final appLocalizations = context.appLocalizations;
    return generateSection(
      title: appLocalizations.source,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final filters = ref.watch(
                accessControlStateProvider.select(
                  (state) => (
                    filterSystemApp: state.isFilterSystemApp,
                    filterNonInternetApp: state.isFilterNonInternetApp,
                  ),
                ),
              );
              return Wrap(
                spacing: 16,
                children: [
                  SettingTextCard(
                    appLocalizations.systemApp,
                    isSelected: filters.filterSystemApp == false,
                    onPressed: () {
                      ref
                          .read(accessControlStateProvider.notifier)
                          .update(
                            (state) => state.copyWith(
                              isFilterSystemApp: !filters.filterSystemApp,
                            ),
                          );
                    },
                  ),
                  SettingTextCard(
                    appLocalizations.noNetworkApp,
                    isSelected: filters.filterNonInternetApp == false,
                    onPressed: () {
                      ref
                          .read(accessControlStateProvider.notifier)
                          .update(
                            (state) => state.copyWith(
                              isFilterNonInternetApp:
                                  !filters.filterNonInternetApp,
                            ),
                          );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: context.sheetTopPadding, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildModeSetting(),
          ..._buildSortSetting(),
          ..._buildSourceSetting(),
        ],
      ),
    );
  }
}

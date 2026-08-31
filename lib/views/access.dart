import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
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
  final GlobalKey<CommonScaffoldState> _scaffoldKey = GlobalKey();
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

  Future<void> _loadPackages({bool force = false}) async {
    final action = ref.read(systemActionProvider.notifier);
    final packages = force
        ? await action.refreshPackages()
        : await action.getPackages();
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
    await globalState.loadingRun(
      () => _loadPackages(force: true),
      tag: LoadingTag.access,
    );
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

  Widget _buildSelectedAllButton({
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
    return FadeRotationScaleBox(
      alignment: Alignment.centerRight,
      child: isSelectedAll
          ? FloatingActionButton.extended(
              key: const ValueKey(true),
              onPressed: onPressed,
              label: Text(appLocalizations.cancelSelectAll),
              icon: const Icon(Icons.deselect),
            )
          : FloatingActionButton.extended(
              key: const ValueKey(false),
              tooltip: appLocalizations.selectAll,
              onPressed: onPressed,
              label: Text(appLocalizations.selectAll),
              icon: const Icon(Icons.select_all),
            ),
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
        return AdaptiveSheetScaffold(
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

  void _handleSearch() {
    _scaffoldKey.currentState?.handleToSearch();
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
        .getViewList(
          pinedList: [],
          sortType: accessControl.sort,
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

  Widget _buildConfirm() {
    return Consumer(
      builder: (_, ref, child) {
        final accessControl = ref.watch(accessControlStateProvider);
        final noSave = ref.watch(
          vpnSettingProvider.select((state) {
            final current = _getRealAccessControlProps(
              state.accessControlProps,
            );
            final origin = _getRealAccessControlProps(accessControl);
            return current == origin;
          }),
        );
        if (noSave) {
          return const SizedBox();
        }
        return child!;
      },
      child: CommonPopScope(
        onPop: (_) {
          _handleBack();
          return false;
        },
        child: CommonMinFilledButtonTheme(
          child: FilledButton.tonal(
            onPressed: _handleSave,
            child: Text(context.appLocalizations.save),
          ),
        ),
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

  List<Widget> _buildActions(BuildContext context, {required bool enable}) {
    final appLocalizations = context.appLocalizations;
    return [
      _buildConfirm(),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            tooltip: appLocalizations.more,
            onPressed: () {
              open(offset: const Offset(0, 0));
            },
            icon: const Icon(Icons.more_vert),
          );
        },
        popupBuilder: (_) => CommonPopupMenu(
          items: [
            CommonPopupMenuItem(
              icon: Icons.swap_horiz,
              label: enable
                  ? appLocalizations.turnOff
                  : appLocalizations.turnOn,
              onPressed: _handleToggle,
            ),
            CommonPopupMenuItem(
              icon: Icons.search,
              label: appLocalizations.search,
              onPressed: _handleSearch,
            ),
            CommonPopupMenuItem(
              icon: Icons.tune,
              label: appLocalizations.settings,
              onPressed: _handleToSetting,
            ),
            CommonPopupMenuItem(
              icon: Icons.emergency_outlined,
              label: appLocalizations.action,
              subItems: [
                CommonPopupMenuItem(
                  icon: Icons.auto_awesome,
                  label: appLocalizations.intelligentSelected,
                  onPressed: _intelligentSelected,
                ),
                CommonPopupMenuItem(
                  icon: Icons.content_copy,
                  label: appLocalizations.clipboardExport,
                  onPressed: _exportToClipboard,
                ),
                CommonPopupMenuItem(
                  icon: Icons.paste,
                  label: appLocalizations.clipboardImport,
                  onPressed: _importFormClipboard,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildContent({
    required List<Package> packages,
    required List<String> valueList,
  }) {
    return FutureBuilder(
      future: _completer.future,
      builder: (context, snapshot) {
        final appLocalizations = context.appLocalizations;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommonCircleLoading());
        }
        return packages.isEmpty
            ? NullStatus(label: appLocalizations.noData)
            : CommonScrollBar(
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
                      value: valueList.contains(package.packageName),
                      onChanged: (value) {
                        _handleSelected(package.packageName);
                      },
                    );
                  },
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
      action: FilledButton.tonalIcon(
        onPressed: _handleGrantInstalledAppsPermission,
        icon: const Icon(Icons.lock_open),
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
        leading: Icon(Icons.info_outline, color: context.colorScheme.outline),
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
    final query = ref.watch(queryProvider(QueryTag.access));
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList ?? [],
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .where(
          (package) =>
              package.label.toLowerCase().contains(query) ||
              package.packageName.contains(query),
        )
        .toList();
    final mode = accessControl.mode;
    final currentList = accessControl.currentList;
    final viewPackageNameList = viewPackages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(viewPackageNameList);
    final needsInstalledAppsPermission =
        packages.isEmpty && !_installedAppsPermissionGranted;
    return CommonScaffold(
      key: _scaffoldKey,
      isLoading: isLoading,
      searchState: AppBarSearchState(onSearch: _onSearch, autoAddSearch: false),
      title: context.appLocalizations.appAccessControl,
      actions: _buildActions(context, enable: accessControl.enable),
      body: Column(
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
                      valueList: valueList,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton:
          accessControl.enable && !needsInstalledAppsPermission
          ? _buildSelectedAllButton(
              isSelectedAll: valueList.length == viewPackageNameList.length,
              allValueList: viewPackageNameList,
            )
          : null,
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
  IconData _getIconWithAccessControlMode(AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => Icons.adjust_outlined,
      AccessControlMode.rejectSelected => Icons.block_outlined,
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

  IconData _getIconWithProxiesSortType(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => Icons.sort,
      AccessSortType.name => Icons.sort_by_alpha,
      AccessSortType.time => Icons.timeline,
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
                        iconData: _getIconWithAccessControlMode(item),
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
                        iconData: _getIconWithProxiesSortType(item),
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildModeSetting(),
            ..._buildSortSetting(),
            ..._buildSourceSetting(),
          ],
        ),
      ),
    );
  }
}

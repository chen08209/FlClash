import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView>
    with RouteSettledMixin<AccessView> {
  late ScrollController _controller;
  List<String>? _pinedList;
  bool _isInit = false;
  bool _installedAppsPermissionGranted = true;

  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
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
    _completer.complete(_loadPackages());
  }

  @override
  void didSettleRoute() => setState(() {});

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

  void _handleSelected(String packageName) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList)
        ..addOrRemove(packageName);
      return state.copyWithNewList(newSet.toList());
    });
  }

  void _update(AccessControlProps Function(AccessControlProps state) update) {
    ref.read(accessControlStateProvider.notifier).update(update);
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == null) {
      return;
    }
    if (res) {
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
    BuildContext context,
    AccessControlProps accessControl,
  ) {
    final appLocalizations = context.appLocalizations;
    String modeText(AccessControlMode mode) => switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
    return [
      CommonPopupMenuItem(
        glyph: AppGlyphs.toggleOn,
        label: appLocalizations.turnOn,
        checked: accessControl.enable,
        section: CommonPopupMenuSection(title: appLocalizations.accessControl),
        onPressed: () => _update((state) => state.copyWith(enable: true)),
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.toggle,
        label: appLocalizations.turnOff,
        checked: !accessControl.enable,
        onPressed: () => _update((state) => state.copyWith(enable: false)),
      ),
      CommonPopupMenuItem(
        glyph: AppGlyphs.sliders,
        label: appLocalizations.settings,
        subtitle: modeText(accessControl.mode),
        section: const CommonPopupMenuSection(),
        subItems: [
          ..._optionsSection(
            title: appLocalizations.mode,
            options: AccessControlMode.values,
            value: accessControl.mode,
            textOf: modeText,
            onSelected: (mode) =>
                _update((state) => state.copyWith(mode: mode)),
          ),
          ..._optionsSection(
            title: appLocalizations.sort,
            options: AccessSortType.values,
            value: accessControl.sort,
            textOf: (type) => switch (type) {
              AccessSortType.none => appLocalizations.defaultText,
              AccessSortType.name => appLocalizations.name,
              AccessSortType.time => appLocalizations.time,
            },
            onSelected: (sort) =>
                _update((state) => state.copyWith(sort: sort)),
          ),
          CommonPopupMenuItem(
            label: appLocalizations.systemApp,
            checked: !accessControl.isFilterSystemApp,
            section: CommonPopupMenuSection(title: appLocalizations.source),
            onPressed: () => _update(
              (state) =>
                  state.copyWith(isFilterSystemApp: !state.isFilterSystemApp),
            ),
          ),
          CommonPopupMenuItem(
            label: appLocalizations.noNetworkApp,
            checked: !accessControl.isFilterNonInternetApp,
            onPressed: () => _update(
              (state) => state.copyWith(
                isFilterNonInternetApp: !state.isFilterNonInternetApp,
              ),
            ),
          ),
        ],
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
          return const Center(child: CommonCircleLoading.page());
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
              padding: EdgeInsets.only(
                top: context.contentTopPadding,
                bottom: context.bottomInset,
              ),
              scrollCacheExtent: arrivalScrollCacheExtent(routeSettled),
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
      action: TonalButton(
        size: TonalButtonSize.bar,
        glyph: AppGlyphs.lockOpen,
        label: appLocalizations.authorize,
        onPressed: _handleGrantInstalledAppsPermission,
      ),
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
        searchInBar: true,
        title: context.appLocalizations.appAccessControl,
        confirmationAction: hasChanges
            ? IconButtonData(
                glyph: AppGlyphs.check,
                onPressed: _handleSave,
                tooltip: context.appLocalizations.save,
              )
            : null,
        iconActions: [?selectAllAction],
        menuItems: _buildMenuItems(context, accessControl),
        body: needsInstalledAppsPermission
            ? _buildInstalledAppsPermissionStatus()
            : FloatingFootBar(
                bar: _AccessStatus(
                  accessControl: accessControl,
                  selectedCount: valueList.length,
                  onEnable: () =>
                      _update((state) => state.copyWith(enable: true)),
                ),
                body: DisabledMask(
                  status: !accessControl.enable,
                  child: _buildContent(
                    packages: viewPackages,
                    selected: valueList.toSet(),
                    isSearching: query.isNotEmpty,
                  ),
                ),
              ),
      ),
    );
  }
}

class _AccessStatus extends StatelessWidget {
  const _AccessStatus({
    required this.accessControl,
    required this.selectedCount,
    required this.onEnable,
  });

  final AccessControlProps accessControl;
  final int selectedCount;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final enabled = accessControl.enable;
    final description = enabled
        ? switch (accessControl.mode) {
            AccessControlMode.acceptSelected =>
              appLocalizations.accessControlAllowDesc,
            AccessControlMode.rejectSelected =>
              appLocalizations.accessControlNotAllowDesc,
          }
        : appLocalizations.accessControlDisabledDesc;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 6, enabled ? 16 : 8, 6),
      child: Row(
        spacing: 12,
        children: [
          GlyphIcon(
            enabled ? AppGlyphs.appsList : AppGlyphs.info,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: colorScheme.onSurface),
            ),
          ),
          if (enabled)
            TonalChip(
              label: appLocalizations.accessControlSelectedCount(selectedCount),
              color: colorScheme.primary.opacity15,
              foregroundColor: colorScheme.primary,
            )
          else
            TonalButton(
              size: TonalButtonSize.compact,
              label: appLocalizations.turnOn,
              onPressed: onEnable,
            ),
        ],
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

List<CommonPopupMenuItem> _optionsSection<T>({
  required String title,
  required List<T> options,
  required T value,
  required String Function(T option) textOf,
  required ValueSetter<T> onSelected,
}) {
  return [
    for (final option in options)
      CommonPopupMenuItem(
        label: textOf(option),
        checked: option == value,
        section: option == options.first
            ? CommonPopupMenuSection(title: title)
            : null,
        onPressed: () => onSelected(option),
      ),
  ];
}

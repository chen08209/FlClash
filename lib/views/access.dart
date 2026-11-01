import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView>
    with RouteSettledMixin<AccessView> {
  late List<String> _pinedList;
  bool _installedAppsPermissionGranted = true;
  late bool _loaded = ref.read(packagesProvider).isNotEmpty;

  @override
  void initState() {
    super.initState();
    _pinedList = ref.read(accessControlStateProvider).currentList;
    ref.listenManual(
      accessControlStateProvider.select((state) => state.mode),
      (_, _) => _pinList(),
    );
  }

  @override
  void didSettleRoute() => unawaited(_loadOnArrival());

  Future<void> _loadOnArrival() async {
    await whenNothingAnimates(besides: _loaded ? 0 : 1);
    if (mounted) {
      await _loadFirstPackages();
    }
  }

  Future<void> _loadFirstPackages() async {
    await _loadPackages().catchError((Object _) {});
    if (mounted && !_loaded) {
      setState(() => _loaded = true);
    }
  }

  Future<void> _loadPackages() async {
    final action = ref.read(systemActionProvider.notifier);
    await action.getPackages();
    final granted = await action.isInstalledAppsPermissionGranted();
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
    if (!mounted) {
      return;
    }
    setState(() {
      _pinedList = ref.read(accessControlStateProvider).currentList;
    });
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
    final enabled = allValueList.isNotEmpty;
    return isSelectedAll
        ? IconButtonData(
            glyph: AppGlyphs.deselect,
            tooltip: appLocalizations.cancelSelectAll,
            onPressed: enabled ? onPressed : null,
          )
        : IconButtonData(
            glyph: AppGlyphs.selectAll,
            tooltip: appLocalizations.selectAll,
            onPressed: enabled ? onPressed : null,
          );
  }

  Future<void> _intelligentSelected() async {
    final packages = ref.read(packagesProvider);
    if (packages.isEmpty) {
      return;
    }
    final action = ref.read(systemActionProvider.notifier);
    final chinaPackageNames = await globalState.loadingRun<List<String>>(
      action.getChinaPackageNames,
      tag: LoadingTag.access,
    );
    if (chinaPackageNames == null || !mounted) {
      return;
    }
    final china = chinaPackageNames.toSet();
    _update((state) {
      final visible = packages
          .whereVisible(
            isFilterSystemApp: state.isFilterSystemApp,
            isFilterNonInternetApp: state.isFilterNonInternetApp,
          )
          .map((item) => item.packageName)
          .toSet();
      List<String> withVisible(List<String> list, bool Function(String) test) {
        final hidden = list.where((item) => !visible.contains(item));
        return [...hidden, ...visible.where(test)];
      }

      return state.copyWith(
        acceptList: withVisible(
          state.acceptList,
          (item) => !china.contains(item),
        ),
        rejectList: withVisible(state.rejectList, china.contains),
      );
    });
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
    final res = await dialogs.showSaveChanges();
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

  AccessControlProps _withSortedList(AccessControlProps accessControl) =>
      accessControl.copyWithNewList([...accessControl.currentList]..sort());

  void _handleSave() {
    final accessControl = ref.read(accessControlStateProvider);
    ref
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            accessControlProps: _withSortedList(accessControl),
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
    final appLocalizations = context.appLocalizations;
    await globalState.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      final list = _parsePackageNames(text);
      if (list.isEmpty) {
        throw MessageException(appLocalizations.clipboardNoPackageNames);
      }
      ref
          .read(accessControlStateProvider.notifier)
          .update((state) => state.copyWithNewList(list));
    });
  }

  List<PopupMenuItem> _buildMenuItems(
    BuildContext context,
    AccessControlProps accessControl,
  ) {
    final appLocalizations = context.appLocalizations;
    String modeText(AccessControlMode mode) => switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
    return [
      PopupMenuItem(
        glyph: AppGlyphs.toggleOn,
        label: appLocalizations.turnOn,
        checked: accessControl.enable,
        section: PopupMenuSection(title: appLocalizations.accessControl),
        onPressed: () => _update((state) => state.copyWith(enable: true)),
      ),
      PopupMenuItem(
        glyph: AppGlyphs.toggle,
        label: appLocalizations.turnOff,
        checked: !accessControl.enable,
        onPressed: () => _update((state) => state.copyWith(enable: false)),
      ),
      PopupMenuItem(
        glyph: AppGlyphs.sliders,
        label: appLocalizations.settings,
        subtitle: modeText(accessControl.mode),
        section: const PopupMenuSection(),
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
          PopupMenuItem(
            label: appLocalizations.systemApp,
            checked: !accessControl.isFilterSystemApp,
            keepsOpen: true,
            section: PopupMenuSection(title: appLocalizations.source),
            onPressed: () => _update(
              (state) =>
                  state.copyWith(isFilterSystemApp: !state.isFilterSystemApp),
            ),
          ),
          PopupMenuItem(
            label: appLocalizations.noNetworkApp,
            checked: !accessControl.isFilterNonInternetApp,
            keepsOpen: true,
            onPressed: () => _update(
              (state) => state.copyWith(
                isFilterNonInternetApp: !state.isFilterNonInternetApp,
              ),
            ),
          ),
        ],
      ),
      PopupMenuItem(
        glyph: AppGlyphs.moreCircle,
        label: appLocalizations.action,
        subItems: [
          PopupMenuItem(
            glyph: AppGlyphs.sparkle,
            label: appLocalizations.intelligentSelected,
            onPressed: _intelligentSelected,
          ),
          PopupMenuItem(
            glyph: AppGlyphs.copy,
            label: appLocalizations.clipboardExport,
            onPressed: _exportToClipboard,
          ),
          PopupMenuItem(
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
    required bool isSearching,
  }) {
    return NullStatusSwitcher(
      isLoading: !_loaded,
      holdsArrival: false,
      isEmpty: packages.isEmpty,
      isSearching: isSearching,
      loadingStatus: const Center(child: ActivityIndicator.page()),
      nullStatus: NullStatus(
        label: context.appLocalizations.noData,
        illustration: NullStatusIllustration.apps,
      ),
      child: _PackageList(packages: packages, onSelected: _handleSelected),
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
    final accessControl = ref.watch(
      accessControlStateProvider.select(_withoutLists),
    );
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList,
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .whereMatches(query, (package) => [package.label, package.packageName])
        .toList();
    final viewPackageNames = {
      for (final package in viewPackages) package.packageName,
    };
    final needsInstalledAppsPermission =
        packages.isEmpty && !_installedAppsPermissionGranted;
    // Only a choice of the user's changes the bar: a list still loading or
    // filtered empty disables select all instead of taking it away.
    final selectAllAction =
        accessControl.enable && !needsInstalledAppsPermission
        ? _buildSelectAllAction(
            isSelectedAll: ref.watch(
              accessControlStateProvider.select(
                (state) =>
                    viewPackageNames.isNotEmpty &&
                    state.currentList.toSet().containsAll(viewPackageNames),
              ),
            ),
            allValueList: viewPackageNames.toList(),
          )
        : null;
    final saved = _withSortedList(
      ref.watch(vpnSettingProvider.select((state) => state.accessControlProps)),
    );
    final hasChanges = ref.watch(
      accessControlStateProvider.select(
        (state) => _withSortedList(state) != saved,
      ),
    );
    return PopGuard(
      onPop: hasChanges
          ? (_) {
              _handleBack();
              return false;
            }
          : null,
      child: Scaffold(
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
                  installedPackageNames: {
                    for (final package in packages) package.packageName,
                  },
                  onAuthorize: _installedAppsPermissionGranted
                      ? null
                      : _handleGrantInstalledAppsPermission,
                  onEnable: () =>
                      _update((state) => state.copyWith(enable: true)),
                ),
                body: DisabledMask(
                  status: !accessControl.enable,
                  child: _buildContent(
                    packages: viewPackages,
                    isSearching: query.isNotEmpty,
                  ),
                ),
              ),
      ),
    );
  }
}

AccessControlProps _withoutLists(AccessControlProps state) =>
    state.copyWith(acceptList: const [], rejectList: const []);

final _packageNamePattern = RegExp(r'^[a-zA-Z]\w*(\.[a-zA-Z]\w*)+$');

List<String> _parsePackageNames(String text) => text
    .split('\n')
    .map((line) => line.trim())
    .where(_packageNamePattern.hasMatch)
    .toSet()
    .toList();

class _PackageList extends ConsumerStatefulWidget {
  const _PackageList({required this.packages, required this.onSelected});

  final List<Package> packages;
  final ValueSetter<String> onSelected;

  @override
  ConsumerState<_PackageList> createState() => _PackageListState();
}

class _PackageListState extends ConsumerState<_PackageList>
    with ArrivalCacheExtentMixin<_PackageList> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sheetScrollController(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packages = widget.packages;
    final selected = ref
        .watch(accessControlStateProvider.select((state) => state.currentList))
        .toSet();
    return Scrollbar(
      controller: _controller,
      child: PrismListView(
        controller: _controller,
        padding: EdgeInsets.only(
          top: context.contentTopPadding,
          bottom: context.bottomInset,
        ),
        scrollCacheExtent: arrivalCacheExtent,
        itemCount: packages.length,
        itemExtent: 72,
        itemBuilder: (_, index) {
          final package = packages[index];
          final value = selected.contains(package.packageName);
          return MemoBuilder(
            key: Key(package.packageName),
            inputs: [package, value],
            builder: (_) => PackageListItem(
              package: package,
              value: value,
              onChanged: (_) => widget.onSelected(package.packageName),
            ),
          );
        },
      ),
    );
  }
}

class _AccessStatus extends ConsumerWidget {
  const _AccessStatus({
    required this.accessControl,
    required this.installedPackageNames,
    required this.onAuthorize,
    required this.onEnable,
  });

  final AccessControlProps accessControl;
  final Set<String> installedPackageNames;
  final VoidCallback? onAuthorize;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCount = ref.watch(
      accessControlStateProvider.select(
        (state) =>
            state.currentList.where(installedPackageNames.contains).length,
      ),
    );
    final appLocalizations = context.appLocalizations;
    final colorScheme = context.colorScheme;
    final enabled = accessControl.enable;
    final authorizes = enabled && onAuthorize != null;
    final description = authorizes
        ? appLocalizations.installedAppsPermissionRequired
        : enabled
        ? switch (accessControl.mode) {
            AccessControlMode.acceptSelected =>
              appLocalizations.accessControlAllowDesc,
            AccessControlMode.rejectSelected =>
              appLocalizations.accessControlNotAllowDesc,
          }
        : appLocalizations.accessControlDisabledDesc;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        6,
        enabled && !authorizes ? 16 : 8,
        6,
      ),
      child: Row(
        spacing: 12,
        children: [
          GlyphIcon(
            enabled && !authorizes ? AppGlyphs.appsList : AppGlyphs.info,
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
          if (authorizes)
            TonalButton(
              size: TonalButtonSize.compact,
              label: appLocalizations.authorize,
              onPressed: onAuthorize,
            )
          else if (enabled)
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

List<PopupMenuItem> _optionsSection<T>({
  required String title,
  required List<T> options,
  required T value,
  required String Function(T option) textOf,
  required ValueSetter<T> onSelected,
}) {
  return [
    for (final option in options)
      PopupMenuItem(
        label: textOf(option),
        checked: option == value,
        section: option == options.first
            ? PopupMenuSection(title: title)
            : null,
        onPressed: () => onSelected(option),
      ),
  ];
}

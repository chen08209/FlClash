import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
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
  AccessControlMode? _lastMode;

  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _completer.complete(globalState.appController.getPackages());
    final accessControl = ref
        .read(vpnSettingProvider.select((state) => state.accessControl))
        .copyWith();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accessControlStateProvider.notifier).value = accessControl;
      _isInit = true;
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
    onPressed() {
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

    return FadeRotationScaleBox(
      alignment: Alignment.centerRight,
      child: isSelectedAll
          ? FloatingActionButton.extended(
              key: ValueKey(true),
              onPressed: onPressed,
              label: Text(appLocalizations.cancelSelectAll),
              icon: const Icon(Icons.deselect),
            )
          : FloatingActionButton.extended(
              key: ValueKey(false),
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
        (await globalState.appController.safeRun<List<String>>(
          needLoading: true,
          () async {
            return await app?.getChinaPackageNames() ?? [];
          },
        ))?.toSet() ??
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
      props: SheetProps(isScrollControlled: true),
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          body: AccessControlPanel(),
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
    final res = await globalState.showMessage(
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

  AccessControl _getRealAccessControl(AccessControl accessControl) {
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
        .toSet()
        .toList();
    return accessControl.copyWithNewList(
      accessControl.currentList.intersection(viewPackageNames),
    );
  }

  void _handleSave() {
    final accessControl = ref.read(accessControlStateProvider);
    ref
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            accessControl: _getRealAccessControl(accessControl),
          ),
        );
  }

  Widget _buildConfirm() {
    return Consumer(
      builder: (_, ref, child) {
        final accessControl = ref.watch(accessControlStateProvider);
        final noSave = ref.watch(
          vpnSettingProvider.select(
            (state) =>
                state.accessControl == _getRealAccessControl(accessControl),
          ),
        );
        if (noSave) {
          return SizedBox();
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
    await globalState.appController.safeRun(() {
      final currentList = ref.read(
        accessControlStateProvider.select((state) => state.currentList),
      );
      Clipboard.setData(ClipboardData(text: currentList.join('\n')));
    });
  }

  Future<void> _importFormClipboard() async {
    await globalState.appController.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      final list = text.split('\n');
      ref
          .read(accessControlStateProvider.notifier)
          .update((state) => state.copyWithNewList(list.toSet().toList()));
    });
  }

  List<Widget> _buildActions({required bool enable}) {
    return [
      _buildConfirm(),
      CommonPopupBox(
        targetBuilder: (open) {
          return IconButton(
            onPressed: () {
              open(offset: Offset(0, 0));
            },
            icon: Icon(Icons.more_vert),
          );
        },
        popup: CommonPopupMenu(
          items: [
            PopupMenuItemData(
              icon: Icons.swap_horiz,
              label: enable
                  ? appLocalizations.turnOff
                  : appLocalizations.turnOn,
              onPressed: _handleToggle,
            ),
            PopupMenuItemData(
              icon: Icons.search,
              label: appLocalizations.search,
              onPressed: _handleSearch,
            ),
            PopupMenuItemData(
              icon: Icons.tune,
              label: appLocalizations.settings,
              onPressed: _handleToSetting,
            ),
            PopupMenuItemData(
              icon: Icons.emergency_outlined,
              label: appLocalizations.action,
              subItems: [
                PopupMenuItemData(
                  icon: Icons.auto_awesome,
                  label: appLocalizations.intelligentSelected,
                  onPressed: _intelligentSelected,
                ),
                PopupMenuItemData(
                  icon: Icons.content_copy,
                  label: appLocalizations.clipboardExport,
                  onPressed: _exportToClipboard,
                ),
                PopupMenuItemData(
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
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
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

  Widget _buildBannerBar(AccessControlMode mode, int count) {
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
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appLocalizations.selected, style: textStyle),
                SizedBox(width: 4),
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
    _pinedList = null;
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(queryProvider(QueryTag.access));
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    if (_isInit) {
      if (_lastMode != accessControl.mode) {
        _lastMode = accessControl.mode;
        _pinedList = accessControl.currentList;
      } else {
        _pinedList ??= accessControl.currentList;
      }
    }
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
    return CommonScaffold(
      key: _scaffoldKey,
      searchState: AppBarSearchState(onSearch: _onSearch, autoAddSearch: false),
      title: appLocalizations.appAccessControl,
      actions: _buildActions(enable: accessControl.enable),
      body: DisabledMask(
        status: !accessControl.enable,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBannerBar(mode, valueList.length),
            SizedBox(height: 8),
            Expanded(
              child: _buildContent(
                packages: viewPackages,
                valueList: valueList,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSelectedAllButton(
        isSelectedAll: valueList.length == viewPackageNameList.length,
        allValueList: viewPackageNameList,
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
      leading: SizedBox(
        width: 48,
        height: 48,
        child: FutureBuilder<ImageProvider?>(
          future: app?.getPackageIcon(package.packageName),
          builder: (_, snapshot) {
            if (!snapshot.hasData && snapshot.data == null) {
              return Container();
            } else {
              return Image(
                image: snapshot.data!,
                gaplessPlayback: true,
                width: 48,
                height: 48,
              );
            }
          },
        ),
      ),
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
      delegate: CheckboxDelegate(value: value, onChanged: onChanged),
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
    return switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
  }

  String _getTextWithAccessSortType(AccessSortType type) {
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
    return generateSection(
      title: appLocalizations.source,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final vm2 = ref.watch(
                accessControlStateProvider.select(
                  (state) => VM2(
                    a: state.isFilterSystemApp,
                    b: state.isFilterNonInternetApp,
                  ),
                ),
              );
              return Wrap(
                spacing: 16,
                children: [
                  SettingTextCard(
                    appLocalizations.systemApp,
                    isSelected: vm2.a == false,
                    onPressed: () {
                      ref
                          .read(accessControlStateProvider.notifier)
                          .update(
                            (state) =>
                                state.copyWith(isFilterSystemApp: !vm2.a),
                          );
                    },
                  ),
                  SettingTextCard(
                    appLocalizations.noNetworkApp,
                    isSelected: vm2.b == false,
                    onPressed: () {
                      ref
                          .read(accessControlStateProvider.notifier)
                          .update(
                            (state) =>
                                state.copyWith(isFilterNonInternetApp: !vm2.b),
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

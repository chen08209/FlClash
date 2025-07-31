import 'dart:async';
import 'dart:convert';

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
  List<String> acceptList = [];
  List<String> rejectList = [];
  late ScrollController _controller;
  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _updateInitList();
    _controller = ScrollController();
    _completer.complete(globalState.appController.getPackages());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateInitList() {
    acceptList = globalState.config.vpnProps.accessControl.acceptList;
    rejectList = globalState.config.vpnProps.accessControl.rejectList;
  }

  Widget _buildSearchButton() {
    return IconButton(
      tooltip: appLocalizations.search,
      onPressed: () {
        showSearch(
          context: context,
          delegate: AccessControlSearchDelegate(
            acceptList: acceptList,
            rejectList: rejectList,
          ),
        ).then(
          (_) => setState(() {
            _updateInitList();
          }),
        );
      },
      icon: const Icon(Icons.search),
    );
  }

  Widget _buildSelectedAllButton({
    required bool isSelectedAll,
    required List<String> allValueList,
  }) {
    onPressed() {
      ref.read(vpnSettingProvider.notifier).updateState((state) {
        final isAccept =
            state.accessControl.mode == AccessControlMode.acceptSelected;
        if (isSelectedAll) {
          return switch (isAccept) {
            true => state.copyWith.accessControl(acceptList: []),
            false => state.copyWith.accessControl(rejectList: []),
          };
        } else {
          return switch (isAccept) {
            true => state.copyWith.accessControl(acceptList: allValueList),
            false => state.copyWith.accessControl(rejectList: allValueList),
          };
        }
      });
    }

    return FadeRotationScaleBox(
      child: isSelectedAll
          ? IconButton(
              key: ValueKey(true),
              tooltip: appLocalizations.cancelSelectAll,
              onPressed: onPressed,
              icon: const Icon(Icons.deselect),
            )
          : IconButton(
              key: ValueKey(false),
              tooltip: appLocalizations.selectAll,
              onPressed: onPressed,
              icon: const Icon(Icons.select_all),
            ),
    );
  }

  Future<void> _intelligentSelected() async {
    final packageNames = ref.read(
      packageListSelectorStateProvider.select(
        (state) => state.list.map((item) => item.packageName),
      ),
    );
    final commonScaffoldState = context.commonScaffoldState;
    if (commonScaffoldState?.mounted != true) return;
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
        .read(vpnSettingProvider.notifier)
        .updateState(
          (state) => state.copyWith.accessControl(
            acceptList: acceptList,
            rejectList: rejectList,
          ),
        );
  }

  Widget _buildSettingButton() {
    return IconButton(
      onPressed: () async {
        final res = await showSheet<int>(
          context: context,
          props: SheetProps(isScrollControlled: true),
          builder: (_, type) {
            return AdaptiveSheetScaffold(
              type: type,
              body: AccessControlPanel(),
              title: appLocalizations.proxiesSetting,
            );
          },
        );
        if (res == 1) {
          _intelligentSelected();
        }
      },
      icon: const Icon(Icons.tune),
    );
  }

  void _handleSelected(List<String> valueList, Package package, bool? value) {
    if (value == true) {
      valueList.add(package.packageName);
    } else {
      valueList.remove(package.packageName);
    }
    ref.read(vpnSettingProvider.notifier).updateState((state) {
      return switch (state.accessControl.mode ==
          AccessControlMode.acceptSelected) {
        true => state.copyWith.accessControl(acceptList: valueList),
        false => state.copyWith.accessControl(rejectList: valueList),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageListSelectorStateProvider);
    final accessControl = state.accessControl;
    final accessControlMode = accessControl.mode;
    final packages = state.getSortList(
      accessControlMode == AccessControlMode.acceptSelected
          ? acceptList
          : rejectList,
    );
    final currentList = accessControl.currentList;
    final packageNameList = packages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(packageNameList);
    final describe = accessControlMode == AccessControlMode.acceptSelected
        ? appLocalizations.accessControlAllowDesc
        : appLocalizations.accessControlNotAllowDesc;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 0,
          child: ListItem.switchItem(
            title: Text(appLocalizations.appAccessControl),
            delegate: SwitchDelegate(
              value: accessControl.enable,
              onChanged: (enable) {
                ref
                    .read(vpnSettingProvider.notifier)
                    .updateState(
                      (state) => state.copyWith.accessControl(enable: enable),
                    );
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 12),
        ),
        Flexible(
          child: DisabledMask(
            status: !accessControl.enable,
            child: Column(
              children: [
                ActivateBox(
                  active: accessControl.enable,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: 16,
                      right: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          appLocalizations.selected,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                      const Flexible(child: SizedBox(width: 8)),
                                      Flexible(
                                        child: Text(
                                          '${valueList.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(child: Text(describe)),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(child: _buildSearchButton()),
                            Flexible(
                              child: _buildSelectedAllButton(
                                isSelectedAll:
                                    valueList.length == packageNameList.length,
                                allValueList: packageNameList,
                              ),
                            ),
                            Flexible(child: _buildSettingButton()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FutureBuilder(
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
                                    value: valueList.contains(
                                      package.packageName,
                                    ),
                                    isActive: accessControl.enable,
                                    onChanged: (value) {
                                      _handleSelected(
                                        valueList,
                                        package,
                                        value,
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool value;
  final bool isActive;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FadeScaleEnterBox(
      child: ActivateBox(
        active: isActive,
        child: ListItem.checkbox(
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
        ),
      ),
    );
  }
}

class AccessControlSearchDelegate extends SearchDelegate {
  List<String> acceptList = [];
  List<String> rejectList = [];

  AccessControlSearchDelegate({
    required this.acceptList,
    required this.rejectList,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
            return;
          }
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  void _handleSelected(
    WidgetRef ref,
    List<String> valueList,
    Package package,
    bool? value,
  ) {
    if (value == true) {
      valueList.add(package.packageName);
    } else {
      valueList.remove(package.packageName);
    }
    ref.read(vpnSettingProvider.notifier).updateState((state) {
      return switch (state.accessControl.mode ==
          AccessControlMode.acceptSelected) {
        true => state.copyWith.accessControl(acceptList: valueList),
        false => state.copyWith.accessControl(rejectList: valueList),
      };
    });
  }

  Widget _packageList() {
    final lowQuery = query.toLowerCase();
    return Consumer(
      builder: (context, ref, _) {
        final vm3 = ref.watch(
          packageListSelectorStateProvider.select(
            (state) => VM3(
              a: state.getSortList(
                state.accessControl.mode == AccessControlMode.acceptSelected
                    ? acceptList
                    : rejectList,
              ),
              b: state.accessControl.enable,
              c: state.accessControl.currentList,
            ),
          ),
        );
        final packages = vm3.a;
        final queryPackages = packages
            .where(
              (package) =>
                  package.label.toLowerCase().contains(lowQuery) ||
                  package.packageName.contains(lowQuery),
            )
            .toList();
        final isAccessControl = vm3.b;
        final currentList = vm3.c;
        final packageNameList = packages.map((e) => e.packageName).toList();
        final valueList = currentList.intersection(packageNameList);
        return DisabledMask(
          status: !isAccessControl,
          child: ListView.builder(
            itemCount: queryPackages.length,
            itemBuilder: (_, index) {
              final package = queryPackages[index];
              return PackageListItem(
                key: Key(package.packageName),
                package: package,
                value: valueList.contains(package.packageName),
                isActive: isAccessControl,
                onChanged: (value) {
                  _handleSelected(ref, valueList, package, value);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _packageList();
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
      title: appLocalizations.mode,
      items: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          child: Consumer(
            builder: (_, ref, _) {
              final accessControlMode = ref.watch(
                vpnSettingProvider.select((state) => state.accessControl.mode),
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
                            .read(vpnSettingProvider.notifier)
                            .updateState(
                              (state) =>
                                  state.copyWith.accessControl(mode: item),
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
                vpnSettingProvider.select((state) => state.accessControl.sort),
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
                            .read(vpnSettingProvider.notifier)
                            .updateState(
                              (state) =>
                                  state.copyWith.accessControl(sort: item),
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
                vpnSettingProvider.select(
                  (state) => VM2(
                    a: state.accessControl.isFilterSystemApp,
                    b: state.accessControl.isFilterNonInternetApp,
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
                          .read(vpnSettingProvider.notifier)
                          .updateState(
                            (state) => state.copyWith.accessControl(
                              isFilterSystemApp: !vm2.a,
                            ),
                          );
                    },
                  ),
                  SettingTextCard(
                    appLocalizations.noNetworkApp,
                    isSelected: vm2.b == false,
                    onPressed: () {
                      ref
                          .read(vpnSettingProvider.notifier)
                          .updateState(
                            (state) => state.copyWith.accessControl(
                              isFilterNonInternetApp: !vm2.b,
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

  Future<void> _copyToClipboard() async {
    await globalState.appController.safeRun(() {
      final data = globalState.config.vpnProps.accessControl.toJson();
      Clipboard.setData(ClipboardData(text: json.encode(data)));
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pasteToClipboard() async {
    await globalState.appController.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      ref
          .read(vpnSettingProvider.notifier)
          .updateState(
            (state) => state.copyWith(
              accessControl: AccessControl.fromJson(json.decode(text)),
            ),
          );
    });
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  List<Widget> _buildActionSetting() {
    return generateSection(
      title: appLocalizations.action,
      items: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            runSpacing: 16,
            spacing: 16,
            children: [
              CommonChip(
                avatar: const Icon(Icons.auto_awesome),
                label: appLocalizations.intelligentSelected,
                onPressed: () {
                  Navigator.of(context).pop(1);
                },
              ),
              CommonChip(
                avatar: const Icon(Icons.paste),
                label: appLocalizations.clipboardImport,
                onPressed: _pasteToClipboard,
              ),
              CommonChip(
                avatar: const Icon(Icons.content_copy),
                label: appLocalizations.clipboardExport,
                onPressed: _copyToClipboard,
              ),
            ],
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
            ..._buildActionSetting(),
          ],
        ),
      ),
    );
  }
}

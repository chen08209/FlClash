import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessFragment extends StatefulWidget {
  const AccessFragment({super.key});

  @override
  State<AccessFragment> createState() => _AccessFragmentState();
}

class _AccessFragmentState extends State<AccessFragment> {
  final packagesListenable = ValueNotifier<List<Package>>([]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () async {
        packagesListenable.value = await app?.getPackages() ?? [];
      });
    });
  }

  Widget _buildAppProxyModePopup() {
    final items = [
      CommonPopupMenuItem(
        action: AccessControlMode.rejectSelected,
        label: appLocalizations.blacklistMode,
      ),
      CommonPopupMenuItem(
        action: AccessControlMode.acceptSelected,
        label: appLocalizations.whitelistMode,
      ),
    ];
    return Selector<Config, AccessControlMode>(
      selector: (_, config) => config.accessControl.mode,
      builder: (context, mode, __) {
        return CommonPopupMenu<AccessControlMode>.radio(
          icon: Icon(
            Icons.mode_standby,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          items: items,
          onSelected: (value) {
            final config = context.read<Config>();
            config.accessControl = config.accessControl.copyWith(
              mode: value,
            );
          },
          selectedValue: mode,
        );
      },
    );
  }

  Widget _buildFilterSystemAppButton() {
    return Selector<Config, bool>(
      selector: (_, config) => config.accessControl.isFilterSystemApp,
      builder: (context, isFilterSystemApp, __) {
        final tooltip = isFilterSystemApp
            ? appLocalizations.cancelFilterSystemApp
            : appLocalizations.filterSystemApp;
        return IconButton(
          tooltip: tooltip,
          onPressed: () {
            final config = context.read<Config>();
            config.accessControl = config.accessControl.copyWith(
              isFilterSystemApp: !isFilterSystemApp,
            );
          },
          icon: isFilterSystemApp
              ? const Icon(Icons.filter_list_off)
              : const Icon(Icons.filter_list),
        );
      },
    );
  }

  Widget _buildSelectedAllButton({
    required bool isSelectedAll,
    required List<String> allValueList,
  }) {
    return Builder(
      builder: (context) {
        final tooltip = isSelectedAll
            ? appLocalizations.cancelSelectAll
            : appLocalizations.selectAll;
        return IconButton(
          tooltip: tooltip,
          onPressed: () {
            final config = globalState.appController.config;
            final isAccept =
                config.accessControl.mode == AccessControlMode.acceptSelected;

            if (isSelectedAll) {
              config.accessControl = switch (isAccept) {
                true => config.accessControl.copyWith(
                    acceptList: [],
                  ),
                false => config.accessControl.copyWith(
                    rejectList: [],
                  ),
              };
            } else {
              config.accessControl = switch (isAccept) {
                true => config.accessControl.copyWith(
                    acceptList: allValueList,
                  ),
                false => config.accessControl.copyWith(
                    rejectList: allValueList,
                  ),
              };
            }
          },
          icon: isSelectedAll
              ? const Icon(Icons.deselect)
              : const Icon(Icons.select_all),
        );
      },
    );
  }

  Widget _actionHeader({
    required bool isAccessControl,
    required List<String> valueList,
    required String describe,
    required List<String> packageNameList,
  }) {
    return AbsorbPointer(
      absorbing: !isAccessControl,
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                          const Flexible(
                            child: SizedBox(
                              width: 8,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "${valueList.length}",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Text(describe),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: _buildSelectedAllButton(
                    isSelectedAll: const ListEquality<String>()
                        .equals(valueList, packageNameList),
                    allValueList: packageNameList,
                  ),
                ),
                Flexible(child: _buildFilterSystemAppButton()),
                Flexible(child: _buildAppProxyModePopup()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList() {
    return ValueListenableBuilder(
      valueListenable: packagesListenable,
      builder: (_, packages, ___) {
        return Selector<Config, PackageListSelectorState>(
          selector: (_, config) => PackageListSelectorState(
            accessControl: config.accessControl,
            isAccessControl: config.isAccessControl,
          ),
          builder: (context, state, __) {
            final accessControl = state.accessControl;
            final isAccessControl = state.isAccessControl;
            final isFilterSystemApp = accessControl.isFilterSystemApp;
            final currentPackages = isFilterSystemApp
                ? packages
                    .where((element) => element.isSystem == false)
                    .toList()
                : packages;
            final packageNameList =
                currentPackages.map((e) => e.packageName).toList();
            final accessControlMode = accessControl.mode;
            final currentList =
                accessControlMode == AccessControlMode.acceptSelected
                    ? accessControl.acceptList
                    : accessControl.rejectList;
            final valueList = currentList.intersection(packageNameList);
            final describe =
                accessControlMode == AccessControlMode.acceptSelected
                    ? appLocalizations.accessControlAllowDesc
                    : appLocalizations.accessControlNotAllowDesc;
            return DisabledMask(
              status: !isAccessControl,
              child: Column(
                children: [
                  _actionHeader(
                    isAccessControl: isAccessControl,
                    valueList: valueList,
                    describe: describe,
                    packageNameList: packageNameList,
                  ),
                  Expanded(
                    flex: 1,
                    child: FadeBox(
                      key: const Key("fade_box"),
                      child: currentPackages.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              itemCount: currentPackages.length,
                              itemBuilder: (_, index) {
                                final package = currentPackages[index];
                                return PackageListItem(
                                  key: Key(package.packageName),
                                  package: package,
                                  value:
                                      valueList.contains(package.packageName),
                                  isActive: isAccessControl,
                                  onChanged: (value) {
                                    if (value == true) {
                                      valueList.add(package.packageName);
                                    } else {
                                      valueList.remove(package.packageName);
                                    }
                                    final config =
                                        globalState.appController.config;
                                    if (accessControlMode ==
                                        AccessControlMode.acceptSelected) {
                                      config.accessControl =
                                          config.accessControl.copyWith(
                                        acceptList: valueList,
                                      );
                                    } else {
                                      config.accessControl =
                                          config.accessControl.copyWith(
                                        rejectList: valueList,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.isAccessControl,
      builder: (_, isAccessControl, child) {
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 0,
              child: ListItem.switchItem(
                title: Text(appLocalizations.appAccessControl),
                delegate: SwitchDelegate(
                  value: isAccessControl,
                  onChanged: (isAccessControl) {
                    final config = context.read<Config>();
                    config.isAccessControl = isAccessControl;
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 12,
              ),
            ),
            Flexible(
              child: child!,
            ),
          ],
        );
      },
      child: _buildPackageList(),
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
    return AbsorbPointer(
      absorbing: !isActive,
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
          style: const TextStyle(
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          package.packageName,
          style: const TextStyle(
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        delegate: CheckboxDelegate(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

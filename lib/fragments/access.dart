import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension AccessControlExtension on AccessControl {
  List<String> get currentList => switch (mode) {
        AccessControlMode.acceptSelected => acceptList,
        AccessControlMode.rejectSelected => rejectList,
      };
}

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

  Widget _buildSearchButton(List<Package> packages) {
    return IconButton(
      tooltip: appLocalizations.search,
      onPressed: () {
        showSearch(
          context: context,
          delegate: AccessControlSearchDelegate(
            packages: packages,
          ),
        ).then((_) => {setState(() {})});
      },
      icon: const Icon(Icons.search),
    );
  }

  // Widget _buildSelectedAllButton({
  //   required bool isSelectedAll,
  //   required List<String> allValueList,
  // }) {
  //   return Builder(
  //     builder: (context) {
  //       final tooltip = isSelectedAll
  //           ? appLocalizations.cancelSelectAll
  //           : appLocalizations.selectAll;
  //       return IconButton(
  //         tooltip: tooltip,
  //         onPressed: () {
  //           final config = globalState.appController.config;
  //           final isAccept =
  //               config.accessControl.mode == AccessControlMode.acceptSelected;
  //
  //           if (isSelectedAll) {
  //             config.accessControl = switch (isAccept) {
  //               true => config.accessControl.copyWith(
  //                   acceptList: [],
  //                 ),
  //               false => config.accessControl.copyWith(
  //                   rejectList: [],
  //                 ),
  //             };
  //           } else {
  //             config.accessControl = switch (isAccept) {
  //               true => config.accessControl.copyWith(
  //                   acceptList: allValueList,
  //                 ),
  //               false => config.accessControl.copyWith(
  //                   rejectList: allValueList,
  //                 ),
  //             };
  //           }
  //         },
  //         icon: isSelectedAll
  //             ? const Icon(Icons.deselect)
  //             : const Icon(Icons.select_all),
  //       );
  //     },
  //   );
  // }

  Widget _buildPackageList() {
    return ValueListenableBuilder(
      valueListenable: packagesListenable,
      builder: (_, packages, ___) {
        final accessControl = globalState.appController.config.accessControl;
        final acceptList = accessControl.acceptList;
        final rejectList = accessControl.rejectList;
        final acceptPackages = packages.sorted((a, b) {
          final isSelectA = acceptList.contains(a.packageName);
          final isSelectB = acceptList.contains(b.packageName);
          if (isSelectA && isSelectB) return 0;
          if (isSelectA) return -1;
          if (isSelectB) return 1;
          return 0;
        });
        final rejectPackages = packages.sorted((a, b) {
          final isSelectA = rejectList.contains(a.packageName);
          final isSelectB = rejectList.contains(b.packageName);
          if (isSelectA && isSelectB) return 0;
          if (isSelectA) return -1;
          if (isSelectB) return 1;
          return 0;
        });
        return Selector<Config, PackageListSelectorState>(
          selector: (_, config) => PackageListSelectorState(
            accessControl: config.accessControl,
            isAccessControl: config.isAccessControl,
          ),
          builder: (context, state, __) {
            final accessControl = state.accessControl;
            final isAccessControl = state.isAccessControl;
            final isFilterSystemApp = accessControl.isFilterSystemApp;
            final accessControlMode = accessControl.mode;
            final packages =
                accessControlMode == AccessControlMode.acceptSelected
                    ? acceptPackages
                    : rejectPackages;
            final currentList = accessControl.currentList;
            final currentPackages = isFilterSystemApp
                ? packages
                    .where((element) => element.isSystem == false)
                    .toList()
                : packages;
            final packageNameList =
                currentPackages.map((e) => e.packageName).toList();
            final valueList = currentList.intersection(packageNameList);
            final describe =
                accessControlMode == AccessControlMode.acceptSelected
                    ? appLocalizations.accessControlAllowDesc
                    : appLocalizations.accessControlNotAllowDesc;
            return DisabledMask(
              status: !isAccessControl,
              child: Column(
                children: [
                  AbsorbPointer(
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
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
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
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
                                  child: _buildSearchButton(currentPackages)),
                              Flexible(child: _buildFilterSystemAppButton()),
                              Flexible(child: _buildAppProxyModePopup()),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class AccessControlSearchDelegate extends SearchDelegate {
  final List<Package> packages;

  AccessControlSearchDelegate({
    required this.packages,
  });

  List<Package> get _results {
    final lowQuery = query.toLowerCase();
    return packages
        .where(
          (package) =>
              package.label.toLowerCase().contains(lowQuery) ||
              package.packageName.contains(lowQuery),
        )
        .toList();
  }

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
      const SizedBox(
        width: 8,
      )
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

  Widget _packageList(List<Package> packages) {
    return Selector<Config, PackageListSelectorState>(
      selector: (_, config) => PackageListSelectorState(
        accessControl: config.accessControl,
        isAccessControl: config.isAccessControl,
      ),
      builder: (context, state, __) {
        final accessControl = state.accessControl;
        final isAccessControl = state.isAccessControl;
        final accessControlMode = accessControl.mode;
        final currentList = accessControl.currentList;
        final packageNameList = packages.map((e) => e.packageName).toList();
        final valueList = currentList.intersection(packageNameList);
        return DisabledMask(
          status: !isAccessControl,
          child: ListView.builder(
            itemCount: packages.length,
            itemBuilder: (_, index) {
              final package = packages[index];
              return PackageListItem(
                key: Key(package.packageName),
                package: package,
                value: valueList.contains(package.packageName),
                isActive: isAccessControl,
                onChanged: (value) {
                  if (value == true) {
                    valueList.add(package.packageName);
                  } else {
                    valueList.remove(package.packageName);
                  }
                  final config = globalState.appController.config;
                  if (accessControlMode == AccessControlMode.acceptSelected) {
                    config.accessControl = config.accessControl.copyWith(
                      acceptList: valueList,
                    );
                  } else {
                    config.accessControl = config.accessControl.copyWith(
                      rejectList: valueList,
                    );
                  }
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
    final packages = _results;
    return _packageList(packages);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _packageList(packages);
  }
}

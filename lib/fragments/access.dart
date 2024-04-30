import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessFragment extends StatelessWidget {
  const AccessFragment({super.key});

  Widget _buildPackageItem({
    required Package package,
    required bool value,
    required bool isActive,
    required void Function(bool?) onChanged,
  }) {
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
            final config = context.read<Config>();
            if (isSelectedAll) {
              config.accessControl.currentList = [];
              config.accessControl = config.accessControl.copyWith();
            } else {
              config.accessControl.currentList = allValueList;
              config.accessControl = config.accessControl.copyWith();
            }
          },
          icon: isSelectedAll
              ? const Icon(Icons.deselect)
              : const Icon(Icons.select_all),
        );
      },
    );
  }

  Widget _buildPackageList(bool isAccessControl) {
    return Selector2<AppState, Config, PackageListSelectorState>(
      selector: (_, appState, config) => PackageListSelectorState(
        accessControl: config.accessControl,
        packages: appState.packages,
      ),
      builder: (context, state, __) {
        final accessControl = state.accessControl;
        final isFilterSystemApp = accessControl.isFilterSystemApp;
        final packages = isFilterSystemApp
            ? state.packages
                .where((element) => element.isSystem == false)
                .toList()
            : state.packages;
        final packageNameList = packages.map((e) => e.packageName).toList();
        final accessControlMode = accessControl.mode;
        final valueList =
            accessControl.currentList.intersection(packageNameList);
        final describe = accessControlMode == AccessControlMode.acceptSelected
            ? appLocalizations.accessControlAllowDesc
            : appLocalizations.accessControlNotAllowDesc;

        final listView = ListView.builder(
          itemCount: packages.length,
          itemBuilder: (_, index) {
            final package = packages[index];
            return _buildPackageItem(
              package: package,
              value: valueList.contains(package.packageName),
              isActive: isAccessControl,
              onChanged: (value) {
                if (value == true) {
                  valueList.add(package.packageName);
                } else {
                  valueList.remove(package.packageName);
                }
                final config = context.read<Config>();
                config.accessControl.currentList = valueList;
                config.accessControl = config.accessControl.copyWith();
              },
            );
          },
        );

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
                            child: _buildSelectedAllButton(
                              isSelectedAll:
                                  valueList.length == packageNameList.length,
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
              ),
              Flexible(
                flex: 1,
                child: FadeBox(
                  child: packages.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : listView,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.appController.appState.packages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.appController.updatePackages();
      });
    }
    return Selector<Config, bool>(
      selector: (_, config) => config.isAccessControl,
      builder: (_, isAccessControl, __) {
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
              child: _buildPackageList(isAccessControl),
            ),
          ],
        );
      },
    );
  }
}

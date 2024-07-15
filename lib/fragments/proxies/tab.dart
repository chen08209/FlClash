import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/setting.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'group.dart';

class ProxiesTabFragment extends StatefulWidget {
  const ProxiesTabFragment({super.key});

  @override
  State<ProxiesTabFragment> createState() => _ProxiesTabFragmentState();
}

class _ProxiesTabFragmentState extends State<ProxiesTabFragment>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final hasMoreButtonNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  _buildMoreButton() {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.viewMode == ViewMode.mobile,
      builder: (_, value, ___) {
        return IconButton(
          onPressed: _showMoreMenu,
          icon: value
              ? const Icon(
                  Icons.expand_more,
                )
              : const Icon(
                  Icons.chevron_right,
                ),
        );
      },
    );
  }

  _showMoreMenu() {
    showSheet(
      context: context,
      width: 380,
      isScrollControlled: false,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Selector2<AppState, Config, ProxiesSelectorState>(
            selector: (_, appState, config) {
              final currentGroups = appState.currentGroups;
              final groupNames = currentGroups.map((e) => e.name).toList();
              return ProxiesSelectorState(
                groupNames: groupNames,
                currentGroupName: config.currentGroupName,
              );
            },
            builder: (_, state, __) {
              return SizedBox(
                width: double.infinity,
                child: Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: [
                    for (final groupName in state.groupNames)
                      SettingTextCard(
                        groupName,
                        onPressed: () {
                          final index = state.groupNames
                              .indexWhere((item) => item == groupName);
                          if (index == -1) return;
                          _tabController?.animateTo(index);
                          globalState.appController.config
                              .updateCurrentGroupName(
                            groupName,
                          );
                        },
                        isSelected: groupName == state.currentGroupName,
                      )
                  ],
                ),
              );
            },
          ),
        );
      },
      title: appLocalizations.proxyGroup,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector2<AppState, Config, ProxiesSelectorState>(
      selector: (_, appState, config) {
        final currentGroups = appState.currentGroups;
        final groupNames = currentGroups.map((e) => e.name).toList();
        return ProxiesSelectorState(
          groupNames: groupNames,
          currentGroupName: config.currentGroupName,
        );
      },
      shouldRebuild: (prev, next) {
        if (!const ListEquality<String>()
            .equals(prev.groupNames, next.groupNames)) {
          _tabController?.dispose();
          _tabController = null;
          return true;
        }
        return false;
      },
      builder: (_, state, __) {
        final index = state.groupNames.indexWhere(
          (item) => item == state.currentGroupName,
        );
        _tabController ??= TabController(
          length: state.groupNames.length,
          initialIndex: index == -1 ? 0 : index,
          vsync: this,
        );
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationListener<ScrollMetricsNotification>(
              onNotification: (scrollNotification) {
                hasMoreButtonNotifier.value =
                    scrollNotification.metrics.maxScrollExtent > 0;
                return true;
              },
              child: ValueListenableBuilder(
                valueListenable: hasMoreButtonNotifier,
                builder: (_, value, child) {
                  return Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      TabBar(
                        controller: _tabController,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16 + (value ? 16 : 0),
                        ),
                        onTap: (index) {
                          final appController = globalState.appController;
                          final currentGroups =
                              appController.appState.currentGroups;
                          if (currentGroups.length > index) {
                            appController.config.updateCurrentGroupName(
                              currentGroups[index].name,
                            );
                          }
                        },
                        dividerColor: Colors.transparent,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        overlayColor:
                            const WidgetStatePropertyAll(Colors.transparent),
                        tabs: [
                          for (final groupName in state.groupNames)
                            Tab(
                              text: groupName,
                            ),
                        ],
                      ),
                      if (value)
                        Positioned(
                          right: 0,
                          child: child!,
                        ),
                    ],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          context.colorScheme.surface.withOpacity(0.1),
                          context.colorScheme.surface,
                        ],
                        stops: const [
                          0.0,
                          0.1
                        ]),
                  ),
                  child: _buildMoreButton(),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final groupName in state.groupNames)
                    KeepContainer(
                      key: ObjectKey(groupName),
                      child: ProxyGroupView(
                        groupName: groupName,
                        type: ProxiesType.tab,
                      ),
                    ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}

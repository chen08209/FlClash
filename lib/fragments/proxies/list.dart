import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'group.dart';

class ProxiesListFragment extends StatefulWidget {
  const ProxiesListFragment({super.key});

  @override
  State<ProxiesListFragment> createState() =>
      _ProxiesListFragmentState();
}

class _ProxiesListFragmentState
    extends State<ProxiesListFragment> {
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
      builder: (_, state, __) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.groupNames.length,
          itemBuilder: (_, index) {
            final groupName = state.groupNames[index];
            return ProxyGroupView(
              key: PageStorageKey(groupName),
              groupName: groupName,
              type: ProxiesType.list,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(
              height: 16,
            );
          },
        );
      },
    );
  }
}
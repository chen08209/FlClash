import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProxiesExpansionPanelFragment extends StatefulWidget {
  const ProxiesExpansionPanelFragment({super.key});

  @override
  State<ProxiesExpansionPanelFragment> createState() =>
      _ProxiesExpansionPanelFragmentState();
}

class _ProxiesExpansionPanelFragmentState
    extends State<ProxiesExpansionPanelFragment> {
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
            return CommonCard(
              child: ExpansionTile(
                title: Text(groupName),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: const BorderSide(color: Colors.transparent),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: const BorderSide(color: Colors.transparent),
                ),
                children: [
                  Text("1212313"),
                ],
              ),
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

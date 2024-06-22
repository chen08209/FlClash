import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/tabview.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProxiesFragment extends StatefulWidget {
  const ProxiesFragment({super.key});

  @override
  State<ProxiesFragment> createState() => _ProxiesFragmentState();
}

class _ProxiesFragmentState extends State<ProxiesFragment> {

  _initActions() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      final items = [
        CommonPopupMenuItem(
          action: ProxiesSortType.none,
          label: appLocalizations.defaultSort,
          iconData: Icons.sort,
        ),
        CommonPopupMenuItem(
            action: ProxiesSortType.delay,
            label: appLocalizations.delaySort,
            iconData: Icons.network_ping),
        CommonPopupMenuItem(
            action: ProxiesSortType.name,
            label: appLocalizations.nameSort,
            iconData: Icons.sort_by_alpha),
      ];
      commonScaffoldState?.actions = [
        Selector<Config, ProxiesSortType>(
          selector: (_, config) => config.proxiesSortType,
          builder: (_, proxiesSortType, __) {
            return CommonPopupMenu<ProxiesSortType>.radio(
              items: items,
              onSelected: (value) {
                final config = context.read<Config>();
                config.proxiesSortType = value;
              },
              selectedValue: proxiesSortType,
            );
          },
        ),
        const SizedBox(
          width: 8,
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.currentLabel == 'proxies',
      builder: (_, isCurrent, child) {
        if (isCurrent) {
          _initActions();
        }
        return child!;
      },
      child: const ProxiesTabFragment(),
    );
  }
}


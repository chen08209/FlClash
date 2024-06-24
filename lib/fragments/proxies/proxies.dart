import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/expansion_panel.dart';
import 'package:fl_clash/fragments/proxies/tabview.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
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
          iconData: Icons.reorder,
        ),
        CommonPopupMenuItem(
          action: ProxiesSortType.delay,
          label: appLocalizations.delaySort,
          iconData: Icons.network_ping,
        ),
        CommonPopupMenuItem(
          action: ProxiesSortType.name,
          label: appLocalizations.nameSort,
          iconData: Icons.sort_by_alpha,
        ),
      ];
      commonScaffoldState?.actions = [
        IconButton(
          icon: const Icon(
            Icons.view_column,
          ),
          onPressed: () {
            globalState.appController.changeColumns();
          },
        ),
        Selector<Config, ProxyCardType>(
          selector: (_, config) => config.proxyCardType,
          builder: (_, proxyCardType, __) {
            return IconButton(
              icon: Icon(
                switch (proxyCardType) {
                  ProxyCardType.expand => Icons.compress,
                  ProxyCardType.shrink => Icons.aspect_ratio,
                },
              ),
              onPressed: () {
                final config = globalState.appController.config;
                config.proxyCardType =
                    config.proxyCardType == ProxyCardType.expand
                        ? ProxyCardType.shrink
                        : ProxyCardType.expand;
              },
            );
          },
        ),
        Selector<Config, ProxiesType>(
          selector: (_, config) => config.proxiesType,
          builder: (_, proxiesType, __) {
            return IconButton(
              icon: Icon(
                switch (proxiesType) {
                  ProxiesType.tab => Icons.view_list,
                  ProxiesType.expansion => Icons.view_carousel,
                },
              ),
              onPressed: () {
                final config = globalState.appController.config;
                config.proxiesType = config.proxiesType == ProxiesType.tab
                    ? ProxiesType.expansion
                    : ProxiesType.tab;
              },
            );
          },
        ),
        Selector<Config, ProxiesSortType>(
          selector: (_, config) => config.proxiesSortType,
          builder: (_, proxiesSortType, __) {
            return CommonPopupMenu<ProxiesSortType>.radio(
              items: items,
              icon: const Icon(Icons.sort),
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
      child: Selector<Config, ProxiesType>(
        selector: (_, config) => config.proxiesType,
        builder: (_, proxiesType, __) {
          return switch (proxiesType) {
            ProxiesType.tab => const ProxiesTabFragment(),
            ProxiesType.expansion => const ProxiesExpansionPanelFragment(),
          };
        },
      ),
    );
  }
}

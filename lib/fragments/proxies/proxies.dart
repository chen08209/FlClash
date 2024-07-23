import 'package:fl_clash/common/app_localizations.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/proxies/list.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'setting.dart';
import 'tab.dart';

class ProxiesFragment extends StatefulWidget {
  const ProxiesFragment({super.key});

  @override
  State<ProxiesFragment> createState() => _ProxiesFragmentState();
}

class _ProxiesFragmentState extends State<ProxiesFragment> {
  final GlobalKey<ProxiesTabFragmentState> _proxiesTabKey = GlobalKey();

  _initActions(ProxiesType proxiesType) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final commonScaffoldState =
          context.findAncestorStateOfType<CommonScaffoldState>();
      commonScaffoldState?.actions = [
        if (proxiesType == ProxiesType.tab) ...[
          IconButton(
            onPressed: () {
              _proxiesTabKey.currentState?.scrollToGroupSelected();
            },
            icon: const Icon(
              Icons.gps_fixed,
            ),
          ),
          const SizedBox(
            width: 8,
          )
        ],
        IconButton(
          onPressed: () {
            showSheet(
              title: appLocalizations.proxiesSetting,
              context: context,
              builder: (context) {
                return const ProxiesSettingWidget();
              },
            );
          },
          icon: const Icon(
            Icons.tune,
          ),
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<Config, ProxiesType>(
      selector: (_, config) => config.proxiesType,
      builder: (_, proxiesType, __) {
        return Selector<AppState, bool>(
          selector: (_, appState) => appState.currentLabel == 'proxies',
          builder: (_, isCurrent, child) {
            if (isCurrent) {
              _initActions(proxiesType);
            }
            return switch (proxiesType) {
              ProxiesType.tab => ProxiesTabFragment(
                  key: _proxiesTabKey,
                ),
              ProxiesType.list => const ProxiesListFragment(),
            };
          },
        );
      },
    );
  }
}

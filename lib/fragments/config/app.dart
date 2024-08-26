import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show dirname, join;
import 'package:provider/provider.dart';

class CloseConnectionsSwitch extends StatelessWidget {
  const CloseConnectionsSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.isCloseConnections,
      builder: (_, isCloseConnections, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.auto_delete_outlined),
          title: Text(appLocalizations.autoCloseConnections),
          subtitle: Text(appLocalizations.autoCloseConnectionsDesc),
          delegate: SwitchDelegate(
            value: isCloseConnections,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.config.isCloseConnections = value;
            },
          ),
        );
      },
    );
  }
}

class UsageSwitch extends StatelessWidget {
  const UsageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.onlyProxy,
      builder: (_, onlyProxy, __) {
        return ListItem.switchItem(
          leading: const Icon(Icons.data_usage_outlined),
          title: Text(appLocalizations.onlyStatisticsProxy),
          subtitle: Text(appLocalizations.onlyStatisticsProxyDesc),
          delegate: SwitchDelegate(
            value: onlyProxy,
            onChanged: (bool value) async {
              final appController = globalState.appController;
              appController.config.onlyProxy = value;
            },
          ),
        );
      },
    );
  }
}

class UWPLoopbackUtil extends StatelessWidget {
  const UWPLoopbackUtil({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.onlyProxy,
      builder: (_, onlyProxy, __) {
        return ListItem(
          leading: const Icon(Icons.lock_open),
          title: Text(appLocalizations.loopback),
          subtitle: Text(appLocalizations.loopbackDesc),
          onTap: () {
            windows?.runas(
              '"${join(dirname(Platform.resolvedExecutable), "EnableLoopback.exe")}"',
              "",
            );
          },
        );
      },
    );
  }
}

final appItems = [
  if (Platform.isWindows) const UWPLoopbackUtil(),
  const CloseConnectionsSwitch(),
  const UsageSwitch(),
];

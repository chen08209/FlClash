import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CloseConnectionsSwitch extends StatelessWidget {
  const CloseConnectionsSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<Config, bool>(
      selector: (_, config) => config.appSetting.closeConnections,
      builder: (_, closeConnections, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.autoCloseConnections),
          subtitle: Text(appLocalizations.autoCloseConnectionsDesc),
          delegate: SwitchDelegate(
            value: closeConnections,
            onChanged: (value) async {
              final config = globalState.appController.config;
              config.appSetting = config.appSetting.copyWith(
                closeConnections: value,
              );
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
      selector: (_, config) => config.appSetting.onlyProxy,
      builder: (_, onlyProxy, __) {
        return ListItem.switchItem(
          title: Text(appLocalizations.onlyStatisticsProxy),
          subtitle: Text(appLocalizations.onlyStatisticsProxyDesc),
          delegate: SwitchDelegate(
            value: onlyProxy,
            onChanged: (bool value) async {
              final config = globalState.appController.config;
              config.appSetting = config.appSetting.copyWith(
                onlyProxy: value,
              );
            },
          ),
        );
      },
    );
  }
}

class ApplicationSettingFragment extends StatelessWidget {
  const ApplicationSettingFragment({super.key});

  String getLocaleString(Locale? locale) {
    if (locale == null) return appLocalizations.defaultText;
    return Intl.message(locale.toString());
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [
      Selector<Config, bool>(
        selector: (_, config) => config.appSetting.minimizeOnExit,
        builder: (_, isMinimizeOnExit, child) {
          return ListItem.switchItem(
            title: Text(appLocalizations.minimizeOnExit),
            subtitle: Text(appLocalizations.minimizeOnExitDesc),
            delegate: SwitchDelegate(
              value: isMinimizeOnExit,
              onChanged: (bool value) {
                final config = context.read<Config>();
                config.appSetting = config.appSetting.copyWith(
                  minimizeOnExit: value,
                );
              },
            ),
          );
        },
      ),
      if (system.isDesktop)
        Selector<Config, bool>(
          selector: (_, config) => config.appSetting.autoLaunch,
          builder: (_, autoLaunch, child) {
            return ListItem.switchItem(
              title: Text(appLocalizations.autoLaunch),
              subtitle: Text(appLocalizations.autoLaunchDesc),
              delegate: SwitchDelegate(
                value: autoLaunch,
                onChanged: (bool value) {
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    autoLaunch: value,
                  );
                },
              ),
            );
          },
        ),
      if (system.isDesktop)
        Selector<Config, bool>(
          selector: (_, config) => config.appSetting.silentLaunch,
          builder: (_, silentLaunch, child) {
            return ListItem.switchItem(
              title: Text(appLocalizations.silentLaunch),
              subtitle: Text(appLocalizations.silentLaunchDesc),
              delegate: SwitchDelegate(
                value: silentLaunch,
                onChanged: (bool value) {
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    silentLaunch: value,
                  );
                },
              ),
            );
          },
        ),
      Selector<Config, bool>(
        selector: (_, config) => config.appSetting.autoRun,
        builder: (_, autoRun, child) {
          return ListItem.switchItem(
            title: Text(appLocalizations.autoRun),
            subtitle: Text(appLocalizations.autoRunDesc),
            delegate: SwitchDelegate(
              value: autoRun,
              onChanged: (bool value) {
                final config = globalState.appController.config;
                config.appSetting = config.appSetting.copyWith(
                  autoRun: value,
                );
              },
            ),
          );
        },
      ),
      if (Platform.isAndroid)
        Selector<Config, bool>(
          selector: (_, config) => config.appSetting.hidden,
          builder: (_, isExclude, child) {
            return ListItem.switchItem(
              title: Text(appLocalizations.exclude),
              subtitle: Text(appLocalizations.excludeDesc),
              delegate: SwitchDelegate(
                value: isExclude,
                onChanged: (value) {
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    hidden: value,
                  );
                },
              ),
            );
          },
        ),
      if (Platform.isAndroid)
        Selector<Config, bool>(
          selector: (_, config) => config.appSetting.isAnimateToPage,
          builder: (_, isAnimateToPage, child) {
            return ListItem.switchItem(
              title: Text(appLocalizations.tabAnimation),
              subtitle: Text(appLocalizations.tabAnimationDesc),
              delegate: SwitchDelegate(
                value: isAnimateToPage,
                onChanged: (value) {
                  final config = globalState.appController.config;
                  config.appSetting = config.appSetting.copyWith(
                    isAnimateToPage: value,
                  );
                },
              ),
            );
          },
        ),
      Selector<Config, bool>(
        selector: (_, config) => config.appSetting.openLogs,
        builder: (_, openLogs, child) {
          return ListItem.switchItem(
            title: Text(appLocalizations.logcat),
            subtitle: Text(appLocalizations.logcatDesc),
            delegate: SwitchDelegate(
              value: openLogs,
              onChanged: (bool value) {
                final config = globalState.appController.config;
                config.appSetting = config.appSetting.copyWith(
                  openLogs: value,
                );
              },
            ),
          );
        },
      ),
      const CloseConnectionsSwitch(),
      const UsageSwitch(),
      Selector<Config, bool>(
        selector: (_, config) => config.appSetting.autoCheckUpdate,
        builder: (_, autoCheckUpdate, child) {
          return ListItem.switchItem(
            title: Text(appLocalizations.autoCheckUpdate),
            subtitle: Text(appLocalizations.autoCheckUpdateDesc),
            delegate: SwitchDelegate(
              value: autoCheckUpdate,
              onChanged: (bool value) {
                final config = globalState.appController.config;
                config.appSetting = config.appSetting.copyWith(
                  autoCheckUpdate: value,
                );
              },
            ),
          );
        },
      ),
    ];
    return ListView.separated(
      itemBuilder: (_, index) {
        final item = items[index];
        return item;
      },
      separatorBuilder: (_, __) {
        return const Divider(
          height: 0,
        );
      },
      itemCount: items.length,
    );
  }
}

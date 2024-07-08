import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
        selector: (_, config) => config.isMinimizeOnExit,
        builder: (_, isMinimizeOnExit, child) {
          return ListItem.switchItem(
            leading: const Icon(Icons.back_hand),
            title: Text(appLocalizations.minimizeOnExit),
            subtitle: Text(appLocalizations.minimizeOnExitDesc),
            delegate: SwitchDelegate(
              value: isMinimizeOnExit,
              onChanged: (bool value) {
                final config = context.read<Config>();
                config.isMinimizeOnExit = value;
              },
            ),
          );
        },
      ),
      if (system.isDesktop)
        Selector<Config, bool>(
          selector: (_, config) => config.autoLaunch,
          builder: (_, autoLaunch, child) {
            return ListItem.switchItem(
              leading: const Icon(Icons.rocket_launch),
              title: Text(appLocalizations.autoLaunch),
              subtitle: Text(appLocalizations.autoLaunchDesc),
              delegate: SwitchDelegate(
                value: autoLaunch,
                onChanged: (bool value) {
                  final config = context.read<Config>();
                  config.autoLaunch = value;
                },
              ),
            );
          },
        ),
      if (system.isDesktop)
        Selector<Config, bool>(
          selector: (_, config) => config.silentLaunch,
          builder: (_, silentLaunch, child) {
            return ListItem.switchItem(
              leading: const Icon(Icons.expand_circle_down),
              title: Text(appLocalizations.silentLaunch),
              subtitle: Text(appLocalizations.silentLaunchDesc),
              delegate: SwitchDelegate(
                value: silentLaunch,
                onChanged: (bool value) {
                  final config = context.read<Config>();
                  config.silentLaunch = value;
                },
              ),
            );
          },
        ),
      Selector<Config, bool>(
        selector: (_, config) => config.autoRun,
        builder: (_, autoRun, child) {
          return ListItem.switchItem(
            leading: const Icon(Icons.start),
            title: Text(appLocalizations.autoRun),
            subtitle: Text(appLocalizations.autoRunDesc),
            delegate: SwitchDelegate(
              value: autoRun,
              onChanged: (bool value) {
                final config = context.read<Config>();
                config.autoRun = value;
              },
            ),
          );
        },
      ),
      if (Platform.isAndroid)
        Selector<Config, bool>(
          selector: (_, config) => config.isExclude,
          builder: (_, isExclude, child) {
            return ListItem.switchItem(
              leading: const Icon(Icons.visibility_off),
              title: Text(appLocalizations.exclude),
              subtitle: Text(appLocalizations.excludeDesc),
              delegate: SwitchDelegate(
                value: isExclude,
                onChanged: (value) {
                  final config = context.read<Config>();
                  config.isExclude = value;
                },
              ),
            );
          },
        ),
      if (Platform.isAndroid)
        Selector<Config, bool>(
          selector: (_, config) => config.isAnimateToPage,
          builder: (_, isAnimateToPage, child) {
            return ListItem.switchItem(
              leading: const Icon(Icons.animation),
              title: Text(appLocalizations.tabAnimation),
              subtitle: Text(appLocalizations.tabAnimationDesc),
              delegate: SwitchDelegate(
                value: isAnimateToPage,
                onChanged: (value) {
                  final config = context.read<Config>();
                  config.isAnimateToPage = value;
                },
              ),
            );
          },
        ),
      Selector<Config, bool>(
        selector: (_, config) => config.openLogs,
        builder: (_, openLogs, child) {
          return ListItem.switchItem(
            leading: const Icon(Icons.bug_report),
            title: Text(appLocalizations.logcat),
            subtitle: Text(appLocalizations.logcatDesc),
            delegate: SwitchDelegate(
              value: openLogs,
              onChanged: (bool value) {
                final config = context.read<Config>();
                config.openLogs = value;
                globalState.appController.updateLogStatus();
              },
            ),
          );
        },
      ),
      Selector<Config, bool>(
        selector: (_, config) => config.autoCheckUpdate,
        builder: (_, autoCheckUpdate, child) {
          return ListItem.switchItem(
            leading: const Icon(Icons.system_update),
            title: Text(appLocalizations.autoCheckUpdate),
            subtitle: Text(appLocalizations.autoCheckUpdateDesc),
            delegate: SwitchDelegate(
              value: autoCheckUpdate,
              onChanged: (bool value) {
                final config = context.read<Config>();
                config.autoCheckUpdate = value;
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

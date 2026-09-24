import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:tray/tray.dart';

import 'app_localizations.dart';
import 'l10n_labels.dart';
import 'app_ports.dart';
import 'constant.dart';
import 'keyboard.dart';
import 'provider_reader.dart';
import 'system.dart';
import 'window.dart';

class AppTray implements TrayPort {
  static AppTray? _instance;

  final bool isMacOS;
  final bool isWindows;

  bool _isShutDown = false;

  AppTray._internal({required this.isMacOS, required this.isWindows});

  factory AppTray() {
    _instance ??= AppTray._internal(
      isMacOS: system.isMacOS,
      isWindows: system.isWindows,
    );
    return _instance!;
  }

  @visibleForTesting
  factory AppTray.forPlatform({
    required bool isMacOS,
    required bool isWindows,
  }) {
    return AppTray._internal(isMacOS: isMacOS, isWindows: isWindows);
  }

  String get _trayIconSuffix {
    return isWindows ? 'ico' : 'png';
  }

  String get _trayIconDir {
    return isWindows ? 'assets/images/tray/windows' : 'assets/images/tray/unix';
  }

  String getTrayIcon({
    required bool isStart,
    required bool tunEnable,
    required bool safeMode,
  }) {
    final status = switch ((safeMode, isMacOS || !isStart, tunEnable)) {
      (true, _, _) => 4,
      (false, true, _) => 1,
      (false, false, false) => 2,
      (false, false, true) => 3,
    };
    return '$_trayIconDir/status_$status.$_trayIconSuffix';
  }

  @override
  Future<void> shutdown() async {
    _isShutDown = true;
    await Tray.instance.hide();
  }

  @override
  Future<void> update({
    required TrayState trayState,
    required Traffic traffic,
    required ProviderReader read,
  }) async {
    if (_isShutDown) {
      return;
    }
    await Tray.instance.show(
      TraySpec(
        icon: TrayIcon.asset(
          getTrayIcon(
            isStart: trayState.isStart,
            tunEnable: trayState.tunEnable,
            safeMode: trayState.safeMode,
          ),
          isTemplate: isMacOS,
        ),
        toolTip: trayState.safeMode
            ? currentAppLocalizations.safeModeAppTitle(appName)
            : appName,
        menu: _buildMenu(trayState: trayState, read: read),
      ),
    );
    await updateTitle(showTrayTitle: trayState.showTrayTitle, traffic: traffic);
  }

  Future<void> updateTitle({
    required bool showTrayTitle,
    required Traffic traffic,
  }) async {
    if (_isShutDown || !isMacOS) {
      return;
    }
    await Tray.instance.setTitle(showTrayTitle ? traffic.trayTitle : '');
  }

  List<TrayMenuItem> _buildMenu({
    required TrayState trayState,
    required ProviderReader read,
  }) {
    final commonAction = read(commonActionProvider.notifier);
    final systemAction = read(systemActionProvider.notifier);
    final setupAction = read(setupActionProvider.notifier);
    final appLocalizations = currentAppLocalizations;
    String? shortcut(HotAction action) => _shortcut(trayState, action);
    final showItem = TrayMenuAction(
      label: appLocalizations.show,
      detail: shortcut(HotAction.view),
      onSelected: () {
        window?.show();
      },
    );
    final exitItem = TrayMenuAction(
      label: appLocalizations.exit,
      detail: shortcut(HotAction.exit),
      onSelected: () {
        systemAction.handleExit();
      },
    );

    return [
      showItem,
      TrayMenuCheckbox(
        label: trayState.isStart
            ? appLocalizations.stop
            : appLocalizations.start,
        checked: false,
        detail: shortcut(HotAction.start),
        onSelected: commonAction.toggleRunning,
      ),
      if (isMacOS)
        TrayMenuCheckbox(
          label: appLocalizations.speedStatistics,
          checked: trayState.showTrayTitle,
          onSelected: commonAction.updateSpeedStatistics,
        ),
      const TrayMenuSeparator(),
      for (final mode in Mode.values)
        TrayMenuCheckbox(
          label: mode.label,
          checked: mode == trayState.mode,
          detail: shortcut(switch (mode) {
            Mode.rule => HotAction.ruleMode,
            Mode.global => HotAction.globalMode,
            Mode.direct => HotAction.directMode,
          }),
          onSelected: () {
            setupAction.changeMode(mode);
          },
        ),
      const TrayMenuSeparator(),
      if (isMacOS) ..._buildGroupMenu(trayState: trayState, read: read),
      if (trayState.isStart) ...[
        TrayMenuCheckbox(
          label: appLocalizations.tun,
          checked: trayState.tunEnable,
          detail: shortcut(HotAction.tun),
          onSelected: systemAction.updateTun,
        ),
        TrayMenuCheckbox(
          label: appLocalizations.systemProxy,
          checked: trayState.systemProxy,
          detail: shortcut(HotAction.proxy),
          onSelected: systemAction.updateSystemProxy,
        ),
        const TrayMenuSeparator(),
      ],
      TrayMenuCheckbox(
        label: appLocalizations.autoLaunch,
        checked: trayState.autoLaunch,
        onSelected: systemAction.updateAutoLaunch,
      ),
      TrayMenuAction(
        label: appLocalizations.copyEnvVar,
        detail: shortcut(HotAction.copyEnv),
        onSelected: systemAction.copyProxyEnv,
      ),
      const TrayMenuSeparator(),
      exitItem,
    ];
  }

  String? _shortcut(TrayState trayState, HotAction action) {
    final hotKey = trayState.hotKeys[action];
    final key = hotKey?.key;
    if (hotKey == null || key == null) {
      return null;
    }
    return ShortcutLabels(
      isMacOS: isMacOS,
      isWindows: isWindows,
    ).text(hotKey.modifiers, key);
  }

  String? _delayText(int? delay) {
    if (delay == null) {
      return null;
    }
    return delay > 0 ? '$delay' : currentAppLocalizations.timeout;
  }

  // Shares the 600 ms threshold of ColorScheme.delayColor on a proxy card.
  TrayDetailTone _delayTone(int? delay) {
    return switch (delay) {
      null => TrayDetailTone.plain,
      <= 0 => TrayDetailTone.error,
      < 600 => TrayDetailTone.success,
      _ => TrayDetailTone.warning,
    };
  }

  List<TrayMenuItem> _buildGroupMenu({
    required TrayState trayState,
    required ProviderReader read,
  }) {
    if (trayState.groups.isEmpty) {
      return const [];
    }
    final delays = read(trayDelaysProvider);
    final proxiesAction = read(proxiesActionProvider.notifier);
    return [
      for (final group in trayState.groups)
        _buildGroupSubmenu(
          group,
          selectedName: read(selectedProxyNameProvider(group.name)),
          delays: delays[group.name] ?? const {},
          onSelected: (proxyName) {
            proxiesAction.changeProxy(
              groupName: group.name,
              proxyName: proxyName,
            );
          },
        ),
      TrayMenuAction(
        label: HotAction.delayTest.label,
        detail: _shortcut(trayState, HotAction.delayTest),
        onSelected: () {
          proxiesAction.delayTestGroups(trayState.groups);
        },
      ),
      const TrayMenuSeparator(),
    ];
  }

  TrayMenuSubmenu _buildGroupSubmenu(
    Group group, {
    required String? selectedName,
    required Map<String, int> delays,
    required void Function(String proxyName) onSelected,
  }) {
    return TrayMenuSubmenu(
      label: group.name,
      detail: _delayText(delays[selectedName]),
      detailTone: _delayTone(delays[selectedName]),
      items: [
        for (final proxy in group.all)
          TrayMenuCheckbox(
            label: proxy.name,
            checked: selectedName == proxy.name,
            detail: _delayText(delays[proxy.name]),
            detailTone: _delayTone(delays[proxy.name]),
            onSelected: () {
              onSelected(proxy.name);
            },
          ),
      ],
    );
  }
}

final appTray = system.isDesktop ? AppTray() : null;

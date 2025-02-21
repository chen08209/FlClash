import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/fragments.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';

class Navigation {
  static Navigation? _instance;

  getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      const NavigationItem(
        icon: Icon(Icons.space_dashboard),
        label: "dashboard",
        fragment: DashboardFragment(),
      ),
      NavigationItem(
        icon: const Icon(Icons.rocket),
        label: "proxies",
        fragment: const ProxiesFragment(),
        modes: hasProxies
            ? [NavigationItemMode.mobile, NavigationItemMode.desktop]
            : [],
      ),
      const NavigationItem(
        icon: Icon(Icons.folder),
        label: "profiles",
        fragment: ProfilesFragment(),
      ),
      const NavigationItem(
        icon: Icon(Icons.view_timeline),
        label: "requests",
        fragment: RequestsFragment(),
        description: "requestsDesc",
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      const NavigationItem(
        icon: Icon(Icons.ballot),
        label: "connections",
        fragment: ConnectionsFragment(),
        description: "connectionsDesc",
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      const NavigationItem(
        icon: Icon(Icons.storage),
        label: "resources",
        description: "resourcesDesc",
        keep: false,
        fragment: Resources(),
        modes: [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.adb),
        label: "logs",
        fragment: const LogsFragment(),
        description: "logsDesc",
        modes: openLogs
            ? [NavigationItemMode.desktop, NavigationItemMode.more]
            : [],
      ),
      // 隐藏 tools 导航项（不删除，仅移除 modes 使其不显示）
      const NavigationItem(
        icon: Icon(Icons.construction),
        label: "tools",
        fragment: ToolsFragment(),
        modes: [],
      ),
      // 新增个人中心导航项，默认桌面端和移动端均显示
      const NavigationItem(
        icon: Icon(Icons.person),
        label: "个人中心",
        fragment: PersonalCenterFragment(),
        modes: [NavigationItemMode.desktop, NavigationItemMode.mobile],
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();

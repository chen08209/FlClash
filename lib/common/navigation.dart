import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/views/account_info.dart';
import 'package:flutter/material.dart';

class Navigation {
  static Navigation? _instance;

  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      const NavigationItem(
        keep: false,
        icon: Icon(Icons.space_dashboard),
        label: PageLabel.dashboard,
        view: DashboardView(
          key: GlobalObjectKey(PageLabel.dashboard),
        ),
      ),
      NavigationItem(
        icon: const Icon(Icons.article),
        label: PageLabel.proxies,
        view: const ProxiesView(
          key: GlobalObjectKey(
            PageLabel.proxies,
          ),
        ),
        modes: hasProxies
            ? [NavigationItemMode.mobile, NavigationItemMode.desktop]
            : [],
      ),
      const NavigationItem(
        icon: Icon(Icons.view_timeline),
        label: PageLabel.requests,
        view: RequestsView(
          key: GlobalObjectKey(
            PageLabel.requests,
          ),
        ),
        description: "requestsDesc",
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      const NavigationItem(
        icon: Icon(Icons.ballot),
        label: PageLabel.connections,
        view: ConnectionsView(
          key: GlobalObjectKey(
            PageLabel.connections,
          ),
        ),
        description: "connectionsDesc",
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      const NavigationItem(
        icon: Icon(Icons.storage),
        label: PageLabel.resources,
        description: "resourcesDesc",
        view: ResourcesView(
          key: GlobalObjectKey(
            PageLabel.resources,
          ),
        ),
        modes: [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.adb),
        label: PageLabel.logs,
        view: const LogsView(
          key: GlobalObjectKey(
            PageLabel.logs,
          ),
        ),
        description: "logsDesc",
        modes: openLogs
            ? [NavigationItemMode.desktop, NavigationItemMode.more]
            : [],
      ),
      const NavigationItem(
        icon: Icon(Icons.construction),
        label: PageLabel.tools,
        view: ToolsView(
          key: GlobalObjectKey(
            PageLabel.tools,
          ),
        ),
        modes: [NavigationItemMode.desktop, NavigationItemMode.mobile],
      ),
      const NavigationItem(
        icon: Icon(Icons.account_circle),
        label: PageLabel.account,
        view: AccountInfoPage(
          key: GlobalObjectKey(
            PageLabel.account,
          ),
        ),
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

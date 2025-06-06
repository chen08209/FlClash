import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Navigation {
  static Navigation? _instance;

  List<NavigationItem> getItems({
    bool openLogs = false,
    bool hasProxies = false,
  }) {
    return [
      NavigationItem(
        keep: false,
        icon: Icon(Icons.space_dashboard),
        label: PageLabel.dashboard,
        builder: (_) => const DashboardView(
          key: GlobalObjectKey(PageLabel.dashboard),
        ),
      ),
      NavigationItem(
        icon: const Icon(Icons.article),
        label: PageLabel.proxies,
        builder: (_) => ProviderScope(
          overrides: [
            queryProvider.overrideWith(
              () => Query(),
            ),
          ],
          child: const ProxiesView(
            key: GlobalObjectKey(
              PageLabel.proxies,
            ),
          ),
        ),
        modes: hasProxies
            ? [NavigationItemMode.mobile, NavigationItemMode.desktop]
            : [],
      ),
      NavigationItem(
        icon: Icon(Icons.folder),
        label: PageLabel.profiles,
        builder: (_) => const ProfilesView(
          key: GlobalObjectKey(
            PageLabel.profiles,
          ),
        ),
      ),
      NavigationItem(
        icon: Icon(Icons.view_timeline),
        label: PageLabel.requests,
        builder: (_) => const RequestsView(
          key: GlobalObjectKey(
            PageLabel.requests,
          ),
        ),
        description: 'requestsDesc',
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        icon: Icon(Icons.ballot),
        label: PageLabel.connections,
        builder: (_) => const ConnectionsView(
          key: GlobalObjectKey(
            PageLabel.connections,
          ),
        ),
        description: 'connectionsDesc',
        modes: [NavigationItemMode.desktop, NavigationItemMode.more],
      ),
      NavigationItem(
        icon: Icon(Icons.storage),
        label: PageLabel.resources,
        description: 'resourcesDesc',
        builder: (_) => const ResourcesView(
          key: GlobalObjectKey(
            PageLabel.resources,
          ),
        ),
        modes: [NavigationItemMode.more],
      ),
      NavigationItem(
        icon: const Icon(Icons.adb),
        label: PageLabel.logs,
        builder: (_) => const LogsView(
          key: GlobalObjectKey(
            PageLabel.logs,
          ),
        ),
        description: 'logsDesc',
        modes: openLogs
            ? [NavigationItemMode.desktop, NavigationItemMode.more]
            : [],
      ),
      NavigationItem(
        icon: Icon(Icons.construction),
        label: PageLabel.tools,
        builder: (_) => const ToolsView(
          key: GlobalObjectKey(
            PageLabel.tools,
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

// lib/common/navigation.dart
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/fragments/fragments.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';

class Navigation {
  static Navigation? _instance;

  List<NavigationItem> getItems({
    bool openLogs = false,  // 保留参数，但不再使用
    bool hasProxies = false, // 保留参数，但不再使用
  }) {
    return [
      const NavigationItem(
        icon: Icon(Icons.space_dashboard),
        label: "dashboard",
        fragment: DashboardFragment(),
      ),
      const NavigationItem(
        icon: Icon(Icons.folder),
        label: "profiles",
        fragment: ProfilesFragment(),
      ),
      const NavigationItem(
        icon: Icon(Icons.rocket),
        label: "proxies",
        fragment: ProxiesFragment(),
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

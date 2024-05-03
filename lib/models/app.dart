import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'ffi.dart';
import 'log.dart';
import 'navigation.dart';
import 'package.dart';
import 'proxy.dart';
import 'system_color_scheme.dart';
import 'traffic.dart';
import 'version.dart';

class AppState with ChangeNotifier {
  List<NavigationItem> _navigationItems;
  int? _runTime;
  bool _isInit;
  DelayMap _delayMap;
  VersionInfo? _versionInfo;
  List<Traffic> _traffics;
  List<Log> _logs;
  List<Package> _packages;
  String _currentLabel;
  SystemColorSchemes _systemColorSchemes;
  List<Group> _groups;

  AppState()
      : _navigationItems = [],
        _delayMap = {},
        _isInit = false,
        _currentLabel = "dashboard",
        _traffics = [],
        _logs = [],
        _groups = [],
        _packages = [],
        _systemColorSchemes = SystemColorSchemes();

  String get currentLabel => _currentLabel;

  set currentLabel(String value) {
    if (_currentLabel != value) {
      _currentLabel = value;
      notifyListeners();
    }
  }

  List<NavigationItem> get navigationItems => _navigationItems;

  set navigationItems(List<NavigationItem> value) {
    if (!const ListEquality<NavigationItem>().equals(_navigationItems, value)) {
      _navigationItems = value;
      notifyListeners();
    }
  }

  bool get isInit => _isInit;

  set isInit(bool value) {
    if (_isInit != value) {
      _isInit = value;
      notifyListeners();
    }
  }

  int? get runTime => _runTime;

  set runTime(int? value) {
    if (_runTime != value) {
      _runTime = value;
      notifyListeners();
    }
  }

  DelayMap get delayMap => _delayMap;

  set delayMap(DelayMap value) {
    if (_delayMap != value) {
      _delayMap = value;
      notifyListeners();
    }
  }

  setDelay(Delay delay) {
    if (_delayMap[delay.name] != delay.value) {
      _delayMap = Map.from(_delayMap)..[delay.name] = delay.value;
      notifyListeners();
    }
  }

  VersionInfo? get versionInfo => _versionInfo;

  set versionInfo(VersionInfo? value) {
    if (_versionInfo != value) {
      _versionInfo = value;
      notifyListeners();
    }
  }

  List<Traffic> get traffics => _traffics;

  set traffics(List<Traffic> value) {
    if (_traffics != value) {
      _traffics = value;
      notifyListeners();
    }
  }

  addTraffic(Traffic value) {
    _traffics = List.from(_traffics)..add(value);
    notifyListeners();
  }

  List<Log> get logs => _logs;

  set logs(List<Log> value) {
    if (_logs != value) {
      _logs = value;
      notifyListeners();
    }
  }

  addLog(Log log) {
    _logs.add(log);
    notifyListeners();
  }

  SystemColorSchemes get systemColorSchemes => _systemColorSchemes;

  set systemColorSchemes(SystemColorSchemes value) {
    if (_systemColorSchemes != value) {
      _systemColorSchemes = value;
      notifyListeners();
    }
  }

  List<Package> get packages => _packages;

  set packages(List<Package> value) {
    if (_packages != value) {
      _packages = value;
      notifyListeners();
    }
  }

  List<Group> get groups => _groups;

  set groups(List<Group> value) {
    if (_groups != value) {
      _groups = value;
      notifyListeners();
    }
  }

  List<Group> getCurrentGroups(Mode mode) {
    switch (mode) {
      case Mode.direct:
        return [];
      case Mode.global:
        return groups
            .where((element) => element.name == UsedProxy.GLOBAL.name)
            .toList();
      case Mode.rule:
        return groups
            .where((element) => element.name != UsedProxy.GLOBAL.name)
            .toList();
    }
  }

  String? getCurrentGroupNameWithGroups(
    List<Group> groups,
    String? groupName,
    Mode mode,
  ) {
    switch (mode) {
      case Mode.direct:
        return null;
      case Mode.global:
        return UsedProxy.GLOBAL.name;
      case Mode.rule:
        return groupName ?? (groups.isNotEmpty ? groups.first.name : null);
    }
  }

  String? getCurrentGroupName(String? groupName, Mode mode) {
    final currentGroups = getCurrentGroups(mode);
    return getCurrentGroupNameWithGroups(currentGroups, groupName, mode);
  }

  String? getCurrentProxyName(String? proxyName, Mode mode) {
    final currentGroups = getCurrentGroups(mode);
    switch (mode) {
      case Mode.direct:
        return UsedProxy.DIRECT.name;
      case Mode.global || Mode.rule:
        return proxyName ??
            (currentGroups.isNotEmpty ? currentGroups.first.now : null);
    }
  }
}

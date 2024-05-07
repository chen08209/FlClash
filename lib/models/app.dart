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
  num _sortNum;
  Mode _mode;
  String? _currentProxyName;

  AppState({required Mode mode, required currentProxyName})
      : _navigationItems = [],
        _delayMap = {},
        _isInit = false,
        _currentLabel = "dashboard",
        _traffics = [],
        _logs = [],
        _groups = [],
        _packages = [],
        _sortNum = 0,
        _mode = mode,
        _currentProxyName = currentProxyName,
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

  String getDesc(String type, String? proxyName) {
    final groupTypeNamesList = GroupType.values.map((e) => e.name).toList();
    if (!groupTypeNamesList.contains(type)) {
      return type;
    }else{
      final index = groups.indexWhere((element) => element.name == proxyName);
      if(index == -1) return type;
      return "$type(${groups[index].now})";
    }
  }

  int? getDelay(String? proxyName) {
    if (proxyName == null) return null;
    final index = groups.indexWhere((element) => element.name == proxyName);
    if (index == -1) return _delayMap[proxyName];
    final group = groups[index];
    if (group.now == null) return null;
    return _delayMap[group.now];
  }

  String? get realCurrentProxyName {
    if (currentProxyName == null) return null;
    final index = groups.indexWhere((element) => element.name == currentProxyName);
    if (index == -1) return currentProxyName;
    final group = groups[index];
    if (group.now == null) return null;
    return group.now;
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
    if (!const ListEquality<Group>().equals(_groups, value)) {
      _groups = value;
      notifyListeners();
    }
  }

  num get sortNum => _sortNum;

  set sortNum(num value) {
    if (_sortNum != value) {
      _sortNum = value;
      notifyListeners();
    }
  }

  Mode get mode => _mode;

  set mode(Mode value) {
    if (_mode != value) {
      _mode = value;
      notifyListeners();
    }
  }

  String? get currentProxyName {
    if (mode == Mode.direct) return UsedProxy.DIRECT.name;
    if (_currentProxyName != null) return _currentProxyName!;
    return currentGroup?.now;
  }

  set currentProxyName(String? value) {
    if (_currentProxyName != value) {
      _currentProxyName = value;
      notifyListeners();
    }
  }

  Group? get currentGroup {
    switch (mode) {
      case Mode.direct:
        return null;
      case Mode.global:
        return globalGroup;
      case Mode.rule:
        return ruleGroup;
    }
  }

  Group? get globalGroup {
    final index =
        groups.indexWhere((element) => element.name == GroupName.GLOBAL.name);
    return index != -1 ? groups[index] : null;
  }

  Group? get ruleGroup {
    final index =
        groups.indexWhere((element) => element.name == GroupName.Proxy.name);
    return index != -1 ? groups[index] : null;
  }
}

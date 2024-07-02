import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'connection.dart';
import 'ffi.dart';
import 'log.dart';
import 'navigation.dart';
import 'profile.dart';
import 'proxy.dart';
import 'system_color_scheme.dart';
import 'traffic.dart';
import 'version.dart';

typedef DelayMap = Map<String, int?>;

class AppState with ChangeNotifier {
  List<NavigationItem> _navigationItems;
  int? _runTime;
  bool _isInit;
  VersionInfo? _versionInfo;
  List<Traffic> _traffics;
  Traffic _totalTraffic;
  List<Log> _logs;
  String _currentLabel;
  SystemColorSchemes _systemColorSchemes;
  num _sortNum;
  Mode _mode;
  DelayMap _delayMap;
  SelectedMap _selectedMap;
  bool _isCompatible;
  List<Group> _groups;
  double _viewWidth;
  List<Connection> _requests;
  num _checkIpNum;

  AppState({
    required Mode mode,
    required bool isCompatible,
    required SelectedMap selectedMap,
  })  : _navigationItems = [],
        _isInit = false,
        _currentLabel = "dashboard",
        _traffics = [],
        _logs = [],
        _viewWidth = 0,
        _selectedMap = selectedMap,
        _sortNum = 0,
        _checkIpNum = 0,
        _requests = [],
        _mode = mode,
        _totalTraffic = Traffic(),
        _delayMap = {},
        _groups = [],
        _isCompatible = isCompatible,
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

  List<NavigationItem> get currentNavigationItems {
    NavigationItemMode navigationItemMode;
    if (_viewWidth <= maxMobileWidth) {
      navigationItemMode = NavigationItemMode.mobile;
    } else {
      navigationItemMode = NavigationItemMode.desktop;
    }
    return navigationItems
        .where(
          (element) => element.modes.contains(navigationItemMode),
        )
        .toList();
  }

  bool get isInit => _isInit;

  set isInit(bool value) {
    if (_isInit != value) {
      _isInit = value;
      notifyListeners();
    }
  }

  bool get isStart => _runTime != null;

  int? get runTime => _runTime;

  set runTime(int? value) {
    if (_runTime != value) {
      _runTime = value;
      notifyListeners();
    }
  }

  String getDesc(String type, String? proxyName) {
    final groupTypeNamesList = GroupType.values.map((e) => e.name).toList();
    if (!groupTypeNamesList.contains(type)) {
      return type;
    } else {
      final index = groups.indexWhere((element) => element.name == proxyName);
      if (index == -1) return type;
      return "$type(${groups[index].now ?? '*'})";
    }
  }

  String? getRealProxyName(String? proxyName) {
    if (proxyName == null) return null;
    final index = groups.indexWhere((element) => element.name == proxyName);
    if (index == -1) return proxyName;
    final group = groups[index];
    return getRealProxyName((selectedMap.containsKey(proxyName)
            ? selectedMap[proxyName]
            : group.now)) ??
        proxyName;
  }

  String? get showProxyName {
    if (currentGroups.isEmpty) {
      return UsedProxy.DIRECT.name;
    }
    final firstGroup = currentGroups.first;
    final firstGroupName = firstGroup.name;
    return selectedMap[firstGroupName] ?? firstGroup.now;
  }

  int? getDelay(String? proxyName) {
    return _delayMap[getRealProxyName(proxyName)];
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

  addTraffic(Traffic traffic) {
    _traffics = List.from(_traffics)..add(traffic);
    const maxLength = 60;
    if (_traffics.length > maxLength) {
      _traffics = _traffics.sublist(_traffics.length - maxLength);
    }
    notifyListeners();
  }

  Traffic get totalTraffic => _totalTraffic;

  set totalTraffic(Traffic value) {
    if (_totalTraffic != value) {
      _totalTraffic = value;
      notifyListeners();
    }
  }

  List<Connection> get requests => _requests;

  set requests(List<Connection> value) {
    if (_requests != value) {
      _requests = value;
      notifyListeners();
    }
  }

  addRequest(Connection value) {
    _requests = List.from(_requests)..add(value);
    final maxLength = Platform.isAndroid ? 1000 : 60;
    if (_requests.length > maxLength) {
      _requests = _requests.sublist(_requests.length - maxLength);
    }
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
    _logs = List.from(_logs)..add(log);
    final maxLength = Platform.isAndroid ? 1000 : 60;
    if (_logs.length > maxLength) {
      _logs = _logs.sublist(_logs.length - maxLength);
    }
    notifyListeners();
  }

  SystemColorSchemes get systemColorSchemes => _systemColorSchemes;

  set systemColorSchemes(SystemColorSchemes value) {
    if (_systemColorSchemes != value) {
      _systemColorSchemes = value;
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

  num get checkIpNum => _checkIpNum;

  set checkIpNum(num value) {
    if (_checkIpNum != value) {
      _checkIpNum = value;
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

  bool get isCompatible {
    return _isCompatible;
  }

  set isCompatible(bool value) {
    if (_isCompatible != value) {
      _isCompatible = value;
      notifyListeners();
    }
  }

  SelectedMap get selectedMap {
    return _selectedMap;
  }

  set selectedMap(SelectedMap value) {
    if (!const MapEquality<String, String>().equals(_selectedMap, value)) {
      _selectedMap = value;
      notifyListeners();
    }
  }

  List<Group> get currentGroups {
    switch (mode) {
      case Mode.direct:
        return [];
      case Mode.global:
        return groups
            .where((element) => element.name == GroupName.GLOBAL.name)
            .toList();
      case Mode.rule:
        return groups
            .where((element) => element.name != GroupName.GLOBAL.name)
            .toList();
    }
  }

  double get viewWidth => _viewWidth;

  set viewWidth(double value) {
    if (_viewWidth != value) {
      _viewWidth = value;
      notifyListeners();
    }
  }

  ViewMode get viewMode => other.getViewMode(_viewWidth);

  DelayMap get delayMap {
    return _delayMap;
  }

  set delayMap(DelayMap value) {
    if (!const MapEquality<String, int?>().equals(_delayMap, value)) {
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

  Group? getGroupWithName(String groupName) {
    final index =
        currentGroups.indexWhere((element) => element.name == groupName);
    return index != -1 ? currentGroups[index] : null;
  }
}

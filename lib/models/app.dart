import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'core.dart';
import 'profile.dart';

typedef DelayMap = Map<String, Map<String, int?>>;

class AppState with ChangeNotifier {
  List<NavigationItem> _navigationItems;
  bool _isInit;
  VersionInfo? _versionInfo;
  String _currentLabel;
  SystemColorSchemes _systemColorSchemes;
  num _sortNum;
  Mode _mode;
  DelayMap _delayMap;
  SelectedMap _selectedMap;
  List<Group> _groups;
  double _viewWidth;
  final FixedList<Connection> _requests;
  num _checkIpNum;
  List<ExternalProvider> _providers;
  List<Package> _packages;
  Brightness? _brightness;
  int _version;

  AppState({
    required Mode mode,
    required SelectedMap selectedMap,
    required int version,
  })
      : _navigationItems = [],
        _isInit = false,
        _currentLabel = "dashboard",
        _viewWidth = other
            .getScreenSize()
            .width,
        _selectedMap = selectedMap,
        _sortNum = 0,
        _checkIpNum = 0,
        _requests = FixedList(1000),
        _mode = mode,
        _brightness = null,
        _delayMap = {},
        _groups = [],
        _providers = [],
        _packages = [],
        _systemColorSchemes = const SystemColorSchemes(),
        _version = version;

  String get currentLabel => _currentLabel;

  set currentLabel(String value) {
    if (_currentLabel != value) {
      _currentLabel = value;
      notifyListeners();
    }
  }

  List<NavigationItem> get navigationItems => _navigationItems;

  set navigationItems(List<NavigationItem> value) {
    if (!navigationItemListEquality.equals(_navigationItems, value)) {
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

  String getDesc(String type, String proxyName) {
    final groupTypeNamesList = GroupType.values.map((e) => e.name).toList();
    if (!groupTypeNamesList.contains(type)) {
      return type;
    } else {
      final index = groups.indexWhere((element) => element.name == proxyName);
      if (index == -1) return type;
      return "$type(${groups[index].now ?? '*'})";
    }
  }

  String getRealProxyName(String proxyName) {
    if (proxyName.isEmpty) return proxyName;
    final index = groups.indexWhere((element) => element.name == proxyName);
    if (index == -1) return proxyName;
    final group = groups[index];
    final currentSelectedName =
    group.getCurrentSelectedName(selectedMap[proxyName] ?? '');
    if (currentSelectedName.isEmpty) return proxyName;
    return getRealProxyName(
      currentSelectedName,
    );
  }

  String? get showProxyName {
    if (currentGroups.isEmpty) {
      return UsedProxy.DIRECT.name;
    }
    final firstGroup = currentGroups.first;
    final firstGroupName = firstGroup.name;
    return selectedMap[firstGroupName] ?? firstGroup.now;
  }

  VersionInfo? get versionInfo => _versionInfo;

  set versionInfo(VersionInfo? value) {
    if (_versionInfo != value) {
      _versionInfo = value;
      notifyListeners();
    }
  }

  List<Connection> get requests => _requests.list;

  addRequest(Connection value) {
    _requests.add(value);
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
    if (!groupListEquality.equals(_groups, value)) {
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

  SelectedMap get selectedMap {
    return _selectedMap;
  }

  set selectedMap(SelectedMap value) {
    if (!stringAndStringMapEquality.equals(_selectedMap, value)) {
      _selectedMap = value;
      notifyListeners();
    }
  }

  List<Group> get currentGroups {
    switch (mode) {
      case Mode.direct:
        return [];
      case Mode.global:
        return groups.toList();
      case Mode.rule:
        return groups
            .where((item) => item.hidden == false)
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
    if (_delayMap != value) {
      _delayMap = value;
      notifyListeners();
    }
  }

  setDelay(Delay delay) {
    if (_delayMap[delay.url]?[delay.name] != delay.value) {
      final DelayMap newDelayMap = Map.from(_delayMap);
      if (newDelayMap[delay.url] == null) {
        newDelayMap[delay.url] = {};
      }
      newDelayMap[delay.url]![delay.name] = delay.value;
      _delayMap = newDelayMap;
      notifyListeners();
    }
  }

  List<Package> get packages => _packages;

  set packages(List<Package> value) {
    if (!packageListEquality.equals(_packages, value)) {
      _packages = value;
      notifyListeners();
    }
  }

  List<ExternalProvider> get providers => _providers;

  set providers(List<ExternalProvider> value) {
    if (!externalProviderListEquality.equals(_providers, value)) {
      _providers = value;
      notifyListeners();
    }
  }

  setProvider(ExternalProvider? provider) {
    if (provider == null) return;
    final index = _providers.indexWhere((item) => item.name == provider.name);
    if (index == -1) return;
    _providers = List.from(_providers)
      ..[index] = provider;
    notifyListeners();
  }

  Group? getGroupWithName(String groupName) {
    final index =
    currentGroups.indexWhere((element) => element.name == groupName);
    return index != -1 ? currentGroups[index] : null;
  }

  Brightness? get brightness => _brightness;

  set brightness(Brightness? value) {
    if (_brightness != value) {
      _brightness = value;
      notifyListeners();
    }
  }

  int get version => _version;

  set version(int value) {
    if (_version != value) {
      _version = value;
      notifyListeners();
    }
  }
}

class AppFlowingState with ChangeNotifier {
  int? _runTime;
  final FixedList<Log> _logs;
  List<Traffic> _traffics;
  Traffic _totalTraffic;
  String? _localIp;

  AppFlowingState()
      : _logs = FixedList(1000),
        _traffics = [],
        _totalTraffic = Traffic();

  bool get isStart => _runTime != null;

  int? get runTime => _runTime;

  set runTime(int? value) {
    if (_runTime != value) {
      _runTime = value;
      notifyListeners();
    }
  }

  List<Log> get logs => _logs.list;

  addLog(Log log) {
    _logs.add(log);
    notifyListeners();
  }

  List<Traffic> get traffics => _traffics;

  set traffics(List<Traffic> value) {
    if (_traffics != value) {
      _traffics = value;
      notifyListeners();
    }
  }

  addTraffic(Traffic traffic) {
    _traffics = List.from(_traffics)
      ..add(traffic);
    const maxLength = 30;
    _traffics = _traffics.safeSublist(_traffics.length - maxLength);
    notifyListeners();
  }

  Traffic get totalTraffic => _totalTraffic;

  set totalTraffic(Traffic value) {
    if (_totalTraffic != value) {
      _totalTraffic = value;
      notifyListeners();
    }
  }

  String? get localIp => _localIp;

  set localIp(String? value) {
    if (_localIp != value) {
      _localIp = value;
      notifyListeners();
    }
  }
}

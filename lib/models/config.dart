import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/enum.dart';
import '../common/common.dart';
import 'models.dart';

part 'generated/config.g.dart';

part 'generated/config.freezed.dart';

@freezed
class AccessControl with _$AccessControl {
  const factory AccessControl({
    @Default(AccessControlMode.rejectSelected) AccessControlMode mode,
    @Default([]) List<String> acceptList,
    @Default([]) List<String> rejectList,
    @Default(AccessSortType.none) AccessSortType sort,
    @Default(true) bool isFilterSystemApp,
  }) = _AccessControl;

  factory AccessControl.fromJson(Map<String, Object?> json) =>
      _$AccessControlFromJson(json);
}

extension AccessControlExt on AccessControl {
  List<String> get currentList => switch (mode) {
        AccessControlMode.acceptSelected => acceptList,
        AccessControlMode.rejectSelected => rejectList,
      };
}

@freezed
class CoreState with _$CoreState {
  const factory CoreState({
    AccessControl? accessControl,
    required String currentProfileName,
    required bool enable,
    required bool allowBypass,
    required bool systemProxy,
    required int mixedPort,
    required bool onlyProxy,
  }) = _CoreState;

  factory CoreState.fromJson(Map<String, Object?> json) =>
      _$CoreStateFromJson(json);
}

@freezed
class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(1000) double width,
    @Default(600) double height,
    double? top,
    double? left,
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

@freezed
class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable,
    @Default(false) bool systemProxy,
    @Default(true) bool allowBypass,
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const VpnProps() : _$VpnPropsFromJson(json);
}

@freezed
class DesktopProps with _$DesktopProps {
  const factory DesktopProps({
    @Default(true) bool systemProxy,
  }) = _DesktopProps;

  factory DesktopProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const DesktopProps() : _$DesktopPropsFromJson(json);
}

@JsonSerializable()
class Config extends ChangeNotifier {
  List<Profile> _profiles;
  bool _isCompatible;
  String? _currentProfileId;
  bool _autoLaunch;
  bool _silentLaunch;
  bool _autoRun;
  bool _openLog;
  ThemeMode _themeMode;
  String? _locale;
  int? _primaryColor;
  ProxiesSortType _proxiesSortType;
  bool _isMinimizeOnExit;
  bool _isAccessControl;
  AccessControl _accessControl;
  bool _isAnimateToPage;
  bool _autoCheckUpdate;
  bool _isExclude;
  DAV? _dav;
  bool _isCloseConnections;
  ProxiesType _proxiesType;
  ProxyCardType _proxyCardType;
  ProxiesLayout _proxiesLayout;
  String _testUrl;
  WindowProps _windowProps;
  bool _onlyProxy;
  bool _prueBlack;
  VpnProps _vpnProps;
  DesktopProps _desktopProps;
  bool _showLabel;

  Config()
      : _profiles = [],
        _autoLaunch = false,
        _silentLaunch = false,
        _autoRun = false,
        _isCloseConnections = false,
        _themeMode = ThemeMode.system,
        _openLog = false,
        _isCompatible = true,
        _primaryColor = defaultPrimaryColor.value,
        _proxiesSortType = ProxiesSortType.none,
        _isMinimizeOnExit = true,
        _isAccessControl = false,
        _autoCheckUpdate = true,
        _testUrl = defaultTestUrl,
        _accessControl = const AccessControl(),
        _isAnimateToPage = true,
        _isExclude = false,
        _proxyCardType = ProxyCardType.expand,
        _windowProps = const WindowProps(),
        _proxiesType = ProxiesType.tab,
        _prueBlack = false,
        _onlyProxy = false,
        _proxiesLayout = ProxiesLayout.standard,
        _vpnProps = const VpnProps(),
        _desktopProps = const DesktopProps(),
        _showLabel = false;

  deleteProfileById(String id) {
    _profiles = profiles.where((element) => element.id != id).toList();
    notifyListeners();
  }

  Profile? getCurrentProfileForId(String? value) {
    if (value == null) {
      return null;
    }
    return _profiles.firstWhere((element) => element.id == value);
  }

  Profile? getCurrentProfile() {
    return getCurrentProfileForId(_currentProfileId);
  }

  String? _getLabel(String? label, String id) {
    final realLabel = label ?? id;
    final hasDup = _profiles.indexWhere(
            (element) => element.label == realLabel && element.id != id) !=
        -1;
    if (hasDup) {
      return _getLabel(other.getOverwriteLabel(realLabel), id);
    } else {
      return label;
    }
  }

  _setProfile(Profile profile) {
    final List<Profile> profilesTemp = List.from(_profiles);
    final index =
        profilesTemp.indexWhere((element) => element.id == profile.id);
    final updateProfile = profile.copyWith(
      label: _getLabel(profile.label, profile.id),
    );
    if (index == -1) {
      profilesTemp.add(updateProfile);
    } else {
      profilesTemp[index] = updateProfile;
    }
    _profiles = profilesTemp;
  }

  setProfile(Profile profile) {
    _setProfile(profile);
    notifyListeners();
  }

  @JsonKey(defaultValue: [])
  List<Profile> get profiles => _profiles;

  set profiles(List<Profile> value) {
    if (_profiles != value) {
      _profiles = value;
      notifyListeners();
    }
  }

  String? get currentProfileId => _currentProfileId;

  set currentProfileId(String? value) {
    if (_currentProfileId != value) {
      _currentProfileId = value;
      notifyListeners();
    }
  }

  Profile? get currentProfile {
    final index =
        profiles.indexWhere((profile) => profile.id == _currentProfileId);
    return index == -1 ? null : profiles[index];
  }

  String? get currentGroupName => currentProfile?.currentGroupName;

  Set<String> get currentUnfoldSet => currentProfile?.unfoldSet ?? {};

  updateCurrentUnfoldSet(Set<String> value) {
    if (!const SetEquality<String>().equals(currentUnfoldSet, value)) {
      _setProfile(
        currentProfile!.copyWith(
          unfoldSet: value,
        ),
      );
      notifyListeners();
    }
  }

  updateCurrentGroupName(String groupName) {
    if (currentProfile != null &&
        currentProfile!.currentGroupName != groupName) {
      _setProfile(
        currentProfile!.copyWith(
          currentGroupName: groupName,
        ),
      );
      notifyListeners();
    }
  }

  SelectedMap get currentSelectedMap {
    return currentProfile?.selectedMap ?? {};
  }

  updateCurrentSelectedMap(String groupName, String proxyName) {
    if (currentProfile != null &&
        currentProfile!.selectedMap[groupName] != proxyName) {
      final SelectedMap selectedMap = Map.from(
        currentProfile?.selectedMap ?? {},
      )..[groupName] = proxyName;
      _setProfile(
        currentProfile!.copyWith(
          selectedMap: selectedMap,
        ),
      );
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get autoLaunch {
    if (!system.isDesktop) return false;
    return _autoLaunch;
  }

  set autoLaunch(bool value) {
    if (_autoLaunch != value) {
      _autoLaunch = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get silentLaunch => _silentLaunch;

  set silentLaunch(bool value) {
    if (_silentLaunch != value) {
      _silentLaunch = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get autoRun => _autoRun;

  set autoRun(bool value) {
    if (_autoRun != value) {
      _autoRun = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: ThemeMode.system)
  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) {
    if (_themeMode != value) {
      _themeMode = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get openLogs => _openLog;

  set openLogs(bool value) {
    if (_openLog != value) {
      _openLog = value;
      notifyListeners();
    }
  }

  String? get locale => _locale;

  set locale(String? value) {
    if (_locale != value) {
      _locale = value;
      notifyListeners();
    }
  }

  int? get primaryColor => _primaryColor;

  set primaryColor(int? value) {
    if (_primaryColor != value) {
      _primaryColor = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: ProxiesSortType.none)
  ProxiesSortType get proxiesSortType => _proxiesSortType;

  set proxiesSortType(ProxiesSortType value) {
    if (_proxiesSortType != value) {
      _proxiesSortType = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: ProxiesLayout.standard)
  ProxiesLayout get proxiesLayout => _proxiesLayout;

  set proxiesLayout(ProxiesLayout value) {
    if (_proxiesLayout != value) {
      _proxiesLayout = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: true)
  bool get isMinimizeOnExit => _isMinimizeOnExit;

  set isMinimizeOnExit(bool value) {
    if (_isMinimizeOnExit != value) {
      _isMinimizeOnExit = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get isAccessControl {
    if (!Platform.isAndroid) return false;
    return _isAccessControl;
  }

  set isAccessControl(bool value) {
    if (_isAccessControl != value) {
      _isAccessControl = value;
      notifyListeners();
    }
  }

  AccessControl get accessControl => _accessControl;

  set accessControl(AccessControl value) {
    if (_accessControl != value) {
      _accessControl = value;
      notifyListeners();
    }
  }

  DAV? get dav => _dav;

  set dav(DAV? value) {
    if (_dav != value) {
      _dav = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: true)
  bool get isAnimateToPage {
    if (!Platform.isAndroid) return false;
    return _isAnimateToPage;
  }

  set isAnimateToPage(bool value) {
    if (_isAnimateToPage != value) {
      _isAnimateToPage = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: true)
  bool get isCompatible {
    return _isCompatible;
  }

  set isCompatible(bool value) {
    if (_isCompatible != value) {
      _isCompatible = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: true)
  bool get autoCheckUpdate {
    return _autoCheckUpdate;
  }

  set autoCheckUpdate(bool value) {
    if (_autoCheckUpdate != value) {
      _autoCheckUpdate = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get onlyProxy {
    return _onlyProxy;
  }

  set onlyProxy(bool value) {
    if (_onlyProxy != value) {
      _onlyProxy = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get prueBlack {
    return _prueBlack;
  }

  set prueBlack(bool value) {
    if (_prueBlack != value) {
      _prueBlack = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get isCloseConnections {
    return _isCloseConnections;
  }

  set isCloseConnections(bool value) {
    if (_isCloseConnections != value) {
      _isCloseConnections = value;
      notifyListeners();
    }
  }

  @JsonKey(
    defaultValue: ProxiesType.tab,
    unknownEnumValue: ProxiesType.tab,
  )
  ProxiesType get proxiesType => _proxiesType;

  set proxiesType(ProxiesType value) {
    if (_proxiesType != value) {
      _proxiesType = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: ProxyCardType.expand)
  ProxyCardType get proxyCardType => _proxyCardType;

  set proxyCardType(ProxyCardType value) {
    if (_proxyCardType != value) {
      _proxyCardType = value;
      notifyListeners();
    }
  }

  @JsonKey(name: "test-url", defaultValue: defaultTestUrl)
  String get testUrl => _testUrl;

  set testUrl(String value) {
    if (_testUrl != value) {
      _testUrl = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get isExclude => _isExclude;

  set isExclude(bool value) {
    if (_isExclude != value) {
      _isExclude = value;
      notifyListeners();
    }
  }

  WindowProps get windowProps => _windowProps;

  set windowProps(WindowProps value) {
    if (_windowProps != value) {
      _windowProps = value;
      notifyListeners();
    }
  }

  VpnProps get vpnProps => _vpnProps;

  set vpnProps(VpnProps value) {
    if (_vpnProps != value) {
      _vpnProps = value;
      notifyListeners();
    }
  }

  DesktopProps get desktopProps => _desktopProps;

  set desktopProps(DesktopProps value) {
    if (_desktopProps != value) {
      _desktopProps = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get showLabel => _showLabel;

  set showLabel(bool value) {
    if (_showLabel != value) {
      _showLabel = value;
      notifyListeners();
    }
  }

  update([
    Config? config,
    RecoveryOption recoveryOptions = RecoveryOption.all,
  ]) {
    if (config != null) {
      _profiles = config._profiles;
      for (final profile in config._profiles) {
        _setProfile(profile);
      }
      final onlyProfiles = recoveryOptions == RecoveryOption.onlyProfiles;
      if (_currentProfileId == null && onlyProfiles && profiles.isNotEmpty) {
        _currentProfileId = _profiles.first.id;
      }
      if (onlyProfiles) return;
      _currentProfileId = config._currentProfileId;
      _isCloseConnections = config._isCloseConnections;
      _isCompatible = config._isCompatible;
      _autoLaunch = config._autoLaunch;
      _silentLaunch = config._silentLaunch;
      _autoRun = config._autoRun;
      _proxiesType = config._proxiesType;
      _openLog = config._openLog;
      _themeMode = config._themeMode;
      _locale = config._locale;
      _primaryColor = config._primaryColor;
      _proxiesSortType = config._proxiesSortType;
      _isMinimizeOnExit = config._isMinimizeOnExit;
      _isAccessControl = config._isAccessControl;
      _accessControl = config._accessControl;
      _isAnimateToPage = config._isAnimateToPage;
      _autoCheckUpdate = config._autoCheckUpdate;
      _prueBlack = config._prueBlack;
      _testUrl = config._testUrl;
      _isExclude = config._isExclude;
      _windowProps = config._windowProps;
      _vpnProps = config._vpnProps;
      _desktopProps = config._desktopProps;
    }
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return _$ConfigToJson(this);
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return _$ConfigFromJson(json);
  }
}

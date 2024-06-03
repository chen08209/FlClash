import 'dart:io';

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
    @Default(true) bool isFilterSystemApp,
  }) = _AccessControl;

  factory AccessControl.fromJson(Map<String, Object?> json) =>
      _$AccessControlFromJson(json);
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
  DAV? _dav;

  Config()
      : _profiles = [],
        _autoLaunch = false,
        _silentLaunch = false,
        _autoRun = false,
        _themeMode = ThemeMode.system,
        _openLog = false,
        _isCompatible = false,
        _primaryColor = defaultPrimaryColor.value,
        _proxiesSortType = ProxiesSortType.none,
        _isMinimizeOnExit = true,
        _isAccessControl = false,
        _autoCheckUpdate = true,
        _accessControl = const AccessControl(),
        _isAnimateToPage = true;

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
    try {
      return profiles.firstWhere((element) => element.id == _currentProfileId);
    } catch (_) {
      return null;
    }
  }

  SelectedMap get currentSelectedMap {
    return currentProfile?.selectedMap ?? {};
  }

  updateCurrentSelectedMap(String groupName, String proxyName) {
    if (currentProfile?.selectedMap[groupName] != proxyName) {
      currentProfile?.selectedMap = Map.from(currentProfile?.selectedMap ?? {})
        ..[groupName] = proxyName;
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

  @JsonKey(defaultValue: false)
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

  update(
      [Config? config, RecoveryOption recoveryOptions = RecoveryOption.all]) {
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
      _isCompatible = config._isCompatible;
      _autoLaunch = config._autoLaunch;
      _silentLaunch = config._silentLaunch;
      _autoRun = config._autoRun;
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
      _dav = config._dav;
    }
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return _$ConfigToJson(this);
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return _$ConfigFromJson(json);
  }

  @override
  String toString() {
    return 'Config{_profiles: $_profiles, _isCompatible: $_isCompatible, _currentProfileId: $_currentProfileId, _autoLaunch: $_autoLaunch, _silentLaunch: $_silentLaunch, _autoRun: $_autoRun, _openLog: $_openLog, _themeMode: $_themeMode, _locale: $_locale, _primaryColor: $_primaryColor, _proxiesSortType: $_proxiesSortType, _isMinimizeOnExit: $_isMinimizeOnExit, _isAccessControl: $_isAccessControl, _accessControl: $_accessControl, _isAnimateToPage: $_isAnimateToPage, _dav: $_dav}';
  }
}

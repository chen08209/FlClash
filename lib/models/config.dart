import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../enum/enum.dart';
import '../common/common.dart';
import 'models.dart';

part 'generated/config.g.dart';

@JsonSerializable()
class AccessControl {
  AccessControlMode mode;
  List<String> acceptList;
  List<String> rejectList;
  bool isFilterSystemApp;

  AccessControl({
    this.isFilterSystemApp = true,
    this.mode = AccessControlMode.rejectSelected,
    this.acceptList = const [],
    this.rejectList = const [],
  });

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> get currentList =>
      mode == AccessControlMode.acceptSelected ? acceptList : rejectList;

  set currentList(List<String> currentList) {
    if (mode == AccessControlMode.acceptSelected) {
      acceptList = currentList;
    } else {
      rejectList = currentList;
    }
  }

  AccessControl copyWith({
    AccessControlMode? mode,
    List<String>? acceptList,
    List<String>? rejectList,
    bool? isFilterSystemApp,
  }) {
    return AccessControl(
      mode: mode ?? this.mode,
      acceptList: acceptList ?? this.acceptList,
      rejectList: rejectList ?? this.rejectList,
      isFilterSystemApp: isFilterSystemApp ?? this.isFilterSystemApp,
    );
  }

  Map<String, dynamic> toJson() {
    return _$AccessControlToJson(this);
  }

  factory AccessControl.fromJson(Map<String, dynamic> json) {
    return _$AccessControlFromJson(json);
  }
}

@JsonSerializable()
class Config extends ChangeNotifier {
  List<Profile> _profiles;
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

  Config()
      : _profiles = [],
        _autoLaunch = false,
        _silentLaunch = false,
        _autoRun = false,
        _themeMode = ThemeMode.system,
        _openLog = false,
        _primaryColor = appConstant.defaultPrimaryColor.value,
        _proxiesSortType = ProxiesSortType.none,
        _isMinimizeOnExit = true,
        _isAccessControl = false,
        _accessControl = AccessControl(),
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
    final hasDup = _profiles.indexWhere(
            (element) => element.label == label && element.id != id) !=
        -1;
    if (hasDup) {
      return _getLabel(Other.getOverwriteLabel(label!), id);
    } else {
      return label;
    }
  }

  setProfile(Profile profile) {
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

  String? get currentProxyName => currentProfile?.proxyName;

  String? get currentGroupName => currentProfile?.groupName;

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

  set accessControl(AccessControl? value) {
    if (_accessControl != value) {
      _accessControl = value ?? AccessControl();
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

  update() {
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return _$ConfigToJson(this);
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    return _$ConfigFromJson(json);
  }
}

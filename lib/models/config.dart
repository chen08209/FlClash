import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'models.dart';

part 'generated/config.freezed.dart';
part 'generated/config.g.dart';

final defaultAppSetting = const AppSetting().copyWith(
  isAnimateToPage: system.isDesktop ? false : true,
);

@freezed
class AppSetting with _$AppSetting {
  const factory AppSetting({
    String? locale,
    @Default(false) bool onlyProxy,
    @Default(false) bool autoLaunch,
    @Default(false) bool adminAutoLaunch,
    @Default(false) bool silentLaunch,
    @Default(false) bool autoRun,
    @Default(false) bool openLogs,
    @Default(true) bool closeConnections,
    @Default(defaultTestUrl) String testUrl,
    @Default(true) bool isAnimateToPage,
    @Default(true) bool autoCheckUpdate,
    @Default(false) bool showLabel,
    @Default(false) bool disclaimerAccepted,
    @Default(true) bool minimizeOnExit,
    @Default(false) bool hidden,
  }) = _AppSetting;

  factory AppSetting.fromJson(Map<String, Object?> json) =>
      _$AppSettingFromJson(json);

  factory AppSetting.realFromJson(Map<String, Object?>? json) {
    final appSetting =
        json == null ? defaultAppSetting : AppSetting.fromJson(json);
    return appSetting.copyWith(
      isAnimateToPage: system.isDesktop ? false : appSetting.isAnimateToPage,
    );
  }
}

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
class WindowProps with _$WindowProps {
  const factory WindowProps({
    @Default(900) double width,
    @Default(600) double height,
    double? top,
    double? left,
  }) = _WindowProps;

  factory WindowProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const WindowProps() : _$WindowPropsFromJson(json);
}

const defaultBypassDomain = [
  "*zhihu.com",
  "*zhimg.com",
  "*jd.com",
  "100ime-iat-api.xfyun.cn",
  "*360buyimg.com",
  "localhost",
  "*.local",
  "127.*",
  "10.*",
  "172.16.*",
  "172.17.*",
  "172.18.*",
  "172.19.*",
  "172.2*",
  "172.30.*",
  "172.31.*",
  "192.168.*"
];

const defaultVpnProps = VpnProps();

@freezed
class VpnProps with _$VpnProps {
  const factory VpnProps({
    @Default(true) bool enable,
    @Default(true) bool systemProxy,
    @Default(false) bool ipv6,
    @Default(true) bool allowBypass,
  }) = _VpnProps;

  factory VpnProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const VpnProps() : _$VpnPropsFromJson(json);
}

@freezed
class NetworkProps with _$NetworkProps {
  const factory NetworkProps({
    @Default(true) bool systemProxy,
    @Default(defaultBypassDomain) List<String> bypassDomain,
  }) = _NetworkProps;

  factory NetworkProps.fromJson(Map<String, Object?>? json) =>
      json == null ? const NetworkProps() : _$NetworkPropsFromJson(json);
}

const defaultProxiesStyle = ProxiesStyle();

@freezed
class ProxiesStyle with _$ProxiesStyle {
  const factory ProxiesStyle({
    @Default(ProxiesType.tab) ProxiesType type,
    @Default(ProxiesSortType.none) ProxiesSortType sortType,
    @Default(ProxiesLayout.standard) ProxiesLayout layout,
    @Default(ProxiesIconStyle.standard) ProxiesIconStyle iconStyle,
    @Default(ProxyCardType.expand) ProxyCardType cardType,
    @Default({}) Map<String, String> iconMap,
  }) = _ProxiesStyle;

  factory ProxiesStyle.fromJson(Map<String, Object?>? json) =>
      json == null ? defaultProxiesStyle : _$ProxiesStyleFromJson(json);
}

final defaultThemeProps = Platform.isWindows
    ? const ThemeProps().copyWith(
        fontFamily: FontFamily.miSans,
        primaryColor: defaultPrimaryColor.value,
      )
    : const ThemeProps().copyWith(
        primaryColor: defaultPrimaryColor.value,
      );

@freezed
class ThemeProps with _$ThemeProps {
  const factory ThemeProps({
    int? primaryColor,
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(false) bool prueBlack,
    @Default(FontFamily.system) FontFamily fontFamily,
  }) = _ThemeProps;

  factory ThemeProps.fromJson(Map<String, Object?> json) =>
      _$ThemePropsFromJson(json);

  factory ThemeProps.realFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultThemeProps;
    }
    try {
      return ThemeProps.fromJson(json);
    } catch (_) {
      return defaultThemeProps;
    }
  }
}

@JsonSerializable()
class Config extends ChangeNotifier {
  AppSetting _appSetting;
  List<Profile> _profiles;
  String? _currentProfileId;
  bool _isAccessControl;
  AccessControl _accessControl;
  DAV? _dav;
  WindowProps _windowProps;
  ThemeProps _themeProps;
  VpnProps _vpnProps;
  NetworkProps _networkProps;
  bool _overrideDns;
  List<HotKeyAction> _hotKeyActions;
  ProxiesStyle _proxiesStyle;

  Config()
      : _profiles = [],
        _isAccessControl = false,
        _accessControl = const AccessControl(),
        _windowProps = const WindowProps(),
        _vpnProps = defaultVpnProps,
        _networkProps = const NetworkProps(),
        _overrideDns = false,
        _appSetting = defaultAppSetting,
        _hotKeyActions = [],
        _proxiesStyle = defaultProxiesStyle,
        _themeProps = defaultThemeProps;

  @JsonKey(fromJson: AppSetting.realFromJson)
  AppSetting get appSetting => _appSetting;

  set appSetting(AppSetting value) {
    if (_appSetting != value) {
      _appSetting = value;
      notifyListeners();
    }
  }

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
    if (!stringSetEquality.equals(currentUnfoldSet, value)) {
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

  NetworkProps get networkProps => _networkProps;

  set networkProps(NetworkProps value) {
    if (_networkProps != value) {
      _networkProps = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: false)
  bool get overrideDns => _overrideDns;

  set overrideDns(bool value) {
    if (_overrideDns != value) {
      _overrideDns = value;
      notifyListeners();
    }
  }

  @JsonKey(defaultValue: [])
  List<HotKeyAction> get hotKeyActions => _hotKeyActions;

  set hotKeyActions(List<HotKeyAction> value) {
    if (_hotKeyActions != value) {
      _hotKeyActions = value;
      notifyListeners();
    }
  }

  ProxiesStyle get proxiesStyle => _proxiesStyle;

  set proxiesStyle(ProxiesStyle value) {
    if (_proxiesStyle != value ||
        !stringAndStringMapEntryIterableEquality.equals(
          _proxiesStyle.iconMap.entries,
          value.iconMap.entries,
        )) {
      _proxiesStyle = value;
      notifyListeners();
    }
  }

  @JsonKey(fromJson: ThemeProps.realFromJson)
  ThemeProps get themeProps => _themeProps;

  set themeProps(ThemeProps value) {
    if (_themeProps != value) {
      _themeProps = value;
      notifyListeners();
    }
  }

  updateOrAddHotKeyAction(HotKeyAction hotKeyAction) {
    final index =
        _hotKeyActions.indexWhere((item) => item.action == hotKeyAction.action);
    if (index == -1) {
      _hotKeyActions = List.from(_hotKeyActions)..add(hotKeyAction);
    } else {
      _hotKeyActions = List.from(_hotKeyActions)..[index] = hotKeyAction;
    }
    notifyListeners();
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
      _appSetting = config._appSetting;
      _currentProfileId = config._currentProfileId;
      _dav = config._dav;
      _isAccessControl = config._isAccessControl;
      _accessControl = config._accessControl;
      _themeProps = config._themeProps;
      _windowProps = config._windowProps;
      _proxiesStyle = config._proxiesStyle;
      _vpnProps = config._vpnProps;
      _overrideDns = config._overrideDns;
      _networkProps = config._networkProps;
      _hotKeyActions = config._hotKeyActions;
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
    return 'Config{_appSetting: $_appSetting, _profiles: $_profiles, _currentProfileId: $_currentProfileId, _isAccessControl: $_isAccessControl, _accessControl: $_accessControl, _dav: $_dav, _windowProps: $_windowProps, _themeProps: $_themeProps, _vpnProps: $_vpnProps, _networkProps: $_networkProps, _overrideDns: $_overrideDns, _hotKeyActions: $_hotKeyActions, _proxiesStyle: $_proxiesStyle}';
  }
}

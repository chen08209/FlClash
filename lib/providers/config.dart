import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/config.g.dart';

@riverpod
class AppSetting extends _$AppSetting with AutoDisposeNotifierMixin {
  @override
  AppSettingProps build() {
    return globalState.config.appSetting;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      appSetting: value,
    );
  }

  updateState(AppSettingProps Function(AppSettingProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class WindowSetting extends _$WindowSetting with AutoDisposeNotifierMixin {
  @override
  WindowProps build() {
    return globalState.config.windowProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      windowProps: value,
    );
  }

  updateState(WindowProps Function(WindowProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class VpnSetting extends _$VpnSetting with AutoDisposeNotifierMixin {
  @override
  VpnProps build() {
    return globalState.config.vpnProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      vpnProps: value,
    );
  }

  updateState(VpnProps Function(VpnProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class NetworkSetting extends _$NetworkSetting with AutoDisposeNotifierMixin {
  @override
  NetworkProps build() {
    return globalState.config.networkProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      networkProps: value,
    );
  }

  updateState(NetworkProps Function(NetworkProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class ThemeSetting extends _$ThemeSetting with AutoDisposeNotifierMixin {
  @override
  ThemeProps build() {
    return globalState.config.themeProps;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      themeProps: value,
    );
  }

  updateState(ThemeProps Function(ThemeProps state) builder) {
    state = builder(state);
  }
}

@riverpod
class Profiles extends _$Profiles with AutoDisposeNotifierMixin {
  @override
  List<Profile> build() {
    return globalState.config.profiles;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      profiles: value,
    );
  }

  String? _getLabel(String? label, String id) {
    final realLabel = label ?? id;
    final hasDup = state.indexWhere(
            (element) => element.label == realLabel && element.id != id) !=
        -1;
    if (hasDup) {
      return _getLabel(utils.getOverwriteLabel(realLabel), id);
    } else {
      return label;
    }
  }

  setProfile(Profile profile) {
    final List<Profile> profilesTemp = List.from(state);
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
    state = profilesTemp;
  }

  updateProfile(String profileId, Profile Function(Profile profile) builder) {
    final List<Profile> profilesTemp = List.from(state);
    final index = profilesTemp.indexWhere((element) => element.id == profileId);
    if (index != -1) {
      profilesTemp[index] = builder(profilesTemp[index]);
    }
    state = profilesTemp;
  }

  deleteProfileById(String id) {
    state = state.where((element) => element.id != id).toList();
  }
}

@riverpod
class CurrentProfileId extends _$CurrentProfileId
    with AutoDisposeNotifierMixin {
  @override
  String? build() {
    return globalState.config.currentProfileId;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      currentProfileId: value,
    );
  }
}

@riverpod
class AppDAVSetting extends _$AppDAVSetting with AutoDisposeNotifierMixin {
  @override
  DAV? build() {
    return globalState.config.dav;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      dav: value,
    );
  }

  updateState(DAV? Function(DAV? state) builder) {
    state = builder(state);
  }
}

@riverpod
class OverrideDns extends _$OverrideDns with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return globalState.config.overrideDns;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      overrideDns: value,
    );
  }
}

@riverpod
class HotKeyActions extends _$HotKeyActions with AutoDisposeNotifierMixin {
  @override
  List<HotKeyAction> build() {
    return globalState.config.hotKeyActions;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      hotKeyActions: value,
    );
  }
}

@riverpod
class ProxiesStyleSetting extends _$ProxiesStyleSetting
    with AutoDisposeNotifierMixin {
  @override
  ProxiesStyle build() {
    return globalState.config.proxiesStyle;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      proxiesStyle: value,
    );
  }

  updateState(ProxiesStyle Function(ProxiesStyle state) builder) {
    state = builder(state);
  }
}

@riverpod
class PatchClashConfig extends _$PatchClashConfig
    with AutoDisposeNotifierMixin {
  @override
  ClashConfig build() {
    return globalState.config.patchClashConfig;
  }

  updateState(ClashConfig? Function(ClashConfig state) builder) {
    final newState = builder(state);
    if (newState == null) {
      return;
    }
    state = newState;
  }

  @override
  onUpdate(value) {
    globalState.config = globalState.config.copyWith(
      patchClashConfig: value,
    );
  }
}

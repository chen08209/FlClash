import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/config.g.dart';

@riverpod
class Setting extends _$Setting {
  @override
  AppSetting build() {
    return AppSetting();
  }
}

@riverpod
class WindowSetting extends _$WindowSetting {
  @override
  WindowProps build() {
    return WindowProps();
  }
}

@riverpod
class VpnSetting extends _$VpnSetting {
  @override
  VpnProps build() {
    return VpnProps();
  }
}

@riverpod
class NetworkSetting extends _$NetworkSetting {
  @override
  NetworkProps build() {
    return NetworkProps();
  }
}

@riverpod
class ThemeSetting extends _$ThemeSetting {
  @override
  ThemeProps build() {
    return ThemeProps();
  }
}

@riverpod
class Profiles extends _$Profiles {
  @override
  List<Profile> build() {
    return [];
  }
}

@riverpod
class ProfileId extends _$ProfileId {
  @override
  String? build() {
    return null;
  }
}

@riverpod
class DAVSetting extends _$DAVSetting {
  @override
  DAV? build() {
    return null;
  }
}

@riverpod
class OverrideDns extends _$OverrideDns {
  @override
  bool build() {
    return false;
  }
}

@riverpod
class AccessControl extends _$AccessControl {
  @override
  bool build() {
    return false;
  }
}

@riverpod
class AccessControlSetting extends _$AccessControlSetting {
  @override
  AccessControl build() {
    return AccessControl();
  }
}

@riverpod
class HotKeyActions extends _$HotKeyActions {
  @override
  List<HotKeyAction> build() {
    return [];
  }
}

@riverpod
class ProxiesStyleSetting extends _$ProxiesStyleSetting {
  @override
  ProxiesStyle build() {
    return ProxiesStyle();
  }
}

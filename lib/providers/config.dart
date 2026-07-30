import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/config.g.dart';

@riverpod
class AppSetting extends _$AppSetting with AutoDisposeNotifierMixin {
  @override
  AppSettingProps build() {
    return const AppSettingProps();
  }
}

@Riverpod(keepAlive: true)
class WindowSetting extends _$WindowSetting with AutoDisposeNotifierMixin {
  @override
  WindowProps build() {
    return const WindowProps();
  }

  void hello() {}
}

@riverpod
class VpnSetting extends _$VpnSetting with AutoDisposeNotifierMixin {
  @override
  VpnProps build() {
    return const VpnProps();
  }
}

@riverpod
class NetworkSetting extends _$NetworkSetting with AutoDisposeNotifierMixin {
  @override
  NetworkProps build() {
    return const NetworkProps();
  }
}

@riverpod
class ThemeSetting extends _$ThemeSetting with AutoDisposeNotifierMixin {
  @override
  ThemeProps build() {
    return const ThemeProps();
  }
}

@riverpod
class CurrentProfileId extends _$CurrentProfileId
    with AutoDisposeNotifierMixin {
  @override
  int? build() {
    return null;
  }
}

@riverpod
class DavSetting extends _$DavSetting with AutoDisposeNotifierMixin {
  @override
  DAVProps? build() {
    return null;
  }
}

@riverpod
class OverrideDns extends _$OverrideDns with AutoDisposeNotifierMixin {
  @override
  bool build() {
    return false;
  }
}

@riverpod
class HotKeyActions extends _$HotKeyActions with AutoDisposeNotifierMixin {
  @override
  List<HotKeyAction> build() {
    return [];
  }
}

@riverpod
class ProxiesStyleSetting extends _$ProxiesStyleSetting
    with AutoDisposeNotifierMixin {
  @override
  ProxiesStyleProps build() {
    return const ProxiesStyleProps();
  }
}

@Riverpod(name: 'patchClashConfigProvider')
class _PatchClashConfig extends _$PatchClashConfig
    with AutoDisposeNotifierMixin {
  @override
  PatchClashConfig build() {
    return const PatchClashConfig();
  }
}

@riverpod
class ExcludeSSIDs extends _$ExcludeSSIDs with AutoDisposeNotifierMixin {
  @override
  List<String> build() {
    return [];
  }
}

@riverpod
class TailscaleSetting extends _$TailscaleSetting with AutoDisposeNotifierMixin {
  @override
  TailscaleProps build() {
    return const TailscaleProps();
  }

  void setEnable(bool enable) {
    update((state) => state.copyWith(enable: enable));
  }

  void setBypassTraffic(bool bypassTraffic) {
    update((state) => state.copyWith(bypassTraffic: bypassTraffic));
    // Keep Config → DNS → Fake IP Filter in sync with the toggle so the user
    // can see the entries appear/disappear, and so override-DNS mode also
    // picks them up without a separate hand edit.
    ref.read(patchClashConfigProvider.notifier).update((state) {
      final filters = List<String>.from(state.dns.fakeIpFilter);
      if (bypassTraffic) {
        for (final filter in tailscaleFakeIpFilters) {
          if (!filters.contains(filter)) {
            filters.add(filter);
          }
        }
      } else {
        filters.removeWhere(tailscaleFakeIpFilters.contains);
      }
      return state.copyWith.dns(fakeIpFilter: filters);
    });
  }

  void addOrUpdate(TailscaleProxy proxy, {String? previousName}) {
    update((state) {
      final next = List<TailscaleProxy>.from(state.proxies);
      final lookupName = previousName ?? proxy.name;
      final index = next.indexWhere((item) => item.name == lookupName);
      if (index == -1) {
        next.add(proxy);
      } else {
        next[index] = proxy;
      }
      return state.copyWith(proxies: next);
    });
  }

  void remove(String name) {
    update((state) {
      return state.copyWith(
        proxies: state.proxies.where((item) => item.name != name).toList(),
      );
    });
  }
}


@Riverpod(name: 'configProvider')
Config _config(Ref ref) {
  final appSettingProps = ref.watch(appSettingProvider);
  final windowProps = ref.watch(windowSettingProvider);
  final vpnProps = ref.watch(vpnSettingProvider);
  final networkProps = ref.watch(networkSettingProvider);
  final themeProps = ref.watch(themeSettingProvider);
  final currentProfileId = ref.watch(currentProfileIdProvider);
  final davProps = ref.watch(davSettingProvider);
  final overrideDns = ref.watch(overrideDnsProvider);
  final hotKeyActions = ref.watch(hotKeyActionsProvider);
  final proxiesStyleProps = ref.watch(proxiesStyleSettingProvider);
  final patchClashConfig = ref.watch(patchClashConfigProvider);
  final excludeSSIDs = ref.watch(excludeSSIDsProvider);
  final tailscaleProps = ref.watch(tailscaleSettingProvider);
  return Config(
    appSettingProps: appSettingProps,
    windowProps: windowProps,
    vpnProps: vpnProps,
    networkProps: networkProps,
    themeProps: themeProps,
    currentProfileId: currentProfileId,
    davProps: davProps,
    overrideDns: overrideDns,
    hotKeyActions: hotKeyActions,
    proxiesStyleProps: proxiesStyleProps,
    patchClashConfig: patchClashConfig,
    excludeSSIDs: excludeSSIDs,
    tailscaleProps: tailscaleProps,
  );
}

List<Override> buildConfigOverrides(Config config) {
  return [
    appSettingProvider.overrideWithBuild((_, _) => config.appSettingProps),
    windowSettingProvider.overrideWithBuild((_, _) => config.windowProps),
    vpnSettingProvider.overrideWithBuild((_, _) => config.vpnProps),
    networkSettingProvider.overrideWithBuild((_, _) => config.networkProps),
    themeSettingProvider.overrideWithBuild((_, _) => config.themeProps),
    currentProfileIdProvider.overrideWithBuild(
      (_, _) => config.currentProfileId,
    ),
    davSettingProvider.overrideWithBuild((_, _) => config.davProps),
    overrideDnsProvider.overrideWithBuild((_, _) => config.overrideDns),
    hotKeyActionsProvider.overrideWithBuild((_, _) => config.hotKeyActions),
    proxiesStyleSettingProvider.overrideWithBuild(
      (_, _) => config.proxiesStyleProps,
    ),
    patchClashConfigProvider.overrideWithBuild(
      (_, _) => config.patchClashConfig,
    ),
    excludeSSIDsProvider.overrideWithBuild((_, _) => config.excludeSSIDs),
    tailscaleSettingProvider.overrideWithBuild(
      (_, _) => config.tailscaleProps,
    ),
  ];
}

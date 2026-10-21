// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../on_demand.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ssidRequired)
final ssidRequiredProvider = SsidRequiredProvider._();

final class SsidRequiredProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  SsidRequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ssidRequiredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ssidRequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return ssidRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ssidRequiredHash() => r'a9648c0530f5826068a6400c2a5094160580503e';

@ProviderFor(LocationPermissions)
final locationPermissionsProvider = LocationPermissionsProvider._();

final class LocationPermissionsProvider
    extends $NotifierProvider<LocationPermissions, WifiSsidPermission> {
  LocationPermissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPermissionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPermissionsHash();

  @$internal
  @override
  LocationPermissions create() => LocationPermissions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WifiSsidPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WifiSsidPermission>(value),
    );
  }
}

String _$locationPermissionsHash() =>
    r'a9391c69b7fb34942dfab8f19eebaf538707ad49';

abstract class _$LocationPermissions extends $Notifier<WifiSsidPermission> {
  WifiSsidPermission build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WifiSsidPermission, WifiSsidPermission>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WifiSsidPermission, WifiSsidPermission>,
              WifiSsidPermission,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(BatteryOptimizationIgnored)
final batteryOptimizationIgnoredProvider =
    BatteryOptimizationIgnoredProvider._();

final class BatteryOptimizationIgnoredProvider
    extends $StreamNotifierProvider<BatteryOptimizationIgnored, bool> {
  BatteryOptimizationIgnoredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'batteryOptimizationIgnoredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$batteryOptimizationIgnoredHash();

  @$internal
  @override
  BatteryOptimizationIgnored create() => BatteryOptimizationIgnored();
}

String _$batteryOptimizationIgnoredHash() =>
    r'57dec1c4aa0a54c5af1a6934a3d4f78407df8013';

abstract class _$BatteryOptimizationIgnored extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

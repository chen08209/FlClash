// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateParams)
final updateParamsProvider = UpdateParamsProvider._();

final class UpdateParamsProvider
    extends $FunctionalProvider<UpdateParams, UpdateParams, UpdateParams>
    with $Provider<UpdateParams> {
  UpdateParamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateParamsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateParamsHash();

  @$internal
  @override
  $ProviderElement<UpdateParams> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateParams create(Ref ref) {
    return updateParams(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateParams value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateParams>(value),
    );
  }
}

String _$updateParamsHash() => r'7b4c3cb2b45e7cd33dd2c57dc65c5067011438ff';

@ProviderFor(setupPatch)
final setupPatchProvider = SetupPatchProvider._();

final class SetupPatchProvider
    extends
        $FunctionalProvider<
          ({bool appendSystemDns, PatchClashConfig patchConfig}),
          ({bool appendSystemDns, PatchClashConfig patchConfig}),
          ({bool appendSystemDns, PatchClashConfig patchConfig})
        >
    with $Provider<({bool appendSystemDns, PatchClashConfig patchConfig})> {
  SetupPatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupPatchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupPatchHash();

  @$internal
  @override
  $ProviderElement<({bool appendSystemDns, PatchClashConfig patchConfig})>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ({bool appendSystemDns, PatchClashConfig patchConfig}) create(Ref ref) {
    return setupPatch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({bool appendSystemDns, PatchClashConfig patchConfig}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            ({bool appendSystemDns, PatchClashConfig patchConfig})
          >(value),
    );
  }
}

String _$setupPatchHash() => r'64d8f97c3b7f367ab0065f9b1d606beb5e6b5ebf';

@ProviderFor(trayState)
final trayStateProvider = TrayStateProvider._();

final class TrayStateProvider
    extends $FunctionalProvider<TrayState, TrayState, TrayState>
    with $Provider<TrayState> {
  TrayStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayStateHash();

  @$internal
  @override
  $ProviderElement<TrayState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrayState create(Ref ref) {
    return trayState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrayState>(value),
    );
  }
}

String _$trayStateHash() => r'e3e841e2d6ae95e4eafe27996c7da33f82edcc80';

/// Measured delays of the proxies the tray lists, by group and then proxy
/// name. Resolved like a proxy card, so a nested group shows its selection.

@ProviderFor(trayDelays)
final trayDelaysProvider = TrayDelaysProvider._();

/// Measured delays of the proxies the tray lists, by group and then proxy
/// name. Resolved like a proxy card, so a nested group shows its selection.

final class TrayDelaysProvider
    extends
        $FunctionalProvider<
          Map<String, Map<String, int>>,
          Map<String, Map<String, int>>,
          Map<String, Map<String, int>>
        >
    with $Provider<Map<String, Map<String, int>>> {
  /// Measured delays of the proxies the tray lists, by group and then proxy
  /// name. Resolved like a proxy card, so a nested group shows its selection.
  TrayDelaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayDelaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayDelaysHash();

  @$internal
  @override
  $ProviderElement<Map<String, Map<String, int>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, Map<String, int>> create(Ref ref) {
    return trayDelays(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Map<String, int>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Map<String, int>>>(
        value,
      ),
    );
  }
}

String _$trayDelaysHash() => r'266ed418b13319a7fcc6a3d8307b6786f6ce89bf';

@ProviderFor(trayTitleState)
final trayTitleStateProvider = TrayTitleStateProvider._();

final class TrayTitleStateProvider
    extends $FunctionalProvider<TrayTitleState, TrayTitleState, TrayTitleState>
    with $Provider<TrayTitleState> {
  TrayTitleStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trayTitleStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trayTitleStateHash();

  @$internal
  @override
  $ProviderElement<TrayTitleState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TrayTitleState create(Ref ref) {
    return trayTitleState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrayTitleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrayTitleState>(value),
    );
  }
}

String _$trayTitleStateHash() => r'aacf3779c879f7f1144484a80043679020bf8424';

@ProviderFor(packageListSelectorState)
final packageListSelectorStateProvider = PackageListSelectorStateProvider._();

final class PackageListSelectorStateProvider
    extends
        $FunctionalProvider<
          PackageListSelectorState,
          PackageListSelectorState,
          PackageListSelectorState
        >
    with $Provider<PackageListSelectorState> {
  PackageListSelectorStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageListSelectorStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageListSelectorStateHash();

  @$internal
  @override
  $ProviderElement<PackageListSelectorState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PackageListSelectorState create(Ref ref) {
    return packageListSelectorState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PackageListSelectorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PackageListSelectorState>(value),
    );
  }
}

String _$packageListSelectorStateHash() =>
    r'1fa2bebbd8ee07910aa8d6e9c5d5d6128df5c13b';

@ProviderFor(getHotKeyAction)
final getHotKeyActionProvider = GetHotKeyActionFamily._();

final class GetHotKeyActionProvider
    extends $FunctionalProvider<HotKeyAction, HotKeyAction, HotKeyAction>
    with $Provider<HotKeyAction> {
  GetHotKeyActionProvider._({
    required GetHotKeyActionFamily super.from,
    required HotAction super.argument,
  }) : super(
         retry: null,
         name: r'getHotKeyActionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getHotKeyActionHash();

  @override
  String toString() {
    return r'getHotKeyActionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<HotKeyAction> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HotKeyAction create(Ref ref) {
    final argument = this.argument as HotAction;
    return getHotKeyAction(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HotKeyAction value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HotKeyAction>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetHotKeyActionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getHotKeyActionHash() => r'4dc74ea7ffb25624ce70c7c8214806f3ef022223';

final class GetHotKeyActionFamily extends $Family
    with $FunctionalFamilyOverride<HotKeyAction, HotAction> {
  GetHotKeyActionFamily._()
    : super(
        retry: null,
        name: r'getHotKeyActionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetHotKeyActionProvider call(HotAction hotAction) =>
      GetHotKeyActionProvider._(argument: hotAction, from: this);

  @override
  String toString() => r'getHotKeyActionProvider';
}

@ProviderFor(shouldPatchSystemDns)
final shouldPatchSystemDnsProvider = ShouldPatchSystemDnsProvider._();

final class ShouldPatchSystemDnsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  ShouldPatchSystemDnsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shouldPatchSystemDnsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shouldPatchSystemDnsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return shouldPatchSystemDns(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shouldPatchSystemDnsHash() =>
    r'f74bcdbae504e9528b2e960b8620d097c27f3ca9';

@ProviderFor(sharedState)
final sharedStateProvider = SharedStateProvider._();

final class SharedStateProvider
    extends $FunctionalProvider<SharedState, SharedState, SharedState>
    with $Provider<SharedState> {
  SharedStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedStateHash();

  @$internal
  @override
  $ProviderElement<SharedState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedState create(Ref ref) {
    return sharedState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedState>(value),
    );
  }
}

String _$sharedStateHash() => r'1aeb51f6a7b6082f5df2a1942f45ec6c2abce606';

@ProviderFor(vpnRouteAddress)
final vpnRouteAddressProvider = VpnRouteAddressProvider._();

final class VpnRouteAddressProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  VpnRouteAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vpnRouteAddressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vpnRouteAddressHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return vpnRouteAddress(ref);
  }
}

String _$vpnRouteAddressHash() => r'bae2530b73b71ecff16aadfc395e60996d739d41';

@ProviderFor(vpnOptions)
final vpnOptionsProvider = VpnOptionsProvider._();

final class VpnOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<VpnOptions>,
          VpnOptions,
          FutureOr<VpnOptions>
        >
    with $FutureModifier<VpnOptions>, $FutureProvider<VpnOptions> {
  VpnOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vpnOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vpnOptionsHash();

  @$internal
  @override
  $FutureProviderElement<VpnOptions> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<VpnOptions> create(Ref ref) {
    return vpnOptions(ref);
  }
}

String _$vpnOptionsHash() => r'c00e87278b32dd8977ed136aace10dccfe05508d';

@ProviderFor(AccessControlState)
final accessControlStateProvider = AccessControlStateProvider._();

final class AccessControlStateProvider
    extends $NotifierProvider<AccessControlState, AccessControlProps> {
  AccessControlStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accessControlStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accessControlStateHash();

  @$internal
  @override
  AccessControlState create() => AccessControlState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccessControlProps value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccessControlProps>(value),
    );
  }
}

String _$accessControlStateHash() =>
    r'a496770f99975b1bcd7f3f50c55f50726971c749';

abstract class _$AccessControlState extends $Notifier<AccessControlProps> {
  AccessControlProps build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AccessControlProps, AccessControlProps>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccessControlProps, AccessControlProps>,
              AccessControlProps,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(suspend)
final suspendProvider = SuspendProvider._();

final class SuspendProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  SuspendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suspendProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suspendHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return suspend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$suspendHash() => r'9ab9210f4f3c70f63d9858d492a9c09b3fb24bf1';

@ProviderFor(DynamicColor)
final dynamicColorProvider = DynamicColorProvider._();

final class DynamicColorProvider
    extends $NotifierProvider<DynamicColor, DynamicColorSeeds> {
  DynamicColorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynamicColorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dynamicColorHash();

  @$internal
  @override
  DynamicColor create() => DynamicColor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynamicColorSeeds value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynamicColorSeeds>(value),
    );
  }
}

String _$dynamicColorHash() => r'6706bed0ee92072cc5b2847d5504be55d3d51f10';

abstract class _$DynamicColor extends $Notifier<DynamicColorSeeds> {
  DynamicColorSeeds build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DynamicColorSeeds, DynamicColorSeeds>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynamicColorSeeds, DynamicColorSeeds>,
              DynamicColorSeeds,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(genColorScheme)
final genColorSchemeProvider = GenColorSchemeFamily._();

final class GenColorSchemeProvider
    extends $FunctionalProvider<ColorScheme, ColorScheme, ColorScheme>
    with $Provider<ColorScheme> {
  GenColorSchemeProvider._({
    required GenColorSchemeFamily super.from,
    required (Brightness, {Color? color, bool ignoreConfig, bool? pureBlack})
    super.argument,
  }) : super(
         retry: null,
         name: r'genColorSchemeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$genColorSchemeHash();

  @override
  String toString() {
    return r'genColorSchemeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ColorScheme> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ColorScheme create(Ref ref) {
    final argument =
        this.argument
            as (Brightness, {Color? color, bool ignoreConfig, bool? pureBlack});
    return genColorScheme(
      ref,
      argument.$1,
      color: argument.color,
      ignoreConfig: argument.ignoreConfig,
      pureBlack: argument.pureBlack,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColorScheme value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColorScheme>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GenColorSchemeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$genColorSchemeHash() => r'c6e551ef2644606e7945acb21c5d721b5423f3d0';

final class GenColorSchemeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ColorScheme,
          (Brightness, {Color? color, bool ignoreConfig, bool? pureBlack})
        > {
  GenColorSchemeFamily._()
    : super(
        retry: null,
        name: r'genColorSchemeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GenColorSchemeProvider call(
    Brightness brightness, {
    Color? color,
    bool ignoreConfig = false,
    bool? pureBlack,
  }) => GenColorSchemeProvider._(
    argument: (
      brightness,
      color: color,
      ignoreConfig: ignoreConfig,
      pureBlack: pureBlack,
    ),
    from: this,
  );

  @override
  String toString() => r'genColorSchemeProvider';
}

@ProviderFor(windowBlurRequest)
final windowBlurRequestProvider = WindowBlurRequestProvider._();

final class WindowBlurRequestProvider
    extends
        $FunctionalProvider<
          WindowBlurRequest,
          WindowBlurRequest,
          WindowBlurRequest
        >
    with $Provider<WindowBlurRequest> {
  WindowBlurRequestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'windowBlurRequestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$windowBlurRequestHash();

  @$internal
  @override
  $ProviderElement<WindowBlurRequest> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WindowBlurRequest create(Ref ref) {
    return windowBlurRequest(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WindowBlurRequest value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WindowBlurRequest>(value),
    );
  }
}

String _$windowBlurRequestHash() => r'e22ea22957373c5b864e3fb80af56a2d08646666';

@ProviderFor(currentBrightness)
final currentBrightnessProvider = CurrentBrightnessProvider._();

final class CurrentBrightnessProvider
    extends $FunctionalProvider<Brightness, Brightness, Brightness>
    with $Provider<Brightness> {
  CurrentBrightnessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentBrightnessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentBrightnessHash();

  @$internal
  @override
  $ProviderElement<Brightness> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Brightness create(Ref ref) {
    return currentBrightness(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Brightness value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Brightness>(value),
    );
  }
}

String _$currentBrightnessHash() => r'ab56c47af4fcae773c8f9f81c91800c1e1890b70';

@ProviderFor(appProviderNames)
final appProviderNamesProvider = AppProviderNamesFamily._();

final class AppProviderNamesProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  AppProviderNamesProvider._({
    required AppProviderNamesFamily super.from,
    required ProviderKind super.argument,
  }) : super(
         retry: null,
         name: r'appProviderNamesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appProviderNamesHash();

  @override
  String toString() {
    return r'appProviderNamesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    final argument = this.argument as ProviderKind;
    return appProviderNames(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppProviderNamesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appProviderNamesHash() => r'f4c925a4d3c8f0c613a1b84eaba4ad7e6a1b7a35';

final class AppProviderNamesFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, ProviderKind> {
  AppProviderNamesFamily._()
    : super(
        retry: null,
        name: r'appProviderNamesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AppProviderNamesProvider call(ProviderKind kind) =>
      AppProviderNamesProvider._(argument: kind, from: this);

  @override
  String toString() => r'appProviderNamesProvider';
}

/// Null until every source loads, so no check reads a loading one as empty.

@ProviderFor(customProfileData)
final customProfileDataProvider = CustomProfileDataFamily._();

/// Null until every source loads, so no check reads a loading one as empty.

final class CustomProfileDataProvider
    extends
        $FunctionalProvider<
          CustomProfileData?,
          CustomProfileData?,
          CustomProfileData?
        >
    with $Provider<CustomProfileData?> {
  /// Null until every source loads, so no check reads a loading one as empty.
  CustomProfileDataProvider._({
    required CustomProfileDataFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customProfileDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customProfileDataHash();

  @override
  String toString() {
    return r'customProfileDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CustomProfileData?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomProfileData? create(Ref ref) {
    final argument = this.argument as int;
    return customProfileData(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomProfileData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomProfileData?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomProfileDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customProfileDataHash() => r'ac6ab2c3e19ae2724704bfbda1b8751867219e2b';

/// Null until every source loads, so no check reads a loading one as empty.

final class CustomProfileDataFamily extends $Family
    with $FunctionalFamilyOverride<CustomProfileData?, int> {
  CustomProfileDataFamily._()
    : super(
        retry: null,
        name: r'customProfileDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Null until every source loads, so no check reads a loading one as empty.

  CustomProfileDataProvider call(int profileId) =>
      CustomProfileDataProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customProfileDataProvider';
}

@ProviderFor(customProfileTargetIsValid)
final customProfileTargetIsValidProvider = CustomProfileTargetIsValidFamily._();

final class CustomProfileTargetIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomProfileTargetIsValidProvider._({
    required CustomProfileTargetIsValidFamily super.from,
    required (int, String?) super.argument,
  }) : super(
         retry: null,
         name: r'customProfileTargetIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customProfileTargetIsValidHash();

  @override
  String toString() {
    return r'customProfileTargetIsValidProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (int, String?);
    return customProfileTargetIsValid(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomProfileTargetIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customProfileTargetIsValidHash() =>
    r'7bad72daba4c3a8a3fa305bbad40e331a969dc0a';

final class CustomProfileTargetIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, String?)> {
  CustomProfileTargetIsValidFamily._()
    : super(
        retry: null,
        name: r'customProfileTargetIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomProfileTargetIsValidProvider call(int profileId, String? target) =>
      CustomProfileTargetIsValidProvider._(
        argument: (profileId, target),
        from: this,
      );

  @override
  String toString() => r'customProfileTargetIsValidProvider';
}

@ProviderFor(customProfileProxyProviderIsValid)
final customProfileProxyProviderIsValidProvider =
    CustomProfileProxyProviderIsValidFamily._();

final class CustomProfileProxyProviderIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomProfileProxyProviderIsValidProvider._({
    required CustomProfileProxyProviderIsValidFamily super.from,
    required (int, String?) super.argument,
  }) : super(
         retry: null,
         name: r'customProfileProxyProviderIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$customProfileProxyProviderIsValidHash();

  @override
  String toString() {
    return r'customProfileProxyProviderIsValidProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (int, String?);
    return customProfileProxyProviderIsValid(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomProfileProxyProviderIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customProfileProxyProviderIsValidHash() =>
    r'85354503656de3faa3ecddfc0e3fcdecc8062eeb';

final class CustomProfileProxyProviderIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, String?)> {
  CustomProfileProxyProviderIsValidFamily._()
    : super(
        retry: null,
        name: r'customProfileProxyProviderIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomProfileProxyProviderIsValidProvider call(
    int profileId,
    String? providerName,
  ) => CustomProfileProxyProviderIsValidProvider._(
    argument: (profileId, providerName),
    from: this,
  );

  @override
  String toString() => r'customProfileProxyProviderIsValidProvider';
}

@ProviderFor(customProfileRuleProviderIsValid)
final customProfileRuleProviderIsValidProvider =
    CustomProfileRuleProviderIsValidFamily._();

final class CustomProfileRuleProviderIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomProfileRuleProviderIsValidProvider._({
    required CustomProfileRuleProviderIsValidFamily super.from,
    required (int, String?) super.argument,
  }) : super(
         retry: null,
         name: r'customProfileRuleProviderIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customProfileRuleProviderIsValidHash();

  @override
  String toString() {
    return r'customProfileRuleProviderIsValidProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (int, String?);
    return customProfileRuleProviderIsValid(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomProfileRuleProviderIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customProfileRuleProviderIsValidHash() =>
    r'723492065473a91be8349283a0517044e91928f4';

final class CustomProfileRuleProviderIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, String?)> {
  CustomProfileRuleProviderIsValidFamily._()
    : super(
        retry: null,
        name: r'customProfileRuleProviderIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomProfileRuleProviderIsValidProvider call(
    int profileId,
    String? providerName,
  ) => CustomProfileRuleProviderIsValidProvider._(
    argument: (profileId, providerName),
    from: this,
  );

  @override
  String toString() => r'customProfileRuleProviderIsValidProvider';
}

/// Lives with the list, as a verdict can rest on a file such as an ssh key.

@ProviderFor(customProxyVerdicts)
final customProxyVerdictsProvider = CustomProxyVerdictsProvider._();

/// Lives with the list, as a verdict can rest on a file such as an ssh key.

final class CustomProxyVerdictsProvider
    extends
        $FunctionalProvider<
          Map<Map<String, dynamic>, String>,
          Map<Map<String, dynamic>, String>,
          Map<Map<String, dynamic>, String>
        >
    with $Provider<Map<Map<String, dynamic>, String>> {
  /// Lives with the list, as a verdict can rest on a file such as an ssh key.
  CustomProxyVerdictsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customProxyVerdictsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customProxyVerdictsHash();

  @$internal
  @override
  $ProviderElement<Map<Map<String, dynamic>, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<Map<String, dynamic>, String> create(Ref ref) {
    return customProxyVerdicts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<Map<String, dynamic>, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<Map<String, dynamic>, String>>(
        value,
      ),
    );
  }
}

String _$customProxyVerdictsHash() =>
    r'786c59c6c38427fb043ef4cba2889e54d4cbca58';

@ProviderFor(customProxyCoreErrors)
final customProxyCoreErrorsProvider = CustomProxyCoreErrorsProvider._();

final class CustomProxyCoreErrorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String>>,
          Map<int, String>,
          FutureOr<Map<int, String>>
        >
    with $FutureModifier<Map<int, String>>, $FutureProvider<Map<int, String>> {
  CustomProxyCoreErrorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'customProxyCoreErrorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customProxyCoreErrorsHash();

  @$internal
  @override
  $FutureProviderElement<Map<int, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, String>> create(Ref ref) {
    return customProxyCoreErrors(ref);
  }
}

String _$customProxyCoreErrorsHash() =>
    r'a5d5015b5e8ed8d7591bca190a5c242073020a70';

@ProviderFor(customProxyListIssues)
final customProxyListIssuesProvider = CustomProxyListIssuesProvider._();

final class CustomProxyListIssuesProvider
    extends
        $FunctionalProvider<
          Map<int, List<CustomIssue>>,
          Map<int, List<CustomIssue>>,
          Map<int, List<CustomIssue>>
        >
    with $Provider<Map<int, List<CustomIssue>>> {
  CustomProxyListIssuesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customProxyListIssuesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customProxyListIssuesHash();

  @$internal
  @override
  $ProviderElement<Map<int, List<CustomIssue>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<int, List<CustomIssue>> create(Ref ref) {
    return customProxyListIssues(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, List<CustomIssue>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, List<CustomIssue>>>(value),
    );
  }
}

String _$customProxyListIssuesHash() =>
    r'6395fed58b3706e97243ec974bbb7d8a6ab5496f';

@ProviderFor(customProfileIssues)
final customProfileIssuesProvider = CustomProfileIssuesFamily._();

final class CustomProfileIssuesProvider
    extends
        $FunctionalProvider<
          CustomProfileIssues,
          CustomProfileIssues,
          CustomProfileIssues
        >
    with $Provider<CustomProfileIssues> {
  CustomProfileIssuesProvider._({
    required CustomProfileIssuesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customProfileIssuesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customProfileIssuesHash();

  @override
  String toString() {
    return r'customProfileIssuesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CustomProfileIssues> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomProfileIssues create(Ref ref) {
    final argument = this.argument as int;
    return customProfileIssues(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomProfileIssues value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomProfileIssues>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomProfileIssuesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customProfileIssuesHash() =>
    r'39501e79bff4c6dad1d454d5becbecd8bfaaa462';

final class CustomProfileIssuesFamily extends $Family
    with $FunctionalFamilyOverride<CustomProfileIssues, int> {
  CustomProfileIssuesFamily._()
    : super(
        retry: null,
        name: r'customProfileIssuesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomProfileIssuesProvider call(int profileId) =>
      CustomProfileIssuesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customProfileIssuesProvider';
}

@ProviderFor(ProxyGroupProvider)
final proxyGroupProvider = ProxyGroupProviderProvider._();

final class ProxyGroupProviderProvider
    extends $NotifierProvider<ProxyGroupProvider, ProxyGroup> {
  ProxyGroupProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyGroupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyGroupProviderHash();

  @$internal
  @override
  ProxyGroupProvider create() => ProxyGroupProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyGroup value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyGroup>(value),
    );
  }
}

String _$proxyGroupProviderHash() =>
    r'26169a4a0ce5bbe3f0a51f7e79326ce29ec8c5bb';

abstract class _$ProxyGroupProvider extends $Notifier<ProxyGroup> {
  ProxyGroup build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProxyGroup, ProxyGroup>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProxyGroup, ProxyGroup>,
              ProxyGroup,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CustomProxyProvider)
final customProxyProvider = CustomProxyProviderProvider._();

final class CustomProxyProviderProvider
    extends $NotifierProvider<CustomProxyProvider, CustomProxy> {
  CustomProxyProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customProxyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customProxyProviderHash();

  @$internal
  @override
  CustomProxyProvider create() => CustomProxyProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomProxy value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomProxy>(value),
    );
  }
}

String _$customProxyProviderHash() =>
    r'1c6023c816671f343956d5d23423dfcb921e1eab';

abstract class _$CustomProxyProvider extends $Notifier<CustomProxy> {
  CustomProxy build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CustomProxy, CustomProxy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CustomProxy, CustomProxy>,
              CustomProxy,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ProxyProviderOptionsProvider)
final proxyProviderOptionsProvider = ProxyProviderOptionsProviderProvider._();

final class ProxyProviderOptionsProviderProvider
    extends
        $NotifierProvider<ProxyProviderOptionsProvider, ProxyProviderOptions> {
  ProxyProviderOptionsProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyProviderOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyProviderOptionsProviderHash();

  @$internal
  @override
  ProxyProviderOptionsProvider create() => ProxyProviderOptionsProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyProviderOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyProviderOptions>(value),
    );
  }
}

String _$proxyProviderOptionsProviderHash() =>
    r'24b5e2be43820d83cc0b99c2bf0f468cdc9906a5';

abstract class _$ProxyProviderOptionsProvider
    extends $Notifier<ProxyProviderOptions> {
  ProxyProviderOptions build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProxyProviderOptions, ProxyProviderOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProxyProviderOptions, ProxyProviderOptions>,
              ProxyProviderOptions,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(RuleProvider)
final ruleProvider = RuleProviderProvider._();

final class RuleProviderProvider extends $NotifierProvider<RuleProvider, Rule> {
  RuleProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ruleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ruleProviderHash();

  @$internal
  @override
  RuleProvider create() => RuleProvider();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Rule value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Rule>(value),
    );
  }
}

String _$ruleProviderHash() => r'e5917672a4a22745719f3b6b6726fb1135f6a19e';

abstract class _$RuleProvider extends $Notifier<Rule> {
  Rule build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Rule, Rule>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Rule, Rule>,
              Rule,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(currentGroupsState)
final currentGroupsStateProvider = CurrentGroupsStateProvider._();

final class CurrentGroupsStateProvider
    extends $FunctionalProvider<GroupsState, GroupsState, GroupsState>
    with $Provider<GroupsState> {
  CurrentGroupsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentGroupsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentGroupsStateHash();

  @$internal
  @override
  $ProviderElement<GroupsState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupsState create(Ref ref) {
    return currentGroupsState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupsState>(value),
    );
  }
}

String _$currentGroupsStateHash() =>
    r'c93e02f94abd4284bff58c42a931df0b35883bd4';

@ProviderFor(proxyState)
final proxyStateProvider = ProxyStateProvider._();

final class ProxyStateProvider
    extends $FunctionalProvider<ProxyState, ProxyState, ProxyState>
    with $Provider<ProxyState> {
  ProxyStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyStateHash();

  @$internal
  @override
  $ProviderElement<ProxyState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProxyState create(Ref ref) {
    return proxyState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyState>(value),
    );
  }
}

String _$proxyStateHash() => r'76a71ab5da07dca9aeb351282c5c03ab222d0760';

@ProviderFor(proxiesActionsState)
final proxiesActionsStateProvider = ProxiesActionsStateProvider._();

final class ProxiesActionsStateProvider
    extends
        $FunctionalProvider<
          ProxiesActionsState,
          ProxiesActionsState,
          ProxiesActionsState
        >
    with $Provider<ProxiesActionsState> {
  ProxiesActionsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxiesActionsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxiesActionsStateHash();

  @$internal
  @override
  $ProviderElement<ProxiesActionsState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxiesActionsState create(Ref ref) {
    return proxiesActionsState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxiesActionsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxiesActionsState>(value),
    );
  }
}

String _$proxiesActionsStateHash() =>
    r'84f8a94706233ff5d4b8a456291a4e66c1381c62';

/// Watching the delay map instead would drop nodes one probe at a time, and
/// reading it on any other rebuild would drop them whenever something
/// unrelated changed mid-test.

@ProviderFor(delaysAtLastTestBatch)
final delaysAtLastTestBatchProvider = DelaysAtLastTestBatchProvider._();

/// Watching the delay map instead would drop nodes one probe at a time, and
/// reading it on any other rebuild would drop them whenever something
/// unrelated changed mid-test.

final class DelaysAtLastTestBatchProvider
    extends $FunctionalProvider<DelayMap, DelayMap, DelayMap>
    with $Provider<DelayMap> {
  /// Watching the delay map instead would drop nodes one probe at a time, and
  /// reading it on any other rebuild would drop them whenever something
  /// unrelated changed mid-test.
  DelaysAtLastTestBatchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'delaysAtLastTestBatchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$delaysAtLastTestBatchHash();

  @$internal
  @override
  $ProviderElement<DelayMap> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DelayMap create(Ref ref) {
    return delaysAtLastTestBatch(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DelayMap value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DelayMap>(value),
    );
  }
}

String _$delaysAtLastTestBatchHash() =>
    r'830e4b670d6a0ffa5ea8edc112a1d591a5adfaec';

@ProviderFor(visibleGroupsState)
final visibleGroupsStateProvider = VisibleGroupsStateProvider._();

final class VisibleGroupsStateProvider
    extends $FunctionalProvider<GroupsState, GroupsState, GroupsState>
    with $Provider<GroupsState> {
  VisibleGroupsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visibleGroupsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visibleGroupsStateHash();

  @$internal
  @override
  $ProviderElement<GroupsState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupsState create(Ref ref) {
    return visibleGroupsState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupsState>(value),
    );
  }
}

String _$visibleGroupsStateHash() =>
    r'02b4a37b356f4484fa3787a08a239ddfe77769f0';

@ProviderFor(filterGroupsState)
final filterGroupsStateProvider = FilterGroupsStateFamily._();

final class FilterGroupsStateProvider
    extends $FunctionalProvider<GroupsState, GroupsState, GroupsState>
    with $Provider<GroupsState> {
  FilterGroupsStateProvider._({
    required FilterGroupsStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filterGroupsStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filterGroupsStateHash();

  @override
  String toString() {
    return r'filterGroupsStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GroupsState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupsState create(Ref ref) {
    final argument = this.argument as String;
    return filterGroupsState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilterGroupsStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filterGroupsStateHash() => r'187b758f3bddcf66e429eda99dfcb4254f9e4583';

final class FilterGroupsStateFamily extends $Family
    with $FunctionalFamilyOverride<GroupsState, String> {
  FilterGroupsStateFamily._()
    : super(
        retry: null,
        name: r'filterGroupsStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilterGroupsStateProvider call(String query) =>
      FilterGroupsStateProvider._(argument: query, from: this);

  @override
  String toString() => r'filterGroupsStateProvider';
}

@ProviderFor(proxiesListState)
final proxiesListStateProvider = ProxiesListStateProvider._();

final class ProxiesListStateProvider
    extends
        $FunctionalProvider<
          ProxiesListState,
          ProxiesListState,
          ProxiesListState
        >
    with $Provider<ProxiesListState> {
  ProxiesListStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxiesListStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxiesListStateHash();

  @$internal
  @override
  $ProviderElement<ProxiesListState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProxiesListState create(Ref ref) {
    return proxiesListState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxiesListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxiesListState>(value),
    );
  }
}

String _$proxiesListStateHash() => r'212d21f79e9c149076e13d1d19ccd83ccb4b471b';

@ProviderFor(proxiesTabState)
final proxiesTabStateProvider = ProxiesTabStateProvider._();

final class ProxiesTabStateProvider
    extends
        $FunctionalProvider<ProxiesTabState, ProxiesTabState, ProxiesTabState>
    with $Provider<ProxiesTabState> {
  ProxiesTabStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxiesTabStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxiesTabStateHash();

  @$internal
  @override
  $ProviderElement<ProxiesTabState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProxiesTabState create(Ref ref) {
    return proxiesTabState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxiesTabState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxiesTabState>(value),
    );
  }
}

String _$proxiesTabStateHash() => r'e4eccd77c3848489c8ec620f4e515cec7cdd5a31';

@ProviderFor(isStart)
final isStartProvider = IsStartProvider._();

final class IsStartProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isStartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isStartHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isStart(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isStartHash() => r'f8bcefa8515c44fbe14876a5fc6676110508e9b2';

@ProviderFor(proxiesTabControllerState)
final proxiesTabControllerStateProvider = ProxiesTabControllerStateProvider._();

final class ProxiesTabControllerStateProvider
    extends
        $FunctionalProvider<
          ProxiesTabControllerState,
          ProxiesTabControllerState,
          ProxiesTabControllerState
        >
    with $Provider<ProxiesTabControllerState> {
  ProxiesTabControllerStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxiesTabControllerStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxiesTabControllerStateHash();

  @$internal
  @override
  $ProviderElement<ProxiesTabControllerState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxiesTabControllerState create(Ref ref) {
    return proxiesTabControllerState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxiesTabControllerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxiesTabControllerState>(value),
    );
  }
}

String _$proxiesTabControllerStateHash() =>
    r'548db61efef2c47c2694c855436276fcd3529956';

@ProviderFor(proxyGroupSelectorState)
final proxyGroupSelectorStateProvider = ProxyGroupSelectorStateFamily._();

final class ProxyGroupSelectorStateProvider
    extends
        $FunctionalProvider<
          ProxyGroupSelectorState,
          ProxyGroupSelectorState,
          ProxyGroupSelectorState
        >
    with $Provider<ProxyGroupSelectorState> {
  ProxyGroupSelectorStateProvider._({
    required ProxyGroupSelectorStateFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'proxyGroupSelectorStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyGroupSelectorStateHash();

  @override
  String toString() {
    return r'proxyGroupSelectorStateProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<ProxyGroupSelectorState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProxyGroupSelectorState create(Ref ref) {
    final argument = this.argument as (String, String);
    return proxyGroupSelectorState(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProxyGroupSelectorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProxyGroupSelectorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyGroupSelectorStateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyGroupSelectorStateHash() =>
    r'afa6c749b28aa2a2c4d3b120ab16e46c46306040';

final class ProxyGroupSelectorStateFamily extends $Family
    with $FunctionalFamilyOverride<ProxyGroupSelectorState, (String, String)> {
  ProxyGroupSelectorStateFamily._()
    : super(
        retry: null,
        name: r'proxyGroupSelectorStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyGroupSelectorStateProvider call(String groupName, String query) =>
      ProxyGroupSelectorStateProvider._(
        argument: (groupName, query),
        from: this,
      );

  @override
  String toString() => r'proxyGroupSelectorStateProvider';
}

@ProviderFor(realTestUrl)
final realTestUrlProvider = RealTestUrlFamily._();

final class RealTestUrlProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  RealTestUrlProvider._({
    required RealTestUrlFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'realTestUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$realTestUrlHash();

  @override
  String toString() {
    return r'realTestUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as String?;
    return realTestUrl(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RealTestUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$realTestUrlHash() => r'6d68caa7a526b6788e3e4899d3ec8ad1c065b15e';

final class RealTestUrlFamily extends $Family
    with $FunctionalFamilyOverride<String, String?> {
  RealTestUrlFamily._()
    : super(
        retry: null,
        name: r'realTestUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RealTestUrlProvider call([String? testUrl]) =>
      RealTestUrlProvider._(argument: testUrl, from: this);

  @override
  String toString() => r'realTestUrlProvider';
}

@ProviderFor(delay)
final delayProvider = DelayFamily._();

final class DelayProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  DelayProvider._({
    required DelayFamily super.from,
    required ({String proxyName, String? testUrl}) super.argument,
  }) : super(
         retry: null,
         name: r'delayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$delayHash();

  @override
  String toString() {
    return r'delayProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    final argument = this.argument as ({String proxyName, String? testUrl});
    return delay(ref, proxyName: argument.proxyName, testUrl: argument.testUrl);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DelayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$delayHash() => r'3cbaa758ea602519d2958a4e413c705b062bce32';

final class DelayFamily extends $Family
    with
        $FunctionalFamilyOverride<int?, ({String proxyName, String? testUrl})> {
  DelayFamily._()
    : super(
        retry: null,
        name: r'delayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DelayProvider call({required String proxyName, String? testUrl}) =>
      DelayProvider._(
        argument: (proxyName: proxyName, testUrl: testUrl),
        from: this,
      );

  @override
  String toString() => r'delayProvider';
}

@ProviderFor(delayTestPhase)
final delayTestPhaseProvider = DelayTestPhaseFamily._();

final class DelayTestPhaseProvider
    extends
        $FunctionalProvider<DelayTestPhase?, DelayTestPhase?, DelayTestPhase?>
    with $Provider<DelayTestPhase?> {
  DelayTestPhaseProvider._({
    required DelayTestPhaseFamily super.from,
    required ({String proxyName, String? testUrl}) super.argument,
  }) : super(
         retry: null,
         name: r'delayTestPhaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$delayTestPhaseHash();

  @override
  String toString() {
    return r'delayTestPhaseProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<DelayTestPhase?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DelayTestPhase? create(Ref ref) {
    final argument = this.argument as ({String proxyName, String? testUrl});
    return delayTestPhase(
      ref,
      proxyName: argument.proxyName,
      testUrl: argument.testUrl,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DelayTestPhase? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DelayTestPhase?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DelayTestPhaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$delayTestPhaseHash() => r'e757e70a0e180c01a4e660e1f16ce77a4547f4cf';

final class DelayTestPhaseFamily extends $Family
    with
        $FunctionalFamilyOverride<
          DelayTestPhase?,
          ({String proxyName, String? testUrl})
        > {
  DelayTestPhaseFamily._()
    : super(
        retry: null,
        name: r'delayTestPhaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DelayTestPhaseProvider call({required String proxyName, String? testUrl}) =>
      DelayTestPhaseProvider._(
        argument: (proxyName: proxyName, testUrl: testUrl),
        from: this,
      );

  @override
  String toString() => r'delayTestPhaseProvider';
}

@ProviderFor(selectedMap)
final selectedMapProvider = SelectedMapProvider._();

final class SelectedMapProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  SelectedMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedMapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedMapHash();

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    return selectedMap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$selectedMapHash() => r'd4438d8d87d0c7ec7d9c5d02f577cdba6ba2a785';

@ProviderFor(unfoldSet)
final unfoldSetProvider = UnfoldSetProvider._();

final class UnfoldSetProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  UnfoldSetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unfoldSetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unfoldSetHash();

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    return unfoldSet(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$unfoldSetHash() => r'59a5b417611533069462ddf31eca080ab2f74ac9';

@ProviderFor(realSelectedProxyState)
final realSelectedProxyStateProvider = RealSelectedProxyStateFamily._();

final class RealSelectedProxyStateProvider
    extends
        $FunctionalProvider<
          SelectedProxyState,
          SelectedProxyState,
          SelectedProxyState
        >
    with $Provider<SelectedProxyState> {
  RealSelectedProxyStateProvider._({
    required RealSelectedProxyStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'realSelectedProxyStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$realSelectedProxyStateHash();

  @override
  String toString() {
    return r'realSelectedProxyStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SelectedProxyState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelectedProxyState create(Ref ref) {
    final argument = this.argument as String;
    return realSelectedProxyState(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedProxyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedProxyState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RealSelectedProxyStateProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$realSelectedProxyStateHash() =>
    r'42fa131419f0a26e30c4f5269bf020893b7f828c';

final class RealSelectedProxyStateFamily extends $Family
    with $FunctionalFamilyOverride<SelectedProxyState, String> {
  RealSelectedProxyStateFamily._()
    : super(
        retry: null,
        name: r'realSelectedProxyStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RealSelectedProxyStateProvider call(String proxyName) =>
      RealSelectedProxyStateProvider._(argument: proxyName, from: this);

  @override
  String toString() => r'realSelectedProxyStateProvider';
}

@ProviderFor(proxyName)
final proxyNameProvider = ProxyNameFamily._();

final class ProxyNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  ProxyNameProvider._({
    required ProxyNameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'proxyNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyNameHash();

  @override
  String toString() {
    return r'proxyNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return proxyName(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyNameHash() => r'a34d43762ff87d7ccd504a7e9ab66a25396b529f';

final class ProxyNameFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  ProxyNameFamily._()
    : super(
        retry: null,
        name: r'proxyNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyNameProvider call(String groupName) =>
      ProxyNameProvider._(argument: groupName, from: this);

  @override
  String toString() => r'proxyNameProvider';
}

@ProviderFor(selectedProxyName)
final selectedProxyNameProvider = SelectedProxyNameFamily._();

final class SelectedProxyNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  SelectedProxyNameProvider._({
    required SelectedProxyNameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectedProxyNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedProxyNameHash();

  @override
  String toString() {
    return r'selectedProxyNameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return selectedProxyName(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedProxyNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedProxyNameHash() => r'417c99385108d630b7cc8aaa3e94abd7011cbc58';

final class SelectedProxyNameFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  SelectedProxyNameFamily._()
    : super(
        retry: null,
        name: r'selectedProxyNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SelectedProxyNameProvider call(String groupName) =>
      SelectedProxyNameProvider._(argument: groupName, from: this);

  @override
  String toString() => r'selectedProxyNameProvider';
}

@ProviderFor(proxyDesc)
final proxyDescProvider = ProxyDescFamily._();

final class ProxyDescProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  ProxyDescProvider._({
    required ProxyDescFamily super.from,
    required Proxy super.argument,
  }) : super(
         retry: null,
         name: r'proxyDescProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyDescHash();

  @override
  String toString() {
    return r'proxyDescProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as Proxy;
    return proxyDesc(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyDescProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyDescHash() => r'16dbf0d090ba4699b1a282d804d1e75a9910696f';

final class ProxyDescFamily extends $Family
    with $FunctionalFamilyOverride<String, Proxy> {
  ProxyDescFamily._()
    : super(
        retry: null,
        name: r'proxyDescProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyDescProvider call(Proxy proxy) =>
      ProxyDescProvider._(argument: proxy, from: this);

  @override
  String toString() => r'proxyDescProvider';
}

@ProviderFor(needUpdateGroups)
final needUpdateGroupsProvider = NeedUpdateGroupsProvider._();

final class NeedUpdateGroupsProvider
    extends
        $FunctionalProvider<
          ({bool isProxies, int sortNum, ProxiesSortType sortType}),
          ({bool isProxies, int sortNum, ProxiesSortType sortType}),
          ({bool isProxies, int sortNum, ProxiesSortType sortType})
        >
    with $Provider<({bool isProxies, int sortNum, ProxiesSortType sortType})> {
  NeedUpdateGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'needUpdateGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$needUpdateGroupsHash();

  @$internal
  @override
  $ProviderElement<({bool isProxies, int sortNum, ProxiesSortType sortType})>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ({bool isProxies, int sortNum, ProxiesSortType sortType}) create(Ref ref) {
    return needUpdateGroups(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({bool isProxies, int sortNum, ProxiesSortType sortType}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            ({bool isProxies, int sortNum, ProxiesSortType sortType})
          >(value),
    );
  }
}

String _$needUpdateGroupsHash() => r'90b7cb35c96bda157cf436e32f251e58721ef757';

@ProviderFor(navigationItemsState)
final navigationItemsStateProvider = NavigationItemsStateProvider._();

final class NavigationItemsStateProvider
    extends
        $FunctionalProvider<
          NavigationItemsState,
          NavigationItemsState,
          NavigationItemsState
        >
    with $Provider<NavigationItemsState> {
  NavigationItemsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationItemsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationItemsStateHash();

  @$internal
  @override
  $ProviderElement<NavigationItemsState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigationItemsState create(Ref ref) {
    return navigationItemsState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationItemsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationItemsState>(value),
    );
  }
}

String _$navigationItemsStateHash() =>
    r'3c633d4f3e5f2e80b7cfd166a46397f9a207bb1e';

@ProviderFor(currentNavigationItemsState)
final currentNavigationItemsStateProvider =
    CurrentNavigationItemsStateProvider._();

final class CurrentNavigationItemsStateProvider
    extends
        $FunctionalProvider<
          NavigationItemsState,
          NavigationItemsState,
          NavigationItemsState
        >
    with $Provider<NavigationItemsState> {
  CurrentNavigationItemsStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentNavigationItemsStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentNavigationItemsStateHash();

  @$internal
  @override
  $ProviderElement<NavigationItemsState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigationItemsState create(Ref ref) {
    return currentNavigationItemsState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationItemsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationItemsState>(value),
    );
  }
}

String _$currentNavigationItemsStateHash() =>
    r'06fbdc194f4527b945695fe3b72b16e0585fa440';

@ProviderFor(navigationState)
final navigationStateProvider = NavigationStateProvider._();

final class NavigationStateProvider
    extends
        $FunctionalProvider<NavigationState, NavigationState, NavigationState>
    with $Provider<NavigationState> {
  NavigationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationStateHash();

  @$internal
  @override
  $ProviderElement<NavigationState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NavigationState create(Ref ref) {
    return navigationState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationState>(value),
    );
  }
}

String _$navigationStateHash() => r'657dc47ecc35ba0807b58cb37e7f1baa14f6c2f9';

@ProviderFor(dashboardState)
final dashboardStateProvider = DashboardStateProvider._();

final class DashboardStateProvider
    extends $FunctionalProvider<DashboardState, DashboardState, DashboardState>
    with $Provider<DashboardState> {
  DashboardStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStateHash();

  @$internal
  @override
  $ProviderElement<DashboardState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DashboardState create(Ref ref) {
    return dashboardState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardState>(value),
    );
  }
}

String _$dashboardStateHash() => r'33838f85f2b6a0ab601891aa2f26adc8870302b6';

@ProviderFor(moreToolsSelectorState)
final moreToolsSelectorStateProvider = MoreToolsSelectorStateProvider._();

final class MoreToolsSelectorStateProvider
    extends
        $FunctionalProvider<
          MoreToolsSelectorState,
          MoreToolsSelectorState,
          MoreToolsSelectorState
        >
    with $Provider<MoreToolsSelectorState> {
  MoreToolsSelectorStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moreToolsSelectorStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moreToolsSelectorStateHash();

  @$internal
  @override
  $ProviderElement<MoreToolsSelectorState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MoreToolsSelectorState create(Ref ref) {
    return moreToolsSelectorState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MoreToolsSelectorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MoreToolsSelectorState>(value),
    );
  }
}

String _$moreToolsSelectorStateHash() =>
    r'c47987547d0e59da10ec4bbd9c8cf1416f8477f3';

@ProviderFor(isCurrentPage)
final isCurrentPageProvider = IsCurrentPageFamily._();

final class IsCurrentPageProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsCurrentPageProvider._({
    required IsCurrentPageFamily super.from,
    required (
      PageLabel, {
      bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'isCurrentPageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isCurrentPageHash();

  @override
  String toString() {
    return r'isCurrentPageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument =
        this.argument
            as (
              PageLabel, {
              bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
            });
    return isCurrentPage(ref, argument.$1, handler: argument.handler);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsCurrentPageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isCurrentPageHash() => r'7c300770aef90da23109d9fcfc3bf26140d8cd08';

final class IsCurrentPageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          bool,
          (
            PageLabel, {
            bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
          })
        > {
  IsCurrentPageFamily._()
    : super(
        retry: null,
        name: r'isCurrentPageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsCurrentPageProvider call(
    PageLabel pageLabel, {
    bool Function(PageLabel pageLabel, ViewMode viewMode)? handler,
  }) => IsCurrentPageProvider._(
    argument: (pageLabel, handler: handler),
    from: this,
  );

  @override
  String toString() => r'isCurrentPageProvider';
}

@ProviderFor(overlayTopOffset)
final overlayTopOffsetProvider = OverlayTopOffsetProvider._();

final class OverlayTopOffsetProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  OverlayTopOffsetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'overlayTopOffsetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$overlayTopOffsetHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return overlayTopOffset(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$overlayTopOffsetHash() => r'44c3b3c9f8f3af5e10ba91e0f2514f52f3c6ddac';

@ProviderFor(profilesState)
final profilesStateProvider = ProfilesStateProvider._();

final class ProfilesStateProvider
    extends $FunctionalProvider<ProfilesState, ProfilesState, ProfilesState>
    with $Provider<ProfilesState> {
  ProfilesStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesStateHash();

  @$internal
  @override
  $ProviderElement<ProfilesState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfilesState create(Ref ref) {
    return profilesState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfilesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfilesState>(value),
    );
  }
}

String _$profilesStateHash() => r'6bcfd61de84c930251ade72b9fe804c4f5ac2be9';

@ProviderFor(currentProfile)
final currentProfileProvider = CurrentProfileProvider._();

final class CurrentProfileProvider
    extends $FunctionalProvider<Profile?, Profile?, Profile?>
    with $Provider<Profile?> {
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $ProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Profile? create(Ref ref) {
    return currentProfile(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Profile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Profile?>(value),
    );
  }
}

String _$currentProfileHash() => r'55f3cb9570a0aa6b9e0b83a36693b69d52e753ab';

@ProviderFor(profile)
final profileProvider = ProfileFamily._();

final class ProfileProvider
    extends $FunctionalProvider<Profile?, Profile?, Profile?>
    with $Provider<Profile?> {
  ProfileProvider._({
    required ProfileFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'profileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @override
  String toString() {
    return r'profileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Profile? create(Ref ref) {
    final argument = this.argument as int?;
    return profile(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Profile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Profile?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileHash() => r'8de429dc0844c6b6155032ad3c9546231e08cead';

final class ProfileFamily extends $Family
    with $FunctionalFamilyOverride<Profile?, int?> {
  ProfileFamily._()
    : super(
        retry: null,
        name: r'profileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileProvider call(int? profileId) =>
      ProfileProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileProvider';
}

@ProviderFor(extendType)
final extendTypeProvider = ExtendTypeFamily._();

final class ExtendTypeProvider
    extends $FunctionalProvider<ExtendType, ExtendType, ExtendType>
    with $Provider<ExtendType> {
  ExtendTypeProvider._({
    required ExtendTypeFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'extendTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$extendTypeHash();

  @override
  String toString() {
    return r'extendTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ExtendType> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExtendType create(Ref ref) {
    final argument = this.argument as int?;
    return extendType(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExtendType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExtendType>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ExtendTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$extendTypeHash() => r'166b866a116caa0e93de80b9a59e23697508d219';

final class ExtendTypeFamily extends $Family
    with $FunctionalFamilyOverride<ExtendType, int?> {
  ExtendTypeFamily._()
    : super(
        retry: null,
        name: r'extendTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExtendTypeProvider call(int? profileId) =>
      ExtendTypeProvider._(argument: profileId, from: this);

  @override
  String toString() => r'extendTypeProvider';
}

@ProviderFor(clashConfig)
final clashConfigProvider = ClashConfigFamily._();

final class ClashConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClashConfig>,
          ClashConfig,
          FutureOr<ClashConfig>
        >
    with $FutureModifier<ClashConfig>, $FutureProvider<ClashConfig> {
  ClashConfigProvider._({
    required ClashConfigFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'clashConfigProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clashConfigHash();

  @override
  String toString() {
    return r'clashConfigProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ClashConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClashConfig> create(Ref ref) {
    final argument = this.argument as int;
    return clashConfig(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClashConfigProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clashConfigHash() => r'5380d3193f9b1fe8fd1f810babb92de70b2d2f89';

final class ClashConfigFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ClashConfig>, int> {
  ClashConfigFamily._()
    : super(
        retry: null,
        name: r'clashConfigProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClashConfigProvider call(int profileId) =>
      ClashConfigProvider._(argument: profileId, from: this);

  @override
  String toString() => r'clashConfigProvider';
}

@ProviderFor(setupState)
final setupStateProvider = SetupStateFamily._();

final class SetupStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<SetupState>,
          SetupState,
          FutureOr<SetupState>
        >
    with $FutureModifier<SetupState>, $FutureProvider<SetupState> {
  SetupStateProvider._({
    required SetupStateFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'setupStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setupStateHash();

  @override
  String toString() {
    return r'setupStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SetupState> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SetupState> create(Ref ref) {
    final argument = this.argument as int?;
    return setupState(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SetupStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setupStateHash() => r'aa74b203b75682d0dbe067377d985378adb63709';

final class SetupStateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SetupState>, int?> {
  SetupStateFamily._()
    : super(
        retry: null,
        name: r'setupStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SetupStateProvider call(int? profileId) =>
      SetupStateProvider._(argument: profileId, from: this);

  @override
  String toString() => r'setupStateProvider';
}

/// Subscription profiles double as proxy providers for custom profiles.

@ProviderFor(profileProviders)
final profileProvidersProvider = ProfileProvidersProvider._();

/// Subscription profiles double as proxy providers for custom profiles.

final class ProfileProvidersProvider
    extends
        $FunctionalProvider<
          Map<String, int>,
          Map<String, int>,
          Map<String, int>
        >
    with $Provider<Map<String, int>> {
  /// Subscription profiles double as proxy providers for custom profiles.
  ProfileProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvidersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileProvidersHash();

  @$internal
  @override
  $ProviderElement<Map<String, int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, int> create(Ref ref) {
    return profileProviders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$profileProvidersHash() => r'689856f32a4b40e6a26b1eedd16db418d140371a';

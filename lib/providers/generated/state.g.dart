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

String _$updateParamsHash() => r'26072e2884cf9613d2a33b44ab78d8014d66fc02';

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

@ProviderFor(vpnState)
final vpnStateProvider = VpnStateProvider._();

final class VpnStateProvider
    extends $FunctionalProvider<VpnState, VpnState, VpnState>
    with $Provider<VpnState> {
  VpnStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vpnStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vpnStateHash();

  @$internal
  @override
  $ProviderElement<VpnState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VpnState create(Ref ref) {
    return vpnState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VpnState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VpnState>(value),
    );
  }
}

String _$vpnStateHash() => r'128ddad03ce045ad1f8204e47aec3cb6cfa29f6e';

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

String _$sharedStateHash() => r'88b6489f5ba8fb588a264408312e69fce09e91b7';

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

String _$genColorSchemeHash() => r'6cdb57ea100cf84c9920e2795963407b62af4543';

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

@ProviderFor(appProviderLabels)
final appProviderLabelsProvider = AppProviderLabelsFamily._();

final class AppProviderLabelsProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  AppProviderLabelsProvider._({
    required AppProviderLabelsFamily super.from,
    required ProviderKind super.argument,
  }) : super(
         retry: null,
         name: r'appProviderLabelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$appProviderLabelsHash();

  @override
  String toString() {
    return r'appProviderLabelsProvider'
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
    return appProviderLabels(ref, argument);
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
    return other is AppProviderLabelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$appProviderLabelsHash() => r'1d3f53046c124c8c1a66c599badc7e2043ec1333';

final class AppProviderLabelsFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, ProviderKind> {
  AppProviderLabelsFamily._()
    : super(
        retry: null,
        name: r'appProviderLabelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AppProviderLabelsProvider call(ProviderKind kind) =>
      AppProviderLabelsProvider._(argument: kind, from: this);

  @override
  String toString() => r'appProviderLabelsProvider';
}

/// Selectable in every profile, so valid next to the names its own config has.

@ProviderFor(appProviderNames)
final appProviderNamesProvider = AppProviderNamesFamily._();

/// Selectable in every profile, so valid next to the names its own config has.

final class AppProviderNamesProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// Selectable in every profile, so valid next to the names its own config has.
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

String _$appProviderNamesHash() => r'3b4d7003031fd91ef58bed2f155df991e98211fb';

/// Selectable in every profile, so valid next to the names its own config has.

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

  /// Selectable in every profile, so valid next to the names its own config has.

  AppProviderNamesProvider call(ProviderKind kind) =>
      AppProviderNamesProvider._(argument: kind, from: this);

  @override
  String toString() => r'appProviderNamesProvider';
}

/// A name the subscription defines is its own, and a profile beats an app one.

@ProviderFor(providerSources)
final providerSourcesProvider = ProviderSourcesFamily._();

/// A name the subscription defines is its own, and a profile beats an app one.

final class ProviderSourcesProvider
    extends
        $FunctionalProvider<
          Map<String, ProviderSource>,
          Map<String, ProviderSource>,
          Map<String, ProviderSource>
        >
    with $Provider<Map<String, ProviderSource>> {
  /// A name the subscription defines is its own, and a profile beats an app one.
  ProviderSourcesProvider._({
    required ProviderSourcesFamily super.from,
    required (int, ProviderKind) super.argument,
  }) : super(
         retry: null,
         name: r'providerSourcesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$providerSourcesHash();

  @override
  String toString() {
    return r'providerSourcesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<Map<String, ProviderSource>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, ProviderSource> create(Ref ref) {
    final argument = this.argument as (int, ProviderKind);
    return providerSources(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ProviderSource> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ProviderSource>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProviderSourcesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$providerSourcesHash() => r'7be45ffdf44a78462d24aae41094d6625c66a152';

/// A name the subscription defines is its own, and a profile beats an app one.

final class ProviderSourcesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Map<String, ProviderSource>,
          (int, ProviderKind)
        > {
  ProviderSourcesFamily._()
    : super(
        retry: null,
        name: r'providerSourcesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A name the subscription defines is its own, and a profile beats an app one.

  ProviderSourcesProvider call(int profileId, ProviderKind kind) =>
      ProviderSourcesProvider._(argument: (profileId, kind), from: this);

  @override
  String toString() => r'providerSourcesProvider';
}

@ProviderFor(customOverwriteDate)
final customOverwriteDateProvider = CustomOverwriteDateFamily._();

final class CustomOverwriteDateProvider
    extends
        $FunctionalProvider<
          CustomOverwriteDate,
          CustomOverwriteDate,
          CustomOverwriteDate
        >
    with $Provider<CustomOverwriteDate> {
  CustomOverwriteDateProvider._({
    required CustomOverwriteDateFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customOverwriteDateHash();

  @override
  String toString() {
    return r'customOverwriteDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CustomOverwriteDate> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomOverwriteDate create(Ref ref) {
    final argument = this.argument as int;
    return customOverwriteDate(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomOverwriteDate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomOverwriteDate>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomOverwriteDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteDateHash() =>
    r'd02ff81daf29e2be806f211cb0d07edd37e0db4e';

final class CustomOverwriteDateFamily extends $Family
    with $FunctionalFamilyOverride<CustomOverwriteDate, int> {
  CustomOverwriteDateFamily._()
    : super(
        retry: null,
        name: r'customOverwriteDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteDateProvider call(int profileId) =>
      CustomOverwriteDateProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customOverwriteDateProvider';
}

@ProviderFor(customOverwriteTargetIsValid)
final customOverwriteTargetIsValidProvider =
    CustomOverwriteTargetIsValidFamily._();

final class CustomOverwriteTargetIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomOverwriteTargetIsValidProvider._({
    required CustomOverwriteTargetIsValidFamily super.from,
    required (int, String?) super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteTargetIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customOverwriteTargetIsValidHash();

  @override
  String toString() {
    return r'customOverwriteTargetIsValidProvider'
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
    return customOverwriteTargetIsValid(ref, argument.$1, argument.$2);
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
    return other is CustomOverwriteTargetIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteTargetIsValidHash() =>
    r'cafcd9915173737f36346feec28e41221ab3657e';

final class CustomOverwriteTargetIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, String?)> {
  CustomOverwriteTargetIsValidFamily._()
    : super(
        retry: null,
        name: r'customOverwriteTargetIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteTargetIsValidProvider call(int profileId, String? target) =>
      CustomOverwriteTargetIsValidProvider._(
        argument: (profileId, target),
        from: this,
      );

  @override
  String toString() => r'customOverwriteTargetIsValidProvider';
}

@ProviderFor(customOverwriteProxyProviderIsValid)
final customOverwriteProxyProviderIsValidProvider =
    CustomOverwriteProxyProviderIsValidFamily._();

final class CustomOverwriteProxyProviderIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomOverwriteProxyProviderIsValidProvider._({
    required CustomOverwriteProxyProviderIsValidFamily super.from,
    required (int, String?) super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteProxyProviderIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$customOverwriteProxyProviderIsValidHash();

  @override
  String toString() {
    return r'customOverwriteProxyProviderIsValidProvider'
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
    return customOverwriteProxyProviderIsValid(ref, argument.$1, argument.$2);
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
    return other is CustomOverwriteProxyProviderIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteProxyProviderIsValidHash() =>
    r'c9b9a691686fd41605cbdf4e5adceadf1245390f';

final class CustomOverwriteProxyProviderIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, String?)> {
  CustomOverwriteProxyProviderIsValidFamily._()
    : super(
        retry: null,
        name: r'customOverwriteProxyProviderIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteProxyProviderIsValidProvider call(
    int profileId,
    String? providerName,
  ) => CustomOverwriteProxyProviderIsValidProvider._(
    argument: (profileId, providerName),
    from: this,
  );

  @override
  String toString() => r'customOverwriteProxyProviderIsValidProvider';
}

@ProviderFor(customOverwriteRuleProviderIsValid)
final customOverwriteRuleProviderIsValidProvider =
    CustomOverwriteRuleProviderIsValidFamily._();

final class CustomOverwriteRuleProviderIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomOverwriteRuleProviderIsValidProvider._({
    required CustomOverwriteRuleProviderIsValidFamily super.from,
    required (int, String?) super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteRuleProviderIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$customOverwriteRuleProviderIsValidHash();

  @override
  String toString() {
    return r'customOverwriteRuleProviderIsValidProvider'
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
    return customOverwriteRuleProviderIsValid(ref, argument.$1, argument.$2);
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
    return other is CustomOverwriteRuleProviderIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteRuleProviderIsValidHash() =>
    r'360dcac0f6df17d628b045c666b5e5969991bb3b';

final class CustomOverwriteRuleProviderIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, String?)> {
  CustomOverwriteRuleProviderIsValidFamily._()
    : super(
        retry: null,
        name: r'customOverwriteRuleProviderIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteRuleProviderIsValidProvider call(
    int profileId,
    String? providerName,
  ) => CustomOverwriteRuleProviderIsValidProvider._(
    argument: (profileId, providerName),
    from: this,
  );

  @override
  String toString() => r'customOverwriteRuleProviderIsValidProvider';
}

@ProviderFor(customProxyCoreErrors)
final customProxyCoreErrorsProvider = CustomProxyCoreErrorsFamily._();

final class CustomProxyCoreErrorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String>>,
          Map<int, String>,
          FutureOr<Map<int, String>>
        >
    with $FutureModifier<Map<int, String>>, $FutureProvider<Map<int, String>> {
  CustomProxyCoreErrorsProvider._({
    required CustomProxyCoreErrorsFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'customProxyCoreErrorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customProxyCoreErrorsHash();

  @override
  String toString() {
    return r'customProxyCoreErrorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, String>> create(Ref ref) {
    final argument = this.argument as int;
    return customProxyCoreErrors(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomProxyCoreErrorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customProxyCoreErrorsHash() =>
    r'6396bdc3600022e0790d911e7e0b8f54b920a699';

final class CustomProxyCoreErrorsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<int, String>>, int> {
  CustomProxyCoreErrorsFamily._()
    : super(
        retry: _noRetry,
        name: r'customProxyCoreErrorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomProxyCoreErrorsProvider call(int profileId) =>
      CustomProxyCoreErrorsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customProxyCoreErrorsProvider';
}

@ProviderFor(effectiveProxyGroups)
final effectiveProxyGroupsProvider = EffectiveProxyGroupsFamily._();

final class EffectiveProxyGroupsProvider
    extends
        $FunctionalProvider<
          List<ProxyGroup>,
          List<ProxyGroup>,
          List<ProxyGroup>
        >
    with $Provider<List<ProxyGroup>> {
  EffectiveProxyGroupsProvider._({
    required EffectiveProxyGroupsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'effectiveProxyGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$effectiveProxyGroupsHash();

  @override
  String toString() {
    return r'effectiveProxyGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ProxyGroup>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ProxyGroup> create(Ref ref) {
    final argument = this.argument as int;
    return effectiveProxyGroups(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ProxyGroup> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProxyGroup>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveProxyGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$effectiveProxyGroupsHash() =>
    r'c32fcc6fb48b8a00fb9461ab3e30f3ec49440949';

final class EffectiveProxyGroupsFamily extends $Family
    with $FunctionalFamilyOverride<List<ProxyGroup>, int> {
  EffectiveProxyGroupsFamily._()
    : super(
        retry: null,
        name: r'effectiveProxyGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EffectiveProxyGroupsProvider call(int profileId) =>
      EffectiveProxyGroupsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'effectiveProxyGroupsProvider';
}

@ProviderFor(customOverwriteIssues)
final customOverwriteIssuesProvider = CustomOverwriteIssuesFamily._();

final class CustomOverwriteIssuesProvider
    extends
        $FunctionalProvider<
          CustomOverwriteIssues,
          CustomOverwriteIssues,
          CustomOverwriteIssues
        >
    with $Provider<CustomOverwriteIssues> {
  CustomOverwriteIssuesProvider._({
    required CustomOverwriteIssuesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteIssuesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customOverwriteIssuesHash();

  @override
  String toString() {
    return r'customOverwriteIssuesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<CustomOverwriteIssues> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CustomOverwriteIssues create(Ref ref) {
    final argument = this.argument as int;
    return customOverwriteIssues(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomOverwriteIssues value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomOverwriteIssues>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomOverwriteIssuesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteIssuesHash() =>
    r'4164bda37f54b37506c3e2d33c79d5330c23a5bf';

final class CustomOverwriteIssuesFamily extends $Family
    with $FunctionalFamilyOverride<CustomOverwriteIssues, int> {
  CustomOverwriteIssuesFamily._()
    : super(
        retry: null,
        name: r'customOverwriteIssuesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteIssuesProvider call(int profileId) =>
      CustomOverwriteIssuesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customOverwriteIssuesProvider';
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
    r'dd3abb63b3d68b22e7dd6158045f5404c291b52c';

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

@ProviderFor(delayTestPending)
final delayTestPendingProvider = DelayTestPendingFamily._();

final class DelayTestPendingProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  DelayTestPendingProvider._({
    required DelayTestPendingFamily super.from,
    required ({String proxyName, String? testUrl}) super.argument,
  }) : super(
         retry: null,
         name: r'delayTestPendingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$delayTestPendingHash();

  @override
  String toString() {
    return r'delayTestPendingProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as ({String proxyName, String? testUrl});
    return delayTestPending(
      ref,
      proxyName: argument.proxyName,
      testUrl: argument.testUrl,
    );
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
    return other is DelayTestPendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$delayTestPendingHash() => r'd48f9c6e03525b435bdd07167d0c256b297482d0';

final class DelayTestPendingFamily extends $Family
    with
        $FunctionalFamilyOverride<bool, ({String proxyName, String? testUrl})> {
  DelayTestPendingFamily._()
    : super(
        retry: null,
        name: r'delayTestPendingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DelayTestPendingProvider call({required String proxyName, String? testUrl}) =>
      DelayTestPendingProvider._(
        argument: (proxyName: proxyName, testUrl: testUrl),
        from: this,
      );

  @override
  String toString() => r'delayTestPendingProvider';
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
    r'448e513866ba1a5f9acfdd09f18249c9ac892e71';

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

@ProviderFor(overwriteType)
final overwriteTypeProvider = OverwriteTypeFamily._();

final class OverwriteTypeProvider
    extends $FunctionalProvider<OverwriteType, OverwriteType, OverwriteType>
    with $Provider<OverwriteType> {
  OverwriteTypeProvider._({
    required OverwriteTypeFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'overwriteTypeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$overwriteTypeHash();

  @override
  String toString() {
    return r'overwriteTypeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<OverwriteType> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OverwriteType create(Ref ref) {
    final argument = this.argument as int?;
    return overwriteType(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OverwriteType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OverwriteType>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OverwriteTypeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$overwriteTypeHash() => r'03a8ab8ddec76935da5fa231270b65baa70fd727';

final class OverwriteTypeFamily extends $Family
    with $FunctionalFamilyOverride<OverwriteType, int?> {
  OverwriteTypeFamily._()
    : super(
        retry: null,
        name: r'overwriteTypeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OverwriteTypeProvider call(int? profileId) =>
      OverwriteTypeProvider._(argument: profileId, from: this);

  @override
  String toString() => r'overwriteTypeProvider';
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

String _$clashConfigHash() => r'd984af6731ae56dbc1f517f683a40618cdfa5129';

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

String _$setupStateHash() => r'e01f18b82c6052eacfd8eba157f028f6ad469b91';

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

/// Every profile doubles as a proxy provider, so a group can pull one
/// subscription's nodes into another profile.

@ProviderFor(profileProviders)
final profileProvidersProvider = ProfileProvidersProvider._();

/// Every profile doubles as a proxy provider, so a group can pull one
/// subscription's nodes into another profile.

final class ProfileProvidersProvider
    extends
        $FunctionalProvider<
          Map<String, int>,
          Map<String, int>,
          Map<String, int>
        >
    with $Provider<Map<String, int>> {
  /// Every profile doubles as a proxy provider, so a group can pull one
  /// subscription's nodes into another profile.
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

String _$profileProvidersHash() => r'3e4b1f794192772bf37f599c1c42b3810cba71a0';

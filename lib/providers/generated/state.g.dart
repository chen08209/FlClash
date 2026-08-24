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

String _$updateParamsHash() => r'6f471ce2a4114291cc7dc725723911764c8c3cd9';

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

String _$trayStateHash() => r'235266f54cc130e924ee457216e1730f5a0e668a';

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

@ProviderFor(checkIp)
final checkIpProvider = CheckIpProvider._();

final class CheckIpProvider
    extends
        $FunctionalProvider<
          ({int checkIpNum, bool containsDetection, bool isInit}),
          ({int checkIpNum, bool containsDetection, bool isInit}),
          ({int checkIpNum, bool containsDetection, bool isInit})
        >
    with $Provider<({int checkIpNum, bool containsDetection, bool isInit})> {
  CheckIpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkIpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkIpHash();

  @$internal
  @override
  $ProviderElement<({int checkIpNum, bool containsDetection, bool isInit})>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ({int checkIpNum, bool containsDetection, bool isInit}) create(Ref ref) {
    return checkIp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    ({int checkIpNum, bool containsDetection, bool isInit}) value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            ({int checkIpNum, bool containsDetection, bool isInit})
          >(value),
    );
  }
}

String _$checkIpHash() => r'0e28032041d80297dcd12e8d659dbac741874073';

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
    r'73e86e60067acc55dd1cce0ea7f2d09899bbf119';

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

String _$sharedStateHash() => r'd2938b816f42721fe21be23e07542f7ab649c748';

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
    required (Brightness, {Color? color, bool ignoreConfig}) super.argument,
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
        this.argument as (Brightness, {Color? color, bool ignoreConfig});
    return genColorScheme(
      ref,
      argument.$1,
      color: argument.color,
      ignoreConfig: argument.ignoreConfig,
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

String _$genColorSchemeHash() => r'2b413948f7d0fbcd3b1263a0053c3d35cbbd4db5';

final class GenColorSchemeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          ColorScheme,
          (Brightness, {Color? color, bool ignoreConfig})
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
  }) => GenColorSchemeProvider._(
    argument: (brightness, color: color, ignoreConfig: ignoreConfig),
    from: this,
  );

  @override
  String toString() => r'genColorSchemeProvider';
}

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
    r'52b7eb3ac298486467443cd941fe993f22086f27';

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
    r'ec4d47b2ca9522a9b183380ebd3ee483d83a0da6';

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
    r'5b93515706b1c8edb078f10be4cbf8c7d73b54c1';

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

@ProviderFor(customOverwriteUseIsValid)
final customOverwriteUseIsValidProvider = CustomOverwriteUseIsValidFamily._();

final class CustomOverwriteUseIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomOverwriteUseIsValidProvider._({
    required CustomOverwriteUseIsValidFamily super.from,
    required (int, List<String>) super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteUseIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customOverwriteUseIsValidHash();

  @override
  String toString() {
    return r'customOverwriteUseIsValidProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (int, List<String>);
    return customOverwriteUseIsValid(ref, argument.$1, argument.$2);
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
    return other is CustomOverwriteUseIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteUseIsValidHash() =>
    r'a6daf410cbde076b58540b8484127c0cabc2b331';

final class CustomOverwriteUseIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, List<String>)> {
  CustomOverwriteUseIsValidFamily._()
    : super(
        retry: null,
        name: r'customOverwriteUseIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteUseIsValidProvider call(int profileId, List<String> use) =>
      CustomOverwriteUseIsValidProvider._(
        argument: (profileId, use),
        from: this,
      );

  @override
  String toString() => r'customOverwriteUseIsValidProvider';
}

@ProviderFor(customOverwriteProxiesIsValid)
final customOverwriteProxiesIsValidProvider =
    CustomOverwriteProxiesIsValidFamily._();

final class CustomOverwriteProxiesIsValidProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  CustomOverwriteProxiesIsValidProvider._({
    required CustomOverwriteProxiesIsValidFamily super.from,
    required (int, List<String>) super.argument,
  }) : super(
         retry: null,
         name: r'customOverwriteProxiesIsValidProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customOverwriteProxiesIsValidHash();

  @override
  String toString() {
    return r'customOverwriteProxiesIsValidProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as (int, List<String>);
    return customOverwriteProxiesIsValid(ref, argument.$1, argument.$2);
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
    return other is CustomOverwriteProxiesIsValidProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customOverwriteProxiesIsValidHash() =>
    r'856289220d963e12b5c62434ea80cf819b471cff';

final class CustomOverwriteProxiesIsValidFamily extends $Family
    with $FunctionalFamilyOverride<bool, (int, List<String>)> {
  CustomOverwriteProxiesIsValidFamily._()
    : super(
        retry: null,
        name: r'customOverwriteProxiesIsValidProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomOverwriteProxiesIsValidProvider call(
    int profileId,
    List<String> proxies,
  ) => CustomOverwriteProxiesIsValidProvider._(
    argument: (profileId, proxies),
    from: this,
  );

  @override
  String toString() => r'customOverwriteProxiesIsValidProvider';
}

@ProviderFor(invalidProxyGroupIds)
final invalidProxyGroupIdsProvider = InvalidProxyGroupIdsFamily._();

final class InvalidProxyGroupIdsProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  InvalidProxyGroupIdsProvider._({
    required InvalidProxyGroupIdsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'invalidProxyGroupIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$invalidProxyGroupIdsHash();

  @override
  String toString() {
    return r'invalidProxyGroupIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<int> create(Ref ref) {
    final argument = this.argument as int;
    return invalidProxyGroupIds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InvalidProxyGroupIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$invalidProxyGroupIdsHash() =>
    r'3a458a1a4f6b7c52d317f3c137114f8cf585a7e0';

final class InvalidProxyGroupIdsFamily extends $Family
    with $FunctionalFamilyOverride<Set<int>, int> {
  InvalidProxyGroupIdsFamily._()
    : super(
        retry: null,
        name: r'invalidProxyGroupIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InvalidProxyGroupIdsProvider call(int profileId) =>
      InvalidProxyGroupIdsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'invalidProxyGroupIdsProvider';
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
    r'dbf8f02606a31486c99d7b89d19914cd5a1fc496';

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

String _$filterGroupsStateHash() => r'7de7a4603ca5ed7c39a00351af43144eb6c21404';

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
    r'26326b400a0a2570188560a553ba8c600ad13b80';

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

String _$overlayTopOffsetHash() => r'b2462f67acbd88b7a881dfe4c6353e68ba49961d';

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

String _$clashConfigHash() => r'9cce2e682141f6d4588b2037f293611e78f80ff4';

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

String _$setupStateHash() => r'69e69aea042907d294d30f6fea1f3c31702272c4';

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

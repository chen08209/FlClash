// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../mitm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MitmCa)
final mitmCaProvider = MitmCaProvider._();

final class MitmCaProvider
    extends $AsyncNotifierProvider<MitmCa, MitmCertificate?> {
  MitmCaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmCaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmCaHash();

  @$internal
  @override
  MitmCa create() => MitmCa();
}

String _$mitmCaHash() => r'fbb31e73365ab11543816ccd768fd109f1243e1d';

abstract class _$MitmCa extends $AsyncNotifier<MitmCertificate?> {
  FutureOr<MitmCertificate?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MitmCertificate?>, MitmCertificate?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MitmCertificate?>, MitmCertificate?>,
              AsyncValue<MitmCertificate?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(mitmTrustStore)
final mitmTrustStoreProvider = MitmTrustStoreProvider._();

final class MitmTrustStoreProvider
    extends
        $FunctionalProvider<MitmTrustStore?, MitmTrustStore?, MitmTrustStore?>
    with $Provider<MitmTrustStore?> {
  MitmTrustStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmTrustStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmTrustStoreHash();

  @$internal
  @override
  $ProviderElement<MitmTrustStore?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MitmTrustStore? create(Ref ref) {
    return mitmTrustStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MitmTrustStore? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MitmTrustStore?>(value),
    );
  }
}

String _$mitmTrustStoreHash() => r'a078a332cb6f2c8fb0599287b2cc820f89c326b7';

/// Whether this device trusts the CA. A check records the CA it found
/// trusted, which is the one the Core decrypts HTTPS with.

@ProviderFor(MitmTrustState)
final mitmTrustStateProvider = MitmTrustStateProvider._();

/// Whether this device trusts the CA. A check records the CA it found
/// trusted, which is the one the Core decrypts HTTPS with.
final class MitmTrustStateProvider
    extends $AsyncNotifierProvider<MitmTrustState, MitmTrustCheck> {
  /// Whether this device trusts the CA. A check records the CA it found
  /// trusted, which is the one the Core decrypts HTTPS with.
  MitmTrustStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmTrustStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmTrustStateHash();

  @$internal
  @override
  MitmTrustState create() => MitmTrustState();
}

String _$mitmTrustStateHash() => r'9142caad5821ea1cbc3d5b32ebda377d43521538';

/// Whether this device trusts the CA. A check records the CA it found
/// trusted, which is the one the Core decrypts HTTPS with.

abstract class _$MitmTrustState extends $AsyncNotifier<MitmTrustCheck> {
  FutureOr<MitmTrustCheck> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MitmTrustCheck>, MitmTrustCheck>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MitmTrustCheck>, MitmTrustCheck>,
              AsyncValue<MitmTrustCheck>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Fetched again while shown, until the connection has closed and none of its
/// requests is pending.

@ProviderFor(mitmExchanges)
final mitmExchangesProvider = MitmExchangesFamily._();

/// Fetched again while shown, until the connection has closed and none of its
/// requests is pending.

final class MitmExchangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmExchangeList>,
          MitmExchangeList,
          FutureOr<MitmExchangeList>
        >
    with $FutureModifier<MitmExchangeList>, $FutureProvider<MitmExchangeList> {
  /// Fetched again while shown, until the connection has closed and none of its
  /// requests is pending.
  MitmExchangesProvider._({
    required MitmExchangesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'mitmExchangesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mitmExchangesHash();

  @override
  String toString() {
    return r'mitmExchangesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MitmExchangeList> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmExchangeList> create(Ref ref) {
    final argument = this.argument as int;
    return mitmExchanges(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MitmExchangesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mitmExchangesHash() => r'29d7ebbce5c3b52f39882628005b995c5e9bd737';

/// Fetched again while shown, until the connection has closed and none of its
/// requests is pending.

final class MitmExchangesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MitmExchangeList>, int> {
  MitmExchangesFamily._()
    : super(
        retry: null,
        name: r'mitmExchangesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetched again while shown, until the connection has closed and none of its
  /// requests is pending.

  MitmExchangesProvider call(int connectionId) =>
      MitmExchangesProvider._(argument: connectionId, from: this);

  @override
  String toString() => r'mitmExchangesProvider';
}

@ProviderFor(mitmExchange)
final mitmExchangeProvider = MitmExchangeFamily._();

final class MitmExchangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmExchange?>,
          MitmExchange?,
          FutureOr<MitmExchange?>
        >
    with $FutureModifier<MitmExchange?>, $FutureProvider<MitmExchange?> {
  MitmExchangeProvider._({
    required MitmExchangeFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'mitmExchangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mitmExchangeHash();

  @override
  String toString() {
    return r'mitmExchangeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MitmExchange?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmExchange?> create(Ref ref) {
    final argument = this.argument as int;
    return mitmExchange(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MitmExchangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mitmExchangeHash() => r'4db9f9893ab5587c0c3400e28200349900a5db90';

final class MitmExchangeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MitmExchange?>, int> {
  MitmExchangeFamily._()
    : super(
        retry: null,
        name: r'mitmExchangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MitmExchangeProvider call(int id) =>
      MitmExchangeProvider._(argument: id, from: this);

  @override
  String toString() => r'mitmExchangeProvider';
}

@ProviderFor(mitmBody)
final mitmBodyProvider = MitmBodyFamily._();

final class MitmBodyProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmBodyContent?>,
          MitmBodyContent?,
          FutureOr<MitmBodyContent?>
        >
    with $FutureModifier<MitmBodyContent?>, $FutureProvider<MitmBodyContent?> {
  MitmBodyProvider._({
    required MitmBodyFamily super.from,
    required (int, {bool response, String contentType}) super.argument,
  }) : super(
         retry: null,
         name: r'mitmBodyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mitmBodyHash();

  @override
  String toString() {
    return r'mitmBodyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<MitmBodyContent?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmBodyContent?> create(Ref ref) {
    final argument =
        this.argument as (int, {bool response, String contentType});
    return mitmBody(
      ref,
      argument.$1,
      response: argument.response,
      contentType: argument.contentType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MitmBodyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mitmBodyHash() => r'e64fd6edd90479902b345749f20febe1d47cd54a';

final class MitmBodyFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<MitmBodyContent?>,
          (int, {bool response, String contentType})
        > {
  MitmBodyFamily._()
    : super(
        retry: null,
        name: r'mitmBodyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MitmBodyProvider call(
    int id, {
    required bool response,
    required String contentType,
  }) => MitmBodyProvider._(
    argument: (id, response: response, contentType: contentType),
    from: this,
  );

  @override
  String toString() => r'mitmBodyProvider';
}

/// Whether the user was told, this run, what a copied or exported request
/// can carry.

@ProviderFor(MitmExportWarned)
final mitmExportWarnedProvider = MitmExportWarnedProvider._();

/// Whether the user was told, this run, what a copied or exported request
/// can carry.
final class MitmExportWarnedProvider
    extends $NotifierProvider<MitmExportWarned, bool> {
  /// Whether the user was told, this run, what a copied or exported request
  /// can carry.
  MitmExportWarnedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmExportWarnedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmExportWarnedHash();

  @$internal
  @override
  MitmExportWarned create() => MitmExportWarned();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$mitmExportWarnedHash() => r'ad55f9cc5bac8541affdf131a5c8e2969f5b55c6';

/// Whether the user was told, this run, what a copied or exported request
/// can carry.

abstract class _$MitmExportWarned extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(mitmModulesToAgree)
final mitmModulesToAgreeProvider = MitmModulesToAgreeProvider._();

final class MitmModulesToAgreeProvider
    extends
        $FunctionalProvider<
          List<MitmModule>,
          List<MitmModule>,
          List<MitmModule>
        >
    with $Provider<List<MitmModule>> {
  MitmModulesToAgreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmModulesToAgreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmModulesToAgreeHash();

  @$internal
  @override
  $ProviderElement<List<MitmModule>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<MitmModule> create(Ref ref) {
    return mitmModulesToAgree(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MitmModule> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MitmModule>>(value),
    );
  }
}

String _$mitmModulesToAgreeHash() =>
    r'b6472c1b0dca198af5710006b265ac11008a0ed7';

/// Why the Core skips each of the user's hostnames, by the line.

@ProviderFor(mitmHostnameIssues)
final mitmHostnameIssuesProvider = MitmHostnameIssuesProvider._();

/// Why the Core skips each of the user's hostnames, by the line.

final class MitmHostnameIssuesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          FutureOr<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $FutureProvider<Map<String, String>> {
  /// Why the Core skips each of the user's hostnames, by the line.
  MitmHostnameIssuesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmHostnameIssuesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmHostnameIssuesHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>> create(Ref ref) {
    return mitmHostnameIssues(ref);
  }
}

String _$mitmHostnameIssuesHash() =>
    r'4f0429d464e66bd530c499fc03f6951d0913a5f6';

/// A module that fails to read adds nothing, so the VPN can still start.

@ProviderFor(enabledMitmModules)
final enabledMitmModulesProvider = EnabledMitmModulesProvider._();

/// A module that fails to read adds nothing, so the VPN can still start.

final class EnabledMitmModulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({MitmModuleDetails details, MitmModule module})>>,
          List<({MitmModuleDetails details, MitmModule module})>,
          FutureOr<List<({MitmModuleDetails details, MitmModule module})>>
        >
    with
        $FutureModifier<List<({MitmModuleDetails details, MitmModule module})>>,
        $FutureProvider<
          List<({MitmModuleDetails details, MitmModule module})>
        > {
  /// A module that fails to read adds nothing, so the VPN can still start.
  EnabledMitmModulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enabledMitmModulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enabledMitmModulesHash();

  @$internal
  @override
  $FutureProviderElement<List<({MitmModuleDetails details, MitmModule module})>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({MitmModuleDetails details, MitmModule module})>> create(
    Ref ref,
  ) {
    return enabledMitmModules(ref);
  }
}

String _$enabledMitmModulesHash() =>
    r'c31ce98df5e7062f04108bcc2e7b19d09b05d5f5';

@ProviderFor(mitmModuleExits)
final mitmModuleExitsProvider = MitmModuleExitsProvider._();

final class MitmModuleExitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<String>>>,
          Map<String, List<String>>,
          FutureOr<Map<String, List<String>>>
        >
    with
        $FutureModifier<Map<String, List<String>>>,
        $FutureProvider<Map<String, List<String>>> {
  MitmModuleExitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmModuleExitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmModuleExitsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, List<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, List<String>>> create(Ref ref) {
    return mitmModuleExits(ref);
  }
}

String _$mitmModuleExitsHash() => r'4d61a4b5182e60c1fa6929246a575899a16f926f';

@ProviderFor(mitmModuleNetworkChanges)
final mitmModuleNetworkChangesProvider = MitmModuleNetworkChangesFamily._();

final class MitmModuleNetworkChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MitmNetworkChangeState>>,
          List<MitmNetworkChangeState>,
          FutureOr<List<MitmNetworkChangeState>>
        >
    with
        $FutureModifier<List<MitmNetworkChangeState>>,
        $FutureProvider<List<MitmNetworkChangeState>> {
  MitmModuleNetworkChangesProvider._({
    required MitmModuleNetworkChangesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'mitmModuleNetworkChangesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mitmModuleNetworkChangesHash();

  @override
  String toString() {
    return r'mitmModuleNetworkChangesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<MitmNetworkChangeState>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MitmNetworkChangeState>> create(Ref ref) {
    final argument = this.argument as int;
    return mitmModuleNetworkChanges(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MitmModuleNetworkChangesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mitmModuleNetworkChangesHash() =>
    r'654762b2ec4332bb158e7de2d408e393edd4a05b';

final class MitmModuleNetworkChangesFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<MitmNetworkChangeState>>, int> {
  MitmModuleNetworkChangesFamily._()
    : super(
        retry: null,
        name: r'mitmModuleNetworkChangesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MitmModuleNetworkChangesProvider call(int id) =>
      MitmModuleNetworkChangesProvider._(argument: id, from: this);

  @override
  String toString() => r'mitmModuleNetworkChangesProvider';
}

/// The module that last replaces each setting, for the setting's own page to
/// name; a module that only adds to a list leaves it the user's.

@ProviderFor(mitmTakeover)
final mitmTakeoverProvider = MitmTakeoverProvider._();

/// The module that last replaces each setting, for the setting's own page to
/// name; a module that only adds to a list leaves it the user's.

final class MitmTakeoverProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmTakeover>,
          MitmTakeover,
          FutureOr<MitmTakeover>
        >
    with $FutureModifier<MitmTakeover>, $FutureProvider<MitmTakeover> {
  /// The module that last replaces each setting, for the setting's own page to
  /// name; a module that only adds to a list leaves it the user's.
  MitmTakeoverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmTakeoverProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmTakeoverHash();

  @$internal
  @override
  $FutureProviderElement<MitmTakeover> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmTakeover> create(Ref ref) {
    return mitmTakeover(ref);
  }
}

String _$mitmTakeoverHash() => r'65f83338f5494bced3308743e28277161f7a1464';

@ProviderFor(mitmModuleNetwork)
final mitmModuleNetworkProvider = MitmModuleNetworkProvider._();

final class MitmModuleNetworkProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmNetwork>,
          MitmNetwork,
          FutureOr<MitmNetwork>
        >
    with $FutureModifier<MitmNetwork>, $FutureProvider<MitmNetwork> {
  MitmModuleNetworkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmModuleNetworkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmModuleNetworkHash();

  @$internal
  @override
  $FutureProviderElement<MitmNetwork> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmNetwork> create(Ref ref) {
    return mitmModuleNetwork(ref);
  }
}

String _$mitmModuleNetworkHash() => r'6570112fcf67889f9233758d80f014ae4eb2af07';

/// The modules in force by the names the profile gives them.

@ProviderFor(mitmModuleStatus)
final mitmModuleStatusProvider = MitmModuleStatusProvider._();

/// The modules in force by the names the profile gives them.

final class MitmModuleStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, MitmModuleStatus>>,
          Map<String, MitmModuleStatus>,
          FutureOr<Map<String, MitmModuleStatus>>
        >
    with
        $FutureModifier<Map<String, MitmModuleStatus>>,
        $FutureProvider<Map<String, MitmModuleStatus>> {
  /// The modules in force by the names the profile gives them.
  MitmModuleStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mitmModuleStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mitmModuleStatusHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, MitmModuleStatus>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, MitmModuleStatus>> create(Ref ref) {
    return mitmModuleStatus(ref);
  }
}

String _$mitmModuleStatusHash() => r'4b75d9de6976e99581aa478141e28d8cc2bf359e';

/// Null while the module's file is not on disk. A file that fails to read
/// fails again until it or the module changes, which rebuilds this anyway.

@ProviderFor(mitmModuleContent)
final mitmModuleContentProvider = MitmModuleContentFamily._();

/// Null while the module's file is not on disk. A file that fails to read
/// fails again until it or the module changes, which rebuilds this anyway.

final class MitmModuleContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmModuleDetails?>,
          MitmModuleDetails?,
          FutureOr<MitmModuleDetails?>
        >
    with
        $FutureModifier<MitmModuleDetails?>,
        $FutureProvider<MitmModuleDetails?> {
  /// Null while the module's file is not on disk. A file that fails to read
  /// fails again until it or the module changes, which rebuilds this anyway.
  MitmModuleContentProvider._({
    required MitmModuleContentFamily super.from,
    required int super.argument,
  }) : super(
         retry: _noRetry,
         name: r'mitmModuleContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mitmModuleContentHash();

  @override
  String toString() {
    return r'mitmModuleContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MitmModuleDetails?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmModuleDetails?> create(Ref ref) {
    final argument = this.argument as int;
    return mitmModuleContent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MitmModuleContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mitmModuleContentHash() => r'f563b3d246dc2518ee94dd867c75dbd9546b0f0b';

/// Null while the module's file is not on disk. A file that fails to read
/// fails again until it or the module changes, which rebuilds this anyway.

final class MitmModuleContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MitmModuleDetails?>, int> {
  MitmModuleContentFamily._()
    : super(
        retry: _noRetry,
        name: r'mitmModuleContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Null while the module's file is not on disk. A file that fails to read
  /// fails again until it or the module changes, which rebuilds this anyway.

  MitmModuleContentProvider call(int id) =>
      MitmModuleContentProvider._(argument: id, from: this);

  @override
  String toString() => r'mitmModuleContentProvider';
}

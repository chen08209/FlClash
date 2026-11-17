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

String _$mitmCaHash() => r'a3c0701e935a4b1949cca7baa07b0860cc814ba6';

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

String _$mitmTrustStateHash() => r'351876d39d532eb12a986d7b9dfb8052eb65f1d1';

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
    required String super.argument,
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
    final argument = this.argument as String;
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

String _$mitmExchangesHash() => r'66e3981eecc1c4b45126a90d061ffe75e3c01585';

/// Fetched again while shown, until the connection has closed and none of its
/// requests is pending.

final class MitmExchangesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MitmExchangeList>, String> {
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

  MitmExchangesProvider call(String connectionId) =>
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

String _$mitmExchangeHash() => r'f7b026828659fb4e9ccdc7ccc8fc3e02f45f7042';

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

String _$mitmBodyHash() => r'bf38c11bea05417c720bfb6e04ef8fc39a9275cc';

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
          AsyncValue<List<({MitmModuleContent content, String name})>>,
          List<({MitmModuleContent content, String name})>,
          FutureOr<List<({MitmModuleContent content, String name})>>
        >
    with
        $FutureModifier<List<({MitmModuleContent content, String name})>>,
        $FutureProvider<List<({MitmModuleContent content, String name})>> {
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
  $FutureProviderElement<List<({MitmModuleContent content, String name})>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({MitmModuleContent content, String name})>> create(Ref ref) {
    return enabledMitmModules(ref);
  }
}

String _$enabledMitmModulesHash() =>
    r'5b135136f70420c16aba461ebd1dc05e8cc7ad9f';

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

String _$mitmModuleExitsHash() => r'caa3ac4da1572dd187bf49adb7658d835c3c6d3f';

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
    r'7e61482361d5042964f37e52ac82351a1ca94839';

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

String _$mitmTakeoverHash() => r'73bf5048a5aec25697b69b4af7c32dc9907edd60';

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

String _$mitmModuleNetworkHash() => r'63683164275d7be63ff680d0dfdcc0119546b523';

/// Null while the module's content is not on disk.

@ProviderFor(mitmModuleDetails)
final mitmModuleDetailsProvider = MitmModuleDetailsFamily._();

/// Null while the module's content is not on disk.

final class MitmModuleDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmModuleDetails?>,
          MitmModuleDetails?,
          FutureOr<MitmModuleDetails?>
        >
    with
        $FutureModifier<MitmModuleDetails?>,
        $FutureProvider<MitmModuleDetails?> {
  /// Null while the module's content is not on disk.
  MitmModuleDetailsProvider._({
    required MitmModuleDetailsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'mitmModuleDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mitmModuleDetailsHash();

  @override
  String toString() {
    return r'mitmModuleDetailsProvider'
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
    return mitmModuleDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MitmModuleDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mitmModuleDetailsHash() => r'f11c973cbb43a0e9ad3eb71f731a6e7f908d9ab7';

/// Null while the module's content is not on disk.

final class MitmModuleDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MitmModuleDetails?>, int> {
  MitmModuleDetailsFamily._()
    : super(
        retry: null,
        name: r'mitmModuleDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Null while the module's content is not on disk.

  MitmModuleDetailsProvider call(int id) =>
      MitmModuleDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'mitmModuleDetailsProvider';
}

/// A file that fails to parse fails again until it changes, which rebuilds
/// this anyway.

@ProviderFor(mitmModuleContent)
final mitmModuleContentProvider = MitmModuleContentFamily._();

/// A file that fails to parse fails again until it changes, which rebuilds
/// this anyway.

final class MitmModuleContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<MitmModuleContent?>,
          MitmModuleContent?,
          FutureOr<MitmModuleContent?>
        >
    with
        $FutureModifier<MitmModuleContent?>,
        $FutureProvider<MitmModuleContent?> {
  /// A file that fails to parse fails again until it changes, which rebuilds
  /// this anyway.
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
  $FutureProviderElement<MitmModuleContent?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MitmModuleContent?> create(Ref ref) {
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

String _$mitmModuleContentHash() => r'8d05136558342f475dec4642a78405585a471968';

/// A file that fails to parse fails again until it changes, which rebuilds
/// this anyway.

final class MitmModuleContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MitmModuleContent?>, int> {
  MitmModuleContentFamily._()
    : super(
        retry: _noRetry,
        name: r'mitmModuleContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A file that fails to parse fails again until it changes, which rebuilds
  /// this anyway.

  MitmModuleContentProvider call(int id) =>
      MitmModuleContentProvider._(argument: id, from: this);

  @override
  String toString() => r'mitmModuleContentProvider';
}

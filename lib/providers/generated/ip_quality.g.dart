// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ip_quality.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ipQualityFailureCooldown)
final ipQualityFailureCooldownProvider = IpQualityFailureCooldownProvider._();

final class IpQualityFailureCooldownProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  IpQualityFailureCooldownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ipQualityFailureCooldownProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ipQualityFailureCooldownHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return ipQualityFailureCooldown(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$ipQualityFailureCooldownHash() =>
    r'173ce54985dc17ba4d9118d84b8a22fd0fa49f24';

@ProviderFor(ipQualityMaxAge)
final ipQualityMaxAgeProvider = IpQualityMaxAgeProvider._();

final class IpQualityMaxAgeProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  IpQualityMaxAgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ipQualityMaxAgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ipQualityMaxAgeHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return ipQualityMaxAge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$ipQualityMaxAgeHash() => r'74aa9def150c9c1955f8c09d6eec1e9038754551';

/// Invalidating skips the stored record and asks the sources again.

@ProviderFor(ipQuality)
final ipQualityProvider = IpQualityFamily._();

/// Invalidating skips the stored record and asks the sources again.

final class IpQualityProvider
    extends
        $FunctionalProvider<
          AsyncValue<IpQuality>,
          IpQuality,
          FutureOr<IpQuality>
        >
    with $FutureModifier<IpQuality>, $FutureProvider<IpQuality> {
  /// Invalidating skips the stored record and asks the sources again.
  IpQualityProvider._({
    required IpQualityFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'ipQualityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ipQualityHash();

  @override
  String toString() {
    return r'ipQualityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<IpQuality> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<IpQuality> create(Ref ref) {
    final argument = this.argument as String;
    return ipQuality(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IpQualityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ipQualityHash() => r'120254d66bea59cae892cd3dcc86ad651c22b3c2';

/// Invalidating skips the stored record and asks the sources again.

final class IpQualityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<IpQuality>, String> {
  IpQualityFamily._()
    : super(
        retry: _noRetry,
        name: r'ipQualityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Invalidating skips the stored record and asks the sources again.

  IpQualityProvider call(String ip) =>
      IpQualityProvider._(argument: ip, from: this);

  @override
  String toString() => r'ipQualityProvider';
}

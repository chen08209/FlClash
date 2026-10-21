// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../service_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceStatus)
final serviceStatusProvider = ServiceStatusProvider._();

final class ServiceStatusProvider
    extends
        $NotifierProvider<
          ServiceStatus,
          RoutedProbeState<ServiceTarget, ServiceCheck>
        > {
  ServiceStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceStatusHash();

  @$internal
  @override
  ServiceStatus create() => ServiceStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    RoutedProbeState<ServiceTarget, ServiceCheck> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<RoutedProbeState<ServiceTarget, ServiceCheck>>(
            value,
          ),
    );
  }
}

String _$serviceStatusHash() => r'e2c34347423e8589bd1657cd6a37acc5ae6ac76e';

abstract class _$ServiceStatus
    extends $Notifier<RoutedProbeState<ServiceTarget, ServiceCheck>> {
  RoutedProbeState<ServiceTarget, ServiceCheck> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              RoutedProbeState<ServiceTarget, ServiceCheck>,
              RoutedProbeState<ServiceTarget, ServiceCheck>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                RoutedProbeState<ServiceTarget, ServiceCheck>,
                RoutedProbeState<ServiceTarget, ServiceCheck>
              >,
              RoutedProbeState<ServiceTarget, ServiceCheck>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How many of [enabledServiceTargets] the dashboard card has room for, which
/// its sheet marks as shown there.

@ProviderFor(ShownServiceCount)
final shownServiceCountProvider = ShownServiceCountProvider._();

/// How many of [enabledServiceTargets] the dashboard card has room for, which
/// its sheet marks as shown there.
final class ShownServiceCountProvider
    extends $NotifierProvider<ShownServiceCount, int> {
  /// How many of [enabledServiceTargets] the dashboard card has room for, which
  /// its sheet marks as shown there.
  ShownServiceCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shownServiceCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shownServiceCountHash();

  @$internal
  @override
  ShownServiceCount create() => ShownServiceCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$shownServiceCountHash() => r'5ed23369fc7ba6ce8d809f06ff026cdbe60f5233';

/// How many of [enabledServiceTargets] the dashboard card has room for, which
/// its sheet marks as shown there.

abstract class _$ShownServiceCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(serviceTargets)
final serviceTargetsProvider = ServiceTargetsProvider._();

final class ServiceTargetsProvider
    extends
        $FunctionalProvider<
          List<ServiceTarget>,
          List<ServiceTarget>,
          List<ServiceTarget>
        >
    with $Provider<List<ServiceTarget>> {
  ServiceTargetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceTargetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceTargetsHash();

  @$internal
  @override
  $ProviderElement<List<ServiceTarget>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ServiceTarget> create(Ref ref) {
    return serviceTargets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ServiceTarget> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ServiceTarget>>(value),
    );
  }
}

String _$serviceTargetsHash() => r'f1c9ae92b6d0c5b7fcf72c90571ff1c67f7ca66e';

@ProviderFor(enabledServiceTargets)
final enabledServiceTargetsProvider = EnabledServiceTargetsProvider._();

final class EnabledServiceTargetsProvider
    extends
        $FunctionalProvider<
          List<ServiceTarget>,
          List<ServiceTarget>,
          List<ServiceTarget>
        >
    with $Provider<List<ServiceTarget>> {
  EnabledServiceTargetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enabledServiceTargetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enabledServiceTargetsHash();

  @$internal
  @override
  $ProviderElement<List<ServiceTarget>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ServiceTarget> create(Ref ref) {
    return enabledServiceTargets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ServiceTarget> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ServiceTarget>>(value),
    );
  }
}

String _$enabledServiceTargetsHash() =>
    r'7c5f5b6879ea73bd726ec9271b792a7c7b4b6528';

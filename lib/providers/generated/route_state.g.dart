// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../route_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RouteTracker)
final routeTrackerProvider = RouteTrackerProvider._();

final class RouteTrackerProvider
    extends $NotifierProvider<RouteTracker, RouteState> {
  RouteTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routeTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routeTrackerHash();

  @$internal
  @override
  RouteTracker create() => RouteTracker();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouteState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouteState>(value),
    );
  }
}

String _$routeTrackerHash() => r'928841c46e14c0aad4e9d4367a70b5809be32ed6';

abstract class _$RouteTracker extends $Notifier<RouteState> {
  RouteState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RouteState, RouteState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RouteState, RouteState>,
              RouteState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

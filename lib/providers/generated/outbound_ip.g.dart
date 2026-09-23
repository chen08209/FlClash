// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../outbound_ip.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keyed by the outbound a lookup pins: a node name, `DIRECT`, or
/// [routedOutbound] for whatever the rules pick right now.

@ProviderFor(OutboundIpProbe)
final outboundIpProbeProvider = OutboundIpProbeProvider._();

/// Keyed by the outbound a lookup pins: a node name, `DIRECT`, or
/// [routedOutbound] for whatever the rules pick right now.
final class OutboundIpProbeProvider
    extends
        $NotifierProvider<OutboundIpProbe, RoutedProbeState<String, IpInfo>> {
  /// Keyed by the outbound a lookup pins: a node name, `DIRECT`, or
  /// [routedOutbound] for whatever the rules pick right now.
  OutboundIpProbeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboundIpProbeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboundIpProbeHash();

  @$internal
  @override
  OutboundIpProbe create() => OutboundIpProbe();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutedProbeState<String, IpInfo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutedProbeState<String, IpInfo>>(
        value,
      ),
    );
  }
}

String _$outboundIpProbeHash() => r'c75ca61c03e296b1eb5a3fd5dc9bbee1801852f1';

/// Keyed by the outbound a lookup pins: a node name, `DIRECT`, or
/// [routedOutbound] for whatever the rules pick right now.

abstract class _$OutboundIpProbe
    extends $Notifier<RoutedProbeState<String, IpInfo>> {
  RoutedProbeState<String, IpInfo> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              RoutedProbeState<String, IpInfo>,
              RoutedProbeState<String, IpInfo>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                RoutedProbeState<String, IpInfo>,
                RoutedProbeState<String, IpInfo>
              >,
              RoutedProbeState<String, IpInfo>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

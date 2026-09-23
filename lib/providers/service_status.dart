import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'config.dart';
import 'core.dart';
import 'route_state.dart';
import 'routed_probe.dart';

part 'generated/service_status.g.dart';

@Riverpod(keepAlive: true)
class ServiceStatus extends _$ServiceStatus
    with RoutedProbe<ServiceTarget, ServiceCheck> {
  @override
  RoutedProbeState<ServiceTarget, ServiceCheck> build() => buildProbe();

  @override
  bool get batched => true;

  @override
  bool isFailure(ServiceCheck value) =>
      value.status == ServiceProbeStatus.timeout ||
      value.status == ServiceProbeStatus.failed;

  @override
  Future<Map<ServiceTarget, ProbeAnswer<ServiceCheck>>> probe(
    List<ServiceTarget> targets,
    RouteState route,
  ) async {
    final checks = await checkServices(
      ref.read(coreHandlerProvider),
      proxyName: route.proxied ? '' : directOutbound,
      targets: targets,
    );
    return {
      for (final MapEntry(key: target, value: check) in checks.entries)
        target: ProbeAnswer(
          value: check,
          coreEpoch: check.coreEpoch,
          picksVersion: check.picksVersion,
          chains: check.chains,
        ),
    };
  }
}

@riverpod
List<ServiceTarget> serviceTargets(Ref ref) {
  final order = ref.watch(
    appSettingProvider.select((state) => SelectValue(state.serviceOrder)),
  );
  return orderServiceTargets(order.value);
}

@riverpod
List<ServiceTarget> enabledServiceTargets(Ref ref) {
  final targets = ref.watch(serviceTargetsProvider);
  final disabled = ref.watch(
    appSettingProvider.select((state) => SelectValue(state.disabledServices)),
  );
  final enabled = [
    for (final target in targets)
      if (!disabled.value.contains(target.id)) target,
  ];
  return enabled.isEmpty ? targets : enabled;
}

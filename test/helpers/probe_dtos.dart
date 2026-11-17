import 'package:fl_clash/core/core.dart';
import 'package:mocktail/mocktail.dart';

import 'core_mocks.dart';

typedef ServiceSweep = ({String proxy, List<String> names, int timeout});

typedef OutboundAsk = ({String proxy, List<String> urls, int timeout});

ServiceItem serviceItem(
  String name, {
  String status = 'available',
  String region = '',
  String ip = '',
  int delay = 0,
  List<String> chains = const [],
  int checkedAt = 0,
  int epoch = 1,
  int version = 1,
  List<RouteHitDto> hits = const [],
}) => ServiceItem(
  name: name,
  status: status,
  region: region,
  ip: ip,
  delay: delay,
  chains: chains,
  checkedAt: checkedAt,
  stamp: RouteStampDto(epoch: epoch, version: version),
  hits: hits,
);

OutboundIp outboundIpOf({
  String url = '',
  String body = '',
  int delay = 0,
  List<String> chains = const [],
  String? error,
  int epoch = 1,
  int version = 1,
  List<RouteHitDto> hits = const [],
  List<RouteHitDto> nodeHits = const [],
}) => OutboundIp(
  url: url,
  body: body,
  delay: delay,
  chains: chains,
  error: error,
  stamp: RouteStampDto(epoch: epoch, version: version),
  hits: hits,
  nodeHits: nodeHits,
);

void stubCheckServices(
  MockCoreApi api,
  Future<List<ServiceItem>> Function(ServiceSweep sweep) answer,
) {
  when(
    () => api.checkServices(
      any(),
      any(),
      timeout: any(named: 'timeout'),
      guard: any(named: 'guard'),
    ),
  ).thenAnswer((invocation) {
    return answer((
      proxy: invocation.positionalArguments[0] as String,
      names: invocation.positionalArguments[1] as List<String>,
      timeout: invocation.namedArguments[#timeout] as int,
    ));
  });
}

void stubOutboundIp(
  MockCoreApi api,
  Future<OutboundIp> Function(OutboundAsk ask) answer,
) {
  when(
    () => api.outboundIp(
      any(),
      any(),
      timeout: any(named: 'timeout'),
      guard: any(named: 'guard'),
    ),
  ).thenAnswer((invocation) {
    return answer((
      proxy: invocation.positionalArguments[0] as String,
      urls: invocation.positionalArguments[1] as List<String>,
      timeout: invocation.namedArguments[#timeout] as int,
    ));
  });
}

VerificationResult verifyOutboundIp(MockCoreApi api) => verify(
  () => api.outboundIp(
    any(),
    any(),
    timeout: any(named: 'timeout'),
    guard: any(named: 'guard'),
  ),
);

VerificationResult verifyCheckServices(MockCoreApi api) => verify(
  () => api.checkServices(
    any(),
    any(),
    timeout: any(named: 'timeout'),
    guard: any(named: 'guard'),
  ),
);

void verifyNeverCheckServices(MockCoreApi api) => verifyNever(
  () => api.checkServices(
    any(),
    any(),
    timeout: any(named: 'timeout'),
    guard: any(named: 'guard'),
  ),
);

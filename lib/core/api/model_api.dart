import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

import 'core_api.dart';
import 'mapping.dart';

/// [CoreApi] answers in wire types; these read them as the app's models.
extension ModelApi on CoreApi {
  Future<CoreCapabilities> getCapabilities() async =>
      capabilitiesOf(await capabilities());

  Future<CoreMemoryStats> getMemoryStats() async => memoryOf(await stats());

  Future<List<ExternalProvider>> getExternalProviders() async => [
    for (final info in await providers()) providerOf(info),
  ];

  Future<ExternalProvider?> getExternalProvider(String name) async {
    final info = await provider(name);
    return info == null ? null : providerOf(info);
  }

  Future<RuleSetInfo> compileRules(String name, {String? url}) async {
    final info = await compileRuleSet(name, url: url);
    return (
      behavior: RuleProviderBehavior.values.byName(info.behavior),
      format: RuleProviderFormat.values.byName(info.format),
    );
  }

  Future<String> dumpRules(String profilePath) async =>
      (await dumpRuleSet(profilePath)).text ?? '';

  Future<OutboundIpResult> probeOutboundIp(
    OutboundIpParams params, {
    Duration? guard,
  }) async => outboundIpResultOf(
    await outboundIp(
      params.proxyName,
      params.urls,
      timeout: params.timeout,
      guard: guard,
    ),
  );

  Future<List<ServiceCheckItem>> probeServices(
    ServiceCheckParams params, {
    Duration? guard,
  }) async => [
    for (final item in await checkServices(
      params.proxyName,
      params.names,
      timeout: params.timeout,
      guard: guard,
    ))
      serviceCheckItemOf(item),
  ];

  Future<MitmCertificate?> getMitmCertificate() async {
    final certificate = await mitmCertificate();
    return certificate == null ? null : MitmCertificate.fromJson(certificate);
  }

  Future<MitmCertificate> createMitmCertificate() async =>
      MitmCertificate.fromJson(await generateMitmCertificate());

  Future<Map<MitmList, Map<int, String>>> checkMitmRules(
    MitmRules rules,
  ) async {
    final lists = await validateMitm(rules.toJson());
    return {
      for (final list in MitmList.values)
        if (lists[list.key] case final List issues)
          list: {
            for (final item in issues)
              if (item case {
                'index': final num index,
                'message': final String message,
              })
                index.toInt(): message,
          },
    };
  }

  Future<MitmExchangeList> getMitmExchanges(int connectionId) async =>
      MitmExchangeList.fromJson(
        Map<String, Object?>.from(await mitmExchanges(connectionId) as Map),
      );

  /// Null once the Core no longer keeps the request.
  Future<MitmExchange?> getMitmExchange(int id) async {
    final exchange = await mitmExchange(id);
    return exchange is Map
        ? MitmExchange.fromJson(Map<String, Object?>.from(exchange))
        : null;
  }

  /// Null once the Core no longer keeps the request.
  Future<MitmBody?> getMitmBody(int id, {required bool response}) async {
    final body = await mitmBody(id, response: response);
    return body is Map
        ? MitmBody.fromJson(Map<String, Object?>.from(body))
        : null;
  }

  /// The Core holds the run to the script's own timeout, up to an hour.
  Future<MitmScriptOutput> runMitmModule(String name) async =>
      MitmScriptOutput.fromJson(
        Map<String, Object?>.from(
          await runMitmScript(name, guard: const Duration(hours: 1, minutes: 1))
              as Map,
        ),
      );
}

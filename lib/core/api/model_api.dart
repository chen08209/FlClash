import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

import 'core_api.dart';
import 'dto.dart';
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

  Future<RuleTable> getRules() async => RuleTable.fromJson(await ruleList());

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

  Future<MitmCheck> checkMitmRules(MitmRules rules) async =>
      mitmCheckOf(await validateMitm(rules.toJson()));

  Future<({MitmModuleRead read, MitmCheck check})> getMitmModuleRead(
    String text, {
    Map<String, String> arguments = const {},
    Map<String, String> attachments = const {},
    String language = '',
  }) async {
    final read = MitmModuleRead.fromJson(
      await readMitmModule(
        text,
        arguments: arguments,
        attachments: attachments,
        language: language,
      ),
    );
    return (
      read: read,
      check: mitmCheckOf({'issues': read.issues, 'views': read.views}),
    );
  }

  Future<List<MitmModuleStatus>> getMitmModuleStatus() async {
    final status = await mitmModuleStatus();
    return [
      for (final module in status['modules'] as List? ?? const [])
        MitmModuleStatus.fromJson(Map<String, Object?>.from(module as Map)),
    ];
  }

  static MitmCheck mitmCheckOf(Map<String, Object?> result) {
    Map<MitmList, Map<int, T>> byLine<T>(
      Object? lists,
      T? Function(Map item) valueOf,
    ) => {
      if (lists is Map)
        for (final list in MitmList.values)
          if (lists[list.key] case final List items)
            list: {
              for (final item in items)
                if (item case {'index': final num index})
                  index.toInt(): ?valueOf(item),
            },
    };
    return (
      issues: byLine(
        result['issues'],
        (item) => switch (item['message']) {
          final String message => message,
          _ => null,
        },
      ),
      views: byLine(result['views'], (item) => _lineView(item['view'])),
    );
  }

  /// Null for a kind of line this build does not know.
  static MitmLineView? _lineView(Object? json) {
    if (json is! Map) {
      return null;
    }
    try {
      return MitmLineView.fromJson(Map<String, Object?>.from(json));
    } on Object {
      return null;
    }
  }

  Future<MitmExchangeList> getMitmExchanges(int connectionId) async =>
      MitmExchangeList.fromJson(
        Map<String, Object?>.from(await mitmExchanges(connectionId) as Map),
      );

  Future<MitmQueryPage> queryMitmExchanges({
    int? before,
    int? since,
    required int limit,
  }) async => mitmQueryPageOf(
    await mitmQuery(before: before, since: since, limit: limit),
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

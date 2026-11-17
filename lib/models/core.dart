import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/core.freezed.dart';
part 'generated/core.g.dart';

@freezed
abstract class SetupParams with _$SetupParams {
  const factory SetupParams({
    @JsonKey(includeToJson: false, includeFromJson: false) SetupBase? base,
    @JsonKey(name: 'selection') required Map<String, String> selectedMap,
    required CoreOptions options,
  }) = _SetupParams;

  factory SetupParams.fromJson(Map<String, dynamic> json) =>
      _$SetupParamsFromJson(json);
}

@freezed
abstract class CoreOptions with _$CoreOptions {
  const factory CoreOptions({
    required String testUrl,
    @Default(false) bool skipCertVerify,
    @Default(defaultDelayTestTimeout) int delayTestTimeout,
    @Default(false) bool mitmCapture,
  }) = _CoreOptions;

  factory CoreOptions.fromJson(Map<String, Object?> json) =>
      _$CoreOptionsFromJson(json);
}

@freezed
abstract class SetupBase with _$SetupBase {
  const factory SetupBase({
    required String path,
    required Map<String, dynamic> overlay,
  }) = _SetupBase;
}

@freezed
abstract class ProfileBase with _$ProfileBase {
  const factory ProfileBase({
    required Map<String, dynamic> config,
    required String digest,
    @Default([]) List<String> matchRules,
    @Default(0) int proxies,
    @Default(0) int proxyGroups,
    @Default(0) int rules,
  }) = _ProfileBase;

  factory ProfileBase.fromJson(Map<String, dynamic> json) =>
      _$ProfileBaseFromJson(json);
}

/// The CA the Core signs decrypted hosts' certificates with.
@freezed
abstract class MitmCertificate with _$MitmCertificate {
  const factory MitmCertificate({
    required String pem,
    required String fingerprint,
    required String subject,
    @JsonKey(name: 'not-before') required DateTime notBefore,
    @JsonKey(name: 'not-after') required DateTime notAfter,
  }) = _MitmCertificate;

  factory MitmCertificate.fromJson(Map<String, Object?> json) =>
      _$MitmCertificateFromJson(json);
}

@freezed
abstract class MitmScriptOutput with _$MitmScriptOutput {
  const factory MitmScriptOutput({
    @Default([]) List<String> logs,
    @Default('') String result,
    @Default('') String error,
  }) = _MitmScriptOutput;

  factory MitmScriptOutput.fromJson(Map<String, Object?> json) =>
      _$MitmScriptOutputFromJson(json);
}

typedef MitmCheck = ({
  Map<MitmList, Map<int, String>> issues,
  Map<MitmList, Map<int, MitmLineView>> views,
});

/// A MITM line as the Core reads it, from the same parse that applies it.
@Freezed(unionKey: 'type')
sealed class MitmLineView with _$MitmLineView {
  const factory MitmLineView.urlRewrite({
    required String pattern,
    required String action,
    String? replacement,
    String? requestHead,
  }) = MitmUrlRewriteView;

  const factory MitmLineView.headerRewrite({
    required String phase,
    required String pattern,
    String? requestHead,
    String? responseHead,
    required String action,
    String? name,
    String? value,
    String? regex,
    String? replacement,
  }) = MitmHeaderRewriteView;

  const factory MitmLineView.bodyRewrite({
    required String phase,
    required String pattern,
    String? requestHead,
    String? responseHead,
    @Default([]) List<MitmBodyReplacement> replacements,
    String? jq,
  }) = MitmBodyRewriteView;

  const factory MitmLineView.mapLocal({
    required String pattern,
    String? requestHead,
    required String dataType,
    @Default('') String data,
    int? status,
  }) = MitmMapLocalView;

  const factory MitmLineView.script({
    required String name,
    required String kind,
    String? pattern,
    String? cronexp,
    String? event,
  }) = MitmScriptView;

  const factory MitmLineView.hosts({@Default([]) List<MitmHostEntry> entries}) =
      MitmHostsView;

  const factory MitmLineView.sources({
    @Default([]) List<MitmSourceEntry> entries,
  }) = MitmSourcesView;

  factory MitmLineView.fromJson(Map<String, Object?> json) =>
      _$MitmLineViewFromJson(json);
}

@freezed
abstract class MitmBodyReplacement with _$MitmBodyReplacement {
  const factory MitmBodyReplacement({
    required String regex,
    required String replacement,
  }) = _MitmBodyReplacement;

  factory MitmBodyReplacement.fromJson(Map<String, Object?> json) =>
      _$MitmBodyReplacementFromJson(json);
}

@freezed
abstract class MitmHostEntry with _$MitmHostEntry {
  const factory MitmHostEntry({
    required String host,
    int? port,
    @Default(false) bool exclude,
  }) = _MitmHostEntry;

  factory MitmHostEntry.fromJson(Map<String, Object?> json) =>
      _$MitmHostEntryFromJson(json);
}

@freezed
abstract class MitmSourceEntry with _$MitmSourceEntry {
  const factory MitmSourceEntry({
    required String network,
    @Default(false) bool exclude,
  }) = _MitmSourceEntry;

  factory MitmSourceEntry.fromJson(Map<String, Object?> json) =>
      _$MitmSourceEntryFromJson(json);
}

/// Times are in milliseconds, sizes those of the client's bodies.
@freezed
abstract class MitmExchangeSummary with _$MitmExchangeSummary {
  const factory MitmExchangeSummary({
    required int id,
    required DateTime start,
    @Default(false) bool pending,
    @Default(0) int duration,
    @Default('') String method,
    @Default('') String url,
    @Default(0) int status,
    @Default(0) @JsonKey(name: 'request-size') int requestSize,
    @Default(0) @JsonKey(name: 'response-size') int responseSize,
    @Default('') String error,
  }) = _MitmExchangeSummary;

  factory MitmExchangeSummary.fromJson(Map<String, Object?> json) =>
      _$MitmExchangeSummaryFromJson(json);
}

/// Every request that started after [since] is still kept.
@freezed
abstract class MitmExchangeList with _$MitmExchangeList {
  const factory MitmExchangeList({
    @Default(false) bool capturing,
    DateTime? since,
    @Default([]) List<MitmExchangeSummary> exchanges,
    @Default(false) bool closed,
  }) = _MitmExchangeList;

  factory MitmExchangeList.fromJson(Map<String, Object?> json) =>
      _$MitmExchangeListFromJson(json);
}

@freezed
abstract class MitmAction with _$MitmAction {
  const factory MitmAction({
    required String kind,
    @Default('') String phase,
    @Default('') String detail,
  }) = _MitmAction;

  factory MitmAction.fromJson(Map<String, Object?> json) =>
      _$MitmActionFromJson(json);
}

@freezed
abstract class MitmExchange with _$MitmExchange {
  const factory MitmExchange({
    required int id,
    required DateTime start,
    @Default(false) bool pending,
    @Default(0) int duration,
    @Default(0) int ttfb,
    @Default('') String method,
    @Default('') String url,
    @Default('') @JsonKey(name: 'original-url') String originalUrl,
    @Default('') String proto,
    @Default(0) int status,
    @Default(0) @JsonKey(name: 'request-size') int requestSize,
    @Default(0) @JsonKey(name: 'response-size') int responseSize,
    @Default('') String error,
    @Default('') String connection,
    @Default({})
    @JsonKey(name: 'request-header')
    Map<String, List<String>> requestHeader,
    @Default({})
    @JsonKey(name: 'response-header')
    Map<String, List<String>> responseHeader,
    @Default([]) List<MitmAction> actions,
  }) = _MitmExchange;

  factory MitmExchange.fromJson(Map<String, Object?> json) =>
      _$MitmExchangeFromJson(json);
}

/// One side of a request as kept, decoded unless [encoding] names the coding
/// the Core could not undo; [data] is Base64.
@freezed
abstract class MitmBody with _$MitmBody {
  const factory MitmBody({
    @Default('') String data,
    @Default(false) bool truncated,
    @Default('') String encoding,
  }) = _MitmBody;

  factory MitmBody.fromJson(Map<String, Object?> json) =>
      _$MitmBodyFromJson(json);
}

@freezed
abstract class VpnOptions with _$VpnOptions {
  const factory VpnOptions({
    required bool enable,
    required int port,
    required bool ipv6,
    required bool dnsHijacking,
    required AccessControlProps accessControlProps,
    required bool allowBypass,
    required bool systemProxy,
    required List<String> bypassDomain,
    @Default([]) List<String> routeAddress,
    @Default(0) int mtu,
    @Default('') String congestionController,
    @Default(false) bool rootTun,
  }) = _VpnOptions;

  factory VpnOptions.fromJson(Map<String, Object?> json) =>
      _$VpnOptionsFromJson(json);
}

extension VpnOptionsExt on VpnOptions {
  /// Only what `ServiceController.start` and `VpnService.handleStart` read.
  VpnOptions get effective {
    if (!enable) {
      return const VpnOptions(
        enable: false,
        port: 0,
        ipv6: false,
        dnsHijacking: false,
        accessControlProps: AccessControlProps(),
        allowBypass: false,
        systemProxy: false,
        bypassDomain: [],
      );
    }
    final accessControl = accessControlProps;
    final accepts = accessControl.mode == AccessControlMode.acceptSelected;
    return copyWith(
      port: systemProxy ? port : 0,
      bypassDomain: systemProxy ? bypassDomain : const [],
      accessControlProps: accessControl.enable
          ? AccessControlProps(
              enable: true,
              mode: accessControl.mode,
              acceptList: accepts ? accessControl.acceptList : const [],
              rejectList: accepts ? const [] : accessControl.rejectList,
            )
          : const AccessControlProps(),
    );
  }
}

@freezed
abstract class RouteSnapshot with _$RouteSnapshot {
  const factory RouteSnapshot({
    @Default(0) int coreEpoch,
    @Default(0) int routeVersion,
    @Default(false) bool running,
  }) = _RouteSnapshot;
}

/// [exit] is the Core's name for where a connection left, only compared whole.
@freezed
abstract class RouteHit with _$RouteHit {
  const factory RouteHit({
    @Default('') String host,
    @Default('') String proxy,
    @Default('') String exit,
  }) = _RouteHit;

  factory RouteHit.fromJson(Map<String, Object?> json) =>
      _$RouteHitFromJson(json);
}

@freezed
abstract class RouteCheck with _$RouteCheck {
  const factory RouteCheck({
    @JsonKey(name: 'core-epoch') @Default(0) int coreEpoch,
    @JsonKey(name: 'route-version') @Default(0) int routeVersion,
    @Default([]) List<bool> held,
  }) = _RouteCheck;

  factory RouteCheck.fromJson(Map<String, Object?> json) =>
      _$RouteCheckFromJson(json);
}

@freezed
abstract class Delay with _$Delay {
  const factory Delay({required String name, required String url, int? value}) =
      _Delay;

  factory Delay.fromJson(Map<String, Object?> json) => _$DelayFromJson(json);
}

@freezed
abstract class OutboundIpParams with _$OutboundIpParams {
  const factory OutboundIpParams({
    @JsonKey(name: 'proxy-name') @Default('') String proxyName,
    @Default([]) List<String> urls,
    required int timeout,
  }) = _OutboundIpParams;

  factory OutboundIpParams.fromJson(Map<String, Object?> json) =>
      _$OutboundIpParamsFromJson(json);
}

@freezed
abstract class OutboundIpResult with _$OutboundIpResult {
  const factory OutboundIpResult({
    @Default('') String url,
    @Default('') String body,
    @Default(0) int delay,
    @Default([]) List<String> chains,
    String? error,
    @JsonKey(name: 'core-epoch') @Default(0) int coreEpoch,
    @JsonKey(name: 'route-version') @Default(0) int routeVersion,
    @Default([]) List<RouteHit> hits,
    @JsonKey(name: 'node-hits') @Default([]) List<RouteHit> nodeHits,
  }) = _OutboundIpResult;

  factory OutboundIpResult.fromJson(Map<String, Object?> json) =>
      _$OutboundIpResultFromJson(json);
}

@freezed
abstract class ServiceCheckParams with _$ServiceCheckParams {
  const factory ServiceCheckParams({
    @JsonKey(name: 'proxy-name') @Default('') String proxyName,
    @Default([]) List<String> names,
    required int timeout,
  }) = _ServiceCheckParams;

  factory ServiceCheckParams.fromJson(Map<String, Object?> json) =>
      _$ServiceCheckParamsFromJson(json);
}

@freezed
abstract class ServiceCheckItem with _$ServiceCheckItem {
  const factory ServiceCheckItem({
    @Default('') String name,
    @Default('') String status,
    @Default('') String region,
    @Default(0) int delay,
    @Default([]) List<String> chains,
    @JsonKey(name: 'checked-at') @Default(0) int checkedAt,
    @JsonKey(name: 'core-epoch') @Default(0) int coreEpoch,
    @JsonKey(name: 'route-version') @Default(0) int routeVersion,
    @Default([]) List<RouteHit> hits,
  }) = _ServiceCheckItem;

  factory ServiceCheckItem.fromJson(Map<String, Object?> json) =>
      _$ServiceCheckItemFromJson(json);
}

@freezed
abstract class CoreMemoryStats with _$CoreMemoryStats {
  const factory CoreMemoryStats({
    @Default(0) int rss,
    @Default(0) @JsonKey(name: 'heap-inuse') int heapInuse,
    @Default(0) @JsonKey(name: 'heap-idle') int heapIdle,
    @Default(0) @JsonKey(name: 'stack-inuse') int stackInuse,
    @Default(0) @JsonKey(name: 'runtime-other') int runtimeOther,
  }) = _CoreMemoryStats;

  factory CoreMemoryStats.fromJson(Map<String, Object?> json) =>
      _$CoreMemoryStatsFromJson(json);
}

extension CoreMemoryStatsExt on CoreMemoryStats {
  int get runtimeTotal => heapInuse + heapIdle + stackInuse + runtimeOther;
}

SubscriptionInfo? subscriptionInfoFormCore(Map<String, Object?>? json) {
  if (json == null) return null;
  return SubscriptionInfo(
    upload: (json['Upload'] as num?)?.toInt() ?? 0,
    download: (json['Download'] as num?)?.toInt() ?? 0,
    total: (json['Total'] as num?)?.toInt() ?? 0,
    expire: (json['Expire'] as num?)?.toInt() ?? 0,
  );
}

@freezed
abstract class ExternalProvider with _$ExternalProvider {
  const factory ExternalProvider({
    required String name,
    required String type,
    String? path,
    required int count,
    @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)
    SubscriptionInfo? subscriptionInfo,
    @JsonKey(name: 'vehicle-type') required String vehicleType,
    @JsonKey(name: 'update-at') required DateTime updateAt,
  }) = _ExternalProvider;

  factory ExternalProvider.fromJson(Map<String, Object?> json) =>
      _$ExternalProviderFromJson(json);
}

extension ExternalProviderExt on ExternalProvider {
  String get updatingKey => 'provider_$name';
}

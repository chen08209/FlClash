import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rust_api/rust_api.dart';
import 'package:yaml/yaml.dart' as yaml_parser;

const freeNodesProfileUrl = 'flclash://free-nodes/merged';
const freeNodesProfileLabel = '\u514d\u8d39\u8282\u70b9';
const freeNodesGroupName = 'FREE-NODES';
const freeNodesSourceAssetPath = 'assets/data/free_node_sources.json';
const freeNodesAutoUpdateDuration = Duration(hours: 1);
const freeNodesHistoryGroupName = '\u5386\u53f2';
const freeNodesDateGroupPrefix = '日期 ';
const freeNodesTreasureGroupName = '优选节点';
const freeNodesLegacyTreasureGroupName = '\u5b9d\u85cf\u79ef\u7d2f';
const freeNodesSourceGroupPrefix = '来源 ';
const freeNodesDelayTestUrl =
    'http://connectivitycheck.platform.hicloud.com/generate_204';
const freeNodesProgressKey = 'free_nodes_progress';
const freeNodesSelectedSourcesKey = 'free_nodes_selected_sources';
const freeNodesDisabledKey = 'free_nodes_disabled';
const freeNodesSourceTimeoutsKey = 'free_nodes_source_timeouts';
const freeNodesSourceFetchTimeoutsKey =
    'free_nodes_source_fetch_timeouts_seconds';
const freeNodesFetchTimesKey = 'free_nodes_fetch_times';
const freeNodesFetchConcurrencyKey = 'free_nodes_fetch_concurrency';
const freeNodesAutoPreferKey = 'free_nodes_auto_prefer';
const freeNodesPreferDeleteExpiredKey = 'free_nodes_prefer_delete_expired';
const freeNodesLastAutoPreferDateKey = 'free_nodes_last_auto_prefer_date';
const freeNodesFetchTimeout = Duration(seconds: 10);

const _freeNodesFastDiscoveryPageLimit = 36;
const _freeNodesFullDiscoveryPageLimit = 72;
const _freeNodesDiscoveryConfigThreshold = 30;
const _freeNodesConfigCandidateCanonicalLimit = 100;
const _githubRawMirrorPrefixes = [
  'https://ghfile.geekertao.top/',
  'https://ghfast.top/',
  'https://ghproxy.net/',
  'https://gh-proxy.com/',
  'https://ghproxy.imciel.com/',
  'https://gh.monlor.com/',
  'https://gh.ddlc.top/',
  'https://gh.llkk.cc/',
  'https://ghproxy.cc/',
  'https://gh.con.sh/',
  'https://hub.gitmirror.com/',
  'https://ghproxy.vip/',
  'https://github.akams.cn/',
];
const _githubPathMirrorPrefixes = [
  'https://gcore.jsdelivr.net/gh/',
  'https://fastly.jsdelivr.net/gh/',
  'https://cdn.jsdelivr.net/gh/',
];
const _githubRawPathMirrorPrefixes = ['https://rawgithubusercontent.deno.dev/'];
final _freeNodesConfigCandidateLimit =
    (_githubRawMirrorPrefixes.length +
        _githubPathMirrorPrefixes.length +
        _githubRawPathMirrorPrefixes.length +
        1) *
    _freeNodesConfigCandidateCanonicalLimit;
const _freeNodesProviderFollowUpLimit = 16;
const _freeNodesEmbeddedBase64MinLength = 32;
const _freeNodesEmbeddedBase64MaxLength = 128 * 1024;
const _freeNodesEmbeddedBase64CandidateLimit = 16;
final _freeNodesCompactBase64Pattern = RegExp(r'^[A-Za-z0-9+/=_\-\s]+$');
final _freeNodesBase64WhitespacePattern = RegExp(r'\s+');
final _freeNodesEmbeddedBase64Pattern = RegExp(r'[A-Za-z0-9+/=_\-]{32,}');
const _githubRawSeedPaths = [
  'clash.yaml',
  'clash.yml',
  'clash.txt',
  'proxies.yaml',
  'proxies.yml',
  'mihomo.yaml',
  'mihomo.yml',
  'mihomo.txt',
  'clash-meta.yaml',
  'clash-meta.yml',
  'clash-meta.txt',
  'clashmeta.yaml',
  'clashmeta.yml',
  'clashmeta.txt',
  'meta.yaml',
  'meta.yml',
  'meta.txt',
  'config.yaml',
  'config.yml',
  'config.txt',
  'all.yaml',
  'all.yml',
  'all.json',
  'all.txt',
  'merged.yaml',
  'merged.yml',
  'merged.txt',
  'free.yaml',
  'free.yml',
  'free.json',
  'free.txt',
  'index.yaml',
  'index.yml',
  'index.txt',
  'base64.txt',
  'v2ray.txt',
  'c.yaml',
  'v.txt',
  'Client.txt',
  'v2',
  'ClashPremiumFree.yaml',
  'README.md',
  'http.txt',
  'https.txt',
  'socks5.txt',
  'http.csv',
  'https.csv',
  'socks5.csv',
  'all-proxies.txt',
  'all.csv',
  'free.csv',
  'node.csv',
  'nodes.csv',
  'proxies.csv',
  'proxy.csv',
  'proxy.json',
  'proxies.json',
  'node.json',
  'nodes.json',
  'proxylist.txt',
  'proxylist.csv',
  'proxylist.json',
  'proxylist.yaml',
  'proxylist.yml',
  'proxylist.xml',
  'proxylist.phps',
  'proxy-list.txt',
  'proxy-list.csv',
  'proxy-list.json',
  'proxy-list.yaml',
  'proxy-list.yml',
  'proxy-list-raw.txt',
  'provider.yaml',
  'provider.yml',
  'provider.json',
  'providers.yaml',
  'providers.yml',
  'providers.json',
  'proxy-providers.yaml',
  'proxy-providers.yml',
  'proxy-providers.json',
  'proxy_providers.yaml',
  'proxy_providers.yml',
  'proxy_providers.json',
  'sub',
  'sub.yml',
  'sub_en',
  'sub_zh',
  'sub_ar',
  'v2ray',
  'base64',
  'list',
  'subscribe',
  'subscribe.txt',
  'subscribe.yaml',
  'subscribe.yml',
  'subscription',
  'subscription.txt',
  'subscription.yaml',
  'subscription.yml',
  'subscriptions',
  'subscriptions.txt',
  'subscriptions.yaml',
  'subscriptions.yml',
  'sub.txt',
  'sub.yaml',
  'sub1.txt',
  'sub2.txt',
  'sub3.txt',
  'node',
  'node.txt',
  'node.yaml',
  'node.yml',
  'nodes',
  'nodes.txt',
  'nodes.yaml',
  'nodes.yml',
  'proxy',
  'proxy.txt',
  'proxy.yaml',
  'proxy.yml',
  'proxies',
  'proxies.txt',
  'profile',
  'profile.txt',
  'profile.yaml',
  'profile.yml',
  'profiles',
  'profiles.txt',
  'profiles.yaml',
  'profiles.yml',
  'sing-box.json',
  'sing-box.yaml',
  'singbox.json',
  'outbounds.json',
  'outbounds.yaml',
  'source/clash-meta.yaml',
  'source/clash-meta-2.yaml',
  'static/sub_en',
  'static/sub_zh',
  'static/sub_ar',
  'sub/clash.yaml',
  'sub/clash.yml',
  'sub/proxies.yaml',
  'sub/proxies.yml',
  'sub/mihomo.yaml',
  'sub/mihomo.yml',
  'sub/base64.txt',
  'sub/merged.yaml',
  'sub/merged.yml',
  'sub/v2ray.txt',
  'sub/sub.txt',
  'sub/sub.yaml',
  'sub/protocols/vless.txt',
  'sub/protocols/vless.yaml',
  'sub/protocols/trojan.txt',
  'sub/protocols/trojan.yaml',
  'sub/protocols/vmess.txt',
  'sub/protocols/vmess.yaml',
  'sub/protocols/ss.txt',
  'sub/protocols/ss.yaml',
  'sub/protocols/hysteria2.txt',
  'sub/protocols/hysteria2.yaml',
  'output_configs/Vless.txt',
  'output_configs/Vmess.txt',
  'output_configs/Trojan.txt',
  'output_configs/ShadowSocks.txt',
  'output_configs/Hysteria2.txt',
  'output_configs/Tuic.txt',
  'Splitted-By-Protocol/vless.txt',
  'Splitted-By-Protocol/vmess.txt',
  'Splitted-By-Protocol/trojan.txt',
  'Splitted-By-Protocol/ss.txt',
  'Splitted-By-Protocol/hysteria2.txt',
  'Splitted-By-Protocol/tuic.txt',
  'sub/continents/Europe.txt',
  'sub/continents/Europe.yaml',
  'sub/continents/Asia.txt',
  'sub/continents/Asia.yaml',
  'sub/continents/NorthAmerica.txt',
  'sub/continents/NorthAmerica.yaml',
  'sub/countries/IR.txt',
  'sub/countries/IR.yaml',
  'sub/countries/US.txt',
  'sub/countries/US.yaml',
  'sub/countries/SG.txt',
  'sub/countries/SG.yaml',
  'sub/countries/HK.txt',
  'sub/countries/HK.yaml',
  'subscribe/clash.yaml',
  'subscribe/clash.yml',
  'subscribe/proxies.yaml',
  'subscribe/mihomo.yaml',
  'subscribe/base64.txt',
  'subscribe/v2ray.txt',
  'subscribe/sub.txt',
  'subscription/clash.yaml',
  'subscription/clash.yml',
  'subscription/proxies.yaml',
  'subscription/mihomo.yaml',
  'subscription/base64.txt',
  'subscriptions/clash.yaml',
  'subscriptions/clash.yml',
  'subscriptions/proxies.yaml',
  'subscriptions/mihomo.yaml',
  'subscriptions/base64.txt',
  'subscriptions/sub.txt',
  'subscriptions/v2ray/super-sub.txt',
  'subscriptions/v2ray/subs/sub1.txt',
  'subscriptions/v2ray/subs/sub2.txt',
  'subscriptions/v2ray/subs/sub3.txt',
  'subscriptions/v2ray/subs/sub4.txt',
  'subscriptions/v2ray/subs/sub5.txt',
  'subscriptions/v2ray/subs/sub6.txt',
  'subscriptions/v2ray/subs/sub7.txt',
  'subscriptions/v2ray/subs/sub8.txt',
  'subscriptions/v2ray/subs/sub9.txt',
  'subscriptions/v2ray/subs/sub10.txt',
  'node/clash.yaml',
  'node/clash.yml',
  'node/proxies.yaml',
  'node/proxies.yml',
  'node/mihomo.yaml',
  'node/base64.txt',
  'node/sub.txt',
  'node/v2ray.txt',
  'nodes/clashmeta.yaml',
  'nodes/v2rayshare.yaml',
  'nodes/yudou66.yaml',
  'nodes/yudou66.txt',
  'nodes/ndnode.txt',
  'nodes/v2rayshare.txt',
  'nodes/wenode.txt',
  'proxy/clash.yaml',
  'proxy/clash.yml',
  'proxy/proxies.yaml',
  'proxy/proxies.yml',
  'proxy/mihomo.yaml',
  'proxy/base64.txt',
  'proxy/sub.txt',
  'proxy/v2ray.txt',
  'proxies/clash.yaml',
  'proxies/clash.yml',
  'proxies/proxies.yaml',
  'proxies/proxies.yml',
  'proxies/mihomo.yaml',
  'proxies/base64.txt',
  'proxies/sub.txt',
  'proxies/v2ray.txt',
  'proxies/protocols/http/data.json',
  'proxies/protocols/http/data.txt',
  'proxies/protocols/http/data.csv',
  'proxies/protocols/https/data.json',
  'proxies/protocols/https/data.txt',
  'proxies/protocols/https/data.csv',
  'proxies/protocols/socks5/data.json',
  'proxies/protocols/socks5/data.txt',
  'proxies/protocols/socks5/data.csv',
  'proxies/all/data.json',
  'proxies/all/data.txt',
  'proxies/all/data.csv',
  'protocols/http.txt',
  'protocols/https.txt',
  'protocols/socks5.txt',
  'protocols/http.csv',
  'protocols/https.csv',
  'protocols/socks5.csv',
  'online-proxies/txt/proxies.txt',
  'online-proxies/txt/proxies-http.txt',
  'online-proxies/txt/proxies-https.txt',
  'online-proxies/txt/proxies-socks5.txt',
  'online-proxies/csv/proxies.csv',
  'online-proxies/json/proxies.json',
  'online-proxies/json/proxies-basic.json',
  'online-proxies/xml/proxies.xml',
  'online-proxies/xml/proxies-basic.xml',
  'online-proxies/yaml/proxies.yaml',
  'online-proxies/yaml/proxies-basic.yaml',
  'config/clash.yaml',
  'config/mihomo.yaml',
  'config/proxies.yaml',
  'config/sub.yaml',
  'configs/clash.yaml',
  'configs/mihomo.yaml',
  'configs/proxies.yaml',
  'configs/sub.yaml',
  'data/clash.yaml',
  'data/mihomo.yaml',
  'data/proxies.yaml',
  'data/sub.yaml',
  'share/clash.yaml',
  'share/mihomo.yaml',
  'share/proxies.yaml',
  'share/sub.yaml',
  'meta/clash.yaml',
  'meta/mihomo.yaml',
  'meta/proxies.yaml',
  'meta/sub.yaml',
  'mihomo/config.yaml',
  'mihomo/config.yml',
  'mihomo/sub.yaml',
  'mihomo/sub.yml',
  'subs/merged/tested_within.yaml',
  'subs/merged/tested_within_sudoku.yaml',
  'clash/clash.yaml',
  'clash/proxies.yaml',
  'clash/all.yaml',
  'mihomo/mihomo.yaml',
  'mihomo/all.yaml',
  'mihomo/proxies.yaml',
  'mihomo/proxies.yml',
  'v2ray/v2ray.txt',
  'v2ray/sub.txt',
  'base64/base64.txt',
  'base64/sub.txt',
  'yaml/clash.yaml',
  'yaml/mihomo.yaml',
  'yaml/proxies.yaml',
  'list.txt',
  'links.txt',
  'urls.txt',
];
final _freeNodesGithubDiscoveryInitialCandidateEstimate =
    _githubRawSeedPaths.length * 3 + 8;

@visibleForTesting
int get freeNodesGithubRawSeedPathCountForTesting => _githubRawSeedPaths.length;

@visibleForTesting
List<String> get freeNodesGithubRawSeedPathsForTesting => _githubRawSeedPaths;

@visibleForTesting
int get freeNodesGithubDiscoveryInitialCandidateEstimateForTesting =>
    _freeNodesGithubDiscoveryInitialCandidateEstimate;

@visibleForTesting
int get freeNodesConfigCandidateLimitForTesting =>
    _freeNodesConfigCandidateLimit;

@visibleForTesting
String canonicalFreeNodeConfigUrlForTesting(String url) {
  return FreeNodesService()._canonicalConfigUrl(url);
}

@visibleForTesting
Set<String> githubMirrorUrlsForTesting(String url) {
  return FreeNodesService()._githubMirrorUrls(url);
}

@visibleForTesting
Profile applyFreeNodesUpdateMetadata(Profile profile, int proxyCount) {
  return profile.copyWith(
    label: profile.label.takeFirstValid([freeNodesProfileLabel]),
    subscriptionInfo: SubscriptionInfo(total: proxyCount),
    autoUpdateDuration: freeNodesAutoUpdateDuration,
  );
}

int freeNodesDateTokenFromGroupName(String groupName) {
  final normalizedGroupName = groupName.trim();
  final match = RegExp(
    r'(20\d{2})[-_/\.]?(\d{2})[-_/\.]?(\d{2})',
  ).firstMatch(normalizedGroupName);
  if (match == null) return 0;
  return int.tryParse('${match.group(1)}${match.group(2)}${match.group(3)}') ??
      0;
}

int freeNodesTodayDateToken([DateTime? now]) {
  final current = now ?? DateTime.now();
  return int.tryParse(
        '${current.year}${current.month.toString().padLeft(2, '0')}'
        '${current.day.toString().padLeft(2, '0')}',
      ) ??
      0;
}

String normalizeFreeNodesGroupName(String groupName) {
  final normalizedInput = groupName.trim();
  if (normalizedInput == freeNodesLegacyTreasureGroupName) {
    return freeNodesTreasureGroupName;
  }
  final sourceLabel = freeNodesSourceLabelFromGroupName(normalizedInput);
  if (sourceLabel != null) {
    return '$freeNodesSourceGroupPrefix$sourceLabel';
  }
  if (normalizedInput == freeNodesGroupName ||
      normalizedInput == freeNodesTreasureGroupName) {
    return normalizedInput;
  }
  final token = freeNodesDateTokenFromGroupName(normalizedInput);
  if (token <= 0) return normalizedInput;
  final tokenText = token.toString().padLeft(8, '0');
  return '$freeNodesDateGroupPrefix'
      '${tokenText.substring(0, 4)}-'
      '${tokenText.substring(4, 6)}-'
      '${tokenText.substring(6, 8)}';
}

bool isTodayFreeNodesGroupName(String groupName, {DateTime? now}) {
  final token = freeNodesDateTokenFromGroupName(groupName);
  return token > 0 && token == freeNodesTodayDateToken(now);
}

String? freeNodesSourceLabelFromGroupName(String groupName) {
  final normalized = groupName.trim();
  if (!normalized.startsWith(freeNodesSourceGroupPrefix)) return null;
  final label = normalized
      .substring(freeNodesSourceGroupPrefix.length)
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return label.isEmpty ? null : label;
}

bool isFreeNodesSourceGroupName(String groupName) {
  return freeNodesSourceLabelFromGroupName(groupName) != null;
}

bool isVisibleFreeNodesGroupName(String groupName, {DateTime? now}) {
  final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
  return normalizedGroupName == freeNodesTreasureGroupName ||
      isFreeNodesSourceGroupName(normalizedGroupName);
}

bool isActionableFreeNodesGroupName(String groupName) {
  final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
  return normalizedGroupName == freeNodesGroupName ||
      normalizedGroupName == freeNodesTreasureGroupName ||
      freeNodesDateTokenFromGroupName(normalizedGroupName) > 0 ||
      isFreeNodesSourceGroupName(normalizedGroupName);
}

String? freeNodesGroupUnavailableReason(String groupName, {DateTime? now}) {
  if (isActionableFreeNodesGroupName(groupName)) return null;
  return '只能操作免费节点分类';
}

String? freeNodesGroupActionUnavailableReason(String groupName) {
  if (isActionableFreeNodesGroupName(groupName)) return null;
  return '只能操作免费节点分类';
}

bool shouldFilterVisibleFreeNodesGroups({
  required Iterable<Group> groups,
  Profile? profile,
}) {
  return profile?.isFreeNodesProfile == true ||
      profile?.label == freeNodesProfileLabel ||
      groups.any(
        (group) =>
            normalizeFreeNodesGroupName(group.name) == freeNodesGroupName,
      ) ||
      groups.any((group) => freeNodesDateTokenFromGroupName(group.name) > 0);
}

List<Group> normalizeVisibleFreeNodesGroups(
  Iterable<Group> groups, {
  String? selectedGroupName,
}) {
  final result = <String, Group>{};
  final normalizedSelectedGroupName = selectedGroupName == null
      ? null
      : normalizeFreeNodesGroupName(selectedGroupName);
  for (final group in groups) {
    final normalizedName = normalizeFreeNodesGroupName(group.name);
    final isSelectedToolbarGroup =
        normalizedName == normalizedSelectedGroupName &&
        (normalizedName == freeNodesTreasureGroupName ||
            freeNodesDateTokenFromGroupName(normalizedName) > 0);
    if (!isVisibleFreeNodesGroupName(normalizedName) &&
        !isSelectedToolbarGroup) {
      continue;
    }
    final normalizedGroup = group.copyWith(
      name: normalizedName,
      hidden:
          normalizedName == freeNodesTreasureGroupName || isSelectedToolbarGroup
          ? false
          : group.hidden,
    );
    final existing = result[normalizedName];
    if (existing == null) {
      result[normalizedName] = normalizedGroup;
      continue;
    }
    result[normalizedName] = existing.copyWith(
      all: [...existing.all, ...normalizedGroup.all],
      now: existing.now?.isNotEmpty == true
          ? existing.now
          : normalizedGroup.now,
      hidden: existing.hidden == true && normalizedGroup.hidden == true,
      testUrl: existing.testUrl ?? normalizedGroup.testUrl,
    );
  }
  final values = result.values.toList(growable: false);
  values.sort((a, b) {
    final aIsSource = isFreeNodesSourceGroupName(a.name);
    final bIsSource = isFreeNodesSourceGroupName(b.name);
    if (aIsSource != bIsSource) return aIsSource ? -1 : 1;
    return a.name.compareTo(b.name);
  });
  return values;
}

List<Group> freeNodesDateSwitchGroups(Iterable<Group> groups) {
  final result = <String, Group>{};
  for (final group in groups) {
    final normalizedName = normalizeFreeNodesGroupName(group.name);
    if (normalizedName != freeNodesTreasureGroupName &&
        freeNodesDateTokenFromGroupName(normalizedName) <= 0) {
      continue;
    }
    result.putIfAbsent(
      normalizedName,
      () => group.name == normalizedName
          ? group
          : group.copyWith(name: normalizedName),
    );
  }
  final values = result.values.toList(growable: false);
  values.sort((a, b) {
    if (a.name == freeNodesTreasureGroupName) return 1;
    if (b.name == freeNodesTreasureGroupName) return -1;
    return freeNodesDateTokenFromGroupName(
      b.name,
    ).compareTo(freeNodesDateTokenFromGroupName(a.name));
  });
  return values;
}

const freeNodeSourceUrls = [
  'https://github.com/free-nodes/clashfree',
  'https://www.freeclashnode.com/free-node/',
  'https://oneclash.cc/',
  'https://clashgithub.com/',
  'https://v2rayshare.net/',
  'https://clashnode.cc/',
  'https://free.datiya.com/',
  'https://github.com/PuddinCat/BestClash',
  'https://clashmeta.cc/',
  'https://github.com/crossxx-labs/free-proxy',
  'https://freenode.biz/',
  'https://github.com/ripaojiedian/freenode',
  'https://github.com/freenodes/freenodes',
  'https://github.com/Flikify/Free-Node',
  'https://github.com/Barabama/FreeNodes',
  'https://free-clash-v2ray.github.io/',
];

typedef FreeNodesFetcher = Future<String> Function(String url);
typedef FreeNodesProgressCallback = void Function(FreeNodesProgress progress);
typedef FreeNodesPartialResultCallback =
    FutureOr<void> Function(FreeNodesUpdateResult result);
typedef FreeNodesPartialProfileCallback =
    FutureOr<void> Function(Profile profile);

String _hoursLabel(int hours) {
  if (hours <= 0) return '\u672a\u77e5';
  if (hours % 24 == 0) {
    final days = hours ~/ 24;
    return days == 1 ? '\u6bcf\u65e5' : '$days \u5929';
  }
  return '$hours \u5c0f\u65f6';
}

String _secondsLabel(int seconds) {
  if (seconds <= 0) return '\u672a\u77e5';
  return '$seconds \u79d2';
}

Future<String> _defaultFreeNodesFetcher(String url) async {
  if (url.contains('freeclash.top')) {
    return _fetchFreeClashTop(url);
  }
  final response = await request.dio.get<String>(
    url,
    options: Options(responseType: ResponseType.plain),
  );
  return response.data ?? '';
}

Future<String> _fetchFreeClashTop(String url) async {
  final verifyPageUrl = url.contains('/v1/sub/')
      ? 'https://www.freeclash.top/ui/free_clash'
      : url;
  final response = await request.dio.get<String>(
    verifyPageUrl,
    options: Options(
      responseType: ResponseType.plain,
      validateStatus: (_) => true,
    ),
  );
  final text = response.data ?? '';
  if (!text.contains('/ui/free_clash/verify')) return text;
  final match = RegExp(r'(\d+)\s*\+\s*(\d+)\s*=').firstMatch(text);
  if (match == null) return text;
  final answer =
      (int.tryParse(match.group(1) ?? '') ?? 0) +
      (int.tryParse(match.group(2) ?? '') ?? 0);
  final verifyResponse = await request.dio.post<String>(
    'https://www.freeclash.top/ui/free_clash/verify',
    data: {'answer': answer.toString()},
    options: Options(
      contentType: Headers.formUrlEncodedContentType,
      followRedirects: false,
      responseType: ResponseType.plain,
      validateStatus: (_) => true,
    ),
  );
  final cookies = verifyResponse.headers['set-cookie'];
  final cookieHeader = cookies
      ?.map((cookie) => cookie.split(';').first)
      .join('; ');
  final verifiedResponse = await request.dio.get<String>(
    url,
    options: Options(
      responseType: ResponseType.plain,
      headers: cookieHeader == null ? null : {'cookie': cookieHeader},
      validateStatus: (_) => true,
    ),
  );
  return verifiedResponse.data ?? text;
}

extension FreeNodesProfileExt on Profile {
  bool get isFreeNodesProfile => url == freeNodesProfileUrl;
}

class FreeNodesUpdateResult {
  final Uint8List bytes;
  final String? filePath;
  final int proxyCount;
  final List<FreeNodeSourceStatus> sources;

  FreeNodesUpdateResult({
    Uint8List? bytes,
    this.filePath,
    required this.proxyCount,
    required this.sources,
  }) : assert(bytes != null || filePath != null),
       bytes = bytes ?? Uint8List(0);
}

class FreeNodesProgress {
  final String operation;
  final int completed;
  final int total;
  final int successfulSources;
  final int failedSources;
  final int proxyCount;
  final String? sourceId;
  final String? url;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final bool done;
  final bool error;

  const FreeNodesProgress({
    required this.operation,
    this.completed = 0,
    this.total = 0,
    this.successfulSources = 0,
    this.failedSources = 0,
    this.proxyCount = 0,
    this.sourceId,
    this.url,
    this.startedAt,
    this.finishedAt,
    this.done = false,
    this.error = false,
  });

  double? get value {
    if (total <= 0) return null;
    return completed.clamp(0, total) / total;
  }

  FreeNodesProgress copyWith({
    String? operation,
    int? completed,
    int? total,
    int? successfulSources,
    int? failedSources,
    int? proxyCount,
    String? sourceId,
    String? url,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool? done,
    bool? error,
  }) {
    return FreeNodesProgress(
      operation: operation ?? this.operation,
      completed: completed ?? this.completed,
      total: total ?? this.total,
      successfulSources: successfulSources ?? this.successfulSources,
      failedSources: failedSources ?? this.failedSources,
      proxyCount: proxyCount ?? this.proxyCount,
      sourceId: sourceId ?? this.sourceId,
      url: url ?? this.url,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      done: done ?? this.done,
      error: error ?? this.error,
    );
  }
}

class FreeNodeSourceOption {
  final String id;
  final String label;
  final String seed;
  final int updateIntervalHours;
  final int staleTimeoutHours;
  final int fetchTimeoutSeconds;
  final DateTime? lastFetchTime;

  const FreeNodeSourceOption({
    required this.id,
    required this.label,
    required this.seed,
    required this.updateIntervalHours,
    required this.staleTimeoutHours,
    required this.fetchTimeoutSeconds,
    this.lastFetchTime,
  });

  String get updateIntervalLabel => _hoursLabel(updateIntervalHours);

  String get staleTimeoutLabel => _hoursLabel(staleTimeoutHours);

  String get fetchTimeoutLabel => _secondsLabel(fetchTimeoutSeconds);
}

class FreeNodeSourceStatus {
  final String url;
  final bool success;
  final int proxyCount;
  final String? sourceId;
  final String? sourceLabel;
  final int? updateIntervalHours;
  final DateTime? fetchedAt;
  final String? message;

  const FreeNodeSourceStatus({
    required this.url,
    required this.success,
    required this.proxyCount,
    this.sourceId,
    this.sourceLabel,
    this.updateIntervalHours,
    this.fetchedAt,
    this.message,
  });
}

class FreeNodesPreferenceState {
  final int fetchConcurrency;
  final bool autoPrefer;
  final bool deleteExpiredOnPrefer;

  const FreeNodesPreferenceState({
    required this.fetchConcurrency,
    required this.autoPrefer,
    required this.deleteExpiredOnPrefer,
  });
}

class FreeNodesPreferResult {
  final Profile? profile;
  final Uint8List bytes;
  final int beforeCount;
  final int afterCount;
  final int removedCount;

  const FreeNodesPreferResult({
    this.profile,
    required this.bytes,
    required this.beforeCount,
    required this.afterCount,
    required this.removedCount,
  });
}

class FreeNodesGroupEditResult {
  final Profile? profile;
  final Uint8List bytes;
  final int beforeCount;
  final int afterCount;
  final int affectedCount;
  final String groupName;

  const FreeNodesGroupEditResult({
    this.profile,
    required this.bytes,
    required this.beforeCount,
    required this.afterCount,
    required this.affectedCount,
    required this.groupName,
  });
}

class FreeNodeStabilityResult {
  final String proxyName;
  final List<int> delays;
  final int failures;
  final int? averageDelay;
  final double variance;
  final FreeNodeStabilityLevel level;

  const FreeNodeStabilityResult({
    required this.proxyName,
    required this.delays,
    required this.failures,
    required this.averageDelay,
    required this.variance,
    required this.level,
  });
}

enum FreeNodeStabilityLevel { good, normal, poor }

enum _FreeNodesGroupEditMode { keep, moveToTreasure }

class _FreeNodeSourceCatalog {
  final int lookbackDays;
  final int historyTimeoutHours;
  final Set<String> defaultSourceIds;
  final List<_FreeNodeSourceDefinition> sources;

  const _FreeNodeSourceCatalog({
    required this.lookbackDays,
    required this.historyTimeoutHours,
    required this.defaultSourceIds,
    required this.sources,
  });

  factory _FreeNodeSourceCatalog.fromJson(String text) {
    final data = json.decode(text);
    if (data is! Map) return _FreeNodeSourceCatalog.fallback();
    final rawSources = data['sources'];
    final sources = rawSources is List
        ? rawSources
              .whereType<Map>()
              .map(_FreeNodeSourceDefinition.fromMap)
              .sorted((a, b) => a.rank.compareTo(b.rank))
              .toList(growable: false)
        : const <_FreeNodeSourceDefinition>[];
    final allSourceIds = sources.map((source) => source.id).toSet();
    final rawDefaultSourceIds = data['defaultSourceIds'];
    final declaredDefaultSourceIds = rawDefaultSourceIds is List
        ? rawDefaultSourceIds.map((item) => item.toString()).toSet()
        : allSourceIds;
    final defaultSourceIds = declaredDefaultSourceIds.intersection(
      allSourceIds,
    );
    return _FreeNodeSourceCatalog(
      lookbackDays: int.tryParse('${data['lookbackDays'] ?? 7}') ?? 7,
      historyTimeoutHours:
          int.tryParse('${data['historyTimeoutHours'] ?? 36}') ?? 36,
      defaultSourceIds: defaultSourceIds.isEmpty
          ? allSourceIds
          : defaultSourceIds,
      sources: sources,
    );
  }

  factory _FreeNodeSourceCatalog.fallback() {
    final sources = freeNodeSourceUrls
        .mapIndexed(
          (index, url) => _FreeNodeSourceDefinition(
            id: url,
            label: Uri.tryParse(url)?.host.takeFirstValid([url]) ?? url,
            seed: url,
            rank: index,
            pageDiscovery: true,
            githubDiscovery: url.contains('github.com'),
          ),
        )
        .toList(growable: false);
    return _FreeNodeSourceCatalog(
      lookbackDays: 7,
      historyTimeoutHours: 36,
      defaultSourceIds: sources.map((source) => source.id).toSet(),
      sources: sources,
    );
  }
}

class _FreeNodeSourceDefinition {
  final String id;
  final String label;
  final String seed;
  final int rank;
  final int updateIntervalHours;
  final int staleTimeoutHours;
  final bool pageDiscovery;
  final bool githubDiscovery;
  final List<String> rawCandidates;
  final List<String> pageTemplates;
  final List<String> configTemplates;
  final List<int> indices;

  const _FreeNodeSourceDefinition({
    required this.id,
    required this.label,
    required this.seed,
    required this.rank,
    this.updateIntervalHours = 24,
    int? staleTimeoutHours,
    this.pageDiscovery = false,
    this.githubDiscovery = false,
    this.rawCandidates = const [],
    this.pageTemplates = const [],
    this.configTemplates = const [],
    this.indices = const [],
  }) : staleTimeoutHours =
           staleTimeoutHours ??
           (updateIntervalHours + 12 < 12
               ? 12
               : updateIntervalHours + 12 > 72
               ? 72
               : updateIntervalHours + 12);

  _FreeNodeSourceDefinition copyWith({int? staleTimeoutHours}) {
    return _FreeNodeSourceDefinition(
      id: id,
      label: label,
      seed: seed,
      rank: rank,
      updateIntervalHours: updateIntervalHours,
      staleTimeoutHours: staleTimeoutHours ?? this.staleTimeoutHours,
      pageDiscovery: pageDiscovery,
      githubDiscovery: githubDiscovery,
      rawCandidates: rawCandidates,
      pageTemplates: pageTemplates,
      configTemplates: configTemplates,
      indices: indices,
    );
  }

  factory _FreeNodeSourceDefinition.fromMap(Map data) {
    List<String> readStringList(String key) {
      final value = data[key];
      if (value is! List) return const [];
      return value.map((item) => item.toString()).toList(growable: false);
    }

    List<int> readIntList(String key) {
      final value = data[key];
      if (value is! List) return const [];
      return value
          .map((item) => int.tryParse(item.toString()))
          .nonNulls
          .toList(growable: false);
    }

    return _FreeNodeSourceDefinition(
      id: data['id']?.toString() ?? data['seed']?.toString() ?? '',
      label:
          data['label']?.toString() ??
          data['id']?.toString() ??
          data['seed']?.toString() ??
          '',
      seed: data['seed']?.toString() ?? '',
      rank: int.tryParse('${data['rank'] ?? 20}') ?? 20,
      updateIntervalHours:
          int.tryParse('${data['updateIntervalHours'] ?? 24}') ?? 24,
      staleTimeoutHours: int.tryParse('${data['staleTimeoutHours'] ?? ''}'),
      pageDiscovery: data['pageDiscovery'] == true,
      githubDiscovery: data['githubDiscovery'] == true,
      rawCandidates: readStringList('rawCandidates'),
      pageTemplates: readStringList('pageTemplates'),
      configTemplates: readStringList('configTemplates'),
      indices: readIntList('indices'),
    );
  }
}

class _DatedProxy {
  final Map<String, dynamic> proxy;
  final String dateLabel;
  final int dateToken;
  final List<String> sourceIds;
  final List<String> sourceLabels;
  final String? sourceId;
  final String? sourceLabel;
  final int? staleTimeoutHours;

  const _DatedProxy({
    required this.proxy,
    required this.dateLabel,
    required this.dateToken,
    this.sourceIds = const [],
    this.sourceLabels = const [],
    this.sourceId,
    this.sourceLabel,
    this.staleTimeoutHours,
  });

  List<String> get effectiveSourceIds {
    if (sourceIds.isNotEmpty) return sourceIds;
    final value = sourceId?.trim();
    return value == null || value.isEmpty ? const [] : [value];
  }

  List<String> get effectiveSourceLabels {
    if (sourceLabels.isNotEmpty) return sourceLabels;
    final value = sourceLabel?.trim();
    return value == null || value.isEmpty ? const [] : [value];
  }
}

class _DiscoveryCandidate {
  final String url;
  final int depth;
  final _FreeNodeSourceDefinition source;

  const _DiscoveryCandidate(this.url, this.depth, this.source);
}

class _ResolvedConfigCandidate {
  final String url;
  final _FreeNodeSourceDefinition source;

  const _ResolvedConfigCandidate({required this.url, required this.source});
}

class _DiscoveryResult {
  final Set<String> configUrls;
  final Set<String> pageUrls;

  const _DiscoveryResult({required this.configUrls, required this.pageUrls});
}

class _RustSourceFetchResult {
  final _FreeNodeSourceDefinition source;
  final Map<String, dynamic>? output;
  final Object? error;

  const _RustSourceFetchResult({required this.source, this.output, this.error});
}

class FreeNodesService {
  final FreeNodesFetcher fetcher;
  final Duration fetchTimeout;
  final String? sourceCatalogJson;
  final Set<String>? enabledSourceIds;
  final bool _usesCustomFetcher;
  _FreeNodeSourceCatalog? _sourceCatalog;

  FreeNodesService({
    FreeNodesFetcher? fetcher,
    this.fetchTimeout = freeNodesFetchTimeout,
    this.sourceCatalogJson,
    this.enabledSourceIds,
  }) : fetcher = fetcher ?? _defaultFreeNodesFetcher,
       _usesCustomFetcher = fetcher != null;

  Profile createProfile() {
    return Profile.normal(
      label: freeNodesProfileLabel,
      url: freeNodesProfileUrl,
    ).copyWith(
      autoUpdate: true,
      autoUpdateDuration: freeNodesAutoUpdateDuration,
    );
  }

  Future<Profile> updateProfile(
    Profile profile, {
    Set<String>? sourceIds,
    FreeNodesProgressCallback? onProgress,
    FreeNodesPartialProfileCallback? onPartialProfile,
  }) async {
    String? existingConfigPath;
    try {
      final existingFile = await profile.file;
      if (await existingFile.exists()) {
        existingConfigPath = existingFile.path;
      }
    } catch (_) {}

    Future<Profile> saveResult(FreeNodesUpdateResult result) async {
      final updatedProfile = applyFreeNodesUpdateMetadata(
        profile,
        result.proxyCount,
      );
      final filePath = result.filePath;
      if (filePath == null || filePath.isEmpty) {
        return updatedProfile.saveFile(result.bytes);
      }
      try {
        return await updatedProfile.saveFileWithPath(filePath);
      } finally {
        try {
          await File(filePath).delete();
        } catch (_) {}
      }
    }

    final result = await fetchMergedConfig(
      existingConfigPath: existingConfigPath,
      sourceIds: sourceIds,
      onProgress: onProgress,
      onPartialResult: onPartialProfile == null
          ? null
          : (result) async {
              if (result.proxyCount <= 0) return;
              await onPartialProfile(await saveResult(result));
            },
    );
    if (result.proxyCount == 0) {
      throw '\u672a\u4ece\u514d\u8d39\u8282\u70b9\u6765\u6e90\u83b7\u53d6\u5230\u53ef\u7528 Clash \u8282\u70b9';
    }
    return saveResult(result);
  }

  Future<Profile?> normalizeExistingProfile(Profile profile) async {
    String? existingConfigText;
    try {
      final existingFile = await profile.file;
      if (await existingFile.exists()) {
        existingConfigText = utf8.decode(await existingFile.readAsBytes());
      }
    } catch (_) {}
    if (existingConfigText == null || existingConfigText.trim().isEmpty) {
      return null;
    }
    final result = await normalizeExistingConfigText(existingConfigText);
    if (result == null) return null;
    return applyFreeNodesUpdateMetadata(
      profile,
      result.proxyCount,
    ).saveFile(result.bytes);
  }

  Future<FreeNodesUpdateResult?> normalizeExistingConfigText(
    String existingConfigText,
  ) async {
    if (!_needsFreeNodesConfigNormalization(existingConfigText)) return null;
    final catalog = await _loadEffectiveSourceCatalog();
    final normalized = _deduplicateAndName(
      _extractExistingDatedProxies(
        existingConfigText,
        catalog,
        cleanupExpired: false,
      ),
    );
    if (normalized.isEmpty) return null;
    final config = _buildClashConfig(normalized, catalog: catalog);
    return FreeNodesUpdateResult(
      bytes: Uint8List.fromList(utf8.encode(yaml.encode(config))),
      proxyCount: normalized.length,
      sources: const [],
    );
  }

  Future<FreeNodesUpdateResult> fetchMergedConfig({
    String? existingConfigText,
    String? existingConfigPath,
    Set<String>? sourceIds,
    FreeNodesProgressCallback? onProgress,
    FreeNodesPartialResultCallback? onPartialResult,
  }) async {
    if (_usesCustomFetcher) {
      var fallbackExistingConfigText = existingConfigText;
      if ((fallbackExistingConfigText == null ||
              fallbackExistingConfigText.trim().isEmpty) &&
          existingConfigPath != null &&
          existingConfigPath.trim().isNotEmpty) {
        try {
          fallbackExistingConfigText = await File(
            existingConfigPath,
          ).readAsString();
        } catch (_) {}
      }
      return _fetchMergedConfigDart(
        existingConfigText: fallbackExistingConfigText,
        sourceIds: sourceIds,
        onProgress: onProgress,
        onPartialResult: onPartialResult,
      );
    }
    onProgress?.call(
      const FreeNodesProgress(
        operation: '\u6b63\u5728\u51c6\u5907\u6765\u6e90',
      ),
    );
    final catalog = await _loadEffectiveSourceCatalog();
    final preferenceState = await getPreferenceState();
    final autoPreferDuringFetch = preferenceState.autoPrefer;
    final enabledIds = await _loadEnabledSourceIds(catalog);
    final timeoutOverrides = await getSourceFetchTimeoutOverrides();
    final now = DateTime.now();
    final targetEnabledIds = sourceIds == null
        ? enabledIds
        : enabledIds.intersection(sourceIds);
    final plannedSources = catalog.sources
        .where((source) => targetEnabledIds.contains(source.id))
        .toList(growable: false);
    final totalSources = plannedSources.length;
    onProgress?.call(
      FreeNodesProgress(operation: '获取中', completed: 0, total: totalSources),
    );
    if (plannedSources.isEmpty) {
      var resolvedExistingConfigText = existingConfigText;
      if ((resolvedExistingConfigText == null ||
              resolvedExistingConfigText.trim().isEmpty) &&
          existingConfigPath != null &&
          existingConfigPath.trim().isNotEmpty) {
        try {
          resolvedExistingConfigText = await File(
            existingConfigPath,
          ).readAsString();
        } catch (_) {}
      }
      final existingProxies = _extractExistingDatedProxies(
        resolvedExistingConfigText,
        catalog,
        cleanupExpired: false,
      );
      final result = _buildUpdateResult(
        existingProxies,
        catalog: catalog,
        autoPrefer: autoPreferDuringFetch,
        sources: const [],
      );
      onProgress?.call(
        FreeNodesProgress(
          operation: '已完成',
          proxyCount: result.proxyCount,
          done: true,
        ),
      );
      return result;
    }
    final sourceFetchConcurrency = preferenceState.fetchConcurrency.clamp(
      1,
      totalSources,
    );
    await ensureRustApiInitialized();
    final sourceFetchTimes = <String, String>{};
    final sourceStatuses = <FreeNodeSourceStatus>[];
    var completedSources = 0;
    var successfulSources = 0;
    var failedSources = 0;
    var progressProxyCount = 0;

    final defaultTimeoutSeconds = fetchTimeout.inSeconds.clamp(3, 120);
    final plannedSourcesById = {
      for (final source in plannedSources) source.id: source,
    };
    final rustInput = {
      'catalog': {
        'historyTimeoutHours': catalog.historyTimeoutHours,
        'sources': [
          for (final source in plannedSources)
            {
              'id': source.id,
              'label': source.label,
              'seed': source.seed,
              'rank': source.rank,
              'updateIntervalHours': source.updateIntervalHours,
              'staleTimeoutHours': source.staleTimeoutHours,
              'pageDiscovery': source.pageDiscovery,
              'githubDiscovery': source.githubDiscovery,
              'rawCandidates': source.rawCandidates,
              'candidateUrls': _sourceCandidates(
                source,
                catalog.lookbackDays,
              ).toList(growable: false),
            },
        ],
      },
      'enabledSourceIds': plannedSources.map((source) => source.id).toList(),
      'sourceIds': plannedSources.map((source) => source.id).toList(),
      'existingConfigText': existingConfigPath == null
          ? existingConfigText
          : null,
      'existingConfigPath': existingConfigPath,
      'preference': {
        'fetchConcurrency': sourceFetchConcurrency,
        'autoPrefer': autoPreferDuringFetch,
      },
      'fetchTimeoutSecondsBySource': {
        for (final entry in timeoutOverrides.entries)
          if (plannedSourcesById.containsKey(entry.key)) entry.key: entry.value,
      },
      'defaultFetchTimeoutSeconds': defaultTimeoutSeconds,
      'proxyUrl': _currentProxyUrl(),
      'userAgent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
          'AppleWebKit/537.36 (KHTML, like Gecko) FlClashPlusPlus/1.0',
      'todayLabel': _formatDateGroupLabel(now),
      'todayToken': _todayDateToken(),
      'nowDayNumber':
          DateTime.utc(now.year, now.month, now.day).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay,
      'nowIso': DateTime.now().toIso8601String(),
    };

    FreeNodesUpdateResult? completedResult;
    await for (final eventText in streamFetchFreeNodeSourcesJson(
      inputJson: json.encode(rustInput),
    )) {
      final decodedEvent = json.decode(eventText);
      if (decodedEvent is! Map) {
        throw const FormatException('免费节点 Rust 流输出格式错误');
      }
      final eventKind = decodedEvent['kind']?.toString();
      if (eventKind == 'partial' || eventKind == 'final') {
        final filePath = decodedEvent['filePath']?.toString() ?? '';
        final fileProxyCount =
            int.tryParse('${decodedEvent['proxyCount'] ?? 0}') ?? 0;
        if (filePath.isEmpty || fileProxyCount <= 0) {
          throw const FormatException('免费节点 Rust 配置文件输出无效');
        }
        final fileResult = FreeNodesUpdateResult(
          filePath: filePath,
          proxyCount: fileProxyCount,
          sources: List.unmodifiable(sourceStatuses),
        );
        if (eventKind == 'partial') {
          if (onPartialResult != null) {
            await onPartialResult(fileResult);
          } else {
            try {
              await File(filePath).delete();
            } catch (_) {}
          }
        } else {
          completedResult = fileResult;
          progressProxyCount = fileProxyCount;
        }
        continue;
      }
      if (eventKind == 'started') {
        progressProxyCount =
            int.tryParse('${decodedEvent['proxyCount'] ?? 0}') ?? 0;
        onProgress?.call(
          FreeNodesProgress(
            operation: '获取中',
            completed: 0,
            total: totalSources,
            proxyCount: progressProxyCount,
          ),
        );
        continue;
      }

      final sourceId = decodedEvent['sourceId']?.toString();
      final source = sourceId == null ? null : plannedSourcesById[sourceId];
      if (source == null) continue;
      final rawOutput = decodedEvent['output'];
      final sourceResult = _RustSourceFetchResult(
        source: source,
        output: rawOutput is Map ? Map<String, dynamic>.from(rawOutput) : null,
        error: decodedEvent['error'],
      );
      final output = sourceResult.output;
      final rawStatuses = output?['sources'];
      final candidateStatuses = rawStatuses is List
          ? rawStatuses
                .whereType<Map>()
                .map(_freeNodeSourceStatusFromMap)
                .toList(growable: false)
          : const <FreeNodeSourceStatus>[];
      final candidateSucceeded = candidateStatuses.any(
        (status) => status.success,
      );
      final sourceProxyCount =
          int.tryParse('${output?['proxyCount'] ?? 0}') ?? 0;
      final sourceSucceeded = candidateSucceeded && sourceProxyCount > 0;
      if (sourceSucceeded) {
        successfulSources++;
      } else {
        failedSources++;
      }
      progressProxyCount =
          int.tryParse(
            '${decodedEvent['cumulativeProxyCount'] ?? progressProxyCount}',
          ) ??
          progressProxyCount;
      final messages = candidateStatuses
          .map((status) => status.message)
          .whereType<String>()
          .where((message) => message.trim().isNotEmpty)
          .toSet();
      sourceStatuses.add(
        FreeNodeSourceStatus(
          url: source.seed,
          success: sourceSucceeded,
          proxyCount: sourceProxyCount,
          sourceId: source.id,
          sourceLabel: source.label,
          updateIntervalHours: source.updateIntervalHours,
          fetchedAt: DateTime.now(),
          message:
              sourceResult.error?.toString() ?? messages.take(3).join('; '),
        ),
      );
      if (sourceSucceeded) {
        final fetchTimes = output?['fetchTimes'];
        if (fetchTimes is Map) {
          sourceFetchTimes.addAll(
            fetchTimes.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          );
        } else {
          sourceFetchTimes[source.id] = DateTime.now().toIso8601String();
        }
      }
      completedSources++;
      onProgress?.call(
        FreeNodesProgress(
          operation: '已完成 $completedSources/$totalSources 个来源',
          completed: completedSources,
          total: totalSources,
          successfulSources: successfulSources,
          failedSources: failedSources,
          proxyCount: progressProxyCount,
          sourceId: source.id,
          url: source.seed,
        ),
      );
    }
    await _saveSourceFetchTimes(sourceFetchTimes);
    final result = completedResult;
    if (result == null) {
      throw const FormatException('免费节点 Rust 未返回最终配置');
    }
    onProgress?.call(
      FreeNodesProgress(
        operation: '已完成',
        completed: completedSources,
        total: totalSources,
        successfulSources: successfulSources,
        failedSources: failedSources,
        proxyCount: result.proxyCount,
        done: true,
      ),
    );
    return result;
  }

  FreeNodeSourceStatus _freeNodeSourceStatusFromMap(Map source) {
    return FreeNodeSourceStatus(
      url: source['url']?.toString() ?? '',
      success: source['success'] == true,
      proxyCount: int.tryParse('${source['proxyCount'] ?? 0}') ?? 0,
      sourceId: source['sourceId']?.toString(),
      sourceLabel: source['sourceLabel']?.toString(),
      updateIntervalHours: int.tryParse(
        '${source['updateIntervalHours'] ?? ''}',
      ),
      fetchedAt: DateTime.tryParse(source['fetchedAt']?.toString() ?? ''),
      message: source['message']?.toString(),
    );
  }

  FreeNodesUpdateResult _buildUpdateResult(
    List<_DatedProxy> proxies, {
    required _FreeNodeSourceCatalog catalog,
    required bool autoPrefer,
    required List<FreeNodeSourceStatus> sources,
  }) {
    final merged = _deduplicateAndName(proxies);
    final config = _buildClashConfig(
      merged,
      catalog: catalog,
      autoPrefer: autoPrefer,
    );
    return FreeNodesUpdateResult(
      bytes: Uint8List.fromList(utf8.encode(yaml.encode(config))),
      proxyCount: merged.length,
      sources: sources,
    );
  }

  Future<FreeNodesUpdateResult> _fetchMergedConfigDart({
    String? existingConfigText,
    Set<String>? sourceIds,
    FreeNodesProgressCallback? onProgress,
    FreeNodesPartialResultCallback? onPartialResult,
  }) async {
    final statusMap = <String, FreeNodeSourceStatus>{};
    onProgress?.call(
      const FreeNodesProgress(
        operation: '\u6b63\u5728\u51c6\u5907\u6765\u6e90',
      ),
    );
    final catalog = await _loadEffectiveSourceCatalog();
    final preferenceState = await getPreferenceState();
    final autoPreferDuringFetch = preferenceState.autoPrefer;
    final candidates = await _resolveCandidateUrls(
      catalog,
      statusMap,
      onProgress,
      sourceIds: sourceIds,
    );
    final proxies = <_DatedProxy>[];
    final successfulFamilies = <String>{};
    final sourceFetchTimes = <String, String>{};
    final completedSourceIds = <String>{};
    final remainingCandidatesBySource = <String, int>{};
    for (final candidate in candidates) {
      remainingCandidatesBySource.update(
        candidate.source.id,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final totalSources = remainingCandidatesBySource.length;
    var completedSources = 0;

    int successfulCompletedSources() {
      return completedSourceIds.where(successfulFamilies.contains).length;
    }

    FreeNodesUpdateResult buildResultFrom(List<_DatedProxy> freshProxies) {
      final existingProxies = _extractExistingDatedProxies(
        existingConfigText,
        catalog,
        cleanupExpired: freshProxies.isNotEmpty,
      );
      final effectiveProxies = freshProxies.isEmpty
          ? existingProxies
          : <_DatedProxy>[...freshProxies, ...existingProxies];
      final merged = _deduplicateAndName(effectiveProxies);
      final config = _buildClashConfig(
        merged,
        catalog: catalog,
        autoPrefer: autoPreferDuringFetch,
      );
      return FreeNodesUpdateResult(
        bytes: Uint8List.fromList(utf8.encode(yaml.encode(config))),
        proxyCount: merged.length,
        sources: statusMap.values.toList(growable: false),
      );
    }

    Future<void> fetchCandidate(_ResolvedConfigCandidate candidate) async {
      final url = candidate.url;
      final source = candidate.source;
      onProgress?.call(
        FreeNodesProgress(
          operation: '\u6b63\u5728\u83b7\u53d6 ${source.label}',
          completed: completedSources,
          total: totalSources,
          successfulSources: successfulCompletedSources(),
          failedSources: completedSources - successfulCompletedSources(),
          proxyCount: proxies.length,
          sourceId: source.id,
          url: url,
        ),
      );
      try {
        final text = await fetcher(url).timeout(fetchTimeout);
        final fetchedAt = DateTime.now();
        var parsed = await parseProxiesFast(text);
        if (parsed.isEmpty) {
          parsed = await _fetchProviderFollowUpProxies(text, url);
        }
        if (parsed.isEmpty) {
          statusMap[url] = FreeNodeSourceStatus(
            url: url,
            success: false,
            proxyCount: 0,
            sourceId: source.id,
            sourceLabel: source.label,
            updateIntervalHours: source.updateIntervalHours,
            fetchedAt: fetchedAt,
            message: '未解析到可用 Clash YAML 节点',
          );
          return;
        }
        statusMap[url] = FreeNodeSourceStatus(
          url: url,
          success: true,
          proxyCount: parsed.length,
          sourceId: source.id,
          sourceLabel: source.label,
          updateIntervalHours: source.updateIntervalHours,
          fetchedAt: fetchedAt,
        );
        proxies.addAll(
          parsed.map(
            (proxy) => _DatedProxy(
              proxy: proxy,
              dateLabel: _formatDateGroupLabel(DateTime.now()),
              dateToken: _todayDateToken(),
              sourceId: source.id,
              sourceLabel: source.label,
              staleTimeoutHours: source.staleTimeoutHours,
            ),
          ),
        );
        successfulFamilies.add(source.id);
        sourceFetchTimes[source.id] = fetchedAt.toIso8601String();
      } catch (e) {
        final fetchedAt = DateTime.now();
        statusMap[url] = FreeNodeSourceStatus(
          url: url,
          success: false,
          proxyCount: 0,
          sourceId: source.id,
          sourceLabel: source.label,
          updateIntervalHours: source.updateIntervalHours,
          fetchedAt: fetchedAt,
          message: e.toString(),
        );
      } finally {
        final remaining = (remainingCandidatesBySource[source.id] ?? 1) - 1;
        remainingCandidatesBySource[source.id] = remaining;
        if (remaining <= 0) {
          completedSourceIds.add(source.id);
          completedSources++;
          if (successfulFamilies.contains(source.id)) {
            await onPartialResult?.call(buildResultFrom(proxies));
          }
        }
        onProgress?.call(
          FreeNodesProgress(
            operation: '已完成 $completedSources/$totalSources 个来源',
            completed: completedSources,
            total: totalSources,
            successfulSources: successfulCompletedSources(),
            failedSources: completedSources - successfulCompletedSources(),
            proxyCount: proxies.length,
            sourceId: source.id,
            url: url,
          ),
        );
      }
    }

    var nextIndex = 0;
    final concurrency = preferenceState.fetchConcurrency.clamp(
      1,
      max(1, candidates.length),
    );
    Future<void> worker() async {
      while (nextIndex < candidates.length) {
        final candidate = candidates[nextIndex++];
        await fetchCandidate(candidate);
      }
    }

    await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
    await _saveSourceFetchTimes(sourceFetchTimes);

    onProgress?.call(
      FreeNodesProgress(
        operation: '\u6b63\u5728\u5408\u5e76\u8282\u70b9',
        completed: completedSources,
        total: totalSources,
        successfulSources: successfulCompletedSources(),
        failedSources: completedSources - successfulCompletedSources(),
        proxyCount: proxies.length,
      ),
    );
    final result = buildResultFrom(proxies);
    onProgress?.call(
      FreeNodesProgress(
        operation: '\u5df2\u5b8c\u6210',
        completed: totalSources,
        total: totalSources,
        successfulSources: successfulFamilies.length,
        failedSources: totalSources - successfulFamilies.length,
        proxyCount: result.proxyCount,
        done: true,
      ),
    );
    return result;
  }

  Future<List<_ResolvedConfigCandidate>> _resolveCandidateUrls(
    _FreeNodeSourceCatalog catalog,
    Map<String, FreeNodeSourceStatus> statusMap,
    FreeNodesProgressCallback? onProgress, {
    Set<String>? sourceIds,
  }) async {
    final configs = <String, _FreeNodeSourceDefinition>{};
    final visitedPages = <String>{};
    final visitedPageKeys = <String>{};
    final queue = ListQueue<_DiscoveryCandidate>();
    var crawledPages = 0;

    final enabledIds = await _loadEnabledSourceIds(catalog);
    final targetIds = sourceIds == null
        ? enabledIds
        : enabledIds.intersection(sourceIds);
    if (targetIds.isEmpty) return const [];
    final sources = catalog.sources
        .where((source) => targetIds.contains(source.id))
        .toList(growable: false);

    void addConfig(String url, _FreeNodeSourceDefinition source) {
      final normalized = _normalizeUrl(url);
      if (normalized.isEmpty || !_isStrongConfigCandidate(normalized)) return;
      configs.putIfAbsent(_canonicalConfigUrl(normalized), () => source);
    }

    void addPage(String url, _FreeNodeSourceDefinition source, int depth) {
      final normalized = _normalizeUrl(url);
      if (normalized.isEmpty || !_isPageCandidate(normalized)) return;
      final pageUrl = _canonicalPageFetchKey(normalized);
      if (visitedPages.add(pageUrl) && visitedPageKeys.add(pageUrl)) {
        queue.add(_DiscoveryCandidate(pageUrl, depth, source));
      }
    }

    for (var sourceIndex = 0; sourceIndex < sources.length; sourceIndex++) {
      final source = sources[sourceIndex];
      onProgress?.call(
        FreeNodesProgress(
          operation: '\u6b63\u5728\u89e3\u6790\u6765\u6e90 ${source.label}',
          completed: sourceIndex,
          total: sources.length,
          sourceId: source.id,
          url: source.seed,
        ),
      );
      final url = _normalizeUrl(source.seed);
      if (url.isEmpty) continue;
      _markSourceStatus(statusMap, source, url, true, 'seed');
      if (_isStrongConfigCandidate(url)) {
        addConfig(url, source);
      }
      final sourceCandidates = _sourceCandidates(source, catalog.lookbackDays);
      for (final configUrl in sourceCandidates) {
        addConfig(configUrl, source);
      }
      for (final pageUrl in sourceCandidates.where(_isPageCandidate)) {
        addPage(pageUrl, source, 0);
      }
      for (final rawUrl in source.rawCandidates.map(_normalizeUrl)) {
        if (_isStrongConfigCandidate(rawUrl)) {
          addConfig(rawUrl, source);
        } else {
          addPage(rawUrl, source, 0);
        }
      }
      if (source.githubDiscovery) {
        for (final rawUrl in _githubRawSeedCandidates(url)) {
          addConfig(rawUrl, source);
        }
        for (final apiUrl in _githubDiscoveryCandidates(url)) {
          addPage(apiUrl, source, 0);
        }
      }
      if (source.pageDiscovery) {
        addPage(url, source, 0);
      }
    }

    final maxDiscoveryPages =
        configs.length >= _freeNodesDiscoveryConfigThreshold
        ? _freeNodesFastDiscoveryPageLimit
        : _freeNodesFullDiscoveryPageLimit;
    while (queue.isNotEmpty &&
        configs.length < _freeNodesConfigCandidateLimit &&
        crawledPages < maxDiscoveryPages) {
      final current = queue.removeFirst();
      try {
        onProgress?.call(
          FreeNodesProgress(
            operation: '\u6b63\u5728\u67e5\u627e\u8ba2\u9605\u94fe\u63a5',
            completed: crawledPages,
            total: maxDiscoveryPages,
            proxyCount: configs.length,
            url: current.url,
          ),
        );
        crawledPages++;
        final text = await _fetchDiscoveryPageText(current.url);
        final discovery = _discoverUrls(text, baseUrl: current.url);
        for (final configUrl in discovery.configUrls) {
          addConfig(configUrl, current.source);
        }
        if (current.depth < 2) {
          for (final pageUrl in discovery.pageUrls.where(_isRelevantPageUrl)) {
            addPage(pageUrl, current.source, current.depth + 1);
          }
        }
        _markSourceStatus(
          statusMap,
          current.source,
          current.url,
          true,
          '发现配置 ${discovery.configUrls.length} / 页面 ${discovery.pageUrls.length}',
        );
      } catch (e) {
        _markSourceStatus(
          statusMap,
          current.source,
          current.url,
          false,
          e.toString(),
        );
      }
    }

    return _prioritizeConfigUrls(
      configs,
    ).take(_freeNodesConfigCandidateLimit).toList(growable: false);
  }

  Future<String> _fetchDiscoveryPageText(String url) async {
    final candidates = [..._githubMirrorUrls(url), url];
    Object? lastError;
    for (final candidate in candidates) {
      try {
        return await fetcher(candidate).timeout(fetchTimeout);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? StateError('发现页面抓取失败: $url');
  }

  Future<List<FreeNodeSourceOption>> getSourceOptions() async {
    final catalog = await _loadEffectiveSourceCatalog();
    final fetchTimes = await _loadSourceFetchTimes();
    final fetchTimeoutOverrides = await getSourceFetchTimeoutOverrides();
    final defaultFetchTimeoutSeconds = fetchTimeout.inSeconds.clamp(3, 120);
    return catalog.sources
        .map(
          (source) => FreeNodeSourceOption(
            id: source.id,
            label: source.label,
            seed: source.seed,
            updateIntervalHours: source.updateIntervalHours,
            staleTimeoutHours: source.staleTimeoutHours,
            fetchTimeoutSeconds:
                fetchTimeoutOverrides[source.id] ?? defaultFetchTimeoutSeconds,
            lastFetchTime: fetchTimes[source.id],
          ),
        )
        .toList(growable: false);
  }

  Future<Set<String>> getDueSourceIds({DateTime? now}) async {
    final current = now ?? DateTime.now();
    final catalog = await _loadEffectiveSourceCatalog();
    final enabledIds = await _loadEnabledSourceIds(catalog);
    final fetchTimes = await _loadSourceFetchTimes();
    return catalog.sources
        .where((source) => enabledIds.contains(source.id))
        .where((source) {
          final lastFetchTime = fetchTimes[source.id];
          if (lastFetchTime == null) return true;
          return !lastFetchTime
              .add(Duration(hours: source.updateIntervalHours))
              .isAfter(current);
        })
        .map((source) => source.id)
        .toSet();
  }

  Future<Set<String>> getEnabledSourceIds() async {
    final catalog = await _loadSourceCatalog();
    return _loadEnabledSourceIds(catalog);
  }

  Future<void> saveEnabledSourceIds(Set<String> ids) async {
    await preferences.setStringList(
      freeNodesSelectedSourcesKey,
      ids.toList(growable: false)..sort(),
    );
  }

  Future<Set<String>> _loadEnabledSourceIds(
    _FreeNodeSourceCatalog catalog,
  ) async {
    final allIds = catalog.sources.map((source) => source.id).toSet();
    final declaredDefaults = catalog.defaultSourceIds.intersection(allIds);
    final defaultIds = declaredDefaults.isEmpty ? allIds : declaredDefaults;
    final overrideIds = enabledSourceIds;
    if (overrideIds != null) {
      final filtered = overrideIds.intersection(allIds);
      return filtered.isEmpty ? defaultIds : filtered;
    }
    final saved = await preferences.getStringList(freeNodesSelectedSourcesKey);
    if (saved == null || saved.isEmpty) return defaultIds;
    final filtered = saved.toSet().intersection(allIds);
    return filtered.isEmpty ? defaultIds : filtered;
  }

  Future<_FreeNodeSourceCatalog> _loadSourceCatalog() async {
    final cached = _sourceCatalog;
    if (cached != null) return cached;
    try {
      final text =
          sourceCatalogJson ??
          await rootBundle.loadString(freeNodesSourceAssetPath);
      final catalog = _FreeNodeSourceCatalog.fromJson(text);
      _sourceCatalog = catalog.sources.isEmpty
          ? _FreeNodeSourceCatalog.fallback()
          : catalog;
    } catch (_) {
      _sourceCatalog = _FreeNodeSourceCatalog.fallback();
    }
    return _sourceCatalog!;
  }

  Future<_FreeNodeSourceCatalog> _loadEffectiveSourceCatalog() async {
    final catalog = await _loadSourceCatalog();
    final timeoutOverrides = await getSourceTimeoutOverrides();
    if (timeoutOverrides.isEmpty) return catalog;
    return _FreeNodeSourceCatalog(
      lookbackDays: catalog.lookbackDays,
      historyTimeoutHours: catalog.historyTimeoutHours,
      defaultSourceIds: catalog.defaultSourceIds,
      sources: catalog.sources
          .map(
            (source) =>
                source.copyWith(staleTimeoutHours: timeoutOverrides[source.id]),
          )
          .toList(growable: false),
    );
  }

  Future<FreeNodesPreferenceState> getPreferenceState() async {
    final catalog = await _loadSourceCatalog();
    final enabledSourceCount = (await _loadEnabledSourceIds(catalog)).length;
    final maxFetchConcurrency = max(1, catalog.sources.length);
    final fetchConcurrency =
        await preferences.getInt(freeNodesFetchConcurrencyKey) ??
        max(1, enabledSourceCount);
    final autoPrefer = await preferences.getBool(
      freeNodesAutoPreferKey,
      defaultValue: false,
    );
    final deleteExpiredOnPrefer = await preferences.getBool(
      freeNodesPreferDeleteExpiredKey,
      defaultValue: false,
    );
    return FreeNodesPreferenceState(
      fetchConcurrency: fetchConcurrency.clamp(1, maxFetchConcurrency),
      autoPrefer: autoPrefer,
      deleteExpiredOnPrefer: deleteExpiredOnPrefer,
    );
  }

  Future<void> saveFetchConcurrency(int value) async {
    final catalog = await _loadSourceCatalog();
    await preferences.setInt(
      freeNodesFetchConcurrencyKey,
      value.clamp(1, max(1, catalog.sources.length)),
    );
  }

  Future<void> saveAutoPrefer(bool value) async {
    await preferences.setBool(freeNodesAutoPreferKey, value);
  }

  Future<void> saveDeleteExpiredOnPrefer(bool value) async {
    await preferences.setBool(freeNodesPreferDeleteExpiredKey, value);
  }

  String _autoPreferDateValue({DateTime? now}) {
    final current = now ?? DateTime.now();
    return _formatDateLabel(current);
  }

  Future<bool> wasAutoPreferredToday({DateTime? now}) async {
    final saved = await preferences.getString(freeNodesLastAutoPreferDateKey);
    return saved == _autoPreferDateValue(now: now);
  }

  Future<void> markAutoPreferredToday({DateTime? now}) async {
    await preferences.setString(
      freeNodesLastAutoPreferDateKey,
      _autoPreferDateValue(now: now),
    );
  }

  Future<Map<String, int>> getSourceTimeoutOverrides() async {
    final text = await preferences.getString(freeNodesSourceTimeoutsKey);
    if (text == null || text.isEmpty) return const {};
    try {
      final data = json.decode(text);
      if (data is! Map) return const {};
      return data.map(
        (key, value) => MapEntry(
          key.toString(),
          _clampHours(int.tryParse(value.toString()) ?? 36),
        ),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<void> saveSourceTimeoutHours(String sourceId, int hours) async {
    final overrides = Map<String, int>.from(await getSourceTimeoutOverrides());
    overrides[sourceId] = _clampHours(hours);
    await preferences.setString(
      freeNodesSourceTimeoutsKey,
      json.encode(overrides),
    );
  }

  int _clampHours(int hours) {
    return hours.clamp(1, 720).toInt();
  }

  Future<Map<String, int>> getSourceFetchTimeoutOverrides() async {
    final text = await preferences.getString(freeNodesSourceFetchTimeoutsKey);
    if (text == null || text.isEmpty) return const {};
    try {
      final data = json.decode(text);
      if (data is! Map) return const {};
      return data.map(
        (key, value) => MapEntry(
          key.toString(),
          _clampFetchTimeoutSeconds(int.tryParse(value.toString()) ?? 10),
        ),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<void> saveSourceFetchTimeoutSeconds(
    String sourceId,
    int seconds,
  ) async {
    final overrides = Map<String, int>.from(
      await getSourceFetchTimeoutOverrides(),
    );
    overrides[sourceId] = _clampFetchTimeoutSeconds(seconds);
    await preferences.setString(
      freeNodesSourceFetchTimeoutsKey,
      json.encode(overrides),
    );
  }

  int _clampFetchTimeoutSeconds(int seconds) {
    return seconds.clamp(3, 120).toInt();
  }

  Future<Map<String, DateTime>> _loadSourceFetchTimes() async {
    final text = await preferences.getString(freeNodesFetchTimesKey);
    if (text == null || text.isEmpty) return const {};
    try {
      final data = json.decode(text);
      if (data is! Map) return const {};
      return {
        for (final entry in data.entries)
          if (DateTime.tryParse(entry.value.toString()) != null)
            entry.key.toString(): DateTime.parse(entry.value.toString()),
      };
    } catch (_) {
      return const {};
    }
  }

  Future<void> _saveSourceFetchTimes(Map<String, String> values) async {
    if (values.isEmpty) return;
    final fetchTimes = await _loadSourceFetchTimes();
    final data = {
      for (final entry in fetchTimes.entries)
        entry.key: entry.value.toIso8601String(),
      ...values,
    };
    await preferences.setString(freeNodesFetchTimesKey, json.encode(data));
  }

  Future<FreeNodesPreferResult> preferProfile(
    Profile profile, {
    bool? deleteExpiredGroups,
  }) async {
    final file = await profile.file;
    if (!await file.exists()) {
      throw '免费节点配置文件不存在，已保留原配置';
    }
    final text = utf8.decode(await file.readAsBytes());
    final cleanupExpired =
        deleteExpiredGroups ??
        (await getPreferenceState()).deleteExpiredOnPrefer;
    final result = await preferConfigText(
      text,
      deleteExpiredGroups: cleanupExpired,
    );
    final savedProfile = await profile
        .copyWith(subscriptionInfo: SubscriptionInfo(total: result.afterCount))
        .saveFile(result.bytes);
    return FreeNodesPreferResult(
      profile: savedProfile,
      bytes: result.bytes,
      beforeCount: result.beforeCount,
      afterCount: result.afterCount,
      removedCount: result.removedCount,
    );
  }

  Future<FreeNodesPreferResult> preferConfigText(
    String text, {
    bool deleteExpiredGroups = false,
  }) async {
    if (!_usesCustomFetcher) {
      await ensureRustApiInitialized();
      final now = DateTime.now();
      final outputText = await preferFreeNodesConfigJson(
        inputJson: json.encode({
          'configText': text,
          'historyTimeoutHours':
              (await _loadEffectiveSourceCatalog()).historyTimeoutHours,
          'nowDayNumber':
              DateTime.utc(
                now.year,
                now.month,
                now.day,
              ).millisecondsSinceEpoch ~/
              Duration.millisecondsPerDay,
          'todayToken': _todayDateToken(),
          'deleteExpiredGroups': deleteExpiredGroups,
        }),
      );
      final output = json.decode(outputText);
      if (output is! Map) {
        throw '\u4f18\u9009\u8282\u70b9 Rust \u8f93\u51fa\u683c\u5f0f\u9519\u8bef';
      }
      final afterCount = int.tryParse('${output['afterCount'] ?? 0}') ?? 0;
      if (afterCount <= 0) {
        throw '\u4f18\u9009\u540e\u6ca1\u6709\u53ef\u7528\u8282\u70b9\uff0c\u5df2\u4fdd\u7559\u539f\u914d\u7f6e';
      }
      final yamlText = output['yaml']?.toString() ?? '';
      if (yamlText.trim().isEmpty) {
        throw '\u4f18\u9009\u7ed3\u679c\u4e3a\u7a7a\uff0c\u5df2\u4fdd\u7559\u539f\u914d\u7f6e';
      }
      final beforeCount = int.tryParse('${output['beforeCount'] ?? 0}') ?? 0;
      final removedCount =
          int.tryParse('${output['removedCount'] ?? 0}') ??
          max(beforeCount - afterCount, 0);
      return FreeNodesPreferResult(
        bytes: Uint8List.fromList(utf8.encode(yamlText)),
        beforeCount: beforeCount,
        afterCount: afterCount,
        removedCount: removedCount,
      );
    }
    final catalog = await _loadEffectiveSourceCatalog();
    final beforeCount = _countUsableProxies(text);
    final cleaned = _deduplicateAndName(
      _extractExistingDatedProxies(
        text,
        catalog,
        cleanupExpired: deleteExpiredGroups,
      ),
    );
    if (cleaned.isEmpty) {
      throw '\u4f18\u9009\u540e\u6ca1\u6709\u53ef\u7528\u8282\u70b9\uff0c\u5df2\u4fdd\u7559\u539f\u914d\u7f6e';
    }
    final config = _buildClashConfig(
      cleaned,
      catalog: catalog,
      autoPrefer: true,
    );
    final bytes = Uint8List.fromList(utf8.encode(yaml.encode(config)));
    return FreeNodesPreferResult(
      bytes: bytes,
      beforeCount: beforeCount,
      afterCount: cleaned.length,
      removedCount: max(beforeCount - cleaned.length, 0),
    );
  }

  Future<FreeNodesGroupEditResult> preferGroup(
    Profile profile,
    String groupName,
  ) async {
    return _rewriteGroup(
      profile,
      groupName,
      mode: _FreeNodesGroupEditMode.keep,
    );
  }

  Future<FreeNodesGroupEditResult> deleteDateGroup(
    Profile profile,
    String groupName,
  ) async {
    return _rewriteGroup(
      profile,
      groupName,
      mode: _FreeNodesGroupEditMode.moveToTreasure,
    );
  }

  Future<FreeNodesGroupEditResult> _rewriteGroup(
    Profile profile,
    String groupName, {
    required _FreeNodesGroupEditMode mode,
  }) async {
    final file = await profile.file;
    if (!await file.exists()) {
      throw '免费节点配置文件不存在';
    }
    final normalizedGroupName = _normalizeDateGroupLabel(groupName);
    final isMainGroup = normalizedGroupName == freeNodesGroupName;
    final isTreasureGroup = _isFreeNodesTreasureGroup(normalizedGroupName);
    final groupToken = _dateTokenFromLabel(normalizedGroupName);
    if (mode == _FreeNodesGroupEditMode.moveToTreasure && isMainGroup) {
      throw '不能删除全部免费节点分类';
    }
    if (mode == _FreeNodesGroupEditMode.moveToTreasure &&
        !isTreasureGroup &&
        groupToken == _todayDateToken()) {
      throw '不能删除本日免费节点';
    }
    final text = utf8.decode(await file.readAsBytes());
    final result = await _rewriteGroupConfigText(text, groupName, mode: mode);
    final savedProfile = await profile
        .copyWith(subscriptionInfo: SubscriptionInfo(total: result.afterCount))
        .saveFile(result.bytes);
    return FreeNodesGroupEditResult(
      profile: savedProfile,
      bytes: result.bytes,
      beforeCount: result.beforeCount,
      afterCount: result.afterCount,
      affectedCount: result.affectedCount,
      groupName: result.groupName,
    );
  }

  Future<FreeNodesGroupEditResult> preferGroupConfigText(
    String text,
    String groupName,
  ) {
    return _rewriteGroupConfigText(
      text,
      groupName,
      mode: _FreeNodesGroupEditMode.keep,
    );
  }

  Future<FreeNodesGroupEditResult> deleteDateGroupConfigText(
    String text,
    String groupName,
  ) {
    return _rewriteGroupConfigText(
      text,
      groupName,
      mode: _FreeNodesGroupEditMode.moveToTreasure,
    );
  }

  Future<FreeNodesGroupEditResult> _rewriteGroupConfigText(
    String text,
    String groupName, {
    _FreeNodesGroupEditMode mode = _FreeNodesGroupEditMode.moveToTreasure,
  }) async {
    final catalog = await _loadEffectiveSourceCatalog();
    final normalizedGroupName = _normalizeDateGroupLabel(groupName);
    final isMainGroup = normalizedGroupName == freeNodesGroupName;
    final groupToken = _dateTokenFromLabel(normalizedGroupName);
    if (mode == _FreeNodesGroupEditMode.moveToTreasure && isMainGroup) {
      throw '不能删除全部免费节点分类';
    }
    if (mode == _FreeNodesGroupEditMode.moveToTreasure &&
        groupToken == _todayDateToken()) {
      throw '不能删除本日免费节点';
    }
    final beforeCount = _countUsableProxies(text);
    final selectedProxyNames =
        !isMainGroup &&
            !_isFreeNodesTreasureGroup(normalizedGroupName) &&
            groupToken <= 0
        ? _proxyNamesForGroup(text, groupName)
        : null;
    final proxies = _extractExistingDatedProxies(
      text,
      catalog,
      cleanupExpired: false,
    );
    var affectedCount = 0;
    final rewritten = proxies
        .map((item) {
          final matchesGroup = isMainGroup
              ? true
              : _isFreeNodesTreasureGroup(normalizedGroupName)
              ? _isFreeNodesTreasureGroup(item.dateLabel)
              : groupToken > 0
              ? item.dateLabel == normalizedGroupName
              : selectedProxyNames?.contains(item.proxy['name']?.toString()) ==
                    true;
          if (!matchesGroup) return item;
          affectedCount++;
          return switch (mode) {
            _FreeNodesGroupEditMode.keep => item,
            _FreeNodesGroupEditMode.moveToTreasure => _DatedProxy(
              proxy: item.proxy,
              dateLabel: freeNodesTreasureGroupName,
              dateToken: 0,
              sourceId: item.sourceId,
              sourceLabel: item.sourceLabel,
              sourceIds: item.effectiveSourceIds,
              sourceLabels: item.effectiveSourceLabels,
              staleTimeoutHours: item.staleTimeoutHours,
            ),
          };
        })
        .toList(growable: false);
    if (affectedCount == 0) {
      throw '未找到 $normalizedGroupName 的免费节点';
    }
    final cleaned = _deduplicateAndName(rewritten);
    if (cleaned.isEmpty) {
      throw '没有可用免费节点，已取消操作';
    }
    final config = _buildClashConfig(
      cleaned,
      catalog: catalog,
      autoPrefer: true,
    );
    final yamlText = yaml.encode(config);
    if (yamlText.trim().isEmpty) {
      throw '优选结果为空，已保留原配置';
    }
    final bytes = Uint8List.fromList(utf8.encode(yamlText));
    return FreeNodesGroupEditResult(
      bytes: bytes,
      beforeCount: beforeCount,
      afterCount: cleaned.length,
      affectedCount: affectedCount,
      groupName: normalizedGroupName,
    );
  }

  Set<String> _proxyNamesForGroup(String text, String groupName) {
    if (text.trim().isEmpty) return const {};
    try {
      final value = _toPlain(yaml_parser.loadYaml(text));
      if (value is! Map) return const {};
      final rawGroups = value['proxy-groups'];
      if (rawGroups is! List) return const {};
      final normalizedGroupName = _normalizeDateGroupLabel(groupName);
      for (final rawGroup in rawGroups.whereType<Map>()) {
        final rawGroupName = rawGroup['name']?.toString() ?? '';
        final normalizedRawGroupName = _normalizeDateGroupLabel(rawGroupName);
        if (rawGroupName != groupName &&
            normalizedRawGroupName != normalizedGroupName) {
          continue;
        }
        final rawNames = rawGroup['proxies'];
        if (rawNames is! List) return const {};
        return rawNames.map((name) => name.toString()).toSet();
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  Set<String> _sourceCandidates(
    _FreeNodeSourceDefinition source,
    int lookbackDays,
  ) {
    final result = <String>{};
    final templates = [...source.pageTemplates, ...source.configTemplates];
    final List<int?> indices = source.indices.isEmpty
        ? const [null]
        : source.indices.map<int?>((index) => index).toList(growable: false);
    final today = DateTime.now();
    for (var offset = 0; offset < lookbackDays; offset++) {
      final date = today.subtract(Duration(days: offset));
      for (final template in templates) {
        for (final index in indices) {
          if (index == null && template.contains('{index}')) continue;
          result.add(_expandDateTemplate(template, date, index));
        }
      }
    }
    return result.map(_normalizeUrl).where((url) => url.isNotEmpty).toSet();
  }

  String _expandDateTemplate(String template, DateTime date, int? index) {
    final yyyy = date.year.toString();
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return template
        .replaceAll('{yyyy}', yyyy)
        .replaceAll('{yy}', yyyy.substring(2))
        .replaceAll('{mm}', mm)
        .replaceAll('{m}', date.month.toString())
        .replaceAll('{dd}', dd)
        .replaceAll('{d}', date.day.toString())
        .replaceAll('{yyyymmdd}', '$yyyy$mm$dd')
        .replaceAll('{index}', index?.toString() ?? '');
  }

  List<_ResolvedConfigCandidate> _prioritizeConfigUrls(
    Map<String, _FreeNodeSourceDefinition> urls,
  ) {
    final expanded = <String, _FreeNodeSourceDefinition>{};
    for (final entry in urls.entries) {
      final url = entry.key;
      final source = entry.value;
      for (final mirrorUrl in _githubMirrorUrls(url)) {
        expanded.putIfAbsent(mirrorUrl, () => source);
      }
      expanded.putIfAbsent(url, () => source);
    }
    final candidates = expanded.entries
        .map(
          (entry) =>
              _ResolvedConfigCandidate(url: entry.key, source: entry.value),
        )
        .toList(growable: false);
    return candidates..sort((a, b) {
      final dateCompare = _dateToken(b.url).compareTo(_dateToken(a.url));
      if (dateCompare != 0) return dateCompare;
      final rankCompare = a.source.rank.compareTo(b.source.rank);
      if (rankCompare != 0) return rankCompare;
      final priorityCompare = _configUrlPriority(
        a.url,
      ).compareTo(_configUrlPriority(b.url));
      if (priorityCompare != 0) return priorityCompare;
      return a.url.compareTo(b.url);
    });
  }

  int _configUrlPriority(String url) {
    final lower = url.toLowerCase();
    final rawMirrorIndex = _githubRawMirrorPrefixes.indexWhere(
      lower.startsWith,
    );
    if (rawMirrorIndex >= 0) return rawMirrorIndex;
    final pathMirrorIndex = _githubPathMirrorPrefixes.indexWhere(
      lower.startsWith,
    );
    if (pathMirrorIndex >= 0) {
      return _githubRawMirrorPrefixes.length + pathMirrorIndex;
    }
    final rawPathMirrorIndex = _githubRawPathMirrorPrefixes.indexWhere(
      lower.startsWith,
    );
    if (rawPathMirrorIndex >= 0) {
      return _githubRawMirrorPrefixes.length +
          _githubPathMirrorPrefixes.length +
          rawPathMirrorIndex;
    }
    if ((Uri.tryParse(url)?.host.toLowerCase()) ==
        'raw.githubusercontent.com') {
      return _githubRawMirrorPrefixes.length +
          _githubPathMirrorPrefixes.length +
          _githubRawPathMirrorPrefixes.length;
    }
    return _freeNodesConfigCandidateLimit;
  }

  Set<String> _githubMirrorUrls(String url) {
    final inputLower = url.toLowerCase();
    if (_githubRawMirrorPrefixes.any(inputLower.startsWith)) {
      return {};
    }
    final canonical = _canonicalConfigUrl(url);
    final host = Uri.tryParse(canonical)?.host.toLowerCase();
    if (host != 'raw.githubusercontent.com' && host != 'api.github.com') {
      return {};
    }
    return {
      for (final prefix in _githubRawMirrorPrefixes) '$prefix$canonical',
      ..._githubPathMirrorUrls(canonical),
    };
  }

  Set<String> _githubPathMirrorUrls(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.toLowerCase() != 'raw.githubusercontent.com') {
      return {};
    }
    final segments = uri.pathSegments;
    if (segments.length < 4) return {};
    final owner = segments[0];
    final repo = segments[1];
    var branch = segments[2];
    var pathStart = 3;
    if (segments.length >= 6 && branch == 'refs' && segments[3] == 'heads') {
      branch = segments[4];
      pathStart = 5;
    }
    final path = segments.skip(pathStart).join('/');
    if (path.isEmpty) return {};
    return {
      for (final prefix in _githubPathMirrorPrefixes)
        '$prefix$owner/$repo@$branch/$path',
      for (final prefix in _githubRawPathMirrorPrefixes)
        '$prefix$owner/$repo/$branch/$path',
    };
  }

  String _canonicalPageFetchKey(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.toLowerCase() != 'api.github.com') {
      return url;
    }
    final segments = uri.pathSegments;
    if (segments.length < 4 ||
        segments[0] != 'repos' ||
        segments[3] != 'contents') {
      return url;
    }
    final ref = uri.queryParameters['ref'];
    if (ref == null ||
        (ref.toLowerCase() != 'main' && ref.toLowerCase() != 'master')) {
      return url;
    }
    final path = segments.skip(4).join('/');
    final base =
        'https://api.github.com/repos/${segments[1]}/${segments[2]}/contents';
    return path.isEmpty ? base : '$base/$path';
  }

  String _canonicalConfigUrl(String url) {
    var value = _normalizeUrl(url);
    while (true) {
      final stripped = _stripKnownGithubMirrorPrefix(value);
      if (stripped == null) break;
      value = _normalizeUrl(stripped);
    }
    value = _githubPathMirrorToRaw(value) ?? value;
    return _githubRawRefsHeadsToBranch(value) ?? value;
  }

  String? _githubPathMirrorToRaw(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments;
    if (host == 'rawgithubusercontent.deno.dev') {
      if (segments.length < 4) return null;
      final path = segments.skip(3).join('/');
      if (path.isEmpty) return null;
      return 'https://raw.githubusercontent.com/${segments[0]}/${segments[1]}/${segments[2]}/$path';
    }
    if (host != 'cdn.jsdelivr.net' &&
        host != 'fastly.jsdelivr.net' &&
        host != 'gcore.jsdelivr.net') {
      return null;
    }
    if (segments.length < 4 || segments[0] != 'gh') return null;
    final repoBranch = segments[2];
    final marker = repoBranch.indexOf('@');
    if (marker <= 0 || marker == repoBranch.length - 1) return null;
    final repo = repoBranch.substring(0, marker);
    final branch = repoBranch.substring(marker + 1);
    final path = segments.skip(3).join('/');
    if (path.isEmpty) return null;
    return 'https://raw.githubusercontent.com/${segments[1]}/$repo/$branch/$path';
  }

  String? _stripKnownGithubMirrorPrefix(String url) {
    final lower = url.toLowerCase();
    for (final prefix in _githubRawMirrorPrefixes) {
      if (!lower.startsWith(prefix)) continue;
      final rest = url.substring(prefix.length);
      if (rest.startsWith('http://') || rest.startsWith('https://')) {
        return rest;
      }
    }
    return null;
  }

  String? _githubRawRefsHeadsToBranch(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.toLowerCase() != 'raw.githubusercontent.com') {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length < 6 ||
        segments[2] != 'refs' ||
        segments[3] != 'heads') {
      return null;
    }
    final path = segments.skip(5).join('/');
    if (path.isEmpty) return null;
    return 'https://raw.githubusercontent.com/${segments[0]}/${segments[1]}/${segments[4]}/$path';
  }

  int _dateToken(String url) {
    final match = RegExp(r'20\d{6}').firstMatch(url);
    final token = int.tryParse(match?.group(0) ?? '');
    if (token != null) return token;
    const freshFamilies = {
      'puddincat',
      'crossxx',
      'freenodebiz',
      'ripaojiedian',
      'freenodes',
      'flikify',
      'barabama',
      'free-clash-v2ray',
    };
    if (freshFamilies.contains(_sourceFamily(url))) {
      final now = DateTime.now();
      return int.tryParse(
            '${now.year}${now.month.toString().padLeft(2, '0')}'
            '${now.day.toString().padLeft(2, '0')}',
          ) ??
          0;
    }
    return 0;
  }

  String _sourceFamily(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('free-nodes/clashfree') ||
        lower.contains('/free-nodes/clashfree/')) {
      return 'github-free-nodes';
    }
    if (lower.contains('freeclashnode.com') ||
        lower.contains('node.freeclashnode.com')) {
      return 'freeclashnode';
    }
    if (lower.contains('oneclash.cc') || lower.contains('oss.oneclash.cc')) {
      return 'oneclash';
    }
    if (lower.contains('v2rayshare.net') ||
        lower.contains('static.v2rayshare.net')) {
      return 'v2rayshare';
    }
    if (lower.contains('clashgithub.com')) return 'clashgithub';
    if (lower.contains('clashnode.cc') || lower.contains('node.clashnode.cc')) {
      return 'clashnode';
    }
    if (lower.contains('datiya.com')) return 'datiya';
    if (lower.contains('puddincat/bestclash') ||
        lower.contains('/puddincat/bestclash/')) {
      return 'puddincat';
    }
    if (lower.contains('clashmeta.cc') || lower.contains('node.clashmeta.cc')) {
      return 'clashmeta';
    }
    if (lower.contains('crossxx-labs/free-proxy') ||
        lower.contains('/crossxx-labs/free-proxy/') ||
        lower.contains('clash.crossxx.com') ||
        lower.contains('freeclash.top/ui/free_clash')) {
      return 'crossxx';
    }
    if (lower.contains('freenode.biz')) return 'freenodebiz';
    if (lower.contains('ripaojiedian/freenode') ||
        lower.contains('/ripaojiedian/freenode/') ||
        lower.contains('down.nigx.cn/raw.githubusercontent.com/ripaojiedian')) {
      return 'ripaojiedian';
    }
    if (lower.contains('freenodes/freenodes') ||
        lower.contains('/freenodes/freenodes/') ||
        lower.contains('freenodes.github.io/freenodes')) {
      return 'freenodes';
    }
    if (lower.contains('flikify/free-node') ||
        lower.contains('/flikify/free-node/') ||
        lower.contains('a2470982985/getnode') ||
        lower.contains('/a2470982985/getnode/')) {
      return 'flikify';
    }
    if (lower.contains('barabama/freenodes') ||
        lower.contains('/barabama/freenodes/')) {
      return 'barabama';
    }
    if (lower.contains('free-clash-v2ray.github.io')) {
      return 'free-clash-v2ray';
    }
    return Uri.tryParse(url)?.host.toLowerCase() ?? url;
  }

  Set<String> _githubDiscoveryCandidates(String seed) {
    final parts = _githubOwnerRepo(seed);
    if (parts == null) return {};
    final owner = parts[0];
    final repo = parts[1];
    final seedBranch = _githubSeedBranch(seed);
    return {
      'https://api.github.com/repos/$owner/$repo',
      'https://api.github.com/repos/$owner/$repo/contents',
      if (seedBranch != null) ...{
        'https://api.github.com/repos/$owner/$repo/contents?ref=$seedBranch',
        'https://api.github.com/repos/$owner/$repo/git/trees/$seedBranch?recursive=1',
      },
      'https://api.github.com/repos/$owner/$repo/git/trees/main?recursive=1',
      'https://api.github.com/repos/$owner/$repo/git/trees/master?recursive=1',
    };
  }

  Set<String> _githubRawSeedCandidates(String seed) {
    final parts = _githubOwnerRepo(seed);
    if (parts == null) return {};
    final owner = parts[0];
    final repo = parts[1];
    final seedBranch = _githubSeedBranch(seed);
    final branches = <String>{?seedBranch, 'main', 'master'};
    final urls = {
      for (final branch in branches)
        for (final path in _githubRawSeedPaths)
          'https://raw.githubusercontent.com/$owner/$repo/$branch/$path',
    };
    final repoKey = '$owner/$repo'.toLowerCase();
    if (repoKey == 'crossxx-labs/free-proxy') {
      urls.add('http://clash.crossxx.com/');
      urls.add('https://www.freeclash.top/ui/free_clash');
    }
    return urls;
  }

  List<String>? _githubOwnerRepo(String seed) {
    final uri = Uri.tryParse(_canonicalConfigUrl(seed));
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments;
    if ((host == 'github.com' || host == 'raw.githubusercontent.com') &&
        segments.length >= 2) {
      return [segments[0], segments[1]];
    }
    if (host == 'api.github.com' &&
        segments.length >= 3 &&
        segments[0] == 'repos') {
      return [segments[1], segments[2]];
    }
    return null;
  }

  String? _githubSeedBranch(String seed) {
    final uri = Uri.tryParse(_canonicalConfigUrl(seed));
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    final segments = uri.pathSegments;
    String? branch;
    if (host == 'raw.githubusercontent.com' && segments.length >= 3) {
      branch = segments[2];
    } else if (host == 'github.com' &&
        segments.length >= 4 &&
        segments[2] == 'blob') {
      branch = segments[3];
    }
    if (branch == null || branch.trim().isEmpty) return null;
    final normalized = branch.trim();
    final lower = normalized.toLowerCase();
    if (lower == 'main' || lower == 'master' || lower == 'refs') {
      return null;
    }
    return normalized;
  }

  _DiscoveryResult _discoverUrls(String text, {required String baseUrl}) {
    final configUrls = <String>{};
    final pageUrls = <String>{};
    final base = Uri.tryParse(baseUrl);

    void addUrl(String value) {
      final normalized = _normalizeUrl(value);
      if (normalized.isEmpty) return;
      if (_isStrongConfigCandidate(normalized)) {
        configUrls.add(normalized);
      } else if (_isPageCandidate(normalized)) {
        pageUrls.add(normalized);
      }
    }

    void scanText(String value) {
      for (final match in _urlPattern.allMatches(value)) {
        addUrl(match.group(0) ?? '');
      }
      for (final match in _hrefPattern.allMatches(value)) {
        final href = match.group(1) ?? '';
        addUrl(base?.resolve(href).toString() ?? href);
      }
      _extractMetaRefreshUrls(value, base, addUrl);
      _extractJsonUrls(value, baseUrl: baseUrl, onUrl: addUrl);
    }

    scanText(text);
    for (final candidate in _embeddedBase64DecodedCandidates(text)) {
      scanText(candidate);
    }

    return _DiscoveryResult(configUrls: configUrls, pageUrls: pageUrls);
  }

  void _extractMetaRefreshUrls(
    String text,
    Uri? base,
    void Function(String url) onUrl,
  ) {
    for (final match in _metaTagPattern.allMatches(text)) {
      final tag = match.group(0) ?? '';
      if (!_metaRefreshPattern.hasMatch(tag)) continue;
      final contentMatch = _contentAttributePattern.firstMatch(tag);
      final content =
          contentMatch?.group(1) ??
          contentMatch?.group(2) ??
          contentMatch?.group(3) ??
          '';
      final urlMatch = _metaRefreshUrlPattern.firstMatch(content);
      if (urlMatch == null) continue;
      final value = _stripMetaRefreshUrl(content.substring(urlMatch.end));
      if (value.isEmpty) continue;
      onUrl(base?.resolve(value).toString() ?? value);
    }
  }

  String _stripMetaRefreshUrl(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return '';
    normalized = normalized.replaceAll('&amp;', '&');
    final first = normalized[0];
    if (first == '"' || first == "'") {
      normalized = normalized.substring(1);
      final end = normalized.indexOf(first);
      if (end >= 0) {
        normalized = normalized.substring(0, end);
      }
      return normalized.trim();
    }
    final separator = _metaRefreshTrailingSeparatorPattern.firstMatch(
      normalized,
    );
    if (separator != null) {
      normalized = normalized.substring(0, separator.start);
    }
    return normalized.trim();
  }

  void _extractJsonUrls(
    String text, {
    required String baseUrl,
    required void Function(String url) onUrl,
  }) {
    Object? data;
    try {
      data = json.decode(text);
    } catch (_) {
      return;
    }

    final repoApiParts = _githubRepoApiParts(baseUrl);
    if (repoApiParts != null && data is Map) {
      final branch = data['default_branch']?.toString().trim();
      if (branch != null && branch.isNotEmpty) {
        final owner = repoApiParts[0];
        final repo = repoApiParts[1];
        onUrl('https://api.github.com/repos/$owner/$repo/contents?ref=$branch');
        onUrl(
          'https://api.github.com/repos/$owner/$repo/git/trees/$branch?recursive=1',
        );
        for (final path in _githubRawSeedPaths) {
          onUrl('https://raw.githubusercontent.com/$owner/$repo/$branch/$path');
        }
      }
    }

    final base = Uri.tryParse(baseUrl);

    void addJsonStringUrl(String value) {
      final raw = value.trim();
      if (raw.isEmpty) return;
      onUrl(base?.resolve(raw).toString() ?? raw);
    }

    bool shouldSkipGenericJsonStringKey(Object? key) {
      final normalized = key?.toString().toLowerCase();
      return normalized == 'path' ||
          normalized == 'name' ||
          normalized == 'type' ||
          normalized == 'sha' ||
          normalized == 'size' ||
          normalized == 'encoding' ||
          normalized == 'content' ||
          normalized == 'default_branch';
    }

    void visit(Object? value, [Object? key]) {
      if (value is String) {
        if (!shouldSkipGenericJsonStringKey(key)) {
          addJsonStringUrl(value);
        }
        return;
      }
      if (value is List) {
        for (final item in value) {
          visit(item);
        }
        return;
      }
      if (value is! Map) return;
      final downloadUrl = value['download_url']?.toString();
      if (downloadUrl != null) {
        onUrl(downloadUrl);
      }
      final htmlUrl = value['html_url']?.toString();
      if (htmlUrl != null) {
        onUrl(htmlUrl);
      }
      final itemUrl = value['url']?.toString();
      if (itemUrl != null && itemUrl.contains('api.github.com/repos/')) {
        onUrl(itemUrl);
      }
      final path = value['path']?.toString();
      if (path != null && _isGithubApiConfigPath(path)) {
        final raw = _rawGithubUrlFromApiPath(baseUrl, path);
        if (raw != null) {
          onUrl(raw);
        }
      }
      for (final entry in value.entries) {
        visit(entry.value, entry.key);
      }
    }

    visit(data);
  }

  List<String>? _githubRepoApiParts(String apiUrl) {
    final uri = Uri.tryParse(apiUrl);
    if (uri == null || uri.host.toLowerCase() != 'api.github.com') {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 3 || segments[0] != 'repos') return null;
    return [segments[1], segments[2]];
  }

  String? _rawGithubUrlFromApiPath(String apiUrl, String path) {
    final uri = Uri.tryParse(apiUrl);
    if (uri == null || uri.host.toLowerCase() != 'api.github.com') {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length < 4 || segments[0] != 'repos') return null;
    final owner = segments[1];
    final repo = segments[2];
    String? ref;
    if (segments[3] == 'contents') {
      ref = uri.queryParameters['ref'];
    } else if (segments.length >= 6 &&
        segments[3] == 'git' &&
        segments[4] == 'trees') {
      ref = segments[5];
    }
    final branch = ref?.takeFirstValid(['main']) ?? 'main';
    return 'https://raw.githubusercontent.com/$owner/$repo/$branch/$path';
  }

  bool _isStrongConfigCandidate(String url) {
    final lower = url.toLowerCase();
    if (lower == freeNodesProfileUrl) return false;
    if (!_isHttpUrl(lower)) return false;
    if (lower.contains('api.github.com/repos/') &&
        (lower.contains('/contents') || lower.contains('/git/trees/'))) {
      return false;
    }
    if (lower.contains('raw.githubusercontent.com')) return true;
    if (_hasConfigExtension(lower)) return true;
    if (lower.contains('clash.crossxx.com')) return true;
    if (lower.contains('freeclash.top/ui/free_clash')) return true;
    if (lower.contains('freeclash.top/v1/sub/')) return true;
    return lower.contains('/api/') ||
        lower.contains('subscription') ||
        lower.contains('subscribe') ||
        lower.contains('/sub/') ||
        lower.contains('/sub?') ||
        lower.contains('suburl=') ||
        lower.contains('clashnode.com/wp-content/uploads/');
  }

  bool _hasConfigExtension(String value) {
    final path = Uri.tryParse(value)?.path.toLowerCase() ?? value.toLowerCase();
    return path.endsWith('.yaml') ||
        path.endsWith('.yml') ||
        path.endsWith('.txt') ||
        path.endsWith('.json');
  }

  bool _isGithubApiConfigPath(String value) {
    if (_hasConfigExtension(value)) return true;
    final path = value
        .split(RegExp(r'[?#]'))
        .first
        .replaceAll(RegExp(r'/+$'), '');
    final fileName = path.split('/').last.toLowerCase();
    return !fileName.contains('.') && _githubRawSeedPaths.contains(fileName);
  }

  bool _isPageCandidate(String url) {
    final lower = url.toLowerCase();
    if (!_isHttpUrl(lower)) return false;
    if (_isStrongConfigCandidate(lower)) return false;
    if (lower.contains('raw.githubusercontent.com')) return false;
    if (lower.contains('/assets/') || lower.contains('/static/')) return false;
    if (RegExp(
      r'\.(png|jpg|jpeg|gif|webp|svg|css|js|ico|woff2?)$',
    ).hasMatch(lower)) {
      return false;
    }
    return true;
  }

  bool _isRelevantPageUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('/tag/') || lower.contains('/category/')) return false;
    if (lower.contains('/client/')) return false;
    if (lower.contains('wp-json')) return false;
    return lower.contains('free') ||
        lower.contains('node') ||
        lower.contains('clash') ||
        lower.contains('/a/') ||
        lower.contains('/p/') ||
        RegExp(r'20\d{6}|20\d{2}[-/]\d{1,2}[-/]\d{1,2}').hasMatch(lower);
  }

  bool _isHttpUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _normalizeUrl(String url) {
    var value = url.trim();
    if (value.isEmpty) return '';
    value = value.replaceAll('&amp;', '&');
    value = value.replaceAll(RegExp(r'''[\s"'<>);\\]+$'''), '');
    if (value.startsWith('//')) {
      value = 'https:$value';
    }
    final blob = RegExp(
      r'https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)',
      caseSensitive: false,
    ).firstMatch(value);
    if (blob != null) {
      value =
          'https://raw.githubusercontent.com/${blob.group(1)}/${blob.group(2)}/${blob.group(3)}/${blob.group(4)}';
    }
    return value;
  }

  void _markSourceStatus(
    Map<String, FreeNodeSourceStatus> statusMap,
    _FreeNodeSourceDefinition source,
    String url,
    bool success,
    String? message,
  ) {
    statusMap[url] ??= FreeNodeSourceStatus(
      url: url,
      success: success,
      proxyCount: 0,
      sourceId: source.id,
      sourceLabel: source.label,
      updateIntervalHours: source.updateIntervalHours,
      message: message,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchProviderFollowUpProxies(
    String text,
    String baseUrl,
  ) async {
    final result = <Map<String, dynamic>>[];
    for (final url in _providerFollowUpUrls(
      text,
      baseUrl,
    ).take(_freeNodesProviderFollowUpLimit)) {
      final candidates = [..._githubMirrorUrls(url), url];
      for (final candidate in candidates) {
        try {
          final providerText = await fetcher(candidate).timeout(fetchTimeout);
          final parsed = await parseProxiesFast(providerText);
          if (parsed.isEmpty) continue;
          result.addAll(parsed);
          break;
        } catch (_) {}
      }
    }
    return result;
  }

  List<String> _providerFollowUpUrls(String text, String baseUrl) {
    final direct = _providerFollowUpUrlsFromYaml(text, baseUrl);
    if (direct.isNotEmpty) return direct;
    var first = true;
    for (final candidate in _decodeCandidates(text)) {
      if (first) {
        first = false;
        continue;
      }
      final decoded = _providerFollowUpUrlsFromYaml(candidate, baseUrl);
      if (decoded.isNotEmpty) return decoded;
    }
    for (final candidate in _embeddedBase64DecodedCandidates(text)) {
      final embedded = _providerFollowUpUrlsFromYaml(candidate, baseUrl);
      if (embedded.isNotEmpty) return embedded;
    }
    return const [];
  }

  List<String> _providerFollowUpUrlsFromYaml(String text, String baseUrl) {
    try {
      final value = _toPlain(yaml_parser.loadYaml(text));
      if (value is! Map) return const [];
      final providers =
          value['proxy-providers'] ??
          value['proxy_providers'] ??
          value['proxy-provider'] ??
          value['proxy_provider'];
      if (providers == null) return const [];
      final urls = <String>{};

      void addProvider(Object? provider) {
        final rawUrl = provider is Map
            ? provider['url']?.toString()
            : provider?.toString();
        final resolved = _resolveProviderFollowUpUrl(rawUrl, baseUrl);
        if (resolved != null) urls.add(resolved);
      }

      if (providers is Map) {
        for (final provider in providers.values) {
          addProvider(provider);
        }
      } else if (providers is List) {
        for (final provider in providers) {
          addProvider(provider);
        }
      } else {
        addProvider(providers);
      }
      return urls.toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String? _resolveProviderFollowUpUrl(String? rawUrl, String baseUrl) {
    if (rawUrl == null) return null;
    final normalized = _normalizeUrl(rawUrl);
    if (normalized.isEmpty) return null;
    final parsed = Uri.tryParse(normalized);
    final resolved = parsed != null && parsed.hasScheme
        ? normalized
        : Uri.tryParse(baseUrl)?.resolve(normalized).toString() ?? normalized;
    final url = _normalizeUrl(resolved);
    return _isStrongConfigCandidate(url) ? url : null;
  }

  List<Map<String, dynamic>> parseProxies(String text) {
    final proxies = <Map<String, dynamic>>[];
    for (final candidate in _decodeCandidates(text)) {
      final parsed = _parseYamlProxies(candidate);
      proxies.addAll(parsed);
      if (parsed.isEmpty || !_isStructuredProxyCollection(candidate)) {
        proxies.addAll(_parseUriProxies(candidate));
      }
    }
    if (!_isCompactBase64Text(text)) {
      for (final candidate in _embeddedBase64DecodedCandidates(text)) {
        final parsed = _parseYamlProxies(candidate);
        proxies.addAll(parsed);
        if (parsed.isEmpty || !_isStructuredProxyCollection(candidate)) {
          proxies.addAll(_parseUriProxies(candidate));
        }
      }
    }
    return proxies;
  }

  bool _isStructuredProxyCollection(String text) {
    final trimmed = text.trimLeft();
    return trimmed.startsWith('[') ||
        trimmed.startsWith('{') ||
        trimmed.startsWith('-');
  }

  Future<List<Map<String, dynamic>>> parseProxiesFast(String text) async {
    if (text.length < 64 * 1024) return parseProxies(text);
    return Isolate.run(() => FreeNodesService().parseProxies(text));
  }

  Iterable<String> _decodeCandidates(String text) sync* {
    yield text;
    final compact = _compactBase64Text(text);
    if (compact == null) return;
    try {
      final decoded = _decodeBase64Text(compact);
      if (decoded != null) yield decoded;
    } catch (_) {}
  }

  bool _isCompactBase64Text(String text) {
    return _compactBase64Text(text) != null;
  }

  String? _compactBase64Text(String text) {
    final compact = text.replaceAll(_freeNodesBase64WhitespacePattern, '');
    if (compact.isEmpty || !_freeNodesCompactBase64Pattern.hasMatch(compact)) {
      return null;
    }
    return compact;
  }

  Iterable<String> _embeddedBase64DecodedCandidates(String text) sync* {
    var count = 0;
    for (final match in _freeNodesEmbeddedBase64Pattern.allMatches(text)) {
      if (count >= _freeNodesEmbeddedBase64CandidateLimit) return;
      final token = match.group(0);
      if (token == null ||
          token.length < _freeNodesEmbeddedBase64MinLength ||
          token.length > _freeNodesEmbeddedBase64MaxLength) {
        continue;
      }
      try {
        final decoded = _decodeBase64Text(token);
        if (decoded != null) {
          yield decoded;
          count++;
        }
      } catch (_) {}
    }
  }

  List<Map<String, dynamic>> _parseYamlProxies(String text) {
    try {
      final value = _toPlain(yaml_parser.loadYaml(text));
      if (value is List) {
        return value
            .whereType<Map>()
            .map((proxy) => Map<String, dynamic>.from(proxy))
            .map(_parseRootProxyObject)
            .nonNulls
            .where(_isUsableProxy)
            .toList(growable: false);
      }
      if (value is! Map) return const [];
      final proxies = <Map<String, dynamic>>[];
      final rawProxies =
          value['proxies'] ??
          value['proxy'] ??
          value['Proxy'] ??
          value['payload'] ??
          value['Payload'];
      if (rawProxies is List) {
        proxies.addAll(
          rawProxies
              .whereType<Map>()
              .map((proxy) => Map<String, dynamic>.from(proxy))
              .where(_isUsableProxy),
        );
      } else if (rawProxies is Map) {
        proxies.addAll(
          rawProxies.entries
              .where((entry) => entry.value is Map)
              .map((entry) {
                final proxy = Map<String, dynamic>.from(entry.value as Map);
                proxy.putIfAbsent('name', () => entry.key.toString());
                return proxy;
              })
              .where(_isUsableProxy),
        );
      }
      final rawOutbounds = value['outbounds'];
      if (rawOutbounds is List) {
        proxies.addAll(
          rawOutbounds
              .whereType<Map>()
              .map((outbound) => Map<String, dynamic>.from(outbound))
              .map(_parseSingBoxOutbound)
              .nonNulls
              .where(_isUsableProxy),
        );
      } else if (rawOutbounds is Map) {
        proxies.addAll(
          rawOutbounds.entries
              .where((entry) => entry.value is Map)
              .map((entry) {
                final outbound = Map<String, dynamic>.from(entry.value as Map);
                outbound.putIfAbsent('tag', () => entry.key.toString());
                return outbound;
              })
              .map(_parseSingBoxOutbound)
              .nonNulls
              .where(_isUsableProxy),
        );
      }
      return proxies;
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic>? _parseRootProxyObject(Map<String, dynamic> proxy) {
    return _parseSingBoxOutbound(proxy) ??
        _parseGenericProxyListObject(proxy) ??
        (_isUsableProxy(proxy) ? proxy : null);
  }

  Map<String, dynamic>? _parseGenericProxyListObject(
    Map<String, dynamic> proxy,
  ) {
    final rawProxy = proxy['proxy']?.toString().trim();
    final parsedUri = rawProxy == null || rawProxy.isEmpty
        ? null
        : Uri.tryParse(rawProxy);
    final protocol = (proxy['protocol']?.toString() ?? '')
        .trim()
        .takeFirstValid([
          proxy['scheme']?.toString() ?? '',
          parsedUri?.scheme ?? '',
        ]);
    final type = _genericProxyListType(protocol);
    final server = (proxy['server']?.toString() ?? '').trim().takeFirstValid([
      proxy['ip']?.toString() ?? '',
      proxy['host']?.toString() ?? '',
      proxy['hostname']?.toString() ?? '',
      parsedUri?.host ?? '',
    ]);
    final port =
        int.tryParse('${proxy['port'] ?? proxy['server_port'] ?? ''}') ??
        parsedUri?.port;
    if (type == null || server.isEmpty || port == null || port <= 0) {
      return null;
    }
    final name = (proxy['name']?.toString() ?? '').trim().takeFirstValid([
      proxy['tag']?.toString() ?? '',
      '$type-$server:$port',
    ]);
    return {'name': name, 'type': type, 'server': server, 'port': port};
  }

  String? _genericProxyListType(String value) {
    final lower = value.toLowerCase();
    if (lower == 'http' || lower == 'https') return 'http';
    if (lower == 'socks' ||
        lower == 'socks4' ||
        lower == 'socks5' ||
        lower == 'socks5h') {
      return 'socks5';
    }
    return null;
  }

  Map<String, dynamic>? _parseSingBoxOutbound(Map<String, dynamic> outbound) {
    final type = _singBoxProxyType(outbound['type']?.toString() ?? '');
    final server = outbound['server']?.toString();
    final port = _singBoxOutboundPort(outbound);
    if (type == null || server == null || server.isEmpty || port == null) {
      return null;
    }
    final proxy = <String, dynamic>{
      'name': outbound['tag']?.toString().takeFirstValid(['$type-$server']),
      'type': type,
      'server': server,
      'port': port,
    };
    switch (type) {
      case 'ss':
        proxy['cipher'] = outbound['method']?.toString();
        proxy['password'] = outbound['password']?.toString();
      case 'vmess':
        proxy['uuid'] = outbound['uuid']?.toString();
        proxy['cipher'] = outbound['security']?.toString().takeFirstValid([
          'auto',
        ]);
      case 'vless':
        proxy['uuid'] = outbound['uuid']?.toString();
        final flow = outbound['flow']?.toString();
        if (flow?.isNotEmpty == true) proxy['flow'] = flow;
      case 'trojan' || 'hysteria2':
        proxy['password'] = outbound['password']?.toString();
        final ports = _singBoxPortsText(outbound);
        if (ports?.isNotEmpty == true) proxy['ports'] = ports;
      case 'hysteria':
        final auth =
            (outbound['auth'] ??
                    outbound['auth_str'] ??
                    outbound['auth-str'] ??
                    outbound['password'])
                ?.toString();
        if (auth?.isNotEmpty == true) proxy['auth_str'] = auth;
        final protocol = outbound['protocol']?.toString();
        if (protocol?.isNotEmpty == true) proxy['protocol'] = protocol;
        final up = (outbound['up_mbps'] ?? outbound['up'])?.toString();
        if (up?.isNotEmpty == true) proxy['up'] = up;
        final down = (outbound['down_mbps'] ?? outbound['down'])?.toString();
        if (down?.isNotEmpty == true) proxy['down'] = down;
        final ports = _singBoxPortsText(outbound);
        if (ports?.isNotEmpty == true) proxy['ports'] = ports;
        final obfs = outbound['obfs']?.toString();
        if (obfs?.isNotEmpty == true) proxy['obfs'] = obfs;
        final udp = outbound['udp'];
        if (udp is bool) proxy['udp'] = udp;
      case 'tuic':
        proxy['uuid'] = outbound['uuid']?.toString();
        proxy['password'] = outbound['password']?.toString();
        final congestion = outbound['congestion_control']?.toString();
        if (congestion?.isNotEmpty == true) {
          proxy['congestion-controller'] = congestion;
        }
        final udpRelayMode = outbound['udp_relay_mode']?.toString();
        if (udpRelayMode?.isNotEmpty == true) {
          proxy['udp-relay-mode'] = udpRelayMode;
        }
      case 'anytls':
        final username = (outbound['username'] ?? outbound['user'])?.toString();
        if (username?.isNotEmpty == true) proxy['username'] = username;
        final password = outbound['password']?.toString();
        if (password?.isNotEmpty == true) proxy['password'] = password;
        final udp = outbound['udp'];
        if (udp is bool) proxy['udp'] = udp;
      case 'wireguard':
        final privateKey = outbound['private_key']?.toString();
        if (privateKey?.isNotEmpty == true) proxy['private-key'] = privateKey;
        final publicKey =
            (outbound['peer_public_key'] ?? outbound['public_key'])?.toString();
        if (publicKey?.isNotEmpty == true) proxy['public-key'] = publicKey;
        final preSharedKey =
            (outbound['pre_shared_key'] ?? outbound['preshared_key'])
                ?.toString();
        if (preSharedKey?.isNotEmpty == true) {
          proxy['pre-shared-key'] = preSharedKey;
        }
        _insertSingBoxLocalAddress(proxy, outbound);
        final reserved = outbound['reserved']?.toString();
        if (reserved?.isNotEmpty == true) proxy['reserved'] = reserved;
        final udp = outbound['udp'];
        if (udp is bool) proxy['udp'] = udp;
        final mtu = int.tryParse('${outbound['mtu'] ?? ''}');
        if (mtu != null) proxy['mtu'] = mtu;
      case 'socks5':
        final username = (outbound['username'] ?? outbound['user'])?.toString();
        if (username?.isNotEmpty == true) proxy['username'] = username;
        final password = (outbound['password'] ?? outbound['pass'])?.toString();
        if (password?.isNotEmpty == true) proxy['password'] = password;
        final udp = outbound['udp'];
        if (udp is bool) proxy['udp'] = udp;
      case 'http':
        final username = (outbound['username'] ?? outbound['user'])?.toString();
        if (username?.isNotEmpty == true) proxy['username'] = username;
        final password = (outbound['password'] ?? outbound['pass'])?.toString();
        if (password?.isNotEmpty == true) proxy['password'] = password;
      case 'ssh':
        final username = (outbound['username'] ?? outbound['user'])?.toString();
        if (username?.isNotEmpty != true) return null;
        proxy['username'] = username;
        final password = (outbound['password'] ?? outbound['pass'])?.toString();
        if (password?.isNotEmpty == true) proxy['password'] = password;
        final privateKey = (outbound['private_key'] ?? outbound['private-key'])
            ?.toString();
        if (privateKey?.isNotEmpty == true) proxy['private-key'] = privateKey;
        final privateKeyPassphrase =
            (outbound['private_key_passphrase'] ??
                    outbound['private-key-passphrase'])
                ?.toString();
        if (privateKeyPassphrase?.isNotEmpty == true) {
          proxy['private-key-passphrase'] = privateKeyPassphrase;
        }
    }
    _insertSingBoxTlsOptions(proxy, outbound);
    _insertSingBoxTransportOptions(proxy, outbound);
    return proxy;
  }

  int? _singBoxOutboundPort(Map<String, dynamic> outbound) {
    final direct = int.tryParse(
      '${outbound['server_port'] ?? outbound['server-port'] ?? outbound['port'] ?? ''}',
    );
    if (direct != null) return direct;
    final ports = _singBoxPortsText(outbound);
    if (ports == null || ports.isEmpty) return null;
    final match = RegExp(r'\d+').firstMatch(ports);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  String? _singBoxPortsText(Map<String, dynamic> outbound) {
    final raw =
        outbound['server_ports'] ??
        outbound['server-ports'] ??
        outbound['ports'];
    if (raw is List) {
      final values = raw
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      return values.isEmpty ? null : values.join(',');
    }
    final text = raw?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  String? _singBoxProxyType(String value) {
    final lower = value.toLowerCase();
    return switch (lower) {
      'shadowsocks' || 'ss' => 'ss',
      'vmess' => 'vmess',
      'vless' => 'vless',
      'trojan' => 'trojan',
      'hysteria' => 'hysteria',
      'hysteria2' || 'hy2' => 'hysteria2',
      'tuic' => 'tuic',
      'anytls' => 'anytls',
      'wireguard' => 'wireguard',
      'socks' || 'socks5' || 'socks4' => 'socks5',
      'http' => 'http',
      'ssh' => 'ssh',
      _ => null,
    };
  }

  void _insertSingBoxLocalAddress(
    Map<String, dynamic> proxy,
    Map<String, dynamic> outbound,
  ) {
    final raw = outbound['local_address'] ?? outbound['local-address'];
    if (raw is List) {
      for (final item in raw) {
        _insertWireGuardLocalAddress(proxy, item.toString());
      }
      return;
    }
    if (raw != null) {
      _insertWireGuardLocalAddress(proxy, raw.toString());
    }
  }

  void _insertWireGuardLocalAddress(
    Map<String, dynamic> proxy,
    String address,
  ) {
    final value = address.trim();
    if (value.isEmpty) return;
    if (value.contains(':')) {
      proxy.putIfAbsent('ipv6', () => value);
    } else {
      proxy.putIfAbsent('ip', () => value);
    }
  }

  void _insertSingBoxTlsOptions(
    Map<String, dynamic> proxy,
    Map<String, dynamic> outbound,
  ) {
    final tls = outbound['tls'];
    if (tls is! Map || tls['enabled'] == false) return;
    proxy['tls'] = true;
    final sni = (tls['server_name'] ?? tls['server-name'])?.toString();
    if (sni?.isNotEmpty == true) proxy['sni'] = sni;
    final insecure = tls['insecure'];
    if (insecure is bool) proxy['skip-cert-verify'] = insecure;
    final utls = tls['utls'];
    if (utls is Map && utls['enabled'] != false) {
      final fingerprint = utls['fingerprint']?.toString();
      if (fingerprint?.isNotEmpty == true) {
        proxy['client-fingerprint'] = fingerprint;
      }
    }
  }

  void _insertSingBoxTransportOptions(
    Map<String, dynamic> proxy,
    Map<String, dynamic> outbound,
  ) {
    final transport = outbound['transport'];
    if (transport is! Map) return;
    final type = transport['type']?.toString().toLowerCase();
    if (type == 'ws' || type == 'websocket') {
      proxy['network'] = 'ws';
      final opts = <String, dynamic>{};
      final path = transport['path']?.toString();
      if (path?.isNotEmpty == true) opts['path'] = path;
      final headers = transport['headers'];
      if (headers is Map) {
        final host = (headers['Host'] ?? headers['host'])?.toString();
        if (host?.isNotEmpty == true) {
          opts['headers'] = {'Host': host};
        }
      }
      if (opts.isNotEmpty) proxy['ws-opts'] = opts;
    } else if (type == 'grpc') {
      proxy['network'] = 'grpc';
      final serviceName =
          (transport['service_name'] ?? transport['service-name'])?.toString();
      if (serviceName?.isNotEmpty == true) {
        proxy['grpc-opts'] = {'grpc-service-name': serviceName};
      }
    }
  }

  List<Map<String, dynamic>> _parseUriProxies(String text) {
    return text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .expand(_parseUriProxyList)
        .where(_isUsableProxy)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _parseUriProxyList(String value) {
    final lower = value.toLowerCase();
    if (lower.startsWith('mieru://') || lower.startsWith('mierus://')) {
      return _parseMieruProxies(value);
    }
    final proxy = _parseUriProxy(value);
    return proxy == null ? const <Map<String, dynamic>>[] : [proxy];
  }

  Map<String, dynamic>? _parseUriProxy(String value) {
    final lower = value.toLowerCase();
    if (lower.startsWith('ss://')) return _parseSsProxy(value);
    if (lower.startsWith('ssr://')) return _parseSsrProxy(value);
    if (lower.startsWith('vmess://')) return _parseVmessProxy(value);
    if (lower.startsWith('snell://')) return _parseSnellProxy(value);
    if (lower.startsWith('trojan://')) {
      return _parseUserInfoProxy(value, 'trojan');
    }
    if (lower.startsWith('vless://')) {
      return _parseUserInfoProxy(value, 'vless');
    }
    if (lower.startsWith('hysteria://')) return _parseHysteriaProxy(value);
    if (lower.startsWith('hysteria2://') || lower.startsWith('hy2://')) {
      return _parseUserInfoProxy(value, 'hysteria2');
    }
    if (lower.startsWith('tuic://')) return _parseTuicProxy(value);
    if (lower.startsWith('anytls://')) return _parseAnyTlsProxy(value);
    if (lower.startsWith('wireguard://')) return _parseWireGuardProxy(value);
    if (lower.startsWith('masque://')) return _parseMasqueProxy(value);
    if (lower.startsWith('trusttunnel://')) {
      return _parseTrustTunnelProxy(value);
    }
    if (lower.startsWith('socks5h://') ||
        lower.startsWith('socks5://') ||
        lower.startsWith('socks://')) {
      return _parseSocksProxy(value);
    }
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return _parseHttpProxy(value);
    }
    if (lower.startsWith('ssh://')) return _parseSshProxy(value);
    return null;
  }

  Map<String, dynamic>? _parseSshProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'ssh') return null;
    if (uri.host.isEmpty) return null;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['SSH']),
      'type': 'ssh',
      'server': uri.host,
      'port': uri.hasPort ? uri.port : 22,
    };
    _insertUriCredentials(proxy, uri.userInfo);
    final username = _firstQueryValue(uri, ['username', 'user']);
    if (proxy['username'] == null && username != null) {
      proxy['username'] = username;
    }
    final password = _firstQueryValue(uri, ['password', 'pass']);
    if (proxy['password'] == null && password != null) {
      proxy['password'] = password;
    }
    if (proxy['username'] == null) return null;
    _insertUriParam(proxy, uri, 'private-key', [
      'private-key',
      'privateKey',
      'private_key',
    ]);
    _insertUriParam(proxy, uri, 'private-key-passphrase', [
      'private-key-passphrase',
      'privateKeyPassphrase',
      'private_key_passphrase',
    ]);
    _insertUriCsvParam(proxy, uri, 'host-key', ['host-key', 'hostKey']);
    _insertUriCsvParam(proxy, uri, 'host-key-algorithms', [
      'host-key-algorithms',
      'hostKeyAlgorithms',
      'host_key_algorithms',
    ]);
    return proxy;
  }

  void _insertUriParam(
    Map<String, dynamic> proxy,
    Uri uri,
    String outputKey,
    List<String> inputKeys,
  ) {
    final value = _firstQueryValue(uri, inputKeys);
    if (value != null && value.isNotEmpty) proxy[outputKey] = value;
  }

  void _insertUriCsvParam(
    Map<String, dynamic> proxy,
    Uri uri,
    String outputKey,
    List<String> inputKeys,
  ) {
    final value = _firstQueryValue(uri, inputKeys);
    if (value == null || value.isEmpty) return;
    final values = value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (values.isNotEmpty) proxy[outputKey] = values;
  }

  void _insertUriIntParam(
    Map<String, dynamic> proxy,
    Uri uri,
    String outputKey,
    List<String> inputKeys,
  ) {
    final value = int.tryParse(_firstQueryValue(uri, inputKeys) ?? '');
    if (value != null) proxy[outputKey] = value;
  }

  void _insertUriBoolParam(
    Map<String, dynamic> proxy,
    Uri uri,
    String outputKey,
    List<String> inputKeys,
  ) {
    final value = _firstQueryValue(uri, inputKeys)?.toLowerCase();
    if (value == '1' || value == 'true' || value == 'yes') {
      proxy[outputKey] = true;
    }
  }

  String? _firstQueryValue(Uri uri, List<String> keys) {
    for (final key in keys) {
      final value = uri.queryParameters[key];
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  Map<String, dynamic>? _parseHttpProxy(String value) {
    final uri = Uri.tryParse(value);
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null || (scheme != 'http' && scheme != 'https')) return null;
    if (uri.path.isNotEmpty && uri.path != '/') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty) return null;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(
        uri.fragment,
      ).takeFirstValid(['${uri.host}:$port']),
      'type': 'http',
      'server': uri.host,
      'port': port,
      'skip-cert-verify': true,
    };
    if (scheme == 'https') proxy['tls'] = true;
    _insertUriCredentials(proxy, uri.userInfo);
    return proxy;
  }

  Map<String, dynamic>? _parseSocksProxy(String value) {
    final uri = Uri.tryParse(value);
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null ||
        (scheme != 'socks' && scheme != 'socks5' && scheme != 'socks5h')) {
      return null;
    }
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty) return null;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['SOCKS5']),
      'type': 'socks5',
      'server': uri.host,
      'port': port,
    };
    _insertUriCredentials(proxy, uri.userInfo);
    final udp = uri.queryParameters['udp']?.toLowerCase();
    if (udp == '1' || udp == 'true' || udp == 'yes') {
      proxy['udp'] = true;
    }
    return proxy;
  }

  void _insertUriCredentials(Map<String, dynamic> proxy, String userInfo) {
    final credentials = _decodeUriCredentials(userInfo);
    if (credentials == null) return;
    proxy['username'] = credentials.$1;
    if (credentials.$2 != null) proxy['password'] = credentials.$2;
  }

  (String, String?)? _decodeUriCredentials(String userInfo) {
    if (userInfo.isEmpty) return null;
    final decodedUserInfo = Uri.decodeComponent(userInfo);
    final separator = decodedUserInfo.indexOf(':');
    if (separator >= 0) {
      final username = decodedUserInfo.substring(0, separator);
      final password = decodedUserInfo.substring(separator + 1);
      return username.isEmpty ? null : (username, password);
    }
    final decodedBase64 = _decodeBase64Text(decodedUserInfo);
    if (decodedBase64 == null) {
      return decodedUserInfo.isEmpty ? null : (decodedUserInfo, null);
    }
    final decodedSeparator = decodedBase64.indexOf(':');
    if (decodedSeparator < 0) return null;
    final username = decodedBase64.substring(0, decodedSeparator);
    final password = decodedBase64.substring(decodedSeparator + 1);
    return username.isEmpty ? null : (username, password);
  }

  Map<String, dynamic>? _parseSsProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'ss') return null;
    final name = Uri.decodeComponent(uri.fragment).takeFirstValid(['SS']);
    final authority = uri.authority;
    if (authority.contains('@')) {
      final decodedUserInfo = Uri.decodeComponent(uri.userInfo);
      final parts = decodedUserInfo.split(':');
      if (parts.length < 2) return null;
      return {
        'name': name,
        'type': 'ss',
        'server': uri.host,
        'port': uri.port,
        'cipher': parts.first,
        'password': parts.sublist(1).join(':'),
      };
    }
    try {
      final payload = value
          .substring('ss://'.length)
          .split(RegExp(r'[?#]'))
          .first;
      final decoded = utf8.decode(base64Decode(base64.normalize(payload)));
      final proxyUri = Uri.tryParse('ss://$decoded');
      if (proxyUri == null) return null;
      final parts = Uri.decodeComponent(proxyUri.userInfo).split(':');
      if (parts.length < 2) return null;
      return {
        'name': name,
        'type': 'ss',
        'server': proxyUri.host,
        'port': proxyUri.port,
        'cipher': parts.first,
        'password': parts.sublist(1).join(':'),
      };
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _parseSnellProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'snell') return null;
    final port = uri.port;
    final psk = Uri.decodeComponent(uri.userInfo);
    if (port <= 0 || uri.host.isEmpty || psk.isEmpty) return null;
    final params = uri.queryParameters;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['Snell']),
      'type': 'snell',
      'server': uri.host,
      'port': port,
      'psk': psk,
    };
    final version = int.tryParse(params['version'] ?? '');
    if (version != null) proxy['version'] = version;
    final obfsOpts = <String, dynamic>{};
    final mode = params['obfs'] ?? params['mode'];
    if (mode?.isNotEmpty == true) obfsOpts['mode'] = mode;
    final host = params['obfs-host'] ?? params['obfs_host'] ?? params['host'];
    if (host?.isNotEmpty == true) obfsOpts['host'] = host;
    if (obfsOpts.isNotEmpty) proxy['obfs-opts'] = obfsOpts;
    return proxy;
  }

  Map<String, dynamic>? _parseSsrProxy(String value) {
    final decoded = _decodeBase64Text(value.substring('ssr://'.length));
    if (decoded == null) return null;
    final splitIndex = decoded.indexOf('/?');
    final main = splitIndex >= 0 ? decoded.substring(0, splitIndex) : decoded;
    final query = splitIndex >= 0 ? decoded.substring(splitIndex + 2) : '';
    final parts = main.split(':');
    if (parts.length < 6) return null;
    final server = parts[0].trim();
    final port = int.tryParse(parts[1]);
    final protocol = parts[2].trim();
    final method = parts[3].trim();
    final obfs = parts[4].trim();
    final password = _decodeSsrValue(parts.sublist(5).join(':'));
    if (server.isEmpty ||
        port == null ||
        protocol.isEmpty ||
        method.isEmpty ||
        obfs.isEmpty ||
        password == null ||
        password.isEmpty) {
      return null;
    }
    final params = _parseSsrQuery(query);
    final proxy = <String, dynamic>{
      'name': params['remarks'].takeFirstValid(['SSR']),
      'type': 'ssr',
      'server': server,
      'port': port,
      'cipher': method,
      'password': password,
      'protocol': protocol,
      'obfs': obfs,
      'udp': true,
    };
    final protoParam = params['protoparam'];
    if (protoParam?.isNotEmpty == true) {
      proxy['protocol-param'] = protoParam;
    }
    final obfsParam = params['obfsparam'];
    if (obfsParam?.isNotEmpty == true) {
      proxy['obfs-param'] = obfsParam;
    }
    return proxy;
  }

  Map<String, String> _parseSsrQuery(String query) {
    if (query.isEmpty) return const {};
    final params = <String, String>{};
    for (final pair in query.split('&')) {
      final separator = pair.indexOf('=');
      final key = separator >= 0 ? pair.substring(0, separator) : pair;
      if (key.isEmpty) continue;
      final rawValue = separator >= 0 ? pair.substring(separator + 1) : '';
      if (rawValue.isEmpty) continue;
      final decoded = _decodeSsrValue(rawValue);
      if (decoded?.isNotEmpty == true) params[key] = decoded!;
    }
    return params;
  }

  String? _decodeSsrValue(String value) {
    return _decodeBase64Text(Uri.decodeComponent(value));
  }

  String? _decodeBase64Text(String value) {
    try {
      return utf8.decode(base64Decode(base64.normalize(value)));
    } catch (_) {
      try {
        return utf8.decode(base64Url.decode(base64Url.normalize(value)));
      } catch (_) {
        return null;
      }
    }
  }

  Map<String, dynamic>? _parseVmessProxy(String value) {
    try {
      final payload = value.substring('vmess://'.length);
      final data = json.decode(
        utf8.decode(base64Decode(base64.normalize(payload))),
      );
      if (data is! Map) return null;
      final port = int.tryParse(data['port']?.toString() ?? '');
      final id = data['id']?.toString();
      final add = data['add']?.toString();
      if (port == null || id == null || add == null) return null;
      final proxy = <String, dynamic>{
        'name': data['ps']?.toString().takeFirstValid(['VMess']) ?? 'VMess',
        'type': 'vmess',
        'server': add,
        'port': port,
        'uuid': id,
        'alterId': int.tryParse(data['aid']?.toString() ?? '') ?? 0,
        'cipher': data['scy']?.toString().takeFirstValid(['auto']) ?? 'auto',
      };
      final net = data['net']?.toString();
      if (net != null && net.isNotEmpty) proxy['network'] = net;
      if (data['tls']?.toString().isNotEmpty == true) {
        proxy['tls'] = data['tls'].toString() == 'tls';
      }
      final sni = data['sni']?.toString().takeFirstValid([
        data['host']?.toString() ?? '',
      ]);
      if (sni != null && sni.isNotEmpty) proxy['servername'] = sni;
      return proxy;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _parseHysteriaProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'hysteria') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty) return null;
    final params = uri.queryParameters;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['Hysteria']),
      'type': 'hysteria',
      'server': uri.host,
      'port': port,
    };
    void insertParam(String outputKey, List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = params[inputKey];
        if (value != null && value.isNotEmpty) {
          proxy[outputKey] = value;
          return;
        }
      }
    }

    insertParam('auth_str', ['auth', 'auth-str', 'auth_str']);
    insertParam('protocol', ['protocol']);
    insertParam('up', ['up', 'upmbps']);
    insertParam('down', ['down', 'downmbps']);
    insertParam('ports', ['ports']);
    insertParam('sni', ['peer', 'sni']);
    insertParam('obfs', ['obfs']);
    insertParam('obfs-protocol', ['obfs-protocol']);
    final alpn = params['alpn']
        ?.split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (alpn?.isNotEmpty == true) proxy['alpn'] = alpn;
    final insecure = params['insecure']?.toLowerCase();
    if (insecure == '1' || insecure == 'true' || insecure == 'yes') {
      proxy['skip-cert-verify'] = true;
    }
    return proxy;
  }

  Map<String, dynamic>? _parseTuicProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'tuic') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty || uri.userInfo.isEmpty) return null;
    final params = uri.queryParameters;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['TUIC']),
      'type': 'tuic',
      'server': uri.host,
      'port': port,
      'udp': true,
    };
    final userInfo = uri.userInfo;
    final separator = userInfo.indexOf(':');
    if (separator >= 0) {
      final uuid = Uri.decodeComponent(userInfo.substring(0, separator));
      final password = Uri.decodeComponent(userInfo.substring(separator + 1));
      if (uuid.isEmpty || password.isEmpty) return null;
      proxy['uuid'] = uuid;
      proxy['password'] = password;
    } else {
      final token = Uri.decodeComponent(userInfo);
      if (token.isEmpty) return null;
      proxy['token'] = token;
    }
    void insertParam(String outputKey, List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = params[inputKey];
        if (value != null && value.isNotEmpty) {
          proxy[outputKey] = value;
          return;
        }
      }
    }

    void insertIntParam(String outputKey, List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = int.tryParse(params[inputKey] ?? '');
        if (value != null) {
          proxy[outputKey] = value;
          return;
        }
      }
    }

    bool hasTruthyParam(List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = params[inputKey]?.toLowerCase();
        if (value == '1' || value == 'true' || value == 'yes') return true;
      }
      return false;
    }

    insertParam('congestion-controller', [
      'congestion_control',
      'congestion-controller',
    ]);
    insertParam('udp-relay-mode', ['udp_relay_mode', 'udp-relay-mode']);
    insertParam('fingerprint', ['fingerprint', 'fp']);
    insertParam('sni', ['sni']);
    insertIntParam('heartbeat-interval', [
      'heartbeat-interval',
      'heartbeat_interval',
    ]);
    insertIntParam('request-timeout', ['request-timeout', 'request_timeout']);
    insertIntParam('max-open-streams', [
      'max-open-streams',
      'max_open_streams',
    ]);
    insertIntParam('max-udp-relay-packet-size', [
      'max-udp-relay-packet-size',
      'max_udp_relay_packet_size',
    ]);
    if (hasTruthyParam(['disable_sni', 'disable-sni'])) {
      proxy['disable-sni'] = true;
    }
    if (hasTruthyParam([
      'skip-cert-verify',
      'skip_cert_verify',
      'allowInsecure',
      'allow_insecure',
      'insecure',
    ])) {
      proxy['skip-cert-verify'] = true;
    }
    if (hasTruthyParam(['reduce-rtt', 'reduce_rtt'])) {
      proxy['reduce-rtt'] = true;
    }
    if (hasTruthyParam(['udp-over-stream', 'udp_over_stream'])) {
      proxy['udp-over-stream'] = true;
    }
    insertIntParam('udp-over-stream-version', [
      'udp-over-stream-version',
      'udp_over_stream_version',
    ]);
    final alpn = params['alpn']
        ?.split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (alpn?.isNotEmpty == true) proxy['alpn'] = alpn;
    return proxy;
  }

  Map<String, dynamic>? _parseAnyTlsProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'anytls') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty || uri.userInfo.isEmpty) return null;
    final separator = uri.userInfo.indexOf(':');
    final username = Uri.decodeComponent(
      separator >= 0 ? uri.userInfo.substring(0, separator) : uri.userInfo,
    );
    if (username.isEmpty) return null;
    final password = separator >= 0
        ? Uri.decodeComponent(uri.userInfo.substring(separator + 1))
        : username;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(
        uri.fragment,
      ).takeFirstValid(['${uri.host}:$port']),
      'type': 'anytls',
      'server': uri.host,
      'port': port,
      'username': username,
      'password': password.isEmpty ? username : password,
      'udp': true,
    };
    final params = uri.queryParameters;
    final sni = params['sni'];
    if (sni?.isNotEmpty == true) proxy['sni'] = sni;
    final hpkp = params['hpkp'];
    if (hpkp?.isNotEmpty == true) proxy['fingerprint'] = hpkp;
    if (params['insecure'] == '1') proxy['skip-cert-verify'] = true;
    return proxy;
  }

  Map<String, dynamic>? _parseWireGuardProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'wireguard') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty) return null;
    final params = uri.queryParameters;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['WireGuard']),
      'type': 'wireguard',
      'server': uri.host,
      'port': port,
    };
    final privateKey = Uri.decodeComponent(uri.userInfo);
    if (privateKey.isNotEmpty) {
      proxy['private-key'] = privateKey;
    } else {
      final queryPrivateKey = params['private-key'];
      if (queryPrivateKey?.isNotEmpty == true) {
        proxy['private-key'] = queryPrivateKey;
      }
    }
    void insertParam(String outputKey, List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = params[inputKey];
        if (value != null && value.isNotEmpty) {
          proxy[outputKey] = value;
          return;
        }
      }
    }

    void insertIntParam(String outputKey, List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = int.tryParse(params[inputKey] ?? '');
        if (value != null) {
          proxy[outputKey] = value;
          return;
        }
      }
    }

    bool hasTruthyParam(List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final value = params[inputKey]?.toLowerCase();
        if (value == '1' || value == 'true' || value == 'yes') return true;
      }
      return false;
    }

    List<String>? csvParam(List<String> inputKeys) {
      for (final inputKey in inputKeys) {
        final raw = params[inputKey];
        if (raw == null || raw.isEmpty) continue;
        final values = raw
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false);
        if (values.isNotEmpty) return values;
      }
      return null;
    }

    insertParam('public-key', ['public-key', 'pubkey']);
    insertParam('pre-shared-key', ['pre-shared-key', 'preshared-key', 'psk']);
    insertParam('ip', ['ip']);
    insertParam('ipv6', ['ipv6']);
    insertParam('reserved', ['reserved']);
    insertIntParam('mtu', ['mtu']);
    insertIntParam('workers', ['workers']);
    insertIntParam('persistent-keepalive', [
      'persistent-keepalive',
      'persistent_keepalive',
      'keepalive',
    ]);
    insertIntParam('refresh-server-ip-interval', [
      'refresh-server-ip-interval',
      'refresh_server_ip_interval',
    ]);
    final allowedIps = csvParam(['allowed-ips', 'allowed_ips']);
    if (allowedIps != null) proxy['allowed-ips'] = allowedIps;
    final dns = csvParam(['dns']);
    if (dns != null) proxy['dns'] = dns;
    if (hasTruthyParam(['udp'])) proxy['udp'] = true;
    if (hasTruthyParam(['remote-dns-resolve', 'remote_dns_resolve'])) {
      proxy['remote-dns-resolve'] = true;
    }
    return proxy;
  }

  Map<String, dynamic>? _parseMasqueProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'masque') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty) return null;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['MASQUE']),
      'type': 'masque',
      'server': uri.host,
      'port': port,
    };
    final privateKey = Uri.decodeComponent(uri.userInfo);
    if (privateKey.isNotEmpty) {
      proxy['private-key'] = privateKey;
    } else {
      _insertUriParam(proxy, uri, 'private-key', [
        'private-key',
        'privateKey',
        'private_key',
      ]);
    }
    _insertUriParam(proxy, uri, 'public-key', [
      'public-key',
      'publicKey',
      'public_key',
      'pubkey',
    ]);
    _insertUriParam(proxy, uri, 'ip', ['ip']);
    _insertUriParam(proxy, uri, 'ipv6', ['ipv6']);
    _insertUriParam(proxy, uri, 'uri', ['uri']);
    _insertUriParam(proxy, uri, 'sni', ['sni']);
    _insertUriParam(proxy, uri, 'network', ['network']);
    _insertUriParam(proxy, uri, 'congestion-controller', [
      'congestion-controller',
      'congestion_controller',
      'congestionController',
    ]);
    _insertUriParam(proxy, uri, 'bbr-profile', [
      'bbr-profile',
      'bbr_profile',
      'bbrProfile',
    ]);
    _insertUriIntParam(proxy, uri, 'mtu', ['mtu']);
    _insertUriIntParam(proxy, uri, 'cwnd', ['cwnd']);
    _insertUriBoolParam(proxy, uri, 'udp', ['udp']);
    _insertUriBoolParam(proxy, uri, 'skip-cert-verify', [
      'skip-cert-verify',
      'skip_cert_verify',
      'insecure',
    ]);
    _insertUriBoolParam(proxy, uri, 'remote-dns-resolve', [
      'remote-dns-resolve',
      'remote_dns_resolve',
    ]);
    _insertUriCsvParam(proxy, uri, 'dns', ['dns']);
    return proxy;
  }

  Map<String, dynamic>? _parseTrustTunnelProxy(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'trusttunnel') return null;
    final port = uri.port;
    if (port <= 0 || uri.host.isEmpty) return null;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid(['TrustTunnel']),
      'type': 'trusttunnel',
      'server': uri.host,
      'port': port,
    };
    _insertUriCredentials(proxy, uri.userInfo);
    _insertUriCsvParam(proxy, uri, 'alpn', ['alpn']);
    _insertUriParam(proxy, uri, 'sni', ['sni']);
    _insertUriParam(proxy, uri, 'client-fingerprint', [
      'client-fingerprint',
      'client_fingerprint',
      'clientFingerprint',
    ]);
    _insertUriParam(proxy, uri, 'fingerprint', ['fingerprint', 'hpkp']);
    _insertUriParam(proxy, uri, 'certificate', ['certificate', 'cert']);
    _insertUriParam(proxy, uri, 'private-key', [
      'private-key',
      'privateKey',
      'private_key',
    ]);
    _insertUriParam(proxy, uri, 'congestion-controller', [
      'congestion-controller',
      'congestion_controller',
      'congestionController',
    ]);
    _insertUriParam(proxy, uri, 'bbr-profile', [
      'bbr-profile',
      'bbr_profile',
      'bbrProfile',
    ]);
    _insertUriBoolParam(proxy, uri, 'udp', ['udp']);
    _insertUriBoolParam(proxy, uri, 'health-check', [
      'health-check',
      'health_check',
      'healthCheck',
    ]);
    _insertUriBoolParam(proxy, uri, 'quic', ['quic']);
    _insertUriBoolParam(proxy, uri, 'skip-cert-verify', [
      'skip-cert-verify',
      'skip_cert_verify',
      'insecure',
    ]);
    _insertUriIntParam(proxy, uri, 'cwnd', ['cwnd']);
    _insertUriIntParam(proxy, uri, 'max-connections', [
      'max-connections',
      'max_connections',
      'maxConnections',
    ]);
    _insertUriIntParam(proxy, uri, 'min-streams', [
      'min-streams',
      'min_streams',
      'minStreams',
    ]);
    _insertUriIntParam(proxy, uri, 'max-streams', [
      'max-streams',
      'max_streams',
      'maxStreams',
    ]);
    return proxy;
  }

  List<Map<String, dynamic>> _parseMieruProxies(String value) {
    final uri = Uri.tryParse(value);
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null || (scheme != 'mieru' && scheme != 'mierus')) {
      return const [];
    }
    if (uri.host.isEmpty) return const [];
    final params = uri.queryParametersAll;
    final ports = (params['port'] ?? const <String>[])
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final protocols = (params['protocol'] ?? const <String>[])
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (ports.isEmpty || ports.length != protocols.length) {
      return const [];
    }
    String? lastNonEmpty(String key) {
      final values = params[key];
      if (values == null) return null;
      for (final value in values.reversed) {
        if (value.isNotEmpty) return value;
      }
      return null;
    }

    final profile = lastNonEmpty('profile');
    final multiplexing = lastNonEmpty('multiplexing');
    final handshakeMode = lastNonEmpty('handshake-mode');
    final trafficPattern = lastNonEmpty('traffic-pattern');
    final fragment = Uri.decodeComponent(uri.fragment);
    final baseName = fragment.takeFirstValid([profile ?? '', uri.host]);
    final username = Uri.decodeComponent(uri.userInfo.split(':').first);
    final separator = uri.userInfo.indexOf(':');
    final password = separator >= 0
        ? Uri.decodeComponent(uri.userInfo.substring(separator + 1))
        : '';
    final proxies = <Map<String, dynamic>>[];
    for (var i = 0; i < ports.length; i++) {
      final port = ports[i];
      final protocol = protocols[i];
      final proxy = <String, dynamic>{
        'name': '$baseName:$port/$protocol',
        'type': 'mieru',
        'server': uri.host,
        'transport': protocol,
        'udp': true,
        'username': username,
        'password': password,
      };
      if (port.contains('-')) {
        proxy['port-range'] = port;
      } else {
        final parsedPort = int.tryParse(port);
        if (parsedPort == null) continue;
        proxy['port'] = parsedPort;
      }
      if (multiplexing != null) proxy['multiplexing'] = multiplexing;
      if (handshakeMode != null) proxy['handshake-mode'] = handshakeMode;
      if (trafficPattern != null) proxy['traffic-pattern'] = trafficPattern;
      proxies.add(proxy);
    }
    return proxies;
  }

  Map<String, dynamic>? _parseUserInfoProxy(String value, String type) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final serverPort = _userInfoServerPort(uri, type, value);
    if (serverPort == null || uri.userInfo.isEmpty) return null;
    final proxy = <String, dynamic>{
      'name': Uri.decodeComponent(uri.fragment).takeFirstValid([type]),
      'type': type,
      'server': serverPort.$1,
      'port': serverPort.$2,
    };
    if (type == 'trojan' || type == 'hysteria2') {
      proxy['password'] = Uri.decodeComponent(uri.userInfo);
    } else {
      proxy['uuid'] = Uri.decodeComponent(uri.userInfo);
    }
    final params = uri.queryParameters;
    final sni = params['sni'] ?? params['peer'] ?? params['host'];
    if (sni != null && sni.isNotEmpty) {
      proxy['sni'] = sni;
      proxy['servername'] = sni;
    }
    final network = _normalizeUserInfoNetwork(params);
    if (network != null) proxy['network'] = network;
    final security = params['security'];
    if (security != null && security.isNotEmpty) {
      proxy['tls'] = security == 'tls' || security == 'reality';
    }
    _insertUserInfoWsOpts(proxy, params, network);
    _insertUserInfoGrpcOpts(proxy, params, network);
    _insertUriParam(proxy, uri, 'flow', ['flow']);
    _insertUriParam(proxy, uri, 'client-fingerprint', [
      'fp',
      'fingerprint',
      'client-fingerprint',
    ]);
    final pinnedFingerprint = params['pcs'];
    if (pinnedFingerprint?.isNotEmpty == true &&
        !proxy.containsKey('fingerprint')) {
      proxy['fingerprint'] = pinnedFingerprint;
    }
    if (proxy['tls'] == true && !proxy.containsKey('client-fingerprint')) {
      proxy['client-fingerprint'] = 'chrome';
    }
    _insertUriCsvParam(proxy, uri, 'alpn', ['alpn']);
    _insertUriBoolParam(proxy, uri, 'skip-cert-verify', [
      'allowInsecure',
      'insecure',
      'skip-cert-verify',
    ]);
    if (type == 'vless') _insertVlessPacketEncoding(proxy, params);
    return proxy;
  }

  (String, int)? _userInfoServerPort(Uri uri, String type, String rawValue) {
    if (uri.host.isEmpty) return null;
    if (uri.hasPort && uri.port > 0) return (uri.host, uri.port);
    if (type != 'vless') return null;
    final rawHost = _rawUriAuthorityHost(rawValue);
    final decoded = _decodeBase64Text(rawHost ?? uri.host);
    if (decoded == null) return null;
    final separator = decoded.lastIndexOf(':');
    if (separator <= 0 || separator == decoded.length - 1) return null;
    final server = decoded.substring(0, separator);
    final port = int.tryParse(decoded.substring(separator + 1));
    if (server.isEmpty || port == null || port <= 0) return null;
    return (server, port);
  }

  String? _rawUriAuthorityHost(String value) {
    final schemeEnd = value.indexOf('://');
    if (schemeEnd < 0) return null;
    final rest = value.substring(schemeEnd + 3);
    final authorityEnd = rest.indexOf(RegExp(r'[/?#]'));
    final authority = authorityEnd < 0 ? rest : rest.substring(0, authorityEnd);
    final userInfoEnd = authority.lastIndexOf('@');
    final hostPort = userInfoEnd < 0
        ? authority
        : authority.substring(userInfoEnd + 1);
    final portStart = hostPort.lastIndexOf(':');
    return portStart < 0 ? hostPort : hostPort.substring(0, portStart);
  }

  String? _normalizeUserInfoNetwork(Map<String, String> params) {
    final type = params['type'];
    if (type == null || type.isEmpty) return null;
    final lower = type.toLowerCase();
    if (lower == 'ws' || lower == 'websocket') return 'ws';
    if (lower == 'grpc') return 'grpc';
    if (lower == 'httpupgrade') return 'httpupgrade';
    if (lower == 'http' || lower == 'h2') return 'h2';
    final headerType = params['headerType'] ?? params['header-type'];
    if (lower == 'tcp' && headerType?.toLowerCase() == 'http') return 'http';
    return lower;
  }

  void _insertUserInfoWsOpts(
    Map<String, dynamic> proxy,
    Map<String, String> params,
    String? network,
  ) {
    if (network != 'ws' && network != 'httpupgrade') return;
    final opts = <String, dynamic>{};
    final path = params['path'];
    if (path?.isNotEmpty == true) opts['path'] = path;
    final host = params['host'];
    if (host?.isNotEmpty == true) {
      opts['headers'] = {'Host': host};
    }
    final earlyData = int.tryParse(params['ed'] ?? '');
    if (network == 'ws' && earlyData != null) {
      opts['max-early-data'] = earlyData;
      opts['early-data-header-name'] = (params['eh'] ?? '').takeFirstValid([
        'Sec-WebSocket-Protocol',
      ]);
    } else if (network == 'httpupgrade' && earlyData != null) {
      opts['v2ray-http-upgrade-fast-open'] = true;
    } else {
      final header = params['eh'];
      if (header?.isNotEmpty == true) opts['early-data-header-name'] = header;
    }
    if (opts.isNotEmpty) proxy['ws-opts'] = opts;
  }

  void _insertUserInfoGrpcOpts(
    Map<String, dynamic> proxy,
    Map<String, String> params,
    String? network,
  ) {
    if (network != 'grpc') return;
    final serviceName =
        params['serviceName'] ??
        params['service-name'] ??
        params['grpc-service-name'];
    if (serviceName?.isNotEmpty == true) {
      proxy['grpc-opts'] = {'grpc-service-name': serviceName};
    }
  }

  void _insertVlessPacketEncoding(
    Map<String, dynamic> proxy,
    Map<String, String> params,
  ) {
    proxy['udp'] = true;
    switch (params['packetEncoding']) {
      case 'none':
        return;
      case 'packet':
        proxy['packet-addr'] = true;
        return;
      default:
        proxy['xudp'] = true;
    }
  }

  Object? _toPlain(Object? value) {
    if (value is yaml_parser.YamlMap) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _toPlain(entry.value),
      };
    }
    if (value is yaml_parser.YamlList) {
      return value.map(_toPlain).toList(growable: false);
    }
    return value;
  }

  bool _isUsableProxy(Map<String, dynamic> proxy) {
    final name = proxy['name'];
    final type = proxy['type'];
    final server = proxy['server'];
    final port = proxy['port'];
    final portRange = proxy['port-range']?.toString().trim();
    if (name == null ||
        type == null ||
        server == null ||
        (port == null && portRange?.isNotEmpty != true)) {
      return false;
    }
    final serverText = server.toString();
    return serverText.isNotEmpty &&
        !serverText.contains(' ') &&
        !serverText.contains('\n');
  }

  List<_DatedProxy> _deduplicateAndName(List<_DatedProxy> proxies) {
    final fingerprintIndexes = <String, int>{};
    final deduplicated = <_DatedProxy>[];
    for (final datedProxy in proxies) {
      final normalized = Map<String, dynamic>.from(datedProxy.proxy);
      _normalizeProxyCipher(normalized);
      final key = _proxyFingerprint(normalized);
      final existingIndex = fingerprintIndexes[key];
      if (existingIndex != null) {
        final existing = deduplicated[existingIndex];
        final mergedSourceIds = LinkedHashSet<String>.from(
          existing.effectiveSourceIds,
        )..addAll(datedProxy.effectiveSourceIds);
        final mergedSourceLabels = LinkedHashSet<String>.from(
          existing.effectiveSourceLabels,
        )..addAll(datedProxy.effectiveSourceLabels);
        deduplicated[existingIndex] = _DatedProxy(
          proxy: existing.proxy,
          dateLabel: existing.dateLabel,
          dateToken: existing.dateToken,
          sourceId: existing.sourceId ?? datedProxy.sourceId,
          sourceLabel: existing.sourceLabel ?? datedProxy.sourceLabel,
          sourceIds: mergedSourceIds.toList(growable: false),
          sourceLabels: mergedSourceLabels.toList(growable: false),
          staleTimeoutHours:
              existing.staleTimeoutHours ?? datedProxy.staleTimeoutHours,
        );
        continue;
      }
      fingerprintIndexes[key] = deduplicated.length;
      deduplicated.add(
        _DatedProxy(
          proxy: normalized,
          dateLabel: datedProxy.dateLabel,
          dateToken: datedProxy.dateToken,
          sourceId: datedProxy.sourceId,
          sourceLabel: datedProxy.sourceLabel,
          sourceIds: datedProxy.effectiveSourceIds,
          sourceLabels: datedProxy.effectiveSourceLabels,
          staleTimeoutHours: datedProxy.staleTimeoutHours,
        ),
      );
    }
    final usedNames = <String>{};
    final nextNameSuffixes = <String, int>{};
    final result = <_DatedProxy>[];
    for (final datedProxy in deduplicated) {
      final normalized = Map<String, dynamic>.from(datedProxy.proxy);
      final fallbackName =
          "${normalized['type']?.toString() ?? ''}-${normalized['server']?.toString() ?? ''}";
      final name = normalized['name'].toString().trim().takeFirstValid([
        fallbackName,
      ]);
      normalized['name'] = _uniqueName(name, usedNames, nextNameSuffixes);
      result.add(
        _DatedProxy(
          proxy: normalized,
          dateLabel: datedProxy.dateLabel,
          dateToken: datedProxy.dateToken,
          sourceId: datedProxy.sourceId,
          sourceLabel: datedProxy.sourceLabel,
          sourceIds: datedProxy.effectiveSourceIds,
          sourceLabels: datedProxy.effectiveSourceLabels,
          staleTimeoutHours: datedProxy.staleTimeoutHours,
        ),
      );
    }
    return result;
  }

  void _normalizeProxyCipher(Map<String, dynamic> proxy) {
    if (proxy['type']?.toString().toLowerCase() != 'ss') return;
    if (proxy['cipher']?.toString().toLowerCase() == 'chacha20-poly1305') {
      proxy['cipher'] = 'chacha20-ietf-poly1305';
    }
  }

  String _proxyFingerprint(Map<String, dynamic> proxy) {
    final values = [
      proxy['type'],
      proxy['server'],
      proxy['port'],
      proxy['uuid'],
      proxy['password'],
      proxy['cipher'],
      proxy['sni'],
    ].map((value) => value?.toString() ?? '').join('|');
    return values.toLowerCase();
  }

  String _uniqueName(
    String name,
    Set<String> usedNames,
    Map<String, int> nextNameSuffixes,
  ) {
    final safeName = name.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
    final baseName = safeName.isEmpty ? 'proxy' : safeName;
    final baseKey = baseName.toLowerCase();
    if (usedNames.add(baseKey)) return baseName;

    var index = nextNameSuffixes[baseKey] ?? 1;
    while (true) {
      final candidate = '$baseName $index';
      index++;
      if (usedNames.add(candidate.toLowerCase())) {
        nextNameSuffixes[baseKey] = index;
        return candidate;
      }
    }
  }

  List<_DatedProxy> _extractExistingDatedProxies(
    String? text,
    _FreeNodeSourceCatalog catalog, {
    required bool cleanupExpired,
  }) {
    if (text == null || text.trim().isEmpty) return const [];
    try {
      final value = _toPlain(yaml_parser.loadYaml(text));
      if (value is! Map) return const [];
      final rawProxies = value['proxies'];
      if (rawProxies is! List) return const [];
      final dateByProxyName = <String, String>{};
      final sourceIdByProxyName = <String, String>{};
      final sourceIdsByProxyName = <String, LinkedHashSet<String>>{};
      final sourceLabelsByProxyName = <String, LinkedHashSet<String>>{};
      final sourceByProxyName = <String, String>{};
      final sourceDefinitionsByGroupName = {
        for (final source in catalog.sources)
          _sourceGroupName(source, catalog): source,
      };
      final rawGroups = value['proxy-groups'];
      if (rawGroups is List) {
        final treasureProxyNames = <String>{};
        for (final rawGroup in rawGroups.whereType<Map>()) {
          final groupName = rawGroup['name']?.toString() ?? '';
          final rawNames = rawGroup['proxies'];
          if (rawNames is! List) continue;
          if (_isFreeNodesTreasureGroup(groupName)) {
            treasureProxyNames.addAll(rawNames.map((name) => name.toString()));
            continue;
          }
          if (_isFreeNodesDateGroup(groupName)) {
            for (final rawName in rawNames) {
              dateByProxyName[rawName.toString()] = groupName;
            }
            continue;
          }
          final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
          final sourceDefinition =
              sourceDefinitionsByGroupName[normalizedGroupName];
          final sourceLabel =
              sourceDefinition?.label ?? _sourceLabelFromGroupName(groupName);
          if (sourceLabel != null) {
            for (final rawName in rawNames) {
              final proxyName = rawName.toString();
              sourceByProxyName[proxyName] = sourceLabel;
              sourceLabelsByProxyName
                  .putIfAbsent(proxyName, LinkedHashSet.new)
                  .add(sourceLabel);
              if (sourceDefinition != null) {
                sourceIdByProxyName[proxyName] = sourceDefinition.id;
                sourceIdsByProxyName
                    .putIfAbsent(proxyName, LinkedHashSet.new)
                    .add(sourceDefinition.id);
              }
            }
          }
        }
        for (final proxyName in treasureProxyNames) {
          dateByProxyName.putIfAbsent(
            proxyName,
            () => freeNodesTreasureGroupName,
          );
        }
      }
      return rawProxies
          .whereType<Map>()
          .map((proxy) {
            final normalized = Map<String, dynamic>.from(proxy);
            final name = normalized['name']?.toString() ?? '';
            final label =
                dateByProxyName[name] ??
                _dateLabelFromProxyName(name) ??
                freeNodesHistoryGroupName;
            final normalizedLabel = _normalizeDateGroupLabel(label);
            return _DatedProxy(
              proxy: normalized,
              dateLabel: normalizedLabel,
              dateToken: _dateTokenFromLabel(normalizedLabel),
              sourceId: sourceIdByProxyName[name],
              sourceLabel: sourceByProxyName[name],
              sourceIds:
                  sourceIdsByProxyName[name]?.toList(growable: false) ??
                  const <String>[],
              sourceLabels:
                  sourceLabelsByProxyName[name]?.toList(growable: false) ??
                  const <String>[],
            );
          })
          .where((item) => _isUsableProxy(item.proxy))
          .where(
            (item) =>
                !cleanupExpired || _shouldKeepExistingProxy(item, catalog),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  bool _needsFreeNodesConfigNormalization(String text) {
    if (text.trim().isEmpty) return false;
    try {
      final value = _toPlain(yaml_parser.loadYaml(text));
      if (value is! Map) return false;
      final rawGroups = value['proxy-groups'];
      if (rawGroups is! List) return false;
      var looksLikeFreeNodesConfig = false;
      final normalizedNames = <String>[];
      for (final rawGroup in rawGroups.whereType<Map>()) {
        final groupName = rawGroup['name']?.toString() ?? '';
        if (groupName.isEmpty) continue;
        final normalizedGroupName = normalizeFreeNodesGroupName(groupName);
        final groupToken = _dateTokenFromLabel(normalizedGroupName);
        normalizedNames.add(normalizedGroupName);
        if (normalizedGroupName == freeNodesGroupName ||
            _isFreeNodesTreasureGroup(normalizedGroupName) ||
            normalizedGroupName == freeNodesHistoryGroupName ||
            groupToken > 0 ||
            _isFreeNodesSourceGroup(normalizedGroupName)) {
          looksLikeFreeNodesConfig = true;
        }
        if (normalizedGroupName != groupName) return true;
      }
      if (!looksLikeFreeNodesConfig) return false;
      for (final normalizedGroupName in normalizedNames) {
        if (_isGeneratedFreeNodesGroupName(normalizedGroupName)) {
          continue;
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  int _countUsableProxies(String? text) {
    if (text == null || text.trim().isEmpty) return 0;
    try {
      final value = _toPlain(yaml_parser.loadYaml(text));
      if (value is! Map) return 0;
      final rawProxies = value['proxies'];
      if (rawProxies is! List) return 0;
      return rawProxies
          .whereType<Map>()
          .map((proxy) => Map<String, dynamic>.from(proxy))
          .where(_isUsableProxy)
          .length;
    } catch (_) {
      return 0;
    }
  }

  bool _isFreeNodesDateGroup(String name) {
    return name == freeNodesHistoryGroupName || _dateTokenFromLabel(name) > 0;
  }

  bool _isFreeNodesTreasureGroup(String name) {
    return name == freeNodesTreasureGroupName ||
        name == freeNodesLegacyTreasureGroupName;
  }

  bool _isFreeNodesSourceGroup(String name) {
    return _sourceLabelFromGroupName(name) != null;
  }

  String? _sourceLabelFromGroupName(String name) {
    return freeNodesSourceLabelFromGroupName(name);
  }

  bool _isGeneratedFreeNodesGroupName(String name) {
    if (name == freeNodesGroupName ||
        name == freeNodesTreasureGroupName ||
        name == 'GLOBAL') {
      return true;
    }
    final token = _dateTokenFromLabel(name);
    return token > 0 || _isFreeNodesSourceGroup(name);
  }

  bool _shouldKeepExistingProxy(
    _DatedProxy item,
    _FreeNodeSourceCatalog catalog,
  ) {
    if (item.dateToken <= 0) return true;
    if (item.dateToken == _todayDateToken()) return true;
    final date = _dateFromToken(item.dateToken);
    if (date == null) return true;
    final timeoutHours = item.staleTimeoutHours ?? catalog.historyTimeoutHours;
    final staleFrom = DateTime(date.year, date.month, date.day + 1);
    return DateTime.now().difference(staleFrom).inHours <= timeoutHours;
  }

  String? _dateLabelFromProxyName(String name) {
    final match = RegExp(
      r'(20\d{2})[-_/\.]?(\d{2})[-_/\.]?(\d{2})',
    ).firstMatch(name);
    if (match == null) return null;
    return _formatDateGroupLabel(
      DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateGroupLabel(DateTime date) {
    return '$freeNodesDateGroupPrefix${_formatDateLabel(date)}';
  }

  String _normalizeDateGroupLabel(String label) {
    if (label == freeNodesLegacyTreasureGroupName) {
      return freeNodesTreasureGroupName;
    }
    if (label == freeNodesHistoryGroupName ||
        _isFreeNodesTreasureGroup(label)) {
      return label;
    }
    final token = _dateTokenFromLabel(label);
    final date = token > 0 ? _dateFromToken(token) : null;
    return date == null ? label : _formatDateGroupLabel(date);
  }

  String? _currentProxyUrl() {
    try {
      final proxy = HttpOverrides.current?.findProxyFromEnvironment(
        Uri.parse('https://raw.githubusercontent.com'),
        null,
      );
      if (proxy == null || proxy.trim().isEmpty || proxy == 'DIRECT') {
        return null;
      }
      final match = RegExp(
        r'^PROXY\s+(.+)$',
        caseSensitive: false,
      ).firstMatch(proxy.trim());
      if (match == null) return null;
      final hostPort = (match.group(1) ?? '').replaceFirst(
        RegExp('^localhost:', caseSensitive: false),
        '127.0.0.1:',
      );
      return 'http://$hostPort';
    } catch (_) {
      return null;
    }
  }

  int _dateTokenFromLabel(String label) {
    return freeNodesDateTokenFromGroupName(label);
  }

  int _todayDateToken() {
    final now = DateTime.now();
    return int.tryParse(
          '${now.year}${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}',
        ) ??
        0;
  }

  DateTime? _dateFromToken(int token) {
    final text = token.toString();
    if (!RegExp(r'^20\d{6}$').hasMatch(text)) return null;
    final year = int.tryParse(text.substring(0, 4));
    final month = int.tryParse(text.substring(4, 6));
    final day = int.tryParse(text.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  String _sourceGroupName(
    _FreeNodeSourceDefinition source,
    _FreeNodeSourceCatalog catalog,
  ) {
    final normalizedLabel = source.label.replaceAll(RegExp(r'\s+'), ' ').trim();
    final duplicateLabelCount = catalog.sources
        .where(
          (candidate) =>
              candidate.label.replaceAll(RegExp(r'\s+'), ' ').trim() ==
              normalizedLabel,
        )
        .length;
    final suffix = duplicateLabelCount > 1 ? ' · ${source.id}' : '';
    return '$freeNodesSourceGroupPrefix$normalizedLabel$suffix';
  }

  Map<String, dynamic> _buildClashConfig(
    List<_DatedProxy> proxies, {
    required _FreeNodeSourceCatalog catalog,
    bool autoPrefer = false,
  }) {
    final normalizedProxies = proxies.map((item) => item.proxy).toList();
    final proxyNames = normalizedProxies
        .map((proxy) => proxy['name'].toString())
        .toList();
    final dateGroups = <String, List<String>>{};
    final dateTokens = <String, int>{};
    final sourceGroups = <String, List<String>>{};
    final sourceDefinitionsById = {
      for (final source in catalog.sources) source.id: source,
    };
    for (final item in proxies) {
      if (_isFreeNodesTreasureGroup(item.dateLabel)) continue;
      final proxyName = item.proxy['name'].toString();
      if (item.dateToken > 0) {
        final date = _dateFromToken(item.dateToken);
        if (date != null) {
          final label = _formatDateGroupLabel(date);
          dateGroups.putIfAbsent(label, () => []).add(proxyName);
          dateTokens[label] = item.dateToken;
        }
      }
      final sourceId = item.sourceId?.trim();
      final sourceLabel = item.sourceLabel?.trim();
      if ((sourceId != null && sourceId.isNotEmpty) ||
          (sourceLabel != null && sourceLabel.isNotEmpty)) {
        final sourceDefinition = sourceId == null
            ? null
            : sourceDefinitionsById[sourceId];
        final groupName = sourceDefinition != null
            ? _sourceGroupName(sourceDefinition, catalog)
            : '$freeNodesSourceGroupPrefix'
                  '${sourceLabel?.replaceAll(RegExp(r'\s+'), ' ') ?? sourceId}';
        sourceGroups.putIfAbsent(groupName, () => []).add(proxyName);
      }
      final coveredSourceLabels = <String>{};
      for (final membershipSourceId in item.effectiveSourceIds) {
        final membershipSource = sourceDefinitionsById[membershipSourceId];
        if (membershipSource != null) {
          coveredSourceLabels.add(
            membershipSource.label.replaceAll(RegExp(r'\s+'), ' ').trim(),
          );
        }
        if (membershipSourceId == sourceId) continue;
        final membershipGroupName = membershipSource != null
            ? _sourceGroupName(membershipSource, catalog)
            : freeNodesSourceGroupPrefix + membershipSourceId;
        sourceGroups.putIfAbsent(membershipGroupName, () => []).add(proxyName);
      }
      for (final membershipSourceLabel in item.effectiveSourceLabels) {
        final normalizedMembershipLabel = membershipSourceLabel
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (normalizedMembershipLabel.isEmpty ||
            coveredSourceLabels.contains(normalizedMembershipLabel) ||
            normalizedMembershipLabel == sourceLabel) {
          continue;
        }
        final membershipGroupName =
            freeNodesSourceGroupPrefix + normalizedMembershipLabel;
        sourceGroups.putIfAbsent(membershipGroupName, () => []).add(proxyName);
      }
    }
    final treasureProxyNames = proxies
        .where((item) => _isFreeNodesTreasureGroup(item.dateLabel))
        .map((item) => item.proxy['name'].toString())
        .toList(growable: false);
    final sortedDateLabels = dateGroups.keys.toList(growable: false)
      ..sort((a, b) {
        if (a == freeNodesHistoryGroupName) return 1;
        if (b == freeNodesHistoryGroupName) return -1;
        final tokenCompare = (dateTokens[b] ?? 0).compareTo(dateTokens[a] ?? 0);
        if (tokenCompare != 0) return tokenCompare;
        return b.compareTo(a);
      });
    final sortedSourceLabels = sourceGroups.keys.toList(growable: false)
      ..sort();
    final mainGroupProxies =
        autoPrefer &&
            (sortedDateLabels.isNotEmpty || treasureProxyNames.isNotEmpty)
        ? [
            ...sortedDateLabels,
            if (treasureProxyNames.isNotEmpty) freeNodesTreasureGroupName,
          ]
        : autoPrefer && sortedSourceLabels.isNotEmpty
        ? sortedSourceLabels
        : proxyNames;
    return {
      'mixed-port': defaultMixedPort,
      'allow-lan': false,
      'mode': 'rule',
      'log-level': 'info',
      'unified-delay': true,
      'proxies': normalizedProxies,
      'proxy-groups': [
        {
          'name': freeNodesGroupName,
          'type': 'url-test',
          'hidden': true,
          'proxies': mainGroupProxies,
          'url': freeNodesDelayTestUrl,
          'interval': 300,
          'timeout': 5000,
          'lazy': true,
        },
        if (treasureProxyNames.isNotEmpty)
          {
            'name': freeNodesTreasureGroupName,
            'type': 'url-test',
            'hidden': false,
            'proxies': treasureProxyNames,
            'url': freeNodesDelayTestUrl,
            'interval': 300,
            'timeout': 5000,
            'lazy': true,
          },
        for (final label in sortedDateLabels)
          {
            'name': label,
            'type': 'url-test',
            'hidden': true,
            'proxies': dateGroups[label],
            'url': freeNodesDelayTestUrl,
            'interval': 300,
            'timeout': 5000,
            'lazy': true,
          },
        for (final label in sortedSourceLabels)
          {
            'name': label,
            'type': 'url-test',
            'hidden': false,
            'proxies': sourceGroups[label],
            'url': freeNodesDelayTestUrl,
            'interval': 300,
            'timeout': 5000,
            'lazy': true,
          },
        {
          'name': 'GLOBAL',
          'type': 'select',
          'hidden': false,
          'proxies': [
            freeNodesGroupName,
            if (treasureProxyNames.isNotEmpty) freeNodesTreasureGroupName,
            ...sortedDateLabels,
            ...sortedSourceLabels,
            ...proxyNames,
            'DIRECT',
          ],
        },
      ],
      'rules': ['MATCH,$freeNodesGroupName'],
    };
  }

  Future<List<String>> getProfileProxyNames(Profile profile) async {
    final config = await coreController.getConfig(profile.id);
    final proxies = config['proxies'];
    if (proxies is! List) return const [];
    return proxies
        .whereType<Map>()
        .map((proxy) => proxy['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  Future<FreeNodeStabilityResult> testProxyStability({
    required String proxyName,
    required String testUrl,
    int rounds = 4,
    int earlySuccesses = 2,
    int earlyFailures = 2,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final delays = <int>[];
    var failures = 0;
    for (var i = 0; i < rounds; i++) {
      try {
        final delay = await coreController
            .getDelay(testUrl, proxyName)
            .timeout(timeout);
        final value = delay.value;
        if (value != null && value > 0) {
          delays.add(value);
        } else {
          failures++;
        }
      } catch (_) {
        failures++;
      }
      if (delays.length >= earlySuccesses && failures == 0) break;
      if (failures >= earlyFailures && delays.isEmpty) break;
    }
    await ensureRustApiInitialized();
    final outputText = await summarizeFreeNodeStabilityJson(
      inputJson: json.encode({
        'proxyName': proxyName,
        'delays': delays,
        'failures': failures,
      }),
    );
    final output = json.decode(outputText);
    if (output is! Map) {
      throw '稳定性测试 Rust 输出格式错误';
    }
    final rawDelays = output['delays'];
    final rustDelays = rawDelays is List
        ? rawDelays
              .map((value) => int.tryParse(value.toString()) ?? 0)
              .where((value) => value > 0)
              .toList(growable: false)
        : delays;
    return FreeNodeStabilityResult(
      proxyName: output['proxyName']?.toString() ?? proxyName,
      delays: rustDelays,
      failures: int.tryParse('${output['failures'] ?? failures}') ?? failures,
      averageDelay: output['averageDelay'] == null
          ? null
          : int.tryParse(output['averageDelay'].toString()),
      variance:
          double.tryParse('${output['variance'] ?? ''}') ??
          _fallbackVariance(rustDelays),
      level: _stabilityLevelFromRust(output['level']?.toString()),
    );
  }

  FreeNodeStabilityLevel _stabilityLevelFromRust(String? value) {
    return switch (value) {
      'good' => FreeNodeStabilityLevel.good,
      'normal' => FreeNodeStabilityLevel.normal,
      _ => FreeNodeStabilityLevel.poor,
    };
  }

  double _fallbackVariance(List<int> values) {
    if (values.length <= 1) return 0;
    final average = values.sum / values.length;
    final sum = values.fold<double>(
      0,
      (total, value) => total + pow(value - average, 2),
    );
    return sum / values.length;
  }
}

final _urlPattern = RegExp(r'''https?://[^\s"'<>]+''', caseSensitive: false);
final _hrefPattern = RegExp(
  r'''href\s*=\s*["']([^"']+)["']''',
  caseSensitive: false,
);
final _metaTagPattern = RegExp(r'''<meta\b[^>]*>''', caseSensitive: false);
final _metaRefreshPattern = RegExp(
  r'''http-equiv\s*=\s*["']?refresh["']?''',
  caseSensitive: false,
);
final _contentAttributePattern = RegExp(
  r'''content\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))''',
  caseSensitive: false,
);
final _metaRefreshUrlPattern = RegExp(r'''url\s*=''', caseSensitive: false);
final _metaRefreshTrailingSeparatorPattern = RegExp(r''';\s+''');

final freeNodesService = FreeNodesService();

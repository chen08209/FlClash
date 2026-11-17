import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/mitm_body.dart';
import 'package:fl_clash/common/mitm_protobuf.dart';
import 'package:fl_clash/common/mitm_module.dart';
import 'package:fl_clash/common/mitm_network.dart';
import 'package:fl_clash/common/mitm_trust.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart' show compute, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rust_api/rust_api.dart' show transcodeCharset;

import 'app.dart';
import 'config.dart';
import 'core.dart';
import 'database.dart';
import 'state.dart';

part 'generated/mitm.g.dart';

const _exchangesRefreshInterval = Duration(seconds: 2);

@Riverpod(keepAlive: true)
class MitmCa extends _$MitmCa {
  @override
  Future<MitmCertificate?> build() {
    return ref.read(coreHandlerProvider).getMitmCertificate();
  }

  Future<void> generate() async {
    final certificate = await ref
        .read(coreHandlerProvider)
        .generateMitmCertificate();
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(certificate);
  }
}

@Riverpod(keepAlive: true)
MitmTrustStore? mitmTrustStore(Ref ref) => mitmTrustStoreForPlatform();

/// Whether this device trusts the CA. A check records the CA it found
/// trusted, which is the one the Core decrypts HTTPS with.
@Riverpod(keepAlive: true)
class MitmTrustState extends _$MitmTrustState {
  @override
  Future<MitmTrustCheck> build() async {
    return _check(await ref.watch(mitmCaProvider.future));
  }

  Future<MitmTrustCheck> _check(MitmCertificate? ca) async {
    final store = ref.read(mitmTrustStoreProvider);
    final MitmTrustCheck check;
    if (ca == null) {
      check = const MitmTrustCheck(MitmTrust.notGenerated);
    } else if (store == null) {
      check = const MitmTrustCheck(MitmTrust.notInstalled);
    } else {
      final core = ref.read(coreHandlerProvider);
      check = await store.check(
        ca,
        () => core.issueMitmCertificate(mitmCheckHost),
      );
    }
    if (ref.mounted) {
      _record(ca, check);
    }
    return check;
  }

  void _record(MitmCertificate? ca, MitmTrustCheck check) {
    final trusted = check.trust == MitmTrust.ready ? ca?.fingerprint : null;
    if (ref.read(patchClashConfigProvider).mitm.trustedFingerprint == trusted) {
      return;
    }
    ref
        .read(patchClashConfigProvider.notifier)
        .update(
          (state) => state.copyWith(
            mitm: state.mitm.copyWith(trustedFingerprint: trusted),
          ),
        );
  }

  Future<void>? _refreshing;

  /// Calls while a check runs share it, since each check runs the platform's
  /// trust tools.
  Future<void> refresh() {
    if (state.isLoading) {
      return future.then((_) {}, onError: (_) {});
    }
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh() async {
    final next = await AsyncValue.guard(
      () async => _check(await ref.read(mitmCaProvider.future)),
    );
    if (ref.mounted) {
      state = next;
    }
  }

  Future<MitmInstallOutcome?> install() async {
    final ca = await ref.read(mitmCaProvider.future);
    final store = ref.read(mitmTrustStoreProvider);
    if (ca == null || store == null || ref.read(safeModeProvider)) {
      return null;
    }
    MitmInstallOutcome? outcome;
    try {
      outcome = await store.install(ca);
      return outcome;
    } finally {
      if (store is AndroidMitmTrustStore && ref.mounted) {
        ref.invalidate(rootAccessProvider);
      }
      if (ref.mounted &&
          (outcome == null ||
              outcome == MitmInstallOutcome.installed ||
              outcome == MitmInstallOutcome.untilReboot)) {
        await refresh();
      }
    }
  }

  Future<MitmRemoveOutcome?> remove() async {
    final ca = await ref.read(mitmCaProvider.future);
    final store = ref.read(mitmTrustStoreProvider);
    if (ca == null || store == null || ref.read(safeModeProvider)) {
      return null;
    }
    MitmRemoveOutcome outcome;
    try {
      outcome = await store.remove(ca);
    } on ProcessException catch (error) {
      commonPrint.log(
        'Removing the MITM certificate failed: ${compactError(error)}',
        logLevel: LogLevel.warning,
      );
      outcome = MitmRemoveOutcome.failed;
    } finally {
      if (store is AndroidMitmTrustStore && ref.mounted) {
        ref.invalidate(rootAccessProvider);
      }
    }
    await refresh();
    return outcome;
  }

  /// False when the old CA is left in the trust store for the user to remove,
  /// as safe mode always leaves it.
  Future<bool> regenerate() async {
    final old = await ref.read(mitmCaProvider.future);
    final store = ref.read(mitmTrustStoreProvider);
    final trust = state.value?.trust;
    var removed = true;
    if (old != null &&
        store != null &&
        (trust == MitmTrust.ready || trust == MitmTrust.untrusted)) {
      try {
        removed =
            !ref.read(safeModeProvider) &&
            await store.remove(old) == MitmRemoveOutcome.removed;
      } catch (error) {
        commonPrint.log(
          'Removing the old MITM certificate failed: ${compactError(error)}',
          logLevel: LogLevel.warning,
        );
        removed = false;
      }
      if (store is AndroidMitmTrustStore && ref.mounted) {
        ref.invalidate(rootAccessProvider);
      }
    }
    await ref.read(mitmCaProvider.notifier).generate();
    return removed;
  }
}

/// Fetched again while shown, until the connection has closed and none of its
/// requests is pending.
@riverpod
Future<MitmExchangeList> mitmExchanges(Ref ref, String connectionId) async {
  final list = await ref
      .read(coreHandlerProvider)
      .getMitmExchanges(connectionId);
  final settled =
      list.closed && !list.exchanges.any((exchange) => exchange.pending);
  if (!settled && ref.mounted) {
    final timer = Timer(_exchangesRefreshInterval, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return list;
}

@riverpod
Future<MitmExchange?> mitmExchange(Ref ref, int id) async {
  final exchange = await ref.read(coreHandlerProvider).getMitmExchange(id);
  if (exchange != null && exchange.pending && ref.mounted) {
    final timer = Timer(_exchangesRefreshInterval, ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  return exchange;
}

@riverpod
Future<MitmBodyContent?> mitmBody(
  Ref ref,
  int id, {
  required bool response,
  required String contentType,
}) async {
  final body = await ref
      .read(coreHandlerProvider)
      .getMitmBody(id, response: response);
  if (body == null) {
    return null;
  }
  final content = await compute(readMitmBody, (
    body,
    contentType,
    grpcOverLimitNote: currentAppLocalizations.mitmGrpcOverLimit(
      mitmGrpcInflateLimit >> 20,
    ),
  ));
  if (content.charset.isEmpty) {
    return content;
  }
  final Uint8List? utf8Bytes;
  try {
    utf8Bytes = await mitmCharsetTranscoder(
      bytes: content.bytes,
      label: content.charset,
      lossy: content.truncated,
    );
  } catch (error) {
    commonPrint.log('Reading ${content.charset} failed: $error');
    return content;
  }
  if (utf8Bytes == null) {
    return content;
  }
  return compute(readMitmCharsetText, (content, utf8Bytes, contentType));
}

typedef MitmCharsetTranscoder =
    Future<Uint8List?> Function({
      required List<int> bytes,
      required String label,
      required bool lossy,
    });

@visibleForTesting
MitmCharsetTranscoder mitmCharsetTranscoder = transcodeCharset;

/// Whether the user was told, this run, what a copied or exported request
/// can carry.
@Riverpod(keepAlive: true)
class MitmExportWarned extends _$MitmExportWarned {
  @override
  bool build() => false;

  void accept() => state = true;
}

@riverpod
List<MitmModule> mitmModulesToAgree(Ref ref) => [
  for (final module
      in ref.watch(mitmModulesProvider).value ?? const <MitmModule>[])
    if (module.awaitsConsent) module,
];

/// Why the Core skips each of the user's hostnames, by the line.
@riverpod
Future<Map<String, String>> mitmHostnameIssues(Ref ref) async {
  final hostname = ref.watch(
    patchClashConfigProvider.select((state) => state.mitm.hostname),
  );
  if (hostname.isEmpty) {
    return const {};
  }
  final check = await _checkOf(ref, MitmRules(hostname: hostname));
  return check.issues[MitmList.hostname] ?? const {};
}

typedef _MitmLineCheck = ({
  Map<MitmList, Map<String, String>> issues,
  Map<MitmList, Map<String, MitmLineView>> views,
});

Future<_MitmLineCheck> _checkOf(Ref ref, MitmRules mitm) async {
  final issues = await ref.read(coreHandlerProvider).validateMitm(mitm);
  Map<MitmList, Map<String, T>> byLine<T>(Map<MitmList, Map<int, T>> lists) => {
    for (final MapEntry(key: list, value: lines) in lists.entries)
      list: {
        for (final MapEntry(key: index, :value) in lines.entries)
          ?mitm.linesOf(list).elementAtOrNull(index): value,
      },
  };
  return (
    issues: byLine(issues),
    views: const <MitmList, Map<String, MitmLineView>>{},
  );
}

/// A module that fails to read adds nothing, so the VPN can still start.
@riverpod
Future<List<({String name, MitmModuleContent content})>> enabledMitmModules(
  Ref ref,
) async {
  if (!(rsFeature &&
      ref.watch(
        patchClashConfigProvider.select((state) => state.mitm.enable),
      ))) {
    return const [];
  }
  final modules = await ref.watch(mitmModulesProvider.future);
  final contents = <({String name, MitmModuleContent content})>[];
  for (final module in modules.where((module) => module.enabled)) {
    try {
      final content = await ref.watch(
        mitmModuleContentProvider(module.id).future,
      );
      if (content != null) {
        contents.add((name: module.name, content: content));
      }
    } catch (e) {
      commonPrint.log(
        'MITM module ${module.name}: ${compactError(e)}',
        logLevel: LogLevel.warning,
      );
    }
  }
  return contents;
}

@riverpod
Future<Map<String, List<String>>> mitmModuleExits(Ref ref) async {
  final exits = <String, List<String>>{};
  for (final module in await ref.watch(enabledMitmModulesProvider.future)) {
    for (final exit in module.content.exits) {
      exits.putIfAbsent(exit, () => []).add(module.name);
    }
  }
  return exits;
}

typedef MitmNetworkChangeState = ({
  MitmNetworkChange change,
  bool overridesYours,
  String? replacedBy,
});

/// A list goes over the user's only when it replaces it whole, a per-domain
/// entry only where the user wrote that domain. Android's VPN reads its own
/// route rows, never the TUN overrides, and only adds a module's routes.
bool mitmChangeOverridesUser(
  MitmNetworkChange change, {
  required ProfileOverrides overrides,
  required Map<String, String> hosts,
}) {
  bool dnsKey(DnsOverrideKey key) => overrides.dnsOverrideKeys.contains(key);
  return switch (change.key) {
    MitmNetworkKey.nameserver =>
      change.replaces && dnsKey(DnsOverrideKey.nameserver),
    MitmNetworkKey.defaultNameserver =>
      change.replaces && dnsKey(DnsOverrideKey.defaultNameserver),
    MitmNetworkKey.fakeIpFilter =>
      change.replaces && dnsKey(DnsOverrideKey.fakeIpFilter),
    MitmNetworkKey.nameserverPolicy =>
      dnsKey(DnsOverrideKey.nameserverPolicy) &&
          overrides.dns.nameserverPolicy.containsKey(change.entry),
    MitmNetworkKey.hosts => hosts.containsKey(change.entry),
    MitmNetworkKey.routeExcludeAddress =>
      change.replaces &&
          !system.isAndroid &&
          overrides.tunOverrideKeys.contains(
            TunOverrideKey.routeExcludeAddress,
          ),
    MitmNetworkKey.bypassDomain => change.replaces,
    MitmNetworkKey.routeAddress => false,
  };
}

@riverpod
Future<List<MitmNetworkChangeState>> mitmModuleNetworkChanges(
  Ref ref,
  int id,
) async {
  final overrides = ref.watch(
    profileOverridesProvider(ref.watch(currentProfileIdProvider)),
  );
  final hosts = ref.watch(
    patchClashConfigProvider.select((state) => state.hosts),
  );
  final changes =
      (await ref.watch(
        mitmModuleContentProvider(id).future,
      ))?.network.changes ??
      const [];
  if (changes.isEmpty) {
    return const [];
  }
  final modules = await ref.watch(mitmModulesProvider.future);
  final later = <(String, MitmNetwork)>[];
  for (final module in modules.skipWhile((module) => module.id != id).skip(1)) {
    if (!module.enabled) {
      continue;
    }
    final content = await ref.watch(
      mitmModuleContentProvider(module.id).future,
    );
    if (content != null && !content.network.isEmpty) {
      later.add((module.name, content.network));
    }
  }
  return [
    for (final change in changes)
      (
        change: change,
        overridesYours: mitmChangeOverridesUser(
          change,
          overrides: overrides,
          hosts: hosts,
        ),
        replacedBy: later
            .lastWhereOrNull((module) => change.replacedBy(module.$2))
            ?.$1,
      ),
  ];
}

typedef MitmTakeover = ({
  Map<MitmNetworkKey, String> keys,
  Map<String, String> hosts,
  Map<String, String> nameserverPolicy,
});

/// The module that last replaces each setting, for the setting's own page to
/// name; a module that only adds to a list leaves it the user's.
@riverpod
Future<MitmTakeover> mitmTakeover(Ref ref) async {
  final keys = <MitmNetworkKey, String>{};
  final hosts = <String, String>{};
  final nameserverPolicy = <String, String>{};
  for (final module in await ref.watch(enabledMitmModulesProvider.future)) {
    for (final change in module.content.network.changes) {
      switch (change.key) {
        case MitmNetworkKey.hosts:
          hosts[change.entry!] = module.name;
        case MitmNetworkKey.nameserverPolicy:
          nameserverPolicy[change.entry!] = module.name;
        case MitmNetworkKey.routeExcludeAddress when system.isAndroid:
          break;
        case final key when change.replaces:
          keys[key] = module.name;
        default:
          break;
      }
    }
  }
  return (keys: keys, hosts: hosts, nameserverPolicy: nameserverPolicy);
}

@riverpod
Future<MitmNetwork> mitmModuleNetwork(Ref ref) async => MitmNetwork.merge(
  (await ref.watch(
    enabledMitmModulesProvider.future,
  )).map((module) => module.content.network),
);

typedef MitmModuleDetails = ({
  MitmModuleContent content,
  Map<MitmList, Map<String, String>> issues,
  Map<MitmList, Map<String, MitmLineView>> views,
});

MitmModuleContent _parseModuleSource(MitmModuleSource source) =>
    parseMitmModule(
      source.content,
      values: source.arguments,
      resources: source.resources,
    );

/// Null while the module's content is not on disk.
@riverpod
Future<MitmModuleDetails?> mitmModuleDetails(Ref ref, int id) async {
  final content = await ref.watch(mitmModuleContentProvider(id).future);
  if (content == null) {
    return null;
  }
  final check = await _checkOf(ref, content.mitm);
  return (content: content, issues: check.issues, views: check.views);
}

Duration? _noRetry(int retryCount, Object error) => null;

/// A file that fails to parse fails again until it changes, which rebuilds
/// this anyway.
@Riverpod(retry: _noRetry)
Future<MitmModuleContent?> mitmModuleContent(Ref ref, int id) async {
  final module = ref.watch(
    mitmModulesProvider.select(
      (state) => state.value?.firstWhereOrNull((item) => item.id == id),
    ),
  );
  if (module == null) {
    return null;
  }
  final file = File(join(await appPath.mitmModulesDirPath, module.fileName));
  if (!await file.exists()) {
    return null;
  }
  return compute(
    _parseModuleSource,
    MitmModuleSource(
      content: await file.readAsString(),
      arguments: module.arguments,
      resources: module.resources,
    ),
  );
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/tailscale.freezed.dart';

part 'generated/tailscale.g.dart';

/// The outbound `type` value understood by the mihomo core for Tailscale nodes.
const tailscaleProxyType = 'tailscale';

const defaultTailscaleProps = TailscaleProps();

/// User configurable Tailscale support.
///
/// Tailscale is opt-in: [enable] gates whether the authored [proxies] are
/// injected into the running configuration. When disabled the generated config
/// is identical to the plain profile config, so normal traffic keeps flowing
/// globally just like before.
@freezed
abstract class TailscaleProps with _$TailscaleProps {
  const factory TailscaleProps({
    @Default(false) bool enable,
    @Default(false) bool bypassTraffic,
    @Default([]) List<TailscaleProxy> proxies,
  }) = _TailscaleProps;

  factory TailscaleProps.fromJson(Map<String, Object?> json) =>
      _$TailscalePropsFromJson(json);

  factory TailscaleProps.safeFromJson(Map<String, Object?>? json) {
    if (json == null) {
      return defaultTailscaleProps;
    }
    try {
      return TailscaleProps.fromJson(json);
    } catch (_) {
      return defaultTailscaleProps;
    }
  }
}

/// Domains that must leave FlClash's tunnel alone when the host also runs the
/// real Tailscale app/daemon (control plane, DERP, MagicDNS).
const tailscaleBypassDomains = <String>[
  'tailscale.com',
  'tailscale.io',
  'ts.net',
];

/// Clash `fake-ip-filter` entries so Tailscale domains resolve to real public
/// IPs instead of Clash's `198.18.0.0/16` fake-IP range.
///
/// Without these, `controlplane.tailscale.com` is answered as something like
/// `198.18.0.12`, the TLS handshake to the control plane hangs mid-certificate,
/// and `tailscale up` never completes — even if DOMAIN-SUFFIX DIRECT rules are
/// present. Prefix `+.` matches the domain and all subdomains in mihomo.
const tailscaleFakeIpFilters = <String>[
  '+.tailscale.com',
  '+.tailscale.io',
  '+.ts.net',
];

/// Rules that keep the host's own Tailscale traffic outside FlClash's tunnel.
///
/// This is for the case where the same device *also* runs the real Tailscale
/// app/daemon (e.g. a home PC that must stay reachable from outside). Sending
/// the tailnet CGNAT ranges, the control/DERP domains and the `tailscaled`
/// process straight to `DIRECT` stops FlClash from hijacking that traffic, so
/// inbound Tailscale connections keep working regardless of which VPN provider
/// profile is loaded. Pair with [tailscaleFakeIpFilters] so DNS is not
/// poisoned by fake-IP either.
const tailscaleBypassRules = <String>[
  'IP-CIDR,100.64.0.0/10,DIRECT,no-resolve',
  'IP-CIDR6,fd7a:115c:a1e0::/48,DIRECT,no-resolve',
  'PROCESS-NAME,tailscaled,DIRECT',
  'PROCESS-NAME,tailscaled.exe,DIRECT',
  'PROCESS-NAME,tailscale,DIRECT',
  'PROCESS-NAME,tailscale.exe,DIRECT',
  'DOMAIN-SUFFIX,tailscale.com,DIRECT',
  'DOMAIN-SUFFIX,tailscale.io,DIRECT',
  'DOMAIN-SUFFIX,ts.net,DIRECT',
];

/// Builds a single clash rule that routes [dest] through [target].
///
/// The rule type is inferred from [dest]: a CIDR or bare IP becomes an
/// `IP-CIDR`/`IP-CIDR6` rule (bare IPs get a /32 or /128 mask and `no-resolve`),
/// anything else is treated as a domain via `DOMAIN-SUFFIX`.
String buildTailscaleRouteRule(String dest, String target) {
  final value = dest.trim();
  final isV6 = value.contains(':');
  if (value.contains('/')) {
    final type = isV6 ? 'IP-CIDR6' : 'IP-CIDR';
    return '$type,$value,$target,no-resolve';
  }
  final isV4 = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(value);
  if (isV4) {
    return 'IP-CIDR,$value/32,$target,no-resolve';
  }
  if (isV6) {
    return 'IP-CIDR6,$value/128,$target,no-resolve';
  }
  return 'DOMAIN-SUFFIX,$value,$target';
}

extension TailscalePropsExt on TailscaleProps {
  /// The nodes that should actually be merged into the config. Empty when the
  /// feature is switched off so Tailscale stops handling any traffic.
  List<TailscaleProxy> get activeProxies =>
      enable ? proxies : const <TailscaleProxy>[];

  /// Clash rules that FlClash injects at the top of the running configuration.
  ///
  /// These are prepended (highest priority) so they win over whatever the
  /// imported VPN provider profile does, which means the user does not have to
  /// hand-edit rules for every profile. Two independent things are produced:
  ///
  /// * Per-node [TailscaleProxy.routes] -> a rule sending that destination
  ///   through the node (only when [enable] is on, since the outbound only
  ///   exists then). This is how a phone reaches the home host through
  ///   FlClash's built-in tailnet node without running the Tailscale app.
  /// * [bypassTraffic] -> the [tailscaleBypassRules] so a device that also runs
  ///   the Tailscale service keeps that traffic direct.
  ///
  /// Route rules come first so a specific destination still wins over the broad
  /// bypass range even if both options are enabled at once.
  List<String> buildInjectedRules() {
    final rules = <String>[];
    if (enable) {
      for (final proxy in proxies.where((item) => item.isValid)) {
        for (final dest in proxy.routes) {
          if (dest.trim().isEmpty) {
            continue;
          }
          rules.add(buildTailscaleRouteRule(dest, proxy.name.trim()));
        }
      }
    }
    if (bypassTraffic) {
      rules.addAll(tailscaleBypassRules);
    }
    return rules;
  }

  /// Fake-IP filter entries injected when [bypassTraffic] is on.
  ///
  /// Empty when the toggle is off so DNS behaviour is unchanged. See
  /// [tailscaleFakeIpFilters].
  List<String> buildFakeIpFilters() =>
      bypassTraffic ? tailscaleFakeIpFilters : const <String>[];
}

/// A user authored Tailscale outbound node.
///
/// The mihomo core (built with the `with_gvisor` tag and without
/// `no_tailscale`) already supports a `tailscale` outbound. FlClash only ever
/// received proxies from imported subscription YAML, so there was no way to add
/// a Tailscale node from the app. This model captures the fields the core
/// understands and can serialize them into a proxy map that is merged into the
/// generated config through [toOutboundJson].
@freezed
abstract class TailscaleProxy with _$TailscaleProxy {
  const factory TailscaleProxy({
    required String name,
    @Default('') String authKey,
    @Default('') String hostname,
    @Default('') String controlUrl,
    @Default('') String stateDir,
    @Default(false) bool ephemeral,
    @Default(false) bool udp,
    @Default(false) bool acceptRoutes,
    @Default('') String exitNode,
    @Default(false) bool exitNodeAllowLanAccess,
    @Default([]) List<String> routes,
  }) = _TailscaleProxy;

  factory TailscaleProxy.fromJson(Map<String, Object?> json) =>
      _$TailscaleProxyFromJson(json);
}

extension TailscaleProxyExt on TailscaleProxy {
  /// Whether the node has the minimum data required to build a valid outbound.
  bool get isValid => name.trim().isNotEmpty;

  /// Builds the mihomo `proxies` entry for this node.
  ///
  /// Only non empty optional values are emitted so the core keeps its own
  /// defaults for anything left blank. Keys use the kebab-case names the core
  /// parser expects (see `adapter/outbound/tailscale.go`).
  Map<String, dynamic> toOutboundJson() {
    final map = <String, dynamic>{
      'name': name.trim(),
      'type': tailscaleProxyType,
    };
    if (authKey.trim().isNotEmpty) {
      map['auth-key'] = authKey.trim();
    }
    if (hostname.trim().isNotEmpty) {
      map['hostname'] = hostname.trim();
    }
    if (controlUrl.trim().isNotEmpty) {
      map['control-url'] = controlUrl.trim();
    }
    if (stateDir.trim().isNotEmpty) {
      map['state-dir'] = stateDir.trim();
    }
    if (ephemeral) {
      map['ephemeral'] = true;
    }
    if (udp) {
      map['udp'] = true;
    }
    if (acceptRoutes) {
      map['accept-routes'] = true;
    }
    if (exitNode.trim().isNotEmpty) {
      map['exit-node'] = exitNode.trim();
      map['exit-node-allow-lan-access'] = exitNodeAllowLanAccess;
    }
    return map;
  }
}

extension TailscaleProxyListExt on List<TailscaleProxy> {
  /// Merges the valid Tailscale nodes in this list into a raw clash config
  /// [rawConfig]'s `proxies` list.
  ///
  /// Nodes are matched by `name`; an existing proxy with the same name is
  /// replaced so the app authored value always wins. The input map is not
  /// mutated. Returns a new config map ready to be serialized to YAML.
  Map<String, dynamic> mergeInto(Map<String, dynamic> rawConfig) {
    final validProxies = where((item) => item.isValid).toList();
    if (validProxies.isEmpty) {
      return Map<String, dynamic>.from(rawConfig);
    }
    final nextConfig = Map<String, dynamic>.from(rawConfig);
    final existing = <dynamic>[
      ...?(nextConfig['proxies'] as List?),
    ];
    final tailscaleNames = validProxies.map((item) => item.name.trim()).toSet();
    existing.removeWhere((item) {
      return item is Map && tailscaleNames.contains(item['name']);
    });
    existing.addAll(validProxies.map((item) => item.toOutboundJson()));
    nextConfig['proxies'] = existing;
    return nextConfig;
  }
}

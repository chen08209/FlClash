import 'dart:io' show InternetAddress, InternetAddressType;

import 'package:fl_clash/common/cidr.dart';

enum MitmNetworkKey {
  nameserver('nameserver'),
  defaultNameserver('default-nameserver'),
  fakeIpFilter('fake-ip-filter'),
  nameserverPolicy('nameserver-policy'),
  hosts('hosts'),
  routeAddress('route-address'),
  routeExcludeAddress('route-exclude-address'),
  bypassDomain('bypass-domain');

  const MitmNetworkKey(this.path);

  final String path;
}

class MitmListEdit {
  const MitmListEdit({
    this.replace = false,
    this.before = const [],
    this.after = const [],
  });

  final bool replace;
  final List<String> before;
  final List<String> after;

  List<String> get values => [...before, ...after];

  List<String> applyTo(List<String> current) =>
      {...before, if (!replace) ...current, ...after}.toList();

  MitmListEdit then(MitmListEdit next) => next.replace
      ? next
      : MitmListEdit(
          replace: replace,
          before: [...next.before, ...before],
          after: [...after, ...next.after],
        );

  @override
  bool operator ==(Object other) =>
      other is MitmListEdit &&
      other.replace == replace &&
      _sameList(other.before, before) &&
      _sameList(other.after, after);

  @override
  int get hashCode =>
      Object.hash(replace, Object.hashAll(before), Object.hashAll(after));
}

bool _sameList(List<String> a, List<String> b) =>
    a.length == b.length &&
    Iterable.generate(a.length).every((index) => a[index] == b[index]);

bool _sameMap(Map<String, List<String>> a, Map<String, List<String>> b) =>
    a.length == b.length &&
    a.entries.every(
      (entry) => b[entry.key] != null && _sameList(entry.value, b[entry.key]!),
    );

List<String> _listOf(Object? value) => switch (value) {
  final List list => [for (final item in list) '$item'],
  final String text when text.isNotEmpty => [text],
  _ => const [],
};

/// The DNS, TUN and system proxy settings a module changes. A module is
/// specific where the app's overrides are general, so it goes over both them
/// and the profile.
class MitmNetwork {
  const MitmNetwork({
    this.nameserver,
    this.defaultNameserver,
    this.fakeIpFilter,
    this.nameserverPolicy = const {},
    this.hosts = const {},
    this.routeAddress = const [],
    this.routeExcludeAddress,
    this.bypassDomain,
  });

  final MitmListEdit? nameserver;
  final MitmListEdit? defaultNameserver;
  final MitmListEdit? fakeIpFilter;
  final Map<String, List<String>> nameserverPolicy;
  final Map<String, List<String>> hosts;
  final List<String> routeAddress;
  final MitmListEdit? routeExcludeAddress;
  final MitmListEdit? bypassDomain;

  bool get isEmpty => changes.isEmpty;

  MitmListEdit? editOf(MitmNetworkKey key) => switch (key) {
    MitmNetworkKey.nameserver => nameserver,
    MitmNetworkKey.defaultNameserver => defaultNameserver,
    MitmNetworkKey.fakeIpFilter => fakeIpFilter,
    MitmNetworkKey.routeExcludeAddress => routeExcludeAddress,
    MitmNetworkKey.bypassDomain => bypassDomain,
    _ => null,
  };

  List<MitmNetworkChange> get changes => [
    for (final key in const [
      MitmNetworkKey.nameserver,
      MitmNetworkKey.defaultNameserver,
      MitmNetworkKey.fakeIpFilter,
    ])
      if (editOf(key) case final edit?) MitmNetworkChange(key, edit: edit),
    for (final MapEntry(:key, :value) in nameserverPolicy.entries)
      MitmNetworkChange(
        MitmNetworkKey.nameserverPolicy,
        entry: key,
        values: value,
      ),
    for (final MapEntry(:key, :value) in hosts.entries)
      MitmNetworkChange(MitmNetworkKey.hosts, entry: key, values: value),
    if (routeAddress.isNotEmpty)
      MitmNetworkChange(MitmNetworkKey.routeAddress, values: routeAddress),
    for (final key in const [
      MitmNetworkKey.routeExcludeAddress,
      MitmNetworkKey.bypassDomain,
    ])
      if (editOf(key) case final edit?) MitmNetworkChange(key, edit: edit),
  ];

  static MitmNetwork merge(Iterable<MitmNetwork> modules) {
    MitmListEdit? fold(MitmListEdit? Function(MitmNetwork module) of) =>
        modules.fold<MitmListEdit?>(
          null,
          (merged, module) => switch (of(module)) {
            final next? => merged?.then(next) ?? next,
            null => merged,
          },
        );
    return MitmNetwork(
      nameserver: fold((module) => module.nameserver),
      defaultNameserver: fold((module) => module.defaultNameserver),
      fakeIpFilter: fold((module) => module.fakeIpFilter),
      nameserverPolicy: {
        for (final module in modules) ...module.nameserverPolicy,
      },
      hosts: {for (final module in modules) ...module.hosts},
      routeAddress: {
        for (final module in modules) ...module.routeAddress,
      }.toList(),
      routeExcludeAddress: fold((module) => module.routeExcludeAddress),
      bypassDomain: fold((module) => module.bypassDomain),
    );
  }

  void applyToDns(Map<String, dynamic> dns) {
    for (final key in const [
      MitmNetworkKey.nameserver,
      MitmNetworkKey.defaultNameserver,
      MitmNetworkKey.fakeIpFilter,
    ]) {
      if (editOf(key) case final edit?) {
        dns[key.path] = edit.applyTo(_listOf(dns[key.path]));
      }
    }
    if (nameserverPolicy.isNotEmpty) {
      dns[MitmNetworkKey.nameserverPolicy.path] = {
        if (dns[MitmNetworkKey.nameserverPolicy.path] case final Map policy)
          ...policy.cast<String, dynamic>(),
        ...nameserverPolicy,
      };
    }
  }

  /// Included routes only widen a list that names any: an empty one already
  /// routes everything, and Surge adds them beside the default route.
  void applyToTun(Map tun) {
    final included = _listOf(tun[MitmNetworkKey.routeAddress.path]);
    if (routeAddress.isNotEmpty && included.isNotEmpty) {
      tun[MitmNetworkKey.routeAddress.path] = {
        ...included,
        ...routeAddress,
      }.toList();
    }
    if (routeExcludeAddress case final edit?) {
      tun[MitmNetworkKey.routeExcludeAddress.path] = edit.applyTo(
        _listOf(tun[MitmNetworkKey.routeExcludeAddress.path]),
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is MitmNetwork &&
      other.nameserver == nameserver &&
      other.defaultNameserver == defaultNameserver &&
      other.fakeIpFilter == fakeIpFilter &&
      _sameMap(other.nameserverPolicy, nameserverPolicy) &&
      _sameMap(other.hosts, hosts) &&
      _sameList(other.routeAddress, routeAddress) &&
      other.routeExcludeAddress == routeExcludeAddress &&
      other.bypassDomain == bypassDomain;

  @override
  int get hashCode => Object.hash(
    nameserver,
    defaultNameserver,
    fakeIpFilter,
    Object.hashAll(nameserverPolicy.keys),
    Object.hashAll(hosts.keys),
    Object.hashAll(routeAddress),
    routeExcludeAddress,
    bypassDomain,
  );
}

class MitmNetworkChange {
  const MitmNetworkChange(
    this.key, {
    this.entry,
    this.values = const [],
    this.edit,
  });

  final MitmNetworkKey key;

  final String? entry;
  final List<String> values;
  final MitmListEdit? edit;

  /// Whether this sets the whole of what it changes, so whatever stood
  /// before it, the user's own setting included, no longer counts.
  bool get replaces => entry != null || (edit?.replace ?? false);

  bool replacedBy(MitmNetwork later) => switch (key) {
    MitmNetworkKey.nameserverPolicy => later.nameserverPolicy.containsKey(
      entry,
    ),
    MitmNetworkKey.hosts => later.hosts.containsKey(entry),
    _ => later.editOf(key)?.replace ?? false,
  };
}

final _ipWithPort = RegExp(r'^\[?([0-9a-fA-F:.]+)\]?(?::\d{1,5})?$');
final _dnsScheme = RegExp(
  r'^(?:udp|tcp|tls|https|http|quic|system|dhcp|rcode)://\S+$',
);

String? mitmDnsServer(String server) {
  final value = server.trim();
  if (value == 'system' || value == 'syslib') {
    return 'system://';
  }
  if (value.startsWith('h3://')) {
    final url = 'https://${value.substring('h3://'.length)}';
    return url.contains('#') ? '$url&h3=true' : '$url#h3=true';
  }
  if (_dnsScheme.hasMatch(value)) {
    return value;
  }
  final address = _ipWithPort.firstMatch(value)?.group(1);
  return address != null && InternetAddress.tryParse(address) != null
      ? value
      : null;
}

bool isMitmPlainDnsServer(String server) =>
    server == 'system://' || _ipWithPort.hasMatch(server);

/// A route Surge, Loon or Stash writes as an address alone reads as a host.
String? mitmRoute(String route) {
  final value = route.trim();
  if (isCidr(value)) {
    return value;
  }
  final address = InternetAddress.tryParse(value);
  if (address == null) {
    return null;
  }
  final bits = address.type == InternetAddressType.IPv4 ? 32 : 128;
  return '$value/$bits';
}

import 'dart:io';

/// WinINet rejects the whole list over one bare IPv6 literal, so the system
/// proxy is not set at all, and its `<local>` token for single-label intranet
/// hosts like `nas` has no cross-platform pattern. Loopback needs no entry:
/// WinINet never proxies it.
List<String> windowsBypassList(List<String> bypassDomain) {
  final entries = <String>{};
  for (final domain in bypassDomain) {
    final entry = domain.trim();
    if (entry.isEmpty) continue;
    final isBareIPv6 =
        InternetAddress.tryParse(entry)?.type == InternetAddressType.IPv6;
    entries.add(isBareIPv6 ? '[$entry]' : entry);
  }
  return {...entries, '<local>'}.toList();
}

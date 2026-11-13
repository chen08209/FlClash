import 'dart:async';

import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/common/print.dart';
import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/enum/enum.dart';

class SystemDnsRecord {
  final String service;
  final List<String> servers;

  const SystemDnsRecord({required this.service, required this.servers});

  static SystemDnsRecord? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final service = json['service'];
    final servers = json['servers'];
    if (service is! String || service.isEmpty || servers is! List) {
      return null;
    }
    return SystemDnsRecord(
      service: service,
      servers: servers.whereType<String>().toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemDnsRecord &&
          other.service == service &&
          stringListEquality.equals(other.servers, servers);

  @override
  int get hashCode => Object.hash(service, stringListEquality.hash(servers));

  @override
  String toString() => 'SystemDnsRecord($service, $servers)';
}

abstract interface class SystemDnsPort {
  Future<bool> writeDnsServers(String service, List<String> servers);
}

abstract interface class SystemDnsStore {
  Future<SystemDnsRecord?> read();

  Future<void> clear();
}

final class PreferencesSystemDnsStore implements SystemDnsStore {
  const PreferencesSystemDnsStore();

  @override
  Future<SystemDnsRecord?> read() => preferences.getSystemDnsRecord();

  @override
  Future<void> clear() => preferences.clearSystemDnsRecord();
}

/// Builds before `tun.dns-mode` appended a resolver to the default service's
/// saved settings and kept the original list until they put it back, so one
/// that exited without restoring left it in the user's network preferences.
Future<void> restoreLegacySystemDns({
  SystemDnsPort? port,
  SystemDnsStore store = const PreferencesSystemDnsStore(),
}) async {
  try {
    final record = await store.read();
    if (record == null) {
      return;
    }
    await (port ?? macOS)?.writeDnsServers(record.service, record.servers);
    await store.clear();
  } catch (error) {
    commonPrint.log(
      'Restoring the system DNS failed: ${compactError(error)}',
      logLevel: LogLevel.warning,
    );
  }
}

import 'dart:math' as math;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:path/path.dart' as p;

final _invalidProcessRuleContent = RegExp(r'[,\r\n]');

class ApplicationIdentity {
  const ApplicationIdentity({
    required this.action,
    required this.content,
    required this.windows,
  });

  final RuleAction action;
  final String content;
  final bool windows;

  String get key => '${action.value}:${_normalize(content)}';

  String get name => action == RuleAction.PROCESS_PATH
      ? (windows ? p.windows : p.posix).basename(content)
      : content;

  bool get canRoute =>
      (action == RuleAction.PROCESS_PATH || action == RuleAction.PROCESS_NAME) &&
      content.trim().isNotEmpty &&
      !_invalidProcessRuleContent.hasMatch(content);

  String _normalize(String value) => windows
      ? (action == RuleAction.PROCESS_PATH
                ? p.windows.normalize(value)
                : value)
            .toLowerCase()
      : value;

  bool matchesRule(Rule rule) =>
      rule.ruleAction == action &&
      !rule.src &&
      _normalize(rule.content ?? '') == _normalize(content);
}

enum ApplicationRoute { proxy, direct, mixed, blocked, unknown, idle }

typedef ApplicationConnection = ({
  String id,
  String process,
  String path,
  String? outbound,
  DateTime start,
  int upload,
  int download,
});

List<ApplicationConnection> applicationConnectionsOf(
  List<TrackerInfo> connections,
) => [
  for (final connection in connections)
    (
      id: connection.id,
      process: connection.metadata.process,
      path: connection.metadata.processPath,
      outbound: connection.chains.firstOrNull,
      start: connection.start,
      upload: connection.upload,
      download: connection.download,
    ),
];

class ApplicationProxyInfo {
  ApplicationProxyInfo(this.identity, {this.target});

  final ApplicationIdentity? identity;
  final String? target;
  int connections = 0;
  int proxy = 0;
  int direct = 0;
  int blocked = 0;
  int unknown = 0;
  int upload = 0;
  int download = 0;
  int uploadSpeed = 0;
  int downloadSpeed = 0;

  ApplicationRoute get route {
    if (connections == 0) return ApplicationRoute.idle;
    if (proxy == connections) return ApplicationRoute.proxy;
    if (direct == connections) return ApplicationRoute.direct;
    if (blocked == connections) return ApplicationRoute.blocked;
    if (unknown == connections) return ApplicationRoute.unknown;
    return ApplicationRoute.mixed;
  }
}

typedef ApplicationTrafficSample = ({
  DateTime start,
  int upload,
  int download,
  int uploadSpeed,
  int downloadSpeed,
});

class ApplicationProxySnapshot {
  const ApplicationProxySnapshot({
    required this.applications,
    required this.samples,
    required this.sampledAt,
  });

  final List<ApplicationProxyInfo> applications;
  final Map<String, ApplicationTrafficSample> samples;
  final DateTime? sampledAt;
}

typedef ApplicationProxyInput = ({
  List<ApplicationConnection> connections,
  List<Rule> rules,
  DateTime? sampledAt,
  Map<String, ApplicationTrafficSample> previousSamples,
  DateTime? previousAt,
  bool windows,
});

ApplicationProxySnapshot aggregateApplicationProxies(
  ApplicationProxyInput input,
) {
  final configured =
      <String, ({ApplicationIdentity identity, Rule rule, int index})>{};
  for (var index = 0; index < input.rules.length; index++) {
    final rule = input.rules[index];
    final identity = ApplicationIdentity(
      action: rule.ruleAction,
      content: rule.content ?? '',
      windows: input.windows,
    );
    if (rule.src || !identity.canRoute) continue;
    configured.putIfAbsent(
      identity.key,
      () => (identity: identity, rule: rule, index: index),
    );
  }
  final applications = <String, ApplicationProxyInfo>{
    for (final entry in configured.entries)
      entry.key: ApplicationProxyInfo(
        entry.value.identity,
        target: entry.value.rule.ruleTarget,
      ),
  };
  final samples = <String, ApplicationTrafficSample>{};
  final previousTime = input.previousAt;
  final sampledAt = input.sampledAt;
  final elapsed = sampledAt != null && previousTime != null
      ? sampledAt.difference(previousTime).inMicroseconds / 1000000
      : null;
  for (final connection in input.connections) {
    final path = ApplicationIdentity(
      action: RuleAction.PROCESS_PATH,
      content: connection.path,
      windows: input.windows,
    );
    final name = ApplicationIdentity(
      action: RuleAction.PROCESS_NAME,
      content: connection.process,
      windows: input.windows,
    );
    final pathRule = configured[path.key];
    final nameRule = configured[name.key];
    final ApplicationIdentity? identity;
    if (pathRule != null &&
        (nameRule == null || pathRule.index < nameRule.index)) {
      identity = pathRule.identity;
    } else if (nameRule != null) {
      identity = nameRule.identity;
    } else if (path.canRoute) {
      identity = path;
    } else if (name.canRoute) {
      identity = name;
    } else if (path.content.isNotEmpty) {
      identity = path;
    } else if (name.content.isNotEmpty) {
      identity = name;
    } else {
      identity = null;
    }
    final application = applications.putIfAbsent(
      identity?.key ?? '',
      () => ApplicationProxyInfo(identity),
    );
    application.connections++;
    application.upload += connection.upload;
    application.download += connection.download;
    switch (connection.outbound) {
      case 'DIRECT':
      case 'COMPATIBLE':
        application.direct++;
      case 'REJECT':
      case 'REJECT-DROP':
        application.blocked++;
      case null:
      case '':
      case 'PASS':
      case 'PASS-RULE':
        application.unknown++;
      default:
        application.proxy++;
    }
    final old = input.previousSamples[connection.id];
    var uploadSpeed = 0;
    var downloadSpeed = 0;
    if (elapsed == 0 && old?.start == connection.start) {
      uploadSpeed = old!.uploadSpeed;
      downloadSpeed = old.downloadSpeed;
    } else if (elapsed != null && elapsed > 0 && elapsed <= 10) {
      final sameConnection = old?.start == connection.start;
      final newlyObserved = old == null &&
          !connection.start.isBefore(previousTime!);
      if (sameConnection || newlyObserved) {
        uploadSpeed = (math.max(
          0,
          connection.upload - (sameConnection ? old!.upload : 0),
        ) / elapsed).round();
        downloadSpeed = (math.max(
          0,
          connection.download - (sameConnection ? old!.download : 0),
        ) / elapsed).round();
      }
    }
    application.uploadSpeed += uploadSpeed;
    application.downloadSpeed += downloadSpeed;
    samples[connection.id] = (
      start: connection.start,
      upload: connection.upload,
      download: connection.download,
      uploadSpeed: uploadSpeed,
      downloadSpeed: downloadSpeed,
    );
  }
  final rows = applications.values.toList()
    ..sort((a, b) {
      final active = b.connections.compareTo(a.connections);
      return active != 0
          ? active
          : (a.identity?.key ?? '').compareTo(b.identity?.key ?? '');
    });
  return ApplicationProxySnapshot(
    applications: rows,
    samples: samples,
    sampledAt: sampledAt,
  );
}

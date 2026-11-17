part of 'dto.dart';

int _int(Object? value) => (value as num? ?? 0).toInt();

List<int> _ints(Object? value) => [
  for (final item in value as List? ?? const []) _int(item),
];

/// `mitm.readModule`: how the Core reads a module with these argument values,
/// each line by its line number in the module.
@immutable
final class MitmModuleRead {
  const MitmModuleRead({
    required this.format,
    this.meta = const MitmModuleMeta(),
    this.off,
    this.arguments = const [],
    this.resources = const [],
    this.declaredScripts = const [],
    this.asksConsent = false,
    this.issues = const {},
    this.views = const {},
    this.rules = const [],
    this.ruleSets = const [],
    this.network = const {},
    this.ignored = const [],
  });

  /// `surge`, `loon`, `quantumult-x` or `stash`.
  final String format;
  final MitmModuleMeta meta;

  /// Why the module takes no effect as a whole: `requirement` or
  /// `requirementUnreadable`.
  final String? off;
  final List<MitmModuleArgumentView> arguments;
  final List<MitmModuleResource> resources;
  final List<int> declaredScripts;
  final bool asksConsent;

  /// As `mitm.validate` answers them, by list key; an `index` is a module line.
  final JsonMap issues;
  final JsonMap views;
  final List<MitmModuleRule> rules;
  final List<MitmModuleRuleSet> ruleSets;

  /// In the Core's `MitmModuleNetwork` keys.
  final JsonMap network;
  final List<MitmModuleIgnoredLine> ignored;

  factory MitmModuleRead.fromJson(JsonMap json) => MitmModuleRead(
    format: json['format'] as String? ?? '',
    meta: MitmModuleMeta.fromJson(_optionalMap(json['meta']) ?? const {}),
    off: _optionalMap(json['off'])?['reason'] as String?,
    arguments: _list(json['arguments'], MitmModuleArgumentView.fromJson),
    resources: _list(json['resources'], MitmModuleResource.fromJson),
    declaredScripts: _ints(json['declaredScripts']),
    asksConsent: json['asksConsent'] as bool? ?? false,
    issues: _optionalMap(json['issues']) ?? const {},
    views: _optionalMap(json['views']) ?? const {},
    rules: _list(json['rules'], MitmModuleRule.fromJson),
    ruleSets: _list(json['ruleSets'], MitmModuleRuleSet.fromJson),
    network: _optionalMap(json['network']) ?? const {},
    ignored: _list(json['ignored'], MitmModuleIgnoredLine.fromJson),
  );

  /// The policy names its rules leave to the host to map.
  Set<String> get namedPolicies => {
    for (final rule in rules)
      if (!rule.policy.builtin) rule.policy.name,
  };
}

@immutable
final class MitmModuleMeta {
  const MitmModuleMeta({
    this.name,
    this.desc,
    this.author,
    this.icon,
    this.homepage,
    this.category,
    this.system,
    this.requirement,
    this.argumentsDesc,
  });

  final String? name;
  final String? desc;
  final String? author;
  final String? icon;
  final String? homepage;
  final String? category;
  final String? system;
  final String? requirement;
  final String? argumentsDesc;

  factory MitmModuleMeta.fromJson(JsonMap json) => MitmModuleMeta(
    name: json['name'] as String?,
    desc: json['desc'] as String?,
    author: json['author'] as String?,
    icon: json['icon'] as String?,
    homepage: json['homepage'] as String?,
    category: json['category'] as String?,
    system: json['system'] as String?,
    requirement: json['requirement'] as String?,
    argumentsDesc: json['argumentsDesc'] as String?,
  );
}

enum MitmArgumentType { text, switcher, select }

@immutable
final class MitmModuleArgumentView {
  const MitmModuleArgumentView({
    required this.name,
    this.type = MitmArgumentType.text,
    this.options = const [],
    this.number = false,
    this.defaultValue = '',
    this.label,
    this.desc,
    this.line = 0,
  });

  final String name;
  final MitmArgumentType type;
  final List<String> options;
  final bool number;
  final String defaultValue;
  final String? label;
  final String? desc;
  final int line;

  factory MitmModuleArgumentView.fromJson(JsonMap json) {
    final kind = _optionalMap(json['kind']) ?? const {};
    return MitmModuleArgumentView(
      name: json['name'] as String,
      type: switch (kind['type']) {
        'switch' => MitmArgumentType.switcher,
        'select' => MitmArgumentType.select,
        _ => MitmArgumentType.text,
      },
      options: _strings(kind['options']),
      number: json['number'] as bool? ?? false,
      defaultValue: json['default'] as String? ?? '',
      label: json['label'] as String?,
      desc: json['desc'] as String?,
      line: _int(json['line']),
    );
  }
}

@immutable
final class MitmModuleResource {
  const MitmModuleResource({
    required this.url,
    required this.kind,
    this.lines = const [],
  });

  final String url;

  /// `script`, `map-local` or `jq`.
  final String kind;
  final List<int> lines;

  factory MitmModuleResource.fromJson(JsonMap json) => MitmModuleResource(
    url: json['url'] as String,
    kind: json['kind'] as String? ?? '',
    lines: _ints(json['lines']),
  );
}

/// A built-in policy such as `REJECT`, or a name the host maps to an outbound.
@immutable
final class MitmModulePolicy {
  const MitmModulePolicy(this.name, {required this.builtin});

  final String name;
  final bool builtin;

  factory MitmModulePolicy.fromJson(JsonMap json) => switch (json) {
    {'builtin': final String name} => MitmModulePolicy(name, builtin: true),
    {'named': final String name} => MitmModulePolicy(name, builtin: false),
    _ => const MitmModulePolicy('', builtin: false),
  };

  @override
  bool operator ==(Object other) =>
      other is MitmModulePolicy &&
      other.name == name &&
      other.builtin == builtin;

  @override
  int get hashCode => Object.hash(name, builtin);
}

@immutable
final class MitmModuleRule {
  const MitmModuleRule({
    required this.line,
    required this.rule,
    required this.policy,
    this.noResolve = false,
    this.extendedMatching = false,
    this.requiresResolve = false,
  });

  final int line;

  /// What goes before the policy in a profile's rule line.
  final String rule;
  final MitmModulePolicy policy;
  final bool noResolve;

  /// Surge's `extended-matching`, which the Core reads but does not apply.
  final bool extendedMatching;

  /// A `SCRIPT` rule's `requires-resolve`.
  final bool requiresResolve;

  factory MitmModuleRule.fromJson(JsonMap json) => MitmModuleRule(
    line: _int(json['line']),
    rule: json['rule'] as String,
    policy: MitmModulePolicy.fromJson(_map(json['policy'])),
    noResolve: json['noResolve'] as bool? ?? false,
    extendedMatching: json['extendedMatching'] as bool? ?? false,
    requiresResolve: json['requiresResolve'] as bool? ?? false,
  );
}

@immutable
final class MitmModuleRuleSet {
  const MitmModuleRuleSet({
    required this.name,
    this.domain = false,
    required this.type,
    this.url,
    this.interval,
    this.file,
    this.rules = const [],
  });

  final String name;
  final bool domain;

  /// `url`, `inline`, `builtin` or `file`.
  final String type;
  final String? url;
  final int? interval;
  final String? file;

  /// An inline or built-in set's rules.
  final List<String> rules;

  factory MitmModuleRuleSet.fromJson(JsonMap json) {
    final source = _optionalMap(json['source']) ?? const {};
    final rules = source['rules'] as List? ?? const [];
    return MitmModuleRuleSet(
      name: json['name'] as String,
      domain: json['domain'] as bool? ?? false,
      type: source['type'] as String? ?? '',
      url: source['url'] as String?,
      interval: (source['interval'] as num?)?.toInt(),
      file: source['file'] as String?,
      rules: [
        for (final rule in rules)
          if (rule is Map) '${rule['rule']}' else '$rule',
      ],
    );
  }
}

@immutable
final class MitmModuleIgnoredLine {
  const MitmModuleIgnoredLine({
    required this.line,
    required this.text,
    required this.reason,
    this.detail,
  });

  final int line;
  final String text;

  /// The Core's `MitmIgnoreReason`, as `appOnly`.
  final String reason;
  final String? detail;

  factory MitmModuleIgnoredLine.fromJson(JsonMap json) => MitmModuleIgnoredLine(
    line: _int(json['line']),
    text: json['text'] as String? ?? '',
    reason: json['reason'] as String? ?? '',
    detail: json['detail'] as String?,
  );
}

/// `mitm.moduleStatus`: a module of the profile in force and its remote files.
@immutable
final class MitmModuleStatus {
  const MitmModuleStatus({
    required this.name,
    this.inForce = false,
    this.problem,
    this.problemDetail,
    this.off,
    this.resources = const [],
    this.refusedRules = const [],
    this.hostNetwork = const {},
  });

  final String name;
  final bool inForce;

  /// `unreadable` or `duplicate`.
  final String? problem;
  final String? problemDetail;
  final String? off;
  final List<MitmModuleResourceStatus> resources;
  final List<MitmRefusedRule> refusedRules;
  final JsonMap hostNetwork;

  factory MitmModuleStatus.fromJson(JsonMap json) {
    final problem = _optionalMap(json['problem']);
    return MitmModuleStatus(
      name: json['name'] as String,
      inForce: json['inForce'] as bool? ?? false,
      problem: problem?['reason'] as String?,
      problemDetail: problem?['detail'] as String?,
      off: _optionalMap(json['off'])?['reason'] as String?,
      resources: _list(json['resources'], MitmModuleResourceStatus.fromJson),
      refusedRules: _list(json['refusedRules'], MitmRefusedRule.fromJson),
      hostNetwork: _optionalMap(json['hostNetwork']) ?? const {},
    );
  }
}

enum MitmResourceState {
  ok,
  failed,
  missing,
  fetching;

  static MitmResourceState parse(Object? name) =>
      _enum(values, name, MitmResourceState.missing);
}

@immutable
final class MitmModuleResourceStatus {
  const MitmModuleResourceStatus({
    required this.url,
    this.kind = '',
    this.lines = const [],
    this.file,
    this.state = MitmResourceState.missing,
    this.error,
  });

  final String url;
  final String kind;
  final List<int> lines;

  /// The file in the MITM resources directory the lines read.
  final String? file;
  final MitmResourceState state;
  final MitmFetchFailure? error;

  factory MitmModuleResourceStatus.fromJson(JsonMap json) =>
      MitmModuleResourceStatus(
        url: json['url'] as String,
        kind: json['kind'] as String? ?? '',
        lines: _ints(json['lines']),
        file: json['file'] as String?,
        state: MitmResourceState.parse(json['state']),
        error: switch (_optionalMap(json['error'])) {
          final JsonMap error => MitmFetchFailure.fromJson(error),
          null => null,
        },
      );
}

@immutable
final class MitmFetchFailure {
  const MitmFetchFailure({required this.reason, this.status, this.detail = ''});

  /// `http`, `dns`, `tls`, `timeout`, `connection` or `other`.
  final String reason;

  /// The HTTP status of an `http` failure.
  final int? status;
  final String detail;

  factory MitmFetchFailure.fromJson(JsonMap json) => MitmFetchFailure(
    reason: json['reason'] as String? ?? 'other',
    status: (json['status'] as num?)?.toInt(),
    detail: json['detail'] as String? ?? '',
  );
}

@immutable
final class MitmRefusedRule {
  const MitmRefusedRule({required this.line, this.detail = ''});

  final int line;
  final String detail;

  factory MitmRefusedRule.fromJson(JsonMap json) => MitmRefusedRule(
    line: _int(json['line']),
    detail: json['detail'] as String? ?? '',
  );
}

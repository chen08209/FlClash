import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/loon_rewrite.dart';
import 'package:fl_clash/common/mitm_network.dart';
import 'package:fl_clash/common/mitm_requirement.dart';
import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:path/path.dart' as p;

enum MitmModuleArgumentType { input, select, toggle }

class MitmModuleArgument {
  const MitmModuleArgument({
    required this.name,
    required this.defaultValue,
    this.type = MitmModuleArgumentType.input,
    this.options = const [],
    this.label,
    this.description,
    this.number = false,
  });

  final String name;
  final String defaultValue;
  final MitmModuleArgumentType type;
  final List<String> options;
  final String? label;
  final String? description;

  /// A number, as Loon's type=number and Stash's integer values are, which an
  /// object argument or a json value hands over as a number.
  final bool number;

  String get title => label ?? name;
}

enum MitmModuleSkipReason {
  section,
  setting,
  scriptType,
  event,
  disabled,
  rule,
  httpRulePolicy,
  finalRule,
  deviceRule,
  requirement,
  managedCa,
  proxies,
  appOnly,
  reflect,
  conditional,

  /// `skip-server-cert-verify` with a hostname entry that covers every host.
  skipVerifyAll,
  relativeData,
  notDownloaded,
  unreadable,
}

class MitmModuleSkip {
  const MitmModuleSkip(this.section, this.line, this.reason);

  final String section;
  final String line;
  final MitmModuleSkipReason reason;
}

/// What a Surge module, a Loon plugin, a Quantumult X snippet or a Stash
/// override adds, in the syntax of FlClash's own lists; the Core still judges
/// each line.
class MitmModuleContent {
  MitmModuleContent({
    this.name,
    this.description,
    this.system,
    this.argumentsDescription,
    this.arguments = const [],
    this.insertedHostname = const [],
    this.hostname = const [],
    this.urlRewrite = const [],
    this.headerRewrite = const [],
    this.bodyRewrite = const [],
    this.mapLocal = const [],
    this.requestBodyMock = const [],
    this.clientSourceAddress = const [],
    this.skipVerifyHostname = const [],
    this.script = const [],
    this.declaredScriptLines = const [],
    this.rules = const [],
    this.resourceUrls = const {},
    this.inlineResources = const {},
    this.skipped = const [],
    this.requestRules = 0,
    this.h2 = false,
    this.requirement,
    this.requirementMet,
    this.ruleProviders = const {},
    this.exits = const {},
    this.network = const MitmNetwork(),
  });

  final String? name;
  final String? description;
  final String? system;
  final String? argumentsDescription;
  final List<MitmModuleArgument> arguments;

  /// Placed by `%INSERT%`, ahead of what other modules append.
  final List<String> insertedHostname;
  final List<String> hostname;
  final List<String> urlRewrite;
  final List<String> headerRewrite;
  final List<String> bodyRewrite;
  final List<String> mapLocal;
  final List<String> requestBodyMock;
  final List<String> clientSourceAddress;

  final List<String> skipVerifyHostname;
  final List<String> script;

  /// The scripts it declares that FlClash runs, whatever its arguments leave
  /// on.
  final List<String> declaredScriptLines;
  int get declaredScripts => declaredScriptLines.length;
  final List<String> rules;

  /// The rule sets its rules name, under names no profile uses.
  final Map<String, Map<String, Object?>> ruleProviders;

  final Set<String> exits;
  final MitmNetwork network;
  final Set<String> resourceUrls;

  /// What the module writes out itself, by the key [resources] names it with.
  final Map<String, String> inlineResources;
  final List<MitmModuleSkip> skipped;

  final int requestRules;
  final bool h2;
  final String? requirement;

  /// Null when [requirement] cannot be read.
  final bool? requirementMet;

  /// Whether turning it on changes what the user set for traffic it does not
  /// itself rewrite, which they confirm first.
  bool get asksConsent =>
      !network.isEmpty ||
      skipVerifyHostname.isNotEmpty ||
      clientSourceAddress.isNotEmpty;

  bool get isEmpty =>
      lines.isEmpty &&
      rules.isEmpty &&
      resourceUrls.isEmpty &&
      inlineResources.isEmpty &&
      skipped.isEmpty &&
      network.isEmpty;

  MitmRules get mitm => MitmRules(
    hostname: [...insertedHostname, ...hostname],
    urlRewrite: urlRewrite,
    headerRewrite: headerRewrite,
    bodyRewrite: bodyRewrite,
    mapLocal: mapLocal,
    requestBodyMock: requestBodyMock,
    clientSourceAddress: clientSourceAddress,
    skipVerifyHostname: skipVerifyHostname,
    script: script,
    h2: h2,
  );

  List<String> get lines => [
    for (final list in MitmList.values) ...mitm.linesOf(list),
  ];
}

/// The user's own hostnames come first, so an exclusion they wrote holds
/// against any module.
({
  MitmRules mitm,
  List<String> rules,
  Map<String, Map<String, Object?>> ruleProviders,
  Set<String> exits,
  MitmNetwork network,
})
mergeMitmModules(List<String> hostname, Iterable<MitmModuleContent> modules) {
  final contents = modules.toList();
  List<String> all(List<String> Function(MitmModuleContent) of) => [
    for (final module in contents) ...of(module),
  ];
  return (
    mitm: MitmRules(
      hostname: [
        ...hostname,
        ...all((module) => module.insertedHostname),
        ...all((module) => module.hostname),
      ],
      urlRewrite: all((module) => module.urlRewrite),
      headerRewrite: all((module) => module.headerRewrite),
      bodyRewrite: all((module) => module.bodyRewrite),
      mapLocal: all((module) => module.mapLocal),
      requestBodyMock: all((module) => module.requestBodyMock),
      clientSourceAddress: all((module) => module.clientSourceAddress),
      skipVerifyHostname: all((module) => module.skipVerifyHostname),
      script: all((module) => module.script),
      h2: contents.any((module) => module.h2),
    ),
    rules: all((module) => module.rules),
    ruleProviders: _mergeRuleProviders(contents),
    exits: {for (final module in contents) ...module.exits},
    network: MitmNetwork.merge(contents.map((module) => module.network)),
  );
}

/// Inline sets of one name add up, as Surge merges a module's `[Ruleset]`
/// lines into the set of that name.
Map<String, Map<String, Object?>> _mergeRuleProviders(
  List<MitmModuleContent> modules,
) {
  final merged = <String, Map<String, Object?>>{};
  for (final module in modules) {
    for (final MapEntry(:key, :value) in module.ruleProviders.entries) {
      final previous = merged[key];
      merged[key] = previous != null && value['type'] == 'inline'
          ? {
              ...value,
              'payload': {
                ...previous['payload']! as List,
                ...value['payload']! as List,
              }.toList(),
            }
          : {...value};
    }
  }
  return merged;
}

Map<String, String> mitmAttachments(MitmModule module) => {
  if (!module.isRemote)
    for (final MapEntry(:key, :value) in module.resources.entries)
      if (!isMitmResourceUrl(key) && !key.startsWith(_inlineResource))
        key: value,
};

const _inlineResource = 'inline:';

/// Named by content, so a resource that changes changes the line naming it
/// and the Core reads it again.
String mitmResourceName(String source, List<int> bytes) {
  final extension = p.url.extension(Uri.tryParse(source)?.path ?? source);
  final suffix = RegExp(r'^\.[A-Za-z0-9]{1,8}$').hasMatch(extension)
      ? extension.toLowerCase()
      : '';
  return '${sha256.convert(bytes).toString().substring(0, 32)}$suffix';
}

/// The Core's own limit on a map-local file.
const maxMitmResourceSize = 16 << 20;

bool isMitmResourceUrl(String text) =>
    RegExp(r'^https?://', caseSensitive: false).hasMatch(text);

const mitmUrlRewriteSection = 'URL Rewrite';
const mitmMapLocalSection = 'Map Local';

String mitmUrlPattern(String url) {
  final end = url.indexOf(RegExp('[?#]'));
  final escaped = (end < 0 ? url : url.substring(0, end)).replaceAllMapped(
    RegExp(r'[.*+?^${}()|[\]\\]'),
    (match) => '\\${match[0]}',
  );
  return '^$escaped(\\?|\$)';
}

String mitmRejectLine(String url) => '${_field(mitmUrlPattern(url))} reject';

String mitmAttachmentName(String url, Iterable<String> taken) {
  final segment = Uri.tryParse(
    url,
  )?.pathSegments.lastWhereOrNull((segment) => segment.isNotEmpty);
  final base = (segment ?? '').replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final name = base.isEmpty || base.startsWith('.') ? 'response$base' : base;
  final used = taken.toSet();
  final extension = p.extension(name);
  final stem = name.substring(0, name.length - extension.length);
  var candidate = name;
  for (var i = 2; used.contains(candidate); i++) {
    candidate = '$stem-$i$extension';
  }
  return candidate;
}

String mitmMapLocalLine(
  String url, {
  String? file,
  int status = 200,
  String contentType = '',
}) {
  final params = {
    'data-type': file == null ? 'text' : 'file',
    'data': file ?? '',
    if (status > 200 && status <= 999) 'status-code': '$status',
    if (contentType.isNotEmpty) 'header': 'Content-Type:$contentType',
  };
  return [
    _field(mitmUrlPattern(url)),
    for (final MapEntry(:key, :value) in params.entries)
      '$key=${_field(value)}',
  ].join(' ');
}

/// [text] with [line] at the end of its [section], added after the others
/// when missing; null for a Stash override, which has no sections.
String? mitmAddLine(String text, String section, String line) {
  if (_stashOverride(text) != null) {
    return null;
  }
  final lines = text.split('\n');
  bool isHeader(String line, [String? name]) {
    final title = _sectionPattern.firstMatch(line.trim())?.group(1);
    return title != null &&
        (name == null || title.trim().toLowerCase() == name.toLowerCase());
  }

  final header = lines.indexWhere((line) => isHeader(line, section));
  if (header < 0) {
    final head = text.trimRight();
    return '${head.isEmpty ? '' : '$head\n\n'}[$section]\n$line\n';
  }
  var end = header + 1;
  for (var i = end; i < lines.length && !isHeader(lines[i]); i++) {
    if (lines[i].trim().isNotEmpty) {
      end = i + 1;
    }
  }
  return (lines..insert(end, line)).join('\n');
}

/// The module URLs a web URL or another app's install link names.
List<String> mitmModuleUrls(String text) {
  final uri = Uri.tryParse(text.trim());
  if (uri == null) {
    return const [];
  }
  final action = '${uri.host}${uri.path}'.replaceAll('/', '');
  try {
    final urls = switch (uri.scheme) {
      'http' || 'https' when uri.host == 'link.stash.ws' => _stashLinkUrls(uri),
      'http' || 'https' => [text.trim()],
      'surge' when action == 'install-module' => [?uri.queryParameters['url']],
      'loon' when action == 'import' => [?uri.queryParameters['plugin']],
      'shadowrocket' when action == 'install' => [
        ?uri.queryParameters['module'],
      ],
      'stash' || 'clash' when action == 'install-override' => [
        ?uri.queryParameters['url'],
      ],
      'quantumult-x'
          when const {
            'add-resource',
            'update-configuration',
          }.contains(action) =>
        _quantumultXRewrites(uri.queryParameters['remote-resource']),
      _ => const <String>[],
    };
    return urls.where((url) => url.isUrl).toList();
  } on FormatException {
    return const [];
  }
}

/// Its URL has no scheme: https unless `?scheme=` names another.
List<String> _stashLinkUrls(Uri uri) {
  final segments = uri.pathSegments;
  if (segments.length < 2 || segments.first != 'install-override') {
    return const [];
  }
  final scheme = uri.queryParameters['scheme'] ?? 'https';
  return ['$scheme://${segments.skip(1).join('/')}'];
}

List<String> _quantumultXRewrites(String? resource) {
  final json = jsonDecode(resource ?? '');
  final rewrites = json is Map ? json['rewrite_remote'] : null;
  return [
    if (rewrites is List)
      for (final entry in rewrites.whereType<String>())
        entry.split(',').first.trim(),
  ];
}

MitmModuleContent parseMitmModule(
  String text, {
  Map<String, String> values = const {},
  Map<String, String> resources = const {},
  MitmRequirementEnvironment? environment,
}) {
  final parser = _ModuleParser(
    values: values,
    resources: resources,
    environment: environment ?? MitmRequirementEnvironment.current(),
  );
  final override = _stashOverride(text);
  return override == null
      ? parser.parse(text)
      : parser.parseStash(override, text);
}

/// Keys at the top of a Stash override that a Surge module or a Quantumult X
/// snippet read as YAML never has.
const _stashKeys = {
  'http',
  'script-providers',
  'cron',
  'rules',
  'tiles',
  'dns',
  'hosts',
};

const _stashScriptTypes = {
  'request': 'http-request',
  'response': 'http-response',
};

/// What a Stash override says about itself, which FlClash reads no further.
const _stashMetaKeys = {
  'name',
  'desc',
  'icon',
  'category',
  'author',
  'homepage',
  'openUrl',
  'manual',
  'date',
  'version',
  'arguments',
  'arguments-version',
  'script-providers',
};

Map<String, Object?>? _stashOverride(String text) {
  final lines = text.split(RegExp(r'\r\n|\r|\n'));
  if (lines.any((line) => _sectionPattern.hasMatch(line.trim()))) {
    return null;
  }
  final Object? document;
  try {
    document = loadPlainYaml(text);
  } on FormatException {
    return null;
  }
  if (document is Map<String, Object?> &&
      _stashKeys.any(document.containsKey)) {
    return document;
  }
  return null;
}

final _sectionPattern = RegExp(r'^\[([^\]]+)\]$');
final _conditionalPattern = RegExp(r'^(request|response)\s+if\s');
final _loonScriptCall = RegExp(r'\bthen\s+script\s*\(');

/// Loon's `cron|network-changed|generic then script(path[, argument])
/// [with options]`; a request or response one names a condition.
final _loonTriggeredScript = RegExp(
  r'^(?:cron\s+("[^"]*"|.+?)|(network-changed|generic))\s+then\s+script\(\s*'
  r'("[^"]*"|[^,\s)]+)\s*(?:,\s*(\{.*\}|"(?:[^"\\]|\\.)*"|[^)]*?))?\s*\)'
  r'\s*(?:with\s+(.*))?$',
);

/// A Loon cron expression an argument fills in, so without its quotes: every
/// word before the first `key=value`.
final _unquotedCron = RegExp(r'^[^"\s=]+(?:\s+[^"\s=]+)+(?=\s+[\w-]+\s*=)');

const _scriptTypes = {
  'http-request',
  'http-response',
  'cron',
  'event',
  'generic',
  'dns',
  'rule',
  'network-changed',
};

const _runnableScriptTypes = {
  'http-request',
  'http-response',
  'cron',
  'event',
  'generic',
};

/// The events FlClash reports, by Surge's names.
const _scriptEvents = {'network-changed', 'engine-started', 'profile-reloaded'};

/// Where each type keeps what a legacy line gives after the type.
const _scriptValueKeys = ['pattern', 'cronexp', 'event-name'];

const _qxFilterTypes = {
  'user-agent': 'USER-AGENT',
  'geoip': 'GEOIP',
  'ip-asn': 'IP-ASN',
  'host': 'DOMAIN',
  'host-suffix': 'DOMAIN-SUFFIX',
  'host-keyword': 'DOMAIN-KEYWORD',
  'host-wildcard': 'DOMAIN-WILDCARD',
  'ip-cidr': 'IP-CIDR',
  'ip6-cidr': 'IP-CIDR6',
};

final _qxFilterPattern = RegExp(
  r'^(host|host-suffix|host-keyword|host-wildcard|ip-cidr|ip6-cidr|user-agent|geoip|ip-asn|final)\s*,',
);
final _qxMitmPattern = RegExp(
  r'^(skip_dst_ip|skip_src_ip|skip_validating_cert|passphrase|p12)\s*=',
);
final _qxRewritePattern = RegExp(r'^\S+\s+url\s+\S|\surl-and-header\s');

/// The phase each of Quantumult X's script rewrites runs in, and whether it
/// waits for the body.
const _qxScripts = {
  'script-request-header': ('http-request', false),
  'script-request-body': ('http-request', true),
  'script-response-header': ('http-response', false),
  'script-response-body': ('http-response', true),
  'script-echo-response': ('http-request', false),
  'script-analyze-echo-response': ('http-request', true),
};

/// Quantumult X gives its tasks no timeout; Script-Hub converts them with this
/// one, which modules written for both platforms expect.
const _qxTaskTimeout = '120';

/// Loon's default for a script a request or response runs.
const _loonHttpScriptTimeout = '20';

/// Loon's default for a script no request triggers.
const _loonTriggeredTimeout = '300';

final _cronField = RegExp(r'^[\d*?/,\-A-Za-z#]+$');

/// A Quantumult X task line: a cron expression of five or six fields, then
/// the script.
({String expression, String rest})? _qxCron(String line) {
  final fields = line.split(RegExp(r'\s+'));
  for (final count in const [5, 6]) {
    if (fields.length > count &&
        fields.take(count).every(_cronField.hasMatch) &&
        (fields[count].contains('://') || fields[count].contains('.js'))) {
      final start = RegExp('^(?:\\S+\\s+){$count}').firstMatch(line)!.end;
      return (
        expression: fields.take(count).join(' '),
        rest: line.substring(start),
      );
    }
  }
  return null;
}

/// The lists under `http` FlClash reads; `rewrite` is the older name of
/// `url-rewrite`.
const _stashHttpLists = {
  'mitm',
  'url-rewrite',
  'rewrite',
  'header-rewrite',
  'body-rewrite',
  'mock',
  'script',
  'force-http-engine',
};

final _stashReference = RegExp(r'(\$?)\$\{args\.(\w+)(\|json)?\}');

/// What the Core reads of a script line; Loon's tag and enable, Surge's engine
/// and update interval, stay behind.
const _scriptKeys = [
  'requires-body',
  'binary-body-mode',
  'max-size',
  'timeout',
  'full-header-mode',
];
final _domainPattern = RegExp(r'^[^\s,()]+$');
final _portsPattern = RegExp(r'^\d{1,5}(-\d{1,5})?(/\d{1,5}(-\d{1,5})?)*$');

const _rejectActions = {
  'REJECT': 'reject',
  'REJECT-DROP': 'reject',
  'REJECT-NO-DROP': 'reject',
  'REJECT-TINYGIF': 'reject-img',
  'REJECT-IMG': 'reject-img',
  'REJECT-DICT': 'reject-dict',
  'REJECT-ARRAY': 'reject-array',
  'REJECT-200': 'reject-200',
  'REJECT-VIDEO': 'reject-200',
};

final _rejectRewrites = {..._rejectActions.values};

const _ruleTypes = {
  'DOMAIN': 'DOMAIN',
  'DOMAIN-SUFFIX': 'DOMAIN-SUFFIX',
  'DOMAIN-KEYWORD': 'DOMAIN-KEYWORD',
  'DOMAIN-WILDCARD': 'DOMAIN-WILDCARD',
  'IP-CIDR': 'IP-CIDR',
  'IP-CIDR6': 'IP-CIDR6',
  'SRC-IP': 'SRC-IP-CIDR',
  'SRC-IP-CIDR': 'SRC-IP-CIDR',
  'DEST-PORT': 'DST-PORT',
  'DST-PORT': 'DST-PORT',
  'SRC-PORT': 'SRC-PORT',
  'IN-PORT': 'IN-PORT',
  'PROCESS-NAME': 'PROCESS-NAME',
  'PROCESS-PATH': 'PROCESS-PATH',
  'GEOIP': 'GEOIP',
  'IP-ASN': 'IP-ASN',
  'GEOSITE': 'GEOSITE',
  'DOMAIN-REGEX': 'DOMAIN-REGEX',
  'NETWORK': 'NETWORK',
};

/// Options a rule may carry after its policy, which say nothing of what it
/// matches; Loon leaves the policy out for DIRECT.
const _ruleOptions = {'no-resolve', 'extended-matching', 'pre-matching'};

/// Rules on what only an Apple device knows of its network or itself.
const _deviceRules = {
  'CELLULAR-RADIO',
  'CELLULAR-CARRIER',
  'SUBNET',
  'DEVICE-NAME',
  'MAC-ADDRESS',
  'HOSTNAME-TYPE',
};

const _proxySections = {'proxy', 'proxy group', 'proxy-groups', 'proxies'};

/// Sections for features of the app the module was written for that FlClash
/// has nothing like.
final _appOnlySection = RegExp(
  r'^(panel|ponte|dhcp|ssid setting|mtproto|snell server|replica|tiles|'
  r'(wireguard|tailscale) .+)$',
);

/// Surge's internal rule sets as `rules/ruleset.md` lists them.
const _builtInRuleSets = {
  'LAN': [
    'DOMAIN-SUFFIX,local',
    'IP-CIDR,0.0.0.0/8',
    'IP-CIDR,10.0.0.0/8',
    'IP-CIDR,100.64.0.0/10',
    'IP-CIDR,127.0.0.0/8',
    'IP-CIDR,169.254.0.0/16',
    'IP-CIDR,172.16.0.0/12',
    'IP-CIDR,192.0.0.0/24',
    'IP-CIDR,192.0.2.0/24',
    'IP-CIDR,192.168.0.0/16',
    'IP-CIDR,224.0.0.0/4',
    'IP-CIDR6,::1/128',
    'IP-CIDR6,fc00::/7',
    'IP-CIDR6,fe80::/10',
  ],
  'SYSTEM': [
    'DOMAIN,api.smoot.apple.com',
    'DOMAIN,captive.apple.com',
    'DOMAIN,xp.apple.com',
    'DOMAIN,configuration.apple.com',
    'DOMAIN,guzzoni.apple.com',
    'DOMAIN,smp-device-content.apple.com',
    'DOMAIN,aod.itunes.apple.com',
    'DOMAIN,mesu.apple.com',
    'DOMAIN,api.smoot.apple.cn',
    'DOMAIN,gs-loc.apple.com',
    'DOMAIN,mvod.itunes.apple.com',
    'DOMAIN,streamingaudio.itunes.apple.com',
    'DOMAIN-SUFFIX,ess.apple.com',
    'DOMAIN-SUFFIX,push-apple.com.akadns.net',
    'DOMAIN-SUFFIX,push.apple.com',
    'DOMAIN-SUFFIX,lcdn-locator.apple.com',
    'DOMAIN-SUFFIX,lcdn-registration.apple.com',
    'DOMAIN-SUFFIX,ls.apple.com',
    'PROCESS-NAME,trustd',
    'PROCESS-NAME,netbiosd',
  ],
};

/// Surge re-downloads a rule set daily unless the line says otherwise.
const _ruleSetInterval = 86400;

String _inlineSetName(String name) => _ruleSetName('ruleset:$name');

/// A list a module writes without a mark takes its format's default.
enum _ListMark { plain, replace, insert, append }

const _plainDnsKey = 'dns-server';
const _encryptedDnsKey = 'encrypted-dns-server';

const _loonSections = {'rewrite', 'argument', 'remote rule', 'plugin'};
const _loonGeneralKeys = {
  'doh-server',
  'doh3-server',
  'doq-server',
  'bypass-tun',
  'include-tun',
  'real-ip',
};

final _hostPattern = RegExp(r'^[A-Za-z0-9*+._-]+$');

String? _builtInTarget(String policy) => switch (policy.toUpperCase()) {
  'DIRECT' => 'DIRECT',
  'REJECT-DROP' => 'REJECT-DROP',
  final upper when _rejectActions.containsKey(upper) => 'REJECT',
  _ => null,
};

List<String> mitmRulesWithExits(
  List<String> rules,
  Set<String> exits,
  String Function(String exit) target,
) => [
  for (final rule in rules)
    if (rule.split(',') case final parts
        when exits.contains(parts[_targetIndex(parts)]))
      (parts..[_targetIndex(parts)] = target(parts[_targetIndex(parts)])).join(
        ',',
      )
    else
      rule,
];

int _targetIndex(List<String> parts) =>
    parts.last == 'no-resolve' ? parts.length - 2 : parts.length - 1;

String _ruleSetName(String key) =>
    'mitm-${sha1.convert(utf8.encode(key)).toString().substring(0, 12)}';

final _portComparison = RegExp(r'^(>=|=>|<=|=<|>|<)\s*(\d{1,5})$');

/// `>=443` and the like as the range of ports they cover.
String? _portRange(String value) {
  final match = _portComparison.firstMatch(value.trim());
  final port = int.tryParse(match?.group(2) ?? '');
  if (match == null || port == null || port > 65535) {
    return null;
  }
  final (low, high) = switch (match.group(1)!) {
    '>=' || '=>' => (port, 65535),
    '>' => (port + 1, 65535),
    '<=' || '=<' => (0, port),
    _ => (0, port - 1),
  };
  return low > high ? null : '$low-$high';
}

final _leadingRequirement = RegExp(r'^#!REQUIREMENT\s+("[^"]*"|\S+)\s+(.*)$');
final _trailingRequirement = RegExp(
  r'\s+(?:#|//)!(?:REQUIREMENT\s+("[^"]*"|\S+)|(IOS|MACOS|TVOS)-ONLY)\s*$',
);

/// A line with its Surge line requirement taken off, and the requirement.
({String line, String? requirement}) _lineRequirement(String line) {
  if (_leadingRequirement.firstMatch(line) case final match?) {
    return (
      line: match.group(2)!.trim(),
      requirement: _unquote(match.group(1)!),
    );
  }
  if (_trailingRequirement.firstMatch(line) case final match?) {
    final system = switch (match.group(2)) {
      'IOS' => 'iOS',
      'MACOS' => 'macOS',
      'TVOS' => 'tvOS',
      _ => null,
    };
    return (
      line: line.substring(0, match.start).trim(),
      requirement: system == null
          ? _unquote(match.group(1)!)
          : "SYSTEM=='$system'",
    );
  }
  return (line: line, requirement: null);
}

/// Surge's USER-AGENT wildcard, `*` and `?` within the header's value, as a
/// pattern over the request head the Core matches `url-and-header` against.
String _userAgentHead(String wildcard) {
  final value = wildcard
      .replaceAllMapped(RegExp(r'[.+^${}()|[\]\\]'), (match) => '\\${match[0]}')
      .replaceAll('*', r'[^\r\n]*')
      .replaceAll('?', r'[^\r\n]');
  return '\\r\\nUser-Agent: $value\\r\\n';
}

bool _isComment(String line) =>
    line.startsWith('#') || line.startsWith(';') || line.startsWith('//');

String _unquote(String text) {
  if (text.length >= 2 &&
      (text.startsWith('"') && text.endsWith('"') ||
          text.startsWith("'") && text.endsWith("'"))) {
    return text.substring(1, text.length - 1);
  }
  return text;
}

String _field(String text) {
  if (text.isNotEmpty && !RegExp(r'[\s"]').hasMatch(text)) {
    return text;
  }
  return _quoted(text);
}

String _quoted(String text) => '"${text.replaceAll('"', r'\"')}"';

class _Token {
  const _Token(this.text, this.end);

  final String text;
  final int end;
}

/// Splits on spaces, keeping a double-quoted run, or a single-quoted one that
/// opens a value as in data='{}', in one token without its quotes.
List<_Token>? _tokens(String line) {
  final tokens = <_Token>[];
  var i = 0;
  while (i < line.length) {
    if (line[i] == ' ' || line[i] == '\t') {
      i++;
      continue;
    }
    final start = i;
    final text = StringBuffer();
    String? quote;
    for (; i < line.length; i++) {
      final c = line[i];
      if (quote != null) {
        if (quote == '"' &&
            c == r'\' &&
            i + 1 < line.length &&
            line[i + 1] == '"') {
          text.write('"');
          i++;
        } else if (c == quote) {
          quote = null;
        } else {
          text.write(c);
        }
        continue;
      }
      if (c == ' ' || c == '\t') {
        break;
      }
      if (c == '"' || (c == "'" && (i == start || line[i - 1] == '='))) {
        quote = c;
      } else {
        text.write(c);
      }
    }
    if (quote != null) {
      return null;
    }
    tokens.add(_Token(text.toString(), i));
  }
  return tokens;
}

/// Splits on commas outside double quotes, and with [nested] outside
/// parentheses, which only a logical rule can count on to be balanced.
List<String> _splitRule(String text, {bool nested = false}) {
  final parts = <String>[];
  var depth = 0;
  var quoted = false;
  var start = 0;
  for (var i = 0; i < text.length; i++) {
    switch (text[i]) {
      case '"':
        quoted = !quoted;
      case '(' when nested && !quoted:
        depth++;
      case ')' when nested && !quoted:
        depth--;
      case ',' when !quoted && depth == 0:
        parts.add(text.substring(start, i).trim());
        start = i + 1;
    }
  }
  parts.add(text.substring(start).trim());
  return parts;
}

const _logicalRules = {'AND', 'OR', 'NOT'};

List<String> _ruleParts(String text) {
  final comma = text.indexOf(',');
  final type = (comma < 0 ? text : text.substring(0, comma)).trim();
  return _splitRule(text, nested: _logicalRules.contains(type.toUpperCase()));
}

List<String> _splitArguments(String text) {
  final parts = <String>[];
  var quoted = false;
  var start = 0;
  for (var i = 0; i < text.length; i++) {
    if (text[i] == '"') {
      quoted = !quoted;
    } else if (text[i] == ',' && !quoted) {
      parts.add(text.substring(start, i).trim());
      start = i + 1;
    }
  }
  parts.add(text.substring(start).trim());
  return parts.where((part) => part.isNotEmpty).toList();
}

/// Splits `key=value,...` as the Core does: on the commas outside quotes,
/// groups and character classes, `\"` being the one escape inside quotes.
Map<String, String>? _scriptParams(String text) {
  final params = <String, String>{};
  void add(String item) {
    final equals = item.indexOf('=');
    if (equals > 0) {
      var value = item.substring(equals + 1).trim();
      if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1).replaceAll(r'\"', '"');
      }
      params[item.substring(0, equals).trim().toLowerCase()] = value;
    }
  }

  var quoted = false;
  var characterClass = false;
  var depth = 0;
  var start = 0;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == r'\' && i + 1 < text.length && text[i + 1] == '"') {
        i++;
      } else if (c == '"') {
        quoted = false;
      }
    } else if (c == r'\') {
      i++;
    } else if (c == '"') {
      quoted = true;
    } else if (characterClass) {
      characterClass = c != ']';
    } else if (c == '[') {
      characterClass = true;
    } else if (c == '(' || c == '{') {
      depth++;
    } else if ((c == ')' || c == '}') && depth > 0) {
      depth--;
    } else if (c == ',' && depth == 0) {
      add(text.substring(start, i));
      start = i + 1;
    }
  }
  if (quoted) {
    return null;
  }
  add(text.substring(start));
  return params;
}

/// A line with a type parameter is Surge's form, so a name may start with a
/// type; the Core reads it the same way, and files a legacy line's value
/// where Surge's form keeps it.
({String name, String type, Map<String, String> params})? _scriptLine(
  String line,
) {
  final equals = line.indexOf('=');
  final params = equals <= 0 ? null : _scriptParams(line.substring(equals + 1));
  final space = line.indexOf(RegExp(r'\s'));
  final keyword = space < 0 ? '' : line.substring(0, space).toLowerCase();
  if (params?['type'] == null && _scriptTypes.contains(keyword)) {
    final rest = line.substring(space).trim();
    final cron = keyword == 'cron' ? _unquotedCron.firstMatch(rest) : null;
    final first = cron != null
        ? _Token(cron.group(0)!, cron.end)
        : _tokens(rest)?.firstOrNull;
    final http = keyword.startsWith('http-');
    final valued = first != null && (http || !first.text.contains('='));
    final legacy = _scriptParams(valued ? rest.substring(first.end) : rest);
    if (legacy == null || http && !valued) {
      return null;
    }
    final value = valued ? first.text : '';
    var type = keyword;
    var name = legacy['tag'] ?? '';
    switch (keyword) {
      case 'http-request' || 'http-response':
        legacy['pattern'] = value;
      case 'cron':
        legacy['cronexp'] = value;
      case 'event':
        legacy['event-name'] = value;
      case 'network-changed':
        type = 'event';
        legacy['event-name'] = 'network-changed';
      default:
        name = name.isEmpty ? value : name;
    }
    return (name: name, type: type, params: legacy);
  }
  if (params == null) {
    return null;
  }
  return (
    name: line.substring(0, equals).trim(),
    type: (params['type'] ?? 'generic').toLowerCase(),
    params: params,
  );
}

/// The name the Core runs a cron, event or generic script line by, for the
/// user to run it now; null for any other line.
String? mitmTaskName(String line) {
  final parsed = _scriptLine(line.trim());
  if (parsed == null ||
      !const {'cron', 'event', 'generic'}.contains(parsed.type)) {
    return null;
  }
  final name = parsed.name.isNotEmpty
      ? parsed.name
      : p.url.basename(parsed.params['script-path'] ?? '');
  return name.isEmpty ? null : name;
}

String _scriptValue(String value) =>
    RegExp(r'[\s,"=\[\](){}]').hasMatch(value) ? _quoted(value) : value;

String? _cidr(String text) {
  if (text.contains('%')) {
    return null;
  }
  final slash = text.indexOf('/');
  final address = InternetAddress.tryParse(
    slash < 0 ? text : text.substring(0, slash),
  );
  if (address == null) {
    return null;
  }
  final max = address.type == InternetAddressType.IPv6 ? 128 : 32;
  final prefix = slash < 0 ? max : int.tryParse(text.substring(slash + 1));
  if (prefix == null || prefix < 0 || prefix > max) {
    return null;
  }
  return '${address.address}/$prefix';
}

bool _validPorts(String text) {
  if (!_portsPattern.hasMatch(text)) {
    return false;
  }
  return text.split(RegExp('[/-]')).every((port) => int.parse(port) <= 65535);
}

class _ModuleParser {
  _ModuleParser({
    required this.values,
    required this.resources,
    required this.environment,
  });

  final Map<String, String> values;
  final Map<String, String> resources;
  final MitmRequirementEnvironment environment;

  final _meta = <String, String>{};
  final _surgeArguments = <MitmModuleArgument>[];
  final _loonArguments = <MitmModuleArgument>[];
  final _stashArguments = <MitmModuleArgument>[];
  final _insertedHostname = <String>[];
  final _hostname = <String>[];
  final _urlRewrite = <String>[];
  final _headerRewrite = <String>[];
  final _bodyRewrite = <String>[];
  final _mapLocal = <String>[];
  final _requestBodyMock = <String>[];
  final _clientSourceAddress = <String>[];
  (String, String)? _skipVerify;
  final _script = <String>[];
  final _declaredScriptLines = <String>[];
  final _rules = <String>[];
  final _resourceUrls = <String>{};
  final _inlineResources = <String, String>{};
  final _skipped = <MitmModuleSkip>[];
  var _requestRules = 0;
  var _h2 = false;
  final _ruleProviders = <String, Map<String, Object?>>{};
  final _rulesetNames = <String>{};
  final _rulesets = <String, List<String>>{};
  final _stashProviderNames = <String, String>{};
  final _exits = <String>{};
  final _sections = <String>{};
  final _generalKeys = <String>{};
  final _listEdits = <String, List<(_ListMark, List<String>)>>{};
  final _nameserverPolicy = <String, List<String>>{};
  final _hosts = <String, List<String>>{};
  final _routeAddress = <String>[];

  MitmModuleContent parse(String text) {
    final lines = text.split(RegExp(r'\r\n|\r|\n'));
    _readDeclarations(lines);
    String? section;
    for (final raw in lines) {
      final trimmed = raw.trim();
      final header = _sectionPattern.firstMatch(trimmed);
      if (header != null) {
        section = header.group(1)!.trim();
        continue;
      }
      final (line: unconditional, :requirement) = _lineRequirement(trimmed);
      if (unconditional.isEmpty || _isComment(unconditional)) {
        continue;
      }
      if (requirement != null &&
          evaluateMitmRequirement(requirement, environment) != true) {
        _skip(section ?? '', trimmed, MitmModuleSkipReason.requirement);
        continue;
      }
      if (section == null) {
        _readQuantumultX(unconditional);
        continue;
      }
      if (section.toLowerCase() == 'script') {
        if (unconditional.contains('{') ||
            _loonScriptCall.hasMatch(unconditional)) {
          _declaredScriptLines.add(unconditional);
        } else {
          _declareScript(_scriptLine(unconditional)?.type, unconditional);
        }
      }
      final line = _substitute(unconditional).trim();
      if (line.isEmpty || _isComment(line)) {
        continue;
      }
      _readLine(section, line, unconditional);
    }
    return _content();
  }

  MitmModuleContent _content() {
    String? meta(String key) {
      final value = _meta[key]?.replaceAll(r'\n', '\n').trim();
      return value == null || value.isEmpty ? null : value;
    }

    final requirement = meta('requirement');
    final skipVerifyHostname = _skipVerifyHostname();
    return MitmModuleContent(
      requirement: requirement,
      requirementMet: requirement == null
          ? null
          : evaluateMitmRequirement(requirement, environment),
      h2: _h2,
      name: meta('name'),
      description: meta('desc'),
      system: meta('system'),
      argumentsDescription: meta('arguments-desc'),
      arguments: [..._surgeArguments, ..._loonArguments, ..._stashArguments],
      insertedHostname: _insertedHostname,
      hostname: _hostname,
      urlRewrite: _urlRewrite,
      headerRewrite: _headerRewrite,
      bodyRewrite: _bodyRewrite,
      mapLocal: _mapLocal,
      requestBodyMock: _requestBodyMock,
      clientSourceAddress: _clientSourceAddress,
      skipVerifyHostname: skipVerifyHostname,
      script: _script,
      declaredScriptLines: _declaredScriptLines,
      rules: _rules,
      exits: _exits,
      network: _network(),
      ruleProviders: {
        ..._ruleProviders,
        for (final MapEntry(:key, :value) in _rulesets.entries)
          _inlineSetName(key): {
            'type': 'inline',
            'behavior': 'classical',
            'payload': value,
          },
      },
      resourceUrls: _resourceUrls,
      inlineResources: _inlineResources,
      skipped: _skipped,
      requestRules: _requestRules,
    );
  }

  /// The module's own hostnames it may skip verifying, never one that covers
  /// every host: a module cannot turn verifying off for all servers.
  List<String> _skipVerifyHostname() {
    final (section, line) = _skipVerify ?? (null, null);
    if (section == null || line == null) {
      return const [];
    }
    final hosts = <String>[];
    var coversAll = false;
    for (final entry in [..._insertedHostname, ..._hostname]) {
      if (entry.startsWith('-')) {
        continue;
      }
      if (RegExp(r'^\*+(:[\d*]+)?$').hasMatch(entry)) {
        coversAll = true;
      } else {
        hosts.add(entry);
      }
    }
    if (coversAll) {
      _skip(section, line, MitmModuleSkipReason.skipVerifyAll);
    }
    return hosts;
  }

  void _readDeclarations(List<String> lines) {
    String? section;
    for (final raw in lines) {
      final line = raw.trim();
      final header = _sectionPattern.firstMatch(line);
      if (header != null) {
        final name = header.group(1)!.trim();
        section = name.toLowerCase();
        if (section.startsWith('ruleset ')) {
          _rulesetNames.add(name.substring('ruleset '.length).trim());
        }
        continue;
      }
      if (line.startsWith('#!')) {
        _readMeta(line.substring(2));
      } else if (section == 'argument' &&
          line.isNotEmpty &&
          !_isComment(line)) {
        final argument = _loonArgument(line);
        if (argument != null) {
          _loonArguments.add(argument);
        }
      }
    }
    for (final item in _splitArguments(_meta['arguments'] ?? '')) {
      final colon = item.indexOf(':');
      final name = (colon < 0 ? item : item.substring(0, colon)).trim();
      if (name.isEmpty) {
        continue;
      }
      final defaultValue = colon < 0
          ? ''
          : _unquote(item.substring(colon + 1).trim());
      _surgeArguments.add(
        MitmModuleArgument(
          name: name,
          defaultValue: defaultValue,
          type: defaultValue == 'true' || defaultValue == 'false'
              ? MitmModuleArgumentType.toggle
              : MitmModuleArgumentType.input,
        ),
      );
    }
  }

  void _readMeta(String entry) {
    final equals = entry.indexOf('=');
    if (equals <= 0) {
      return;
    }
    final key = entry.substring(0, equals).trim().toLowerCase();
    final value = entry.substring(equals + 1).trim();
    switch (key) {
      case 'input':
        _loonArguments.add(MitmModuleArgument(name: value, defaultValue: ''));
      case 'select':
        final options = _splitArguments(value).map(_unquote).toList();
        if (options.length > 1) {
          _loonArguments.add(
            MitmModuleArgument(
              name: options.first,
              defaultValue: options[1],
              type: MitmModuleArgumentType.select,
              options: options.sublist(1),
            ),
          );
        }
      default:
        _meta.putIfAbsent(key, () => value);
    }
  }

  /// Reads Loon's `name = input|select|switch,values...,tag=...,desc=...`.
  MitmModuleArgument? _loonArgument(String line) {
    final equals = line.indexOf('=');
    if (equals <= 0) {
      return null;
    }
    final name = line.substring(0, equals).trim();
    final parts = _splitArguments(line.substring(equals + 1));
    if (name.isEmpty || parts.isEmpty) {
      return null;
    }
    final kind = parts.first.toLowerCase();
    final options = <String>[];
    String? label;
    String? description;
    var number = false;
    for (final part in parts.skip(1)) {
      final match = RegExp(r'^(tag|desc|type)\s*=\s*(.*)$').firstMatch(part);
      switch (match?.group(1)) {
        case 'tag':
          label = _unquote(match!.group(2)!.trim());
        case 'desc':
          description = _unquote(match!.group(2)!.trim());
        case 'type':
          number = match!.group(2)!.trim().toLowerCase() == 'number';
        default:
          options.add(_unquote(part));
      }
    }
    final type = switch (kind) {
      'select' => MitmModuleArgumentType.select,
      'switch' => MitmModuleArgumentType.toggle,
      _ => MitmModuleArgumentType.input,
    };
    final defaultValue = switch (type) {
      MitmModuleArgumentType.toggle => options.firstWhere(
        (option) => option == 'true' || option == 'false',
        orElse: () => 'false',
      ),
      _ => options.firstOrNull ?? '',
    };
    return MitmModuleArgument(
      name: name,
      defaultValue: defaultValue,
      type: type,
      options: type == MitmModuleArgumentType.select ? options : const [],
      label: label == null || label.isEmpty ? null : label,
      description: description == null || description.isEmpty
          ? null
          : description,
      number: number,
    );
  }

  String _valueOf(MitmModuleArgument argument) =>
      values[argument.name] ?? argument.defaultValue;

  String _substitute(String line) {
    if (!line.contains('{')) {
      return line;
    }
    for (final argument in _surgeArguments) {
      line = line.replaceAll('{{{${argument.name}}}}', _valueOf(argument));
    }
    for (final argument in _loonArguments) {
      final value = _valueOf(argument);
      line = line
          .replaceAll('\${${argument.name}}', value)
          .replaceAll('{${argument.name}}', value);
    }
    return line;
  }

  void _skip(String section, String line, MitmModuleSkipReason reason) {
    _skipped.add(MitmModuleSkip(section, line, reason));
  }

  void _readLine(String section, String line, String raw) {
    _sections.add(section.toLowerCase());
    switch (section.toLowerCase()) {
      case 'general':
        _readGeneral(section, line);
      case 'host':
        _readHost(section, line);
      case 'argument':
        break;
      case 'rule':
        _readRule(section, line);
      case 'url rewrite':
        _urlRewrite.add(line);
      case 'header rewrite':
        _headerRewrite.add(line);
      case 'body rewrite':
        _bodyRewrite.add(line);
      case 'map local':
        _readMapLocal(section, line);
      case 'rewrite':
        _readLoonRewrite(section, line);
      case 'mitm':
        _readMitm(section, line);
      case 'script':
        _readScript(section, line, raw);
      case 'rewrite_local' || 'filter_local' || 'task_local':
        if (!_readQuantumultX(line)) {
          _skip(section, line, MitmModuleSkipReason.unreadable);
        }
      case 'ip rewrite':
        _readIpRewrite(section, line);
      case 'remote rule':
        _readLoonRemoteRule(section, line);
      case final name when name.startsWith('ruleset '):
        if (RegExp(
          r'^(RULE|DOMAIN)-SET\s*,',
          caseSensitive: false,
        ).hasMatch(line)) {
          _skip(section, line, MitmModuleSkipReason.rule);
        } else {
          _rulesets
              .putIfAbsent(
                section.substring('ruleset '.length).trim(),
                () => [],
              )
              .add(line);
        }
      case final name when _proxySections.contains(name):
        _skip(section, line, MitmModuleSkipReason.proxies);
      case final name when _appOnlySection.hasMatch(name):
        _skip(section, line, MitmModuleSkipReason.appOnly);
      default:
        _skip(section, line, MitmModuleSkipReason.section);
    }
  }

  /// Reads Surge's `name = type=...,...` and the legacy `type pattern ...`
  /// Loon writes, into the form the Core's script list takes.
  void _readScript(String section, String line, String raw) {
    if (_loonTriggeredScript.firstMatch(line) case final match?) {
      _readLoonTriggeredScript(section, line, match, raw);
      return;
    }
    if (_conditionalPattern.hasMatch(line)) {
      _readLoonConditional(section, line);
      return;
    }
    if (_loonScriptCall.hasMatch(line)) {
      _skip(section, line, MitmModuleSkipReason.conditional);
      return;
    }
    final parsed = _scriptLine(line);
    if (parsed == null) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    final (:name, :type, :params) = parsed;
    if (!_runnableScriptTypes.contains(type)) {
      _skip(section, line, MitmModuleSkipReason.scriptType);
      return;
    }
    if (type == 'event' && !_scriptEvents.contains(params['event-name'])) {
      _skip(section, line, MitmModuleSkipReason.event);
      return;
    }
    if (params['enable']?.toLowerCase() == 'false') {
      _skip(section, line, MitmModuleSkipReason.disabled);
      return;
    }
    final after = {for (final key in _scriptKeys) key: ?params[key]};
    final object = _objectArgument(_scriptLine(raw)?.params['argument']);
    if (object != null) {
      after['argument-json'] = jsonEncode(object);
    } else if (params['argument'] case final argument?) {
      after['argument'] = argument;
    }
    _addScript(section, line, name, params['script-path'] ?? '', {
      'type': type,
      for (final key in _scriptValueKeys) key: ?params[key],
    }, after);
  }

  void _readLoonTriggeredScript(
    String section,
    String line,
    RegExpMatch match,
    String raw,
  ) {
    final options = <String, String>{};
    for (final option in _splitArguments(match.group(5) ?? '')) {
      final equals = option.indexOf('=');
      if (equals <= 0) {
        _skip(section, line, MitmModuleSkipReason.unreadable);
        return;
      }
      options[option.substring(0, equals).trim()] = _unquote(
        option.substring(equals + 1).trim(),
      );
    }
    if (options['enable']?.toLowerCase() == 'false') {
      _skip(section, line, MitmModuleSkipReason.disabled);
      return;
    }
    final argument = match.group(4)?.trim();
    final names = RegExp(
      r'^\{(.*)\}$',
    ).firstMatch(_loonTriggeredScript.firstMatch(raw)?.group(4)?.trim() ?? '');
    final object = names == null
        ? null
        : _objectArgument(
            '[${names.group(1)!.split(',').map((name) => name.trim().replaceAll(r'$', '')).join(',')}]',
          );
    _addScript(
      section,
      line,
      options['tag'] ?? '',
      _unquote(match.group(3)!),
      {
        if (match.group(1) case final cron?) ...{
          'type': 'cron',
          'cronexp': _unquote(cron),
        } else if (match.group(2) == 'generic')
          'type': 'generic'
        else ...{
          'type': 'event',
          'event-name': 'network-changed',
        },
      },
      {
        'timeout': options['timeout'] ?? _loonTriggeredTimeout,
        if (object != null)
          'argument-json': jsonEncode(object)
        else if (argument != null && argument.isNotEmpty)
          'argument': _unquote(argument),
      },
    );
  }

  void _declareScript(String? type, String line) {
    if (_runnableScriptTypes.contains(type) || (type?.contains('{') ?? false)) {
      _declaredScriptLines.add(line);
    }
  }

  /// A script or file the module carries in its own text, under a key that
  /// changes with it.
  String _inline(String text) {
    final key =
        '$_inlineResource${sha256.convert(utf8.encode(text)).toString().substring(0, 16)}.js';
    _inlineResources[key] = text;
    return key;
  }

  /// The resources directory's file for [url], or null once the line is
  /// skipped for a file the module does not download or FlClash has not.
  String? _resource(String section, String line, String url) {
    if (url.startsWith(_inlineResource)) {
      final file = resources[url];
      if (file == null) {
        _skip(section, line, MitmModuleSkipReason.notDownloaded);
      }
      return file;
    }
    if (!isMitmResourceUrl(url)) {
      final attachment = resources[url];
      if (attachment == null) {
        _skip(section, line, MitmModuleSkipReason.relativeData);
      }
      return attachment;
    }
    _resourceUrls.add(url);
    final file = resources[url];
    if (file == null) {
      _skip(section, line, MitmModuleSkipReason.notDownloaded);
    }
    return file;
  }

  /// Writes a script line in the form the Core's list takes, its downloaded
  /// file between [fields] and [after].
  void _addScript(
    String section,
    String line,
    String name,
    String path,
    Map<String, String> fields, [
    Map<String, String> after = const {},
  ]) {
    final file = _resource(section, line, path);
    if (file == null) {
      return;
    }
    final title = name.replaceAll(RegExp('[=,]'), ' ').trim();
    _script.add(
      [
        '${title.isEmpty ? p.url.basename(Uri.parse(path).path) : title} =',
        [
          for (final MapEntry(:key, :value) in {
            ...fields,
            'script-path': file,
            ...after,
          }.entries)
            '$key=${_scriptValue(value)}',
        ].join(','),
      ].join(' '),
    );
  }

  /// Loon's `argument=[{a},{b}]`, which hands the script an object of the
  /// arguments it names, each keeping its type.
  Map<String, Object?>? _objectArgument(String? text) {
    final match = RegExp(r'^\[(.*)\]$').firstMatch(text?.trim() ?? '');
    if (match == null) {
      return null;
    }
    final object = <String, Object?>{};
    for (final item in match.group(1)!.split(',')) {
      final name = RegExp(r'^\{([^{}]+)\}$').firstMatch(item.trim())?.group(1);
      if (name == null) {
        return null;
      }
      final argument = _loonArguments.firstWhereOrNull(
        (argument) => argument.name == name,
      );
      final value = argument == null ? null : _valueOf(argument);
      object[name] = switch (argument) {
        null => null,
        MitmModuleArgument(type: MitmModuleArgumentType.toggle) =>
          value == 'true',
        MitmModuleArgument(number: true) => num.tryParse(value!) ?? value,
        _ => value,
      };
    }
    return object.isEmpty ? null : object;
  }

  void _readMitm(String section, String line) {
    final equals = line.indexOf('=');
    final key = equals < 0
        ? ''
        : line.substring(0, equals).trim().toLowerCase();
    switch (key) {
      case 'hostname':
        break;
      case 'h2':
        _h2 = _h2 || line.substring(equals + 1).trim().toLowerCase() == 'true';
        return;
      case 'skip-server-cert-verify':
        if (line.substring(equals + 1).trim().toLowerCase() == 'true') {
          _skipVerify = (section, line);
        }
        return;
      case 'client-source-address':
        final value = line
            .substring(equals + 1)
            .trim()
            .replaceFirst(RegExp('^%(APPEND|INSERT)%'), '')
            .trim();
        if (value.isNotEmpty) {
          _clientSourceAddress.add(value);
        }
        return;
      case 'ca-p12' || 'ca-passphrase' || 'keystore':
        _skip(section, line, MitmModuleSkipReason.managedCa);
        return;
      case _ when _qxMitmPattern.hasMatch('$key='):
        _readQxMitm(line);
        return;
      default:
        _skip(section, line, MitmModuleSkipReason.setting);
        return;
    }
    var value = line.substring(equals + 1).trim();
    var target = _hostname;
    if (value.startsWith('%INSERT%')) {
      target = _insertedHostname;
      value = value.substring('%INSERT%'.length);
    } else if (value.startsWith('%APPEND%')) {
      value = value.substring('%APPEND%'.length);
    }
    target.addAll(
      value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }

  /// A Loon plugin adds to the profile's lists, as its manual says; a Surge
  /// module replaces them unless marked. Surge reads its plain servers only
  /// for the encrypted ones' domains once any encrypted one is set, which is
  /// mihomo's default-nameserver.
  MitmNetwork _network() {
    final loon =
        _sections.any(_loonSections.contains) ||
        _generalKeys.any(_loonGeneralKeys.contains);
    MitmListEdit? edit(String key) {
      MitmListEdit? merged;
      for (final (mark, values)
          in _listEdits[key] ?? const <(_ListMark, List<String>)>[]) {
        final next = switch (mark) {
          _ListMark.insert => MitmListEdit(before: values),
          _ListMark.append => MitmListEdit(after: values),
          _ListMark.plain when loon => MitmListEdit(after: values),
          _ListMark.plain ||
          _ListMark.replace => MitmListEdit(replace: true, before: values),
        };
        merged = merged?.then(next) ?? next;
      }
      return merged;
    }

    final plain = edit(_plainDnsKey);
    final encrypted = edit(_encryptedDnsKey);
    final bootstrap = plain == null || encrypted == null || loon
        ? null
        : MitmListEdit(
            replace: plain.replace,
            before: plain.before.where(isMitmPlainDnsServer).toList(),
            after: plain.after.where(isMitmPlainDnsServer).toList(),
          );
    return MitmNetwork(
      nameserver: encrypted == null
          ? plain
          : loon && plain != null
          ? plain.then(encrypted)
          : encrypted,
      defaultNameserver:
          edit(MitmNetworkKey.defaultNameserver.path) ?? bootstrap,
      fakeIpFilter: edit(MitmNetworkKey.fakeIpFilter.path),
      nameserverPolicy: _nameserverPolicy,
      hosts: _hosts,
      routeAddress: _routeAddress,
      routeExcludeAddress: edit(MitmNetworkKey.routeExcludeAddress.path),
      bypassDomain: edit(MitmNetworkKey.bypassDomain.path),
    );
  }

  void _editList(String key, _ListMark mark, List<String> values) {
    _listEdits.putIfAbsent(key, () => []).add((mark, values));
  }

  /// The `[General]` keys a Surge module or a Loon plugin may set.
  void _readGeneral(String section, String line) {
    final equals = line.indexOf('=');
    if (equals < 0) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    final key = line.substring(0, equals).trim().toLowerCase();
    var value = line.substring(equals + 1).trim();
    var mark = _ListMark.plain;
    for (final (prefix, marked) in const [
      ('%INSERT%', _ListMark.insert),
      ('%APPEND%', _ListMark.append),
    ]) {
      if (value.startsWith(prefix)) {
        value = value.substring(prefix.length);
        mark = marked;
      }
    }
    _generalKeys.add(key);
    final items = [
      for (final item in value.split(','))
        if (item.trim().isNotEmpty) item.trim(),
    ];
    List<String>? read(String? Function(String) parse) {
      final parsed = items.map(parse).toList();
      if (parsed.contains(null)) {
        _skip(section, line, MitmModuleSkipReason.unreadable);
        return null;
      }
      return parsed.nonNulls.toList();
    }

    switch (key) {
      case 'dns-server':
        if (read(mitmDnsServer) case final servers?) {
          _editList(_plainDnsKey, mark, servers);
        }
      case 'encrypted-dns-server' ||
          'doh-server' ||
          'doh3-server' ||
          'doq-server':
        if (read(mitmDnsServer) case final servers?) {
          _editList(_encryptedDnsKey, mark, servers);
        }
      case 'skip-proxy':
        _editList(MitmNetworkKey.bypassDomain.path, mark, items);
      case 'tun-excluded-routes' || 'bypass-tun':
        if (read(mitmRoute) case final routes?) {
          _editList(MitmNetworkKey.routeExcludeAddress.path, mark, routes);
        }
      case 'tun-included-routes' || 'include-tun':
        if (read(mitmRoute) case final routes?) {
          _routeAddress.addAll(routes);
        }
      case 'always-real-ip' || 'real-ip':
        _editList(MitmNetworkKey.fakeIpFilter.path, mark, items);
      case 'force-http-engine-hosts':
        _hostname.addAll(items);
      default:
        _skip(section, line, MitmModuleSkipReason.setting);
    }
  }

  /// `domain = address[, address]`, `domain = alias` or
  /// `domain = server:dns-server`, as Surge and Loon write `[Host]`.
  void _readHost(String section, String line) {
    final equals = line.indexOf('=');
    final host = equals < 0 ? '' : line.substring(0, equals).trim();
    final value = equals < 0 ? '' : line.substring(equals + 1).trim();
    if (!_hostPattern.hasMatch(host) || value.isEmpty) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    if (value.toLowerCase().startsWith('server:')) {
      final server = mitmDnsServer(value.substring('server:'.length));
      if (server == null) {
        _skip(section, line, MitmModuleSkipReason.unreadable);
        return;
      }
      _nameserverPolicy[host] = [server];
      return;
    }
    final targets = [
      for (final item in value.split(','))
        if (item.trim().isNotEmpty) item.trim(),
    ];
    if (!targets.every(
      (target) =>
          InternetAddress.tryParse(target) != null ||
          _hostPattern.hasMatch(target),
    )) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    _hosts[host] = targets;
  }

  /// Stash puts an override's list ahead of the profile's unless the key is
  /// marked `#!append` or `#!replace`, in a comment the YAML no longer holds.
  void _readStashDns(Map<String, Object?> dns, String text) {
    _ListMark markOf(String key) => switch (RegExp(
      '^\\s+$key:\\s*#!(replace|append)',
      multiLine: true,
    ).firstMatch(text)?.group(1)) {
      'replace' => _ListMark.replace,
      'append' => _ListMark.append,
      _ => _ListMark.insert,
    };
    List<String> strings(Object? value) => switch (value) {
      final List list => [for (final item in list) '$item'.trim()],
      null => const [],
      _ => ['$value'.trim()],
    };
    for (final MapEntry(:key, :value) in dns.entries) {
      switch (key) {
        case 'nameserver' || 'default-nameserver':
          final servers = strings(value).map(mitmDnsServer).toList();
          if (servers.contains(null)) {
            _skip(
              'dns',
              '$key: ${strings(value).join(', ')}',
              MitmModuleSkipReason.unreadable,
            );
            continue;
          }
          _editList(
            key == 'nameserver' ? _plainDnsKey : key,
            markOf(key),
            servers.nonNulls.toList(),
          );
        case 'fake-ip-filter':
          _editList(key, markOf(key), strings(value));
        case 'nameserver-policy' when value is Map:
          for (final MapEntry(key: domain, value: servers) in value.entries) {
            final read = strings(servers).map(mitmDnsServer).toList();
            if (read.contains(null) || read.isEmpty) {
              _skip(
                'dns',
                '$domain: $servers',
                MitmModuleSkipReason.unreadable,
              );
            } else {
              _nameserverPolicy['$domain'] = read.nonNulls.toList();
            }
          }
        default:
          _skip('dns', key, MitmModuleSkipReason.setting);
      }
    }
  }

  void _readRule(String section, String line, {String? shown}) {
    final parts = _ruleParts(line);
    final type = parts.first.toUpperCase();
    if (type == 'FINAL' || type == 'MATCH') {
      _skip(section, shown ?? line, MitmModuleSkipReason.finalRule);
      return;
    }
    if (_deviceRules.contains(type)) {
      _skip(section, shown ?? line, MitmModuleSkipReason.deviceRule);
      return;
    }
    final named =
        parts.length > 2 &&
        parts[2].trim().isNotEmpty &&
        !_ruleOptions.contains(parts[2].toLowerCase());
    final policy = named ? _unquote(parts[2].trim()) : 'DIRECT';
    final options = [...parts.skip(named ? 3 : 2)];
    if (RegExp(r'^https?://').hasMatch(parts.first)) {
      _readRuleSet(
        section,
        shown ?? line,
        parts.first,
        parts.length > 1 ? _unquote(parts[1].trim()) : 'DIRECT',
        [...parts.skip(2)],
      );
      return;
    }
    if (type == 'RULE-SET' && parts.length > 1) {
      _readRuleSet(section, shown ?? line, _unquote(parts[1]), policy, options);
      return;
    }
    if (type == 'DOMAIN-SET' && parts.length > 1) {
      _readRuleSet(
        section,
        shown ?? line,
        _unquote(parts[1]),
        policy,
        options,
        domainSet: true,
      );
      return;
    }
    if (type == 'URL-REGEX' || type == 'USER-AGENT') {
      final action = _rejectActions[policy.toUpperCase()];
      if (action == null) {
        _skip(section, shown ?? line, MitmModuleSkipReason.httpRulePolicy);
        return;
      }
      final value = _unquote(parts[1].trim());
      _urlRewrite.add(
        type == 'URL-REGEX'
            ? '${_field(value)} $action'
            : '^https?:// ${_field(_userAgentHead(value))} url-and-header $action',
      );
      _requestRules++;
      return;
    }
    final rule = _translateRule(
      parts.first,
      parts.length > 1 ? parts[1] : '',
      options,
    );
    final target = _target(policy);
    if (rule == null || target == null) {
      _skip(section, shown ?? line, MitmModuleSkipReason.rule);
      return;
    }
    _rules.add([rule.body, target, if (rule.noResolve) 'no-resolve'].join(','));
  }

  /// A built-in policy, or an exit of the policy's name; Quantumult X writes
  /// Loon's `PROXY` as `proxy`. An argument left unexpanded names nothing.
  String? _target(String policy) {
    if (_builtInTarget(policy) case final target?) {
      return target;
    }
    if (policy.contains(r'${')) {
      return null;
    }
    final exit = policy == 'proxy' ? 'PROXY' : policy;
    _exits.add(exit);
    return exit;
  }

  /// A RULE-SET of a URL, of Surge's internal sets, of a `[Ruleset]` section
  /// of the module, or of a rule provider a Stash override brings.
  void _readRuleSet(
    String section,
    String line,
    String value,
    String policy,
    List<String> options, {
    bool domainSet = false,
  }) {
    final target = _target(policy);
    if (target == null) {
      _skip(section, line, MitmModuleSkipReason.rule);
      return;
    }
    final String name;
    if (RegExp(r'^https?://').hasMatch(value)) {
      final interval = options
          .map(
            (option) => RegExp(
              r'^update-interval\s*=\s*(-?\d+)$',
            ).firstMatch(option.trim()),
          )
          .nonNulls
          .map((match) => int.parse(match.group(1)!))
          .firstOrNull;
      name = _ruleSetName(domainSet ? 'domain-set:$value' : value);
      _ruleProviders[name] = {
        'type': 'http',
        'behavior': domainSet ? 'domain' : 'classical',
        'format': domainSet ? 'domain-set' : 'text',
        'url': value,
        'interval': max(interval ?? _ruleSetInterval, 0),
      };
    } else if (_builtInRuleSets[value.toUpperCase()] case final payload?) {
      name = _ruleSetName('surge:${value.toUpperCase()}');
      _ruleProviders[name] = {
        'type': 'inline',
        'behavior': 'classical',
        'payload': [...payload],
      };
    } else if (_rulesetNames.contains(value)) {
      name = _inlineSetName(value);
    } else if (_stashProviderNames[value] case final mapped?) {
      name = mapped;
    } else if (section == 'rules') {
      _skip(section, line, MitmModuleSkipReason.rule);
      return;
    } else if (_resource(section, line, value) case final file?) {
      name = _ruleSetName('file:${domainSet ? 'domain-set:' : ''}$file');
      _ruleProviders[name] = {
        'type': 'file',
        'behavior': domainSet ? 'domain' : 'classical',
        'format': domainSet ? 'domain-set' : 'text',
        'path': '$mitmDirectoryName/$mitmResourcesDirectoryName/$file',
      };
    } else {
      return;
    }
    final noResolve = options.any(
      (option) => option.trim().toLowerCase() == 'no-resolve',
    );
    _rules.add(
      ['RULE-SET', name, target, if (noResolve) 'no-resolve'].join(','),
    );
  }

  /// Loon's `url, policy=..., tag=..., enabled=...`.
  void _readLoonRemoteRule(String section, String line) {
    final parts = _splitArguments(line);
    final params = {
      for (final part in parts.skip(1))
        if (part.indexOf('=') case final equals when equals > 0)
          part.substring(0, equals).trim().toLowerCase(): _unquote(
            part.substring(equals + 1).trim(),
          ),
    };
    if (params['enabled']?.toLowerCase() == 'false') {
      _skip(section, line, MitmModuleSkipReason.disabled);
      return;
    }
    if (parts.isEmpty || !RegExp(r'^https?://').hasMatch(parts.first)) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    _readRuleSet(
      section,
      line,
      parts.first,
      params['policy'] ?? 'DIRECT',
      const [],
    );
  }

  ({String body, bool noResolve})? _translateRule(
    String rawType,
    String payload,
    List<String> options, {
    bool nested = false,
  }) {
    final type = rawType.trim().toUpperCase();
    switch (type) {
      case 'AND' || 'OR' || 'NOT':
        final operands = _operands(payload);
        if (operands == null || (type == 'NOT' && operands.length != 1)) {
          return null;
        }
        final translated = <String>[];
        for (final operand in operands) {
          final parts = _ruleParts(operand);
          final rule = _translateRule(
            parts.first,
            parts.length > 1 ? parts[1] : '',
            const [],
            nested: true,
          );
          if (rule == null) {
            return null;
          }
          translated.add('(${rule.body})');
        }
        return (body: '$type,(${translated.join(',')})', noResolve: false);
      case 'PROTOCOL':
        final network = switch (payload.trim().toUpperCase()) {
          'TCP' => 'TCP',
          'UDP' => 'UDP',
          'QUIC' when nested => 'UDP',
          _ => null,
        };
        return network == null
            ? null
            : (body: 'NETWORK,$network', noResolve: false);
    }
    final target = _ruleTypes[type];
    var value = _unquote(payload.trim());
    switch (target) {
      case null:
        return null;
      case 'DOMAIN' || 'DOMAIN-SUFFIX' || 'DOMAIN-KEYWORD' || 'DOMAIN-WILDCARD':
        if (!_domainPattern.hasMatch(value)) {
          return null;
        }
      case 'IP-CIDR' || 'IP-CIDR6' || 'SRC-IP-CIDR':
        final cidr = _cidr(value);
        if (cidr == null) {
          return null;
        }
        value = cidr;
      case 'DST-PORT' || 'SRC-PORT' || 'IN-PORT':
        value = _portRange(value) ?? value;
        if (!_validPorts(value)) {
          return null;
        }
      case 'IP-ASN':
        if (int.tryParse(value) == null) {
          return null;
        }
      case 'NETWORK':
        value = value.toUpperCase();
        if (value != 'TCP' && value != 'UDP') {
          return null;
        }
      default:
        if (value.isEmpty || value.contains(',')) {
          return null;
        }
    }
    return (
      body: '$target,$value',
      noResolve:
          const {'IP-CIDR', 'IP-CIDR6', 'GEOIP', 'IP-ASN'}.contains(target) &&
          options.any((option) => option.toLowerCase() == 'no-resolve'),
    );
  }

  List<String>? _operands(String payload) {
    final text = payload.trim();
    if (!text.startsWith('(') || !text.endsWith(')')) {
      return null;
    }
    final operands = <String>[];
    for (final part in _splitRule(
      text.substring(1, text.length - 1),
      nested: true,
    )) {
      if (!part.startsWith('(') || !part.endsWith(')')) {
        return null;
      }
      operands.add(part.substring(1, part.length - 1));
    }
    return operands.isEmpty ? null : operands;
  }

  /// Surge's `address = action`, where reject answers and drop stays silent,
  /// as the rules that do the same.
  void _readIpRewrite(String section, String line) {
    final equals = line.indexOf('=');
    final cidr = equals < 0 ? null : _cidr(line.substring(0, equals).trim());
    final policy = switch (line.substring(equals + 1).trim().toLowerCase()) {
      'reject' => 'REJECT',
      'drop' => 'REJECT-DROP',
      'reflect' => 'reflect',
      _ => null,
    };
    if (cidr == null || policy == null) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
    } else if (policy == 'reflect') {
      _skip(section, line, MitmModuleSkipReason.reflect);
    } else {
      final type = cidr.contains(':') ? 'IP-CIDR6' : 'IP-CIDR';
      _rules.add('$type,$cidr,$policy,no-resolve');
    }
  }

  void _readMapLocal(String section, String line) {
    final tokens = _tokens(line);
    if (tokens == null || tokens.isEmpty) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    final params = <String, String>{};
    for (final token in tokens.skip(1)) {
      final equals = token.text.indexOf('=');
      if (equals <= 0) {
        _skip(section, line, MitmModuleSkipReason.unreadable);
        return;
      }
      params[token.text.substring(0, equals).toLowerCase()] = token.text
          .substring(equals + 1);
    }
    _addMapLocal(section, line, tokens.first.text, params);
  }

  /// With [request], a request body mock, which takes no status.
  void _addMapLocal(
    String section,
    String line,
    String pattern,
    Map<String, String> params, {
    String? head,
    bool request = false,
  }) {
    if ((params['data-type'] ?? 'file') == 'file') {
      final file = _resource(section, line, params['data'] ?? '');
      if (file == null) {
        return;
      }
      params['data'] = file;
    }
    (request ? _requestBodyMock : _mapLocal).add(
      [
        _field(pattern),
        if (head != null) ...['request-head', _field(head)],
        for (final MapEntry(:key, :value) in params.entries)
          if (!request || key != 'status-code') '$key=${_quoted(value)}',
      ].join(' '),
    );
  }

  /// Loon's legacy `pattern action ...`, which spreads over Surge's lists.
  void _readLoonRewrite(String section, String line) {
    if (_conditionalPattern.hasMatch(line)) {
      _readLoonConditional(section, line);
      return;
    }
    final tokens = _tokens(line);
    if (tokens == null || tokens.length < 2) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    final pattern = _field(tokens[0].text);
    var action = tokens[1].text.toLowerCase();
    var rest = line.substring(tokens[1].end).trim();
    if ((action == '-' || action == '_') && tokens.length > 2) {
      action = tokens[2].text.toLowerCase();
      rest = line.substring(tokens[2].end).trim();
    }
    final reject = _rejectActions[action.toUpperCase()];
    if (reject != null) {
      _urlRewrite.add('$pattern $reject');
      return;
    }
    if (const {'302', '307', 'header'}.contains(action) && tokens.length > 2) {
      _urlRewrite.add('$pattern ${_field(tokens[2].text)} $action');
      return;
    }
    if (isMitmResourceUrl(tokens[1].text) && tokens.length > 2) {
      final type = tokens[2].text.toLowerCase();
      if (const {'302', '307', 'header'}.contains(type)) {
        _urlRewrite.add('$pattern ${_field(tokens[1].text)} $type');
        return;
      }
    }
    if (action == 'url') {
      _urlRewrite.add(line);
      return;
    }
    if (tokens.length == 2 && !action.contains('-')) {
      _urlRewrite.add('$pattern ${_field(tokens[1].text)}');
      return;
    }
    final header = RegExp(
      r'^(request-|response-)?(header-(add|del|replace|replace-regex))$',
    ).firstMatch(action);
    if (header != null) {
      final phase = header.group(1) == 'response-'
          ? 'http-response'
          : 'http-request';
      final pairs = _tokens(rest);
      if (header.group(3) == 'add' && pairs != null && pairs.length > 2) {
        if (pairs.length.isOdd) {
          _skip(section, line, MitmModuleSkipReason.unreadable);
          return;
        }
        for (var i = 0; i < pairs.length; i += 2) {
          _headerRewrite.add(
            '$phase $pattern header-add ${_field(pairs[i].text)} '
            '${_field(pairs[i + 1].text)}',
          );
        }
        return;
      }
      _headerRewrite.add('$phase $pattern ${header.group(2)} $rest'.trim());
      return;
    }
    switch (action) {
      case 'request-body-replace-regex':
        _bodyRewrite.add('http-request $pattern $rest');
      case 'response-body-replace-regex':
        _bodyRewrite.add('http-response $pattern $rest');
      case 'request-body-json-jq':
        _bodyRewrite.add('http-request-jq $pattern $rest');
      case 'response-body-json-jq':
        _bodyRewrite.add('http-response-jq $pattern $rest');
      case 'mock-response-body' || 'mock-request-body':
        _readLoonMock(
          section,
          line,
          tokens[0].text,
          tokens.skip(2),
          request: action == 'mock-request-body',
        );
      default:
        final json = RegExp(
          r'^(request|response)-body-json-(add|replace|del)$',
        ).firstMatch(action);
        final jq = switch ((json, jsonEditArgs(rest))) {
          (final json?, final args?) => jsonEditJq(
            json.group(2)!,
            args,
            stash: false,
          ),
          _ => null,
        };
        if (jq == null) {
          _skip(section, line, MitmModuleSkipReason.unreadable);
        } else {
          _bodyRewrite.add('http-${json!.group(1)}-jq $pattern $jq');
        }
    }
  }

  /// Loon's `request|response if <condition> then <actions>`, whose
  /// actions all go over or the line is skipped.
  void _readLoonConditional(String section, String line) {
    switch (translateLoonRewrite(line)) {
      case LoonRewriteFailure.unreadable:
        _skip(section, line, MitmModuleSkipReason.unreadable);
      case LoonRewriteFailure.unsupported:
        _skip(section, line, MitmModuleSkipReason.conditional);
      case final LoonRewrite out:
        _urlRewrite.addAll(out.urlRewrite);
        _headerRewrite.addAll(out.headerRewrite);
        _bodyRewrite.addAll(out.bodyRewrite);
        for (final (:pattern, :head, :params) in out.mapLocal) {
          _addMapLocal(section, line, pattern, params, head: head);
        }
        for (final (:pattern, :head, :params) in out.requestBodyMock) {
          _addMapLocal(
            section,
            line,
            pattern,
            params,
            head: head,
            request: true,
          );
        }
        for (final (:path, :fields, :tag) in out.scripts) {
          if (fields['enable']?.toLowerCase() == 'false') {
            _skip(section, line, MitmModuleSkipReason.disabled);
            continue;
          }
          _addScript(
            section,
            line,
            tag,
            path,
            {
              'type': fields['type']!,
              'pattern': fields['pattern']!,
              'request-head': ?fields['request-head'],
              'response-head': ?fields['response-head'],
            },
            {
              'requires-body': ?fields['requires-body'],
              'binary-body-mode': ?fields['binary-body-mode'],
              'timeout': fields['timeout'] ?? _loonHttpScriptTimeout,
              'argument': ?fields['argument'],
            },
          );
        }
    }
  }

  void _readLoonMock(
    String section,
    String line,
    String pattern,
    Iterable<_Token> tokens, {
    bool request = false,
  }) {
    final params = <String, String>{};
    for (final token in tokens) {
      final equals = token.text.indexOf('=');
      if (equals > 0) {
        params[token.text.substring(0, equals).toLowerCase()] = token.text
            .substring(equals + 1);
      }
    }
    final dataType = params['data-type']?.toLowerCase() ?? 'text';
    final mapped = <String, String>{};
    final path = params['data-path'];
    if (path != null) {
      mapped['data-type'] = 'file';
      mapped['data'] = path;
    } else if (dataType == 'tiny-gif') {
      mapped['data-type'] = 'tiny-gif';
    } else {
      mapped['data-type'] = params['mock-data-is-base64'] == 'true'
          ? 'base64'
          : 'text';
      mapped['data'] = params['data'] ?? '';
    }
    if (params['status-code'] case final status?) {
      mapped['status-code'] = status;
    }
    if (loonContentTypes[dataType] case final contentType?
        when dataType != 'tiny-gif') {
      mapped['header'] = 'Content-Type:$contentType';
    }
    _addMapLocal(section, line, pattern, mapped, request: request);
  }

  /// Reads a line of a Quantumult X snippet, which may stand outside any
  /// section; a line of no form it has is left to the caller.
  bool _readQuantumultX(String line) {
    final lower = line.toLowerCase();
    if (RegExp(r'^hostname\s*=').hasMatch(lower)) {
      _readMitm('mitm', line);
    } else if (_qxMitmPattern.hasMatch(lower)) {
      _readQxMitm(line);
    } else if (_qxFilterPattern.hasMatch(lower)) {
      _readQxFilter(line);
    } else if (lower.startsWith('event-') || _qxCron(line) != null) {
      _readQxTask(line);
    } else if (_qxRewritePattern.hasMatch(line)) {
      _readQxRewrite(line);
    } else {
      return false;
    }
    return true;
  }

  void _readQxMitm(String line) {
    const section = 'mitm';
    final equals = line.indexOf('=');
    final key = line.substring(0, equals).trim().toLowerCase();
    switch (key) {
      case 'skip_dst_ip':
        _insertedHostname.addAll(
          line
              .substring(equals + 1)
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .map((item) => '-$item'),
        );
      case 'skip_src_ip':
        final skipped = line
            .substring(equals + 1)
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .map((item) => '-$item');
        if (skipped.isNotEmpty) {
          _clientSourceAddress.add(skipped.join(', '));
        }
      case 'skip_validating_cert':
        if (line.substring(equals + 1).trim().toLowerCase() == 'true') {
          _skipVerify = (section, line);
        }
      case 'p12' || 'passphrase':
        _skip(section, line, MitmModuleSkipReason.managedCa);
      default:
        _skip(section, line, MitmModuleSkipReason.setting);
    }
  }

  void _readQxFilter(String line) {
    const section = 'filter_local';
    final parts = _ruleParts(line);
    if (parts.first.toLowerCase() == 'final') {
      _skip(section, line, MitmModuleSkipReason.finalRule);
      return;
    }
    final type = _qxFilterTypes[parts.first.toLowerCase()];
    if (type == null || parts.length < 3) {
      _skip(section, line, MitmModuleSkipReason.rule);
      return;
    }
    _readRule(section, [type, ...parts.skip(1)].join(','), shown: line);
  }

  /// Reads `pattern url type ...`, where a body or echo rewrite repeats its
  /// type between the two values it takes.
  /// Quantumult X's `pattern url type ...`, and `pattern head url-and-header
  /// type ...`, whose head pattern is the Core's `request-head`.
  void _readQxRewrite(String line) {
    const section = 'rewrite_local';
    final match =
        RegExp(r'^(\S+)\s+url\s+(\S+)\s*(.*)$').firstMatch(line) ??
        RegExp(
          r'^(\S+)\s+(.+?)\s+url-and-header\s+(\S+)\s*(.*)$',
        ).firstMatch(line);
    if (match == null) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    final conditioned = match.groupCount == 4;
    final pattern = match.group(1)!;
    final head = conditioned ? match.group(2)!.trim() : null;
    final type = match.group(conditioned ? 3 : 2)!.toLowerCase();
    final rest = match.group(conditioned ? 4 : 3)!.trim();
    final repeated = rest.indexOf(type);
    final url = [
      _field(pattern),
      if (head != null) ...[_field(head), 'url-and-header'],
    ].join(' ');
    String rule(String phase, List<String> after) => [
      phase,
      _field(pattern),
      if (head != null) ...['request-head', _field(head)],
      ...after,
    ].join(' ');
    if (_qxScripts[type] case (final phase, final body)) {
      _declareScript(phase, line);
      _addScript(section, line, '', rest, {
        'type': phase,
        'pattern': pattern,
        'request-head': ?head,
        if (body) 'requires-body': 'true',
      });
      return;
    }
    switch (type) {
      case _ when _rejectRewrites.contains(type):
        _urlRewrite.add('$url $type');
      case '302' || '307' when rest.isNotEmpty && !rest.contains(' '):
        _urlRewrite.add(
          head == null
              ? '$url ${_field(rest)} $type'
              : '$url $type ${_field(rest)}',
        );
      case 'request-body' || 'response-body' when repeated > 0:
        _bodyRewrite.add(
          rule(type == 'request-body' ? 'http-request' : 'http-response', [
            _field(rest.substring(0, repeated).trim()),
            _field(rest.substring(repeated + type.length).trim()),
          ]),
        );
      case 'request-header' || 'response-header' when repeated > 0:
        _headerRewrite.add(
          rule(type == 'request-header' ? 'http-request' : 'http-response', [
            'header-text-replace',
            _field(rest.substring(0, repeated).trim()),
            _field(rest.substring(repeated + type.length).trim()),
          ]),
        );
      case 'jsonjq-request-body' || 'jsonjq-response-body' when rest.isNotEmpty:
        _bodyRewrite.add(
          rule(
            type == 'jsonjq-request-body'
                ? 'http-request-jq'
                : 'http-response-jq',
            [rest],
          ),
        );
      case 'echo-response' when repeated > 0:
        final headers = rest.substring(0, repeated).trim().split(r'\r\n');
        _addMapLocal(section, line, pattern, head: head, {
          'data-type': 'file',
          'data': rest.substring(repeated + type.length).trim(),
          'header': [
            'Content-Type:${headers.first}',
            for (final header in headers.skip(1))
              if (header.indexOf(':') case final colon when colon > 0)
                [
                  header.substring(0, colon).trim(),
                  header.substring(colon + 1).trim(),
                ].join(':'),
          ].join('|'),
        });
      default:
        _skip(section, line, MitmModuleSkipReason.unreadable);
    }
  }

  void _readQxTask(String line) {
    const section = 'task_local';
    final lower = line.toLowerCase();
    final cron = _qxCron(line);
    final String rest;
    final interaction = lower.startsWith('event-interaction');
    if (lower.startsWith('event-network')) {
      rest = line.substring('event-network'.length).trim();
    } else if (interaction) {
      rest = line.substring('event-interaction'.length).trim();
    } else if (cron != null) {
      rest = cron.rest;
    } else {
      _skip(
        section,
        line,
        lower.startsWith('event-')
            ? MitmModuleSkipReason.scriptType
            : MitmModuleSkipReason.unreadable,
      );
      return;
    }
    _declareScript(
      cron != null
          ? 'cron'
          : interaction
          ? 'generic'
          : 'event',
      line,
    );
    final comma = rest.indexOf(',');
    final params = comma < 0
        ? const <String, String>{}
        : _scriptParams(rest.substring(comma + 1)) ?? const {};
    if (params['enabled']?.toLowerCase() == 'false') {
      _skip(section, line, MitmModuleSkipReason.disabled);
      return;
    }
    _addScript(
      section,
      line,
      params['tag'] ?? '',
      (comma < 0 ? rest : rest.substring(0, comma)).trim(),
      {
        if (cron != null) ...{
          'type': 'cron',
          'cronexp': cron.expression,
        } else if (interaction)
          'type': 'generic'
        else ...{
          'type': 'event',
          'event-name': 'network-changed',
        },
      },
      const {'timeout': _qxTaskTimeout},
    );
  }

  MitmModuleContent parseStash(Map<String, Object?> override, String text) {
    for (final key in const ['name', 'desc']) {
      if (override[key] case final Object value) {
        _meta[key] = '$value';
      }
    }
    _readDeclarations(text.split(RegExp(r'\r\n|\r|\n')));
    _readStashArguments(override['arguments']);
    _readStashRuleProviders(override['rule-providers']);
    final providers = switch (override['script-providers']) {
      final Map<String, Object?> providers => providers,
      _ => const <String, Object?>{},
    };
    for (final MapEntry(:key, :value) in override.entries) {
      switch (value) {
        case final Map<String, Object?> http when key == 'http':
          _readStashHttp(http, providers);
        case final Map<String, Object?> cron when key == 'cron':
          for (final MapEntry(key: name, :value) in cron.entries) {
            if (name == 'script' && value is List) {
              for (final item in value) {
                _readStashScript('cron', item, providers);
              }
            } else {
              _skip('cron', name, MitmModuleSkipReason.setting);
            }
          }
        case _ when key == 'rule-providers':
          break;
        case final Map<String, Object?> dns when key == 'dns':
          _readStashDns(dns, text);
        case final Map<String, Object?> hosts when key == 'hosts':
          for (final MapEntry(key: host, :value) in hosts.entries) {
            _readHost(
              key,
              '$host = ${value is List ? value.join(', ') : value}',
            );
          }
        case final List rules when key == 'rules':
          for (final rule in rules) {
            _readRule('rules', _stashText(rule), shown: _stashLine(rule));
          }
        case _ when _proxySections.contains(key) || key == 'proxy-providers':
          _skip(key, key, MitmModuleSkipReason.proxies);
        case _ when _appOnlySection.hasMatch(key):
          _skip(key, key, MitmModuleSkipReason.appOnly);
        case _ when !_stashMetaKeys.contains(key):
          _skip(key, key, MitmModuleSkipReason.section);
      }
    }
    return _content();
  }

  void _readStashHttp(
    Map<String, Object?> http,
    Map<String, Object?> providers,
  ) {
    for (final MapEntry(:key, :value) in http.entries) {
      if (key == 'ca' || key == 'ca-passphrase') {
        _skip('http', key, MitmModuleSkipReason.managedCa);
        continue;
      }
      if (value is! List || !_stashHttpLists.contains(key)) {
        _skip('http', key, MitmModuleSkipReason.setting);
        continue;
      }
      for (final item in value) {
        final line = _stashText(item);
        switch (key) {
          case 'force-http-engine':
            if (line.trim().isNotEmpty) {
              _hostname.add(line.trim());
            }
          case 'mitm':
            final host = line.endsWith(':*')
                ? line.substring(0, line.length - 2)
                : line;
            if (host.trim().isNotEmpty) {
              _hostname.add(host.trim());
            }
          case 'url-rewrite' || 'rewrite':
            _readStashUrlRewrite(key, line);
          case 'header-rewrite':
            _readStashHeaderRewrite(key, line);
          case 'body-rewrite':
            _readStashBodyRewrite(key, line);
          case 'mock':
            _readStashMock(key, item);
          case 'script':
            _readStashScript(key, item, providers);
        }
      }
    }
  }

  /// Reads `pattern replacement type`, where a rejection names no
  /// replacement or a placeholder.
  void _readStashUrlRewrite(String section, String line) {
    final tokens = _tokens(line);
    final type = tokens?.lastOrNull?.text.toLowerCase();
    if (tokens == null || tokens.length < 2 || type == null) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
    } else if (_rejectRewrites.contains(type)) {
      _urlRewrite.add('${_field(tokens.first.text)} $type');
    } else if (tokens.length == 3 &&
        const {'302', '307', 'transparent', 'header'}.contains(type)) {
      _urlRewrite.add(
        '${_field(tokens.first.text)} ${_field(tokens[1].text)} '
        '${type == 'transparent' ? 'header' : type}',
      );
    } else {
      _skip(section, line, MitmModuleSkipReason.unreadable);
    }
  }

  void _readStashHeaderRewrite(String section, String line) {
    final match = RegExp(
      r'^(\S+)\s+(request|response)-(add|del|replace|replace-regex)\s+(.+)$',
    ).firstMatch(line);
    if (match == null) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    _headerRewrite.add(
      'http-${match.group(2)} ${_field(match.group(1)!)} '
      'header-${match.group(3)} ${match.group(4)}',
    );
  }

  void _readStashBodyRewrite(String section, String line) {
    final match = RegExp(
      r'^(\S+)\s+(request|response)-(\S+)\s+(.+)$',
    ).firstMatch(line);
    switch (match?.group(3)) {
      case 'replace-regex':
        _bodyRewrite.add(
          'http-${match!.group(2)} ${_field(match.group(1)!)} '
          '${match.group(4)}',
        );
      case 'jq':
        _bodyRewrite.add(
          'http-${match!.group(2)}-jq ${_field(match.group(1)!)} '
          '${match.group(4)}',
        );
      case final action?
          when RegExp(r'^json-(add|replace|del)$').hasMatch(action):
        final args = jsonEditArgs(match!.group(4)!);
        final jq = args == null
            ? null
            : jsonEditJq(action.substring('json-'.length), args, stash: true);
        if (jq == null) {
          _skip(section, line, MitmModuleSkipReason.unreadable);
        } else {
          _bodyRewrite.add(
            'http-${match.group(2)}-jq ${_field(match.group(1)!)} $jq',
          );
        }
      default:
        _skip(section, line, MitmModuleSkipReason.unreadable);
    }
  }

  /// A mock body of more than one line goes over as base64, as each line of
  /// the Core's lists is one entry.
  void _readStashMock(String section, Object? item) {
    final shown = _stashLine(item);
    if (item is! Map<String, Object?> || item['match'] == null) {
      _skip(section, shown, MitmModuleSkipReason.unreadable);
      return;
    }
    final text = _stashText(item['text']);
    final headers = item['headers'];
    _addMapLocal(section, shown, _stashText(item['match']), {
      if (item['base64'] != null) ...{
        'data-type': 'base64',
        'data': _stashText(item['base64']),
      } else if (text.contains(RegExp(r'[\r\n]'))) ...{
        'data-type': 'base64',
        'data': base64Encode(utf8.encode(text)),
      } else ...{
        'data-type': 'text',
        'data': text,
      },
      if (item['status-code'] != null)
        'status-code': _stashText(item['status-code']),
      if (headers is Map<String, Object?> && headers.isNotEmpty)
        'header': [
          for (final MapEntry(:key, :value) in headers.entries)
            '$key:${_stashText(value)}',
        ].join('|'),
    });
  }

  /// Reads an http script, or with [section] `cron` a scheduled one, whose
  /// file a script provider of the same name downloads.
  void _readStashScript(
    String section,
    Object? item,
    Map<String, Object?> providers,
  ) {
    final shown = _stashLine(item);
    if (item is! Map<String, Object?>) {
      _skip(section, shown, MitmModuleSkipReason.unreadable);
      return;
    }
    String? field(String key) =>
        item[key] == null ? null : _stashText(item[key]);
    final cron = section == 'cron';
    final declared = '${item['type'] ?? ''}'.toLowerCase();
    _declareScript(
      cron ? 'cron' : _stashScriptTypes[declared] ?? declared,
      shown,
    );
    final type = cron
        ? 'cron'
        : _stashScriptTypes[field('type')?.toLowerCase()];
    if (type == null) {
      _skip(section, shown, MitmModuleSkipReason.scriptType);
      return;
    }
    final name = field('name') ?? '';
    final provider = providers[name];
    final argument = field('argument');
    final url = provider is Map<String, Object?>
        ? _stashText(provider['url'])
        : '';
    _addScript(
      section,
      shown,
      name,
      switch (provider) {
        {'payload': final String payload} when url.isEmpty => _inline(
          _stashText(payload),
        ),
        _ => url,
      },
      {
        'type': type,
        if (cron) 'cronexp': ?field('cron') else 'pattern': ?field('match'),
      },
      {
        'requires-body': ?field('require-body'),
        'binary-body-mode': ?field('binary-mode'),
        'max-size': ?field('max-size'),
        'timeout': ?field('timeout'),
        if (argument != null && argument.isNotEmpty) 'argument': argument,
      },
    );
  }

  void _readStashRuleProviders(Object? providers) {
    if (providers is! Map<String, Object?>) {
      return;
    }
    for (final MapEntry(key: name, :value) in providers.entries) {
      if (value is! Map<String, Object?> ||
          !const {'http', 'inline'}.contains(value['type'])) {
        _skip(
          'rule-providers',
          name,
          value is Map && value['type'] == 'file'
              ? MitmModuleSkipReason.relativeData
              : MitmModuleSkipReason.unreadable,
        );
        continue;
      }
      final provider = {
        for (final MapEntry(:key, :value) in value.entries)
          if (key != 'path') key: value is String ? _stashText(value) : value,
      };
      final mapped = _ruleSetName('stash:$name:${jsonEncode(provider)}');
      _stashProviderNames[name] = mapped;
      _ruleProviders[mapped] = provider;
    }
  }

  void _readStashArguments(Object? arguments) {
    if (arguments is! Map<String, Object?>) {
      return;
    }
    for (final MapEntry(key: name, :value) in arguments.entries) {
      if (value is! Map<String, Object?>) {
        continue;
      }
      final type = switch (value['type']) {
        'select' => MitmModuleArgumentType.select,
        'switch' => MitmModuleArgumentType.toggle,
        _ => MitmModuleArgumentType.input,
      };
      final choices = [
        if (value['options'] case final List options)
          for (final option in options)
            option is Map<String, Object?> ? option['value'] : option,
      ].nonNulls.toList();
      final options = [for (final choice in choices) '$choice'];
      _stashArguments.add(
        MitmModuleArgument(
          name: name,
          defaultValue: switch (value['default']) {
            final Object fallback => '$fallback',
            _ when type == MitmModuleArgumentType.toggle => 'false',
            _ => options.firstOrNull ?? '',
          },
          type: type,
          options: type == MitmModuleArgumentType.select ? options : const [],
          label: switch (value['title']) {
            final String title when title.isNotEmpty => title,
            _ => null,
          },
          description: switch (value['description']) {
            final String description when description.isNotEmpty => description,
            _ => null,
          },
          number:
              value['value-type'] == 'integer' ||
              choices.isNotEmpty && choices.every((choice) => choice is int),
        ),
      );
    }
  }

  /// A scalar of the override with its `${args.name}` references filled in;
  /// `|json` writes the value as JSON and `$$` escapes a reference.
  String _stashText(Object? value) {
    final text = value == null ? '' : '$value';
    if (!text.contains(r'${args.')) {
      return text;
    }
    return text.replaceAllMapped(_stashReference, (match) {
      final argument = _stashArguments.firstWhereOrNull(
        (argument) => argument.name == match.group(2),
      );
      if (match.group(1)!.isNotEmpty || argument == null) {
        return match.group(0)!.substring(match.group(1)!.length);
      }
      final value = _valueOf(argument);
      if (match.group(3) == null) {
        return value;
      }
      return switch (argument) {
        MitmModuleArgument(type: MitmModuleArgumentType.toggle) =>
          '${value == 'true'}',
        MitmModuleArgument(number: true) when num.tryParse(value) != null =>
          value,
        _ => jsonEncode(value),
      };
    });
  }
}

String _stashLine(Object? item) => item is String ? item : jsonEncode(item);

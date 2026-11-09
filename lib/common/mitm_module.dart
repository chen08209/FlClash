import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
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
  policy,
  jq,
  jsonBody,
  rawHeader,
  conditional,
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
    this.script = const [],
    this.declaredScriptLines = const [],
    this.rules = const [],
    this.resourceUrls = const {},
    this.skipped = const [],
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
  final List<String> script;

  /// The scripts it declares that FlClash runs, whatever its arguments leave
  /// on.
  final List<String> declaredScriptLines;
  int get declaredScripts => declaredScriptLines.length;
  final List<String> rules;
  final Set<String> resourceUrls;
  final List<MitmModuleSkip> skipped;

  bool get isEmpty =>
      lines.isEmpty && rules.isEmpty && resourceUrls.isEmpty && skipped.isEmpty;

  MitmRules get mitm => MitmRules(
    hostname: [...insertedHostname, ...hostname],
    urlRewrite: urlRewrite,
    headerRewrite: headerRewrite,
    bodyRewrite: bodyRewrite,
    mapLocal: mapLocal,
    script: script,
  );

  List<String> get lines => [
    for (final list in MitmList.values) ...mitm.linesOf(list),
  ];
}

/// The user's own hostnames come first, so an exclusion they wrote holds
/// against any module.
({MitmRules mitm, List<String> rules}) mergeMitmModules(
  List<String> hostname,
  Iterable<MitmModuleContent> modules,
) {
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
      script: all((module) => module.script),
    ),
    rules: all((module) => module.rules),
  );
}

Map<String, String> mitmAttachments(MitmModule module) => {
  if (!module.isRemote)
    for (final MapEntry(:key, :value) in module.resources.entries)
      if (!isMitmResourceUrl(key)) key: value,
};

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
}) {
  final parser = _ModuleParser(values: values, resources: resources);
  final override = _stashOverride(text);
  return override == null
      ? parser.parse(text)
      : parser.parseStash(override, text);
}

/// What consent to a module's scripts covers; a line run names its content's hash.
Set<String> mitmScriptScope(
  String text, {
  Map<String, String> values = const {},
  Map<String, String> resources = const {},
}) {
  final content = parseMitmModule(text, values: values, resources: resources);
  return {...content.declaredScriptLines, ...content.script};
}

/// Keys at the top of a Stash override that a Surge module or a Quantumult X
/// snippet read as YAML never has.
const _stashKeys = {'http', 'script-providers', 'cron', 'rules', 'tiles'};

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
};

const _loonContentTypes = {
  'text': 'text/plain; charset=utf-8',
  'json': 'application/json',
  'html': 'text/html; charset=utf-8',
  'javascript': 'application/javascript',
  'css': 'text/css',
  'xml': 'application/xml',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'gif': 'image/gif',
};

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
  _ModuleParser({required this.values, required this.resources});

  final Map<String, String> values;
  final Map<String, String> resources;

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
  final _script = <String>[];
  final _declaredScriptLines = <String>[];
  final _rules = <String>[];
  final _resourceUrls = <String>{};
  final _skipped = <MitmModuleSkip>[];

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
      if (trimmed.isEmpty || _isComment(trimmed)) {
        continue;
      }
      if (section == null) {
        _readQuantumultX(trimmed);
        continue;
      }
      if (section.toLowerCase() == 'script') {
        if (trimmed.contains('{')) {
          _declaredScriptLines.add(trimmed);
        } else {
          _declareScript(_scriptLine(trimmed)?.type, trimmed);
        }
      }
      final line = _substitute(trimmed).trim();
      if (line.isEmpty || _isComment(line)) {
        continue;
      }
      _readLine(section, line, trimmed);
    }
    return _content();
  }

  MitmModuleContent _content() {
    String? meta(String key) {
      final value = _meta[key]?.replaceAll(r'\n', '\n').trim();
      return value == null || value.isEmpty ? null : value;
    }

    return MitmModuleContent(
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
      script: _script,
      declaredScriptLines: _declaredScriptLines,
      rules: _rules,
      resourceUrls: _resourceUrls,
      skipped: _skipped,
    );
  }

  void _readDeclarations(List<String> lines) {
    String? section;
    for (final raw in lines) {
      final line = raw.trim();
      final header = _sectionPattern.firstMatch(line);
      if (header != null) {
        section = header.group(1)!.trim().toLowerCase();
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
    switch (section.toLowerCase()) {
      case 'argument':
        break;
      case 'rule':
        _readRule(section, line);
      case 'url rewrite':
        _urlRewrite.add(line);
      case 'header rewrite':
        _headerRewrite.add(line);
      case 'body rewrite':
        if (RegExp(r'^http-(request|response)-jq\s').hasMatch(line)) {
          _skip(section, line, MitmModuleSkipReason.jq);
        } else {
          _bodyRewrite.add(line);
        }
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
      default:
        _skip(section, line, MitmModuleSkipReason.section);
    }
  }

  /// Reads Surge's `name = type=...,...` and the legacy `type pattern ...`
  /// Loon writes, into the form the Core's script list takes.
  void _readScript(String section, String line, String raw) {
    if (_conditionalPattern.hasMatch(line) || _loonScriptCall.hasMatch(line)) {
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

  void _declareScript(String? type, String line) {
    if (_runnableScriptTypes.contains(type) || (type?.contains('{') ?? false)) {
      _declaredScriptLines.add(line);
    }
  }

  /// The resources directory's file for [url], or null once the line is
  /// skipped for a file the module does not download or FlClash has not.
  String? _resource(String section, String line, String url) {
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
    if (key != 'hostname') {
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

  void _readRule(String section, String line, {String? shown}) {
    final parts = _ruleParts(line);
    final type = parts.first.toUpperCase();
    final policy = parts.length > 2 ? parts[2].toUpperCase() : null;
    if (type == 'URL-REGEX') {
      final action = _rejectActions[policy];
      if (action == null) {
        _skip(section, shown ?? line, MitmModuleSkipReason.policy);
      } else {
        _urlRewrite.add('${_field(_unquote(parts[1]))} $action');
      }
      return;
    }
    final target = switch (policy) {
      'DIRECT' => 'DIRECT',
      'REJECT-DROP' => 'REJECT-DROP',
      final policy? when _rejectActions.containsKey(policy) => 'REJECT',
      _ => null,
    };
    if (target == null) {
      _skip(section, shown ?? line, MitmModuleSkipReason.policy);
      return;
    }
    final rule = _translateRule(parts.first, parts.length > 1 ? parts[1] : '', [
      ...parts.skip(3),
    ]);
    if (rule == null) {
      _skip(section, shown ?? line, MitmModuleSkipReason.rule);
      return;
    }
    _rules.add([rule.body, target, if (rule.noResolve) 'no-resolve'].join(','));
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
      case 'PROTOCOL' when nested:
        final network = switch (payload.trim().toUpperCase()) {
          'TCP' => 'TCP',
          'UDP' || 'QUIC' => 'UDP',
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
        if (!_validPorts(value)) {
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
          target.startsWith('IP-CIDR') &&
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

  void _addMapLocal(
    String section,
    String line,
    String pattern,
    Map<String, String> params,
  ) {
    if ((params['data-type'] ?? 'file') == 'file') {
      final file = _resource(section, line, params['data'] ?? '');
      if (file == null) {
        return;
      }
      params['data'] = file;
    }
    _mapLocal.add(
      [
        _field(pattern),
        for (final MapEntry(:key, :value) in params.entries)
          '$key=${_quoted(value)}',
      ].join(' '),
    );
  }

  /// Loon's legacy `pattern action ...`, which spreads over Surge's lists.
  void _readLoonRewrite(String section, String line) {
    if (_conditionalPattern.hasMatch(line)) {
      _skip(section, line, MitmModuleSkipReason.conditional);
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
      _headerRewrite.add('$phase $pattern ${header.group(2)} $rest'.trim());
      return;
    }
    switch (action) {
      case 'request-body-replace-regex':
        _bodyRewrite.add('http-request $pattern $rest');
      case 'response-body-replace-regex':
        _bodyRewrite.add('http-response $pattern $rest');
      case 'mock-response-body':
        _readLoonMock(section, line, tokens[0].text, tokens.skip(2));
      default:
        _skip(
          section,
          line,
          RegExp(r'^(request|response)-body-json-').hasMatch(action)
              ? MitmModuleSkipReason.jsonBody
              : MitmModuleSkipReason.unreadable,
        );
    }
  }

  void _readLoonMock(
    String section,
    String line,
    String pattern,
    Iterable<_Token> tokens,
  ) {
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
    if (_loonContentTypes[dataType] case final contentType?
        when dataType != 'tiny-gif') {
      mapped['header'] = 'Content-Type:$contentType';
    }
    _addMapLocal(section, line, pattern, mapped);
  }

  /// Reads a line of a Quantumult X snippet, which may stand outside any
  /// section; a line of no form it has is left to the caller.
  bool _readQuantumultX(String line) {
    final lower = line.toLowerCase();
    if (RegExp(r'^hostname\s*=').hasMatch(lower)) {
      _readMitm('mitm', line);
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

  void _readQxFilter(String line) {
    const section = 'filter_local';
    final parts = _ruleParts(line);
    final type = _qxFilterTypes[parts.first.toLowerCase()];
    if (type == null || parts.length < 3) {
      _skip(section, line, MitmModuleSkipReason.rule);
      return;
    }
    _readRule(section, [type, ...parts.skip(1)].join(','), shown: line);
  }

  /// Reads `pattern url type ...`, where a body or echo rewrite repeats its
  /// type between the two values it takes.
  void _readQxRewrite(String line) {
    const section = 'rewrite_local';
    if (RegExp(r'\surl-and-header\s').hasMatch(line)) {
      _skip(section, line, MitmModuleSkipReason.conditional);
      return;
    }
    final match = RegExp(r'^(\S+)\s+url\s+(\S+)\s*(.*)$').firstMatch(line);
    if (match == null) {
      _skip(section, line, MitmModuleSkipReason.unreadable);
      return;
    }
    final pattern = match.group(1)!;
    final type = match.group(2)!.toLowerCase();
    final rest = match.group(3)!.trim();
    final repeated = rest.indexOf(type);
    if (_qxScripts[type] case (final phase, final body)) {
      _declareScript(phase, line);
      _addScript(section, line, '', rest, {
        'type': phase,
        'pattern': pattern,
        if (body) 'requires-body': 'true',
      });
      return;
    }
    switch (type) {
      case _ when _rejectRewrites.contains(type):
        _urlRewrite.add('${_field(pattern)} $type');
      case '302' || '307' when rest.isNotEmpty && !rest.contains(' '):
        _urlRewrite.add('${_field(pattern)} ${_field(rest)} $type');
      case 'request-body' || 'response-body' when repeated > 0:
        _bodyRewrite.add(
          [
            type == 'request-body' ? 'http-request' : 'http-response',
            _field(pattern),
            _field(rest.substring(0, repeated).trim()),
            _field(rest.substring(repeated + type.length).trim()),
          ].join(' '),
        );
      case 'request-header' || 'response-header':
        _skip(section, line, MitmModuleSkipReason.rawHeader);
      case 'jsonjq-request-body' || 'jsonjq-response-body':
        _skip(section, line, MitmModuleSkipReason.jq);
      case 'echo-response' when repeated > 0:
        final headers = rest.substring(0, repeated).trim().split(r'\r\n');
        _addMapLocal(section, line, pattern, {
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
    if (lower.startsWith('event-network')) {
      rest = line.substring('event-network'.length).trim();
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
    _declareScript(cron != null ? 'cron' : 'event', line);
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
        if (cron != null) ...{'type': 'cron', 'cronexp': cron.expression},
        if (cron == null) ...{'type': 'event', 'event-name': 'network-changed'},
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
        case final List rules when key == 'rules':
          for (final rule in rules) {
            _readRule('rules', _stashText(rule), shown: _stashLine(rule));
          }
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
      if (value is! List || !_stashHttpLists.contains(key)) {
        _skip('http', key, MitmModuleSkipReason.setting);
        continue;
      }
      for (final item in value) {
        final line = _stashText(item);
        switch (key) {
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
        const {'302', '307', 'transparent'}.contains(type)) {
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
        _skip(section, line, MitmModuleSkipReason.jq);
      case final action? when action.startsWith('json-'):
        _skip(section, line, MitmModuleSkipReason.jsonBody);
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
    _addScript(
      section,
      shown,
      name,
      provider is Map<String, Object?> ? _stashText(provider['url']) : '',
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

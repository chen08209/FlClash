import 'dart:io';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:fl_clash/common/string.dart';
import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/models/models.dart';
import 'package:path/path.dart' as p;

Map<String, String> mitmAttachments(MitmModule module) => {
  if (!module.isRemote)
    for (final MapEntry(:key, :value) in module.resources.entries)
      if (!isMitmResourceUrl(key) && !key.startsWith(mitmInlineResource))
        key: value,
};

/// The prefix of a resource key a module writes inline.
const mitmInlineResource = 'inline:';

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
/// What a module's `LANGUAGE` requirement reads, as Surge gives it.
String get mitmModuleLanguage => Platform.localeName.replaceAll('_', '-');

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
  if (_isStashOverride(text)) {
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

final _sectionPattern = RegExp(r'^\[([^\]]+)\]$');

bool _isStashOverride(String text) {
  final lines = text.split(RegExp(r'\r\n|\r|\n'));
  if (lines.any((line) => _sectionPattern.hasMatch(line.trim()))) {
    return false;
  }
  try {
    return switch (loadPlainYaml(text)) {
      final Map<String, Object?> document => _stashKeys.any(
        document.containsKey,
      ),
      _ => false,
    };
  } on FormatException {
    return false;
  }
}

const _stashKeys = {
  'http',
  'script-providers',
  'cron',
  'rules',
  'tiles',
  'dns',
  'hosts',
};

String _field(String text) {
  if (text.isNotEmpty && !RegExp(r'[\s"]').hasMatch(text)) {
    return text;
  }
  return '"${text.replaceAll('"', r'\"')}"';
}

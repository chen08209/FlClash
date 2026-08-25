import 'dart:convert';

class V2BoardRemoteConfig {
  final List<String> domains;

  const V2BoardRemoteConfig({required this.domains});

  factory V2BoardRemoteConfig.decode(Object? value) {
    final decoded = _decodeValue(value);
    final root = _asMap(decoded);
    final config = root['domain'] == null ? _asMap(root['data']) : root;
    final rawDomains = config['domain'];
    if (rawDomains is! List) {
      throw const FormatException('OSS config does not contain domain list');
    }
    final domains = rawDomains
        .whereType<String>()
        .map((domain) => domain.trim().replaceFirst(RegExp(r'/+$'), ''))
        .where(_isHttpUrl)
        .toSet()
        .toList(growable: false);
    if (domains.isEmpty) {
      throw const FormatException('OSS config contains no valid API domain');
    }
    return V2BoardRemoteConfig(domains: domains);
  }

  static Object? _decodeValue(Object? value) {
    if (value is! String) return value;
    final source = value.trim();
    if (source.isEmpty) {
      throw const FormatException('OSS config is empty');
    }
    try {
      return jsonDecode(source);
    } on FormatException {
      try {
        return jsonDecode(utf8.decode(base64.decode(base64.normalize(source))));
      } on Object {
        throw const FormatException('OSS config is not valid JSON');
      }
    }
  }

  static Map<String, Object?> _asMap(Object? value) {
    if (value is! Map) {
      throw const FormatException('OSS config root must be an object');
    }
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  static bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}

class V2BoardSession {
  final String authData;
  final String email;
  final String subscribeUrl;

  const V2BoardSession({
    required this.authData,
    required this.email,
    required this.subscribeUrl,
  });
}

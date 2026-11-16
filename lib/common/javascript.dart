import 'dart:convert';

import 'package:fl_clash/common/exception.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:flutter/foundation.dart';
import 'package:rust_api/rust_api.dart';

typedef ScriptEvaluator =
    Future<String> Function({required String script, required String config});

@visibleForTesting
ScriptEvaluator scriptEvaluator = evaluateScript;

Future<Map<String, dynamic>> handleEvaluate(
  String scriptContent,
  Map<String, dynamic> config,
) async {
  if (config['proxy-providers'] == null) {
    config['proxy-providers'] = {};
  }
  final String result;
  try {
    result = await scriptEvaluator(
      script: scriptContent,
      config: json.encode(config),
    );
  } catch (e) {
    throw MessageException(e.toString());
  }
  return _decodeConfig(result);
}

/// What a target can name once [scriptContent] has run over [config].
Future<ClashConfig> evaluateOutbounds(
  String scriptContent,
  Map<String, dynamic> config,
) async {
  final input = await compute(_encodeConfig, config);
  final String result;
  try {
    result = await scriptEvaluator(script: scriptContent, config: input);
  } catch (e) {
    throw MessageException(e.toString());
  }
  return compute(_outboundsOf, result);
}

String _encodeConfig(Map<String, dynamic> config) => json.encode({
  ...config,
  'proxy-providers': config['proxy-providers'] ?? {},
});

ClashConfig _outboundsOf(String result) {
  final config = _decodeConfig(result);
  List<Map<String, Object?>> outbounds(Object? items) => [
    if (items is List)
      for (final item in items)
        if (item is Map) {'name': item['name'], 'type': item['type']},
  ];
  final rules = config['rules'];
  return ClashConfig.fromJson({
    'proxies': outbounds(config['proxies']),
    'proxy-groups': outbounds(config['proxy-groups']),
    'rules': [
      if (rules is List)
        for (final rule in rules)
          if (rule is String &&
              rule.split(',').first.trim().toUpperCase() ==
                  RuleAction.MATCH.value)
            rule,
    ],
  });
}

Map<String, dynamic> _decodeConfig(String result) {
  final decoded = json.decode(result);
  if (decoded is! Map<String, dynamic>) {
    throw const MessageException(
      'script did not return a configuration object',
    );
  }
  return decoded;
}

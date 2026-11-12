import 'dart:convert';
import 'dart:io';

import 'fake_channel.dart';

typedef Json = Map<String, Object?>;

/// The Core's wire contract, read from `concord/schema/api.json`: it checks what
/// a client sends and makes up answers that hold to the schema.
class ApiSchema {
  ApiSchema._(this._root);

  factory ApiSchema.load() {
    final text = File('concord/schema/api.json').readAsStringSync();
    return ApiSchema._(json.decode(text) as Json);
  }

  final Json _root;

  Json get _defs => _root[r'$defs']! as Json;

  List<Json> get methods => [
    for (final method in _root['methods']! as List) method as Json,
  ];

  Json? method(String name) =>
      methods.where((method) => method['name'] == name).firstOrNull;

  Object? resolve(Object? schema) {
    var current = schema;
    while (current is Map && current.containsKey(r'$ref')) {
      final name = (current[r'$ref']! as String).split('/').last;
      current = _defs[name];
    }
    return current;
  }

  List<String> validate(Object? value, Object? schema, [String path = r'$']) {
    final resolved = resolve(schema);
    if (resolved == true || resolved is! Map) {
      return const [];
    }
    final errors = <String>[];
    final alternatives = resolved['oneOf'] ?? resolved['anyOf'];
    if (alternatives is List) {
      final attempts = [
        for (final alternative in alternatives)
          validate(value, alternative, path),
      ];
      return attempts.any((attempt) => attempt.isEmpty)
          ? const []
          : ['$path: matches none of ${alternatives.length} alternatives'];
    }
    if (resolved.containsKey('const') && value != resolved['const']) {
      errors.add('$path: expected ${resolved['const']}, got $value');
    }
    final enumValues = resolved['enum'];
    if (enumValues is List && !enumValues.contains(value)) {
      errors.add('$path: $value is not one of $enumValues');
    }
    final type = resolved['type'];
    final types = type is List ? type : [?type];
    if (types.isNotEmpty && !types.any((name) => _is(value, name as String))) {
      return ['$path: expected $types, got ${value.runtimeType}'];
    }
    if (value is Map) {
      final properties = (resolved['properties'] as Map?) ?? const {};
      final extra = resolved['additionalProperties'];
      for (final required in (resolved['required'] as List?) ?? const []) {
        if (!value.containsKey(required)) {
          errors.add('$path: missing required "$required"');
        }
      }
      for (final entry in value.entries) {
        final key = entry.key as String;
        if (properties.containsKey(key)) {
          errors.addAll(validate(entry.value, properties[key], '$path.$key'));
        } else if (extra is Map || extra == true) {
          errors.addAll(validate(entry.value, extra, '$path.$key'));
        } else if (types.contains('object') && properties.isNotEmpty) {
          errors.add('$path: unknown field "$key"');
        }
      }
    }
    if (value is List) {
      final items = resolved['items'];
      for (var index = 0; index < value.length; index++) {
        errors.addAll(validate(value[index], items, '$path[$index]'));
      }
    }
    return errors;
  }

  bool _is(Object? value, String type) => switch (type) {
    'string' => value is String,
    'integer' => value is int,
    'number' => value is num,
    'boolean' => value is bool,
    'array' => value is List,
    'object' => value is Map,
    'null' => value == null,
    _ => true,
  };

  /// An instance holding to [schema]: every property when [full], only the
  /// required ones otherwise, and a null for each required nullable one.
  Object? generate(Object? schema, {required bool full, int alternative = 0}) {
    final resolved = resolve(schema);
    if (resolved == true || resolved is! Map) {
      return <String, Object?>{};
    }
    final alternatives = resolved['oneOf'] ?? resolved['anyOf'];
    if (alternatives is List) {
      return generate(
        alternatives[alternative % alternatives.length],
        full: full,
      );
    }
    if (resolved.containsKey('const')) {
      return resolved['const'];
    }
    final enumValues = resolved['enum'];
    if (enumValues is List) {
      return enumValues.first;
    }
    final type = resolved['type'];
    final types = type is List ? type : [?type];
    if (!full && types.contains('null')) {
      return null;
    }
    final concrete = types.firstWhere(
      (name) => name != 'null',
      orElse: () => 'object',
    );
    switch (concrete) {
      case 'string':
        return 'x';
      case 'integer':
        final minimum = resolved['minimum'];
        return minimum is num ? minimum.toInt() + 1 : 1;
      case 'number':
        return 1.5;
      case 'boolean':
        return true;
      case 'array':
        return full || (resolved['minItems'] ?? 0) != 0
            ? [generate(resolved['items'], full: full)]
            : <Object?>[];
      default:
        final properties = (resolved['properties'] as Map?) ?? const {};
        final required = {...?(resolved['required'] as List?)};
        final result = <String, Object?>{};
        for (final entry in properties.entries) {
          if (full || required.contains(entry.key)) {
            result[entry.key as String] = generate(entry.value, full: full);
          }
        }
        final extra = resolved['additionalProperties'];
        if (extra is Map && properties.isEmpty) {
          result['k'] = generate(extra, full: full);
        }
        return result;
    }
  }
}

/// Answers every request from the schema, and keeps what the client got wrong.
class SchemaCore {
  SchemaCore(this.channel, this.schema, {required this.full}) {
    channel.sentListener = _onSent;
  }

  final FakeFrameChannel channel;
  final ApiSchema schema;
  final bool full;
  final List<String> problems = [];
  final Set<String> called = {};
  final Map<String, Object?> params = {};
  int _sub = 100;

  void _onSent(Json message) {
    final name = message['method'] as String?;
    final id = message['id'];
    if (name == null || id == null) {
      return;
    }
    final method = schema.method(name);
    if (method == null) {
      problems.add('$name is not a method of the schema');
      channel.fail(id, {
        'code': -32601,
        'message': 'unknown',
        'data': {'kind': 'unsupported'},
      });
      return;
    }
    called.add(name);
    params[name] = message['params'];
    problems.addAll(
      schema
          .validate(message['params'] ?? <String, Object?>{}, method['params'])
          .map((error) => '$name params $error'),
    );
    if (method['kind'] == 'stream') {
      final sub = ++_sub;
      channel.answer(id, {
        'sub': sub,
        'snapshot': schema.generate(method['snapshot'], full: full),
      });
      final event = (method['stream']! as Json)['event'];
      final count = _alternatives(event);
      Future<void>.microtask(() {
        channel.event(sub, [
          for (var index = 0; index < count; index++)
            schema.generate(event, full: full, alternative: index),
        ]);
      });
      return;
    }
    channel.answer(id, schema.generate(method['result'], full: full));
  }

  int _alternatives(Object? event) {
    final resolved = schema.resolve(event);
    final alternatives = resolved is Map
        ? resolved['oneOf'] ?? resolved['anyOf']
        : null;
    return alternatives is List ? alternatives.length : 1;
  }
}

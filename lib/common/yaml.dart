import 'package:fl_clash/common/yaml_writer.dart';
import 'package:yaml/yaml.dart';

class Yaml {
  static Yaml? _instance;

  Yaml._internal();

  factory Yaml() {
    _instance ??= Yaml._internal();
    return _instance!;
  }

  String encode(Object? value) {
    return writeYaml(value);
  }
}

final yaml = Yaml();

/// Applies `<<` merge keys as mihomo does; package:yaml keeps them as keys.
Object? loadPlainYaml(String content) => _plainYaml(loadYaml(content));

Object? _plainYaml(Object? node) => switch (node) {
  YamlMap() => _plainYamlMap(node),
  YamlList() => [for (final item in node) _plainYaml(item)],
  _ => node,
};

Map<String, Object?> _plainYamlMap(YamlMap node) {
  final map = <String, Object?>{};
  final merged = <Object?>[];
  for (final MapEntry(:key, :value) in node.entries) {
    if (key == '<<') {
      merged.addAll(value is YamlList ? value : [value]);
    } else {
      map[key.toString()] = _plainYaml(value);
    }
  }
  for (final item in merged) {
    if (item is YamlMap) {
      for (final MapEntry(:key, :value) in _plainYamlMap(item).entries) {
        map.putIfAbsent(key, () => value);
      }
    }
  }
  return map;
}

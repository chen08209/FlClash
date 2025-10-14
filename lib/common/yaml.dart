import 'package:yaml_writer/yaml_writer.dart';

class Yaml {
  static Yaml? _instance;

  Yaml._internal();

  factory Yaml() {
    _instance ??= Yaml._internal();
    return _instance!;
  }

  String encode(Object? value) {
    return YamlWriter().convert(value);
  }
}

final yaml = Yaml();

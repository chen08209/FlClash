import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/constant.dart';
import 'package:path/path.dart' as p;

final class CoreManifest {
  const CoreManifest._();

  static Future<String?> readCoreSha256({String? path}) async {
    try {
      final file = File(path ?? _defaultPath());
      final value = jsonDecode(await file.readAsString());
      if (value is! Map) return null;
      final coreSha256 = value['coreSha256'];
      if (coreSha256 is! String ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(coreSha256)) {
        return null;
      }
      return coreSha256;
    } on Object {
      return null;
    }
  }

  static String _defaultPath() {
    return p.join(p.dirname(Platform.resolvedExecutable), coreManifestName);
  }
}

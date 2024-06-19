import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'constant.dart';

class AppPath {
  static AppPath? _instance;
  Completer<Directory> cacheDir = Completer();

  // Future<Directory> _createDesktopCacheDir() async {
  //   final path = join(dirname(Platform.resolvedExecutable), 'cache');
  //   final dir = Directory(path);
  //   if (await dir.exists()) {
  //     await dir.create(recursive: true);
  //   }
  //   return dir;
  // }

  AppPath._internal() {
    getApplicationSupportDirectory().then((value) {
      cacheDir.complete(value);
    });
    // if (Platform.isAndroid) {
    //   getApplicationSupportDirectory().then((value) {
    //     cacheDir.complete(value);
    //   });
    // } else {
    //   _createDesktopCacheDir().then((value) {
    //     cacheDir.complete(value);
    //   });
    // }
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  Future<String> getHomeDirPath() async {
    final directory = await cacheDir.future;
    return directory.path;
  }

  Future<String> getProfilesPath() async {
    final directory = await cacheDir.future;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String?> getProfilePath(String? id) async {
    if (id == null) return null;
    final directory = await getProfilesPath();
    return join(directory, "$id.yaml");
  }
}

final appPath = AppPath();

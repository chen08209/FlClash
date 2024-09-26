import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'constant.dart';

class AppPath {
  static AppPath? _instance;
  Completer<Directory> dataDir = Completer();
  Completer<Directory> downloadDir = Completer();
  Completer<Directory> tempDir = Completer();
  late String appDirPath;

  // Future<Directory> _createDesktopCacheDir() async {
  //   final dir = Directory(path);
  //   if (await dir.exists()) {
  //     await dir.create(recursive: true);
  //   }
  //   return dir;
  // }

  AppPath._internal() {
    appDirPath = join(dirname(Platform.resolvedExecutable));
    getApplicationSupportDirectory().then((value) {
      dataDir.complete(value);
    });
    getTemporaryDirectory().then((value){
     tempDir.complete(value);
    });
    getDownloadsDirectory().then((value) {
      downloadDir.complete(value);
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

  Future<String> getDownloadDirPath() async {
    final directory = await downloadDir.future;
    return directory.path;
  }

  Future<String> getHomeDirPath() async {
    final directory = await dataDir.future;
    return directory.path;
  }

  Future<String> getProfilesPath() async {
    final directory = await dataDir.future;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String?> getProfilePath(String? id) async {
    if (id == null) return null;
    final directory = await getProfilesPath();
    return join(directory, "$id.yaml");
  }

  Future<String> get tempPath async {
    final directory = await tempDir.future;
    return directory.path;
  }
}

final appPath = AppPath();

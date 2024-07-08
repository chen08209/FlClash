import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'core.dart';

class ClashService {
  Future<void> initGeo() async {
    final homePath = await appPath.getHomeDirPath();
    final homeDir = Directory(homePath);
    final isExists = await homeDir.exists();
    if (!isExists) {
      await homeDir.create(recursive: true);
    }
    const geoFileNameList = [
      mmdbFileName,
      geoIpFileName,
      geoSiteFileName,
      asnFileName,
    ];
    try {
      for (final geoFileName in geoFileNameList) {
        final geoFile = File(
          join(homePath, geoFileName),
        );
        final isExists = await geoFile.exists();
        if (isExists) {
          continue;
        }
        final data = await rootBundle.load('assets/data/$geoFileName');
        List<int> bytes = data.buffer.asUint8List();
        await geoFile.writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      debugPrint("$e");
      exit(0);
    }
  }

  Future<bool> init({
    required ClashConfig clashConfig,
    required Config config,
  }) async {
    await initGeo();
    final homeDirPath = await appPath.getHomeDirPath();
    final isInit = clashCore.init(homeDirPath);
    return isInit;
  }
}

final clashService = ClashService();

import 'dart:io';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/services.dart';
import 'core.dart';

class ClashService {
  Future<bool> initMmdb() async {
    final mmdbPath = await appPath.getMMDBPath();
    var mmdbFile = File(mmdbPath);
    final isExists = await mmdbFile.exists();
    if (isExists) return true;
    try {
      mmdbFile = await mmdbFile.create(recursive: true);
      ByteData data = await rootBundle.load('assets/data/geoip.metadb');
      List<int> bytes = data.buffer.asUint8List();
      await mmdbFile.writeAsBytes(bytes, flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> init({
    required ClashConfig clashConfig,
    required Config config,
  }) async {
    final isInitMmdb = await initMmdb();
    if (!isInitMmdb) return false;
    final homeDirPath = await appPath.getHomeDirPath();
    final isInit = clashCore.init(homeDirPath);
    return isInit;
  }
}

final clashService = ClashService();

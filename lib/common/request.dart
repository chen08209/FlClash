import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:http/http.dart';
import '../models/models.dart';

class Request {
  static Future<Result<Response>> getFileResponseForUrl(String url) async {
    final headers = {'User-Agent': appConstant.name};
    try {
      final response = await get(Uri.parse(url), headers: headers).timeout(
        appConstant.httpTimeoutDuration,
      );
      return Result.success(data: response);
    } catch (err) {
      return Result.error(message: err.toString());
    }
  }

  static Future<Result<String>> checkForUpdate() async {
    final response = await get(
      Uri.parse(
        "https://api.github.com/repos/${appConstant.repository}/releases/latest",
      ),
    );
    if (response.statusCode != 200) return Result.error();
    final body = json.decode(response.body);
    final remoteVersion = body['tag_name'];
    final packageInfo = await appPackage.packageInfoCompleter.future;
    final version = packageInfo.version;
    final hasUpdate =
        other.compareVersions(remoteVersion.replaceAll('v', ''), version) > 0;
    if (!hasUpdate) return Result.error();
    return Result.success(data: body['body']);
  }
}

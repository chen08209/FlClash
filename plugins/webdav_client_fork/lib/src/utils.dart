import 'dart:convert';
import 'dart:math' as math;

import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'md5.dart';

const months = {
  'jan': '01',
  'feb': '02',
  'mar': '03',
  'apr': '04',
  'may': '05',
  'jun': '06',
  'jul': '07',
  'aug': '08',
  'sep': '09',
  'oct': '10',
  'nov': '11',
  'dec': '12',
};

// md5
String md5Hash(String data) {
  MD5 hasher = new MD5()..add(Utf8Encoder().convert(data));
  var bytes = hasher.close();
  var result = new StringBuffer();
  for (var part in bytes) {
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

DateTime? str2LocalTime(String? str) {
  if (str == null) {
    return null;
  }
  var s = str.toLowerCase();
  if (!s.endsWith('gmt')) {
    return null;
  }
  var list = s.split(' ');
  if (list.length != 6) {
    return null;
  }
  var month = months[list[2]];
  if (month == null) {
    return null;
  }

  return DateTime.parse(
          '${list[3]}-$month-${list[1].padLeft(2, '0')}T${list[4]}Z')
      .toLocal();
}

// create response error
DioError newResponseError(Response resp) {
  return DioError(
      requestOptions: resp.requestOptions,
      response: resp,
      type: DioErrorType.badResponse,
      error: resp.statusMessage);
}

// create xml error
DioError newXmlError(dynamic err) {
  return DioError(
    requestOptions: RequestOptions(path: '/'),
    type: DioErrorType.unknown,
    error: err,
  );
}

// 16进制字符串随机数
String computeNonce() {
  final rnd = math.Random.secure();
  final values = List<int>.generate(16, (i) => rnd.nextInt(256));
  return hex.encode(values).substring(0, 16);
}

String trim(String str, [String? chars]) {
  RegExp pattern =
      (chars != null) ? RegExp('^[$chars]+|[$chars]+\$') : RegExp(r'^\s+|\s+$');
  return str.replaceAll(pattern, '');
}

String ltrim(String str, [String? chars]) {
  var pattern = chars != null ? new RegExp('^[$chars]+') : new RegExp(r'^\s+');
  return str.replaceAll(pattern, '');
}

String rtrim(String str, [String? chars]) {
  var pattern = chars != null ? new RegExp('[$chars]+\$') : new RegExp(r'\s+$');
  return str.replaceAll(pattern, '');
}

// 添加 '/' 后缀
String fixSlash(String s) {
  if (!s.endsWith('/')) {
    return s + '/';
  }
  return s;
}

// 添加 '/' 前后缀
String fixSlashes(String s) {
  if (!s.startsWith('/')) {
    s = '/${s}';
  }
  return fixSlash(s);
}

// 使用 '/' 连接path
String join(String path0, String path1) {
  return rtrim(path0, '/') + '/' + ltrim(path1, '/');
}

// 获取文件名
String path2Name(String path) {
  var str = rtrim(path, '/');
  var index = str.lastIndexOf('/');
  if (index > -1) {
    str = str.substring(index + 1);
  }
  if (str == '') {
    return '/';
  }
  return str;
}

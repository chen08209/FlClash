import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/enum.dart';

part 'generated/proxy.g.dart';

part 'generated/proxy.freezed.dart';

typedef ProxyMap = Map<String, Proxy>;

@freezed
class Group with _$Group {
  const factory Group({
    required GroupType type,
    @Default([]) List<Proxy> all,
    String? now,
    bool? hidden,
    required String name,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
}

extension GroupExt on Group {
  String get realNow => now ?? "";

  String getCurrentSelectedName(String proxyName) {
    if (type == GroupType.URLTest) {
      return realNow.isNotEmpty ? realNow : proxyName;
    }
    return proxyName.isNotEmpty ? proxyName : realNow;
  }
}

@freezed
class Proxy with _$Proxy {
  const factory Proxy({
    required String name,
    required String type,
    String? now,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

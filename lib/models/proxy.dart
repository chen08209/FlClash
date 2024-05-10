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
    required String name,
  }) = _Group;

  factory Group.fromJson(Map<String, Object?> json) => _$GroupFromJson(json);
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

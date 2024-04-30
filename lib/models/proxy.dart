import 'package:freezed_annotation/freezed_annotation.dart';

import '../enum/enum.dart';

part 'generated/proxy.g.dart';

part 'generated/proxy.freezed.dart';

typedef DelayMap = Map<String, int?>;

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
    @Default("") String name,
    @Default("") String type,
  }) = _Proxy;

  factory Proxy.fromJson(Map<String, Object?> json) => _$ProxyFromJson(json);
}

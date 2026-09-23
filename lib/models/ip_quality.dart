import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/ip_quality.freezed.dart';

@freezed
abstract class IpQuality with _$IpQuality {
  const factory IpQuality({
    required String ip,
    required IpQualitySource source,
    required IpType type,
    String? organization,
    int? asn,
    @Default(false) bool isProxy,
    @Default(false) bool isVpn,
    @Default(false) bool isTor,
    @Default(false) bool isAbuser,
  }) = _IpQuality;
}

extension IpQualityExt on IpQuality {
  IpQualityLevel get level {
    if (isTor || isAbuser) {
      return IpQualityLevel.risky;
    }
    return switch (type) {
      IpType.residential ||
      IpType.mobile ||
      IpType.business => IpQualityLevel.good,
      IpType.hosting => IpQualityLevel.normal,
    };
  }
}

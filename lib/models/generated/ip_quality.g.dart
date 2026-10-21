// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../ip_quality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IpQuality _$IpQualityFromJson(Map<String, dynamic> json) => _IpQuality(
  ip: json['ip'] as String,
  source: $enumDecode(_$IpQualitySourceEnumMap, json['source']),
  type: $enumDecode(_$IpTypeEnumMap, json['type']),
  organization: json['organization'] as String?,
  asn: (json['asn'] as num?)?.toInt(),
  isProxy: json['isProxy'] as bool? ?? false,
  isVpn: json['isVpn'] as bool? ?? false,
  isTor: json['isTor'] as bool? ?? false,
  isAbuser: json['isAbuser'] as bool? ?? false,
);

Map<String, dynamic> _$IpQualityToJson(_IpQuality instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'source': _$IpQualitySourceEnumMap[instance.source]!,
      'type': _$IpTypeEnumMap[instance.type]!,
      'organization': instance.organization,
      'asn': instance.asn,
      'isProxy': instance.isProxy,
      'isVpn': instance.isVpn,
      'isTor': instance.isTor,
      'isAbuser': instance.isAbuser,
    };

const _$IpQualitySourceEnumMap = {
  IpQualitySource.identMe: 'identMe',
  IpQualitySource.ipApiCom: 'ipApiCom',
  IpQualitySource.ipQuery: 'ipQuery',
  IpQualitySource.ipLocate: 'ipLocate',
  IpQualitySource.proxyCheck: 'proxyCheck',
  IpQualitySource.ipApiIs: 'ipApiIs',
};

const _$IpTypeEnumMap = {
  IpType.residential: 'residential',
  IpType.mobile: 'mobile',
  IpType.business: 'business',
  IpType.hosting: 'hosting',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetadataImpl _$$MetadataImplFromJson(Map<String, dynamic> json) =>
    _$MetadataImpl(
      uid: (json['uid'] as num).toInt(),
      network: json['network'] as String,
      sourceIP: json['sourceIP'] as String,
      sourcePort: json['sourcePort'] as String,
      destinationIP: json['destinationIP'] as String,
      destinationPort: json['destinationPort'] as String,
      host: json['host'] as String,
      process: json['process'] as String,
      remoteDestination: json['remoteDestination'] as String,
    );

Map<String, dynamic> _$$MetadataImplToJson(_$MetadataImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'network': instance.network,
      'sourceIP': instance.sourceIP,
      'sourcePort': instance.sourcePort,
      'destinationIP': instance.destinationIP,
      'destinationPort': instance.destinationPort,
      'host': instance.host,
      'process': instance.process,
      'remoteDestination': instance.remoteDestination,
    };

_$ConnectionImpl _$$ConnectionImplFromJson(Map<String, dynamic> json) =>
    _$ConnectionImpl(
      id: json['id'] as String,
      upload: json['upload'] as num?,
      download: json['download'] as num?,
      start: DateTime.parse(json['start'] as String),
      metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
      chains:
          (json['chains'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$ConnectionImplToJson(_$ConnectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'upload': instance.upload,
      'download': instance.download,
      'start': instance.start.toIso8601String(),
      'metadata': instance.metadata,
      'chains': instance.chains,
    };

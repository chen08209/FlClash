import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/connection.g.dart';

part 'generated/connection.freezed.dart';

@freezed
class Metadata with _$Metadata {
  const factory Metadata({
    required int uid,
    required String network,
    required String sourceIP,
    required String sourcePort,
    required String destinationIP,
    required String destinationPort,
    required String host,
    required String process,
    required String remoteDestination,
  }) = _Metadata;

  factory Metadata.fromJson(Map<String, Object?> json) =>
      _$MetadataFromJson(json);
}

@freezed
class Connection with _$Connection{
  const factory Connection({
    required String id,
    num? upload,
    num? download,
    required DateTime start,
    required Metadata metadata,
    required List<String> chains,
  }) = _Connection;

  factory Connection.fromJson(Map<String, Object?> json) =>
      _$ConnectionFromJson(json);
}

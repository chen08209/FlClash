// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Metadata _$MetadataFromJson(Map<String, dynamic> json) {
  return _Metadata.fromJson(json);
}

/// @nodoc
mixin _$Metadata {
  int get uid => throw _privateConstructorUsedError;
  String get network => throw _privateConstructorUsedError;
  String get sourceIP => throw _privateConstructorUsedError;
  String get sourcePort => throw _privateConstructorUsedError;
  String get destinationIP => throw _privateConstructorUsedError;
  String get destinationPort => throw _privateConstructorUsedError;
  String get host => throw _privateConstructorUsedError;
  String get process => throw _privateConstructorUsedError;
  String get remoteDestination => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MetadataCopyWith<Metadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MetadataCopyWith<$Res> {
  factory $MetadataCopyWith(Metadata value, $Res Function(Metadata) then) =
      _$MetadataCopyWithImpl<$Res, Metadata>;
  @useResult
  $Res call(
      {int uid,
      String network,
      String sourceIP,
      String sourcePort,
      String destinationIP,
      String destinationPort,
      String host,
      String process,
      String remoteDestination});
}

/// @nodoc
class _$MetadataCopyWithImpl<$Res, $Val extends Metadata>
    implements $MetadataCopyWith<$Res> {
  _$MetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? network = null,
    Object? sourceIP = null,
    Object? sourcePort = null,
    Object? destinationIP = null,
    Object? destinationPort = null,
    Object? host = null,
    Object? process = null,
    Object? remoteDestination = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as int,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String,
      sourceIP: null == sourceIP
          ? _value.sourceIP
          : sourceIP // ignore: cast_nullable_to_non_nullable
              as String,
      sourcePort: null == sourcePort
          ? _value.sourcePort
          : sourcePort // ignore: cast_nullable_to_non_nullable
              as String,
      destinationIP: null == destinationIP
          ? _value.destinationIP
          : destinationIP // ignore: cast_nullable_to_non_nullable
              as String,
      destinationPort: null == destinationPort
          ? _value.destinationPort
          : destinationPort // ignore: cast_nullable_to_non_nullable
              as String,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      process: null == process
          ? _value.process
          : process // ignore: cast_nullable_to_non_nullable
              as String,
      remoteDestination: null == remoteDestination
          ? _value.remoteDestination
          : remoteDestination // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MetadataImplCopyWith<$Res>
    implements $MetadataCopyWith<$Res> {
  factory _$$MetadataImplCopyWith(
          _$MetadataImpl value, $Res Function(_$MetadataImpl) then) =
      __$$MetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int uid,
      String network,
      String sourceIP,
      String sourcePort,
      String destinationIP,
      String destinationPort,
      String host,
      String process,
      String remoteDestination});
}

/// @nodoc
class __$$MetadataImplCopyWithImpl<$Res>
    extends _$MetadataCopyWithImpl<$Res, _$MetadataImpl>
    implements _$$MetadataImplCopyWith<$Res> {
  __$$MetadataImplCopyWithImpl(
      _$MetadataImpl _value, $Res Function(_$MetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? network = null,
    Object? sourceIP = null,
    Object? sourcePort = null,
    Object? destinationIP = null,
    Object? destinationPort = null,
    Object? host = null,
    Object? process = null,
    Object? remoteDestination = null,
  }) {
    return _then(_$MetadataImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as int,
      network: null == network
          ? _value.network
          : network // ignore: cast_nullable_to_non_nullable
              as String,
      sourceIP: null == sourceIP
          ? _value.sourceIP
          : sourceIP // ignore: cast_nullable_to_non_nullable
              as String,
      sourcePort: null == sourcePort
          ? _value.sourcePort
          : sourcePort // ignore: cast_nullable_to_non_nullable
              as String,
      destinationIP: null == destinationIP
          ? _value.destinationIP
          : destinationIP // ignore: cast_nullable_to_non_nullable
              as String,
      destinationPort: null == destinationPort
          ? _value.destinationPort
          : destinationPort // ignore: cast_nullable_to_non_nullable
              as String,
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      process: null == process
          ? _value.process
          : process // ignore: cast_nullable_to_non_nullable
              as String,
      remoteDestination: null == remoteDestination
          ? _value.remoteDestination
          : remoteDestination // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MetadataImpl implements _Metadata {
  const _$MetadataImpl(
      {required this.uid,
      required this.network,
      required this.sourceIP,
      required this.sourcePort,
      required this.destinationIP,
      required this.destinationPort,
      required this.host,
      required this.process,
      required this.remoteDestination});

  factory _$MetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MetadataImplFromJson(json);

  @override
  final int uid;
  @override
  final String network;
  @override
  final String sourceIP;
  @override
  final String sourcePort;
  @override
  final String destinationIP;
  @override
  final String destinationPort;
  @override
  final String host;
  @override
  final String process;
  @override
  final String remoteDestination;

  @override
  String toString() {
    return 'Metadata(uid: $uid, network: $network, sourceIP: $sourceIP, sourcePort: $sourcePort, destinationIP: $destinationIP, destinationPort: $destinationPort, host: $host, process: $process, remoteDestination: $remoteDestination)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MetadataImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.network, network) || other.network == network) &&
            (identical(other.sourceIP, sourceIP) ||
                other.sourceIP == sourceIP) &&
            (identical(other.sourcePort, sourcePort) ||
                other.sourcePort == sourcePort) &&
            (identical(other.destinationIP, destinationIP) ||
                other.destinationIP == destinationIP) &&
            (identical(other.destinationPort, destinationPort) ||
                other.destinationPort == destinationPort) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.process, process) || other.process == process) &&
            (identical(other.remoteDestination, remoteDestination) ||
                other.remoteDestination == remoteDestination));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      network,
      sourceIP,
      sourcePort,
      destinationIP,
      destinationPort,
      host,
      process,
      remoteDestination);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MetadataImplCopyWith<_$MetadataImpl> get copyWith =>
      __$$MetadataImplCopyWithImpl<_$MetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MetadataImplToJson(
      this,
    );
  }
}

abstract class _Metadata implements Metadata {
  const factory _Metadata(
      {required final int uid,
      required final String network,
      required final String sourceIP,
      required final String sourcePort,
      required final String destinationIP,
      required final String destinationPort,
      required final String host,
      required final String process,
      required final String remoteDestination}) = _$MetadataImpl;

  factory _Metadata.fromJson(Map<String, dynamic> json) =
      _$MetadataImpl.fromJson;

  @override
  int get uid;
  @override
  String get network;
  @override
  String get sourceIP;
  @override
  String get sourcePort;
  @override
  String get destinationIP;
  @override
  String get destinationPort;
  @override
  String get host;
  @override
  String get process;
  @override
  String get remoteDestination;
  @override
  @JsonKey(ignore: true)
  _$$MetadataImplCopyWith<_$MetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Connection _$ConnectionFromJson(Map<String, dynamic> json) {
  return _Connection.fromJson(json);
}

/// @nodoc
mixin _$Connection {
  String get id => throw _privateConstructorUsedError;
  num? get upload => throw _privateConstructorUsedError;
  num? get download => throw _privateConstructorUsedError;
  DateTime get start => throw _privateConstructorUsedError;
  Metadata get metadata => throw _privateConstructorUsedError;
  List<String> get chains => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConnectionCopyWith<Connection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionCopyWith<$Res> {
  factory $ConnectionCopyWith(
          Connection value, $Res Function(Connection) then) =
      _$ConnectionCopyWithImpl<$Res, Connection>;
  @useResult
  $Res call(
      {String id,
      num? upload,
      num? download,
      DateTime start,
      Metadata metadata,
      List<String> chains});

  $MetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class _$ConnectionCopyWithImpl<$Res, $Val extends Connection>
    implements $ConnectionCopyWith<$Res> {
  _$ConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? upload = freezed,
    Object? download = freezed,
    Object? start = null,
    Object? metadata = null,
    Object? chains = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      upload: freezed == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as num?,
      download: freezed == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as num?,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Metadata,
      chains: null == chains
          ? _value.chains
          : chains // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MetadataCopyWith<$Res> get metadata {
    return $MetadataCopyWith<$Res>(_value.metadata, (value) {
      return _then(_value.copyWith(metadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConnectionImplCopyWith<$Res>
    implements $ConnectionCopyWith<$Res> {
  factory _$$ConnectionImplCopyWith(
          _$ConnectionImpl value, $Res Function(_$ConnectionImpl) then) =
      __$$ConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      num? upload,
      num? download,
      DateTime start,
      Metadata metadata,
      List<String> chains});

  @override
  $MetadataCopyWith<$Res> get metadata;
}

/// @nodoc
class __$$ConnectionImplCopyWithImpl<$Res>
    extends _$ConnectionCopyWithImpl<$Res, _$ConnectionImpl>
    implements _$$ConnectionImplCopyWith<$Res> {
  __$$ConnectionImplCopyWithImpl(
      _$ConnectionImpl _value, $Res Function(_$ConnectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? upload = freezed,
    Object? download = freezed,
    Object? start = null,
    Object? metadata = null,
    Object? chains = null,
  }) {
    return _then(_$ConnectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      upload: freezed == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as num?,
      download: freezed == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as num?,
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Metadata,
      chains: null == chains
          ? _value._chains
          : chains // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionImpl implements _Connection {
  const _$ConnectionImpl(
      {required this.id,
      this.upload,
      this.download,
      required this.start,
      required this.metadata,
      required final List<String> chains})
      : _chains = chains;

  factory _$ConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionImplFromJson(json);

  @override
  final String id;
  @override
  final num? upload;
  @override
  final num? download;
  @override
  final DateTime start;
  @override
  final Metadata metadata;
  final List<String> _chains;
  @override
  List<String> get chains {
    if (_chains is EqualUnmodifiableListView) return _chains;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chains);
  }

  @override
  String toString() {
    return 'Connection(id: $id, upload: $upload, download: $download, start: $start, metadata: $metadata, chains: $chains)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.upload, upload) || other.upload == upload) &&
            (identical(other.download, download) ||
                other.download == download) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.metadata, metadata) ||
                other.metadata == metadata) &&
            const DeepCollectionEquality().equals(other._chains, _chains));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, upload, download, start,
      metadata, const DeepCollectionEquality().hash(_chains));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionImplCopyWith<_$ConnectionImpl> get copyWith =>
      __$$ConnectionImplCopyWithImpl<_$ConnectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionImplToJson(
      this,
    );
  }
}

abstract class _Connection implements Connection {
  const factory _Connection(
      {required final String id,
      final num? upload,
      final num? download,
      required final DateTime start,
      required final Metadata metadata,
      required final List<String> chains}) = _$ConnectionImpl;

  factory _Connection.fromJson(Map<String, dynamic> json) =
      _$ConnectionImpl.fromJson;

  @override
  String get id;
  @override
  num? get upload;
  @override
  num? get download;
  @override
  DateTime get start;
  @override
  Metadata get metadata;
  @override
  List<String> get chains;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionImplCopyWith<_$ConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConnectionsAndKeywords _$ConnectionsAndKeywordsFromJson(
    Map<String, dynamic> json) {
  return _ConnectionsAndKeywords.fromJson(json);
}

/// @nodoc
mixin _$ConnectionsAndKeywords {
  List<Connection> get connections => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConnectionsAndKeywordsCopyWith<ConnectionsAndKeywords> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionsAndKeywordsCopyWith<$Res> {
  factory $ConnectionsAndKeywordsCopyWith(ConnectionsAndKeywords value,
          $Res Function(ConnectionsAndKeywords) then) =
      _$ConnectionsAndKeywordsCopyWithImpl<$Res, ConnectionsAndKeywords>;
  @useResult
  $Res call({List<Connection> connections, List<String> keywords});
}

/// @nodoc
class _$ConnectionsAndKeywordsCopyWithImpl<$Res,
        $Val extends ConnectionsAndKeywords>
    implements $ConnectionsAndKeywordsCopyWith<$Res> {
  _$ConnectionsAndKeywordsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connections = null,
    Object? keywords = null,
  }) {
    return _then(_value.copyWith(
      connections: null == connections
          ? _value.connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<Connection>,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConnectionsAndKeywordsImplCopyWith<$Res>
    implements $ConnectionsAndKeywordsCopyWith<$Res> {
  factory _$$ConnectionsAndKeywordsImplCopyWith(
          _$ConnectionsAndKeywordsImpl value,
          $Res Function(_$ConnectionsAndKeywordsImpl) then) =
      __$$ConnectionsAndKeywordsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Connection> connections, List<String> keywords});
}

/// @nodoc
class __$$ConnectionsAndKeywordsImplCopyWithImpl<$Res>
    extends _$ConnectionsAndKeywordsCopyWithImpl<$Res,
        _$ConnectionsAndKeywordsImpl>
    implements _$$ConnectionsAndKeywordsImplCopyWith<$Res> {
  __$$ConnectionsAndKeywordsImplCopyWithImpl(
      _$ConnectionsAndKeywordsImpl _value,
      $Res Function(_$ConnectionsAndKeywordsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connections = null,
    Object? keywords = null,
  }) {
    return _then(_$ConnectionsAndKeywordsImpl(
      connections: null == connections
          ? _value._connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<Connection>,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConnectionsAndKeywordsImpl implements _ConnectionsAndKeywords {
  const _$ConnectionsAndKeywordsImpl(
      {final List<Connection> connections = const [],
      final List<String> keywords = const []})
      : _connections = connections,
        _keywords = keywords;

  factory _$ConnectionsAndKeywordsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConnectionsAndKeywordsImplFromJson(json);

  final List<Connection> _connections;
  @override
  @JsonKey()
  List<Connection> get connections {
    if (_connections is EqualUnmodifiableListView) return _connections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_connections);
  }

  final List<String> _keywords;
  @override
  @JsonKey()
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  String toString() {
    return 'ConnectionsAndKeywords(connections: $connections, keywords: $keywords)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionsAndKeywordsImpl &&
            const DeepCollectionEquality()
                .equals(other._connections, _connections) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_connections),
      const DeepCollectionEquality().hash(_keywords));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionsAndKeywordsImplCopyWith<_$ConnectionsAndKeywordsImpl>
      get copyWith => __$$ConnectionsAndKeywordsImplCopyWithImpl<
          _$ConnectionsAndKeywordsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConnectionsAndKeywordsImplToJson(
      this,
    );
  }
}

abstract class _ConnectionsAndKeywords implements ConnectionsAndKeywords {
  const factory _ConnectionsAndKeywords(
      {final List<Connection> connections,
      final List<String> keywords}) = _$ConnectionsAndKeywordsImpl;

  factory _ConnectionsAndKeywords.fromJson(Map<String, dynamic> json) =
      _$ConnectionsAndKeywordsImpl.fromJson;

  @override
  List<Connection> get connections;
  @override
  List<String> get keywords;
  @override
  @JsonKey(ignore: true)
  _$$ConnectionsAndKeywordsImplCopyWith<_$ConnectionsAndKeywordsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

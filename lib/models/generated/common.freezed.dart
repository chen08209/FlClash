// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NavigationItem {
  Icon get icon => throw _privateConstructorUsedError;
  PageLabel get label => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Widget get fragment => throw _privateConstructorUsedError;
  bool get keep => throw _privateConstructorUsedError;
  String? get path => throw _privateConstructorUsedError;
  List<NavigationItemMode> get modes => throw _privateConstructorUsedError;

  /// Create a copy of NavigationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NavigationItemCopyWith<NavigationItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NavigationItemCopyWith<$Res> {
  factory $NavigationItemCopyWith(
          NavigationItem value, $Res Function(NavigationItem) then) =
      _$NavigationItemCopyWithImpl<$Res, NavigationItem>;
  @useResult
  $Res call(
      {Icon icon,
      PageLabel label,
      String? description,
      Widget fragment,
      bool keep,
      String? path,
      List<NavigationItemMode> modes});
}

/// @nodoc
class _$NavigationItemCopyWithImpl<$Res, $Val extends NavigationItem>
    implements $NavigationItemCopyWith<$Res> {
  _$NavigationItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NavigationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? label = null,
    Object? description = freezed,
    Object? fragment = null,
    Object? keep = null,
    Object? path = freezed,
    Object? modes = null,
  }) {
    return _then(_value.copyWith(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as Icon,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as PageLabel,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      fragment: null == fragment
          ? _value.fragment
          : fragment // ignore: cast_nullable_to_non_nullable
              as Widget,
      keep: null == keep
          ? _value.keep
          : keep // ignore: cast_nullable_to_non_nullable
              as bool,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      modes: null == modes
          ? _value.modes
          : modes // ignore: cast_nullable_to_non_nullable
              as List<NavigationItemMode>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NavigationItemImplCopyWith<$Res>
    implements $NavigationItemCopyWith<$Res> {
  factory _$$NavigationItemImplCopyWith(_$NavigationItemImpl value,
          $Res Function(_$NavigationItemImpl) then) =
      __$$NavigationItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Icon icon,
      PageLabel label,
      String? description,
      Widget fragment,
      bool keep,
      String? path,
      List<NavigationItemMode> modes});
}

/// @nodoc
class __$$NavigationItemImplCopyWithImpl<$Res>
    extends _$NavigationItemCopyWithImpl<$Res, _$NavigationItemImpl>
    implements _$$NavigationItemImplCopyWith<$Res> {
  __$$NavigationItemImplCopyWithImpl(
      _$NavigationItemImpl _value, $Res Function(_$NavigationItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NavigationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? label = null,
    Object? description = freezed,
    Object? fragment = null,
    Object? keep = null,
    Object? path = freezed,
    Object? modes = null,
  }) {
    return _then(_$NavigationItemImpl(
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as Icon,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as PageLabel,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      fragment: null == fragment
          ? _value.fragment
          : fragment // ignore: cast_nullable_to_non_nullable
              as Widget,
      keep: null == keep
          ? _value.keep
          : keep // ignore: cast_nullable_to_non_nullable
              as bool,
      path: freezed == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      modes: null == modes
          ? _value._modes
          : modes // ignore: cast_nullable_to_non_nullable
              as List<NavigationItemMode>,
    ));
  }
}

/// @nodoc

class _$NavigationItemImpl implements _NavigationItem {
  const _$NavigationItemImpl(
      {required this.icon,
      required this.label,
      this.description,
      required this.fragment,
      this.keep = true,
      this.path,
      final List<NavigationItemMode> modes = const [
        NavigationItemMode.mobile,
        NavigationItemMode.desktop
      ]})
      : _modes = modes;

  @override
  final Icon icon;
  @override
  final PageLabel label;
  @override
  final String? description;
  @override
  final Widget fragment;
  @override
  @JsonKey()
  final bool keep;
  @override
  final String? path;
  final List<NavigationItemMode> _modes;
  @override
  @JsonKey()
  List<NavigationItemMode> get modes {
    if (_modes is EqualUnmodifiableListView) return _modes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modes);
  }

  @override
  String toString() {
    return 'NavigationItem(icon: $icon, label: $label, description: $description, fragment: $fragment, keep: $keep, path: $path, modes: $modes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NavigationItemImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.fragment, fragment) ||
                other.fragment == fragment) &&
            (identical(other.keep, keep) || other.keep == keep) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other._modes, _modes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, icon, label, description,
      fragment, keep, path, const DeepCollectionEquality().hash(_modes));

  /// Create a copy of NavigationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NavigationItemImplCopyWith<_$NavigationItemImpl> get copyWith =>
      __$$NavigationItemImplCopyWithImpl<_$NavigationItemImpl>(
          this, _$identity);
}

abstract class _NavigationItem implements NavigationItem {
  const factory _NavigationItem(
      {required final Icon icon,
      required final PageLabel label,
      final String? description,
      required final Widget fragment,
      final bool keep,
      final String? path,
      final List<NavigationItemMode> modes}) = _$NavigationItemImpl;

  @override
  Icon get icon;
  @override
  PageLabel get label;
  @override
  String? get description;
  @override
  Widget get fragment;
  @override
  bool get keep;
  @override
  String? get path;
  @override
  List<NavigationItemMode> get modes;

  /// Create a copy of NavigationItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NavigationItemImplCopyWith<_$NavigationItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Package _$PackageFromJson(Map<String, dynamic> json) {
  return _Package.fromJson(json);
}

/// @nodoc
mixin _$Package {
  String get packageName => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  bool get system => throw _privateConstructorUsedError;
  bool get internet => throw _privateConstructorUsedError;
  int get lastUpdateTime => throw _privateConstructorUsedError;

  /// Serializes this Package to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageCopyWith<Package> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageCopyWith<$Res> {
  factory $PackageCopyWith(Package value, $Res Function(Package) then) =
      _$PackageCopyWithImpl<$Res, Package>;
  @useResult
  $Res call(
      {String packageName,
      String label,
      bool system,
      bool internet,
      int lastUpdateTime});
}

/// @nodoc
class _$PackageCopyWithImpl<$Res, $Val extends Package>
    implements $PackageCopyWith<$Res> {
  _$PackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packageName = null,
    Object? label = null,
    Object? system = null,
    Object? internet = null,
    Object? lastUpdateTime = null,
  }) {
    return _then(_value.copyWith(
      packageName: null == packageName
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      system: null == system
          ? _value.system
          : system // ignore: cast_nullable_to_non_nullable
              as bool,
      internet: null == internet
          ? _value.internet
          : internet // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackageImplCopyWith<$Res> implements $PackageCopyWith<$Res> {
  factory _$$PackageImplCopyWith(
          _$PackageImpl value, $Res Function(_$PackageImpl) then) =
      __$$PackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String packageName,
      String label,
      bool system,
      bool internet,
      int lastUpdateTime});
}

/// @nodoc
class __$$PackageImplCopyWithImpl<$Res>
    extends _$PackageCopyWithImpl<$Res, _$PackageImpl>
    implements _$$PackageImplCopyWith<$Res> {
  __$$PackageImplCopyWithImpl(
      _$PackageImpl _value, $Res Function(_$PackageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? packageName = null,
    Object? label = null,
    Object? system = null,
    Object? internet = null,
    Object? lastUpdateTime = null,
  }) {
    return _then(_$PackageImpl(
      packageName: null == packageName
          ? _value.packageName
          : packageName // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      system: null == system
          ? _value.system
          : system // ignore: cast_nullable_to_non_nullable
              as bool,
      internet: null == internet
          ? _value.internet
          : internet // ignore: cast_nullable_to_non_nullable
              as bool,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageImpl implements _Package {
  const _$PackageImpl(
      {required this.packageName,
      required this.label,
      required this.system,
      required this.internet,
      required this.lastUpdateTime});

  factory _$PackageImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageImplFromJson(json);

  @override
  final String packageName;
  @override
  final String label;
  @override
  final bool system;
  @override
  final bool internet;
  @override
  final int lastUpdateTime;

  @override
  String toString() {
    return 'Package(packageName: $packageName, label: $label, system: $system, internet: $internet, lastUpdateTime: $lastUpdateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageImpl &&
            (identical(other.packageName, packageName) ||
                other.packageName == packageName) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.system, system) || other.system == system) &&
            (identical(other.internet, internet) ||
                other.internet == internet) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, packageName, label, system, internet, lastUpdateTime);

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageImplCopyWith<_$PackageImpl> get copyWith =>
      __$$PackageImplCopyWithImpl<_$PackageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageImplToJson(
      this,
    );
  }
}

abstract class _Package implements Package {
  const factory _Package(
      {required final String packageName,
      required final String label,
      required final bool system,
      required final bool internet,
      required final int lastUpdateTime}) = _$PackageImpl;

  factory _Package.fromJson(Map<String, dynamic> json) = _$PackageImpl.fromJson;

  @override
  String get packageName;
  @override
  String get label;
  @override
  bool get system;
  @override
  bool get internet;
  @override
  int get lastUpdateTime;

  /// Create a copy of Package
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageImplCopyWith<_$PackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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

  /// Serializes this Metadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Metadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Serializes this Connection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, upload, download, start,
      metadata, const DeepCollectionEquality().hash(_chains));

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of Connection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionImplCopyWith<_$ConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Log _$LogFromJson(Map<String, dynamic> json) {
  return _Log.fromJson(json);
}

/// @nodoc
mixin _$Log {
  @JsonKey(name: "LogLevel")
  LogLevel get logLevel => throw _privateConstructorUsedError;
  @JsonKey(name: "Payload")
  String get payload => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _logDateTime)
  String get dateTime => throw _privateConstructorUsedError;

  /// Serializes this Log to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Log
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogCopyWith<Log> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogCopyWith<$Res> {
  factory $LogCopyWith(Log value, $Res Function(Log) then) =
      _$LogCopyWithImpl<$Res, Log>;
  @useResult
  $Res call(
      {@JsonKey(name: "LogLevel") LogLevel logLevel,
      @JsonKey(name: "Payload") String payload,
      @JsonKey(fromJson: _logDateTime) String dateTime});
}

/// @nodoc
class _$LogCopyWithImpl<$Res, $Val extends Log> implements $LogCopyWith<$Res> {
  _$LogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Log
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logLevel = null,
    Object? payload = null,
    Object? dateTime = null,
  }) {
    return _then(_value.copyWith(
      logLevel: null == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogImplCopyWith<$Res> implements $LogCopyWith<$Res> {
  factory _$$LogImplCopyWith(_$LogImpl value, $Res Function(_$LogImpl) then) =
      __$$LogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "LogLevel") LogLevel logLevel,
      @JsonKey(name: "Payload") String payload,
      @JsonKey(fromJson: _logDateTime) String dateTime});
}

/// @nodoc
class __$$LogImplCopyWithImpl<$Res> extends _$LogCopyWithImpl<$Res, _$LogImpl>
    implements _$$LogImplCopyWith<$Res> {
  __$$LogImplCopyWithImpl(_$LogImpl _value, $Res Function(_$LogImpl) _then)
      : super(_value, _then);

  /// Create a copy of Log
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logLevel = null,
    Object? payload = null,
    Object? dateTime = null,
  }) {
    return _then(_$LogImpl(
      logLevel: null == logLevel
          ? _value.logLevel
          : logLevel // ignore: cast_nullable_to_non_nullable
              as LogLevel,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LogImpl implements _Log {
  const _$LogImpl(
      {@JsonKey(name: "LogLevel") this.logLevel = LogLevel.app,
      @JsonKey(name: "Payload") this.payload = "",
      @JsonKey(fromJson: _logDateTime) required this.dateTime});

  factory _$LogImpl.fromJson(Map<String, dynamic> json) =>
      _$$LogImplFromJson(json);

  @override
  @JsonKey(name: "LogLevel")
  final LogLevel logLevel;
  @override
  @JsonKey(name: "Payload")
  final String payload;
  @override
  @JsonKey(fromJson: _logDateTime)
  final String dateTime;

  @override
  String toString() {
    return 'Log(logLevel: $logLevel, payload: $payload, dateTime: $dateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogImpl &&
            (identical(other.logLevel, logLevel) ||
                other.logLevel == logLevel) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, logLevel, payload, dateTime);

  /// Create a copy of Log
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogImplCopyWith<_$LogImpl> get copyWith =>
      __$$LogImplCopyWithImpl<_$LogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LogImplToJson(
      this,
    );
  }
}

abstract class _Log implements Log {
  const factory _Log(
          {@JsonKey(name: "LogLevel") final LogLevel logLevel,
          @JsonKey(name: "Payload") final String payload,
          @JsonKey(fromJson: _logDateTime) required final String dateTime}) =
      _$LogImpl;

  factory _Log.fromJson(Map<String, dynamic> json) = _$LogImpl.fromJson;

  @override
  @JsonKey(name: "LogLevel")
  LogLevel get logLevel;
  @override
  @JsonKey(name: "Payload")
  String get payload;
  @override
  @JsonKey(fromJson: _logDateTime)
  String get dateTime;

  /// Create a copy of Log
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogImplCopyWith<_$LogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LogsState {
  List<Log> get logs => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;

  /// Create a copy of LogsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogsStateCopyWith<LogsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogsStateCopyWith<$Res> {
  factory $LogsStateCopyWith(LogsState value, $Res Function(LogsState) then) =
      _$LogsStateCopyWithImpl<$Res, LogsState>;
  @useResult
  $Res call(
      {List<Log> logs, List<String> keywords, String query, bool loading});
}

/// @nodoc
class _$LogsStateCopyWithImpl<$Res, $Val extends LogsState>
    implements $LogsStateCopyWith<$Res> {
  _$LogsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logs = null,
    Object? keywords = null,
    Object? query = null,
    Object? loading = null,
  }) {
    return _then(_value.copyWith(
      logs: null == logs
          ? _value.logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<Log>,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LogsStateImplCopyWith<$Res>
    implements $LogsStateCopyWith<$Res> {
  factory _$$LogsStateImplCopyWith(
          _$LogsStateImpl value, $Res Function(_$LogsStateImpl) then) =
      __$$LogsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Log> logs, List<String> keywords, String query, bool loading});
}

/// @nodoc
class __$$LogsStateImplCopyWithImpl<$Res>
    extends _$LogsStateCopyWithImpl<$Res, _$LogsStateImpl>
    implements _$$LogsStateImplCopyWith<$Res> {
  __$$LogsStateImplCopyWithImpl(
      _$LogsStateImpl _value, $Res Function(_$LogsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of LogsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? logs = null,
    Object? keywords = null,
    Object? query = null,
    Object? loading = null,
  }) {
    return _then(_$LogsStateImpl(
      logs: null == logs
          ? _value._logs
          : logs // ignore: cast_nullable_to_non_nullable
              as List<Log>,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$LogsStateImpl implements _LogsState {
  const _$LogsStateImpl(
      {final List<Log> logs = const [],
      final List<String> keywords = const [],
      this.query = "",
      this.loading = false})
      : _logs = logs,
        _keywords = keywords;

  final List<Log> _logs;
  @override
  @JsonKey()
  List<Log> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
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
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final bool loading;

  @override
  String toString() {
    return 'LogsState(logs: $logs, keywords: $keywords, query: $query, loading: $loading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogsStateImpl &&
            const DeepCollectionEquality().equals(other._logs, _logs) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.loading, loading) || other.loading == loading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_logs),
      const DeepCollectionEquality().hash(_keywords),
      query,
      loading);

  /// Create a copy of LogsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogsStateImplCopyWith<_$LogsStateImpl> get copyWith =>
      __$$LogsStateImplCopyWithImpl<_$LogsStateImpl>(this, _$identity);
}

abstract class _LogsState implements LogsState {
  const factory _LogsState(
      {final List<Log> logs,
      final List<String> keywords,
      final String query,
      final bool loading}) = _$LogsStateImpl;

  @override
  List<Log> get logs;
  @override
  List<String> get keywords;
  @override
  String get query;
  @override
  bool get loading;

  /// Create a copy of LogsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogsStateImplCopyWith<_$LogsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ConnectionsState {
  List<Connection> get connections => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionsStateCopyWith<ConnectionsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionsStateCopyWith<$Res> {
  factory $ConnectionsStateCopyWith(
          ConnectionsState value, $Res Function(ConnectionsState) then) =
      _$ConnectionsStateCopyWithImpl<$Res, ConnectionsState>;
  @useResult
  $Res call(
      {List<Connection> connections,
      List<String> keywords,
      String query,
      bool loading});
}

/// @nodoc
class _$ConnectionsStateCopyWithImpl<$Res, $Val extends ConnectionsState>
    implements $ConnectionsStateCopyWith<$Res> {
  _$ConnectionsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connections = null,
    Object? keywords = null,
    Object? query = null,
    Object? loading = null,
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
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConnectionsStateImplCopyWith<$Res>
    implements $ConnectionsStateCopyWith<$Res> {
  factory _$$ConnectionsStateImplCopyWith(_$ConnectionsStateImpl value,
          $Res Function(_$ConnectionsStateImpl) then) =
      __$$ConnectionsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Connection> connections,
      List<String> keywords,
      String query,
      bool loading});
}

/// @nodoc
class __$$ConnectionsStateImplCopyWithImpl<$Res>
    extends _$ConnectionsStateCopyWithImpl<$Res, _$ConnectionsStateImpl>
    implements _$$ConnectionsStateImplCopyWith<$Res> {
  __$$ConnectionsStateImplCopyWithImpl(_$ConnectionsStateImpl _value,
      $Res Function(_$ConnectionsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConnectionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? connections = null,
    Object? keywords = null,
    Object? query = null,
    Object? loading = null,
  }) {
    return _then(_$ConnectionsStateImpl(
      connections: null == connections
          ? _value._connections
          : connections // ignore: cast_nullable_to_non_nullable
              as List<Connection>,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ConnectionsStateImpl implements _ConnectionsState {
  const _$ConnectionsStateImpl(
      {final List<Connection> connections = const [],
      final List<String> keywords = const [],
      this.query = "",
      this.loading = false})
      : _connections = connections,
        _keywords = keywords;

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
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final bool loading;

  @override
  String toString() {
    return 'ConnectionsState(connections: $connections, keywords: $keywords, query: $query, loading: $loading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._connections, _connections) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.loading, loading) || other.loading == loading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_connections),
      const DeepCollectionEquality().hash(_keywords),
      query,
      loading);

  /// Create a copy of ConnectionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionsStateImplCopyWith<_$ConnectionsStateImpl> get copyWith =>
      __$$ConnectionsStateImplCopyWithImpl<_$ConnectionsStateImpl>(
          this, _$identity);
}

abstract class _ConnectionsState implements ConnectionsState {
  const factory _ConnectionsState(
      {final List<Connection> connections,
      final List<String> keywords,
      final String query,
      final bool loading}) = _$ConnectionsStateImpl;

  @override
  List<Connection> get connections;
  @override
  List<String> get keywords;
  @override
  String get query;
  @override
  bool get loading;

  /// Create a copy of ConnectionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionsStateImplCopyWith<_$ConnectionsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DAV _$DAVFromJson(Map<String, dynamic> json) {
  return _DAV.fromJson(json);
}

/// @nodoc
mixin _$DAV {
  String get uri => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;

  /// Serializes this DAV to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DAV
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DAVCopyWith<DAV> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DAVCopyWith<$Res> {
  factory $DAVCopyWith(DAV value, $Res Function(DAV) then) =
      _$DAVCopyWithImpl<$Res, DAV>;
  @useResult
  $Res call({String uri, String user, String password, String fileName});
}

/// @nodoc
class _$DAVCopyWithImpl<$Res, $Val extends DAV> implements $DAVCopyWith<$Res> {
  _$DAVCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DAV
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? user = null,
    Object? password = null,
    Object? fileName = null,
  }) {
    return _then(_value.copyWith(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DAVImplCopyWith<$Res> implements $DAVCopyWith<$Res> {
  factory _$$DAVImplCopyWith(_$DAVImpl value, $Res Function(_$DAVImpl) then) =
      __$$DAVImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, String user, String password, String fileName});
}

/// @nodoc
class __$$DAVImplCopyWithImpl<$Res> extends _$DAVCopyWithImpl<$Res, _$DAVImpl>
    implements _$$DAVImplCopyWith<$Res> {
  __$$DAVImplCopyWithImpl(_$DAVImpl _value, $Res Function(_$DAVImpl) _then)
      : super(_value, _then);

  /// Create a copy of DAV
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? user = null,
    Object? password = null,
    Object? fileName = null,
  }) {
    return _then(_$DAVImpl(
      uri: null == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DAVImpl implements _DAV {
  const _$DAVImpl(
      {required this.uri,
      required this.user,
      required this.password,
      this.fileName = defaultDavFileName});

  factory _$DAVImpl.fromJson(Map<String, dynamic> json) =>
      _$$DAVImplFromJson(json);

  @override
  final String uri;
  @override
  final String user;
  @override
  final String password;
  @override
  @JsonKey()
  final String fileName;

  @override
  String toString() {
    return 'DAV(uri: $uri, user: $user, password: $password, fileName: $fileName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DAVImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uri, user, password, fileName);

  /// Create a copy of DAV
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DAVImplCopyWith<_$DAVImpl> get copyWith =>
      __$$DAVImplCopyWithImpl<_$DAVImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DAVImplToJson(
      this,
    );
  }
}

abstract class _DAV implements DAV {
  const factory _DAV(
      {required final String uri,
      required final String user,
      required final String password,
      final String fileName}) = _$DAVImpl;

  factory _DAV.fromJson(Map<String, dynamic> json) = _$DAVImpl.fromJson;

  @override
  String get uri;
  @override
  String get user;
  @override
  String get password;
  @override
  String get fileName;

  /// Create a copy of DAV
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DAVImplCopyWith<_$DAVImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FileInfo {
  int get size => throw _privateConstructorUsedError;
  DateTime get lastModified => throw _privateConstructorUsedError;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FileInfoCopyWith<FileInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileInfoCopyWith<$Res> {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) then) =
      _$FileInfoCopyWithImpl<$Res, FileInfo>;
  @useResult
  $Res call({int size, DateTime lastModified});
}

/// @nodoc
class _$FileInfoCopyWithImpl<$Res, $Val extends FileInfo>
    implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? lastModified = null,
  }) {
    return _then(_value.copyWith(
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      lastModified: null == lastModified
          ? _value.lastModified
          : lastModified // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FileInfoImplCopyWith<$Res>
    implements $FileInfoCopyWith<$Res> {
  factory _$$FileInfoImplCopyWith(
          _$FileInfoImpl value, $Res Function(_$FileInfoImpl) then) =
      __$$FileInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int size, DateTime lastModified});
}

/// @nodoc
class __$$FileInfoImplCopyWithImpl<$Res>
    extends _$FileInfoCopyWithImpl<$Res, _$FileInfoImpl>
    implements _$$FileInfoImplCopyWith<$Res> {
  __$$FileInfoImplCopyWithImpl(
      _$FileInfoImpl _value, $Res Function(_$FileInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? lastModified = null,
  }) {
    return _then(_$FileInfoImpl(
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      lastModified: null == lastModified
          ? _value.lastModified
          : lastModified // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$FileInfoImpl implements _FileInfo {
  const _$FileInfoImpl({required this.size, required this.lastModified});

  @override
  final int size;
  @override
  final DateTime lastModified;

  @override
  String toString() {
    return 'FileInfo(size: $size, lastModified: $lastModified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileInfoImpl &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.lastModified, lastModified) ||
                other.lastModified == lastModified));
  }

  @override
  int get hashCode => Object.hash(runtimeType, size, lastModified);

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      __$$FileInfoImplCopyWithImpl<_$FileInfoImpl>(this, _$identity);
}

abstract class _FileInfo implements FileInfo {
  const factory _FileInfo(
      {required final int size,
      required final DateTime lastModified}) = _$FileInfoImpl;

  @override
  int get size;
  @override
  DateTime get lastModified;

  /// Create a copy of FileInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FileInfoImplCopyWith<_$FileInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) {
  return _VersionInfo.fromJson(json);
}

/// @nodoc
mixin _$VersionInfo {
  String get clashName => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  /// Serializes this VersionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VersionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VersionInfoCopyWith<VersionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VersionInfoCopyWith<$Res> {
  factory $VersionInfoCopyWith(
          VersionInfo value, $Res Function(VersionInfo) then) =
      _$VersionInfoCopyWithImpl<$Res, VersionInfo>;
  @useResult
  $Res call({String clashName, String version});
}

/// @nodoc
class _$VersionInfoCopyWithImpl<$Res, $Val extends VersionInfo>
    implements $VersionInfoCopyWith<$Res> {
  _$VersionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VersionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clashName = null,
    Object? version = null,
  }) {
    return _then(_value.copyWith(
      clashName: null == clashName
          ? _value.clashName
          : clashName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VersionInfoImplCopyWith<$Res>
    implements $VersionInfoCopyWith<$Res> {
  factory _$$VersionInfoImplCopyWith(
          _$VersionInfoImpl value, $Res Function(_$VersionInfoImpl) then) =
      __$$VersionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String clashName, String version});
}

/// @nodoc
class __$$VersionInfoImplCopyWithImpl<$Res>
    extends _$VersionInfoCopyWithImpl<$Res, _$VersionInfoImpl>
    implements _$$VersionInfoImplCopyWith<$Res> {
  __$$VersionInfoImplCopyWithImpl(
      _$VersionInfoImpl _value, $Res Function(_$VersionInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of VersionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clashName = null,
    Object? version = null,
  }) {
    return _then(_$VersionInfoImpl(
      clashName: null == clashName
          ? _value.clashName
          : clashName // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VersionInfoImpl implements _VersionInfo {
  const _$VersionInfoImpl({this.clashName = "", this.version = ""});

  factory _$VersionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VersionInfoImplFromJson(json);

  @override
  @JsonKey()
  final String clashName;
  @override
  @JsonKey()
  final String version;

  @override
  String toString() {
    return 'VersionInfo(clashName: $clashName, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VersionInfoImpl &&
            (identical(other.clashName, clashName) ||
                other.clashName == clashName) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clashName, version);

  /// Create a copy of VersionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VersionInfoImplCopyWith<_$VersionInfoImpl> get copyWith =>
      __$$VersionInfoImplCopyWithImpl<_$VersionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VersionInfoImplToJson(
      this,
    );
  }
}

abstract class _VersionInfo implements VersionInfo {
  const factory _VersionInfo({final String clashName, final String version}) =
      _$VersionInfoImpl;

  factory _VersionInfo.fromJson(Map<String, dynamic> json) =
      _$VersionInfoImpl.fromJson;

  @override
  String get clashName;
  @override
  String get version;

  /// Create a copy of VersionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VersionInfoImplCopyWith<_$VersionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Proxy _$ProxyFromJson(Map<String, dynamic> json) {
  return _Proxy.fromJson(json);
}

/// @nodoc
mixin _$Proxy {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get now => throw _privateConstructorUsedError;

  /// Serializes this Proxy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Proxy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProxyCopyWith<Proxy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProxyCopyWith<$Res> {
  factory $ProxyCopyWith(Proxy value, $Res Function(Proxy) then) =
      _$ProxyCopyWithImpl<$Res, Proxy>;
  @useResult
  $Res call({String name, String type, String? now});
}

/// @nodoc
class _$ProxyCopyWithImpl<$Res, $Val extends Proxy>
    implements $ProxyCopyWith<$Res> {
  _$ProxyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Proxy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? now = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      now: freezed == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProxyImplCopyWith<$Res> implements $ProxyCopyWith<$Res> {
  factory _$$ProxyImplCopyWith(
          _$ProxyImpl value, $Res Function(_$ProxyImpl) then) =
      __$$ProxyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String type, String? now});
}

/// @nodoc
class __$$ProxyImplCopyWithImpl<$Res>
    extends _$ProxyCopyWithImpl<$Res, _$ProxyImpl>
    implements _$$ProxyImplCopyWith<$Res> {
  __$$ProxyImplCopyWithImpl(
      _$ProxyImpl _value, $Res Function(_$ProxyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Proxy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? type = null,
    Object? now = freezed,
  }) {
    return _then(_$ProxyImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      now: freezed == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProxyImpl implements _Proxy {
  const _$ProxyImpl({required this.name, required this.type, this.now});

  factory _$ProxyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProxyImplFromJson(json);

  @override
  final String name;
  @override
  final String type;
  @override
  final String? now;

  @override
  String toString() {
    return 'Proxy(name: $name, type: $type, now: $now)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProxyImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.now, now) || other.now == now));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, now);

  /// Create a copy of Proxy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProxyImplCopyWith<_$ProxyImpl> get copyWith =>
      __$$ProxyImplCopyWithImpl<_$ProxyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProxyImplToJson(
      this,
    );
  }
}

abstract class _Proxy implements Proxy {
  const factory _Proxy(
      {required final String name,
      required final String type,
      final String? now}) = _$ProxyImpl;

  factory _Proxy.fromJson(Map<String, dynamic> json) = _$ProxyImpl.fromJson;

  @override
  String get name;
  @override
  String get type;
  @override
  String? get now;

  /// Create a copy of Proxy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProxyImplCopyWith<_$ProxyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  GroupType get type => throw _privateConstructorUsedError;
  List<Proxy> get all => throw _privateConstructorUsedError;
  String? get now => throw _privateConstructorUsedError;
  bool? get hidden => throw _privateConstructorUsedError;
  String? get testUrl => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call(
      {GroupType type,
      List<Proxy> all,
      String? now,
      bool? hidden,
      String? testUrl,
      String icon,
      String name});
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? all = null,
    Object? now = freezed,
    Object? hidden = freezed,
    Object? testUrl = freezed,
    Object? icon = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GroupType,
      all: null == all
          ? _value.all
          : all // ignore: cast_nullable_to_non_nullable
              as List<Proxy>,
      now: freezed == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as String?,
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      testUrl: freezed == testUrl
          ? _value.testUrl
          : testUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupImplCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$$GroupImplCopyWith(
          _$GroupImpl value, $Res Function(_$GroupImpl) then) =
      __$$GroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GroupType type,
      List<Proxy> all,
      String? now,
      bool? hidden,
      String? testUrl,
      String icon,
      String name});
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
      _$GroupImpl _value, $Res Function(_$GroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? all = null,
    Object? now = freezed,
    Object? hidden = freezed,
    Object? testUrl = freezed,
    Object? icon = null,
    Object? name = null,
  }) {
    return _then(_$GroupImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GroupType,
      all: null == all
          ? _value._all
          : all // ignore: cast_nullable_to_non_nullable
              as List<Proxy>,
      now: freezed == now
          ? _value.now
          : now // ignore: cast_nullable_to_non_nullable
              as String?,
      hidden: freezed == hidden
          ? _value.hidden
          : hidden // ignore: cast_nullable_to_non_nullable
              as bool?,
      testUrl: freezed == testUrl
          ? _value.testUrl
          : testUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl implements _Group {
  const _$GroupImpl(
      {required this.type,
      final List<Proxy> all = const [],
      this.now,
      this.hidden,
      this.testUrl,
      this.icon = "",
      required this.name})
      : _all = all;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final GroupType type;
  final List<Proxy> _all;
  @override
  @JsonKey()
  List<Proxy> get all {
    if (_all is EqualUnmodifiableListView) return _all;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_all);
  }

  @override
  final String? now;
  @override
  final bool? hidden;
  @override
  final String? testUrl;
  @override
  @JsonKey()
  final String icon;
  @override
  final String name;

  @override
  String toString() {
    return 'Group(type: $type, all: $all, now: $now, hidden: $hidden, testUrl: $testUrl, icon: $icon, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._all, _all) &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.testUrl, testUrl) || other.testUrl == testUrl) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      const DeepCollectionEquality().hash(_all),
      now,
      hidden,
      testUrl,
      icon,
      name);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      __$$GroupImplCopyWithImpl<_$GroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupImplToJson(
      this,
    );
  }
}

abstract class _Group implements Group {
  const factory _Group(
      {required final GroupType type,
      final List<Proxy> all,
      final String? now,
      final bool? hidden,
      final String? testUrl,
      final String icon,
      required final String name}) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  GroupType get type;
  @override
  List<Proxy> get all;
  @override
  String? get now;
  @override
  bool? get hidden;
  @override
  String? get testUrl;
  @override
  String get icon;
  @override
  String get name;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ColorSchemes {
  ColorScheme? get lightColorScheme => throw _privateConstructorUsedError;
  ColorScheme? get darkColorScheme => throw _privateConstructorUsedError;

  /// Create a copy of ColorSchemes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ColorSchemesCopyWith<ColorSchemes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ColorSchemesCopyWith<$Res> {
  factory $ColorSchemesCopyWith(
          ColorSchemes value, $Res Function(ColorSchemes) then) =
      _$ColorSchemesCopyWithImpl<$Res, ColorSchemes>;
  @useResult
  $Res call({ColorScheme? lightColorScheme, ColorScheme? darkColorScheme});
}

/// @nodoc
class _$ColorSchemesCopyWithImpl<$Res, $Val extends ColorSchemes>
    implements $ColorSchemesCopyWith<$Res> {
  _$ColorSchemesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ColorSchemes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lightColorScheme = freezed,
    Object? darkColorScheme = freezed,
  }) {
    return _then(_value.copyWith(
      lightColorScheme: freezed == lightColorScheme
          ? _value.lightColorScheme
          : lightColorScheme // ignore: cast_nullable_to_non_nullable
              as ColorScheme?,
      darkColorScheme: freezed == darkColorScheme
          ? _value.darkColorScheme
          : darkColorScheme // ignore: cast_nullable_to_non_nullable
              as ColorScheme?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ColorSchemesImplCopyWith<$Res>
    implements $ColorSchemesCopyWith<$Res> {
  factory _$$ColorSchemesImplCopyWith(
          _$ColorSchemesImpl value, $Res Function(_$ColorSchemesImpl) then) =
      __$$ColorSchemesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ColorScheme? lightColorScheme, ColorScheme? darkColorScheme});
}

/// @nodoc
class __$$ColorSchemesImplCopyWithImpl<$Res>
    extends _$ColorSchemesCopyWithImpl<$Res, _$ColorSchemesImpl>
    implements _$$ColorSchemesImplCopyWith<$Res> {
  __$$ColorSchemesImplCopyWithImpl(
      _$ColorSchemesImpl _value, $Res Function(_$ColorSchemesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ColorSchemes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lightColorScheme = freezed,
    Object? darkColorScheme = freezed,
  }) {
    return _then(_$ColorSchemesImpl(
      lightColorScheme: freezed == lightColorScheme
          ? _value.lightColorScheme
          : lightColorScheme // ignore: cast_nullable_to_non_nullable
              as ColorScheme?,
      darkColorScheme: freezed == darkColorScheme
          ? _value.darkColorScheme
          : darkColorScheme // ignore: cast_nullable_to_non_nullable
              as ColorScheme?,
    ));
  }
}

/// @nodoc

class _$ColorSchemesImpl implements _ColorSchemes {
  const _$ColorSchemesImpl({this.lightColorScheme, this.darkColorScheme});

  @override
  final ColorScheme? lightColorScheme;
  @override
  final ColorScheme? darkColorScheme;

  @override
  String toString() {
    return 'ColorSchemes(lightColorScheme: $lightColorScheme, darkColorScheme: $darkColorScheme)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ColorSchemesImpl &&
            (identical(other.lightColorScheme, lightColorScheme) ||
                other.lightColorScheme == lightColorScheme) &&
            (identical(other.darkColorScheme, darkColorScheme) ||
                other.darkColorScheme == darkColorScheme));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, lightColorScheme, darkColorScheme);

  /// Create a copy of ColorSchemes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ColorSchemesImplCopyWith<_$ColorSchemesImpl> get copyWith =>
      __$$ColorSchemesImplCopyWithImpl<_$ColorSchemesImpl>(this, _$identity);
}

abstract class _ColorSchemes implements ColorSchemes {
  const factory _ColorSchemes(
      {final ColorScheme? lightColorScheme,
      final ColorScheme? darkColorScheme}) = _$ColorSchemesImpl;

  @override
  ColorScheme? get lightColorScheme;
  @override
  ColorScheme? get darkColorScheme;

  /// Create a copy of ColorSchemes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ColorSchemesImplCopyWith<_$ColorSchemesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HotKeyAction _$HotKeyActionFromJson(Map<String, dynamic> json) {
  return _HotKeyAction.fromJson(json);
}

/// @nodoc
mixin _$HotKeyAction {
  HotAction get action => throw _privateConstructorUsedError;
  int? get key => throw _privateConstructorUsedError;
  Set<KeyboardModifier> get modifiers => throw _privateConstructorUsedError;

  /// Serializes this HotKeyAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HotKeyAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HotKeyActionCopyWith<HotKeyAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HotKeyActionCopyWith<$Res> {
  factory $HotKeyActionCopyWith(
          HotKeyAction value, $Res Function(HotKeyAction) then) =
      _$HotKeyActionCopyWithImpl<$Res, HotKeyAction>;
  @useResult
  $Res call({HotAction action, int? key, Set<KeyboardModifier> modifiers});
}

/// @nodoc
class _$HotKeyActionCopyWithImpl<$Res, $Val extends HotKeyAction>
    implements $HotKeyActionCopyWith<$Res> {
  _$HotKeyActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HotKeyAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? key = freezed,
    Object? modifiers = null,
  }) {
    return _then(_value.copyWith(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as HotAction,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as int?,
      modifiers: null == modifiers
          ? _value.modifiers
          : modifiers // ignore: cast_nullable_to_non_nullable
              as Set<KeyboardModifier>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HotKeyActionImplCopyWith<$Res>
    implements $HotKeyActionCopyWith<$Res> {
  factory _$$HotKeyActionImplCopyWith(
          _$HotKeyActionImpl value, $Res Function(_$HotKeyActionImpl) then) =
      __$$HotKeyActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({HotAction action, int? key, Set<KeyboardModifier> modifiers});
}

/// @nodoc
class __$$HotKeyActionImplCopyWithImpl<$Res>
    extends _$HotKeyActionCopyWithImpl<$Res, _$HotKeyActionImpl>
    implements _$$HotKeyActionImplCopyWith<$Res> {
  __$$HotKeyActionImplCopyWithImpl(
      _$HotKeyActionImpl _value, $Res Function(_$HotKeyActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of HotKeyAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? action = null,
    Object? key = freezed,
    Object? modifiers = null,
  }) {
    return _then(_$HotKeyActionImpl(
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as HotAction,
      key: freezed == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as int?,
      modifiers: null == modifiers
          ? _value._modifiers
          : modifiers // ignore: cast_nullable_to_non_nullable
              as Set<KeyboardModifier>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HotKeyActionImpl implements _HotKeyAction {
  const _$HotKeyActionImpl(
      {required this.action,
      this.key,
      final Set<KeyboardModifier> modifiers = const {}})
      : _modifiers = modifiers;

  factory _$HotKeyActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$HotKeyActionImplFromJson(json);

  @override
  final HotAction action;
  @override
  final int? key;
  final Set<KeyboardModifier> _modifiers;
  @override
  @JsonKey()
  Set<KeyboardModifier> get modifiers {
    if (_modifiers is EqualUnmodifiableSetView) return _modifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_modifiers);
  }

  @override
  String toString() {
    return 'HotKeyAction(action: $action, key: $key, modifiers: $modifiers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HotKeyActionImpl &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality()
                .equals(other._modifiers, _modifiers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, action, key,
      const DeepCollectionEquality().hash(_modifiers));

  /// Create a copy of HotKeyAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HotKeyActionImplCopyWith<_$HotKeyActionImpl> get copyWith =>
      __$$HotKeyActionImplCopyWithImpl<_$HotKeyActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HotKeyActionImplToJson(
      this,
    );
  }
}

abstract class _HotKeyAction implements HotKeyAction {
  const factory _HotKeyAction(
      {required final HotAction action,
      final int? key,
      final Set<KeyboardModifier> modifiers}) = _$HotKeyActionImpl;

  factory _HotKeyAction.fromJson(Map<String, dynamic> json) =
      _$HotKeyActionImpl.fromJson;

  @override
  HotAction get action;
  @override
  int? get key;
  @override
  Set<KeyboardModifier> get modifiers;

  /// Create a copy of HotKeyAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HotKeyActionImplCopyWith<_$HotKeyActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Field {
  String get label => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  Validator? get validator => throw _privateConstructorUsedError;

  /// Create a copy of Field
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FieldCopyWith<Field> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FieldCopyWith<$Res> {
  factory $FieldCopyWith(Field value, $Res Function(Field) then) =
      _$FieldCopyWithImpl<$Res, Field>;
  @useResult
  $Res call({String label, String value, Validator? validator});
}

/// @nodoc
class _$FieldCopyWithImpl<$Res, $Val extends Field>
    implements $FieldCopyWith<$Res> {
  _$FieldCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Field
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? validator = freezed,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      validator: freezed == validator
          ? _value.validator
          : validator // ignore: cast_nullable_to_non_nullable
              as Validator?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FieldImplCopyWith<$Res> implements $FieldCopyWith<$Res> {
  factory _$$FieldImplCopyWith(
          _$FieldImpl value, $Res Function(_$FieldImpl) then) =
      __$$FieldImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String value, Validator? validator});
}

/// @nodoc
class __$$FieldImplCopyWithImpl<$Res>
    extends _$FieldCopyWithImpl<$Res, _$FieldImpl>
    implements _$$FieldImplCopyWith<$Res> {
  __$$FieldImplCopyWithImpl(
      _$FieldImpl _value, $Res Function(_$FieldImpl) _then)
      : super(_value, _then);

  /// Create a copy of Field
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? validator = freezed,
  }) {
    return _then(_$FieldImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      validator: freezed == validator
          ? _value.validator
          : validator // ignore: cast_nullable_to_non_nullable
              as Validator?,
    ));
  }
}

/// @nodoc

class _$FieldImpl implements _Field {
  const _$FieldImpl({required this.label, required this.value, this.validator});

  @override
  final String label;
  @override
  final String value;
  @override
  final Validator? validator;

  @override
  String toString() {
    return 'Field(label: $label, value: $value, validator: $validator)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FieldImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.validator, validator) ||
                other.validator == validator));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, value, validator);

  /// Create a copy of Field
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FieldImplCopyWith<_$FieldImpl> get copyWith =>
      __$$FieldImplCopyWithImpl<_$FieldImpl>(this, _$identity);
}

abstract class _Field implements Field {
  const factory _Field(
      {required final String label,
      required final String value,
      final Validator? validator}) = _$FieldImpl;

  @override
  String get label;
  @override
  String get value;
  @override
  Validator? get validator;

  /// Create a copy of Field
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FieldImplCopyWith<_$FieldImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TextPainterParams _$TextPainterParamsFromJson(Map<String, dynamic> json) {
  return _TextPainterParams.fromJson(json);
}

/// @nodoc
mixin _$TextPainterParams {
  String? get text => throw _privateConstructorUsedError;
  double? get fontSize => throw _privateConstructorUsedError;
  double get textScaleFactor => throw _privateConstructorUsedError;
  double get maxWidth => throw _privateConstructorUsedError;
  int? get maxLines => throw _privateConstructorUsedError;

  /// Serializes this TextPainterParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TextPainterParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextPainterParamsCopyWith<TextPainterParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextPainterParamsCopyWith<$Res> {
  factory $TextPainterParamsCopyWith(
          TextPainterParams value, $Res Function(TextPainterParams) then) =
      _$TextPainterParamsCopyWithImpl<$Res, TextPainterParams>;
  @useResult
  $Res call(
      {String? text,
      double? fontSize,
      double textScaleFactor,
      double maxWidth,
      int? maxLines});
}

/// @nodoc
class _$TextPainterParamsCopyWithImpl<$Res, $Val extends TextPainterParams>
    implements $TextPainterParamsCopyWith<$Res> {
  _$TextPainterParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TextPainterParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = freezed,
    Object? fontSize = freezed,
    Object? textScaleFactor = null,
    Object? maxWidth = null,
    Object? maxLines = freezed,
  }) {
    return _then(_value.copyWith(
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      fontSize: freezed == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double?,
      textScaleFactor: null == textScaleFactor
          ? _value.textScaleFactor
          : textScaleFactor // ignore: cast_nullable_to_non_nullable
              as double,
      maxWidth: null == maxWidth
          ? _value.maxWidth
          : maxWidth // ignore: cast_nullable_to_non_nullable
              as double,
      maxLines: freezed == maxLines
          ? _value.maxLines
          : maxLines // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TextPainterParamsImplCopyWith<$Res>
    implements $TextPainterParamsCopyWith<$Res> {
  factory _$$TextPainterParamsImplCopyWith(_$TextPainterParamsImpl value,
          $Res Function(_$TextPainterParamsImpl) then) =
      __$$TextPainterParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? text,
      double? fontSize,
      double textScaleFactor,
      double maxWidth,
      int? maxLines});
}

/// @nodoc
class __$$TextPainterParamsImplCopyWithImpl<$Res>
    extends _$TextPainterParamsCopyWithImpl<$Res, _$TextPainterParamsImpl>
    implements _$$TextPainterParamsImplCopyWith<$Res> {
  __$$TextPainterParamsImplCopyWithImpl(_$TextPainterParamsImpl _value,
      $Res Function(_$TextPainterParamsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TextPainterParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = freezed,
    Object? fontSize = freezed,
    Object? textScaleFactor = null,
    Object? maxWidth = null,
    Object? maxLines = freezed,
  }) {
    return _then(_$TextPainterParamsImpl(
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      fontSize: freezed == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double?,
      textScaleFactor: null == textScaleFactor
          ? _value.textScaleFactor
          : textScaleFactor // ignore: cast_nullable_to_non_nullable
              as double,
      maxWidth: null == maxWidth
          ? _value.maxWidth
          : maxWidth // ignore: cast_nullable_to_non_nullable
              as double,
      maxLines: freezed == maxLines
          ? _value.maxLines
          : maxLines // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TextPainterParamsImpl implements _TextPainterParams {
  const _$TextPainterParamsImpl(
      {required this.text,
      required this.fontSize,
      required this.textScaleFactor,
      this.maxWidth = double.infinity,
      this.maxLines});

  factory _$TextPainterParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextPainterParamsImplFromJson(json);

  @override
  final String? text;
  @override
  final double? fontSize;
  @override
  final double textScaleFactor;
  @override
  @JsonKey()
  final double maxWidth;
  @override
  final int? maxLines;

  @override
  String toString() {
    return 'TextPainterParams(text: $text, fontSize: $fontSize, textScaleFactor: $textScaleFactor, maxWidth: $maxWidth, maxLines: $maxLines)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextPainterParamsImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.textScaleFactor, textScaleFactor) ||
                other.textScaleFactor == textScaleFactor) &&
            (identical(other.maxWidth, maxWidth) ||
                other.maxWidth == maxWidth) &&
            (identical(other.maxLines, maxLines) ||
                other.maxLines == maxLines));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, text, fontSize, textScaleFactor, maxWidth, maxLines);

  /// Create a copy of TextPainterParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextPainterParamsImplCopyWith<_$TextPainterParamsImpl> get copyWith =>
      __$$TextPainterParamsImplCopyWithImpl<_$TextPainterParamsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextPainterParamsImplToJson(
      this,
    );
  }
}

abstract class _TextPainterParams implements TextPainterParams {
  const factory _TextPainterParams(
      {required final String? text,
      required final double? fontSize,
      required final double textScaleFactor,
      final double maxWidth,
      final int? maxLines}) = _$TextPainterParamsImpl;

  factory _TextPainterParams.fromJson(Map<String, dynamic> json) =
      _$TextPainterParamsImpl.fromJson;

  @override
  String? get text;
  @override
  double? get fontSize;
  @override
  double get textScaleFactor;
  @override
  double get maxWidth;
  @override
  int? get maxLines;

  /// Create a copy of TextPainterParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextPainterParamsImplCopyWith<_$TextPainterParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) {
  return _SubscriptionInfo.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionInfo {
  int get upload => throw _privateConstructorUsedError;
  int get download => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get expire => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionInfoCopyWith<$Res> {
  factory $SubscriptionInfoCopyWith(
          SubscriptionInfo value, $Res Function(SubscriptionInfo) then) =
      _$SubscriptionInfoCopyWithImpl<$Res, SubscriptionInfo>;
  @useResult
  $Res call({int upload, int download, int total, int expire});
}

/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res, $Val extends SubscriptionInfo>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upload = null,
    Object? download = null,
    Object? total = null,
    Object? expire = null,
  }) {
    return _then(_value.copyWith(
      upload: null == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as int,
      download: null == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      expire: null == expire
          ? _value.expire
          : expire // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionInfoImplCopyWith<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  factory _$$SubscriptionInfoImplCopyWith(_$SubscriptionInfoImpl value,
          $Res Function(_$SubscriptionInfoImpl) then) =
      __$$SubscriptionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int upload, int download, int total, int expire});
}

/// @nodoc
class __$$SubscriptionInfoImplCopyWithImpl<$Res>
    extends _$SubscriptionInfoCopyWithImpl<$Res, _$SubscriptionInfoImpl>
    implements _$$SubscriptionInfoImplCopyWith<$Res> {
  __$$SubscriptionInfoImplCopyWithImpl(_$SubscriptionInfoImpl _value,
      $Res Function(_$SubscriptionInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upload = null,
    Object? download = null,
    Object? total = null,
    Object? expire = null,
  }) {
    return _then(_$SubscriptionInfoImpl(
      upload: null == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as int,
      download: null == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      expire: null == expire
          ? _value.expire
          : expire // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionInfoImpl implements _SubscriptionInfo {
  const _$SubscriptionInfoImpl(
      {this.upload = 0, this.download = 0, this.total = 0, this.expire = 0});

  factory _$SubscriptionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionInfoImplFromJson(json);

  @override
  @JsonKey()
  final int upload;
  @override
  @JsonKey()
  final int download;
  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int expire;

  @override
  String toString() {
    return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionInfoImpl &&
            (identical(other.upload, upload) || other.upload == upload) &&
            (identical(other.download, download) ||
                other.download == download) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.expire, expire) || other.expire == expire));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, upload, download, total, expire);

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionInfoImplCopyWith<_$SubscriptionInfoImpl> get copyWith =>
      __$$SubscriptionInfoImplCopyWithImpl<_$SubscriptionInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionInfoImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionInfo implements SubscriptionInfo {
  const factory _SubscriptionInfo(
      {final int upload,
      final int download,
      final int total,
      final int expire}) = _$SubscriptionInfoImpl;

  factory _SubscriptionInfo.fromJson(Map<String, dynamic> json) =
      _$SubscriptionInfoImpl.fromJson;

  @override
  int get upload;
  @override
  int get download;
  @override
  int get total;
  @override
  int get expire;

  /// Create a copy of SubscriptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionInfoImplCopyWith<_$SubscriptionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get id => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  String? get currentGroupName => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  DateTime? get lastUpdateDate => throw _privateConstructorUsedError;
  Duration get autoUpdateDuration => throw _privateConstructorUsedError;
  SubscriptionInfo? get subscriptionInfo => throw _privateConstructorUsedError;
  bool get autoUpdate => throw _privateConstructorUsedError;
  Map<String, String> get selectedMap => throw _privateConstructorUsedError;
  Set<String> get unfoldSet => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isUpdating => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call(
      {String id,
      String? label,
      String? currentGroupName,
      String url,
      DateTime? lastUpdateDate,
      Duration autoUpdateDuration,
      SubscriptionInfo? subscriptionInfo,
      bool autoUpdate,
      Map<String, String> selectedMap,
      Set<String> unfoldSet,
      @JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating});

  $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? currentGroupName = freezed,
    Object? url = null,
    Object? lastUpdateDate = freezed,
    Object? autoUpdateDuration = null,
    Object? subscriptionInfo = freezed,
    Object? autoUpdate = null,
    Object? selectedMap = null,
    Object? unfoldSet = null,
    Object? isUpdating = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      currentGroupName: freezed == currentGroupName
          ? _value.currentGroupName
          : currentGroupName // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdateDate: freezed == lastUpdateDate
          ? _value.lastUpdateDate
          : lastUpdateDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoUpdateDuration: null == autoUpdateDuration
          ? _value.autoUpdateDuration
          : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      subscriptionInfo: freezed == subscriptionInfo
          ? _value.subscriptionInfo
          : subscriptionInfo // ignore: cast_nullable_to_non_nullable
              as SubscriptionInfo?,
      autoUpdate: null == autoUpdate
          ? _value.autoUpdate
          : autoUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedMap: null == selectedMap
          ? _value.selectedMap
          : selectedMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      unfoldSet: null == unfoldSet
          ? _value.unfoldSet
          : unfoldSet // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_value.subscriptionInfo == null) {
      return null;
    }

    return $SubscriptionInfoCopyWith<$Res>(_value.subscriptionInfo!, (value) {
      return _then(_value.copyWith(subscriptionInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
          _$ProfileImpl value, $Res Function(_$ProfileImpl) then) =
      __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? label,
      String? currentGroupName,
      String url,
      DateTime? lastUpdateDate,
      Duration autoUpdateDuration,
      SubscriptionInfo? subscriptionInfo,
      bool autoUpdate,
      Map<String, String> selectedMap,
      Set<String> unfoldSet,
      @JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating});

  @override
  $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
      _$ProfileImpl _value, $Res Function(_$ProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = freezed,
    Object? currentGroupName = freezed,
    Object? url = null,
    Object? lastUpdateDate = freezed,
    Object? autoUpdateDuration = null,
    Object? subscriptionInfo = freezed,
    Object? autoUpdate = null,
    Object? selectedMap = null,
    Object? unfoldSet = null,
    Object? isUpdating = null,
  }) {
    return _then(_$ProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      currentGroupName: freezed == currentGroupName
          ? _value.currentGroupName
          : currentGroupName // ignore: cast_nullable_to_non_nullable
              as String?,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdateDate: freezed == lastUpdateDate
          ? _value.lastUpdateDate
          : lastUpdateDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoUpdateDuration: null == autoUpdateDuration
          ? _value.autoUpdateDuration
          : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      subscriptionInfo: freezed == subscriptionInfo
          ? _value.subscriptionInfo
          : subscriptionInfo // ignore: cast_nullable_to_non_nullable
              as SubscriptionInfo?,
      autoUpdate: null == autoUpdate
          ? _value.autoUpdate
          : autoUpdate // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedMap: null == selectedMap
          ? _value._selectedMap
          : selectedMap // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      unfoldSet: null == unfoldSet
          ? _value._unfoldSet
          : unfoldSet // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      isUpdating: null == isUpdating
          ? _value.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl(
      {required this.id,
      this.label,
      this.currentGroupName,
      this.url = "",
      this.lastUpdateDate,
      required this.autoUpdateDuration,
      this.subscriptionInfo,
      this.autoUpdate = true,
      final Map<String, String> selectedMap = const {},
      final Set<String> unfoldSet = const {},
      @JsonKey(includeToJson: false, includeFromJson: false)
      this.isUpdating = false})
      : _selectedMap = selectedMap,
        _unfoldSet = unfoldSet;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String? label;
  @override
  final String? currentGroupName;
  @override
  @JsonKey()
  final String url;
  @override
  final DateTime? lastUpdateDate;
  @override
  final Duration autoUpdateDuration;
  @override
  final SubscriptionInfo? subscriptionInfo;
  @override
  @JsonKey()
  final bool autoUpdate;
  final Map<String, String> _selectedMap;
  @override
  @JsonKey()
  Map<String, String> get selectedMap {
    if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedMap);
  }

  final Set<String> _unfoldSet;
  @override
  @JsonKey()
  Set<String> get unfoldSet {
    if (_unfoldSet is EqualUnmodifiableSetView) return _unfoldSet;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_unfoldSet);
  }

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  final bool isUpdating;

  @override
  String toString() {
    return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, isUpdating: $isUpdating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.currentGroupName, currentGroupName) ||
                other.currentGroupName == currentGroupName) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.lastUpdateDate, lastUpdateDate) ||
                other.lastUpdateDate == lastUpdateDate) &&
            (identical(other.autoUpdateDuration, autoUpdateDuration) ||
                other.autoUpdateDuration == autoUpdateDuration) &&
            (identical(other.subscriptionInfo, subscriptionInfo) ||
                other.subscriptionInfo == subscriptionInfo) &&
            (identical(other.autoUpdate, autoUpdate) ||
                other.autoUpdate == autoUpdate) &&
            const DeepCollectionEquality()
                .equals(other._selectedMap, _selectedMap) &&
            const DeepCollectionEquality()
                .equals(other._unfoldSet, _unfoldSet) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      label,
      currentGroupName,
      url,
      lastUpdateDate,
      autoUpdateDuration,
      subscriptionInfo,
      autoUpdate,
      const DeepCollectionEquality().hash(_selectedMap),
      const DeepCollectionEquality().hash(_unfoldSet),
      isUpdating);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(
      this,
    );
  }
}

abstract class _Profile implements Profile {
  const factory _Profile(
      {required final String id,
      final String? label,
      final String? currentGroupName,
      final String url,
      final DateTime? lastUpdateDate,
      required final Duration autoUpdateDuration,
      final SubscriptionInfo? subscriptionInfo,
      final bool autoUpdate,
      final Map<String, String> selectedMap,
      final Set<String> unfoldSet,
      @JsonKey(includeToJson: false, includeFromJson: false)
      final bool isUpdating}) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get id;
  @override
  String? get label;
  @override
  String? get currentGroupName;
  @override
  String get url;
  @override
  DateTime? get lastUpdateDate;
  @override
  Duration get autoUpdateDuration;
  @override
  SubscriptionInfo? get subscriptionInfo;
  @override
  bool get autoUpdate;
  @override
  Map<String, String> get selectedMap;
  @override
  Set<String> get unfoldSet;
  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isUpdating;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

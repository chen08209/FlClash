// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../proxy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  GroupType get type => throw _privateConstructorUsedError;
  List<Proxy> get all => throw _privateConstructorUsedError;
  String? get now => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call({GroupType type, List<Proxy> all, String? now, String name});
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? all = null,
    Object? now = freezed,
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
  $Res call({GroupType type, List<Proxy> all, String? now, String name});
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
      _$GroupImpl _value, $Res Function(_$GroupImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? all = null,
    Object? now = freezed,
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
  final String name;

  @override
  String toString() {
    return 'Group(type: $type, all: $all, now: $now, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._all, _all) &&
            (identical(other.now, now) || other.now == now) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, type, const DeepCollectionEquality().hash(_all), now, name);

  @JsonKey(ignore: true)
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
      required final String name}) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  GroupType get type;
  @override
  List<Proxy> get all;
  @override
  String? get now;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
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

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, type, now);

  @JsonKey(ignore: true)
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
  @override
  @JsonKey(ignore: true)
  _$$ProxyImplCopyWith<_$ProxyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

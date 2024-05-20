// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../dav.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DAV _$DAVFromJson(Map<String, dynamic> json) {
  return _DAV.fromJson(json);
}

/// @nodoc
mixin _$DAV {
  String get uri => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DAVCopyWith<DAV> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DAVCopyWith<$Res> {
  factory $DAVCopyWith(DAV value, $Res Function(DAV) then) =
      _$DAVCopyWithImpl<$Res, DAV>;
  @useResult
  $Res call({String uri, String user, String password});
}

/// @nodoc
class _$DAVCopyWithImpl<$Res, $Val extends DAV> implements $DAVCopyWith<$Res> {
  _$DAVCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? user = null,
    Object? password = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DAVImplCopyWith<$Res> implements $DAVCopyWith<$Res> {
  factory _$$DAVImplCopyWith(_$DAVImpl value, $Res Function(_$DAVImpl) then) =
      __$$DAVImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String uri, String user, String password});
}

/// @nodoc
class __$$DAVImplCopyWithImpl<$Res> extends _$DAVCopyWithImpl<$Res, _$DAVImpl>
    implements _$$DAVImplCopyWith<$Res> {
  __$$DAVImplCopyWithImpl(_$DAVImpl _value, $Res Function(_$DAVImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uri = null,
    Object? user = null,
    Object? password = null,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DAVImpl implements _DAV {
  const _$DAVImpl(
      {required this.uri, required this.user, required this.password});

  factory _$DAVImpl.fromJson(Map<String, dynamic> json) =>
      _$$DAVImplFromJson(json);

  @override
  final String uri;
  @override
  final String user;
  @override
  final String password;

  @override
  String toString() {
    return 'DAV(uri: $uri, user: $user, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DAVImpl &&
            (identical(other.uri, uri) || other.uri == uri) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uri, user, password);

  @JsonKey(ignore: true)
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
      required final String password}) = _$DAVImpl;

  factory _DAV.fromJson(Map<String, dynamic> json) = _$DAVImpl.fromJson;

  @override
  String get uri;
  @override
  String get user;
  @override
  String get password;
  @override
  @JsonKey(ignore: true)
  _$$DAVImplCopyWith<_$DAVImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

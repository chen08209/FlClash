// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../clash_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Tun _$TunFromJson(Map<String, dynamic> json) {
  return _Tun.fromJson(json);
}

/// @nodoc
mixin _$Tun {
  bool get enable => throw _privateConstructorUsedError;
  String get device => throw _privateConstructorUsedError;
  TunStack get stack => throw _privateConstructorUsedError;
  @JsonKey(name: "dns-hijack")
  List<String> get dnsHijack => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TunCopyWith<Tun> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TunCopyWith<$Res> {
  factory $TunCopyWith(Tun value, $Res Function(Tun) then) =
      _$TunCopyWithImpl<$Res, Tun>;
  @useResult
  $Res call(
      {bool enable,
      String device,
      TunStack stack,
      @JsonKey(name: "dns-hijack") List<String> dnsHijack});
}

/// @nodoc
class _$TunCopyWithImpl<$Res, $Val extends Tun> implements $TunCopyWith<$Res> {
  _$TunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? device = null,
    Object? stack = null,
    Object? dnsHijack = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      device: null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as String,
      stack: null == stack
          ? _value.stack
          : stack // ignore: cast_nullable_to_non_nullable
              as TunStack,
      dnsHijack: null == dnsHijack
          ? _value.dnsHijack
          : dnsHijack // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TunImplCopyWith<$Res> implements $TunCopyWith<$Res> {
  factory _$$TunImplCopyWith(_$TunImpl value, $Res Function(_$TunImpl) then) =
      __$$TunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enable,
      String device,
      TunStack stack,
      @JsonKey(name: "dns-hijack") List<String> dnsHijack});
}

/// @nodoc
class __$$TunImplCopyWithImpl<$Res> extends _$TunCopyWithImpl<$Res, _$TunImpl>
    implements _$$TunImplCopyWith<$Res> {
  __$$TunImplCopyWithImpl(_$TunImpl _value, $Res Function(_$TunImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? device = null,
    Object? stack = null,
    Object? dnsHijack = null,
  }) {
    return _then(_$TunImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      device: null == device
          ? _value.device
          : device // ignore: cast_nullable_to_non_nullable
              as String,
      stack: null == stack
          ? _value.stack
          : stack // ignore: cast_nullable_to_non_nullable
              as TunStack,
      dnsHijack: null == dnsHijack
          ? _value._dnsHijack
          : dnsHijack // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TunImpl implements _Tun {
  const _$TunImpl(
      {this.enable = false,
      this.device = appName,
      this.stack = TunStack.gvisor,
      @JsonKey(name: "dns-hijack")
      final List<String> dnsHijack = const ["any:53"]})
      : _dnsHijack = dnsHijack;

  factory _$TunImpl.fromJson(Map<String, dynamic> json) =>
      _$$TunImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey()
  final String device;
  @override
  @JsonKey()
  final TunStack stack;
  final List<String> _dnsHijack;
  @override
  @JsonKey(name: "dns-hijack")
  List<String> get dnsHijack {
    if (_dnsHijack is EqualUnmodifiableListView) return _dnsHijack;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dnsHijack);
  }

  @override
  String toString() {
    return 'Tun(enable: $enable, device: $device, stack: $stack, dnsHijack: $dnsHijack)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TunImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.stack, stack) || other.stack == stack) &&
            const DeepCollectionEquality()
                .equals(other._dnsHijack, _dnsHijack));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, enable, device, stack,
      const DeepCollectionEquality().hash(_dnsHijack));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TunImplCopyWith<_$TunImpl> get copyWith =>
      __$$TunImplCopyWithImpl<_$TunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TunImplToJson(
      this,
    );
  }
}

abstract class _Tun implements Tun {
  const factory _Tun(
      {final bool enable,
      final String device,
      final TunStack stack,
      @JsonKey(name: "dns-hijack") final List<String> dnsHijack}) = _$TunImpl;

  factory _Tun.fromJson(Map<String, dynamic> json) = _$TunImpl.fromJson;

  @override
  bool get enable;
  @override
  String get device;
  @override
  TunStack get stack;
  @override
  @JsonKey(name: "dns-hijack")
  List<String> get dnsHijack;
  @override
  @JsonKey(ignore: true)
  _$$TunImplCopyWith<_$TunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

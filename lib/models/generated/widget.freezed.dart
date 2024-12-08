// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ActivateState {
  bool get active => throw _privateConstructorUsedError;

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivateStateCopyWith<ActivateState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivateStateCopyWith<$Res> {
  factory $ActivateStateCopyWith(
          ActivateState value, $Res Function(ActivateState) then) =
      _$ActivateStateCopyWithImpl<$Res, ActivateState>;
  @useResult
  $Res call({bool active});
}

/// @nodoc
class _$ActivateStateCopyWithImpl<$Res, $Val extends ActivateState>
    implements $ActivateStateCopyWith<$Res> {
  _$ActivateStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivateStateImplCopyWith<$Res>
    implements $ActivateStateCopyWith<$Res> {
  factory _$$ActivateStateImplCopyWith(
          _$ActivateStateImpl value, $Res Function(_$ActivateStateImpl) then) =
      __$$ActivateStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool active});
}

/// @nodoc
class __$$ActivateStateImplCopyWithImpl<$Res>
    extends _$ActivateStateCopyWithImpl<$Res, _$ActivateStateImpl>
    implements _$$ActivateStateImplCopyWith<$Res> {
  __$$ActivateStateImplCopyWithImpl(
      _$ActivateStateImpl _value, $Res Function(_$ActivateStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? active = null,
  }) {
    return _then(_$ActivateStateImpl(
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ActivateStateImpl implements _ActivateState {
  const _$ActivateStateImpl({required this.active});

  @override
  final bool active;

  @override
  String toString() {
    return 'ActivateState(active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivateStateImpl &&
            (identical(other.active, active) || other.active == active));
  }

  @override
  int get hashCode => Object.hash(runtimeType, active);

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivateStateImplCopyWith<_$ActivateStateImpl> get copyWith =>
      __$$ActivateStateImplCopyWithImpl<_$ActivateStateImpl>(this, _$identity);
}

abstract class _ActivateState implements ActivateState {
  const factory _ActivateState({required final bool active}) =
      _$ActivateStateImpl;

  @override
  bool get active;

  /// Create a copy of ActivateState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivateStateImplCopyWith<_$ActivateStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommonMessage {
  String get id => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommonMessageCopyWith<CommonMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommonMessageCopyWith<$Res> {
  factory $CommonMessageCopyWith(
          CommonMessage value, $Res Function(CommonMessage) then) =
      _$CommonMessageCopyWithImpl<$Res, CommonMessage>;
  @useResult
  $Res call({String id, String text, Duration duration});
}

/// @nodoc
class _$CommonMessageCopyWithImpl<$Res, $Val extends CommonMessage>
    implements $CommonMessageCopyWith<$Res> {
  _$CommonMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommonMessageImplCopyWith<$Res>
    implements $CommonMessageCopyWith<$Res> {
  factory _$$CommonMessageImplCopyWith(
          _$CommonMessageImpl value, $Res Function(_$CommonMessageImpl) then) =
      __$$CommonMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String text, Duration duration});
}

/// @nodoc
class __$$CommonMessageImplCopyWithImpl<$Res>
    extends _$CommonMessageCopyWithImpl<$Res, _$CommonMessageImpl>
    implements _$$CommonMessageImplCopyWith<$Res> {
  __$$CommonMessageImplCopyWithImpl(
      _$CommonMessageImpl _value, $Res Function(_$CommonMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? duration = null,
  }) {
    return _then(_$CommonMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$CommonMessageImpl implements _CommonMessage {
  const _$CommonMessageImpl(
      {required this.id,
      required this.text,
      this.duration = const Duration(seconds: 3)});

  @override
  final String id;
  @override
  final String text;
  @override
  @JsonKey()
  final Duration duration;

  @override
  String toString() {
    return 'CommonMessage(id: $id, text: $text, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommonMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, text, duration);

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommonMessageImplCopyWith<_$CommonMessageImpl> get copyWith =>
      __$$CommonMessageImplCopyWithImpl<_$CommonMessageImpl>(this, _$identity);
}

abstract class _CommonMessage implements CommonMessage {
  const factory _CommonMessage(
      {required final String id,
      required final String text,
      final Duration duration}) = _$CommonMessageImpl;

  @override
  String get id;
  @override
  String get text;
  @override
  Duration get duration;

  /// Create a copy of CommonMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommonMessageImplCopyWith<_$CommonMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

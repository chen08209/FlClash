// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AccessControl _$AccessControlFromJson(Map<String, dynamic> json) {
  return _AccessControl.fromJson(json);
}

/// @nodoc
mixin _$AccessControl {
  AccessControlMode get mode => throw _privateConstructorUsedError;
  List<String> get acceptList => throw _privateConstructorUsedError;
  List<String> get rejectList => throw _privateConstructorUsedError;
  bool get isFilterSystemApp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccessControlCopyWith<AccessControl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccessControlCopyWith<$Res> {
  factory $AccessControlCopyWith(
          AccessControl value, $Res Function(AccessControl) then) =
      _$AccessControlCopyWithImpl<$Res, AccessControl>;
  @useResult
  $Res call(
      {AccessControlMode mode,
      List<String> acceptList,
      List<String> rejectList,
      bool isFilterSystemApp});
}

/// @nodoc
class _$AccessControlCopyWithImpl<$Res, $Val extends AccessControl>
    implements $AccessControlCopyWith<$Res> {
  _$AccessControlCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? acceptList = null,
    Object? rejectList = null,
    Object? isFilterSystemApp = null,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as AccessControlMode,
      acceptList: null == acceptList
          ? _value.acceptList
          : acceptList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectList: null == rejectList
          ? _value.rejectList
          : rejectList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFilterSystemApp: null == isFilterSystemApp
          ? _value.isFilterSystemApp
          : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccessControlImplCopyWith<$Res>
    implements $AccessControlCopyWith<$Res> {
  factory _$$AccessControlImplCopyWith(
          _$AccessControlImpl value, $Res Function(_$AccessControlImpl) then) =
      __$$AccessControlImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AccessControlMode mode,
      List<String> acceptList,
      List<String> rejectList,
      bool isFilterSystemApp});
}

/// @nodoc
class __$$AccessControlImplCopyWithImpl<$Res>
    extends _$AccessControlCopyWithImpl<$Res, _$AccessControlImpl>
    implements _$$AccessControlImplCopyWith<$Res> {
  __$$AccessControlImplCopyWithImpl(
      _$AccessControlImpl _value, $Res Function(_$AccessControlImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? acceptList = null,
    Object? rejectList = null,
    Object? isFilterSystemApp = null,
  }) {
    return _then(_$AccessControlImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as AccessControlMode,
      acceptList: null == acceptList
          ? _value._acceptList
          : acceptList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rejectList: null == rejectList
          ? _value._rejectList
          : rejectList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isFilterSystemApp: null == isFilterSystemApp
          ? _value.isFilterSystemApp
          : isFilterSystemApp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccessControlImpl implements _AccessControl {
  const _$AccessControlImpl(
      {this.mode = AccessControlMode.rejectSelected,
      final List<String> acceptList = const [],
      final List<String> rejectList = const [],
      this.isFilterSystemApp = true})
      : _acceptList = acceptList,
        _rejectList = rejectList;

  factory _$AccessControlImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccessControlImplFromJson(json);

  @override
  @JsonKey()
  final AccessControlMode mode;
  final List<String> _acceptList;
  @override
  @JsonKey()
  List<String> get acceptList {
    if (_acceptList is EqualUnmodifiableListView) return _acceptList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_acceptList);
  }

  final List<String> _rejectList;
  @override
  @JsonKey()
  List<String> get rejectList {
    if (_rejectList is EqualUnmodifiableListView) return _rejectList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rejectList);
  }

  @override
  @JsonKey()
  final bool isFilterSystemApp;

  @override
  String toString() {
    return 'AccessControl(mode: $mode, acceptList: $acceptList, rejectList: $rejectList, isFilterSystemApp: $isFilterSystemApp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccessControlImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            const DeepCollectionEquality()
                .equals(other._acceptList, _acceptList) &&
            const DeepCollectionEquality()
                .equals(other._rejectList, _rejectList) &&
            (identical(other.isFilterSystemApp, isFilterSystemApp) ||
                other.isFilterSystemApp == isFilterSystemApp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      const DeepCollectionEquality().hash(_acceptList),
      const DeepCollectionEquality().hash(_rejectList),
      isFilterSystemApp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccessControlImplCopyWith<_$AccessControlImpl> get copyWith =>
      __$$AccessControlImplCopyWithImpl<_$AccessControlImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccessControlImplToJson(
      this,
    );
  }
}

abstract class _AccessControl implements AccessControl {
  const factory _AccessControl(
      {final AccessControlMode mode,
      final List<String> acceptList,
      final List<String> rejectList,
      final bool isFilterSystemApp}) = _$AccessControlImpl;

  factory _AccessControl.fromJson(Map<String, dynamic> json) =
      _$AccessControlImpl.fromJson;

  @override
  AccessControlMode get mode;
  @override
  List<String> get acceptList;
  @override
  List<String> get rejectList;
  @override
  bool get isFilterSystemApp;
  @override
  @JsonKey(ignore: true)
  _$$AccessControlImplCopyWith<_$AccessControlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Props _$PropsFromJson(Map<String, dynamic> json) {
  return _Props.fromJson(json);
}

/// @nodoc
mixin _$Props {
  AccessControl? get accessControl => throw _privateConstructorUsedError;
  bool get allowBypass => throw _privateConstructorUsedError;
  bool get systemProxy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PropsCopyWith<Props> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PropsCopyWith<$Res> {
  factory $PropsCopyWith(Props value, $Res Function(Props) then) =
      _$PropsCopyWithImpl<$Res, Props>;
  @useResult
  $Res call({AccessControl? accessControl, bool allowBypass, bool systemProxy});

  $AccessControlCopyWith<$Res>? get accessControl;
}

/// @nodoc
class _$PropsCopyWithImpl<$Res, $Val extends Props>
    implements $PropsCopyWith<$Res> {
  _$PropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessControl = freezed,
    Object? allowBypass = null,
    Object? systemProxy = null,
  }) {
    return _then(_value.copyWith(
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccessControlCopyWith<$Res>? get accessControl {
    if (_value.accessControl == null) {
      return null;
    }

    return $AccessControlCopyWith<$Res>(_value.accessControl!, (value) {
      return _then(_value.copyWith(accessControl: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PropsImplCopyWith<$Res> implements $PropsCopyWith<$Res> {
  factory _$$PropsImplCopyWith(
          _$PropsImpl value, $Res Function(_$PropsImpl) then) =
      __$$PropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AccessControl? accessControl, bool allowBypass, bool systemProxy});

  @override
  $AccessControlCopyWith<$Res>? get accessControl;
}

/// @nodoc
class __$$PropsImplCopyWithImpl<$Res>
    extends _$PropsCopyWithImpl<$Res, _$PropsImpl>
    implements _$$PropsImplCopyWith<$Res> {
  __$$PropsImplCopyWithImpl(
      _$PropsImpl _value, $Res Function(_$PropsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessControl = freezed,
    Object? allowBypass = null,
    Object? systemProxy = null,
  }) {
    return _then(_$PropsImpl(
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PropsImpl implements _Props {
  const _$PropsImpl(
      {this.accessControl,
      required this.allowBypass,
      required this.systemProxy});

  factory _$PropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PropsImplFromJson(json);

  @override
  final AccessControl? accessControl;
  @override
  final bool allowBypass;
  @override
  final bool systemProxy;

  @override
  String toString() {
    return 'Props(accessControl: $accessControl, allowBypass: $allowBypass, systemProxy: $systemProxy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PropsImpl &&
            (identical(other.accessControl, accessControl) ||
                other.accessControl == accessControl) &&
            (identical(other.allowBypass, allowBypass) ||
                other.allowBypass == allowBypass) &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, accessControl, allowBypass, systemProxy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PropsImplCopyWith<_$PropsImpl> get copyWith =>
      __$$PropsImplCopyWithImpl<_$PropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PropsImplToJson(
      this,
    );
  }
}

abstract class _Props implements Props {
  const factory _Props(
      {final AccessControl? accessControl,
      required final bool allowBypass,
      required final bool systemProxy}) = _$PropsImpl;

  factory _Props.fromJson(Map<String, dynamic> json) = _$PropsImpl.fromJson;

  @override
  AccessControl? get accessControl;
  @override
  bool get allowBypass;
  @override
  bool get systemProxy;
  @override
  @JsonKey(ignore: true)
  _$$PropsImplCopyWith<_$PropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WindowProps _$WindowPropsFromJson(Map<String, dynamic> json) {
  return _WindowProps.fromJson(json);
}

/// @nodoc
mixin _$WindowProps {
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  double? get top => throw _privateConstructorUsedError;
  double? get left => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WindowPropsCopyWith<WindowProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WindowPropsCopyWith<$Res> {
  factory $WindowPropsCopyWith(
          WindowProps value, $Res Function(WindowProps) then) =
      _$WindowPropsCopyWithImpl<$Res, WindowProps>;
  @useResult
  $Res call({double width, double height, double? top, double? left});
}

/// @nodoc
class _$WindowPropsCopyWithImpl<$Res, $Val extends WindowProps>
    implements $WindowPropsCopyWith<$Res> {
  _$WindowPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? top = freezed,
    Object? left = freezed,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      top: freezed == top
          ? _value.top
          : top // ignore: cast_nullable_to_non_nullable
              as double?,
      left: freezed == left
          ? _value.left
          : left // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WindowPropsImplCopyWith<$Res>
    implements $WindowPropsCopyWith<$Res> {
  factory _$$WindowPropsImplCopyWith(
          _$WindowPropsImpl value, $Res Function(_$WindowPropsImpl) then) =
      __$$WindowPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double width, double height, double? top, double? left});
}

/// @nodoc
class __$$WindowPropsImplCopyWithImpl<$Res>
    extends _$WindowPropsCopyWithImpl<$Res, _$WindowPropsImpl>
    implements _$$WindowPropsImplCopyWith<$Res> {
  __$$WindowPropsImplCopyWithImpl(
      _$WindowPropsImpl _value, $Res Function(_$WindowPropsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? height = null,
    Object? top = freezed,
    Object? left = freezed,
  }) {
    return _then(_$WindowPropsImpl(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double,
      top: freezed == top
          ? _value.top
          : top // ignore: cast_nullable_to_non_nullable
              as double?,
      left: freezed == left
          ? _value.left
          : left // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WindowPropsImpl implements _WindowProps {
  const _$WindowPropsImpl(
      {this.width = 1000, this.height = 600, this.top, this.left});

  factory _$WindowPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WindowPropsImplFromJson(json);

  @override
  @JsonKey()
  final double width;
  @override
  @JsonKey()
  final double height;
  @override
  final double? top;
  @override
  final double? left;

  @override
  String toString() {
    return 'WindowProps(width: $width, height: $height, top: $top, left: $left)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WindowPropsImpl &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.left, left) || other.left == left));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, width, height, top, left);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WindowPropsImplCopyWith<_$WindowPropsImpl> get copyWith =>
      __$$WindowPropsImplCopyWithImpl<_$WindowPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WindowPropsImplToJson(
      this,
    );
  }
}

abstract class _WindowProps implements WindowProps {
  const factory _WindowProps(
      {final double width,
      final double height,
      final double? top,
      final double? left}) = _$WindowPropsImpl;

  factory _WindowProps.fromJson(Map<String, dynamic> json) =
      _$WindowPropsImpl.fromJson;

  @override
  double get width;
  @override
  double get height;
  @override
  double? get top;
  @override
  double? get left;
  @override
  @JsonKey(ignore: true)
  _$$WindowPropsImplCopyWith<_$WindowPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

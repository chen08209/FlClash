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
  AccessSortType get sort => throw _privateConstructorUsedError;
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
      AccessSortType sort,
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
    Object? sort = null,
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
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as AccessSortType,
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
      AccessSortType sort,
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
    Object? sort = null,
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
      sort: null == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as AccessSortType,
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
      this.sort = AccessSortType.none,
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
  final AccessSortType sort;
  @override
  @JsonKey()
  final bool isFilterSystemApp;

  @override
  String toString() {
    return 'AccessControl(mode: $mode, acceptList: $acceptList, rejectList: $rejectList, sort: $sort, isFilterSystemApp: $isFilterSystemApp)';
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
            (identical(other.sort, sort) || other.sort == sort) &&
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
      sort,
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
      final AccessSortType sort,
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
  AccessSortType get sort;
  @override
  bool get isFilterSystemApp;
  @override
  @JsonKey(ignore: true)
  _$$AccessControlImplCopyWith<_$AccessControlImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoreState _$CoreStateFromJson(Map<String, dynamic> json) {
  return _CoreState.fromJson(json);
}

/// @nodoc
mixin _$CoreState {
  AccessControl? get accessControl => throw _privateConstructorUsedError;
  String get currentProfileName => throw _privateConstructorUsedError;
  bool get enable => throw _privateConstructorUsedError;
  bool get allowBypass => throw _privateConstructorUsedError;
  bool get systemProxy => throw _privateConstructorUsedError;
  int get mixedPort => throw _privateConstructorUsedError;
  bool get ipv6 => throw _privateConstructorUsedError;
  bool get onlyProxy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoreStateCopyWith<CoreState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoreStateCopyWith<$Res> {
  factory $CoreStateCopyWith(CoreState value, $Res Function(CoreState) then) =
      _$CoreStateCopyWithImpl<$Res, CoreState>;
  @useResult
  $Res call(
      {AccessControl? accessControl,
      String currentProfileName,
      bool enable,
      bool allowBypass,
      bool systemProxy,
      int mixedPort,
      bool ipv6,
      bool onlyProxy});

  $AccessControlCopyWith<$Res>? get accessControl;
}

/// @nodoc
class _$CoreStateCopyWithImpl<$Res, $Val extends CoreState>
    implements $CoreStateCopyWith<$Res> {
  _$CoreStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessControl = freezed,
    Object? currentProfileName = null,
    Object? enable = null,
    Object? allowBypass = null,
    Object? systemProxy = null,
    Object? mixedPort = null,
    Object? ipv6 = null,
    Object? onlyProxy = null,
  }) {
    return _then(_value.copyWith(
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      currentProfileName: null == currentProfileName
          ? _value.currentProfileName
          : currentProfileName // ignore: cast_nullable_to_non_nullable
              as String,
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      mixedPort: null == mixedPort
          ? _value.mixedPort
          : mixedPort // ignore: cast_nullable_to_non_nullable
              as int,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      onlyProxy: null == onlyProxy
          ? _value.onlyProxy
          : onlyProxy // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CoreStateImplCopyWith<$Res>
    implements $CoreStateCopyWith<$Res> {
  factory _$$CoreStateImplCopyWith(
          _$CoreStateImpl value, $Res Function(_$CoreStateImpl) then) =
      __$$CoreStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AccessControl? accessControl,
      String currentProfileName,
      bool enable,
      bool allowBypass,
      bool systemProxy,
      int mixedPort,
      bool ipv6,
      bool onlyProxy});

  @override
  $AccessControlCopyWith<$Res>? get accessControl;
}

/// @nodoc
class __$$CoreStateImplCopyWithImpl<$Res>
    extends _$CoreStateCopyWithImpl<$Res, _$CoreStateImpl>
    implements _$$CoreStateImplCopyWith<$Res> {
  __$$CoreStateImplCopyWithImpl(
      _$CoreStateImpl _value, $Res Function(_$CoreStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessControl = freezed,
    Object? currentProfileName = null,
    Object? enable = null,
    Object? allowBypass = null,
    Object? systemProxy = null,
    Object? mixedPort = null,
    Object? ipv6 = null,
    Object? onlyProxy = null,
  }) {
    return _then(_$CoreStateImpl(
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      currentProfileName: null == currentProfileName
          ? _value.currentProfileName
          : currentProfileName // ignore: cast_nullable_to_non_nullable
              as String,
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      mixedPort: null == mixedPort
          ? _value.mixedPort
          : mixedPort // ignore: cast_nullable_to_non_nullable
              as int,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      onlyProxy: null == onlyProxy
          ? _value.onlyProxy
          : onlyProxy // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoreStateImpl implements _CoreState {
  const _$CoreStateImpl(
      {this.accessControl,
      required this.currentProfileName,
      required this.enable,
      required this.allowBypass,
      required this.systemProxy,
      required this.mixedPort,
      required this.ipv6,
      required this.onlyProxy});

  factory _$CoreStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoreStateImplFromJson(json);

  @override
  final AccessControl? accessControl;
  @override
  final String currentProfileName;
  @override
  final bool enable;
  @override
  final bool allowBypass;
  @override
  final bool systemProxy;
  @override
  final int mixedPort;
  @override
  final bool ipv6;
  @override
  final bool onlyProxy;

  @override
  String toString() {
    return 'CoreState(accessControl: $accessControl, currentProfileName: $currentProfileName, enable: $enable, allowBypass: $allowBypass, systemProxy: $systemProxy, mixedPort: $mixedPort, ipv6: $ipv6, onlyProxy: $onlyProxy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoreStateImpl &&
            (identical(other.accessControl, accessControl) ||
                other.accessControl == accessControl) &&
            (identical(other.currentProfileName, currentProfileName) ||
                other.currentProfileName == currentProfileName) &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.allowBypass, allowBypass) ||
                other.allowBypass == allowBypass) &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy) &&
            (identical(other.mixedPort, mixedPort) ||
                other.mixedPort == mixedPort) &&
            (identical(other.ipv6, ipv6) || other.ipv6 == ipv6) &&
            (identical(other.onlyProxy, onlyProxy) ||
                other.onlyProxy == onlyProxy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      accessControl,
      currentProfileName,
      enable,
      allowBypass,
      systemProxy,
      mixedPort,
      ipv6,
      onlyProxy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoreStateImplCopyWith<_$CoreStateImpl> get copyWith =>
      __$$CoreStateImplCopyWithImpl<_$CoreStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoreStateImplToJson(
      this,
    );
  }
}

abstract class _CoreState implements CoreState {
  const factory _CoreState(
      {final AccessControl? accessControl,
      required final String currentProfileName,
      required final bool enable,
      required final bool allowBypass,
      required final bool systemProxy,
      required final int mixedPort,
      required final bool ipv6,
      required final bool onlyProxy}) = _$CoreStateImpl;

  factory _CoreState.fromJson(Map<String, dynamic> json) =
      _$CoreStateImpl.fromJson;

  @override
  AccessControl? get accessControl;
  @override
  String get currentProfileName;
  @override
  bool get enable;
  @override
  bool get allowBypass;
  @override
  bool get systemProxy;
  @override
  int get mixedPort;
  @override
  bool get ipv6;
  @override
  bool get onlyProxy;
  @override
  @JsonKey(ignore: true)
  _$$CoreStateImplCopyWith<_$CoreStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VPNState _$VPNStateFromJson(Map<String, dynamic> json) {
  return _VPNState.fromJson(json);
}

/// @nodoc
mixin _$VPNState {
  AccessControl? get accessControl => throw _privateConstructorUsedError;
  VpnProps get vpnProps => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VPNStateCopyWith<VPNState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VPNStateCopyWith<$Res> {
  factory $VPNStateCopyWith(VPNState value, $Res Function(VPNState) then) =
      _$VPNStateCopyWithImpl<$Res, VPNState>;
  @useResult
  $Res call({AccessControl? accessControl, VpnProps vpnProps});

  $AccessControlCopyWith<$Res>? get accessControl;
  $VpnPropsCopyWith<$Res> get vpnProps;
}

/// @nodoc
class _$VPNStateCopyWithImpl<$Res, $Val extends VPNState>
    implements $VPNStateCopyWith<$Res> {
  _$VPNStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessControl = freezed,
    Object? vpnProps = null,
  }) {
    return _then(_value.copyWith(
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      vpnProps: null == vpnProps
          ? _value.vpnProps
          : vpnProps // ignore: cast_nullable_to_non_nullable
              as VpnProps,
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

  @override
  @pragma('vm:prefer-inline')
  $VpnPropsCopyWith<$Res> get vpnProps {
    return $VpnPropsCopyWith<$Res>(_value.vpnProps, (value) {
      return _then(_value.copyWith(vpnProps: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VPNStateImplCopyWith<$Res>
    implements $VPNStateCopyWith<$Res> {
  factory _$$VPNStateImplCopyWith(
          _$VPNStateImpl value, $Res Function(_$VPNStateImpl) then) =
      __$$VPNStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AccessControl? accessControl, VpnProps vpnProps});

  @override
  $AccessControlCopyWith<$Res>? get accessControl;
  @override
  $VpnPropsCopyWith<$Res> get vpnProps;
}

/// @nodoc
class __$$VPNStateImplCopyWithImpl<$Res>
    extends _$VPNStateCopyWithImpl<$Res, _$VPNStateImpl>
    implements _$$VPNStateImplCopyWith<$Res> {
  __$$VPNStateImplCopyWithImpl(
      _$VPNStateImpl _value, $Res Function(_$VPNStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessControl = freezed,
    Object? vpnProps = null,
  }) {
    return _then(_$VPNStateImpl(
      accessControl: freezed == accessControl
          ? _value.accessControl
          : accessControl // ignore: cast_nullable_to_non_nullable
              as AccessControl?,
      vpnProps: null == vpnProps
          ? _value.vpnProps
          : vpnProps // ignore: cast_nullable_to_non_nullable
              as VpnProps,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VPNStateImpl implements _VPNState {
  const _$VPNStateImpl({required this.accessControl, required this.vpnProps});

  factory _$VPNStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$VPNStateImplFromJson(json);

  @override
  final AccessControl? accessControl;
  @override
  final VpnProps vpnProps;

  @override
  String toString() {
    return 'VPNState(accessControl: $accessControl, vpnProps: $vpnProps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VPNStateImpl &&
            (identical(other.accessControl, accessControl) ||
                other.accessControl == accessControl) &&
            (identical(other.vpnProps, vpnProps) ||
                other.vpnProps == vpnProps));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, accessControl, vpnProps);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VPNStateImplCopyWith<_$VPNStateImpl> get copyWith =>
      __$$VPNStateImplCopyWithImpl<_$VPNStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VPNStateImplToJson(
      this,
    );
  }
}

abstract class _VPNState implements VPNState {
  const factory _VPNState(
      {required final AccessControl? accessControl,
      required final VpnProps vpnProps}) = _$VPNStateImpl;

  factory _VPNState.fromJson(Map<String, dynamic> json) =
      _$VPNStateImpl.fromJson;

  @override
  AccessControl? get accessControl;
  @override
  VpnProps get vpnProps;
  @override
  @JsonKey(ignore: true)
  _$$VPNStateImplCopyWith<_$VPNStateImpl> get copyWith =>
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

VpnProps _$VpnPropsFromJson(Map<String, dynamic> json) {
  return _VpnProps.fromJson(json);
}

/// @nodoc
mixin _$VpnProps {
  bool get enable => throw _privateConstructorUsedError;
  bool get systemProxy => throw _privateConstructorUsedError;
  bool get ipv6 => throw _privateConstructorUsedError;
  bool get allowBypass => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $VpnPropsCopyWith<VpnProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VpnPropsCopyWith<$Res> {
  factory $VpnPropsCopyWith(VpnProps value, $Res Function(VpnProps) then) =
      _$VpnPropsCopyWithImpl<$Res, VpnProps>;
  @useResult
  $Res call({bool enable, bool systemProxy, bool ipv6, bool allowBypass});
}

/// @nodoc
class _$VpnPropsCopyWithImpl<$Res, $Val extends VpnProps>
    implements $VpnPropsCopyWith<$Res> {
  _$VpnPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? systemProxy = null,
    Object? ipv6 = null,
    Object? allowBypass = null,
  }) {
    return _then(_value.copyWith(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VpnPropsImplCopyWith<$Res>
    implements $VpnPropsCopyWith<$Res> {
  factory _$$VpnPropsImplCopyWith(
          _$VpnPropsImpl value, $Res Function(_$VpnPropsImpl) then) =
      __$$VpnPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enable, bool systemProxy, bool ipv6, bool allowBypass});
}

/// @nodoc
class __$$VpnPropsImplCopyWithImpl<$Res>
    extends _$VpnPropsCopyWithImpl<$Res, _$VpnPropsImpl>
    implements _$$VpnPropsImplCopyWith<$Res> {
  __$$VpnPropsImplCopyWithImpl(
      _$VpnPropsImpl _value, $Res Function(_$VpnPropsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enable = null,
    Object? systemProxy = null,
    Object? ipv6 = null,
    Object? allowBypass = null,
  }) {
    return _then(_$VpnPropsImpl(
      enable: null == enable
          ? _value.enable
          : enable // ignore: cast_nullable_to_non_nullable
              as bool,
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
      ipv6: null == ipv6
          ? _value.ipv6
          : ipv6 // ignore: cast_nullable_to_non_nullable
              as bool,
      allowBypass: null == allowBypass
          ? _value.allowBypass
          : allowBypass // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VpnPropsImpl implements _VpnProps {
  const _$VpnPropsImpl(
      {this.enable = true,
      this.systemProxy = true,
      this.ipv6 = false,
      this.allowBypass = true});

  factory _$VpnPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$VpnPropsImplFromJson(json);

  @override
  @JsonKey()
  final bool enable;
  @override
  @JsonKey()
  final bool systemProxy;
  @override
  @JsonKey()
  final bool ipv6;
  @override
  @JsonKey()
  final bool allowBypass;

  @override
  String toString() {
    return 'VpnProps(enable: $enable, systemProxy: $systemProxy, ipv6: $ipv6, allowBypass: $allowBypass)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VpnPropsImpl &&
            (identical(other.enable, enable) || other.enable == enable) &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy) &&
            (identical(other.ipv6, ipv6) || other.ipv6 == ipv6) &&
            (identical(other.allowBypass, allowBypass) ||
                other.allowBypass == allowBypass));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, enable, systemProxy, ipv6, allowBypass);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VpnPropsImplCopyWith<_$VpnPropsImpl> get copyWith =>
      __$$VpnPropsImplCopyWithImpl<_$VpnPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VpnPropsImplToJson(
      this,
    );
  }
}

abstract class _VpnProps implements VpnProps {
  const factory _VpnProps(
      {final bool enable,
      final bool systemProxy,
      final bool ipv6,
      final bool allowBypass}) = _$VpnPropsImpl;

  factory _VpnProps.fromJson(Map<String, dynamic> json) =
      _$VpnPropsImpl.fromJson;

  @override
  bool get enable;
  @override
  bool get systemProxy;
  @override
  bool get ipv6;
  @override
  bool get allowBypass;
  @override
  @JsonKey(ignore: true)
  _$$VpnPropsImplCopyWith<_$VpnPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DesktopProps _$DesktopPropsFromJson(Map<String, dynamic> json) {
  return _DesktopProps.fromJson(json);
}

/// @nodoc
mixin _$DesktopProps {
  bool get systemProxy => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DesktopPropsCopyWith<DesktopProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DesktopPropsCopyWith<$Res> {
  factory $DesktopPropsCopyWith(
          DesktopProps value, $Res Function(DesktopProps) then) =
      _$DesktopPropsCopyWithImpl<$Res, DesktopProps>;
  @useResult
  $Res call({bool systemProxy});
}

/// @nodoc
class _$DesktopPropsCopyWithImpl<$Res, $Val extends DesktopProps>
    implements $DesktopPropsCopyWith<$Res> {
  _$DesktopPropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? systemProxy = null,
  }) {
    return _then(_value.copyWith(
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DesktopPropsImplCopyWith<$Res>
    implements $DesktopPropsCopyWith<$Res> {
  factory _$$DesktopPropsImplCopyWith(
          _$DesktopPropsImpl value, $Res Function(_$DesktopPropsImpl) then) =
      __$$DesktopPropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool systemProxy});
}

/// @nodoc
class __$$DesktopPropsImplCopyWithImpl<$Res>
    extends _$DesktopPropsCopyWithImpl<$Res, _$DesktopPropsImpl>
    implements _$$DesktopPropsImplCopyWith<$Res> {
  __$$DesktopPropsImplCopyWithImpl(
      _$DesktopPropsImpl _value, $Res Function(_$DesktopPropsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? systemProxy = null,
  }) {
    return _then(_$DesktopPropsImpl(
      systemProxy: null == systemProxy
          ? _value.systemProxy
          : systemProxy // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DesktopPropsImpl implements _DesktopProps {
  const _$DesktopPropsImpl({this.systemProxy = true});

  factory _$DesktopPropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DesktopPropsImplFromJson(json);

  @override
  @JsonKey()
  final bool systemProxy;

  @override
  String toString() {
    return 'DesktopProps(systemProxy: $systemProxy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DesktopPropsImpl &&
            (identical(other.systemProxy, systemProxy) ||
                other.systemProxy == systemProxy));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, systemProxy);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DesktopPropsImplCopyWith<_$DesktopPropsImpl> get copyWith =>
      __$$DesktopPropsImplCopyWithImpl<_$DesktopPropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DesktopPropsImplToJson(
      this,
    );
  }
}

abstract class _DesktopProps implements DesktopProps {
  const factory _DesktopProps({final bool systemProxy}) = _$DesktopPropsImpl;

  factory _DesktopProps.fromJson(Map<String, dynamic> json) =
      _$DesktopPropsImpl.fromJson;

  @override
  bool get systemProxy;
  @override
  @JsonKey(ignore: true)
  _$$DesktopPropsImplCopyWith<_$DesktopPropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScaleProps _$ScalePropsFromJson(Map<String, dynamic> json) {
  return _ScaleProps.fromJson(json);
}

/// @nodoc
mixin _$ScaleProps {
  bool get custom => throw _privateConstructorUsedError;
  double get scale => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScalePropsCopyWith<ScaleProps> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScalePropsCopyWith<$Res> {
  factory $ScalePropsCopyWith(
          ScaleProps value, $Res Function(ScaleProps) then) =
      _$ScalePropsCopyWithImpl<$Res, ScaleProps>;
  @useResult
  $Res call({bool custom, double scale});
}

/// @nodoc
class _$ScalePropsCopyWithImpl<$Res, $Val extends ScaleProps>
    implements $ScalePropsCopyWith<$Res> {
  _$ScalePropsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? custom = null,
    Object? scale = null,
  }) {
    return _then(_value.copyWith(
      custom: null == custom
          ? _value.custom
          : custom // ignore: cast_nullable_to_non_nullable
              as bool,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScalePropsImplCopyWith<$Res>
    implements $ScalePropsCopyWith<$Res> {
  factory _$$ScalePropsImplCopyWith(
          _$ScalePropsImpl value, $Res Function(_$ScalePropsImpl) then) =
      __$$ScalePropsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool custom, double scale});
}

/// @nodoc
class __$$ScalePropsImplCopyWithImpl<$Res>
    extends _$ScalePropsCopyWithImpl<$Res, _$ScalePropsImpl>
    implements _$$ScalePropsImplCopyWith<$Res> {
  __$$ScalePropsImplCopyWithImpl(
      _$ScalePropsImpl _value, $Res Function(_$ScalePropsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? custom = null,
    Object? scale = null,
  }) {
    return _then(_$ScalePropsImpl(
      custom: null == custom
          ? _value.custom
          : custom // ignore: cast_nullable_to_non_nullable
              as bool,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScalePropsImpl implements _ScaleProps {
  const _$ScalePropsImpl(
      {this.custom = false, this.scale = defaultCustomFontSizeScale});

  factory _$ScalePropsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScalePropsImplFromJson(json);

  @override
  @JsonKey()
  final bool custom;
  @override
  @JsonKey()
  final double scale;

  @override
  String toString() {
    return 'ScaleProps(custom: $custom, scale: $scale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScalePropsImpl &&
            (identical(other.custom, custom) || other.custom == custom) &&
            (identical(other.scale, scale) || other.scale == scale));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, custom, scale);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScalePropsImplCopyWith<_$ScalePropsImpl> get copyWith =>
      __$$ScalePropsImplCopyWithImpl<_$ScalePropsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScalePropsImplToJson(
      this,
    );
  }
}

abstract class _ScaleProps implements ScaleProps {
  const factory _ScaleProps({final bool custom, final double scale}) =
      _$ScalePropsImpl;

  factory _ScaleProps.fromJson(Map<String, dynamic> json) =
      _$ScalePropsImpl.fromJson;

  @override
  bool get custom;
  @override
  double get scale;
  @override
  @JsonKey(ignore: true)
  _$$ScalePropsImplCopyWith<_$ScalePropsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

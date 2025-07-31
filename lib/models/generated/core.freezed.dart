// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../core.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SetupParams {

@JsonKey(name: 'selected-map') Map<String, String> get selectedMap;@JsonKey(name: 'test-url') String get testUrl;
/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupParamsCopyWith<SetupParams> get copyWith => _$SetupParamsCopyWithImpl<SetupParams>(this as SetupParams, _$identity);

  /// Serializes this SetupParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupParams&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedMap),testUrl);

@override
String toString() {
  return 'SetupParams(selectedMap: $selectedMap, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class $SetupParamsCopyWith<$Res>  {
  factory $SetupParamsCopyWith(SetupParams value, $Res Function(SetupParams) _then) = _$SetupParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'selected-map') Map<String, String> selectedMap,@JsonKey(name: 'test-url') String testUrl
});




}
/// @nodoc
class _$SetupParamsCopyWithImpl<$Res>
    implements $SetupParamsCopyWith<$Res> {
  _$SetupParamsCopyWithImpl(this._self, this._then);

  final SetupParams _self;
  final $Res Function(SetupParams) _then;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedMap = null,Object? testUrl = null,}) {
  return _then(_self.copyWith(
selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetupParams].
extension SetupParamsPatterns on SetupParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupParams value)  $default,){
final _that = this;
switch (_that) {
case _SetupParams():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupParams value)?  $default,){
final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'selected-map')  Map<String, String> selectedMap, @JsonKey(name: 'test-url')  String testUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.selectedMap,_that.testUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'selected-map')  Map<String, String> selectedMap, @JsonKey(name: 'test-url')  String testUrl)  $default,) {final _that = this;
switch (_that) {
case _SetupParams():
return $default(_that.selectedMap,_that.testUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'selected-map')  Map<String, String> selectedMap, @JsonKey(name: 'test-url')  String testUrl)?  $default,) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.selectedMap,_that.testUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupParams implements SetupParams {
  const _SetupParams({@JsonKey(name: 'selected-map') required final  Map<String, String> selectedMap, @JsonKey(name: 'test-url') required this.testUrl}): _selectedMap = selectedMap;
  factory _SetupParams.fromJson(Map<String, dynamic> json) => _$SetupParamsFromJson(json);

 final  Map<String, String> _selectedMap;
@override@JsonKey(name: 'selected-map') Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override@JsonKey(name: 'test-url') final  String testUrl;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupParamsCopyWith<_SetupParams> get copyWith => __$SetupParamsCopyWithImpl<_SetupParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetupParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupParams&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedMap),testUrl);

@override
String toString() {
  return 'SetupParams(selectedMap: $selectedMap, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class _$SetupParamsCopyWith<$Res> implements $SetupParamsCopyWith<$Res> {
  factory _$SetupParamsCopyWith(_SetupParams value, $Res Function(_SetupParams) _then) = __$SetupParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'selected-map') Map<String, String> selectedMap,@JsonKey(name: 'test-url') String testUrl
});




}
/// @nodoc
class __$SetupParamsCopyWithImpl<$Res>
    implements _$SetupParamsCopyWith<$Res> {
  __$SetupParamsCopyWithImpl(this._self, this._then);

  final _SetupParams _self;
  final $Res Function(_SetupParams) _then;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedMap = null,Object? testUrl = null,}) {
  return _then(_SetupParams(
selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpdateParams {

 Tun get tun;@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'find-process-mode') FindProcessMode get findProcessMode; Mode get mode;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController;@JsonKey(name: 'unified-delay') bool get unifiedDelay;
/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateParamsCopyWith<UpdateParams> get copyWith => _$UpdateParamsCopyWithImpl<UpdateParams>(this as UpdateParams, _$identity);

  /// Serializes this UpdateParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateParams&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tun,mixedPort,allowLan,findProcessMode,mode,logLevel,ipv6,tcpConcurrent,externalController,unifiedDelay);

@override
String toString() {
  return 'UpdateParams(tun: $tun, mixedPort: $mixedPort, allowLan: $allowLan, findProcessMode: $findProcessMode, mode: $mode, logLevel: $logLevel, ipv6: $ipv6, tcpConcurrent: $tcpConcurrent, externalController: $externalController, unifiedDelay: $unifiedDelay)';
}


}

/// @nodoc
abstract mixin class $UpdateParamsCopyWith<$Res>  {
  factory $UpdateParamsCopyWith(UpdateParams value, $Res Function(UpdateParams) _then) = _$UpdateParamsCopyWithImpl;
@useResult
$Res call({
 Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController,@JsonKey(name: 'unified-delay') bool unifiedDelay
});


$TunCopyWith<$Res> get tun;

}
/// @nodoc
class _$UpdateParamsCopyWithImpl<$Res>
    implements $UpdateParamsCopyWith<$Res> {
  _$UpdateParamsCopyWithImpl(this._self, this._then);

  final UpdateParams _self;
  final $Res Function(UpdateParams) _then;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = null,Object? tcpConcurrent = null,Object? externalController = null,Object? unifiedDelay = null,}) {
  return _then(_self.copyWith(
tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// Adds pattern-matching-related methods to [UpdateParams].
extension UpdateParamsPatterns on UpdateParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateParams value)  $default,){
final _that = this;
switch (_that) {
case _UpdateParams():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateParams value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay)  $default,) {final _that = this;
switch (_that) {
case _UpdateParams():
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay)?  $default,) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateParams implements UpdateParams {
  const _UpdateParams({required this.tun, @JsonKey(name: 'mixed-port') required this.mixedPort, @JsonKey(name: 'allow-lan') required this.allowLan, @JsonKey(name: 'find-process-mode') required this.findProcessMode, required this.mode, @JsonKey(name: 'log-level') required this.logLevel, required this.ipv6, @JsonKey(name: 'tcp-concurrent') required this.tcpConcurrent, @JsonKey(name: 'external-controller') required this.externalController, @JsonKey(name: 'unified-delay') required this.unifiedDelay});
  factory _UpdateParams.fromJson(Map<String, dynamic> json) => _$UpdateParamsFromJson(json);

@override final  Tun tun;
@override@JsonKey(name: 'mixed-port') final  int mixedPort;
@override@JsonKey(name: 'allow-lan') final  bool allowLan;
@override@JsonKey(name: 'find-process-mode') final  FindProcessMode findProcessMode;
@override final  Mode mode;
@override@JsonKey(name: 'log-level') final  LogLevel logLevel;
@override final  bool ipv6;
@override@JsonKey(name: 'tcp-concurrent') final  bool tcpConcurrent;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
@override@JsonKey(name: 'unified-delay') final  bool unifiedDelay;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateParamsCopyWith<_UpdateParams> get copyWith => __$UpdateParamsCopyWithImpl<_UpdateParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateParams&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tun,mixedPort,allowLan,findProcessMode,mode,logLevel,ipv6,tcpConcurrent,externalController,unifiedDelay);

@override
String toString() {
  return 'UpdateParams(tun: $tun, mixedPort: $mixedPort, allowLan: $allowLan, findProcessMode: $findProcessMode, mode: $mode, logLevel: $logLevel, ipv6: $ipv6, tcpConcurrent: $tcpConcurrent, externalController: $externalController, unifiedDelay: $unifiedDelay)';
}


}

/// @nodoc
abstract mixin class _$UpdateParamsCopyWith<$Res> implements $UpdateParamsCopyWith<$Res> {
  factory _$UpdateParamsCopyWith(_UpdateParams value, $Res Function(_UpdateParams) _then) = __$UpdateParamsCopyWithImpl;
@override @useResult
$Res call({
 Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController,@JsonKey(name: 'unified-delay') bool unifiedDelay
});


@override $TunCopyWith<$Res> get tun;

}
/// @nodoc
class __$UpdateParamsCopyWithImpl<$Res>
    implements _$UpdateParamsCopyWith<$Res> {
  __$UpdateParamsCopyWithImpl(this._self, this._then);

  final _UpdateParams _self;
  final $Res Function(_UpdateParams) _then;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = null,Object? tcpConcurrent = null,Object? externalController = null,Object? unifiedDelay = null,}) {
  return _then(_UpdateParams(
tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,tcpConcurrent: null == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,unifiedDelay: null == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TunCopyWith<$Res> get tun {
  
  return $TunCopyWith<$Res>(_self.tun, (value) {
    return _then(_self.copyWith(tun: value));
  });
}
}


/// @nodoc
mixin _$VpnOptions {

 bool get enable; int get port; bool get ipv6; bool get dnsHijacking; AccessControl get accessControl; bool get allowBypass; bool get systemProxy; List<String> get bypassDomain; String get stack; List<String> get routeAddress;
/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<VpnOptions> get copyWith => _$VpnOptionsCopyWithImpl<VpnOptions>(this as VpnOptions, _$identity);

  /// Serializes this VpnOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.port, port) || other.port == port)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, bypassDomain)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.routeAddress, routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,port,ipv6,dnsHijacking,accessControl,allowBypass,systemProxy,const DeepCollectionEquality().hash(bypassDomain),stack,const DeepCollectionEquality().hash(routeAddress));

@override
String toString() {
  return 'VpnOptions(enable: $enable, port: $port, ipv6: $ipv6, dnsHijacking: $dnsHijacking, accessControl: $accessControl, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, stack: $stack, routeAddress: $routeAddress)';
}


}

/// @nodoc
abstract mixin class $VpnOptionsCopyWith<$Res>  {
  factory $VpnOptionsCopyWith(VpnOptions value, $Res Function(VpnOptions) _then) = _$VpnOptionsCopyWithImpl;
@useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControl accessControl, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress
});


$AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class _$VpnOptionsCopyWithImpl<$Res>
    implements $VpnOptionsCopyWith<$Res> {
  _$VpnOptionsCopyWithImpl(this._self, this._then);

  final VpnOptions _self;
  final $Res Function(VpnOptions) _then;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControl = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as String,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnOptions].
extension VpnOptionsPatterns on VpnOptions {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnOptions value)  $default,){
final _that = this;
switch (_that) {
case _VpnOptions():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnOptions value)?  $default,){
final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControl accessControl,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControl,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControl accessControl,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress)  $default,) {final _that = this;
switch (_that) {
case _VpnOptions():
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControl,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControl accessControl,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress)?  $default,) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControl,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnOptions implements VpnOptions {
  const _VpnOptions({required this.enable, required this.port, required this.ipv6, required this.dnsHijacking, required this.accessControl, required this.allowBypass, required this.systemProxy, required final  List<String> bypassDomain, required this.stack, final  List<String> routeAddress = const []}): _bypassDomain = bypassDomain,_routeAddress = routeAddress;
  factory _VpnOptions.fromJson(Map<String, dynamic> json) => _$VpnOptionsFromJson(json);

@override final  bool enable;
@override final  int port;
@override final  bool ipv6;
@override final  bool dnsHijacking;
@override final  AccessControl accessControl;
@override final  bool allowBypass;
@override final  bool systemProxy;
 final  List<String> _bypassDomain;
@override List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}

@override final  String stack;
 final  List<String> _routeAddress;
@override@JsonKey() List<String> get routeAddress {
  if (_routeAddress is EqualUnmodifiableListView) return _routeAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routeAddress);
}


/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnOptionsCopyWith<_VpnOptions> get copyWith => __$VpnOptionsCopyWithImpl<_VpnOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VpnOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.port, port) || other.port == port)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other._bypassDomain, _bypassDomain)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other._routeAddress, _routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,port,ipv6,dnsHijacking,accessControl,allowBypass,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),stack,const DeepCollectionEquality().hash(_routeAddress));

@override
String toString() {
  return 'VpnOptions(enable: $enable, port: $port, ipv6: $ipv6, dnsHijacking: $dnsHijacking, accessControl: $accessControl, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, stack: $stack, routeAddress: $routeAddress)';
}


}

/// @nodoc
abstract mixin class _$VpnOptionsCopyWith<$Res> implements $VpnOptionsCopyWith<$Res> {
  factory _$VpnOptionsCopyWith(_VpnOptions value, $Res Function(_VpnOptions) _then) = __$VpnOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControl accessControl, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress
});


@override $AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class __$VpnOptionsCopyWithImpl<$Res>
    implements _$VpnOptionsCopyWith<$Res> {
  __$VpnOptionsCopyWithImpl(this._self, this._then);

  final _VpnOptions _self;
  final $Res Function(_VpnOptions) _then;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControl = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,}) {
  return _then(_VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as String,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
  });
}
}


/// @nodoc
mixin _$InitParams {

@JsonKey(name: 'home-dir') String get homeDir; int get version;
/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitParamsCopyWith<InitParams> get copyWith => _$InitParamsCopyWithImpl<InitParams>(this as InitParams, _$identity);

  /// Serializes this InitParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitParams&&(identical(other.homeDir, homeDir) || other.homeDir == homeDir)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeDir,version);

@override
String toString() {
  return 'InitParams(homeDir: $homeDir, version: $version)';
}


}

/// @nodoc
abstract mixin class $InitParamsCopyWith<$Res>  {
  factory $InitParamsCopyWith(InitParams value, $Res Function(InitParams) _then) = _$InitParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'home-dir') String homeDir, int version
});




}
/// @nodoc
class _$InitParamsCopyWithImpl<$Res>
    implements $InitParamsCopyWith<$Res> {
  _$InitParamsCopyWithImpl(this._self, this._then);

  final InitParams _self;
  final $Res Function(InitParams) _then;

/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homeDir = null,Object? version = null,}) {
  return _then(_self.copyWith(
homeDir: null == homeDir ? _self.homeDir : homeDir // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InitParams].
extension InitParamsPatterns on InitParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitParams value)  $default,){
final _that = this;
switch (_that) {
case _InitParams():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitParams value)?  $default,){
final _that = this;
switch (_that) {
case _InitParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'home-dir')  String homeDir,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitParams() when $default != null:
return $default(_that.homeDir,_that.version);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'home-dir')  String homeDir,  int version)  $default,) {final _that = this;
switch (_that) {
case _InitParams():
return $default(_that.homeDir,_that.version);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'home-dir')  String homeDir,  int version)?  $default,) {final _that = this;
switch (_that) {
case _InitParams() when $default != null:
return $default(_that.homeDir,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InitParams implements InitParams {
  const _InitParams({@JsonKey(name: 'home-dir') required this.homeDir, required this.version});
  factory _InitParams.fromJson(Map<String, dynamic> json) => _$InitParamsFromJson(json);

@override@JsonKey(name: 'home-dir') final  String homeDir;
@override final  int version;

/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitParamsCopyWith<_InitParams> get copyWith => __$InitParamsCopyWithImpl<_InitParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InitParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitParams&&(identical(other.homeDir, homeDir) || other.homeDir == homeDir)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homeDir,version);

@override
String toString() {
  return 'InitParams(homeDir: $homeDir, version: $version)';
}


}

/// @nodoc
abstract mixin class _$InitParamsCopyWith<$Res> implements $InitParamsCopyWith<$Res> {
  factory _$InitParamsCopyWith(_InitParams value, $Res Function(_InitParams) _then) = __$InitParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'home-dir') String homeDir, int version
});




}
/// @nodoc
class __$InitParamsCopyWithImpl<$Res>
    implements _$InitParamsCopyWith<$Res> {
  __$InitParamsCopyWithImpl(this._self, this._then);

  final _InitParams _self;
  final $Res Function(_InitParams) _then;

/// Create a copy of InitParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homeDir = null,Object? version = null,}) {
  return _then(_InitParams(
homeDir: null == homeDir ? _self.homeDir : homeDir // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ChangeProxyParams {

@JsonKey(name: 'group-name') String get groupName;@JsonKey(name: 'proxy-name') String get proxyName;
/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeProxyParamsCopyWith<ChangeProxyParams> get copyWith => _$ChangeProxyParamsCopyWithImpl<ChangeProxyParams>(this as ChangeProxyParams, _$identity);

  /// Serializes this ChangeProxyParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeProxyParams&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupName,proxyName);

@override
String toString() {
  return 'ChangeProxyParams(groupName: $groupName, proxyName: $proxyName)';
}


}

/// @nodoc
abstract mixin class $ChangeProxyParamsCopyWith<$Res>  {
  factory $ChangeProxyParamsCopyWith(ChangeProxyParams value, $Res Function(ChangeProxyParams) _then) = _$ChangeProxyParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'group-name') String groupName,@JsonKey(name: 'proxy-name') String proxyName
});




}
/// @nodoc
class _$ChangeProxyParamsCopyWithImpl<$Res>
    implements $ChangeProxyParamsCopyWith<$Res> {
  _$ChangeProxyParamsCopyWithImpl(this._self, this._then);

  final ChangeProxyParams _self;
  final $Res Function(ChangeProxyParams) _then;

/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupName = null,Object? proxyName = null,}) {
  return _then(_self.copyWith(
groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeProxyParams].
extension ChangeProxyParamsPatterns on ChangeProxyParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeProxyParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeProxyParams value)  $default,){
final _that = this;
switch (_that) {
case _ChangeProxyParams():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeProxyParams value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'group-name')  String groupName, @JsonKey(name: 'proxy-name')  String proxyName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
return $default(_that.groupName,_that.proxyName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'group-name')  String groupName, @JsonKey(name: 'proxy-name')  String proxyName)  $default,) {final _that = this;
switch (_that) {
case _ChangeProxyParams():
return $default(_that.groupName,_that.proxyName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'group-name')  String groupName, @JsonKey(name: 'proxy-name')  String proxyName)?  $default,) {final _that = this;
switch (_that) {
case _ChangeProxyParams() when $default != null:
return $default(_that.groupName,_that.proxyName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeProxyParams implements ChangeProxyParams {
  const _ChangeProxyParams({@JsonKey(name: 'group-name') required this.groupName, @JsonKey(name: 'proxy-name') required this.proxyName});
  factory _ChangeProxyParams.fromJson(Map<String, dynamic> json) => _$ChangeProxyParamsFromJson(json);

@override@JsonKey(name: 'group-name') final  String groupName;
@override@JsonKey(name: 'proxy-name') final  String proxyName;

/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeProxyParamsCopyWith<_ChangeProxyParams> get copyWith => __$ChangeProxyParamsCopyWithImpl<_ChangeProxyParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeProxyParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeProxyParams&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupName,proxyName);

@override
String toString() {
  return 'ChangeProxyParams(groupName: $groupName, proxyName: $proxyName)';
}


}

/// @nodoc
abstract mixin class _$ChangeProxyParamsCopyWith<$Res> implements $ChangeProxyParamsCopyWith<$Res> {
  factory _$ChangeProxyParamsCopyWith(_ChangeProxyParams value, $Res Function(_ChangeProxyParams) _then) = __$ChangeProxyParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'group-name') String groupName,@JsonKey(name: 'proxy-name') String proxyName
});




}
/// @nodoc
class __$ChangeProxyParamsCopyWithImpl<$Res>
    implements _$ChangeProxyParamsCopyWith<$Res> {
  __$ChangeProxyParamsCopyWithImpl(this._self, this._then);

  final _ChangeProxyParams _self;
  final $Res Function(_ChangeProxyParams) _then;

/// Create a copy of ChangeProxyParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupName = null,Object? proxyName = null,}) {
  return _then(_ChangeProxyParams(
groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpdateGeoDataParams {

@JsonKey(name: 'geo-type') String get geoType;@JsonKey(name: 'geo-name') String get geoName;
/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGeoDataParamsCopyWith<UpdateGeoDataParams> get copyWith => _$UpdateGeoDataParamsCopyWithImpl<UpdateGeoDataParams>(this as UpdateGeoDataParams, _$identity);

  /// Serializes this UpdateGeoDataParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGeoDataParams&&(identical(other.geoType, geoType) || other.geoType == geoType)&&(identical(other.geoName, geoName) || other.geoName == geoName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geoType,geoName);

@override
String toString() {
  return 'UpdateGeoDataParams(geoType: $geoType, geoName: $geoName)';
}


}

/// @nodoc
abstract mixin class $UpdateGeoDataParamsCopyWith<$Res>  {
  factory $UpdateGeoDataParamsCopyWith(UpdateGeoDataParams value, $Res Function(UpdateGeoDataParams) _then) = _$UpdateGeoDataParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'geo-type') String geoType,@JsonKey(name: 'geo-name') String geoName
});




}
/// @nodoc
class _$UpdateGeoDataParamsCopyWithImpl<$Res>
    implements $UpdateGeoDataParamsCopyWith<$Res> {
  _$UpdateGeoDataParamsCopyWithImpl(this._self, this._then);

  final UpdateGeoDataParams _self;
  final $Res Function(UpdateGeoDataParams) _then;

/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? geoType = null,Object? geoName = null,}) {
  return _then(_self.copyWith(
geoType: null == geoType ? _self.geoType : geoType // ignore: cast_nullable_to_non_nullable
as String,geoName: null == geoName ? _self.geoName : geoName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGeoDataParams].
extension UpdateGeoDataParamsPatterns on UpdateGeoDataParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGeoDataParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGeoDataParams value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGeoDataParams():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGeoDataParams value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'geo-type')  String geoType, @JsonKey(name: 'geo-name')  String geoName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
return $default(_that.geoType,_that.geoName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'geo-type')  String geoType, @JsonKey(name: 'geo-name')  String geoName)  $default,) {final _that = this;
switch (_that) {
case _UpdateGeoDataParams():
return $default(_that.geoType,_that.geoName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'geo-type')  String geoType, @JsonKey(name: 'geo-name')  String geoName)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGeoDataParams() when $default != null:
return $default(_that.geoType,_that.geoName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateGeoDataParams implements UpdateGeoDataParams {
  const _UpdateGeoDataParams({@JsonKey(name: 'geo-type') required this.geoType, @JsonKey(name: 'geo-name') required this.geoName});
  factory _UpdateGeoDataParams.fromJson(Map<String, dynamic> json) => _$UpdateGeoDataParamsFromJson(json);

@override@JsonKey(name: 'geo-type') final  String geoType;
@override@JsonKey(name: 'geo-name') final  String geoName;

/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGeoDataParamsCopyWith<_UpdateGeoDataParams> get copyWith => __$UpdateGeoDataParamsCopyWithImpl<_UpdateGeoDataParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGeoDataParamsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGeoDataParams&&(identical(other.geoType, geoType) || other.geoType == geoType)&&(identical(other.geoName, geoName) || other.geoName == geoName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,geoType,geoName);

@override
String toString() {
  return 'UpdateGeoDataParams(geoType: $geoType, geoName: $geoName)';
}


}

/// @nodoc
abstract mixin class _$UpdateGeoDataParamsCopyWith<$Res> implements $UpdateGeoDataParamsCopyWith<$Res> {
  factory _$UpdateGeoDataParamsCopyWith(_UpdateGeoDataParams value, $Res Function(_UpdateGeoDataParams) _then) = __$UpdateGeoDataParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'geo-type') String geoType,@JsonKey(name: 'geo-name') String geoName
});




}
/// @nodoc
class __$UpdateGeoDataParamsCopyWithImpl<$Res>
    implements _$UpdateGeoDataParamsCopyWith<$Res> {
  __$UpdateGeoDataParamsCopyWithImpl(this._self, this._then);

  final _UpdateGeoDataParams _self;
  final $Res Function(_UpdateGeoDataParams) _then;

/// Create a copy of UpdateGeoDataParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? geoType = null,Object? geoName = null,}) {
  return _then(_UpdateGeoDataParams(
geoType: null == geoType ? _self.geoType : geoType // ignore: cast_nullable_to_non_nullable
as String,geoName: null == geoName ? _self.geoName : geoName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CoreEvent {

 CoreEventType get type; dynamic get data;
/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreEventCopyWith<CoreEvent> get copyWith => _$CoreEventCopyWithImpl<CoreEvent>(this as CoreEvent, _$identity);

  /// Serializes this CoreEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreEvent&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'CoreEvent(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $CoreEventCopyWith<$Res>  {
  factory $CoreEventCopyWith(CoreEvent value, $Res Function(CoreEvent) _then) = _$CoreEventCopyWithImpl;
@useResult
$Res call({
 CoreEventType type, dynamic data
});




}
/// @nodoc
class _$CoreEventCopyWithImpl<$Res>
    implements $CoreEventCopyWith<$Res> {
  _$CoreEventCopyWithImpl(this._self, this._then);

  final CoreEvent _self;
  final $Res Function(CoreEvent) _then;

/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoreEventType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreEvent].
extension CoreEventPatterns on CoreEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreEvent value)  $default,){
final _that = this;
switch (_that) {
case _CoreEvent():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CoreEventType type,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
return $default(_that.type,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CoreEventType type,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _CoreEvent():
return $default(_that.type,_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CoreEventType type,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _CoreEvent() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreEvent implements CoreEvent {
  const _CoreEvent({required this.type, this.data});
  factory _CoreEvent.fromJson(Map<String, dynamic> json) => _$CoreEventFromJson(json);

@override final  CoreEventType type;
@override final  dynamic data;

/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreEventCopyWith<_CoreEvent> get copyWith => __$CoreEventCopyWithImpl<_CoreEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreEvent&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'CoreEvent(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$CoreEventCopyWith<$Res> implements $CoreEventCopyWith<$Res> {
  factory _$CoreEventCopyWith(_CoreEvent value, $Res Function(_CoreEvent) _then) = __$CoreEventCopyWithImpl;
@override @useResult
$Res call({
 CoreEventType type, dynamic data
});




}
/// @nodoc
class __$CoreEventCopyWithImpl<$Res>
    implements _$CoreEventCopyWith<$Res> {
  __$CoreEventCopyWithImpl(this._self, this._then);

  final _CoreEvent _self;
  final $Res Function(_CoreEvent) _then;

/// Create a copy of CoreEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_CoreEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as CoreEventType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}


/// @nodoc
mixin _$InvokeMessage {

 InvokeMessageType get type; dynamic get data;
/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvokeMessageCopyWith<InvokeMessage> get copyWith => _$InvokeMessageCopyWithImpl<InvokeMessage>(this as InvokeMessage, _$identity);

  /// Serializes this InvokeMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvokeMessage&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'InvokeMessage(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $InvokeMessageCopyWith<$Res>  {
  factory $InvokeMessageCopyWith(InvokeMessage value, $Res Function(InvokeMessage) _then) = _$InvokeMessageCopyWithImpl;
@useResult
$Res call({
 InvokeMessageType type, dynamic data
});




}
/// @nodoc
class _$InvokeMessageCopyWithImpl<$Res>
    implements $InvokeMessageCopyWith<$Res> {
  _$InvokeMessageCopyWithImpl(this._self, this._then);

  final InvokeMessage _self;
  final $Res Function(InvokeMessage) _then;

/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvokeMessageType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [InvokeMessage].
extension InvokeMessagePatterns on InvokeMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvokeMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvokeMessage value)  $default,){
final _that = this;
switch (_that) {
case _InvokeMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvokeMessage value)?  $default,){
final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( InvokeMessageType type,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
return $default(_that.type,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( InvokeMessageType type,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _InvokeMessage():
return $default(_that.type,_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( InvokeMessageType type,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _InvokeMessage() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvokeMessage implements InvokeMessage {
  const _InvokeMessage({required this.type, this.data});
  factory _InvokeMessage.fromJson(Map<String, dynamic> json) => _$InvokeMessageFromJson(json);

@override final  InvokeMessageType type;
@override final  dynamic data;

/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvokeMessageCopyWith<_InvokeMessage> get copyWith => __$InvokeMessageCopyWithImpl<_InvokeMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvokeMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvokeMessage&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'InvokeMessage(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$InvokeMessageCopyWith<$Res> implements $InvokeMessageCopyWith<$Res> {
  factory _$InvokeMessageCopyWith(_InvokeMessage value, $Res Function(_InvokeMessage) _then) = __$InvokeMessageCopyWithImpl;
@override @useResult
$Res call({
 InvokeMessageType type, dynamic data
});




}
/// @nodoc
class __$InvokeMessageCopyWithImpl<$Res>
    implements _$InvokeMessageCopyWith<$Res> {
  __$InvokeMessageCopyWithImpl(this._self, this._then);

  final _InvokeMessage _self;
  final $Res Function(_InvokeMessage) _then;

/// Create a copy of InvokeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_InvokeMessage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InvokeMessageType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}


/// @nodoc
mixin _$Delay {

 String get name; String get url; int? get value;
/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DelayCopyWith<Delay> get copyWith => _$DelayCopyWithImpl<Delay>(this as Delay, _$identity);

  /// Serializes this Delay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Delay&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,value);

@override
String toString() {
  return 'Delay(name: $name, url: $url, value: $value)';
}


}

/// @nodoc
abstract mixin class $DelayCopyWith<$Res>  {
  factory $DelayCopyWith(Delay value, $Res Function(Delay) _then) = _$DelayCopyWithImpl;
@useResult
$Res call({
 String name, String url, int? value
});




}
/// @nodoc
class _$DelayCopyWithImpl<$Res>
    implements $DelayCopyWith<$Res> {
  _$DelayCopyWithImpl(this._self, this._then);

  final Delay _self;
  final $Res Function(Delay) _then;

/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Delay].
extension DelayPatterns on Delay {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Delay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Delay() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Delay value)  $default,){
final _that = this;
switch (_that) {
case _Delay():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Delay value)?  $default,){
final _that = this;
switch (_that) {
case _Delay() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url,  int? value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Delay() when $default != null:
return $default(_that.name,_that.url,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url,  int? value)  $default,) {final _that = this;
switch (_that) {
case _Delay():
return $default(_that.name,_that.url,_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url,  int? value)?  $default,) {final _that = this;
switch (_that) {
case _Delay() when $default != null:
return $default(_that.name,_that.url,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Delay implements Delay {
  const _Delay({required this.name, required this.url, this.value});
  factory _Delay.fromJson(Map<String, dynamic> json) => _$DelayFromJson(json);

@override final  String name;
@override final  String url;
@override final  int? value;

/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DelayCopyWith<_Delay> get copyWith => __$DelayCopyWithImpl<_Delay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DelayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Delay&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url,value);

@override
String toString() {
  return 'Delay(name: $name, url: $url, value: $value)';
}


}

/// @nodoc
abstract mixin class _$DelayCopyWith<$Res> implements $DelayCopyWith<$Res> {
  factory _$DelayCopyWith(_Delay value, $Res Function(_Delay) _then) = __$DelayCopyWithImpl;
@override @useResult
$Res call({
 String name, String url, int? value
});




}
/// @nodoc
class __$DelayCopyWithImpl<$Res>
    implements _$DelayCopyWith<$Res> {
  __$DelayCopyWithImpl(this._self, this._then);

  final _Delay _self;
  final $Res Function(_Delay) _then;

/// Create a copy of Delay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,Object? value = freezed,}) {
  return _then(_Delay(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Now {

 String get name; String get value;
/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowCopyWith<Now> get copyWith => _$NowCopyWithImpl<Now>(this as Now, _$identity);

  /// Serializes this Now to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Now&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'Now(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class $NowCopyWith<$Res>  {
  factory $NowCopyWith(Now value, $Res Function(Now) _then) = _$NowCopyWithImpl;
@useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class _$NowCopyWithImpl<$Res>
    implements $NowCopyWith<$Res> {
  _$NowCopyWithImpl(this._self, this._then);

  final Now _self;
  final $Res Function(Now) _then;

/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Now].
extension NowPatterns on Now {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Now value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Now() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Now value)  $default,){
final _that = this;
switch (_that) {
case _Now():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Now value)?  $default,){
final _that = this;
switch (_that) {
case _Now() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Now() when $default != null:
return $default(_that.name,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String value)  $default,) {final _that = this;
switch (_that) {
case _Now():
return $default(_that.name,_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String value)?  $default,) {final _that = this;
switch (_that) {
case _Now() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Now implements Now {
  const _Now({required this.name, required this.value});
  factory _Now.fromJson(Map<String, dynamic> json) => _$NowFromJson(json);

@override final  String name;
@override final  String value;

/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NowCopyWith<_Now> get copyWith => __$NowCopyWithImpl<_Now>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Now&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,value);

@override
String toString() {
  return 'Now(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$NowCopyWith<$Res> implements $NowCopyWith<$Res> {
  factory _$NowCopyWith(_Now value, $Res Function(_Now) _then) = __$NowCopyWithImpl;
@override @useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class __$NowCopyWithImpl<$Res>
    implements _$NowCopyWith<$Res> {
  __$NowCopyWithImpl(this._self, this._then);

  final _Now _self;
  final $Res Function(_Now) _then;

/// Create a copy of Now
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_Now(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProviderSubscriptionInfo {

@JsonKey(name: 'UPLOAD') int get upload;@JsonKey(name: 'DOWNLOAD') int get download;@JsonKey(name: 'TOTAL') int get total;@JsonKey(name: 'EXPIRE') int get expire;
/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderSubscriptionInfoCopyWith<ProviderSubscriptionInfo> get copyWith => _$ProviderSubscriptionInfoCopyWithImpl<ProviderSubscriptionInfo>(this as ProviderSubscriptionInfo, _$identity);

  /// Serializes this ProviderSubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderSubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,upload,download,total,expire);

@override
String toString() {
  return 'ProviderSubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class $ProviderSubscriptionInfoCopyWith<$Res>  {
  factory $ProviderSubscriptionInfoCopyWith(ProviderSubscriptionInfo value, $Res Function(ProviderSubscriptionInfo) _then) = _$ProviderSubscriptionInfoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'UPLOAD') int upload,@JsonKey(name: 'DOWNLOAD') int download,@JsonKey(name: 'TOTAL') int total,@JsonKey(name: 'EXPIRE') int expire
});




}
/// @nodoc
class _$ProviderSubscriptionInfoCopyWithImpl<$Res>
    implements $ProviderSubscriptionInfoCopyWith<$Res> {
  _$ProviderSubscriptionInfoCopyWithImpl(this._self, this._then);

  final ProviderSubscriptionInfo _self;
  final $Res Function(ProviderSubscriptionInfo) _then;

/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_self.copyWith(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderSubscriptionInfo].
extension ProviderSubscriptionInfoPatterns on ProviderSubscriptionInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderSubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderSubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderSubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'UPLOAD')  int upload, @JsonKey(name: 'DOWNLOAD')  int download, @JsonKey(name: 'TOTAL')  int total, @JsonKey(name: 'EXPIRE')  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'UPLOAD')  int upload, @JsonKey(name: 'DOWNLOAD')  int download, @JsonKey(name: 'TOTAL')  int total, @JsonKey(name: 'EXPIRE')  int expire)  $default,) {final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo():
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'UPLOAD')  int upload, @JsonKey(name: 'DOWNLOAD')  int download, @JsonKey(name: 'TOTAL')  int total, @JsonKey(name: 'EXPIRE')  int expire)?  $default,) {final _that = this;
switch (_that) {
case _ProviderSubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderSubscriptionInfo implements ProviderSubscriptionInfo {
  const _ProviderSubscriptionInfo({@JsonKey(name: 'UPLOAD') this.upload = 0, @JsonKey(name: 'DOWNLOAD') this.download = 0, @JsonKey(name: 'TOTAL') this.total = 0, @JsonKey(name: 'EXPIRE') this.expire = 0});
  factory _ProviderSubscriptionInfo.fromJson(Map<String, dynamic> json) => _$ProviderSubscriptionInfoFromJson(json);

@override@JsonKey(name: 'UPLOAD') final  int upload;
@override@JsonKey(name: 'DOWNLOAD') final  int download;
@override@JsonKey(name: 'TOTAL') final  int total;
@override@JsonKey(name: 'EXPIRE') final  int expire;

/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderSubscriptionInfoCopyWith<_ProviderSubscriptionInfo> get copyWith => __$ProviderSubscriptionInfoCopyWithImpl<_ProviderSubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderSubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderSubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,upload,download,total,expire);

@override
String toString() {
  return 'ProviderSubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$ProviderSubscriptionInfoCopyWith<$Res> implements $ProviderSubscriptionInfoCopyWith<$Res> {
  factory _$ProviderSubscriptionInfoCopyWith(_ProviderSubscriptionInfo value, $Res Function(_ProviderSubscriptionInfo) _then) = __$ProviderSubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'UPLOAD') int upload,@JsonKey(name: 'DOWNLOAD') int download,@JsonKey(name: 'TOTAL') int total,@JsonKey(name: 'EXPIRE') int expire
});




}
/// @nodoc
class __$ProviderSubscriptionInfoCopyWithImpl<$Res>
    implements _$ProviderSubscriptionInfoCopyWith<$Res> {
  __$ProviderSubscriptionInfoCopyWithImpl(this._self, this._then);

  final _ProviderSubscriptionInfo _self;
  final $Res Function(_ProviderSubscriptionInfo) _then;

/// Create a copy of ProviderSubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_ProviderSubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ExternalProvider {

 String get name; String get type; String? get path; int get count;@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? get subscriptionInfo; bool get isUpdating;@JsonKey(name: 'vehicle-type') String get vehicleType;@JsonKey(name: 'update-at') DateTime get updateAt;
/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalProviderCopyWith<ExternalProvider> get copyWith => _$ExternalProviderCopyWithImpl<ExternalProvider>(this as ExternalProvider, _$identity);

  /// Serializes this ExternalProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalProvider&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path)&&(identical(other.count, count) || other.count == count)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.updateAt, updateAt) || other.updateAt == updateAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,path,count,subscriptionInfo,isUpdating,vehicleType,updateAt);

@override
String toString() {
  return 'ExternalProvider(name: $name, type: $type, path: $path, count: $count, subscriptionInfo: $subscriptionInfo, isUpdating: $isUpdating, vehicleType: $vehicleType, updateAt: $updateAt)';
}


}

/// @nodoc
abstract mixin class $ExternalProviderCopyWith<$Res>  {
  factory $ExternalProviderCopyWith(ExternalProvider value, $Res Function(ExternalProvider) _then) = _$ExternalProviderCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? path, int count,@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? subscriptionInfo, bool isUpdating,@JsonKey(name: 'vehicle-type') String vehicleType,@JsonKey(name: 'update-at') DateTime updateAt
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;

}
/// @nodoc
class _$ExternalProviderCopyWithImpl<$Res>
    implements $ExternalProviderCopyWith<$Res> {
  _$ExternalProviderCopyWithImpl(this._self, this._then);

  final ExternalProvider _self;
  final $Res Function(ExternalProvider) _then;

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? path = freezed,Object? count = null,Object? subscriptionInfo = freezed,Object? isUpdating = null,Object? vehicleType = null,Object? updateAt = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,updateAt: null == updateAt ? _self.updateAt : updateAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExternalProvider].
extension ExternalProviderPatterns on ExternalProvider {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExternalProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExternalProvider value)  $default,){
final _that = this;
switch (_that) {
case _ExternalProvider():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExternalProvider value)?  $default,){
final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo,  bool isUpdating, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.isUpdating,_that.vehicleType,_that.updateAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo,  bool isUpdating, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)  $default,) {final _that = this;
switch (_that) {
case _ExternalProvider():
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.isUpdating,_that.vehicleType,_that.updateAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo,  bool isUpdating, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)?  $default,) {final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.isUpdating,_that.vehicleType,_that.updateAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExternalProvider implements ExternalProvider {
  const _ExternalProvider({required this.name, required this.type, this.path, required this.count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) this.subscriptionInfo, this.isUpdating = false, @JsonKey(name: 'vehicle-type') required this.vehicleType, @JsonKey(name: 'update-at') required this.updateAt});
  factory _ExternalProvider.fromJson(Map<String, dynamic> json) => _$ExternalProviderFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? path;
@override final  int count;
@override@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) final  SubscriptionInfo? subscriptionInfo;
@override@JsonKey() final  bool isUpdating;
@override@JsonKey(name: 'vehicle-type') final  String vehicleType;
@override@JsonKey(name: 'update-at') final  DateTime updateAt;

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExternalProviderCopyWith<_ExternalProvider> get copyWith => __$ExternalProviderCopyWithImpl<_ExternalProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExternalProviderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExternalProvider&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path)&&(identical(other.count, count) || other.count == count)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.updateAt, updateAt) || other.updateAt == updateAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,path,count,subscriptionInfo,isUpdating,vehicleType,updateAt);

@override
String toString() {
  return 'ExternalProvider(name: $name, type: $type, path: $path, count: $count, subscriptionInfo: $subscriptionInfo, isUpdating: $isUpdating, vehicleType: $vehicleType, updateAt: $updateAt)';
}


}

/// @nodoc
abstract mixin class _$ExternalProviderCopyWith<$Res> implements $ExternalProviderCopyWith<$Res> {
  factory _$ExternalProviderCopyWith(_ExternalProvider value, $Res Function(_ExternalProvider) _then) = __$ExternalProviderCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? path, int count,@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? subscriptionInfo, bool isUpdating,@JsonKey(name: 'vehicle-type') String vehicleType,@JsonKey(name: 'update-at') DateTime updateAt
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;

}
/// @nodoc
class __$ExternalProviderCopyWithImpl<$Res>
    implements _$ExternalProviderCopyWith<$Res> {
  __$ExternalProviderCopyWithImpl(this._self, this._then);

  final _ExternalProvider _self;
  final $Res Function(_ExternalProvider) _then;

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? path = freezed,Object? count = null,Object? subscriptionInfo = freezed,Object? isUpdating = null,Object? vehicleType = null,Object? updateAt = null,}) {
  return _then(_ExternalProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,updateAt: null == updateAt ? _self.updateAt : updateAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo {
    if (_self.subscriptionInfo == null) {
    return null;
  }

  return $SubscriptionInfoCopyWith<$Res>(_self.subscriptionInfo!, (value) {
    return _then(_self.copyWith(subscriptionInfo: value));
  });
}
}


/// @nodoc
mixin _$Action {

 ActionMethod get method; dynamic get data; String get id;
/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionCopyWith<Action> get copyWith => _$ActionCopyWithImpl<Action>(this as Action, _$identity);

  /// Serializes this Action to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Action&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,const DeepCollectionEquality().hash(data),id);

@override
String toString() {
  return 'Action(method: $method, data: $data, id: $id)';
}


}

/// @nodoc
abstract mixin class $ActionCopyWith<$Res>  {
  factory $ActionCopyWith(Action value, $Res Function(Action) _then) = _$ActionCopyWithImpl;
@useResult
$Res call({
 ActionMethod method, dynamic data, String id
});




}
/// @nodoc
class _$ActionCopyWithImpl<$Res>
    implements $ActionCopyWith<$Res> {
  _$ActionCopyWithImpl(this._self, this._then);

  final Action _self;
  final $Res Function(Action) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? data = freezed,Object? id = null,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ActionMethod,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Action].
extension ActionPatterns on Action {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Action value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Action() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Action value)  $default,){
final _that = this;
switch (_that) {
case _Action():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Action value)?  $default,){
final _that = this;
switch (_that) {
case _Action() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActionMethod method,  dynamic data,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Action() when $default != null:
return $default(_that.method,_that.data,_that.id);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActionMethod method,  dynamic data,  String id)  $default,) {final _that = this;
switch (_that) {
case _Action():
return $default(_that.method,_that.data,_that.id);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActionMethod method,  dynamic data,  String id)?  $default,) {final _that = this;
switch (_that) {
case _Action() when $default != null:
return $default(_that.method,_that.data,_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Action implements Action {
  const _Action({required this.method, required this.data, required this.id});
  factory _Action.fromJson(Map<String, dynamic> json) => _$ActionFromJson(json);

@override final  ActionMethod method;
@override final  dynamic data;
@override final  String id;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionCopyWith<_Action> get copyWith => __$ActionCopyWithImpl<_Action>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Action&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,const DeepCollectionEquality().hash(data),id);

@override
String toString() {
  return 'Action(method: $method, data: $data, id: $id)';
}


}

/// @nodoc
abstract mixin class _$ActionCopyWith<$Res> implements $ActionCopyWith<$Res> {
  factory _$ActionCopyWith(_Action value, $Res Function(_Action) _then) = __$ActionCopyWithImpl;
@override @useResult
$Res call({
 ActionMethod method, dynamic data, String id
});




}
/// @nodoc
class __$ActionCopyWithImpl<$Res>
    implements _$ActionCopyWith<$Res> {
  __$ActionCopyWithImpl(this._self, this._then);

  final _Action _self;
  final $Res Function(_Action) _then;

/// Create a copy of Action
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? data = freezed,Object? id = null,}) {
  return _then(_Action(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ActionMethod,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ActionResult {

 ActionMethod get method; dynamic get data; String? get id; ResultType get code;
/// Create a copy of ActionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionResultCopyWith<ActionResult> get copyWith => _$ActionResultCopyWithImpl<ActionResult>(this as ActionResult, _$identity);

  /// Serializes this ActionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionResult&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,const DeepCollectionEquality().hash(data),id,code);

@override
String toString() {
  return 'ActionResult(method: $method, data: $data, id: $id, code: $code)';
}


}

/// @nodoc
abstract mixin class $ActionResultCopyWith<$Res>  {
  factory $ActionResultCopyWith(ActionResult value, $Res Function(ActionResult) _then) = _$ActionResultCopyWithImpl;
@useResult
$Res call({
 ActionMethod method, dynamic data, String? id, ResultType code
});




}
/// @nodoc
class _$ActionResultCopyWithImpl<$Res>
    implements $ActionResultCopyWith<$Res> {
  _$ActionResultCopyWithImpl(this._self, this._then);

  final ActionResult _self;
  final $Res Function(ActionResult) _then;

/// Create a copy of ActionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? data = freezed,Object? id = freezed,Object? code = null,}) {
  return _then(_self.copyWith(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ActionMethod,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ResultType,
  ));
}

}


/// Adds pattern-matching-related methods to [ActionResult].
extension ActionResultPatterns on ActionResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionResult value)  $default,){
final _that = this;
switch (_that) {
case _ActionResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionResult value)?  $default,){
final _that = this;
switch (_that) {
case _ActionResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActionMethod method,  dynamic data,  String? id,  ResultType code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionResult() when $default != null:
return $default(_that.method,_that.data,_that.id,_that.code);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActionMethod method,  dynamic data,  String? id,  ResultType code)  $default,) {final _that = this;
switch (_that) {
case _ActionResult():
return $default(_that.method,_that.data,_that.id,_that.code);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActionMethod method,  dynamic data,  String? id,  ResultType code)?  $default,) {final _that = this;
switch (_that) {
case _ActionResult() when $default != null:
return $default(_that.method,_that.data,_that.id,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActionResult implements ActionResult {
  const _ActionResult({required this.method, required this.data, this.id, this.code = ResultType.success});
  factory _ActionResult.fromJson(Map<String, dynamic> json) => _$ActionResultFromJson(json);

@override final  ActionMethod method;
@override final  dynamic data;
@override final  String? id;
@override@JsonKey() final  ResultType code;

/// Create a copy of ActionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionResultCopyWith<_ActionResult> get copyWith => __$ActionResultCopyWithImpl<_ActionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionResult&&(identical(other.method, method) || other.method == method)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,method,const DeepCollectionEquality().hash(data),id,code);

@override
String toString() {
  return 'ActionResult(method: $method, data: $data, id: $id, code: $code)';
}


}

/// @nodoc
abstract mixin class _$ActionResultCopyWith<$Res> implements $ActionResultCopyWith<$Res> {
  factory _$ActionResultCopyWith(_ActionResult value, $Res Function(_ActionResult) _then) = __$ActionResultCopyWithImpl;
@override @useResult
$Res call({
 ActionMethod method, dynamic data, String? id, ResultType code
});




}
/// @nodoc
class __$ActionResultCopyWithImpl<$Res>
    implements _$ActionResultCopyWith<$Res> {
  __$ActionResultCopyWithImpl(this._self, this._then);

  final _ActionResult _self;
  final $Res Function(_ActionResult) _then;

/// Create a copy of ActionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? data = freezed,Object? id = freezed,Object? code = null,}) {
  return _then(_ActionResult(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ActionMethod,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as ResultType,
  ));
}


}

// dart format on

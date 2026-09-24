// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../core.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
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
  final _this = this as SetupParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupParams&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupParams;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.selectedMap),_this.testUrl);
}

@override
String toString() {
  final _this = this as SetupParams;
  return 'SetupParams(selectedMap: ${_this.selectedMap}, testUrl: ${_this.testUrl})';
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
  return _then(SetupParams(
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
  const _SetupParams({@JsonKey(name: 'selected-map') required  Map<String, String> selectedMap, @JsonKey(name: 'test-url') required this.testUrl}): _selectedMap = selectedMap;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupParams&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedMap),testUrl);
}

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

 Tun get tun;@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'find-process-mode') FindProcessMode get findProcessMode; Mode get mode;@JsonKey(name: 'log-level') LogLevel get logLevel; bool get ipv6;@JsonKey(name: 'tcp-concurrent') bool get tcpConcurrent;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController;@JsonKey(name: 'unified-delay') bool get unifiedDelay; List<String> get authentication;@JsonKey(name: 'geo-auto-update') bool get geoAutoUpdate;@JsonKey(name: 'geo-update-interval') int get geoUpdateInterval;
/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateParamsCopyWith<UpdateParams> get copyWith => _$UpdateParamsCopyWithImpl<UpdateParams>(this as UpdateParams, _$identity);

  /// Serializes this UpdateParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpdateParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateParams&&(identical(other.tun, _this.tun) || other.tun == _this.tun)&&(identical(other.mixedPort, _this.mixedPort) || other.mixedPort == _this.mixedPort)&&(identical(other.allowLan, _this.allowLan) || other.allowLan == _this.allowLan)&&(identical(other.findProcessMode, _this.findProcessMode) || other.findProcessMode == _this.findProcessMode)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.tcpConcurrent, _this.tcpConcurrent) || other.tcpConcurrent == _this.tcpConcurrent)&&(identical(other.externalController, _this.externalController) || other.externalController == _this.externalController)&&(identical(other.unifiedDelay, _this.unifiedDelay) || other.unifiedDelay == _this.unifiedDelay)&&const DeepCollectionEquality().equals(other.authentication, _this.authentication)&&(identical(other.geoAutoUpdate, _this.geoAutoUpdate) || other.geoAutoUpdate == _this.geoAutoUpdate)&&(identical(other.geoUpdateInterval, _this.geoUpdateInterval) || other.geoUpdateInterval == _this.geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateParams;
  return Object.hash(runtimeType,_this.tun,_this.mixedPort,_this.allowLan,_this.findProcessMode,_this.mode,_this.logLevel,_this.ipv6,_this.tcpConcurrent,_this.externalController,_this.unifiedDelay,const DeepCollectionEquality().hash(_this.authentication),_this.geoAutoUpdate,_this.geoUpdateInterval);
}

@override
String toString() {
  final _this = this as UpdateParams;
  return 'UpdateParams(tun: ${_this.tun}, mixedPort: ${_this.mixedPort}, allowLan: ${_this.allowLan}, findProcessMode: ${_this.findProcessMode}, mode: ${_this.mode}, logLevel: ${_this.logLevel}, ipv6: ${_this.ipv6}, tcpConcurrent: ${_this.tcpConcurrent}, externalController: ${_this.externalController}, unifiedDelay: ${_this.unifiedDelay}, authentication: ${_this.authentication}, geoAutoUpdate: ${_this.geoAutoUpdate}, geoUpdateInterval: ${_this.geoUpdateInterval})';
}


}

/// @nodoc
abstract mixin class $UpdateParamsCopyWith<$Res>  {
  factory $UpdateParamsCopyWith(UpdateParams value, $Res Function(UpdateParams) _then) = _$UpdateParamsCopyWithImpl;
@useResult
$Res call({
 Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController,@JsonKey(name: 'unified-delay') bool unifiedDelay, List<String> authentication,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
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
@pragma('vm:prefer-inline') @override $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = null,Object? tcpConcurrent = null,Object? externalController = null,Object? unifiedDelay = null,Object? authentication = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
  return _then(UpdateParams(
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
as bool,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as List<String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)  $default,) {final _that = this;
switch (_that) {
case _UpdateParams():
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool ipv6, @JsonKey(name: 'tcp-concurrent')  bool tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController, @JsonKey(name: 'unified-delay')  bool unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval)?  $default,) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateParams implements UpdateParams {
  const _UpdateParams({required this.tun, @JsonKey(name: 'mixed-port') required this.mixedPort, @JsonKey(name: 'allow-lan') required this.allowLan, @JsonKey(name: 'find-process-mode') required this.findProcessMode, required this.mode, @JsonKey(name: 'log-level') required this.logLevel, required this.ipv6, @JsonKey(name: 'tcp-concurrent') required this.tcpConcurrent, @JsonKey(name: 'external-controller') required this.externalController, @JsonKey(name: 'unified-delay') required this.unifiedDelay,  List<String> authentication = const [], @JsonKey(name: 'geo-auto-update') this.geoAutoUpdate = false, @JsonKey(name: 'geo-update-interval') this.geoUpdateInterval = 24}): _authentication = authentication;
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
 final  List<String> _authentication;
@override@JsonKey() List<String> get authentication {
  if (_authentication is EqualUnmodifiableListView) return _authentication;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authentication);
}

@override@JsonKey(name: 'geo-auto-update') final  bool geoAutoUpdate;
@override@JsonKey(name: 'geo-update-interval') final  int geoUpdateInterval;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateParams&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&const DeepCollectionEquality().equals(other.authentication, _authentication)&&(identical(other.geoAutoUpdate, geoAutoUpdate) || other.geoAutoUpdate == geoAutoUpdate)&&(identical(other.geoUpdateInterval, geoUpdateInterval) || other.geoUpdateInterval == geoUpdateInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tun,mixedPort,allowLan,findProcessMode,mode,logLevel,ipv6,tcpConcurrent,externalController,unifiedDelay,const DeepCollectionEquality().hash(_authentication),geoAutoUpdate,geoUpdateInterval);
}

@override
String toString() {
    return 'UpdateParams(tun: $tun, mixedPort: $mixedPort, allowLan: $allowLan, findProcessMode: $findProcessMode, mode: $mode, logLevel: $logLevel, ipv6: $ipv6, tcpConcurrent: $tcpConcurrent, externalController: $externalController, unifiedDelay: $unifiedDelay, authentication: $authentication, geoAutoUpdate: $geoAutoUpdate, geoUpdateInterval: $geoUpdateInterval)';
}


}

/// @nodoc
abstract mixin class _$UpdateParamsCopyWith<$Res> implements $UpdateParamsCopyWith<$Res> {
  factory _$UpdateParamsCopyWith(_UpdateParams value, $Res Function(_UpdateParams) _then) = __$UpdateParamsCopyWithImpl;
@override @useResult
$Res call({
 Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool ipv6,@JsonKey(name: 'tcp-concurrent') bool tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController,@JsonKey(name: 'unified-delay') bool unifiedDelay, List<String> authentication,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval
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
@override @pragma('vm:prefer-inline') $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = null,Object? tcpConcurrent = null,Object? externalController = null,Object? unifiedDelay = null,Object? authentication = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,}) {
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
as bool,authentication: null == authentication ? _self._authentication : authentication // ignore: cast_nullable_to_non_nullable
as List<String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,
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

 bool get enable; int get port; bool get ipv6; bool get dnsHijacking; AccessControlProps get accessControlProps; bool get allowBypass; bool get systemProxy; List<String> get bypassDomain; String get stack; List<String> get routeAddress;
/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<VpnOptions> get copyWith => _$VpnOptionsCopyWithImpl<VpnOptions>(this as VpnOptions, _$identity);

  /// Serializes this VpnOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VpnOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnOptions&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.dnsHijacking, _this.dnsHijacking) || other.dnsHijacking == _this.dnsHijacking)&&(identical(other.accessControlProps, _this.accessControlProps) || other.accessControlProps == _this.accessControlProps)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&(identical(other.stack, _this.stack) || other.stack == _this.stack)&&const DeepCollectionEquality().equals(other.routeAddress, _this.routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnOptions;
  return Object.hash(runtimeType,_this.enable,_this.port,_this.ipv6,_this.dnsHijacking,_this.accessControlProps,_this.allowBypass,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),_this.stack,const DeepCollectionEquality().hash(_this.routeAddress));
}

@override
String toString() {
  final _this = this as VpnOptions;
  return 'VpnOptions(enable: ${_this.enable}, port: ${_this.port}, ipv6: ${_this.ipv6}, dnsHijacking: ${_this.dnsHijacking}, accessControlProps: ${_this.accessControlProps}, allowBypass: ${_this.allowBypass}, systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, stack: ${_this.stack}, routeAddress: ${_this.routeAddress})';
}


}

/// @nodoc
abstract mixin class $VpnOptionsCopyWith<$Res>  {
  factory $VpnOptionsCopyWith(VpnOptions value, $Res Function(VpnOptions) _then) = _$VpnOptionsCopyWithImpl;
@useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress
});


$AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class _$VpnOptionsCopyWithImpl<$Res>
    implements $VpnOptionsCopyWith<$Res> {
  _$VpnOptionsCopyWithImpl(this._self, this._then);

  final VpnOptions _self;
  final $Res Function(VpnOptions) _then;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,}) {
  return _then(VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
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
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress)  $default,) {final _that = this;
switch (_that) {
case _VpnOptions():
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress)?  $default,) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnOptions implements VpnOptions {
  const _VpnOptions({required this.enable, required this.port, required this.ipv6, required this.dnsHijacking, required this.accessControlProps, required this.allowBypass, required this.systemProxy, required  List<String> bypassDomain, required this.stack,  List<String> routeAddress = const []}): _bypassDomain = bypassDomain,_routeAddress = routeAddress;
  factory _VpnOptions.fromJson(Map<String, dynamic> json) => _$VpnOptionsFromJson(json);

@override final  bool enable;
@override final  int port;
@override final  bool ipv6;
@override final  bool dnsHijacking;
@override final  AccessControlProps accessControlProps;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.port, port) || other.port == port)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.routeAddress, _routeAddress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,port,ipv6,dnsHijacking,accessControlProps,allowBypass,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),stack,const DeepCollectionEquality().hash(_routeAddress));
}

@override
String toString() {
    return 'VpnOptions(enable: $enable, port: $port, ipv6: $ipv6, dnsHijacking: $dnsHijacking, accessControlProps: $accessControlProps, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, stack: $stack, routeAddress: $routeAddress)';
}


}

/// @nodoc
abstract mixin class _$VpnOptionsCopyWith<$Res> implements $VpnOptionsCopyWith<$Res> {
  factory _$VpnOptionsCopyWith(_VpnOptions value, $Res Function(_VpnOptions) _then) = __$VpnOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress
});


@override $AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class __$VpnOptionsCopyWithImpl<$Res>
    implements _$VpnOptionsCopyWith<$Res> {
  __$VpnOptionsCopyWithImpl(this._self, this._then);

  final _VpnOptions _self;
  final $Res Function(_VpnOptions) _then;

/// Create a copy of VpnOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,}) {
  return _then(_VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
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
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
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
  final _this = this as InitParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitParams&&(identical(other.homeDir, _this.homeDir) || other.homeDir == _this.homeDir)&&(identical(other.version, _this.version) || other.version == _this.version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InitParams;
  return Object.hash(runtimeType,_this.homeDir,_this.version);
}

@override
String toString() {
  final _this = this as InitParams;
  return 'InitParams(homeDir: ${_this.homeDir}, version: ${_this.version})';
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
  return _then(InitParams(
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
int get hashCode {
    return Object.hash(runtimeType,homeDir,version);
}

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
  final _this = this as ChangeProxyParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeProxyParams&&(identical(other.groupName, _this.groupName) || other.groupName == _this.groupName)&&(identical(other.proxyName, _this.proxyName) || other.proxyName == _this.proxyName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangeProxyParams;
  return Object.hash(runtimeType,_this.groupName,_this.proxyName);
}

@override
String toString() {
  final _this = this as ChangeProxyParams;
  return 'ChangeProxyParams(groupName: ${_this.groupName}, proxyName: ${_this.proxyName})';
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
  return _then(ChangeProxyParams(
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
int get hashCode {
    return Object.hash(runtimeType,groupName,proxyName);
}

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
mixin _$ChangeProxyResult {

 String get message; bool get changed;
/// Create a copy of ChangeProxyResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeProxyResultCopyWith<ChangeProxyResult> get copyWith => _$ChangeProxyResultCopyWithImpl<ChangeProxyResult>(this as ChangeProxyResult, _$identity);

  /// Serializes this ChangeProxyResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ChangeProxyResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeProxyResult&&(identical(other.message, _this.message) || other.message == _this.message)&&(identical(other.changed, _this.changed) || other.changed == _this.changed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ChangeProxyResult;
  return Object.hash(runtimeType,_this.message,_this.changed);
}

@override
String toString() {
  final _this = this as ChangeProxyResult;
  return 'ChangeProxyResult(message: ${_this.message}, changed: ${_this.changed})';
}


}

/// @nodoc
abstract mixin class $ChangeProxyResultCopyWith<$Res>  {
  factory $ChangeProxyResultCopyWith(ChangeProxyResult value, $Res Function(ChangeProxyResult) _then) = _$ChangeProxyResultCopyWithImpl;
@useResult
$Res call({
 String message, bool changed
});




}
/// @nodoc
class _$ChangeProxyResultCopyWithImpl<$Res>
    implements $ChangeProxyResultCopyWith<$Res> {
  _$ChangeProxyResultCopyWithImpl(this._self, this._then);

  final ChangeProxyResult _self;
  final $Res Function(ChangeProxyResult) _then;

/// Create a copy of ChangeProxyResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? changed = null,}) {
  return _then(ChangeProxyResult(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,changed: null == changed ? _self.changed : changed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangeProxyResult].
extension ChangeProxyResultPatterns on ChangeProxyResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangeProxyResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangeProxyResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangeProxyResult value)  $default,){
final _that = this;
switch (_that) {
case _ChangeProxyResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangeProxyResult value)?  $default,){
final _that = this;
switch (_that) {
case _ChangeProxyResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  bool changed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangeProxyResult() when $default != null:
return $default(_that.message,_that.changed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  bool changed)  $default,) {final _that = this;
switch (_that) {
case _ChangeProxyResult():
return $default(_that.message,_that.changed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  bool changed)?  $default,) {final _that = this;
switch (_that) {
case _ChangeProxyResult() when $default != null:
return $default(_that.message,_that.changed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangeProxyResult implements ChangeProxyResult {
  const _ChangeProxyResult({this.message = '', this.changed = false});
  factory _ChangeProxyResult.fromJson(Map<String, dynamic> json) => _$ChangeProxyResultFromJson(json);

@override@JsonKey() final  String message;
@override@JsonKey() final  bool changed;

/// Create a copy of ChangeProxyResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangeProxyResultCopyWith<_ChangeProxyResult> get copyWith => __$ChangeProxyResultCopyWithImpl<_ChangeProxyResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangeProxyResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangeProxyResult&&(identical(other.message, message) || other.message == message)&&(identical(other.changed, changed) || other.changed == changed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,message,changed);
}

@override
String toString() {
    return 'ChangeProxyResult(message: $message, changed: $changed)';
}


}

/// @nodoc
abstract mixin class _$ChangeProxyResultCopyWith<$Res> implements $ChangeProxyResultCopyWith<$Res> {
  factory _$ChangeProxyResultCopyWith(_ChangeProxyResult value, $Res Function(_ChangeProxyResult) _then) = __$ChangeProxyResultCopyWithImpl;
@override @useResult
$Res call({
 String message, bool changed
});




}
/// @nodoc
class __$ChangeProxyResultCopyWithImpl<$Res>
    implements _$ChangeProxyResultCopyWith<$Res> {
  __$ChangeProxyResultCopyWithImpl(this._self, this._then);

  final _ChangeProxyResult _self;
  final $Res Function(_ChangeProxyResult) _then;

/// Create a copy of ChangeProxyResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? changed = null,}) {
  return _then(_ChangeProxyResult(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,changed: null == changed ? _self.changed : changed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$RouteSnapshot {

@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'picks-version') int get picksVersion; Map<String, String> get picks;
/// Create a copy of RouteSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteSnapshotCopyWith<RouteSnapshot> get copyWith => _$RouteSnapshotCopyWithImpl<RouteSnapshot>(this as RouteSnapshot, _$identity);

  /// Serializes this RouteSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteSnapshot&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.picksVersion, _this.picksVersion) || other.picksVersion == _this.picksVersion)&&const DeepCollectionEquality().equals(other.picks, _this.picks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteSnapshot;
  return Object.hash(runtimeType,_this.coreEpoch,_this.picksVersion,const DeepCollectionEquality().hash(_this.picks));
}

@override
String toString() {
  final _this = this as RouteSnapshot;
  return 'RouteSnapshot(coreEpoch: ${_this.coreEpoch}, picksVersion: ${_this.picksVersion}, picks: ${_this.picks})';
}


}

/// @nodoc
abstract mixin class $RouteSnapshotCopyWith<$Res>  {
  factory $RouteSnapshotCopyWith(RouteSnapshot value, $Res Function(RouteSnapshot) _then) = _$RouteSnapshotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'picks-version') int picksVersion, Map<String, String> picks
});




}
/// @nodoc
class _$RouteSnapshotCopyWithImpl<$Res>
    implements $RouteSnapshotCopyWith<$Res> {
  _$RouteSnapshotCopyWithImpl(this._self, this._then);

  final RouteSnapshot _self;
  final $Res Function(RouteSnapshot) _then;

/// Create a copy of RouteSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coreEpoch = null,Object? picksVersion = null,Object? picks = null,}) {
  return _then(RouteSnapshot(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,picksVersion: null == picksVersion ? _self.picksVersion : picksVersion // ignore: cast_nullable_to_non_nullable
as int,picks: null == picks ? _self.picks : picks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteSnapshot].
extension RouteSnapshotPatterns on RouteSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _RouteSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion,  Map<String, String> picks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
return $default(_that.coreEpoch,_that.picksVersion,_that.picks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion,  Map<String, String> picks)  $default,) {final _that = this;
switch (_that) {
case _RouteSnapshot():
return $default(_that.coreEpoch,_that.picksVersion,_that.picks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion,  Map<String, String> picks)?  $default,) {final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
return $default(_that.coreEpoch,_that.picksVersion,_that.picks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteSnapshot implements RouteSnapshot {
  const _RouteSnapshot({@JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'picks-version') this.picksVersion = 0,  Map<String, String> picks = const {}}): _picks = picks;
  factory _RouteSnapshot.fromJson(Map<String, dynamic> json) => _$RouteSnapshotFromJson(json);

@override@JsonKey(name: 'core-epoch') final  int coreEpoch;
@override@JsonKey(name: 'picks-version') final  int picksVersion;
 final  Map<String, String> _picks;
@override@JsonKey() Map<String, String> get picks {
  if (_picks is EqualUnmodifiableMapView) return _picks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_picks);
}


/// Create a copy of RouteSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteSnapshotCopyWith<_RouteSnapshot> get copyWith => __$RouteSnapshotCopyWithImpl<_RouteSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteSnapshot&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.picksVersion, picksVersion) || other.picksVersion == picksVersion)&&const DeepCollectionEquality().equals(other.picks, _picks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,coreEpoch,picksVersion,const DeepCollectionEquality().hash(_picks));
}

@override
String toString() {
    return 'RouteSnapshot(coreEpoch: $coreEpoch, picksVersion: $picksVersion, picks: $picks)';
}


}

/// @nodoc
abstract mixin class _$RouteSnapshotCopyWith<$Res> implements $RouteSnapshotCopyWith<$Res> {
  factory _$RouteSnapshotCopyWith(_RouteSnapshot value, $Res Function(_RouteSnapshot) _then) = __$RouteSnapshotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'picks-version') int picksVersion, Map<String, String> picks
});




}
/// @nodoc
class __$RouteSnapshotCopyWithImpl<$Res>
    implements _$RouteSnapshotCopyWith<$Res> {
  __$RouteSnapshotCopyWithImpl(this._self, this._then);

  final _RouteSnapshot _self;
  final $Res Function(_RouteSnapshot) _then;

/// Create a copy of RouteSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coreEpoch = null,Object? picksVersion = null,Object? picks = null,}) {
  return _then(_RouteSnapshot(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,picksVersion: null == picksVersion ? _self.picksVersion : picksVersion // ignore: cast_nullable_to_non_nullable
as int,picks: null == picks ? _self._picks : picks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
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
  final _this = this as UpdateGeoDataParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGeoDataParams&&(identical(other.geoType, _this.geoType) || other.geoType == _this.geoType)&&(identical(other.geoName, _this.geoName) || other.geoName == _this.geoName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateGeoDataParams;
  return Object.hash(runtimeType,_this.geoType,_this.geoName);
}

@override
String toString() {
  final _this = this as UpdateGeoDataParams;
  return 'UpdateGeoDataParams(geoType: ${_this.geoType}, geoName: ${_this.geoName})';
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
  return _then(UpdateGeoDataParams(
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
int get hashCode {
    return Object.hash(runtimeType,geoType,geoName);
}

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
  final _this = this as CoreEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreEvent&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoreEvent;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as CoreEvent;
  return 'CoreEvent(type: ${_this.type}, data: ${_this.data})';
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
  return _then(CoreEvent(
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
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));
}

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
  final _this = this as InvokeMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvokeMessage&&(identical(other.type, _this.type) || other.type == _this.type)&&const DeepCollectionEquality().equals(other.data, _this.data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as InvokeMessage;
  return Object.hash(runtimeType,_this.type,const DeepCollectionEquality().hash(_this.data));
}

@override
String toString() {
  final _this = this as InvokeMessage;
  return 'InvokeMessage(type: ${_this.type}, data: ${_this.data})';
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
  return _then(InvokeMessage(
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
int get hashCode {
    return Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));
}

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
  final _this = this as Delay;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Delay&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Delay;
  return Object.hash(runtimeType,_this.name,_this.url,_this.value);
}

@override
String toString() {
  final _this = this as Delay;
  return 'Delay(name: ${_this.name}, url: ${_this.url}, value: ${_this.value})';
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
  return _then(Delay(
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
int get hashCode {
    return Object.hash(runtimeType,name,url,value);
}

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
mixin _$ProbeParams {

 String get url;@JsonKey(name: 'proxy-name') String get proxyName; Map<String, String> get headers; int get timeout;@JsonKey(name: 'max-body') int get maxBody;
/// Create a copy of ProbeParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeParamsCopyWith<ProbeParams> get copyWith => _$ProbeParamsCopyWithImpl<ProbeParams>(this as ProbeParams, _$identity);

  /// Serializes this ProbeParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProbeParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeParams&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.proxyName, _this.proxyName) || other.proxyName == _this.proxyName)&&const DeepCollectionEquality().equals(other.headers, _this.headers)&&(identical(other.timeout, _this.timeout) || other.timeout == _this.timeout)&&(identical(other.maxBody, _this.maxBody) || other.maxBody == _this.maxBody));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProbeParams;
  return Object.hash(runtimeType,_this.url,_this.proxyName,const DeepCollectionEquality().hash(_this.headers),_this.timeout,_this.maxBody);
}

@override
String toString() {
  final _this = this as ProbeParams;
  return 'ProbeParams(url: ${_this.url}, proxyName: ${_this.proxyName}, headers: ${_this.headers}, timeout: ${_this.timeout}, maxBody: ${_this.maxBody})';
}


}

/// @nodoc
abstract mixin class $ProbeParamsCopyWith<$Res>  {
  factory $ProbeParamsCopyWith(ProbeParams value, $Res Function(ProbeParams) _then) = _$ProbeParamsCopyWithImpl;
@useResult
$Res call({
 String url,@JsonKey(name: 'proxy-name') String proxyName, Map<String, String> headers, int timeout,@JsonKey(name: 'max-body') int maxBody
});




}
/// @nodoc
class _$ProbeParamsCopyWithImpl<$Res>
    implements $ProbeParamsCopyWith<$Res> {
  _$ProbeParamsCopyWithImpl(this._self, this._then);

  final ProbeParams _self;
  final $Res Function(ProbeParams) _then;

/// Create a copy of ProbeParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? proxyName = null,Object? headers = null,Object? timeout = null,Object? maxBody = null,}) {
  return _then(ProbeParams(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,maxBody: null == maxBody ? _self.maxBody : maxBody // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProbeParams].
extension ProbeParamsPatterns on ProbeParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProbeParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProbeParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProbeParams value)  $default,){
final _that = this;
switch (_that) {
case _ProbeParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProbeParams value)?  $default,){
final _that = this;
switch (_that) {
case _ProbeParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'proxy-name')  String proxyName,  Map<String, String> headers,  int timeout, @JsonKey(name: 'max-body')  int maxBody)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProbeParams() when $default != null:
return $default(_that.url,_that.proxyName,_that.headers,_that.timeout,_that.maxBody);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url, @JsonKey(name: 'proxy-name')  String proxyName,  Map<String, String> headers,  int timeout, @JsonKey(name: 'max-body')  int maxBody)  $default,) {final _that = this;
switch (_that) {
case _ProbeParams():
return $default(_that.url,_that.proxyName,_that.headers,_that.timeout,_that.maxBody);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url, @JsonKey(name: 'proxy-name')  String proxyName,  Map<String, String> headers,  int timeout, @JsonKey(name: 'max-body')  int maxBody)?  $default,) {final _that = this;
switch (_that) {
case _ProbeParams() when $default != null:
return $default(_that.url,_that.proxyName,_that.headers,_that.timeout,_that.maxBody);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProbeParams implements ProbeParams {
  const _ProbeParams({required this.url, @JsonKey(name: 'proxy-name') this.proxyName = '',  Map<String, String> headers = const {}, required this.timeout, @JsonKey(name: 'max-body') this.maxBody = 0}): _headers = headers;
  factory _ProbeParams.fromJson(Map<String, dynamic> json) => _$ProbeParamsFromJson(json);

@override final  String url;
@override@JsonKey(name: 'proxy-name') final  String proxyName;
 final  Map<String, String> _headers;
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

@override final  int timeout;
@override@JsonKey(name: 'max-body') final  int maxBody;

/// Create a copy of ProbeParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProbeParamsCopyWith<_ProbeParams> get copyWith => __$ProbeParamsCopyWithImpl<_ProbeParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProbeParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProbeParams&&(identical(other.url, url) || other.url == url)&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.timeout, timeout) || other.timeout == timeout)&&(identical(other.maxBody, maxBody) || other.maxBody == maxBody));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,proxyName,const DeepCollectionEquality().hash(_headers),timeout,maxBody);
}

@override
String toString() {
    return 'ProbeParams(url: $url, proxyName: $proxyName, headers: $headers, timeout: $timeout, maxBody: $maxBody)';
}


}

/// @nodoc
abstract mixin class _$ProbeParamsCopyWith<$Res> implements $ProbeParamsCopyWith<$Res> {
  factory _$ProbeParamsCopyWith(_ProbeParams value, $Res Function(_ProbeParams) _then) = __$ProbeParamsCopyWithImpl;
@override @useResult
$Res call({
 String url,@JsonKey(name: 'proxy-name') String proxyName, Map<String, String> headers, int timeout,@JsonKey(name: 'max-body') int maxBody
});




}
/// @nodoc
class __$ProbeParamsCopyWithImpl<$Res>
    implements _$ProbeParamsCopyWith<$Res> {
  __$ProbeParamsCopyWithImpl(this._self, this._then);

  final _ProbeParams _self;
  final $Res Function(_ProbeParams) _then;

/// Create a copy of ProbeParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? proxyName = null,Object? headers = null,Object? timeout = null,Object? maxBody = null,}) {
  return _then(_ProbeParams(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,maxBody: null == maxBody ? _self.maxBody : maxBody // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProbeResult {

@JsonKey(name: 'status-code') int get statusCode; int get delay; String get body; String get url; List<String> get chains; String get rule;@JsonKey(name: 'rule-payload') String get rulePayload; String? get error; String? get message;
/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProbeResultCopyWith<ProbeResult> get copyWith => _$ProbeResultCopyWithImpl<ProbeResult>(this as ProbeResult, _$identity);

  /// Serializes this ProbeResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProbeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProbeResult&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.rule, _this.rule) || other.rule == _this.rule)&&(identical(other.rulePayload, _this.rulePayload) || other.rulePayload == _this.rulePayload)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.message, _this.message) || other.message == _this.message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProbeResult;
  return Object.hash(runtimeType,_this.statusCode,_this.delay,_this.body,_this.url,const DeepCollectionEquality().hash(_this.chains),_this.rule,_this.rulePayload,_this.error,_this.message);
}

@override
String toString() {
  final _this = this as ProbeResult;
  return 'ProbeResult(statusCode: ${_this.statusCode}, delay: ${_this.delay}, body: ${_this.body}, url: ${_this.url}, chains: ${_this.chains}, rule: ${_this.rule}, rulePayload: ${_this.rulePayload}, error: ${_this.error}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ProbeResultCopyWith<$Res>  {
  factory $ProbeResultCopyWith(ProbeResult value, $Res Function(ProbeResult) _then) = _$ProbeResultCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'status-code') int statusCode, int delay, String body, String url, List<String> chains, String rule,@JsonKey(name: 'rule-payload') String rulePayload, String? error, String? message
});




}
/// @nodoc
class _$ProbeResultCopyWithImpl<$Res>
    implements $ProbeResultCopyWith<$Res> {
  _$ProbeResultCopyWithImpl(this._self, this._then);

  final ProbeResult _self;
  final $Res Function(ProbeResult) _then;

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? delay = null,Object? body = null,Object? url = null,Object? chains = null,Object? rule = null,Object? rulePayload = null,Object? error = freezed,Object? message = freezed,}) {
  return _then(ProbeResult(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProbeResult].
extension ProbeResultPatterns on ProbeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProbeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProbeResult value)  $default,){
final _that = this;
switch (_that) {
case _ProbeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProbeResult value)?  $default,){
final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'status-code')  int statusCode,  int delay,  String body,  String url,  List<String> chains,  String rule, @JsonKey(name: 'rule-payload')  String rulePayload,  String? error,  String? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
return $default(_that.statusCode,_that.delay,_that.body,_that.url,_that.chains,_that.rule,_that.rulePayload,_that.error,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'status-code')  int statusCode,  int delay,  String body,  String url,  List<String> chains,  String rule, @JsonKey(name: 'rule-payload')  String rulePayload,  String? error,  String? message)  $default,) {final _that = this;
switch (_that) {
case _ProbeResult():
return $default(_that.statusCode,_that.delay,_that.body,_that.url,_that.chains,_that.rule,_that.rulePayload,_that.error,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'status-code')  int statusCode,  int delay,  String body,  String url,  List<String> chains,  String rule, @JsonKey(name: 'rule-payload')  String rulePayload,  String? error,  String? message)?  $default,) {final _that = this;
switch (_that) {
case _ProbeResult() when $default != null:
return $default(_that.statusCode,_that.delay,_that.body,_that.url,_that.chains,_that.rule,_that.rulePayload,_that.error,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProbeResult implements ProbeResult {
  const _ProbeResult({@JsonKey(name: 'status-code') this.statusCode = 0, this.delay = 0, this.body = '', this.url = '',  List<String> chains = const [], this.rule = '', @JsonKey(name: 'rule-payload') this.rulePayload = '', this.error, this.message}): _chains = chains;
  factory _ProbeResult.fromJson(Map<String, dynamic> json) => _$ProbeResultFromJson(json);

@override@JsonKey(name: 'status-code') final  int statusCode;
@override@JsonKey() final  int delay;
@override@JsonKey() final  String body;
@override@JsonKey() final  String url;
 final  List<String> _chains;
@override@JsonKey() List<String> get chains {
  if (_chains is EqualUnmodifiableListView) return _chains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chains);
}

@override@JsonKey() final  String rule;
@override@JsonKey(name: 'rule-payload') final  String rulePayload;
@override final  String? error;
@override final  String? message;

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProbeResultCopyWith<_ProbeResult> get copyWith => __$ProbeResultCopyWithImpl<_ProbeResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProbeResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProbeResult&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.body, body) || other.body == body)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.rulePayload, rulePayload) || other.rulePayload == rulePayload)&&(identical(other.error, error) || other.error == error)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,delay,body,url,const DeepCollectionEquality().hash(_chains),rule,rulePayload,error,message);
}

@override
String toString() {
    return 'ProbeResult(statusCode: $statusCode, delay: $delay, body: $body, url: $url, chains: $chains, rule: $rule, rulePayload: $rulePayload, error: $error, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ProbeResultCopyWith<$Res> implements $ProbeResultCopyWith<$Res> {
  factory _$ProbeResultCopyWith(_ProbeResult value, $Res Function(_ProbeResult) _then) = __$ProbeResultCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'status-code') int statusCode, int delay, String body, String url, List<String> chains, String rule,@JsonKey(name: 'rule-payload') String rulePayload, String? error, String? message
});




}
/// @nodoc
class __$ProbeResultCopyWithImpl<$Res>
    implements _$ProbeResultCopyWith<$Res> {
  __$ProbeResultCopyWithImpl(this._self, this._then);

  final _ProbeResult _self;
  final $Res Function(_ProbeResult) _then;

/// Create a copy of ProbeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? delay = null,Object? body = null,Object? url = null,Object? chains = null,Object? rule = null,Object? rulePayload = null,Object? error = freezed,Object? message = freezed,}) {
  return _then(_ProbeResult(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OutboundIpParams {

@JsonKey(name: 'proxy-name') String get proxyName; List<String> get urls; int get timeout;
/// Create a copy of OutboundIpParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboundIpParamsCopyWith<OutboundIpParams> get copyWith => _$OutboundIpParamsCopyWithImpl<OutboundIpParams>(this as OutboundIpParams, _$identity);

  /// Serializes this OutboundIpParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboundIpParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboundIpParams&&(identical(other.proxyName, _this.proxyName) || other.proxyName == _this.proxyName)&&const DeepCollectionEquality().equals(other.urls, _this.urls)&&(identical(other.timeout, _this.timeout) || other.timeout == _this.timeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboundIpParams;
  return Object.hash(runtimeType,_this.proxyName,const DeepCollectionEquality().hash(_this.urls),_this.timeout);
}

@override
String toString() {
  final _this = this as OutboundIpParams;
  return 'OutboundIpParams(proxyName: ${_this.proxyName}, urls: ${_this.urls}, timeout: ${_this.timeout})';
}


}

/// @nodoc
abstract mixin class $OutboundIpParamsCopyWith<$Res>  {
  factory $OutboundIpParamsCopyWith(OutboundIpParams value, $Res Function(OutboundIpParams) _then) = _$OutboundIpParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'proxy-name') String proxyName, List<String> urls, int timeout
});




}
/// @nodoc
class _$OutboundIpParamsCopyWithImpl<$Res>
    implements $OutboundIpParamsCopyWith<$Res> {
  _$OutboundIpParamsCopyWithImpl(this._self, this._then);

  final OutboundIpParams _self;
  final $Res Function(OutboundIpParams) _then;

/// Create a copy of OutboundIpParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyName = null,Object? urls = null,Object? timeout = null,}) {
  return _then(OutboundIpParams(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,urls: null == urls ? _self.urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboundIpParams].
extension OutboundIpParamsPatterns on OutboundIpParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboundIpParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboundIpParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboundIpParams value)  $default,){
final _that = this;
switch (_that) {
case _OutboundIpParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboundIpParams value)?  $default,){
final _that = this;
switch (_that) {
case _OutboundIpParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-name')  String proxyName,  List<String> urls,  int timeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboundIpParams() when $default != null:
return $default(_that.proxyName,_that.urls,_that.timeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-name')  String proxyName,  List<String> urls,  int timeout)  $default,) {final _that = this;
switch (_that) {
case _OutboundIpParams():
return $default(_that.proxyName,_that.urls,_that.timeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'proxy-name')  String proxyName,  List<String> urls,  int timeout)?  $default,) {final _that = this;
switch (_that) {
case _OutboundIpParams() when $default != null:
return $default(_that.proxyName,_that.urls,_that.timeout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboundIpParams implements OutboundIpParams {
  const _OutboundIpParams({@JsonKey(name: 'proxy-name') this.proxyName = '',  List<String> urls = const [], required this.timeout}): _urls = urls;
  factory _OutboundIpParams.fromJson(Map<String, dynamic> json) => _$OutboundIpParamsFromJson(json);

@override@JsonKey(name: 'proxy-name') final  String proxyName;
 final  List<String> _urls;
@override@JsonKey() List<String> get urls {
  if (_urls is EqualUnmodifiableListView) return _urls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_urls);
}

@override final  int timeout;

/// Create a copy of OutboundIpParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboundIpParamsCopyWith<_OutboundIpParams> get copyWith => __$OutboundIpParamsCopyWithImpl<_OutboundIpParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboundIpParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboundIpParams&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&const DeepCollectionEquality().equals(other.urls, _urls)&&(identical(other.timeout, timeout) || other.timeout == timeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,proxyName,const DeepCollectionEquality().hash(_urls),timeout);
}

@override
String toString() {
    return 'OutboundIpParams(proxyName: $proxyName, urls: $urls, timeout: $timeout)';
}


}

/// @nodoc
abstract mixin class _$OutboundIpParamsCopyWith<$Res> implements $OutboundIpParamsCopyWith<$Res> {
  factory _$OutboundIpParamsCopyWith(_OutboundIpParams value, $Res Function(_OutboundIpParams) _then) = __$OutboundIpParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'proxy-name') String proxyName, List<String> urls, int timeout
});




}
/// @nodoc
class __$OutboundIpParamsCopyWithImpl<$Res>
    implements _$OutboundIpParamsCopyWith<$Res> {
  __$OutboundIpParamsCopyWithImpl(this._self, this._then);

  final _OutboundIpParams _self;
  final $Res Function(_OutboundIpParams) _then;

/// Create a copy of OutboundIpParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyName = null,Object? urls = null,Object? timeout = null,}) {
  return _then(_OutboundIpParams(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,urls: null == urls ? _self._urls : urls // ignore: cast_nullable_to_non_nullable
as List<String>,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OutboundIpResult {

 String get url; String get body; int get delay; List<String> get chains; String? get error;@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'picks-version') int get picksVersion;
/// Create a copy of OutboundIpResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboundIpResultCopyWith<OutboundIpResult> get copyWith => _$OutboundIpResultCopyWithImpl<OutboundIpResult>(this as OutboundIpResult, _$identity);

  /// Serializes this OutboundIpResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboundIpResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboundIpResult&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.picksVersion, _this.picksVersion) || other.picksVersion == _this.picksVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboundIpResult;
  return Object.hash(runtimeType,_this.url,_this.body,_this.delay,const DeepCollectionEquality().hash(_this.chains),_this.error,_this.coreEpoch,_this.picksVersion);
}

@override
String toString() {
  final _this = this as OutboundIpResult;
  return 'OutboundIpResult(url: ${_this.url}, body: ${_this.body}, delay: ${_this.delay}, chains: ${_this.chains}, error: ${_this.error}, coreEpoch: ${_this.coreEpoch}, picksVersion: ${_this.picksVersion})';
}


}

/// @nodoc
abstract mixin class $OutboundIpResultCopyWith<$Res>  {
  factory $OutboundIpResultCopyWith(OutboundIpResult value, $Res Function(OutboundIpResult) _then) = _$OutboundIpResultCopyWithImpl;
@useResult
$Res call({
 String url, String body, int delay, List<String> chains, String? error,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'picks-version') int picksVersion
});




}
/// @nodoc
class _$OutboundIpResultCopyWithImpl<$Res>
    implements $OutboundIpResultCopyWith<$Res> {
  _$OutboundIpResultCopyWithImpl(this._self, this._then);

  final OutboundIpResult _self;
  final $Res Function(OutboundIpResult) _then;

/// Create a copy of OutboundIpResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? body = null,Object? delay = null,Object? chains = null,Object? error = freezed,Object? coreEpoch = null,Object? picksVersion = null,}) {
  return _then(OutboundIpResult(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,picksVersion: null == picksVersion ? _self.picksVersion : picksVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboundIpResult].
extension OutboundIpResultPatterns on OutboundIpResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboundIpResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboundIpResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboundIpResult value)  $default,){
final _that = this;
switch (_that) {
case _OutboundIpResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboundIpResult value)?  $default,){
final _that = this;
switch (_that) {
case _OutboundIpResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String body,  int delay,  List<String> chains,  String? error, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboundIpResult() when $default != null:
return $default(_that.url,_that.body,_that.delay,_that.chains,_that.error,_that.coreEpoch,_that.picksVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String body,  int delay,  List<String> chains,  String? error, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion)  $default,) {final _that = this;
switch (_that) {
case _OutboundIpResult():
return $default(_that.url,_that.body,_that.delay,_that.chains,_that.error,_that.coreEpoch,_that.picksVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String body,  int delay,  List<String> chains,  String? error, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion)?  $default,) {final _that = this;
switch (_that) {
case _OutboundIpResult() when $default != null:
return $default(_that.url,_that.body,_that.delay,_that.chains,_that.error,_that.coreEpoch,_that.picksVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboundIpResult implements OutboundIpResult {
  const _OutboundIpResult({this.url = '', this.body = '', this.delay = 0,  List<String> chains = const [], this.error, @JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'picks-version') this.picksVersion = 0}): _chains = chains;
  factory _OutboundIpResult.fromJson(Map<String, dynamic> json) => _$OutboundIpResultFromJson(json);

@override@JsonKey() final  String url;
@override@JsonKey() final  String body;
@override@JsonKey() final  int delay;
 final  List<String> _chains;
@override@JsonKey() List<String> get chains {
  if (_chains is EqualUnmodifiableListView) return _chains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chains);
}

@override final  String? error;
@override@JsonKey(name: 'core-epoch') final  int coreEpoch;
@override@JsonKey(name: 'picks-version') final  int picksVersion;

/// Create a copy of OutboundIpResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboundIpResultCopyWith<_OutboundIpResult> get copyWith => __$OutboundIpResultCopyWithImpl<_OutboundIpResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboundIpResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboundIpResult&&(identical(other.url, url) || other.url == url)&&(identical(other.body, body) || other.body == body)&&(identical(other.delay, delay) || other.delay == delay)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.error, error) || other.error == error)&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.picksVersion, picksVersion) || other.picksVersion == picksVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,body,delay,const DeepCollectionEquality().hash(_chains),error,coreEpoch,picksVersion);
}

@override
String toString() {
    return 'OutboundIpResult(url: $url, body: $body, delay: $delay, chains: $chains, error: $error, coreEpoch: $coreEpoch, picksVersion: $picksVersion)';
}


}

/// @nodoc
abstract mixin class _$OutboundIpResultCopyWith<$Res> implements $OutboundIpResultCopyWith<$Res> {
  factory _$OutboundIpResultCopyWith(_OutboundIpResult value, $Res Function(_OutboundIpResult) _then) = __$OutboundIpResultCopyWithImpl;
@override @useResult
$Res call({
 String url, String body, int delay, List<String> chains, String? error,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'picks-version') int picksVersion
});




}
/// @nodoc
class __$OutboundIpResultCopyWithImpl<$Res>
    implements _$OutboundIpResultCopyWith<$Res> {
  __$OutboundIpResultCopyWithImpl(this._self, this._then);

  final _OutboundIpResult _self;
  final $Res Function(_OutboundIpResult) _then;

/// Create a copy of OutboundIpResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? body = null,Object? delay = null,Object? chains = null,Object? error = freezed,Object? coreEpoch = null,Object? picksVersion = null,}) {
  return _then(_OutboundIpResult(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,picksVersion: null == picksVersion ? _self.picksVersion : picksVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ServiceCheckParams {

@JsonKey(name: 'proxy-name') String get proxyName; List<String> get names; int get timeout;
/// Create a copy of ServiceCheckParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceCheckParamsCopyWith<ServiceCheckParams> get copyWith => _$ServiceCheckParamsCopyWithImpl<ServiceCheckParams>(this as ServiceCheckParams, _$identity);

  /// Serializes this ServiceCheckParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceCheckParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceCheckParams&&(identical(other.proxyName, _this.proxyName) || other.proxyName == _this.proxyName)&&const DeepCollectionEquality().equals(other.names, _this.names)&&(identical(other.timeout, _this.timeout) || other.timeout == _this.timeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceCheckParams;
  return Object.hash(runtimeType,_this.proxyName,const DeepCollectionEquality().hash(_this.names),_this.timeout);
}

@override
String toString() {
  final _this = this as ServiceCheckParams;
  return 'ServiceCheckParams(proxyName: ${_this.proxyName}, names: ${_this.names}, timeout: ${_this.timeout})';
}


}

/// @nodoc
abstract mixin class $ServiceCheckParamsCopyWith<$Res>  {
  factory $ServiceCheckParamsCopyWith(ServiceCheckParams value, $Res Function(ServiceCheckParams) _then) = _$ServiceCheckParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'proxy-name') String proxyName, List<String> names, int timeout
});




}
/// @nodoc
class _$ServiceCheckParamsCopyWithImpl<$Res>
    implements $ServiceCheckParamsCopyWith<$Res> {
  _$ServiceCheckParamsCopyWithImpl(this._self, this._then);

  final ServiceCheckParams _self;
  final $Res Function(ServiceCheckParams) _then;

/// Create a copy of ServiceCheckParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyName = null,Object? names = null,Object? timeout = null,}) {
  return _then(ServiceCheckParams(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,names: null == names ? _self.names : names // ignore: cast_nullable_to_non_nullable
as List<String>,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceCheckParams].
extension ServiceCheckParamsPatterns on ServiceCheckParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceCheckParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceCheckParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceCheckParams value)  $default,){
final _that = this;
switch (_that) {
case _ServiceCheckParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceCheckParams value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceCheckParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-name')  String proxyName,  List<String> names,  int timeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceCheckParams() when $default != null:
return $default(_that.proxyName,_that.names,_that.timeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-name')  String proxyName,  List<String> names,  int timeout)  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckParams():
return $default(_that.proxyName,_that.names,_that.timeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'proxy-name')  String proxyName,  List<String> names,  int timeout)?  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckParams() when $default != null:
return $default(_that.proxyName,_that.names,_that.timeout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceCheckParams implements ServiceCheckParams {
  const _ServiceCheckParams({@JsonKey(name: 'proxy-name') this.proxyName = '',  List<String> names = const [], required this.timeout}): _names = names;
  factory _ServiceCheckParams.fromJson(Map<String, dynamic> json) => _$ServiceCheckParamsFromJson(json);

@override@JsonKey(name: 'proxy-name') final  String proxyName;
 final  List<String> _names;
@override@JsonKey() List<String> get names {
  if (_names is EqualUnmodifiableListView) return _names;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_names);
}

@override final  int timeout;

/// Create a copy of ServiceCheckParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceCheckParamsCopyWith<_ServiceCheckParams> get copyWith => __$ServiceCheckParamsCopyWithImpl<_ServiceCheckParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceCheckParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceCheckParams&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&const DeepCollectionEquality().equals(other.names, _names)&&(identical(other.timeout, timeout) || other.timeout == timeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,proxyName,const DeepCollectionEquality().hash(_names),timeout);
}

@override
String toString() {
    return 'ServiceCheckParams(proxyName: $proxyName, names: $names, timeout: $timeout)';
}


}

/// @nodoc
abstract mixin class _$ServiceCheckParamsCopyWith<$Res> implements $ServiceCheckParamsCopyWith<$Res> {
  factory _$ServiceCheckParamsCopyWith(_ServiceCheckParams value, $Res Function(_ServiceCheckParams) _then) = __$ServiceCheckParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'proxy-name') String proxyName, List<String> names, int timeout
});




}
/// @nodoc
class __$ServiceCheckParamsCopyWithImpl<$Res>
    implements _$ServiceCheckParamsCopyWith<$Res> {
  __$ServiceCheckParamsCopyWithImpl(this._self, this._then);

  final _ServiceCheckParams _self;
  final $Res Function(_ServiceCheckParams) _then;

/// Create a copy of ServiceCheckParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyName = null,Object? names = null,Object? timeout = null,}) {
  return _then(_ServiceCheckParams(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,names: null == names ? _self._names : names // ignore: cast_nullable_to_non_nullable
as List<String>,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ServiceCheckItem {

 String get name; String get status; String get region; int get delay; List<String> get chains;@JsonKey(name: 'checked-at') int get checkedAt;@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'picks-version') int get picksVersion;
/// Create a copy of ServiceCheckItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceCheckItemCopyWith<ServiceCheckItem> get copyWith => _$ServiceCheckItemCopyWithImpl<ServiceCheckItem>(this as ServiceCheckItem, _$identity);

  /// Serializes this ServiceCheckItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ServiceCheckItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceCheckItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.picksVersion, _this.picksVersion) || other.picksVersion == _this.picksVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceCheckItem;
  return Object.hash(runtimeType,_this.name,_this.status,_this.region,_this.delay,const DeepCollectionEquality().hash(_this.chains),_this.checkedAt,_this.coreEpoch,_this.picksVersion);
}

@override
String toString() {
  final _this = this as ServiceCheckItem;
  return 'ServiceCheckItem(name: ${_this.name}, status: ${_this.status}, region: ${_this.region}, delay: ${_this.delay}, chains: ${_this.chains}, checkedAt: ${_this.checkedAt}, coreEpoch: ${_this.coreEpoch}, picksVersion: ${_this.picksVersion})';
}


}

/// @nodoc
abstract mixin class $ServiceCheckItemCopyWith<$Res>  {
  factory $ServiceCheckItemCopyWith(ServiceCheckItem value, $Res Function(ServiceCheckItem) _then) = _$ServiceCheckItemCopyWithImpl;
@useResult
$Res call({
 String name, String status, String region, int delay, List<String> chains,@JsonKey(name: 'checked-at') int checkedAt,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'picks-version') int picksVersion
});




}
/// @nodoc
class _$ServiceCheckItemCopyWithImpl<$Res>
    implements $ServiceCheckItemCopyWith<$Res> {
  _$ServiceCheckItemCopyWithImpl(this._self, this._then);

  final ServiceCheckItem _self;
  final $Res Function(ServiceCheckItem) _then;

/// Create a copy of ServiceCheckItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? status = null,Object? region = null,Object? delay = null,Object? chains = null,Object? checkedAt = null,Object? coreEpoch = null,Object? picksVersion = null,}) {
  return _then(ServiceCheckItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as int,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,picksVersion: null == picksVersion ? _self.picksVersion : picksVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServiceCheckItem].
extension ServiceCheckItemPatterns on ServiceCheckItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceCheckItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceCheckItem value)  $default,){
final _that = this;
switch (_that) {
case _ServiceCheckItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceCheckItem value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String status,  String region,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
return $default(_that.name,_that.status,_that.region,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.picksVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String status,  String region,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion)  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckItem():
return $default(_that.name,_that.status,_that.region,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.picksVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String status,  String region,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'picks-version')  int picksVersion)?  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
return $default(_that.name,_that.status,_that.region,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.picksVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceCheckItem implements ServiceCheckItem {
  const _ServiceCheckItem({this.name = '', this.status = '', this.region = '', this.delay = 0,  List<String> chains = const [], @JsonKey(name: 'checked-at') this.checkedAt = 0, @JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'picks-version') this.picksVersion = 0}): _chains = chains;
  factory _ServiceCheckItem.fromJson(Map<String, dynamic> json) => _$ServiceCheckItemFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String status;
@override@JsonKey() final  String region;
@override@JsonKey() final  int delay;
 final  List<String> _chains;
@override@JsonKey() List<String> get chains {
  if (_chains is EqualUnmodifiableListView) return _chains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chains);
}

@override@JsonKey(name: 'checked-at') final  int checkedAt;
@override@JsonKey(name: 'core-epoch') final  int coreEpoch;
@override@JsonKey(name: 'picks-version') final  int picksVersion;

/// Create a copy of ServiceCheckItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceCheckItemCopyWith<_ServiceCheckItem> get copyWith => __$ServiceCheckItemCopyWithImpl<_ServiceCheckItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceCheckItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceCheckItem&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.region, region) || other.region == region)&&(identical(other.delay, delay) || other.delay == delay)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.picksVersion, picksVersion) || other.picksVersion == picksVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,status,region,delay,const DeepCollectionEquality().hash(_chains),checkedAt,coreEpoch,picksVersion);
}

@override
String toString() {
    return 'ServiceCheckItem(name: $name, status: $status, region: $region, delay: $delay, chains: $chains, checkedAt: $checkedAt, coreEpoch: $coreEpoch, picksVersion: $picksVersion)';
}


}

/// @nodoc
abstract mixin class _$ServiceCheckItemCopyWith<$Res> implements $ServiceCheckItemCopyWith<$Res> {
  factory _$ServiceCheckItemCopyWith(_ServiceCheckItem value, $Res Function(_ServiceCheckItem) _then) = __$ServiceCheckItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String status, String region, int delay, List<String> chains,@JsonKey(name: 'checked-at') int checkedAt,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'picks-version') int picksVersion
});




}
/// @nodoc
class __$ServiceCheckItemCopyWithImpl<$Res>
    implements _$ServiceCheckItemCopyWith<$Res> {
  __$ServiceCheckItemCopyWithImpl(this._self, this._then);

  final _ServiceCheckItem _self;
  final $Res Function(_ServiceCheckItem) _then;

/// Create a copy of ServiceCheckItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? status = null,Object? region = null,Object? delay = null,Object? chains = null,Object? checkedAt = null,Object? coreEpoch = null,Object? picksVersion = null,}) {
  return _then(_ServiceCheckItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as int,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,picksVersion: null == picksVersion ? _self.picksVersion : picksVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CoreMemoryStats {

 int get rss; int get heapInuse; int get heapIdle; int get stackInuse; int get runtimeOther;
/// Create a copy of CoreMemoryStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreMemoryStatsCopyWith<CoreMemoryStats> get copyWith => _$CoreMemoryStatsCopyWithImpl<CoreMemoryStats>(this as CoreMemoryStats, _$identity);

  /// Serializes this CoreMemoryStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoreMemoryStats;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreMemoryStats&&(identical(other.rss, _this.rss) || other.rss == _this.rss)&&(identical(other.heapInuse, _this.heapInuse) || other.heapInuse == _this.heapInuse)&&(identical(other.heapIdle, _this.heapIdle) || other.heapIdle == _this.heapIdle)&&(identical(other.stackInuse, _this.stackInuse) || other.stackInuse == _this.stackInuse)&&(identical(other.runtimeOther, _this.runtimeOther) || other.runtimeOther == _this.runtimeOther));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoreMemoryStats;
  return Object.hash(runtimeType,_this.rss,_this.heapInuse,_this.heapIdle,_this.stackInuse,_this.runtimeOther);
}

@override
String toString() {
  final _this = this as CoreMemoryStats;
  return 'CoreMemoryStats(rss: ${_this.rss}, heapInuse: ${_this.heapInuse}, heapIdle: ${_this.heapIdle}, stackInuse: ${_this.stackInuse}, runtimeOther: ${_this.runtimeOther})';
}


}

/// @nodoc
abstract mixin class $CoreMemoryStatsCopyWith<$Res>  {
  factory $CoreMemoryStatsCopyWith(CoreMemoryStats value, $Res Function(CoreMemoryStats) _then) = _$CoreMemoryStatsCopyWithImpl;
@useResult
$Res call({
 int rss, int heapInuse, int heapIdle, int stackInuse, int runtimeOther
});




}
/// @nodoc
class _$CoreMemoryStatsCopyWithImpl<$Res>
    implements $CoreMemoryStatsCopyWith<$Res> {
  _$CoreMemoryStatsCopyWithImpl(this._self, this._then);

  final CoreMemoryStats _self;
  final $Res Function(CoreMemoryStats) _then;

/// Create a copy of CoreMemoryStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rss = null,Object? heapInuse = null,Object? heapIdle = null,Object? stackInuse = null,Object? runtimeOther = null,}) {
  return _then(CoreMemoryStats(
rss: null == rss ? _self.rss : rss // ignore: cast_nullable_to_non_nullable
as int,heapInuse: null == heapInuse ? _self.heapInuse : heapInuse // ignore: cast_nullable_to_non_nullable
as int,heapIdle: null == heapIdle ? _self.heapIdle : heapIdle // ignore: cast_nullable_to_non_nullable
as int,stackInuse: null == stackInuse ? _self.stackInuse : stackInuse // ignore: cast_nullable_to_non_nullable
as int,runtimeOther: null == runtimeOther ? _self.runtimeOther : runtimeOther // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreMemoryStats].
extension CoreMemoryStatsPatterns on CoreMemoryStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreMemoryStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreMemoryStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreMemoryStats value)  $default,){
final _that = this;
switch (_that) {
case _CoreMemoryStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreMemoryStats value)?  $default,){
final _that = this;
switch (_that) {
case _CoreMemoryStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rss,  int heapInuse,  int heapIdle,  int stackInuse,  int runtimeOther)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreMemoryStats() when $default != null:
return $default(_that.rss,_that.heapInuse,_that.heapIdle,_that.stackInuse,_that.runtimeOther);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rss,  int heapInuse,  int heapIdle,  int stackInuse,  int runtimeOther)  $default,) {final _that = this;
switch (_that) {
case _CoreMemoryStats():
return $default(_that.rss,_that.heapInuse,_that.heapIdle,_that.stackInuse,_that.runtimeOther);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rss,  int heapInuse,  int heapIdle,  int stackInuse,  int runtimeOther)?  $default,) {final _that = this;
switch (_that) {
case _CoreMemoryStats() when $default != null:
return $default(_that.rss,_that.heapInuse,_that.heapIdle,_that.stackInuse,_that.runtimeOther);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreMemoryStats implements CoreMemoryStats {
  const _CoreMemoryStats({this.rss = 0, this.heapInuse = 0, this.heapIdle = 0, this.stackInuse = 0, this.runtimeOther = 0});
  factory _CoreMemoryStats.fromJson(Map<String, dynamic> json) => _$CoreMemoryStatsFromJson(json);

@override@JsonKey() final  int rss;
@override@JsonKey() final  int heapInuse;
@override@JsonKey() final  int heapIdle;
@override@JsonKey() final  int stackInuse;
@override@JsonKey() final  int runtimeOther;

/// Create a copy of CoreMemoryStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreMemoryStatsCopyWith<_CoreMemoryStats> get copyWith => __$CoreMemoryStatsCopyWithImpl<_CoreMemoryStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreMemoryStatsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreMemoryStats&&(identical(other.rss, rss) || other.rss == rss)&&(identical(other.heapInuse, heapInuse) || other.heapInuse == heapInuse)&&(identical(other.heapIdle, heapIdle) || other.heapIdle == heapIdle)&&(identical(other.stackInuse, stackInuse) || other.stackInuse == stackInuse)&&(identical(other.runtimeOther, runtimeOther) || other.runtimeOther == runtimeOther));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rss,heapInuse,heapIdle,stackInuse,runtimeOther);
}

@override
String toString() {
    return 'CoreMemoryStats(rss: $rss, heapInuse: $heapInuse, heapIdle: $heapIdle, stackInuse: $stackInuse, runtimeOther: $runtimeOther)';
}


}

/// @nodoc
abstract mixin class _$CoreMemoryStatsCopyWith<$Res> implements $CoreMemoryStatsCopyWith<$Res> {
  factory _$CoreMemoryStatsCopyWith(_CoreMemoryStats value, $Res Function(_CoreMemoryStats) _then) = __$CoreMemoryStatsCopyWithImpl;
@override @useResult
$Res call({
 int rss, int heapInuse, int heapIdle, int stackInuse, int runtimeOther
});




}
/// @nodoc
class __$CoreMemoryStatsCopyWithImpl<$Res>
    implements _$CoreMemoryStatsCopyWith<$Res> {
  __$CoreMemoryStatsCopyWithImpl(this._self, this._then);

  final _CoreMemoryStats _self;
  final $Res Function(_CoreMemoryStats) _then;

/// Create a copy of CoreMemoryStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rss = null,Object? heapInuse = null,Object? heapIdle = null,Object? stackInuse = null,Object? runtimeOther = null,}) {
  return _then(_CoreMemoryStats(
rss: null == rss ? _self.rss : rss // ignore: cast_nullable_to_non_nullable
as int,heapInuse: null == heapInuse ? _self.heapInuse : heapInuse // ignore: cast_nullable_to_non_nullable
as int,heapIdle: null == heapIdle ? _self.heapIdle : heapIdle // ignore: cast_nullable_to_non_nullable
as int,stackInuse: null == stackInuse ? _self.stackInuse : stackInuse // ignore: cast_nullable_to_non_nullable
as int,runtimeOther: null == runtimeOther ? _self.runtimeOther : runtimeOther // ignore: cast_nullable_to_non_nullable
as int,
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
  final _this = this as Now;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Now&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Now;
  return Object.hash(runtimeType,_this.name,_this.value);
}

@override
String toString() {
  final _this = this as Now;
  return 'Now(name: ${_this.name}, value: ${_this.value})';
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
  return _then(Now(
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
int get hashCode {
    return Object.hash(runtimeType,name,value);
}

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
  final _this = this as ProviderSubscriptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderSubscriptionInfo&&(identical(other.upload, _this.upload) || other.upload == _this.upload)&&(identical(other.download, _this.download) || other.download == _this.download)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.expire, _this.expire) || other.expire == _this.expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProviderSubscriptionInfo;
  return Object.hash(runtimeType,_this.upload,_this.download,_this.total,_this.expire);
}

@override
String toString() {
  final _this = this as ProviderSubscriptionInfo;
  return 'ProviderSubscriptionInfo(upload: ${_this.upload}, download: ${_this.download}, total: ${_this.total}, expire: ${_this.expire})';
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
  return _then(ProviderSubscriptionInfo(
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
int get hashCode {
    return Object.hash(runtimeType,upload,download,total,expire);
}

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

 String get name; String get type; String? get path; int get count;@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? get subscriptionInfo;@JsonKey(name: 'vehicle-type') String get vehicleType;@JsonKey(name: 'update-at') DateTime get updateAt;
/// Create a copy of ExternalProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExternalProviderCopyWith<ExternalProvider> get copyWith => _$ExternalProviderCopyWithImpl<ExternalProvider>(this as ExternalProvider, _$identity);

  /// Serializes this ExternalProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExternalProvider;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExternalProvider&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.subscriptionInfo, _this.subscriptionInfo) || other.subscriptionInfo == _this.subscriptionInfo)&&(identical(other.vehicleType, _this.vehicleType) || other.vehicleType == _this.vehicleType)&&(identical(other.updateAt, _this.updateAt) || other.updateAt == _this.updateAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExternalProvider;
  return Object.hash(runtimeType,_this.name,_this.type,_this.path,_this.count,_this.subscriptionInfo,_this.vehicleType,_this.updateAt);
}

@override
String toString() {
  final _this = this as ExternalProvider;
  return 'ExternalProvider(name: ${_this.name}, type: ${_this.type}, path: ${_this.path}, count: ${_this.count}, subscriptionInfo: ${_this.subscriptionInfo}, vehicleType: ${_this.vehicleType}, updateAt: ${_this.updateAt})';
}


}

/// @nodoc
abstract mixin class $ExternalProviderCopyWith<$Res>  {
  factory $ExternalProviderCopyWith(ExternalProvider value, $Res Function(ExternalProvider) _then) = _$ExternalProviderCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? path, int count,@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? subscriptionInfo,@JsonKey(name: 'vehicle-type') String vehicleType,@JsonKey(name: 'update-at') DateTime updateAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? path = freezed,Object? count = null,Object? subscriptionInfo = freezed,Object? vehicleType = null,Object? updateAt = null,}) {
  return _then(ExternalProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.vehicleType,_that.updateAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)  $default,) {final _that = this;
switch (_that) {
case _ExternalProvider():
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.vehicleType,_that.updateAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? path,  int count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore)  SubscriptionInfo? subscriptionInfo, @JsonKey(name: 'vehicle-type')  String vehicleType, @JsonKey(name: 'update-at')  DateTime updateAt)?  $default,) {final _that = this;
switch (_that) {
case _ExternalProvider() when $default != null:
return $default(_that.name,_that.type,_that.path,_that.count,_that.subscriptionInfo,_that.vehicleType,_that.updateAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExternalProvider implements ExternalProvider {
  const _ExternalProvider({required this.name, required this.type, this.path, required this.count, @JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) this.subscriptionInfo, @JsonKey(name: 'vehicle-type') required this.vehicleType, @JsonKey(name: 'update-at') required this.updateAt});
  factory _ExternalProvider.fromJson(Map<String, dynamic> json) => _$ExternalProviderFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? path;
@override final  int count;
@override@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) final  SubscriptionInfo? subscriptionInfo;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExternalProvider&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.path, path) || other.path == path)&&(identical(other.count, count) || other.count == count)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.updateAt, updateAt) || other.updateAt == updateAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,type,path,count,subscriptionInfo,vehicleType,updateAt);
}

@override
String toString() {
    return 'ExternalProvider(name: $name, type: $type, path: $path, count: $count, subscriptionInfo: $subscriptionInfo, vehicleType: $vehicleType, updateAt: $updateAt)';
}


}

/// @nodoc
abstract mixin class _$ExternalProviderCopyWith<$Res> implements $ExternalProviderCopyWith<$Res> {
  factory _$ExternalProviderCopyWith(_ExternalProvider value, $Res Function(_ExternalProvider) _then) = __$ExternalProviderCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? path, int count,@JsonKey(name: 'subscription-info', fromJson: subscriptionInfoFormCore) SubscriptionInfo? subscriptionInfo,@JsonKey(name: 'vehicle-type') String vehicleType,@JsonKey(name: 'update-at') DateTime updateAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? path = freezed,Object? count = null,Object? subscriptionInfo = freezed,Object? vehicleType = null,Object? updateAt = null,}) {
  return _then(_ExternalProvider(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
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
mixin _$ProxiesData {

 Map<String, dynamic> get proxies; List<String> get all;
/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesDataCopyWith<ProxiesData> get copyWith => _$ProxiesDataCopyWithImpl<ProxiesData>(this as ProxiesData, _$identity);

  /// Serializes this ProxiesData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProxiesData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesData&&const DeepCollectionEquality().equals(other.proxies, _this.proxies)&&const DeepCollectionEquality().equals(other.all, _this.all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProxiesData;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.proxies),const DeepCollectionEquality().hash(_this.all));
}

@override
String toString() {
  final _this = this as ProxiesData;
  return 'ProxiesData(proxies: ${_this.proxies}, all: ${_this.all})';
}


}

/// @nodoc
abstract mixin class $ProxiesDataCopyWith<$Res>  {
  factory $ProxiesDataCopyWith(ProxiesData value, $Res Function(ProxiesData) _then) = _$ProxiesDataCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> proxies, List<String> all
});




}
/// @nodoc
class _$ProxiesDataCopyWithImpl<$Res>
    implements $ProxiesDataCopyWith<$Res> {
  _$ProxiesDataCopyWithImpl(this._self, this._then);

  final ProxiesData _self;
  final $Res Function(ProxiesData) _then;

/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxies = null,Object? all = null,}) {
  return _then(ProxiesData(
proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesData].
extension ProxiesDataPatterns on ProxiesData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesData value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesData value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> proxies,  List<String> all)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
return $default(_that.proxies,_that.all);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> proxies,  List<String> all)  $default,) {final _that = this;
switch (_that) {
case _ProxiesData():
return $default(_that.proxies,_that.all);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> proxies,  List<String> all)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesData() when $default != null:
return $default(_that.proxies,_that.all);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProxiesData implements ProxiesData {
  const _ProxiesData({required  Map<String, dynamic> proxies, required  List<String> all}): _proxies = proxies,_all = all;
  factory _ProxiesData.fromJson(Map<String, dynamic> json) => _$ProxiesDataFromJson(json);

 final  Map<String, dynamic> _proxies;
@override Map<String, dynamic> get proxies {
  if (_proxies is EqualUnmodifiableMapView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_proxies);
}

 final  List<String> _all;
@override List<String> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}


/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesDataCopyWith<_ProxiesData> get copyWith => __$ProxiesDataCopyWithImpl<_ProxiesData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxiesDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesData&&const DeepCollectionEquality().equals(other.proxies, _proxies)&&const DeepCollectionEquality().equals(other.all, _all));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_proxies),const DeepCollectionEquality().hash(_all));
}

@override
String toString() {
    return 'ProxiesData(proxies: $proxies, all: $all)';
}


}

/// @nodoc
abstract mixin class _$ProxiesDataCopyWith<$Res> implements $ProxiesDataCopyWith<$Res> {
  factory _$ProxiesDataCopyWith(_ProxiesData value, $Res Function(_ProxiesData) _then) = __$ProxiesDataCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> proxies, List<String> all
});




}
/// @nodoc
class __$ProxiesDataCopyWithImpl<$Res>
    implements _$ProxiesDataCopyWith<$Res> {
  __$ProxiesDataCopyWithImpl(this._self, this._then);

  final _ProxiesData _self;
  final $Res Function(_ProxiesData) _then;

/// Create a copy of ProxiesData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxies = null,Object? all = null,}) {
  return _then(_ProxiesData(
proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

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

@JsonKey(includeIfNull: false) SetupBase? get base;@JsonKey(name: 'selected-map') Map<String, String> get selectedMap; CoreOptions get options;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupParams&&(identical(other.base, _this.base) || other.base == _this.base)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&(identical(other.options, _this.options) || other.options == _this.options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupParams;
  return Object.hash(runtimeType,_this.base,const DeepCollectionEquality().hash(_this.selectedMap),_this.options);
}

@override
String toString() {
  final _this = this as SetupParams;
  return 'SetupParams(base: ${_this.base}, selectedMap: ${_this.selectedMap}, options: ${_this.options})';
}


}

/// @nodoc
abstract mixin class $SetupParamsCopyWith<$Res>  {
  factory $SetupParamsCopyWith(SetupParams value, $Res Function(SetupParams) _then) = _$SetupParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) SetupBase? base,@JsonKey(name: 'selected-map') Map<String, String> selectedMap, CoreOptions options
});


$SetupBaseCopyWith<$Res>? get base;$CoreOptionsCopyWith<$Res> get options;

}
/// @nodoc
class _$SetupParamsCopyWithImpl<$Res>
    implements $SetupParamsCopyWith<$Res> {
  _$SetupParamsCopyWithImpl(this._self, this._then);

  final SetupParams _self;
  final $Res Function(SetupParams) _then;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = freezed,Object? selectedMap = null,Object? options = null,}) {
  return _then(SetupParams(
base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as SetupBase?,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as CoreOptions,
  ));
}
/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SetupBaseCopyWith<$Res>? get base {
    if (_self.base == null) {
    return null;
  }

  return $SetupBaseCopyWith<$Res>(_self.base!, (value) {
    return _then(_self.copyWith(base: value));
  });
}/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreOptionsCopyWith<$Res> get options {
  
  return $CoreOptionsCopyWith<$Res>(_self.options, (value) {
    return _then(_self.copyWith(options: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SetupBase? base, @JsonKey(name: 'selected-map')  Map<String, String> selectedMap,  CoreOptions options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.base,_that.selectedMap,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeIfNull: false)  SetupBase? base, @JsonKey(name: 'selected-map')  Map<String, String> selectedMap,  CoreOptions options)  $default,) {final _that = this;
switch (_that) {
case _SetupParams():
return $default(_that.base,_that.selectedMap,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeIfNull: false)  SetupBase? base, @JsonKey(name: 'selected-map')  Map<String, String> selectedMap,  CoreOptions options)?  $default,) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.base,_that.selectedMap,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupParams implements SetupParams {
  const _SetupParams({@JsonKey(includeIfNull: false) this.base, @JsonKey(name: 'selected-map') required  Map<String, String> selectedMap, required this.options}): _selectedMap = selectedMap;
  factory _SetupParams.fromJson(Map<String, dynamic> json) => _$SetupParamsFromJson(json);

@override@JsonKey(includeIfNull: false) final  SetupBase? base;
 final  Map<String, String> _selectedMap;
@override@JsonKey(name: 'selected-map') Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override final  CoreOptions options;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupParams&&(identical(other.base, base) || other.base == base)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&(identical(other.options, options) || other.options == options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,const DeepCollectionEquality().hash(_selectedMap),options);
}

@override
String toString() {
    return 'SetupParams(base: $base, selectedMap: $selectedMap, options: $options)';
}


}

/// @nodoc
abstract mixin class _$SetupParamsCopyWith<$Res> implements $SetupParamsCopyWith<$Res> {
  factory _$SetupParamsCopyWith(_SetupParams value, $Res Function(_SetupParams) _then) = __$SetupParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeIfNull: false) SetupBase? base,@JsonKey(name: 'selected-map') Map<String, String> selectedMap, CoreOptions options
});


@override $SetupBaseCopyWith<$Res>? get base;@override $CoreOptionsCopyWith<$Res> get options;

}
/// @nodoc
class __$SetupParamsCopyWithImpl<$Res>
    implements _$SetupParamsCopyWith<$Res> {
  __$SetupParamsCopyWithImpl(this._self, this._then);

  final _SetupParams _self;
  final $Res Function(_SetupParams) _then;

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? base = freezed,Object? selectedMap = null,Object? options = null,}) {
  return _then(_SetupParams(
base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as SetupBase?,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as CoreOptions,
  ));
}

/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SetupBaseCopyWith<$Res>? get base {
    if (_self.base == null) {
    return null;
  }

  return $SetupBaseCopyWith<$Res>(_self.base!, (value) {
    return _then(_self.copyWith(base: value));
  });
}/// Create a copy of SetupParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreOptionsCopyWith<$Res> get options {
  
  return $CoreOptionsCopyWith<$Res>(_self.options, (value) {
    return _then(_self.copyWith(options: value));
  });
}
}


/// @nodoc
mixin _$CoreOptions {

@JsonKey(name: 'test-url') String get testUrl;@JsonKey(name: 'skip-cert-verify') bool get skipCertVerify;@JsonKey(name: 'delay-test-timeout') int get delayTestTimeout;@JsonKey(name: 'mitm-capture') bool get mitmCapture;
/// Create a copy of CoreOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoreOptionsCopyWith<CoreOptions> get copyWith => _$CoreOptionsCopyWithImpl<CoreOptions>(this as CoreOptions, _$identity);

  /// Serializes this CoreOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CoreOptions;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoreOptions&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl)&&(identical(other.skipCertVerify, _this.skipCertVerify) || other.skipCertVerify == _this.skipCertVerify)&&(identical(other.delayTestTimeout, _this.delayTestTimeout) || other.delayTestTimeout == _this.delayTestTimeout)&&(identical(other.mitmCapture, _this.mitmCapture) || other.mitmCapture == _this.mitmCapture));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CoreOptions;
  return Object.hash(runtimeType,_this.testUrl,_this.skipCertVerify,_this.delayTestTimeout,_this.mitmCapture);
}

@override
String toString() {
  final _this = this as CoreOptions;
  return 'CoreOptions(testUrl: ${_this.testUrl}, skipCertVerify: ${_this.skipCertVerify}, delayTestTimeout: ${_this.delayTestTimeout}, mitmCapture: ${_this.mitmCapture})';
}


}

/// @nodoc
abstract mixin class $CoreOptionsCopyWith<$Res>  {
  factory $CoreOptionsCopyWith(CoreOptions value, $Res Function(CoreOptions) _then) = _$CoreOptionsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'test-url') String testUrl,@JsonKey(name: 'skip-cert-verify') bool skipCertVerify,@JsonKey(name: 'delay-test-timeout') int delayTestTimeout,@JsonKey(name: 'mitm-capture') bool mitmCapture
});




}
/// @nodoc
class _$CoreOptionsCopyWithImpl<$Res>
    implements $CoreOptionsCopyWith<$Res> {
  _$CoreOptionsCopyWithImpl(this._self, this._then);

  final CoreOptions _self;
  final $Res Function(CoreOptions) _then;

/// Create a copy of CoreOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testUrl = null,Object? skipCertVerify = null,Object? delayTestTimeout = null,Object? mitmCapture = null,}) {
  return _then(CoreOptions(
testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,skipCertVerify: null == skipCertVerify ? _self.skipCertVerify : skipCertVerify // ignore: cast_nullable_to_non_nullable
as bool,delayTestTimeout: null == delayTestTimeout ? _self.delayTestTimeout : delayTestTimeout // ignore: cast_nullable_to_non_nullable
as int,mitmCapture: null == mitmCapture ? _self.mitmCapture : mitmCapture // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CoreOptions].
extension CoreOptionsPatterns on CoreOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoreOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoreOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoreOptions value)  $default,){
final _that = this;
switch (_that) {
case _CoreOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoreOptions value)?  $default,){
final _that = this;
switch (_that) {
case _CoreOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'test-url')  String testUrl, @JsonKey(name: 'skip-cert-verify')  bool skipCertVerify, @JsonKey(name: 'delay-test-timeout')  int delayTestTimeout, @JsonKey(name: 'mitm-capture')  bool mitmCapture)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoreOptions() when $default != null:
return $default(_that.testUrl,_that.skipCertVerify,_that.delayTestTimeout,_that.mitmCapture);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'test-url')  String testUrl, @JsonKey(name: 'skip-cert-verify')  bool skipCertVerify, @JsonKey(name: 'delay-test-timeout')  int delayTestTimeout, @JsonKey(name: 'mitm-capture')  bool mitmCapture)  $default,) {final _that = this;
switch (_that) {
case _CoreOptions():
return $default(_that.testUrl,_that.skipCertVerify,_that.delayTestTimeout,_that.mitmCapture);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'test-url')  String testUrl, @JsonKey(name: 'skip-cert-verify')  bool skipCertVerify, @JsonKey(name: 'delay-test-timeout')  int delayTestTimeout, @JsonKey(name: 'mitm-capture')  bool mitmCapture)?  $default,) {final _that = this;
switch (_that) {
case _CoreOptions() when $default != null:
return $default(_that.testUrl,_that.skipCertVerify,_that.delayTestTimeout,_that.mitmCapture);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoreOptions implements CoreOptions {
  const _CoreOptions({@JsonKey(name: 'test-url') required this.testUrl, @JsonKey(name: 'skip-cert-verify') this.skipCertVerify = false, @JsonKey(name: 'delay-test-timeout') this.delayTestTimeout = defaultDelayTestTimeout, @JsonKey(name: 'mitm-capture') this.mitmCapture = false});
  factory _CoreOptions.fromJson(Map<String, dynamic> json) => _$CoreOptionsFromJson(json);

@override@JsonKey(name: 'test-url') final  String testUrl;
@override@JsonKey(name: 'skip-cert-verify') final  bool skipCertVerify;
@override@JsonKey(name: 'delay-test-timeout') final  int delayTestTimeout;
@override@JsonKey(name: 'mitm-capture') final  bool mitmCapture;

/// Create a copy of CoreOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoreOptionsCopyWith<_CoreOptions> get copyWith => __$CoreOptionsCopyWithImpl<_CoreOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoreOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoreOptions&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.skipCertVerify, skipCertVerify) || other.skipCertVerify == skipCertVerify)&&(identical(other.delayTestTimeout, delayTestTimeout) || other.delayTestTimeout == delayTestTimeout)&&(identical(other.mitmCapture, mitmCapture) || other.mitmCapture == mitmCapture));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,testUrl,skipCertVerify,delayTestTimeout,mitmCapture);
}

@override
String toString() {
    return 'CoreOptions(testUrl: $testUrl, skipCertVerify: $skipCertVerify, delayTestTimeout: $delayTestTimeout, mitmCapture: $mitmCapture)';
}


}

/// @nodoc
abstract mixin class _$CoreOptionsCopyWith<$Res> implements $CoreOptionsCopyWith<$Res> {
  factory _$CoreOptionsCopyWith(_CoreOptions value, $Res Function(_CoreOptions) _then) = __$CoreOptionsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'test-url') String testUrl,@JsonKey(name: 'skip-cert-verify') bool skipCertVerify,@JsonKey(name: 'delay-test-timeout') int delayTestTimeout,@JsonKey(name: 'mitm-capture') bool mitmCapture
});




}
/// @nodoc
class __$CoreOptionsCopyWithImpl<$Res>
    implements _$CoreOptionsCopyWith<$Res> {
  __$CoreOptionsCopyWithImpl(this._self, this._then);

  final _CoreOptions _self;
  final $Res Function(_CoreOptions) _then;

/// Create a copy of CoreOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testUrl = null,Object? skipCertVerify = null,Object? delayTestTimeout = null,Object? mitmCapture = null,}) {
  return _then(_CoreOptions(
testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,skipCertVerify: null == skipCertVerify ? _self.skipCertVerify : skipCertVerify // ignore: cast_nullable_to_non_nullable
as bool,delayTestTimeout: null == delayTestTimeout ? _self.delayTestTimeout : delayTestTimeout // ignore: cast_nullable_to_non_nullable
as int,mitmCapture: null == mitmCapture ? _self.mitmCapture : mitmCapture // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SetupBase {

 String get path; String get overlay;
/// Create a copy of SetupBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupBaseCopyWith<SetupBase> get copyWith => _$SetupBaseCopyWithImpl<SetupBase>(this as SetupBase, _$identity);

  /// Serializes this SetupBase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SetupBase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupBase&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.overlay, _this.overlay) || other.overlay == _this.overlay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupBase;
  return Object.hash(runtimeType,_this.path,_this.overlay);
}

@override
String toString() {
  final _this = this as SetupBase;
  return 'SetupBase(path: ${_this.path}, overlay: ${_this.overlay})';
}


}

/// @nodoc
abstract mixin class $SetupBaseCopyWith<$Res>  {
  factory $SetupBaseCopyWith(SetupBase value, $Res Function(SetupBase) _then) = _$SetupBaseCopyWithImpl;
@useResult
$Res call({
 String path, String overlay
});




}
/// @nodoc
class _$SetupBaseCopyWithImpl<$Res>
    implements $SetupBaseCopyWith<$Res> {
  _$SetupBaseCopyWithImpl(this._self, this._then);

  final SetupBase _self;
  final $Res Function(SetupBase) _then;

/// Create a copy of SetupBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? overlay = null,}) {
  return _then(SetupBase(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,overlay: null == overlay ? _self.overlay : overlay // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SetupBase].
extension SetupBasePatterns on SetupBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupBase value)  $default,){
final _that = this;
switch (_that) {
case _SetupBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupBase value)?  $default,){
final _that = this;
switch (_that) {
case _SetupBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String overlay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupBase() when $default != null:
return $default(_that.path,_that.overlay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String overlay)  $default,) {final _that = this;
switch (_that) {
case _SetupBase():
return $default(_that.path,_that.overlay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String overlay)?  $default,) {final _that = this;
switch (_that) {
case _SetupBase() when $default != null:
return $default(_that.path,_that.overlay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupBase implements SetupBase {
  const _SetupBase({required this.path, required this.overlay});
  factory _SetupBase.fromJson(Map<String, dynamic> json) => _$SetupBaseFromJson(json);

@override final  String path;
@override final  String overlay;

/// Create a copy of SetupBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupBaseCopyWith<_SetupBase> get copyWith => __$SetupBaseCopyWithImpl<_SetupBase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SetupBaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupBase&&(identical(other.path, path) || other.path == path)&&(identical(other.overlay, overlay) || other.overlay == overlay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,path,overlay);
}

@override
String toString() {
    return 'SetupBase(path: $path, overlay: $overlay)';
}


}

/// @nodoc
abstract mixin class _$SetupBaseCopyWith<$Res> implements $SetupBaseCopyWith<$Res> {
  factory _$SetupBaseCopyWith(_SetupBase value, $Res Function(_SetupBase) _then) = __$SetupBaseCopyWithImpl;
@override @useResult
$Res call({
 String path, String overlay
});




}
/// @nodoc
class __$SetupBaseCopyWithImpl<$Res>
    implements _$SetupBaseCopyWith<$Res> {
  __$SetupBaseCopyWithImpl(this._self, this._then);

  final _SetupBase _self;
  final $Res Function(_SetupBase) _then;

/// Create a copy of SetupBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? overlay = null,}) {
  return _then(_SetupBase(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,overlay: null == overlay ? _self.overlay : overlay // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProfileBase {

 Map<String, dynamic> get config; String get digest;@JsonKey(name: 'match-rules') List<String> get matchRules; int get proxies;@JsonKey(name: 'proxy-groups') int get proxyGroups; int get rules;
/// Create a copy of ProfileBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileBaseCopyWith<ProfileBase> get copyWith => _$ProfileBaseCopyWithImpl<ProfileBase>(this as ProfileBase, _$identity);

  /// Serializes this ProfileBase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileBase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileBase&&const DeepCollectionEquality().equals(other.config, _this.config)&&(identical(other.digest, _this.digest) || other.digest == _this.digest)&&const DeepCollectionEquality().equals(other.matchRules, _this.matchRules)&&(identical(other.proxies, _this.proxies) || other.proxies == _this.proxies)&&(identical(other.proxyGroups, _this.proxyGroups) || other.proxyGroups == _this.proxyGroups)&&(identical(other.rules, _this.rules) || other.rules == _this.rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileBase;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.config),_this.digest,const DeepCollectionEquality().hash(_this.matchRules),_this.proxies,_this.proxyGroups,_this.rules);
}

@override
String toString() {
  final _this = this as ProfileBase;
  return 'ProfileBase(config: ${_this.config}, digest: ${_this.digest}, matchRules: ${_this.matchRules}, proxies: ${_this.proxies}, proxyGroups: ${_this.proxyGroups}, rules: ${_this.rules})';
}


}

/// @nodoc
abstract mixin class $ProfileBaseCopyWith<$Res>  {
  factory $ProfileBaseCopyWith(ProfileBase value, $Res Function(ProfileBase) _then) = _$ProfileBaseCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> config, String digest,@JsonKey(name: 'match-rules') List<String> matchRules, int proxies,@JsonKey(name: 'proxy-groups') int proxyGroups, int rules
});




}
/// @nodoc
class _$ProfileBaseCopyWithImpl<$Res>
    implements $ProfileBaseCopyWith<$Res> {
  _$ProfileBaseCopyWithImpl(this._self, this._then);

  final ProfileBase _self;
  final $Res Function(ProfileBase) _then;

/// Create a copy of ProfileBase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? config = null,Object? digest = null,Object? matchRules = null,Object? proxies = null,Object? proxyGroups = null,Object? rules = null,}) {
  return _then(ProfileBase(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,digest: null == digest ? _self.digest : digest // ignore: cast_nullable_to_non_nullable
as String,matchRules: null == matchRules ? _self.matchRules : matchRules // ignore: cast_nullable_to_non_nullable
as List<String>,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as int,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileBase].
extension ProfileBasePatterns on ProfileBase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileBase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileBase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileBase value)  $default,){
final _that = this;
switch (_that) {
case _ProfileBase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileBase value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileBase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> config,  String digest, @JsonKey(name: 'match-rules')  List<String> matchRules,  int proxies, @JsonKey(name: 'proxy-groups')  int proxyGroups,  int rules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileBase() when $default != null:
return $default(_that.config,_that.digest,_that.matchRules,_that.proxies,_that.proxyGroups,_that.rules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> config,  String digest, @JsonKey(name: 'match-rules')  List<String> matchRules,  int proxies, @JsonKey(name: 'proxy-groups')  int proxyGroups,  int rules)  $default,) {final _that = this;
switch (_that) {
case _ProfileBase():
return $default(_that.config,_that.digest,_that.matchRules,_that.proxies,_that.proxyGroups,_that.rules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> config,  String digest, @JsonKey(name: 'match-rules')  List<String> matchRules,  int proxies, @JsonKey(name: 'proxy-groups')  int proxyGroups,  int rules)?  $default,) {final _that = this;
switch (_that) {
case _ProfileBase() when $default != null:
return $default(_that.config,_that.digest,_that.matchRules,_that.proxies,_that.proxyGroups,_that.rules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileBase implements ProfileBase {
  const _ProfileBase({required  Map<String, dynamic> config, required this.digest, @JsonKey(name: 'match-rules')  List<String> matchRules = const [], this.proxies = 0, @JsonKey(name: 'proxy-groups') this.proxyGroups = 0, this.rules = 0}): _config = config,_matchRules = matchRules;
  factory _ProfileBase.fromJson(Map<String, dynamic> json) => _$ProfileBaseFromJson(json);

 final  Map<String, dynamic> _config;
@override Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

@override final  String digest;
 final  List<String> _matchRules;
@override@JsonKey(name: 'match-rules') List<String> get matchRules {
  if (_matchRules is EqualUnmodifiableListView) return _matchRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matchRules);
}

@override@JsonKey() final  int proxies;
@override@JsonKey(name: 'proxy-groups') final  int proxyGroups;
@override@JsonKey() final  int rules;

/// Create a copy of ProfileBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileBaseCopyWith<_ProfileBase> get copyWith => __$ProfileBaseCopyWithImpl<_ProfileBase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileBaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileBase&&const DeepCollectionEquality().equals(other.config, _config)&&(identical(other.digest, digest) || other.digest == digest)&&const DeepCollectionEquality().equals(other.matchRules, _matchRules)&&(identical(other.proxies, proxies) || other.proxies == proxies)&&(identical(other.proxyGroups, proxyGroups) || other.proxyGroups == proxyGroups)&&(identical(other.rules, rules) || other.rules == rules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_config),digest,const DeepCollectionEquality().hash(_matchRules),proxies,proxyGroups,rules);
}

@override
String toString() {
    return 'ProfileBase(config: $config, digest: $digest, matchRules: $matchRules, proxies: $proxies, proxyGroups: $proxyGroups, rules: $rules)';
}


}

/// @nodoc
abstract mixin class _$ProfileBaseCopyWith<$Res> implements $ProfileBaseCopyWith<$Res> {
  factory _$ProfileBaseCopyWith(_ProfileBase value, $Res Function(_ProfileBase) _then) = __$ProfileBaseCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> config, String digest,@JsonKey(name: 'match-rules') List<String> matchRules, int proxies,@JsonKey(name: 'proxy-groups') int proxyGroups, int rules
});




}
/// @nodoc
class __$ProfileBaseCopyWithImpl<$Res>
    implements _$ProfileBaseCopyWith<$Res> {
  __$ProfileBaseCopyWithImpl(this._self, this._then);

  final _ProfileBase _self;
  final $Res Function(_ProfileBase) _then;

/// Create a copy of ProfileBase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? config = null,Object? digest = null,Object? matchRules = null,Object? proxies = null,Object? proxyGroups = null,Object? rules = null,}) {
  return _then(_ProfileBase(
config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,digest: null == digest ? _self.digest : digest // ignore: cast_nullable_to_non_nullable
as String,matchRules: null == matchRules ? _self._matchRules : matchRules // ignore: cast_nullable_to_non_nullable
as List<String>,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as int,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as int,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UpdateParams {

@JsonKey(toJson: _tunCoreJson) Tun get tun;@JsonKey(name: 'mixed-port') int get mixedPort;@JsonKey(name: 'allow-lan') bool get allowLan;@JsonKey(name: 'find-process-mode') FindProcessMode get findProcessMode; Mode get mode;@JsonKey(name: 'log-level') LogLevel get logLevel; bool? get ipv6;@JsonKey(name: 'tcp-concurrent') bool? get tcpConcurrent;@JsonKey(name: 'external-controller') ExternalControllerStatus get externalController; String get secret;@JsonKey(name: 'unified-delay') bool? get unifiedDelay; List<String> get authentication;@JsonKey(name: 'geo-auto-update') bool get geoAutoUpdate;@JsonKey(name: 'geo-update-interval') int get geoUpdateInterval;@JsonKey(name: 'geox-url') Map<String, String> get geoXUrl; CoreOptions get options;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateParams&&(identical(other.tun, _this.tun) || other.tun == _this.tun)&&(identical(other.mixedPort, _this.mixedPort) || other.mixedPort == _this.mixedPort)&&(identical(other.allowLan, _this.allowLan) || other.allowLan == _this.allowLan)&&(identical(other.findProcessMode, _this.findProcessMode) || other.findProcessMode == _this.findProcessMode)&&(identical(other.mode, _this.mode) || other.mode == _this.mode)&&(identical(other.logLevel, _this.logLevel) || other.logLevel == _this.logLevel)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.tcpConcurrent, _this.tcpConcurrent) || other.tcpConcurrent == _this.tcpConcurrent)&&(identical(other.externalController, _this.externalController) || other.externalController == _this.externalController)&&(identical(other.secret, _this.secret) || other.secret == _this.secret)&&(identical(other.unifiedDelay, _this.unifiedDelay) || other.unifiedDelay == _this.unifiedDelay)&&const DeepCollectionEquality().equals(other.authentication, _this.authentication)&&(identical(other.geoAutoUpdate, _this.geoAutoUpdate) || other.geoAutoUpdate == _this.geoAutoUpdate)&&(identical(other.geoUpdateInterval, _this.geoUpdateInterval) || other.geoUpdateInterval == _this.geoUpdateInterval)&&const DeepCollectionEquality().equals(other.geoXUrl, _this.geoXUrl)&&(identical(other.options, _this.options) || other.options == _this.options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpdateParams;
  return Object.hash(runtimeType,_this.tun,_this.mixedPort,_this.allowLan,_this.findProcessMode,_this.mode,_this.logLevel,_this.ipv6,_this.tcpConcurrent,_this.externalController,_this.secret,_this.unifiedDelay,const DeepCollectionEquality().hash(_this.authentication),_this.geoAutoUpdate,_this.geoUpdateInterval,const DeepCollectionEquality().hash(_this.geoXUrl),_this.options);
}

@override
String toString() {
  final _this = this as UpdateParams;
  return 'UpdateParams(tun: ${_this.tun}, mixedPort: ${_this.mixedPort}, allowLan: ${_this.allowLan}, findProcessMode: ${_this.findProcessMode}, mode: ${_this.mode}, logLevel: ${_this.logLevel}, ipv6: ${_this.ipv6}, tcpConcurrent: ${_this.tcpConcurrent}, externalController: ${_this.externalController}, secret: ${_this.secret}, unifiedDelay: ${_this.unifiedDelay}, authentication: ${_this.authentication}, geoAutoUpdate: ${_this.geoAutoUpdate}, geoUpdateInterval: ${_this.geoUpdateInterval}, geoXUrl: ${_this.geoXUrl}, options: ${_this.options})';
}


}

/// @nodoc
abstract mixin class $UpdateParamsCopyWith<$Res>  {
  factory $UpdateParamsCopyWith(UpdateParams value, $Res Function(UpdateParams) _then) = _$UpdateParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _tunCoreJson) Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool? ipv6,@JsonKey(name: 'tcp-concurrent') bool? tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, String secret,@JsonKey(name: 'unified-delay') bool? unifiedDelay, List<String> authentication,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval,@JsonKey(name: 'geox-url') Map<String, String> geoXUrl, CoreOptions options
});


$TunCopyWith<$Res> get tun;$CoreOptionsCopyWith<$Res> get options;

}
/// @nodoc
class _$UpdateParamsCopyWithImpl<$Res>
    implements $UpdateParamsCopyWith<$Res> {
  _$UpdateParamsCopyWithImpl(this._self, this._then);

  final UpdateParams _self;
  final $Res Function(UpdateParams) _then;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = freezed,Object? tcpConcurrent = freezed,Object? externalController = null,Object? secret = null,Object? unifiedDelay = freezed,Object? authentication = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,Object? geoXUrl = null,Object? options = null,}) {
  return _then(UpdateParams(
tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: freezed == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool?,tcpConcurrent: freezed == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,unifiedDelay: freezed == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool?,authentication: null == authentication ? _self.authentication : authentication // ignore: cast_nullable_to_non_nullable
as List<String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,geoXUrl: null == geoXUrl ? _self.geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as Map<String, String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as CoreOptions,
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
}/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreOptionsCopyWith<$Res> get options {
  
  return $CoreOptionsCopyWith<$Res>(_self.options, (value) {
    return _then(_self.copyWith(options: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(toJson: _tunCoreJson)  Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool? ipv6, @JsonKey(name: 'tcp-concurrent')  bool? tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String secret, @JsonKey(name: 'unified-delay')  bool? unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval, @JsonKey(name: 'geox-url')  Map<String, String> geoXUrl,  CoreOptions options)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.secret,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval,_that.geoXUrl,_that.options);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(toJson: _tunCoreJson)  Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool? ipv6, @JsonKey(name: 'tcp-concurrent')  bool? tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String secret, @JsonKey(name: 'unified-delay')  bool? unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval, @JsonKey(name: 'geox-url')  Map<String, String> geoXUrl,  CoreOptions options)  $default,) {final _that = this;
switch (_that) {
case _UpdateParams():
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.secret,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval,_that.geoXUrl,_that.options);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(toJson: _tunCoreJson)  Tun tun, @JsonKey(name: 'mixed-port')  int mixedPort, @JsonKey(name: 'allow-lan')  bool allowLan, @JsonKey(name: 'find-process-mode')  FindProcessMode findProcessMode,  Mode mode, @JsonKey(name: 'log-level')  LogLevel logLevel,  bool? ipv6, @JsonKey(name: 'tcp-concurrent')  bool? tcpConcurrent, @JsonKey(name: 'external-controller')  ExternalControllerStatus externalController,  String secret, @JsonKey(name: 'unified-delay')  bool? unifiedDelay,  List<String> authentication, @JsonKey(name: 'geo-auto-update')  bool geoAutoUpdate, @JsonKey(name: 'geo-update-interval')  int geoUpdateInterval, @JsonKey(name: 'geox-url')  Map<String, String> geoXUrl,  CoreOptions options)?  $default,) {final _that = this;
switch (_that) {
case _UpdateParams() when $default != null:
return $default(_that.tun,_that.mixedPort,_that.allowLan,_that.findProcessMode,_that.mode,_that.logLevel,_that.ipv6,_that.tcpConcurrent,_that.externalController,_that.secret,_that.unifiedDelay,_that.authentication,_that.geoAutoUpdate,_that.geoUpdateInterval,_that.geoXUrl,_that.options);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateParams implements UpdateParams {
  const _UpdateParams({@JsonKey(toJson: _tunCoreJson) required this.tun, @JsonKey(name: 'mixed-port') required this.mixedPort, @JsonKey(name: 'allow-lan') required this.allowLan, @JsonKey(name: 'find-process-mode') required this.findProcessMode, required this.mode, @JsonKey(name: 'log-level') required this.logLevel, this.ipv6, @JsonKey(name: 'tcp-concurrent') this.tcpConcurrent, @JsonKey(name: 'external-controller') required this.externalController, this.secret = '', @JsonKey(name: 'unified-delay') this.unifiedDelay,  List<String> authentication = const [], @JsonKey(name: 'geo-auto-update') this.geoAutoUpdate = false, @JsonKey(name: 'geo-update-interval') this.geoUpdateInterval = 24, @JsonKey(name: 'geox-url')  Map<String, String> geoXUrl = const {}, required this.options}): _authentication = authentication,_geoXUrl = geoXUrl;
  factory _UpdateParams.fromJson(Map<String, dynamic> json) => _$UpdateParamsFromJson(json);

@override@JsonKey(toJson: _tunCoreJson) final  Tun tun;
@override@JsonKey(name: 'mixed-port') final  int mixedPort;
@override@JsonKey(name: 'allow-lan') final  bool allowLan;
@override@JsonKey(name: 'find-process-mode') final  FindProcessMode findProcessMode;
@override final  Mode mode;
@override@JsonKey(name: 'log-level') final  LogLevel logLevel;
@override final  bool? ipv6;
@override@JsonKey(name: 'tcp-concurrent') final  bool? tcpConcurrent;
@override@JsonKey(name: 'external-controller') final  ExternalControllerStatus externalController;
@override@JsonKey() final  String secret;
@override@JsonKey(name: 'unified-delay') final  bool? unifiedDelay;
 final  List<String> _authentication;
@override@JsonKey() List<String> get authentication {
  if (_authentication is EqualUnmodifiableListView) return _authentication;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_authentication);
}

@override@JsonKey(name: 'geo-auto-update') final  bool geoAutoUpdate;
@override@JsonKey(name: 'geo-update-interval') final  int geoUpdateInterval;
 final  Map<String, String> _geoXUrl;
@override@JsonKey(name: 'geox-url') Map<String, String> get geoXUrl {
  if (_geoXUrl is EqualUnmodifiableMapView) return _geoXUrl;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_geoXUrl);
}

@override final  CoreOptions options;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateParams&&(identical(other.tun, tun) || other.tun == tun)&&(identical(other.mixedPort, mixedPort) || other.mixedPort == mixedPort)&&(identical(other.allowLan, allowLan) || other.allowLan == allowLan)&&(identical(other.findProcessMode, findProcessMode) || other.findProcessMode == findProcessMode)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.tcpConcurrent, tcpConcurrent) || other.tcpConcurrent == tcpConcurrent)&&(identical(other.externalController, externalController) || other.externalController == externalController)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.unifiedDelay, unifiedDelay) || other.unifiedDelay == unifiedDelay)&&const DeepCollectionEquality().equals(other.authentication, _authentication)&&(identical(other.geoAutoUpdate, geoAutoUpdate) || other.geoAutoUpdate == geoAutoUpdate)&&(identical(other.geoUpdateInterval, geoUpdateInterval) || other.geoUpdateInterval == geoUpdateInterval)&&const DeepCollectionEquality().equals(other.geoXUrl, _geoXUrl)&&(identical(other.options, options) || other.options == options));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tun,mixedPort,allowLan,findProcessMode,mode,logLevel,ipv6,tcpConcurrent,externalController,secret,unifiedDelay,const DeepCollectionEquality().hash(_authentication),geoAutoUpdate,geoUpdateInterval,const DeepCollectionEquality().hash(_geoXUrl),options);
}

@override
String toString() {
    return 'UpdateParams(tun: $tun, mixedPort: $mixedPort, allowLan: $allowLan, findProcessMode: $findProcessMode, mode: $mode, logLevel: $logLevel, ipv6: $ipv6, tcpConcurrent: $tcpConcurrent, externalController: $externalController, secret: $secret, unifiedDelay: $unifiedDelay, authentication: $authentication, geoAutoUpdate: $geoAutoUpdate, geoUpdateInterval: $geoUpdateInterval, geoXUrl: $geoXUrl, options: $options)';
}


}

/// @nodoc
abstract mixin class _$UpdateParamsCopyWith<$Res> implements $UpdateParamsCopyWith<$Res> {
  factory _$UpdateParamsCopyWith(_UpdateParams value, $Res Function(_UpdateParams) _then) = __$UpdateParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(toJson: _tunCoreJson) Tun tun,@JsonKey(name: 'mixed-port') int mixedPort,@JsonKey(name: 'allow-lan') bool allowLan,@JsonKey(name: 'find-process-mode') FindProcessMode findProcessMode, Mode mode,@JsonKey(name: 'log-level') LogLevel logLevel, bool? ipv6,@JsonKey(name: 'tcp-concurrent') bool? tcpConcurrent,@JsonKey(name: 'external-controller') ExternalControllerStatus externalController, String secret,@JsonKey(name: 'unified-delay') bool? unifiedDelay, List<String> authentication,@JsonKey(name: 'geo-auto-update') bool geoAutoUpdate,@JsonKey(name: 'geo-update-interval') int geoUpdateInterval,@JsonKey(name: 'geox-url') Map<String, String> geoXUrl, CoreOptions options
});


@override $TunCopyWith<$Res> get tun;@override $CoreOptionsCopyWith<$Res> get options;

}
/// @nodoc
class __$UpdateParamsCopyWithImpl<$Res>
    implements _$UpdateParamsCopyWith<$Res> {
  __$UpdateParamsCopyWithImpl(this._self, this._then);

  final _UpdateParams _self;
  final $Res Function(_UpdateParams) _then;

/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tun = null,Object? mixedPort = null,Object? allowLan = null,Object? findProcessMode = null,Object? mode = null,Object? logLevel = null,Object? ipv6 = freezed,Object? tcpConcurrent = freezed,Object? externalController = null,Object? secret = null,Object? unifiedDelay = freezed,Object? authentication = null,Object? geoAutoUpdate = null,Object? geoUpdateInterval = null,Object? geoXUrl = null,Object? options = null,}) {
  return _then(_UpdateParams(
tun: null == tun ? _self.tun : tun // ignore: cast_nullable_to_non_nullable
as Tun,mixedPort: null == mixedPort ? _self.mixedPort : mixedPort // ignore: cast_nullable_to_non_nullable
as int,allowLan: null == allowLan ? _self.allowLan : allowLan // ignore: cast_nullable_to_non_nullable
as bool,findProcessMode: null == findProcessMode ? _self.findProcessMode : findProcessMode // ignore: cast_nullable_to_non_nullable
as FindProcessMode,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,ipv6: freezed == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool?,tcpConcurrent: freezed == tcpConcurrent ? _self.tcpConcurrent : tcpConcurrent // ignore: cast_nullable_to_non_nullable
as bool?,externalController: null == externalController ? _self.externalController : externalController // ignore: cast_nullable_to_non_nullable
as ExternalControllerStatus,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,unifiedDelay: freezed == unifiedDelay ? _self.unifiedDelay : unifiedDelay // ignore: cast_nullable_to_non_nullable
as bool?,authentication: null == authentication ? _self._authentication : authentication // ignore: cast_nullable_to_non_nullable
as List<String>,geoAutoUpdate: null == geoAutoUpdate ? _self.geoAutoUpdate : geoAutoUpdate // ignore: cast_nullable_to_non_nullable
as bool,geoUpdateInterval: null == geoUpdateInterval ? _self.geoUpdateInterval : geoUpdateInterval // ignore: cast_nullable_to_non_nullable
as int,geoXUrl: null == geoXUrl ? _self._geoXUrl : geoXUrl // ignore: cast_nullable_to_non_nullable
as Map<String, String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as CoreOptions,
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
}/// Create a copy of UpdateParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoreOptionsCopyWith<$Res> get options {
  
  return $CoreOptionsCopyWith<$Res>(_self.options, (value) {
    return _then(_self.copyWith(options: value));
  });
}
}


/// @nodoc
mixin _$MitmCertificate {

 String get pem; String get fingerprint; String get subject;@JsonKey(name: 'not-before') DateTime get notBefore;@JsonKey(name: 'not-after') DateTime get notAfter;
/// Create a copy of MitmCertificate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmCertificateCopyWith<MitmCertificate> get copyWith => _$MitmCertificateCopyWithImpl<MitmCertificate>(this as MitmCertificate, _$identity);

  /// Serializes this MitmCertificate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmCertificate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmCertificate&&(identical(other.pem, _this.pem) || other.pem == _this.pem)&&(identical(other.fingerprint, _this.fingerprint) || other.fingerprint == _this.fingerprint)&&(identical(other.subject, _this.subject) || other.subject == _this.subject)&&(identical(other.notBefore, _this.notBefore) || other.notBefore == _this.notBefore)&&(identical(other.notAfter, _this.notAfter) || other.notAfter == _this.notAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmCertificate;
  return Object.hash(runtimeType,_this.pem,_this.fingerprint,_this.subject,_this.notBefore,_this.notAfter);
}

@override
String toString() {
  final _this = this as MitmCertificate;
  return 'MitmCertificate(pem: ${_this.pem}, fingerprint: ${_this.fingerprint}, subject: ${_this.subject}, notBefore: ${_this.notBefore}, notAfter: ${_this.notAfter})';
}


}

/// @nodoc
abstract mixin class $MitmCertificateCopyWith<$Res>  {
  factory $MitmCertificateCopyWith(MitmCertificate value, $Res Function(MitmCertificate) _then) = _$MitmCertificateCopyWithImpl;
@useResult
$Res call({
 String pem, String fingerprint, String subject,@JsonKey(name: 'not-before') DateTime notBefore,@JsonKey(name: 'not-after') DateTime notAfter
});




}
/// @nodoc
class _$MitmCertificateCopyWithImpl<$Res>
    implements $MitmCertificateCopyWith<$Res> {
  _$MitmCertificateCopyWithImpl(this._self, this._then);

  final MitmCertificate _self;
  final $Res Function(MitmCertificate) _then;

/// Create a copy of MitmCertificate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pem = null,Object? fingerprint = null,Object? subject = null,Object? notBefore = null,Object? notAfter = null,}) {
  return _then(MitmCertificate(
pem: null == pem ? _self.pem : pem // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,notBefore: null == notBefore ? _self.notBefore : notBefore // ignore: cast_nullable_to_non_nullable
as DateTime,notAfter: null == notAfter ? _self.notAfter : notAfter // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmCertificate].
extension MitmCertificatePatterns on MitmCertificate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmCertificate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmCertificate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmCertificate value)  $default,){
final _that = this;
switch (_that) {
case _MitmCertificate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmCertificate value)?  $default,){
final _that = this;
switch (_that) {
case _MitmCertificate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pem,  String fingerprint,  String subject, @JsonKey(name: 'not-before')  DateTime notBefore, @JsonKey(name: 'not-after')  DateTime notAfter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmCertificate() when $default != null:
return $default(_that.pem,_that.fingerprint,_that.subject,_that.notBefore,_that.notAfter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pem,  String fingerprint,  String subject, @JsonKey(name: 'not-before')  DateTime notBefore, @JsonKey(name: 'not-after')  DateTime notAfter)  $default,) {final _that = this;
switch (_that) {
case _MitmCertificate():
return $default(_that.pem,_that.fingerprint,_that.subject,_that.notBefore,_that.notAfter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pem,  String fingerprint,  String subject, @JsonKey(name: 'not-before')  DateTime notBefore, @JsonKey(name: 'not-after')  DateTime notAfter)?  $default,) {final _that = this;
switch (_that) {
case _MitmCertificate() when $default != null:
return $default(_that.pem,_that.fingerprint,_that.subject,_that.notBefore,_that.notAfter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmCertificate implements MitmCertificate {
  const _MitmCertificate({required this.pem, required this.fingerprint, required this.subject, @JsonKey(name: 'not-before') required this.notBefore, @JsonKey(name: 'not-after') required this.notAfter});
  factory _MitmCertificate.fromJson(Map<String, dynamic> json) => _$MitmCertificateFromJson(json);

@override final  String pem;
@override final  String fingerprint;
@override final  String subject;
@override@JsonKey(name: 'not-before') final  DateTime notBefore;
@override@JsonKey(name: 'not-after') final  DateTime notAfter;

/// Create a copy of MitmCertificate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmCertificateCopyWith<_MitmCertificate> get copyWith => __$MitmCertificateCopyWithImpl<_MitmCertificate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmCertificateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmCertificate&&(identical(other.pem, pem) || other.pem == pem)&&(identical(other.fingerprint, fingerprint) || other.fingerprint == fingerprint)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.notBefore, notBefore) || other.notBefore == notBefore)&&(identical(other.notAfter, notAfter) || other.notAfter == notAfter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pem,fingerprint,subject,notBefore,notAfter);
}

@override
String toString() {
    return 'MitmCertificate(pem: $pem, fingerprint: $fingerprint, subject: $subject, notBefore: $notBefore, notAfter: $notAfter)';
}


}

/// @nodoc
abstract mixin class _$MitmCertificateCopyWith<$Res> implements $MitmCertificateCopyWith<$Res> {
  factory _$MitmCertificateCopyWith(_MitmCertificate value, $Res Function(_MitmCertificate) _then) = __$MitmCertificateCopyWithImpl;
@override @useResult
$Res call({
 String pem, String fingerprint, String subject,@JsonKey(name: 'not-before') DateTime notBefore,@JsonKey(name: 'not-after') DateTime notAfter
});




}
/// @nodoc
class __$MitmCertificateCopyWithImpl<$Res>
    implements _$MitmCertificateCopyWith<$Res> {
  __$MitmCertificateCopyWithImpl(this._self, this._then);

  final _MitmCertificate _self;
  final $Res Function(_MitmCertificate) _then;

/// Create a copy of MitmCertificate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pem = null,Object? fingerprint = null,Object? subject = null,Object? notBefore = null,Object? notAfter = null,}) {
  return _then(_MitmCertificate(
pem: null == pem ? _self.pem : pem // ignore: cast_nullable_to_non_nullable
as String,fingerprint: null == fingerprint ? _self.fingerprint : fingerprint // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,notBefore: null == notBefore ? _self.notBefore : notBefore // ignore: cast_nullable_to_non_nullable
as DateTime,notAfter: null == notAfter ? _self.notAfter : notAfter // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MitmScriptOutput {

 List<String> get logs; String get result; String get error;
/// Create a copy of MitmScriptOutput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmScriptOutputCopyWith<MitmScriptOutput> get copyWith => _$MitmScriptOutputCopyWithImpl<MitmScriptOutput>(this as MitmScriptOutput, _$identity);

  /// Serializes this MitmScriptOutput to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmScriptOutput;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmScriptOutput&&const DeepCollectionEquality().equals(other.logs, _this.logs)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmScriptOutput;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.logs),_this.result,_this.error);
}

@override
String toString() {
  final _this = this as MitmScriptOutput;
  return 'MitmScriptOutput(logs: ${_this.logs}, result: ${_this.result}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $MitmScriptOutputCopyWith<$Res>  {
  factory $MitmScriptOutputCopyWith(MitmScriptOutput value, $Res Function(MitmScriptOutput) _then) = _$MitmScriptOutputCopyWithImpl;
@useResult
$Res call({
 List<String> logs, String result, String error
});




}
/// @nodoc
class _$MitmScriptOutputCopyWithImpl<$Res>
    implements $MitmScriptOutputCopyWith<$Res> {
  _$MitmScriptOutputCopyWithImpl(this._self, this._then);

  final MitmScriptOutput _self;
  final $Res Function(MitmScriptOutput) _then;

/// Create a copy of MitmScriptOutput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logs = null,Object? result = null,Object? error = null,}) {
  return _then(MitmScriptOutput(
logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<String>,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmScriptOutput].
extension MitmScriptOutputPatterns on MitmScriptOutput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmScriptOutput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmScriptOutput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmScriptOutput value)  $default,){
final _that = this;
switch (_that) {
case _MitmScriptOutput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmScriptOutput value)?  $default,){
final _that = this;
switch (_that) {
case _MitmScriptOutput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> logs,  String result,  String error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmScriptOutput() when $default != null:
return $default(_that.logs,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> logs,  String result,  String error)  $default,) {final _that = this;
switch (_that) {
case _MitmScriptOutput():
return $default(_that.logs,_that.result,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> logs,  String result,  String error)?  $default,) {final _that = this;
switch (_that) {
case _MitmScriptOutput() when $default != null:
return $default(_that.logs,_that.result,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmScriptOutput implements MitmScriptOutput {
  const _MitmScriptOutput({ List<String> logs = const [], this.result = '', this.error = ''}): _logs = logs;
  factory _MitmScriptOutput.fromJson(Map<String, dynamic> json) => _$MitmScriptOutputFromJson(json);

 final  List<String> _logs;
@override@JsonKey() List<String> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

@override@JsonKey() final  String result;
@override@JsonKey() final  String error;

/// Create a copy of MitmScriptOutput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmScriptOutputCopyWith<_MitmScriptOutput> get copyWith => __$MitmScriptOutputCopyWithImpl<_MitmScriptOutput>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmScriptOutputToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmScriptOutput&&const DeepCollectionEquality().equals(other.logs, _logs)&&(identical(other.result, result) || other.result == result)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_logs),result,error);
}

@override
String toString() {
    return 'MitmScriptOutput(logs: $logs, result: $result, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MitmScriptOutputCopyWith<$Res> implements $MitmScriptOutputCopyWith<$Res> {
  factory _$MitmScriptOutputCopyWith(_MitmScriptOutput value, $Res Function(_MitmScriptOutput) _then) = __$MitmScriptOutputCopyWithImpl;
@override @useResult
$Res call({
 List<String> logs, String result, String error
});




}
/// @nodoc
class __$MitmScriptOutputCopyWithImpl<$Res>
    implements _$MitmScriptOutputCopyWith<$Res> {
  __$MitmScriptOutputCopyWithImpl(this._self, this._then);

  final _MitmScriptOutput _self;
  final $Res Function(_MitmScriptOutput) _then;

/// Create a copy of MitmScriptOutput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logs = null,Object? result = null,Object? error = null,}) {
  return _then(_MitmScriptOutput(
logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<String>,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MitmExchangeSummary {

 int get id; DateTime get start; bool get pending; int get duration; String get method; String get url; int get status;@JsonKey(name: 'request-size') int get requestSize;@JsonKey(name: 'response-size') int get responseSize; String get error;
/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmExchangeSummaryCopyWith<MitmExchangeSummary> get copyWith => _$MitmExchangeSummaryCopyWithImpl<MitmExchangeSummary>(this as MitmExchangeSummary, _$identity);

  /// Serializes this MitmExchangeSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmExchangeSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmExchangeSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requestSize, _this.requestSize) || other.requestSize == _this.requestSize)&&(identical(other.responseSize, _this.responseSize) || other.responseSize == _this.responseSize)&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmExchangeSummary;
  return Object.hash(runtimeType,_this.id,_this.start,_this.pending,_this.duration,_this.method,_this.url,_this.status,_this.requestSize,_this.responseSize,_this.error);
}

@override
String toString() {
  final _this = this as MitmExchangeSummary;
  return 'MitmExchangeSummary(id: ${_this.id}, start: ${_this.start}, pending: ${_this.pending}, duration: ${_this.duration}, method: ${_this.method}, url: ${_this.url}, status: ${_this.status}, requestSize: ${_this.requestSize}, responseSize: ${_this.responseSize}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $MitmExchangeSummaryCopyWith<$Res>  {
  factory $MitmExchangeSummaryCopyWith(MitmExchangeSummary value, $Res Function(MitmExchangeSummary) _then) = _$MitmExchangeSummaryCopyWithImpl;
@useResult
$Res call({
 int id, DateTime start, bool pending, int duration, String method, String url, int status,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error
});




}
/// @nodoc
class _$MitmExchangeSummaryCopyWithImpl<$Res>
    implements $MitmExchangeSummaryCopyWith<$Res> {
  _$MitmExchangeSummaryCopyWithImpl(this._self, this._then);

  final MitmExchangeSummary _self;
  final $Res Function(MitmExchangeSummary) _then;

/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? method = null,Object? url = null,Object? status = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,}) {
  return _then(MitmExchangeSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,requestSize: null == requestSize ? _self.requestSize : requestSize // ignore: cast_nullable_to_non_nullable
as int,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmExchangeSummary].
extension MitmExchangeSummaryPatterns on MitmExchangeSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmExchangeSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmExchangeSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmExchangeSummary value)  $default,){
final _that = this;
switch (_that) {
case _MitmExchangeSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmExchangeSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MitmExchangeSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  String method,  String url,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmExchangeSummary() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.method,_that.url,_that.status,_that.requestSize,_that.responseSize,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  String method,  String url,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error)  $default,) {final _that = this;
switch (_that) {
case _MitmExchangeSummary():
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.method,_that.url,_that.status,_that.requestSize,_that.responseSize,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime start,  bool pending,  int duration,  String method,  String url,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error)?  $default,) {final _that = this;
switch (_that) {
case _MitmExchangeSummary() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.method,_that.url,_that.status,_that.requestSize,_that.responseSize,_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmExchangeSummary implements MitmExchangeSummary {
  const _MitmExchangeSummary({required this.id, required this.start, this.pending = false, this.duration = 0, this.method = '', this.url = '', this.status = 0, @JsonKey(name: 'request-size') this.requestSize = 0, @JsonKey(name: 'response-size') this.responseSize = 0, this.error = ''});
  factory _MitmExchangeSummary.fromJson(Map<String, dynamic> json) => _$MitmExchangeSummaryFromJson(json);

@override final  int id;
@override final  DateTime start;
@override@JsonKey() final  bool pending;
@override@JsonKey() final  int duration;
@override@JsonKey() final  String method;
@override@JsonKey() final  String url;
@override@JsonKey() final  int status;
@override@JsonKey(name: 'request-size') final  int requestSize;
@override@JsonKey(name: 'response-size') final  int responseSize;
@override@JsonKey() final  String error;

/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmExchangeSummaryCopyWith<_MitmExchangeSummary> get copyWith => __$MitmExchangeSummaryCopyWithImpl<_MitmExchangeSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmExchangeSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmExchangeSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.start, start) || other.start == start)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestSize, requestSize) || other.requestSize == requestSize)&&(identical(other.responseSize, responseSize) || other.responseSize == responseSize)&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,start,pending,duration,method,url,status,requestSize,responseSize,error);
}

@override
String toString() {
    return 'MitmExchangeSummary(id: $id, start: $start, pending: $pending, duration: $duration, method: $method, url: $url, status: $status, requestSize: $requestSize, responseSize: $responseSize, error: $error)';
}


}

/// @nodoc
abstract mixin class _$MitmExchangeSummaryCopyWith<$Res> implements $MitmExchangeSummaryCopyWith<$Res> {
  factory _$MitmExchangeSummaryCopyWith(_MitmExchangeSummary value, $Res Function(_MitmExchangeSummary) _then) = __$MitmExchangeSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime start, bool pending, int duration, String method, String url, int status,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error
});




}
/// @nodoc
class __$MitmExchangeSummaryCopyWithImpl<$Res>
    implements _$MitmExchangeSummaryCopyWith<$Res> {
  __$MitmExchangeSummaryCopyWithImpl(this._self, this._then);

  final _MitmExchangeSummary _self;
  final $Res Function(_MitmExchangeSummary) _then;

/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? method = null,Object? url = null,Object? status = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,}) {
  return _then(_MitmExchangeSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,requestSize: null == requestSize ? _self.requestSize : requestSize // ignore: cast_nullable_to_non_nullable
as int,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MitmExchangeList {

 bool get capturing; DateTime? get since; List<MitmExchangeSummary> get exchanges; bool get closed;
/// Create a copy of MitmExchangeList
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmExchangeListCopyWith<MitmExchangeList> get copyWith => _$MitmExchangeListCopyWithImpl<MitmExchangeList>(this as MitmExchangeList, _$identity);

  /// Serializes this MitmExchangeList to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmExchangeList;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmExchangeList&&(identical(other.capturing, _this.capturing) || other.capturing == _this.capturing)&&(identical(other.since, _this.since) || other.since == _this.since)&&const DeepCollectionEquality().equals(other.exchanges, _this.exchanges)&&(identical(other.closed, _this.closed) || other.closed == _this.closed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmExchangeList;
  return Object.hash(runtimeType,_this.capturing,_this.since,const DeepCollectionEquality().hash(_this.exchanges),_this.closed);
}

@override
String toString() {
  final _this = this as MitmExchangeList;
  return 'MitmExchangeList(capturing: ${_this.capturing}, since: ${_this.since}, exchanges: ${_this.exchanges}, closed: ${_this.closed})';
}


}

/// @nodoc
abstract mixin class $MitmExchangeListCopyWith<$Res>  {
  factory $MitmExchangeListCopyWith(MitmExchangeList value, $Res Function(MitmExchangeList) _then) = _$MitmExchangeListCopyWithImpl;
@useResult
$Res call({
 bool capturing, DateTime? since, List<MitmExchangeSummary> exchanges, bool closed
});




}
/// @nodoc
class _$MitmExchangeListCopyWithImpl<$Res>
    implements $MitmExchangeListCopyWith<$Res> {
  _$MitmExchangeListCopyWithImpl(this._self, this._then);

  final MitmExchangeList _self;
  final $Res Function(MitmExchangeList) _then;

/// Create a copy of MitmExchangeList
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capturing = null,Object? since = freezed,Object? exchanges = null,Object? closed = null,}) {
  return _then(MitmExchangeList(
capturing: null == capturing ? _self.capturing : capturing // ignore: cast_nullable_to_non_nullable
as bool,since: freezed == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime?,exchanges: null == exchanges ? _self.exchanges : exchanges // ignore: cast_nullable_to_non_nullable
as List<MitmExchangeSummary>,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmExchangeList].
extension MitmExchangeListPatterns on MitmExchangeList {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmExchangeList value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmExchangeList() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmExchangeList value)  $default,){
final _that = this;
switch (_that) {
case _MitmExchangeList():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmExchangeList value)?  $default,){
final _that = this;
switch (_that) {
case _MitmExchangeList() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool capturing,  DateTime? since,  List<MitmExchangeSummary> exchanges,  bool closed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmExchangeList() when $default != null:
return $default(_that.capturing,_that.since,_that.exchanges,_that.closed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool capturing,  DateTime? since,  List<MitmExchangeSummary> exchanges,  bool closed)  $default,) {final _that = this;
switch (_that) {
case _MitmExchangeList():
return $default(_that.capturing,_that.since,_that.exchanges,_that.closed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool capturing,  DateTime? since,  List<MitmExchangeSummary> exchanges,  bool closed)?  $default,) {final _that = this;
switch (_that) {
case _MitmExchangeList() when $default != null:
return $default(_that.capturing,_that.since,_that.exchanges,_that.closed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmExchangeList implements MitmExchangeList {
  const _MitmExchangeList({this.capturing = false, this.since,  List<MitmExchangeSummary> exchanges = const [], this.closed = false}): _exchanges = exchanges;
  factory _MitmExchangeList.fromJson(Map<String, dynamic> json) => _$MitmExchangeListFromJson(json);

@override@JsonKey() final  bool capturing;
@override final  DateTime? since;
 final  List<MitmExchangeSummary> _exchanges;
@override@JsonKey() List<MitmExchangeSummary> get exchanges {
  if (_exchanges is EqualUnmodifiableListView) return _exchanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exchanges);
}

@override@JsonKey() final  bool closed;

/// Create a copy of MitmExchangeList
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmExchangeListCopyWith<_MitmExchangeList> get copyWith => __$MitmExchangeListCopyWithImpl<_MitmExchangeList>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmExchangeListToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmExchangeList&&(identical(other.capturing, capturing) || other.capturing == capturing)&&(identical(other.since, since) || other.since == since)&&const DeepCollectionEquality().equals(other.exchanges, _exchanges)&&(identical(other.closed, closed) || other.closed == closed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,capturing,since,const DeepCollectionEquality().hash(_exchanges),closed);
}

@override
String toString() {
    return 'MitmExchangeList(capturing: $capturing, since: $since, exchanges: $exchanges, closed: $closed)';
}


}

/// @nodoc
abstract mixin class _$MitmExchangeListCopyWith<$Res> implements $MitmExchangeListCopyWith<$Res> {
  factory _$MitmExchangeListCopyWith(_MitmExchangeList value, $Res Function(_MitmExchangeList) _then) = __$MitmExchangeListCopyWithImpl;
@override @useResult
$Res call({
 bool capturing, DateTime? since, List<MitmExchangeSummary> exchanges, bool closed
});




}
/// @nodoc
class __$MitmExchangeListCopyWithImpl<$Res>
    implements _$MitmExchangeListCopyWith<$Res> {
  __$MitmExchangeListCopyWithImpl(this._self, this._then);

  final _MitmExchangeList _self;
  final $Res Function(_MitmExchangeList) _then;

/// Create a copy of MitmExchangeList
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capturing = null,Object? since = freezed,Object? exchanges = null,Object? closed = null,}) {
  return _then(_MitmExchangeList(
capturing: null == capturing ? _self.capturing : capturing // ignore: cast_nullable_to_non_nullable
as bool,since: freezed == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime?,exchanges: null == exchanges ? _self._exchanges : exchanges // ignore: cast_nullable_to_non_nullable
as List<MitmExchangeSummary>,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MitmAction {

 String get kind; String get phase; String get detail;
/// Create a copy of MitmAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmActionCopyWith<MitmAction> get copyWith => _$MitmActionCopyWithImpl<MitmAction>(this as MitmAction, _$identity);

  /// Serializes this MitmAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmAction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmAction&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.detail, _this.detail) || other.detail == _this.detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmAction;
  return Object.hash(runtimeType,_this.kind,_this.phase,_this.detail);
}

@override
String toString() {
  final _this = this as MitmAction;
  return 'MitmAction(kind: ${_this.kind}, phase: ${_this.phase}, detail: ${_this.detail})';
}


}

/// @nodoc
abstract mixin class $MitmActionCopyWith<$Res>  {
  factory $MitmActionCopyWith(MitmAction value, $Res Function(MitmAction) _then) = _$MitmActionCopyWithImpl;
@useResult
$Res call({
 String kind, String phase, String detail
});




}
/// @nodoc
class _$MitmActionCopyWithImpl<$Res>
    implements $MitmActionCopyWith<$Res> {
  _$MitmActionCopyWithImpl(this._self, this._then);

  final MitmAction _self;
  final $Res Function(MitmAction) _then;

/// Create a copy of MitmAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? phase = null,Object? detail = null,}) {
  return _then(MitmAction(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmAction].
extension MitmActionPatterns on MitmAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmAction value)  $default,){
final _that = this;
switch (_that) {
case _MitmAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmAction value)?  $default,){
final _that = this;
switch (_that) {
case _MitmAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String phase,  String detail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmAction() when $default != null:
return $default(_that.kind,_that.phase,_that.detail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String phase,  String detail)  $default,) {final _that = this;
switch (_that) {
case _MitmAction():
return $default(_that.kind,_that.phase,_that.detail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String phase,  String detail)?  $default,) {final _that = this;
switch (_that) {
case _MitmAction() when $default != null:
return $default(_that.kind,_that.phase,_that.detail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmAction implements MitmAction {
  const _MitmAction({required this.kind, this.phase = '', this.detail = ''});
  factory _MitmAction.fromJson(Map<String, dynamic> json) => _$MitmActionFromJson(json);

@override final  String kind;
@override@JsonKey() final  String phase;
@override@JsonKey() final  String detail;

/// Create a copy of MitmAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmActionCopyWith<_MitmAction> get copyWith => __$MitmActionCopyWithImpl<_MitmAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmActionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmAction&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.detail, detail) || other.detail == detail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,phase,detail);
}

@override
String toString() {
    return 'MitmAction(kind: $kind, phase: $phase, detail: $detail)';
}


}

/// @nodoc
abstract mixin class _$MitmActionCopyWith<$Res> implements $MitmActionCopyWith<$Res> {
  factory _$MitmActionCopyWith(_MitmAction value, $Res Function(_MitmAction) _then) = __$MitmActionCopyWithImpl;
@override @useResult
$Res call({
 String kind, String phase, String detail
});




}
/// @nodoc
class __$MitmActionCopyWithImpl<$Res>
    implements _$MitmActionCopyWith<$Res> {
  __$MitmActionCopyWithImpl(this._self, this._then);

  final _MitmAction _self;
  final $Res Function(_MitmAction) _then;

/// Create a copy of MitmAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? phase = null,Object? detail = null,}) {
  return _then(_MitmAction(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MitmExchange {

 int get id; DateTime get start; bool get pending; int get duration; int get ttfb; String get method; String get url;@JsonKey(name: 'original-url') String get originalUrl; String get proto; int get status;@JsonKey(name: 'request-size') int get requestSize;@JsonKey(name: 'response-size') int get responseSize; String get error; String get connection;@JsonKey(name: 'request-header') Map<String, List<String>> get requestHeader;@JsonKey(name: 'response-header') Map<String, List<String>> get responseHeader; List<MitmAction> get actions;
/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmExchangeCopyWith<MitmExchange> get copyWith => _$MitmExchangeCopyWithImpl<MitmExchange>(this as MitmExchange, _$identity);

  /// Serializes this MitmExchange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmExchange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmExchange&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.ttfb, _this.ttfb) || other.ttfb == _this.ttfb)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.originalUrl, _this.originalUrl) || other.originalUrl == _this.originalUrl)&&(identical(other.proto, _this.proto) || other.proto == _this.proto)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requestSize, _this.requestSize) || other.requestSize == _this.requestSize)&&(identical(other.responseSize, _this.responseSize) || other.responseSize == _this.responseSize)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.connection, _this.connection) || other.connection == _this.connection)&&const DeepCollectionEquality().equals(other.requestHeader, _this.requestHeader)&&const DeepCollectionEquality().equals(other.responseHeader, _this.responseHeader)&&const DeepCollectionEquality().equals(other.actions, _this.actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmExchange;
  return Object.hash(runtimeType,_this.id,_this.start,_this.pending,_this.duration,_this.ttfb,_this.method,_this.url,_this.originalUrl,_this.proto,_this.status,_this.requestSize,_this.responseSize,_this.error,_this.connection,const DeepCollectionEquality().hash(_this.requestHeader),const DeepCollectionEquality().hash(_this.responseHeader),const DeepCollectionEquality().hash(_this.actions));
}

@override
String toString() {
  final _this = this as MitmExchange;
  return 'MitmExchange(id: ${_this.id}, start: ${_this.start}, pending: ${_this.pending}, duration: ${_this.duration}, ttfb: ${_this.ttfb}, method: ${_this.method}, url: ${_this.url}, originalUrl: ${_this.originalUrl}, proto: ${_this.proto}, status: ${_this.status}, requestSize: ${_this.requestSize}, responseSize: ${_this.responseSize}, error: ${_this.error}, connection: ${_this.connection}, requestHeader: ${_this.requestHeader}, responseHeader: ${_this.responseHeader}, actions: ${_this.actions})';
}


}

/// @nodoc
abstract mixin class $MitmExchangeCopyWith<$Res>  {
  factory $MitmExchangeCopyWith(MitmExchange value, $Res Function(MitmExchange) _then) = _$MitmExchangeCopyWithImpl;
@useResult
$Res call({
 int id, DateTime start, bool pending, int duration, int ttfb, String method, String url,@JsonKey(name: 'original-url') String originalUrl, String proto, int status,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error, String connection,@JsonKey(name: 'request-header') Map<String, List<String>> requestHeader,@JsonKey(name: 'response-header') Map<String, List<String>> responseHeader, List<MitmAction> actions
});




}
/// @nodoc
class _$MitmExchangeCopyWithImpl<$Res>
    implements $MitmExchangeCopyWith<$Res> {
  _$MitmExchangeCopyWithImpl(this._self, this._then);

  final MitmExchange _self;
  final $Res Function(MitmExchange) _then;

/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? ttfb = null,Object? method = null,Object? url = null,Object? originalUrl = null,Object? proto = null,Object? status = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,Object? connection = null,Object? requestHeader = null,Object? responseHeader = null,Object? actions = null,}) {
  return _then(MitmExchange(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,ttfb: null == ttfb ? _self.ttfb : ttfb // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,originalUrl: null == originalUrl ? _self.originalUrl : originalUrl // ignore: cast_nullable_to_non_nullable
as String,proto: null == proto ? _self.proto : proto // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,requestSize: null == requestSize ? _self.requestSize : requestSize // ignore: cast_nullable_to_non_nullable
as int,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as String,requestHeader: null == requestHeader ? _self.requestHeader : requestHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,responseHeader: null == responseHeader ? _self.responseHeader : responseHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<MitmAction>,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmExchange].
extension MitmExchangePatterns on MitmExchange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmExchange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmExchange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmExchange value)  $default,){
final _that = this;
switch (_that) {
case _MitmExchange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmExchange value)?  $default,){
final _that = this;
switch (_that) {
case _MitmExchange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  int ttfb,  String method,  String url, @JsonKey(name: 'original-url')  String originalUrl,  String proto,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String connection, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader,  List<MitmAction> actions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmExchange() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.ttfb,_that.method,_that.url,_that.originalUrl,_that.proto,_that.status,_that.requestSize,_that.responseSize,_that.error,_that.connection,_that.requestHeader,_that.responseHeader,_that.actions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  int ttfb,  String method,  String url, @JsonKey(name: 'original-url')  String originalUrl,  String proto,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String connection, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader,  List<MitmAction> actions)  $default,) {final _that = this;
switch (_that) {
case _MitmExchange():
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.ttfb,_that.method,_that.url,_that.originalUrl,_that.proto,_that.status,_that.requestSize,_that.responseSize,_that.error,_that.connection,_that.requestHeader,_that.responseHeader,_that.actions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime start,  bool pending,  int duration,  int ttfb,  String method,  String url, @JsonKey(name: 'original-url')  String originalUrl,  String proto,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String connection, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader,  List<MitmAction> actions)?  $default,) {final _that = this;
switch (_that) {
case _MitmExchange() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.ttfb,_that.method,_that.url,_that.originalUrl,_that.proto,_that.status,_that.requestSize,_that.responseSize,_that.error,_that.connection,_that.requestHeader,_that.responseHeader,_that.actions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmExchange implements MitmExchange {
  const _MitmExchange({required this.id, required this.start, this.pending = false, this.duration = 0, this.ttfb = 0, this.method = '', this.url = '', @JsonKey(name: 'original-url') this.originalUrl = '', this.proto = '', this.status = 0, @JsonKey(name: 'request-size') this.requestSize = 0, @JsonKey(name: 'response-size') this.responseSize = 0, this.error = '', this.connection = '', @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader = const {}, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader = const {},  List<MitmAction> actions = const []}): _requestHeader = requestHeader,_responseHeader = responseHeader,_actions = actions;
  factory _MitmExchange.fromJson(Map<String, dynamic> json) => _$MitmExchangeFromJson(json);

@override final  int id;
@override final  DateTime start;
@override@JsonKey() final  bool pending;
@override@JsonKey() final  int duration;
@override@JsonKey() final  int ttfb;
@override@JsonKey() final  String method;
@override@JsonKey() final  String url;
@override@JsonKey(name: 'original-url') final  String originalUrl;
@override@JsonKey() final  String proto;
@override@JsonKey() final  int status;
@override@JsonKey(name: 'request-size') final  int requestSize;
@override@JsonKey(name: 'response-size') final  int responseSize;
@override@JsonKey() final  String error;
@override@JsonKey() final  String connection;
 final  Map<String, List<String>> _requestHeader;
@override@JsonKey(name: 'request-header') Map<String, List<String>> get requestHeader {
  if (_requestHeader is EqualUnmodifiableMapView) return _requestHeader;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_requestHeader);
}

 final  Map<String, List<String>> _responseHeader;
@override@JsonKey(name: 'response-header') Map<String, List<String>> get responseHeader {
  if (_responseHeader is EqualUnmodifiableMapView) return _responseHeader;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_responseHeader);
}

 final  List<MitmAction> _actions;
@override@JsonKey() List<MitmAction> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}


/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmExchangeCopyWith<_MitmExchange> get copyWith => __$MitmExchangeCopyWithImpl<_MitmExchange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmExchangeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmExchange&&(identical(other.id, id) || other.id == id)&&(identical(other.start, start) || other.start == start)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.ttfb, ttfb) || other.ttfb == ttfb)&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&(identical(other.originalUrl, originalUrl) || other.originalUrl == originalUrl)&&(identical(other.proto, proto) || other.proto == proto)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestSize, requestSize) || other.requestSize == requestSize)&&(identical(other.responseSize, responseSize) || other.responseSize == responseSize)&&(identical(other.error, error) || other.error == error)&&(identical(other.connection, connection) || other.connection == connection)&&const DeepCollectionEquality().equals(other.requestHeader, _requestHeader)&&const DeepCollectionEquality().equals(other.responseHeader, _responseHeader)&&const DeepCollectionEquality().equals(other.actions, _actions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,start,pending,duration,ttfb,method,url,originalUrl,proto,status,requestSize,responseSize,error,connection,const DeepCollectionEquality().hash(_requestHeader),const DeepCollectionEquality().hash(_responseHeader),const DeepCollectionEquality().hash(_actions));
}

@override
String toString() {
    return 'MitmExchange(id: $id, start: $start, pending: $pending, duration: $duration, ttfb: $ttfb, method: $method, url: $url, originalUrl: $originalUrl, proto: $proto, status: $status, requestSize: $requestSize, responseSize: $responseSize, error: $error, connection: $connection, requestHeader: $requestHeader, responseHeader: $responseHeader, actions: $actions)';
}


}

/// @nodoc
abstract mixin class _$MitmExchangeCopyWith<$Res> implements $MitmExchangeCopyWith<$Res> {
  factory _$MitmExchangeCopyWith(_MitmExchange value, $Res Function(_MitmExchange) _then) = __$MitmExchangeCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime start, bool pending, int duration, int ttfb, String method, String url,@JsonKey(name: 'original-url') String originalUrl, String proto, int status,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error, String connection,@JsonKey(name: 'request-header') Map<String, List<String>> requestHeader,@JsonKey(name: 'response-header') Map<String, List<String>> responseHeader, List<MitmAction> actions
});




}
/// @nodoc
class __$MitmExchangeCopyWithImpl<$Res>
    implements _$MitmExchangeCopyWith<$Res> {
  __$MitmExchangeCopyWithImpl(this._self, this._then);

  final _MitmExchange _self;
  final $Res Function(_MitmExchange) _then;

/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? ttfb = null,Object? method = null,Object? url = null,Object? originalUrl = null,Object? proto = null,Object? status = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,Object? connection = null,Object? requestHeader = null,Object? responseHeader = null,Object? actions = null,}) {
  return _then(_MitmExchange(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int,ttfb: null == ttfb ? _self.ttfb : ttfb // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,originalUrl: null == originalUrl ? _self.originalUrl : originalUrl // ignore: cast_nullable_to_non_nullable
as String,proto: null == proto ? _self.proto : proto // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,requestSize: null == requestSize ? _self.requestSize : requestSize // ignore: cast_nullable_to_non_nullable
as int,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as String,requestHeader: null == requestHeader ? _self._requestHeader : requestHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,responseHeader: null == responseHeader ? _self._responseHeader : responseHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<MitmAction>,
  ));
}


}


/// @nodoc
mixin _$MitmBody {

 String get data; bool get truncated; String get encoding;
/// Create a copy of MitmBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmBodyCopyWith<MitmBody> get copyWith => _$MitmBodyCopyWithImpl<MitmBody>(this as MitmBody, _$identity);

  /// Serializes this MitmBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmBody;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmBody&&(identical(other.data, _this.data) || other.data == _this.data)&&(identical(other.truncated, _this.truncated) || other.truncated == _this.truncated)&&(identical(other.encoding, _this.encoding) || other.encoding == _this.encoding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmBody;
  return Object.hash(runtimeType,_this.data,_this.truncated,_this.encoding);
}

@override
String toString() {
  final _this = this as MitmBody;
  return 'MitmBody(data: ${_this.data}, truncated: ${_this.truncated}, encoding: ${_this.encoding})';
}


}

/// @nodoc
abstract mixin class $MitmBodyCopyWith<$Res>  {
  factory $MitmBodyCopyWith(MitmBody value, $Res Function(MitmBody) _then) = _$MitmBodyCopyWithImpl;
@useResult
$Res call({
 String data, bool truncated, String encoding
});




}
/// @nodoc
class _$MitmBodyCopyWithImpl<$Res>
    implements $MitmBodyCopyWith<$Res> {
  _$MitmBodyCopyWithImpl(this._self, this._then);

  final MitmBody _self;
  final $Res Function(MitmBody) _then;

/// Create a copy of MitmBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? truncated = null,Object? encoding = null,}) {
  return _then(MitmBody(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,encoding: null == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmBody].
extension MitmBodyPatterns on MitmBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmBody value)  $default,){
final _that = this;
switch (_that) {
case _MitmBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmBody value)?  $default,){
final _that = this;
switch (_that) {
case _MitmBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String data,  bool truncated,  String encoding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmBody() when $default != null:
return $default(_that.data,_that.truncated,_that.encoding);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String data,  bool truncated,  String encoding)  $default,) {final _that = this;
switch (_that) {
case _MitmBody():
return $default(_that.data,_that.truncated,_that.encoding);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String data,  bool truncated,  String encoding)?  $default,) {final _that = this;
switch (_that) {
case _MitmBody() when $default != null:
return $default(_that.data,_that.truncated,_that.encoding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmBody implements MitmBody {
  const _MitmBody({this.data = '', this.truncated = false, this.encoding = ''});
  factory _MitmBody.fromJson(Map<String, dynamic> json) => _$MitmBodyFromJson(json);

@override@JsonKey() final  String data;
@override@JsonKey() final  bool truncated;
@override@JsonKey() final  String encoding;

/// Create a copy of MitmBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmBodyCopyWith<_MitmBody> get copyWith => __$MitmBodyCopyWithImpl<_MitmBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmBodyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmBody&&(identical(other.data, data) || other.data == data)&&(identical(other.truncated, truncated) || other.truncated == truncated)&&(identical(other.encoding, encoding) || other.encoding == encoding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,data,truncated,encoding);
}

@override
String toString() {
    return 'MitmBody(data: $data, truncated: $truncated, encoding: $encoding)';
}


}

/// @nodoc
abstract mixin class _$MitmBodyCopyWith<$Res> implements $MitmBodyCopyWith<$Res> {
  factory _$MitmBodyCopyWith(_MitmBody value, $Res Function(_MitmBody) _then) = __$MitmBodyCopyWithImpl;
@override @useResult
$Res call({
 String data, bool truncated, String encoding
});




}
/// @nodoc
class __$MitmBodyCopyWithImpl<$Res>
    implements _$MitmBodyCopyWith<$Res> {
  __$MitmBodyCopyWithImpl(this._self, this._then);

  final _MitmBody _self;
  final $Res Function(_MitmBody) _then;

/// Create a copy of MitmBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? truncated = null,Object? encoding = null,}) {
  return _then(_MitmBody(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String,truncated: null == truncated ? _self.truncated : truncated // ignore: cast_nullable_to_non_nullable
as bool,encoding: null == encoding ? _self.encoding : encoding // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VpnOptions {

 bool get enable; int get port; bool get ipv6; bool get dnsHijacking; AccessControlProps get accessControlProps; bool get allowBypass; bool get systemProxy; List<String> get bypassDomain; String get stack; List<String> get routeAddress; int get mtu; String get congestionController;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnOptions&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.dnsHijacking, _this.dnsHijacking) || other.dnsHijacking == _this.dnsHijacking)&&(identical(other.accessControlProps, _this.accessControlProps) || other.accessControlProps == _this.accessControlProps)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&(identical(other.stack, _this.stack) || other.stack == _this.stack)&&const DeepCollectionEquality().equals(other.routeAddress, _this.routeAddress)&&(identical(other.mtu, _this.mtu) || other.mtu == _this.mtu)&&(identical(other.congestionController, _this.congestionController) || other.congestionController == _this.congestionController));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnOptions;
  return Object.hash(runtimeType,_this.enable,_this.port,_this.ipv6,_this.dnsHijacking,_this.accessControlProps,_this.allowBypass,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),_this.stack,const DeepCollectionEquality().hash(_this.routeAddress),_this.mtu,_this.congestionController);
}

@override
String toString() {
  final _this = this as VpnOptions;
  return 'VpnOptions(enable: ${_this.enable}, port: ${_this.port}, ipv6: ${_this.ipv6}, dnsHijacking: ${_this.dnsHijacking}, accessControlProps: ${_this.accessControlProps}, allowBypass: ${_this.allowBypass}, systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, stack: ${_this.stack}, routeAddress: ${_this.routeAddress}, mtu: ${_this.mtu}, congestionController: ${_this.congestionController})';
}


}

/// @nodoc
abstract mixin class $VpnOptionsCopyWith<$Res>  {
  factory $VpnOptionsCopyWith(VpnOptions value, $Res Function(VpnOptions) _then) = _$VpnOptionsCopyWithImpl;
@useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress, int mtu, String congestionController
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
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,Object? mtu = null,Object? congestionController = null,}) {
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
as List<String>,mtu: null == mtu ? _self.mtu : mtu // ignore: cast_nullable_to_non_nullable
as int,congestionController: null == congestionController ? _self.congestionController : congestionController // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress,  int mtu,  String congestionController)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress,_that.mtu,_that.congestionController);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress,  int mtu,  String congestionController)  $default,) {final _that = this;
switch (_that) {
case _VpnOptions():
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress,_that.mtu,_that.congestionController);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  String stack,  List<String> routeAddress,  int mtu,  String congestionController)?  $default,) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.stack,_that.routeAddress,_that.mtu,_that.congestionController);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnOptions implements VpnOptions {
  const _VpnOptions({required this.enable, required this.port, required this.ipv6, required this.dnsHijacking, required this.accessControlProps, required this.allowBypass, required this.systemProxy, required  List<String> bypassDomain, required this.stack,  List<String> routeAddress = const [], this.mtu = 0, this.congestionController = ''}): _bypassDomain = bypassDomain,_routeAddress = routeAddress;
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

@override@JsonKey() final  int mtu;
@override@JsonKey() final  String congestionController;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.port, port) || other.port == port)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&(identical(other.stack, stack) || other.stack == stack)&&const DeepCollectionEquality().equals(other.routeAddress, _routeAddress)&&(identical(other.mtu, mtu) || other.mtu == mtu)&&(identical(other.congestionController, congestionController) || other.congestionController == congestionController));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,port,ipv6,dnsHijacking,accessControlProps,allowBypass,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),stack,const DeepCollectionEquality().hash(_routeAddress),mtu,congestionController);
}

@override
String toString() {
    return 'VpnOptions(enable: $enable, port: $port, ipv6: $ipv6, dnsHijacking: $dnsHijacking, accessControlProps: $accessControlProps, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, stack: $stack, routeAddress: $routeAddress, mtu: $mtu, congestionController: $congestionController)';
}


}

/// @nodoc
abstract mixin class _$VpnOptionsCopyWith<$Res> implements $VpnOptionsCopyWith<$Res> {
  factory _$VpnOptionsCopyWith(_VpnOptions value, $Res Function(_VpnOptions) _then) = __$VpnOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, String stack, List<String> routeAddress, int mtu, String congestionController
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
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? stack = null,Object? routeAddress = null,Object? mtu = null,Object? congestionController = null,}) {
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
as List<String>,mtu: null == mtu ? _self.mtu : mtu // ignore: cast_nullable_to_non_nullable
as int,congestionController: null == congestionController ? _self.congestionController : congestionController // ignore: cast_nullable_to_non_nullable
as String,
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

@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'route-version') int get routeVersion;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteSnapshot&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.routeVersion, _this.routeVersion) || other.routeVersion == _this.routeVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteSnapshot;
  return Object.hash(runtimeType,_this.coreEpoch,_this.routeVersion);
}

@override
String toString() {
  final _this = this as RouteSnapshot;
  return 'RouteSnapshot(coreEpoch: ${_this.coreEpoch}, routeVersion: ${_this.routeVersion})';
}


}

/// @nodoc
abstract mixin class $RouteSnapshotCopyWith<$Res>  {
  factory $RouteSnapshotCopyWith(RouteSnapshot value, $Res Function(RouteSnapshot) _then) = _$RouteSnapshotCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion
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
@pragma('vm:prefer-inline') @override $Res call({Object? coreEpoch = null,Object? routeVersion = null,}) {
  return _then(RouteSnapshot(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
return $default(_that.coreEpoch,_that.routeVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion)  $default,) {final _that = this;
switch (_that) {
case _RouteSnapshot():
return $default(_that.coreEpoch,_that.routeVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion)?  $default,) {final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
return $default(_that.coreEpoch,_that.routeVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteSnapshot implements RouteSnapshot {
  const _RouteSnapshot({@JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'route-version') this.routeVersion = 0});
  factory _RouteSnapshot.fromJson(Map<String, dynamic> json) => _$RouteSnapshotFromJson(json);

@override@JsonKey(name: 'core-epoch') final  int coreEpoch;
@override@JsonKey(name: 'route-version') final  int routeVersion;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteSnapshot&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.routeVersion, routeVersion) || other.routeVersion == routeVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,coreEpoch,routeVersion);
}

@override
String toString() {
    return 'RouteSnapshot(coreEpoch: $coreEpoch, routeVersion: $routeVersion)';
}


}

/// @nodoc
abstract mixin class _$RouteSnapshotCopyWith<$Res> implements $RouteSnapshotCopyWith<$Res> {
  factory _$RouteSnapshotCopyWith(_RouteSnapshot value, $Res Function(_RouteSnapshot) _then) = __$RouteSnapshotCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion
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
@override @pragma('vm:prefer-inline') $Res call({Object? coreEpoch = null,Object? routeVersion = null,}) {
  return _then(_RouteSnapshot(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$RouteHit {

 String get host; String get proxy; String get exit;
/// Create a copy of RouteHit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteHitCopyWith<RouteHit> get copyWith => _$RouteHitCopyWithImpl<RouteHit>(this as RouteHit, _$identity);

  /// Serializes this RouteHit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteHit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteHit&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.proxy, _this.proxy) || other.proxy == _this.proxy)&&(identical(other.exit, _this.exit) || other.exit == _this.exit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteHit;
  return Object.hash(runtimeType,_this.host,_this.proxy,_this.exit);
}

@override
String toString() {
  final _this = this as RouteHit;
  return 'RouteHit(host: ${_this.host}, proxy: ${_this.proxy}, exit: ${_this.exit})';
}


}

/// @nodoc
abstract mixin class $RouteHitCopyWith<$Res>  {
  factory $RouteHitCopyWith(RouteHit value, $Res Function(RouteHit) _then) = _$RouteHitCopyWithImpl;
@useResult
$Res call({
 String host, String proxy, String exit
});




}
/// @nodoc
class _$RouteHitCopyWithImpl<$Res>
    implements $RouteHitCopyWith<$Res> {
  _$RouteHitCopyWithImpl(this._self, this._then);

  final RouteHit _self;
  final $Res Function(RouteHit) _then;

/// Create a copy of RouteHit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? proxy = null,Object? exit = null,}) {
  return _then(RouteHit(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,proxy: null == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String,exit: null == exit ? _self.exit : exit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteHit].
extension RouteHitPatterns on RouteHit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteHit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteHit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteHit value)  $default,){
final _that = this;
switch (_that) {
case _RouteHit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteHit value)?  $default,){
final _that = this;
switch (_that) {
case _RouteHit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  String proxy,  String exit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteHit() when $default != null:
return $default(_that.host,_that.proxy,_that.exit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  String proxy,  String exit)  $default,) {final _that = this;
switch (_that) {
case _RouteHit():
return $default(_that.host,_that.proxy,_that.exit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  String proxy,  String exit)?  $default,) {final _that = this;
switch (_that) {
case _RouteHit() when $default != null:
return $default(_that.host,_that.proxy,_that.exit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteHit implements RouteHit {
  const _RouteHit({this.host = '', this.proxy = '', this.exit = ''});
  factory _RouteHit.fromJson(Map<String, dynamic> json) => _$RouteHitFromJson(json);

@override@JsonKey() final  String host;
@override@JsonKey() final  String proxy;
@override@JsonKey() final  String exit;

/// Create a copy of RouteHit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteHitCopyWith<_RouteHit> get copyWith => __$RouteHitCopyWithImpl<_RouteHit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteHitToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteHit&&(identical(other.host, host) || other.host == host)&&(identical(other.proxy, proxy) || other.proxy == proxy)&&(identical(other.exit, exit) || other.exit == exit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,host,proxy,exit);
}

@override
String toString() {
    return 'RouteHit(host: $host, proxy: $proxy, exit: $exit)';
}


}

/// @nodoc
abstract mixin class _$RouteHitCopyWith<$Res> implements $RouteHitCopyWith<$Res> {
  factory _$RouteHitCopyWith(_RouteHit value, $Res Function(_RouteHit) _then) = __$RouteHitCopyWithImpl;
@override @useResult
$Res call({
 String host, String proxy, String exit
});




}
/// @nodoc
class __$RouteHitCopyWithImpl<$Res>
    implements _$RouteHitCopyWith<$Res> {
  __$RouteHitCopyWithImpl(this._self, this._then);

  final _RouteHit _self;
  final $Res Function(_RouteHit) _then;

/// Create a copy of RouteHit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? proxy = null,Object? exit = null,}) {
  return _then(_RouteHit(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,proxy: null == proxy ? _self.proxy : proxy // ignore: cast_nullable_to_non_nullable
as String,exit: null == exit ? _self.exit : exit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CheckRoutesParams {

 List<List<RouteHit>> get routes;
/// Create a copy of CheckRoutesParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckRoutesParamsCopyWith<CheckRoutesParams> get copyWith => _$CheckRoutesParamsCopyWithImpl<CheckRoutesParams>(this as CheckRoutesParams, _$identity);

  /// Serializes this CheckRoutesParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CheckRoutesParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckRoutesParams&&const DeepCollectionEquality().equals(other.routes, _this.routes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CheckRoutesParams;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.routes));
}

@override
String toString() {
  final _this = this as CheckRoutesParams;
  return 'CheckRoutesParams(routes: ${_this.routes})';
}


}

/// @nodoc
abstract mixin class $CheckRoutesParamsCopyWith<$Res>  {
  factory $CheckRoutesParamsCopyWith(CheckRoutesParams value, $Res Function(CheckRoutesParams) _then) = _$CheckRoutesParamsCopyWithImpl;
@useResult
$Res call({
 List<List<RouteHit>> routes
});




}
/// @nodoc
class _$CheckRoutesParamsCopyWithImpl<$Res>
    implements $CheckRoutesParamsCopyWith<$Res> {
  _$CheckRoutesParamsCopyWithImpl(this._self, this._then);

  final CheckRoutesParams _self;
  final $Res Function(CheckRoutesParams) _then;

/// Create a copy of CheckRoutesParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? routes = null,}) {
  return _then(CheckRoutesParams(
routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<List<RouteHit>>,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckRoutesParams].
extension CheckRoutesParamsPatterns on CheckRoutesParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckRoutesParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckRoutesParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckRoutesParams value)  $default,){
final _that = this;
switch (_that) {
case _CheckRoutesParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckRoutesParams value)?  $default,){
final _that = this;
switch (_that) {
case _CheckRoutesParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<List<RouteHit>> routes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckRoutesParams() when $default != null:
return $default(_that.routes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<List<RouteHit>> routes)  $default,) {final _that = this;
switch (_that) {
case _CheckRoutesParams():
return $default(_that.routes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<List<RouteHit>> routes)?  $default,) {final _that = this;
switch (_that) {
case _CheckRoutesParams() when $default != null:
return $default(_that.routes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckRoutesParams implements CheckRoutesParams {
  const _CheckRoutesParams({ List<List<RouteHit>> routes = const []}): _routes = routes;
  factory _CheckRoutesParams.fromJson(Map<String, dynamic> json) => _$CheckRoutesParamsFromJson(json);

 final  List<List<RouteHit>> _routes;
@override@JsonKey() List<List<RouteHit>> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}


/// Create a copy of CheckRoutesParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckRoutesParamsCopyWith<_CheckRoutesParams> get copyWith => __$CheckRoutesParamsCopyWithImpl<_CheckRoutesParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckRoutesParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckRoutesParams&&const DeepCollectionEquality().equals(other.routes, _routes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_routes));
}

@override
String toString() {
    return 'CheckRoutesParams(routes: $routes)';
}


}

/// @nodoc
abstract mixin class _$CheckRoutesParamsCopyWith<$Res> implements $CheckRoutesParamsCopyWith<$Res> {
  factory _$CheckRoutesParamsCopyWith(_CheckRoutesParams value, $Res Function(_CheckRoutesParams) _then) = __$CheckRoutesParamsCopyWithImpl;
@override @useResult
$Res call({
 List<List<RouteHit>> routes
});




}
/// @nodoc
class __$CheckRoutesParamsCopyWithImpl<$Res>
    implements _$CheckRoutesParamsCopyWith<$Res> {
  __$CheckRoutesParamsCopyWithImpl(this._self, this._then);

  final _CheckRoutesParams _self;
  final $Res Function(_CheckRoutesParams) _then;

/// Create a copy of CheckRoutesParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? routes = null,}) {
  return _then(_CheckRoutesParams(
routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<List<RouteHit>>,
  ));
}


}


/// @nodoc
mixin _$RouteCheck {

@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'route-version') int get routeVersion; List<bool> get held;
/// Create a copy of RouteCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteCheckCopyWith<RouteCheck> get copyWith => _$RouteCheckCopyWithImpl<RouteCheck>(this as RouteCheck, _$identity);

  /// Serializes this RouteCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RouteCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteCheck&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.routeVersion, _this.routeVersion) || other.routeVersion == _this.routeVersion)&&const DeepCollectionEquality().equals(other.held, _this.held));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RouteCheck;
  return Object.hash(runtimeType,_this.coreEpoch,_this.routeVersion,const DeepCollectionEquality().hash(_this.held));
}

@override
String toString() {
  final _this = this as RouteCheck;
  return 'RouteCheck(coreEpoch: ${_this.coreEpoch}, routeVersion: ${_this.routeVersion}, held: ${_this.held})';
}


}

/// @nodoc
abstract mixin class $RouteCheckCopyWith<$Res>  {
  factory $RouteCheckCopyWith(RouteCheck value, $Res Function(RouteCheck) _then) = _$RouteCheckCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<bool> held
});




}
/// @nodoc
class _$RouteCheckCopyWithImpl<$Res>
    implements $RouteCheckCopyWith<$Res> {
  _$RouteCheckCopyWithImpl(this._self, this._then);

  final RouteCheck _self;
  final $Res Function(RouteCheck) _then;

/// Create a copy of RouteCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coreEpoch = null,Object? routeVersion = null,Object? held = null,}) {
  return _then(RouteCheck(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as List<bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteCheck].
extension RouteCheckPatterns on RouteCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteCheck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteCheck value)  $default,){
final _that = this;
switch (_that) {
case _RouteCheck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteCheck value)?  $default,){
final _that = this;
switch (_that) {
case _RouteCheck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<bool> held)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteCheck() when $default != null:
return $default(_that.coreEpoch,_that.routeVersion,_that.held);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<bool> held)  $default,) {final _that = this;
switch (_that) {
case _RouteCheck():
return $default(_that.coreEpoch,_that.routeVersion,_that.held);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<bool> held)?  $default,) {final _that = this;
switch (_that) {
case _RouteCheck() when $default != null:
return $default(_that.coreEpoch,_that.routeVersion,_that.held);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteCheck implements RouteCheck {
  const _RouteCheck({@JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'route-version') this.routeVersion = 0,  List<bool> held = const []}): _held = held;
  factory _RouteCheck.fromJson(Map<String, dynamic> json) => _$RouteCheckFromJson(json);

@override@JsonKey(name: 'core-epoch') final  int coreEpoch;
@override@JsonKey(name: 'route-version') final  int routeVersion;
 final  List<bool> _held;
@override@JsonKey() List<bool> get held {
  if (_held is EqualUnmodifiableListView) return _held;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_held);
}


/// Create a copy of RouteCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteCheckCopyWith<_RouteCheck> get copyWith => __$RouteCheckCopyWithImpl<_RouteCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteCheck&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.routeVersion, routeVersion) || other.routeVersion == routeVersion)&&const DeepCollectionEquality().equals(other.held, _held));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,coreEpoch,routeVersion,const DeepCollectionEquality().hash(_held));
}

@override
String toString() {
    return 'RouteCheck(coreEpoch: $coreEpoch, routeVersion: $routeVersion, held: $held)';
}


}

/// @nodoc
abstract mixin class _$RouteCheckCopyWith<$Res> implements $RouteCheckCopyWith<$Res> {
  factory _$RouteCheckCopyWith(_RouteCheck value, $Res Function(_RouteCheck) _then) = __$RouteCheckCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<bool> held
});




}
/// @nodoc
class __$RouteCheckCopyWithImpl<$Res>
    implements _$RouteCheckCopyWith<$Res> {
  __$RouteCheckCopyWithImpl(this._self, this._then);

  final _RouteCheck _self;
  final $Res Function(_RouteCheck) _then;

/// Create a copy of RouteCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coreEpoch = null,Object? routeVersion = null,Object? held = null,}) {
  return _then(_RouteCheck(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,held: null == held ? _self._held : held // ignore: cast_nullable_to_non_nullable
as List<bool>,
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
mixin _$TestDelayParams {

@JsonKey(name: 'proxy-name') String get proxyName;@JsonKey(name: 'test-url') String get testUrl; int get timeout;
/// Create a copy of TestDelayParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestDelayParamsCopyWith<TestDelayParams> get copyWith => _$TestDelayParamsCopyWithImpl<TestDelayParams>(this as TestDelayParams, _$identity);

  /// Serializes this TestDelayParams to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TestDelayParams;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestDelayParams&&(identical(other.proxyName, _this.proxyName) || other.proxyName == _this.proxyName)&&(identical(other.testUrl, _this.testUrl) || other.testUrl == _this.testUrl)&&(identical(other.timeout, _this.timeout) || other.timeout == _this.timeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TestDelayParams;
  return Object.hash(runtimeType,_this.proxyName,_this.testUrl,_this.timeout);
}

@override
String toString() {
  final _this = this as TestDelayParams;
  return 'TestDelayParams(proxyName: ${_this.proxyName}, testUrl: ${_this.testUrl}, timeout: ${_this.timeout})';
}


}

/// @nodoc
abstract mixin class $TestDelayParamsCopyWith<$Res>  {
  factory $TestDelayParamsCopyWith(TestDelayParams value, $Res Function(TestDelayParams) _then) = _$TestDelayParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'proxy-name') String proxyName,@JsonKey(name: 'test-url') String testUrl, int timeout
});




}
/// @nodoc
class _$TestDelayParamsCopyWithImpl<$Res>
    implements $TestDelayParamsCopyWith<$Res> {
  _$TestDelayParamsCopyWithImpl(this._self, this._then);

  final TestDelayParams _self;
  final $Res Function(TestDelayParams) _then;

/// Create a copy of TestDelayParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyName = null,Object? testUrl = null,Object? timeout = null,}) {
  return _then(TestDelayParams(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TestDelayParams].
extension TestDelayParamsPatterns on TestDelayParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestDelayParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestDelayParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestDelayParams value)  $default,){
final _that = this;
switch (_that) {
case _TestDelayParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestDelayParams value)?  $default,){
final _that = this;
switch (_that) {
case _TestDelayParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-name')  String proxyName, @JsonKey(name: 'test-url')  String testUrl,  int timeout)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestDelayParams() when $default != null:
return $default(_that.proxyName,_that.testUrl,_that.timeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'proxy-name')  String proxyName, @JsonKey(name: 'test-url')  String testUrl,  int timeout)  $default,) {final _that = this;
switch (_that) {
case _TestDelayParams():
return $default(_that.proxyName,_that.testUrl,_that.timeout);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'proxy-name')  String proxyName, @JsonKey(name: 'test-url')  String testUrl,  int timeout)?  $default,) {final _that = this;
switch (_that) {
case _TestDelayParams() when $default != null:
return $default(_that.proxyName,_that.testUrl,_that.timeout);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestDelayParams implements TestDelayParams {
  const _TestDelayParams({@JsonKey(name: 'proxy-name') required this.proxyName, @JsonKey(name: 'test-url') required this.testUrl, required this.timeout});
  factory _TestDelayParams.fromJson(Map<String, dynamic> json) => _$TestDelayParamsFromJson(json);

@override@JsonKey(name: 'proxy-name') final  String proxyName;
@override@JsonKey(name: 'test-url') final  String testUrl;
@override final  int timeout;

/// Create a copy of TestDelayParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestDelayParamsCopyWith<_TestDelayParams> get copyWith => __$TestDelayParamsCopyWithImpl<_TestDelayParams>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestDelayParamsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestDelayParams&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.timeout, timeout) || other.timeout == timeout));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,proxyName,testUrl,timeout);
}

@override
String toString() {
    return 'TestDelayParams(proxyName: $proxyName, testUrl: $testUrl, timeout: $timeout)';
}


}

/// @nodoc
abstract mixin class _$TestDelayParamsCopyWith<$Res> implements $TestDelayParamsCopyWith<$Res> {
  factory _$TestDelayParamsCopyWith(_TestDelayParams value, $Res Function(_TestDelayParams) _then) = __$TestDelayParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'proxy-name') String proxyName,@JsonKey(name: 'test-url') String testUrl, int timeout
});




}
/// @nodoc
class __$TestDelayParamsCopyWithImpl<$Res>
    implements _$TestDelayParamsCopyWith<$Res> {
  __$TestDelayParamsCopyWithImpl(this._self, this._then);

  final _TestDelayParams _self;
  final $Res Function(_TestDelayParams) _then;

/// Create a copy of TestDelayParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyName = null,Object? testUrl = null,Object? timeout = null,}) {
  return _then(_TestDelayParams(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,testUrl: null == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String,timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as int,
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

 String get url; String get body; int get delay; List<String> get chains; String? get error;@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'route-version') int get routeVersion; List<RouteHit> get hits;@JsonKey(name: 'node-hits') List<RouteHit> get nodeHits;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboundIpResult&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.routeVersion, _this.routeVersion) || other.routeVersion == _this.routeVersion)&&const DeepCollectionEquality().equals(other.hits, _this.hits)&&const DeepCollectionEquality().equals(other.nodeHits, _this.nodeHits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboundIpResult;
  return Object.hash(runtimeType,_this.url,_this.body,_this.delay,const DeepCollectionEquality().hash(_this.chains),_this.error,_this.coreEpoch,_this.routeVersion,const DeepCollectionEquality().hash(_this.hits),const DeepCollectionEquality().hash(_this.nodeHits));
}

@override
String toString() {
  final _this = this as OutboundIpResult;
  return 'OutboundIpResult(url: ${_this.url}, body: ${_this.body}, delay: ${_this.delay}, chains: ${_this.chains}, error: ${_this.error}, coreEpoch: ${_this.coreEpoch}, routeVersion: ${_this.routeVersion}, hits: ${_this.hits}, nodeHits: ${_this.nodeHits})';
}


}

/// @nodoc
abstract mixin class $OutboundIpResultCopyWith<$Res>  {
  factory $OutboundIpResultCopyWith(OutboundIpResult value, $Res Function(OutboundIpResult) _then) = _$OutboundIpResultCopyWithImpl;
@useResult
$Res call({
 String url, String body, int delay, List<String> chains, String? error,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<RouteHit> hits,@JsonKey(name: 'node-hits') List<RouteHit> nodeHits
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
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? body = null,Object? delay = null,Object? chains = null,Object? error = freezed,Object? coreEpoch = null,Object? routeVersion = null,Object? hits = null,Object? nodeHits = null,}) {
  return _then(OutboundIpResult(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as List<RouteHit>,nodeHits: null == nodeHits ? _self.nodeHits : nodeHits // ignore: cast_nullable_to_non_nullable
as List<RouteHit>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String body,  int delay,  List<String> chains,  String? error, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits, @JsonKey(name: 'node-hits')  List<RouteHit> nodeHits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboundIpResult() when $default != null:
return $default(_that.url,_that.body,_that.delay,_that.chains,_that.error,_that.coreEpoch,_that.routeVersion,_that.hits,_that.nodeHits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String body,  int delay,  List<String> chains,  String? error, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits, @JsonKey(name: 'node-hits')  List<RouteHit> nodeHits)  $default,) {final _that = this;
switch (_that) {
case _OutboundIpResult():
return $default(_that.url,_that.body,_that.delay,_that.chains,_that.error,_that.coreEpoch,_that.routeVersion,_that.hits,_that.nodeHits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String body,  int delay,  List<String> chains,  String? error, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits, @JsonKey(name: 'node-hits')  List<RouteHit> nodeHits)?  $default,) {final _that = this;
switch (_that) {
case _OutboundIpResult() when $default != null:
return $default(_that.url,_that.body,_that.delay,_that.chains,_that.error,_that.coreEpoch,_that.routeVersion,_that.hits,_that.nodeHits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutboundIpResult implements OutboundIpResult {
  const _OutboundIpResult({this.url = '', this.body = '', this.delay = 0,  List<String> chains = const [], this.error, @JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'route-version') this.routeVersion = 0,  List<RouteHit> hits = const [], @JsonKey(name: 'node-hits')  List<RouteHit> nodeHits = const []}): _chains = chains,_hits = hits,_nodeHits = nodeHits;
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
@override@JsonKey(name: 'route-version') final  int routeVersion;
 final  List<RouteHit> _hits;
@override@JsonKey() List<RouteHit> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}

 final  List<RouteHit> _nodeHits;
@override@JsonKey(name: 'node-hits') List<RouteHit> get nodeHits {
  if (_nodeHits is EqualUnmodifiableListView) return _nodeHits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nodeHits);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboundIpResult&&(identical(other.url, url) || other.url == url)&&(identical(other.body, body) || other.body == body)&&(identical(other.delay, delay) || other.delay == delay)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.error, error) || other.error == error)&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.routeVersion, routeVersion) || other.routeVersion == routeVersion)&&const DeepCollectionEquality().equals(other.hits, _hits)&&const DeepCollectionEquality().equals(other.nodeHits, _nodeHits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,body,delay,const DeepCollectionEquality().hash(_chains),error,coreEpoch,routeVersion,const DeepCollectionEquality().hash(_hits),const DeepCollectionEquality().hash(_nodeHits));
}

@override
String toString() {
    return 'OutboundIpResult(url: $url, body: $body, delay: $delay, chains: $chains, error: $error, coreEpoch: $coreEpoch, routeVersion: $routeVersion, hits: $hits, nodeHits: $nodeHits)';
}


}

/// @nodoc
abstract mixin class _$OutboundIpResultCopyWith<$Res> implements $OutboundIpResultCopyWith<$Res> {
  factory _$OutboundIpResultCopyWith(_OutboundIpResult value, $Res Function(_OutboundIpResult) _then) = __$OutboundIpResultCopyWithImpl;
@override @useResult
$Res call({
 String url, String body, int delay, List<String> chains, String? error,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<RouteHit> hits,@JsonKey(name: 'node-hits') List<RouteHit> nodeHits
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
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? body = null,Object? delay = null,Object? chains = null,Object? error = freezed,Object? coreEpoch = null,Object? routeVersion = null,Object? hits = null,Object? nodeHits = null,}) {
  return _then(_OutboundIpResult(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<RouteHit>,nodeHits: null == nodeHits ? _self._nodeHits : nodeHits // ignore: cast_nullable_to_non_nullable
as List<RouteHit>,
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

 String get name; String get status; String get region; int get delay; List<String> get chains;@JsonKey(name: 'checked-at') int get checkedAt;@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'route-version') int get routeVersion; List<RouteHit> get hits;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceCheckItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.routeVersion, _this.routeVersion) || other.routeVersion == _this.routeVersion)&&const DeepCollectionEquality().equals(other.hits, _this.hits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceCheckItem;
  return Object.hash(runtimeType,_this.name,_this.status,_this.region,_this.delay,const DeepCollectionEquality().hash(_this.chains),_this.checkedAt,_this.coreEpoch,_this.routeVersion,const DeepCollectionEquality().hash(_this.hits));
}

@override
String toString() {
  final _this = this as ServiceCheckItem;
  return 'ServiceCheckItem(name: ${_this.name}, status: ${_this.status}, region: ${_this.region}, delay: ${_this.delay}, chains: ${_this.chains}, checkedAt: ${_this.checkedAt}, coreEpoch: ${_this.coreEpoch}, routeVersion: ${_this.routeVersion}, hits: ${_this.hits})';
}


}

/// @nodoc
abstract mixin class $ServiceCheckItemCopyWith<$Res>  {
  factory $ServiceCheckItemCopyWith(ServiceCheckItem value, $Res Function(ServiceCheckItem) _then) = _$ServiceCheckItemCopyWithImpl;
@useResult
$Res call({
 String name, String status, String region, int delay, List<String> chains,@JsonKey(name: 'checked-at') int checkedAt,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<RouteHit> hits
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? status = null,Object? region = null,Object? delay = null,Object? chains = null,Object? checkedAt = null,Object? coreEpoch = null,Object? routeVersion = null,Object? hits = null,}) {
  return _then(ServiceCheckItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as int,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as List<RouteHit>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String status,  String region,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
return $default(_that.name,_that.status,_that.region,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.routeVersion,_that.hits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String status,  String region,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits)  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckItem():
return $default(_that.name,_that.status,_that.region,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.routeVersion,_that.hits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String status,  String region,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits)?  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
return $default(_that.name,_that.status,_that.region,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.routeVersion,_that.hits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceCheckItem implements ServiceCheckItem {
  const _ServiceCheckItem({this.name = '', this.status = '', this.region = '', this.delay = 0,  List<String> chains = const [], @JsonKey(name: 'checked-at') this.checkedAt = 0, @JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'route-version') this.routeVersion = 0,  List<RouteHit> hits = const []}): _chains = chains,_hits = hits;
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
@override@JsonKey(name: 'route-version') final  int routeVersion;
 final  List<RouteHit> _hits;
@override@JsonKey() List<RouteHit> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceCheckItem&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.region, region) || other.region == region)&&(identical(other.delay, delay) || other.delay == delay)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.routeVersion, routeVersion) || other.routeVersion == routeVersion)&&const DeepCollectionEquality().equals(other.hits, _hits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,status,region,delay,const DeepCollectionEquality().hash(_chains),checkedAt,coreEpoch,routeVersion,const DeepCollectionEquality().hash(_hits));
}

@override
String toString() {
    return 'ServiceCheckItem(name: $name, status: $status, region: $region, delay: $delay, chains: $chains, checkedAt: $checkedAt, coreEpoch: $coreEpoch, routeVersion: $routeVersion, hits: $hits)';
}


}

/// @nodoc
abstract mixin class _$ServiceCheckItemCopyWith<$Res> implements $ServiceCheckItemCopyWith<$Res> {
  factory _$ServiceCheckItemCopyWith(_ServiceCheckItem value, $Res Function(_ServiceCheckItem) _then) = __$ServiceCheckItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String status, String region, int delay, List<String> chains,@JsonKey(name: 'checked-at') int checkedAt,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<RouteHit> hits
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? status = null,Object? region = null,Object? delay = null,Object? chains = null,Object? checkedAt = null,Object? coreEpoch = null,Object? routeVersion = null,Object? hits = null,}) {
  return _then(_ServiceCheckItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as int,coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<RouteHit>,
  ));
}


}


/// @nodoc
mixin _$CoreMemoryStats {

 int get rss;@JsonKey(name: 'heap-inuse') int get heapInuse;@JsonKey(name: 'heap-idle') int get heapIdle;@JsonKey(name: 'stack-inuse') int get stackInuse;@JsonKey(name: 'runtime-other') int get runtimeOther;
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
 int rss,@JsonKey(name: 'heap-inuse') int heapInuse,@JsonKey(name: 'heap-idle') int heapIdle,@JsonKey(name: 'stack-inuse') int stackInuse,@JsonKey(name: 'runtime-other') int runtimeOther
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rss, @JsonKey(name: 'heap-inuse')  int heapInuse, @JsonKey(name: 'heap-idle')  int heapIdle, @JsonKey(name: 'stack-inuse')  int stackInuse, @JsonKey(name: 'runtime-other')  int runtimeOther)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rss, @JsonKey(name: 'heap-inuse')  int heapInuse, @JsonKey(name: 'heap-idle')  int heapIdle, @JsonKey(name: 'stack-inuse')  int stackInuse, @JsonKey(name: 'runtime-other')  int runtimeOther)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rss, @JsonKey(name: 'heap-inuse')  int heapInuse, @JsonKey(name: 'heap-idle')  int heapIdle, @JsonKey(name: 'stack-inuse')  int stackInuse, @JsonKey(name: 'runtime-other')  int runtimeOther)?  $default,) {final _that = this;
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
  const _CoreMemoryStats({this.rss = 0, @JsonKey(name: 'heap-inuse') this.heapInuse = 0, @JsonKey(name: 'heap-idle') this.heapIdle = 0, @JsonKey(name: 'stack-inuse') this.stackInuse = 0, @JsonKey(name: 'runtime-other') this.runtimeOther = 0});
  factory _CoreMemoryStats.fromJson(Map<String, dynamic> json) => _$CoreMemoryStatsFromJson(json);

@override@JsonKey() final  int rss;
@override@JsonKey(name: 'heap-inuse') final  int heapInuse;
@override@JsonKey(name: 'heap-idle') final  int heapIdle;
@override@JsonKey(name: 'stack-inuse') final  int stackInuse;
@override@JsonKey(name: 'runtime-other') final  int runtimeOther;

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
 int rss,@JsonKey(name: 'heap-inuse') int heapInuse,@JsonKey(name: 'heap-idle') int heapIdle,@JsonKey(name: 'stack-inuse') int stackInuse,@JsonKey(name: 'runtime-other') int runtimeOther
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

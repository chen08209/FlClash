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

@JsonKey(includeToJson: false, includeFromJson: false) SetupBase? get base;@JsonKey(name: 'selection') Map<String, String> get selectedMap; CoreOptions get options;/// As `config.apply` takes it, since Android hands these params on as they are.
@JsonKey(includeIfNull: false) Map<String, Object?>? get host;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupParams&&(identical(other.base, _this.base) || other.base == _this.base)&&const DeepCollectionEquality().equals(other.selectedMap, _this.selectedMap)&&(identical(other.options, _this.options) || other.options == _this.options)&&const DeepCollectionEquality().equals(other.host, _this.host));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SetupParams;
  return Object.hash(runtimeType,_this.base,const DeepCollectionEquality().hash(_this.selectedMap),_this.options,const DeepCollectionEquality().hash(_this.host));
}

@override
String toString() {
  final _this = this as SetupParams;
  return 'SetupParams(base: ${_this.base}, selectedMap: ${_this.selectedMap}, options: ${_this.options}, host: ${_this.host})';
}


}

/// @nodoc
abstract mixin class $SetupParamsCopyWith<$Res>  {
  factory $SetupParamsCopyWith(SetupParams value, $Res Function(SetupParams) _then) = _$SetupParamsCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) SetupBase? base,@JsonKey(name: 'selection') Map<String, String> selectedMap, CoreOptions options,@JsonKey(includeIfNull: false) Map<String, Object?>? host
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
@pragma('vm:prefer-inline') @override $Res call({Object? base = freezed,Object? selectedMap = null,Object? options = null,Object? host = freezed,}) {
  return _then(SetupParams(
base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as SetupBase?,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as CoreOptions,host: freezed == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  SetupBase? base, @JsonKey(name: 'selection')  Map<String, String> selectedMap,  CoreOptions options, @JsonKey(includeIfNull: false)  Map<String, Object?>? host)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.base,_that.selectedMap,_that.options,_that.host);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false, includeFromJson: false)  SetupBase? base, @JsonKey(name: 'selection')  Map<String, String> selectedMap,  CoreOptions options, @JsonKey(includeIfNull: false)  Map<String, Object?>? host)  $default,) {final _that = this;
switch (_that) {
case _SetupParams():
return $default(_that.base,_that.selectedMap,_that.options,_that.host);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false, includeFromJson: false)  SetupBase? base, @JsonKey(name: 'selection')  Map<String, String> selectedMap,  CoreOptions options, @JsonKey(includeIfNull: false)  Map<String, Object?>? host)?  $default,) {final _that = this;
switch (_that) {
case _SetupParams() when $default != null:
return $default(_that.base,_that.selectedMap,_that.options,_that.host);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SetupParams implements SetupParams {
  const _SetupParams({@JsonKey(includeToJson: false, includeFromJson: false) this.base, @JsonKey(name: 'selection') required  Map<String, String> selectedMap, required this.options, @JsonKey(includeIfNull: false)  Map<String, Object?>? host}): _selectedMap = selectedMap,_host = host;
  factory _SetupParams.fromJson(Map<String, dynamic> json) => _$SetupParamsFromJson(json);

@override@JsonKey(includeToJson: false, includeFromJson: false) final  SetupBase? base;
 final  Map<String, String> _selectedMap;
@override@JsonKey(name: 'selection') Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override final  CoreOptions options;
/// As `config.apply` takes it, since Android hands these params on as they are.
 final  Map<String, Object?>? _host;
/// As `config.apply` takes it, since Android hands these params on as they are.
@override@JsonKey(includeIfNull: false) Map<String, Object?>? get host {
  final value = _host;
  if (value == null) return null;
  if (_host is EqualUnmodifiableMapView) return _host;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupParams&&(identical(other.base, base) || other.base == base)&&const DeepCollectionEquality().equals(other.selectedMap, _selectedMap)&&(identical(other.options, options) || other.options == options)&&const DeepCollectionEquality().equals(other.host, _host));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,base,const DeepCollectionEquality().hash(_selectedMap),options,const DeepCollectionEquality().hash(_host));
}

@override
String toString() {
    return 'SetupParams(base: $base, selectedMap: $selectedMap, options: $options, host: $host)';
}


}

/// @nodoc
abstract mixin class _$SetupParamsCopyWith<$Res> implements $SetupParamsCopyWith<$Res> {
  factory _$SetupParamsCopyWith(_SetupParams value, $Res Function(_SetupParams) _then) = __$SetupParamsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false, includeFromJson: false) SetupBase? base,@JsonKey(name: 'selection') Map<String, String> selectedMap, CoreOptions options,@JsonKey(includeIfNull: false) Map<String, Object?>? host
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
@override @pragma('vm:prefer-inline') $Res call({Object? base = freezed,Object? selectedMap = null,Object? options = null,Object? host = freezed,}) {
  return _then(_SetupParams(
base: freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as SetupBase?,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as CoreOptions,host: freezed == host ? _self._host : host // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,
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

 String get testUrl; bool get skipCertVerify; int get delayTestTimeout; bool get mitmCapture;
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
 String testUrl, bool skipCertVerify, int delayTestTimeout, bool mitmCapture
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String testUrl,  bool skipCertVerify,  int delayTestTimeout,  bool mitmCapture)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String testUrl,  bool skipCertVerify,  int delayTestTimeout,  bool mitmCapture)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String testUrl,  bool skipCertVerify,  int delayTestTimeout,  bool mitmCapture)?  $default,) {final _that = this;
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
  const _CoreOptions({required this.testUrl, this.skipCertVerify = false, this.delayTestTimeout = defaultDelayTestTimeout, this.mitmCapture = false});
  factory _CoreOptions.fromJson(Map<String, dynamic> json) => _$CoreOptionsFromJson(json);

@override final  String testUrl;
@override@JsonKey() final  bool skipCertVerify;
@override@JsonKey() final  int delayTestTimeout;
@override@JsonKey() final  bool mitmCapture;

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
 String testUrl, bool skipCertVerify, int delayTestTimeout, bool mitmCapture
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

 String get path; Map<String, dynamic> get overlay;
/// Create a copy of SetupBase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupBaseCopyWith<SetupBase> get copyWith => _$SetupBaseCopyWithImpl<SetupBase>(this as SetupBase, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SetupBase;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupBase&&(identical(other.path, _this.path) || other.path == _this.path)&&const DeepCollectionEquality().equals(other.overlay, _this.overlay));
}


@override
int get hashCode {
  final _this = this as SetupBase;
  return Object.hash(runtimeType,_this.path,const DeepCollectionEquality().hash(_this.overlay));
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
 String path, Map<String, dynamic> overlay
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
as Map<String, dynamic>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  Map<String, dynamic> overlay)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  Map<String, dynamic> overlay)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  Map<String, dynamic> overlay)?  $default,) {final _that = this;
switch (_that) {
case _SetupBase() when $default != null:
return $default(_that.path,_that.overlay);case _:
  return null;

}
}

}

/// @nodoc


class _SetupBase implements SetupBase {
  const _SetupBase({required this.path, required  Map<String, dynamic> overlay}): _overlay = overlay;
  

@override final  String path;
 final  Map<String, dynamic> _overlay;
@override Map<String, dynamic> get overlay {
  if (_overlay is EqualUnmodifiableMapView) return _overlay;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_overlay);
}


/// Create a copy of SetupBase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupBaseCopyWith<_SetupBase> get copyWith => __$SetupBaseCopyWithImpl<_SetupBase>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupBase&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.overlay, _overlay));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,const DeepCollectionEquality().hash(_overlay));
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
 String path, Map<String, dynamic> overlay
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
as String,overlay: null == overlay ? _self._overlay : overlay // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$ProfileBase {

 Map<String, dynamic> get config; String get digest; List<String> get matchRules; int get proxies; int get proxyGroups; int get rules;
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
 Map<String, dynamic> config, String digest, List<String> matchRules, int proxies, int proxyGroups, int rules
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> config,  String digest,  List<String> matchRules,  int proxies,  int proxyGroups,  int rules)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> config,  String digest,  List<String> matchRules,  int proxies,  int proxyGroups,  int rules)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> config,  String digest,  List<String> matchRules,  int proxies,  int proxyGroups,  int rules)?  $default,) {final _that = this;
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
  const _ProfileBase({required  Map<String, dynamic> config, required this.digest,  List<String> matchRules = const [], this.proxies = 0, this.proxyGroups = 0, this.rules = 0}): _config = config,_matchRules = matchRules;
  factory _ProfileBase.fromJson(Map<String, dynamic> json) => _$ProfileBaseFromJson(json);

 final  Map<String, dynamic> _config;
@override Map<String, dynamic> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}

@override final  String digest;
 final  List<String> _matchRules;
@override@JsonKey() List<String> get matchRules {
  if (_matchRules is EqualUnmodifiableListView) return _matchRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matchRules);
}

@override@JsonKey() final  int proxies;
@override@JsonKey() final  int proxyGroups;
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
 Map<String, dynamic> config, String digest, List<String> matchRules, int proxies, int proxyGroups, int rules
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

MitmLineView _$MitmLineViewFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'urlRewrite':
          return MitmUrlRewriteView.fromJson(
            json
          );
                case 'headerRewrite':
          return MitmHeaderRewriteView.fromJson(
            json
          );
                case 'bodyRewrite':
          return MitmBodyRewriteView.fromJson(
            json
          );
                case 'mapLocal':
          return MitmMapLocalView.fromJson(
            json
          );
                case 'script':
          return MitmScriptView.fromJson(
            json
          );
                case 'hosts':
          return MitmHostsView.fromJson(
            json
          );
                case 'sources':
          return MitmSourcesView.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'MitmLineView',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$MitmLineView {



  /// Serializes this MitmLineView to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmLineView);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MitmLineView()';
}


}

/// @nodoc
class $MitmLineViewCopyWith<$Res>  {
$MitmLineViewCopyWith(MitmLineView _, $Res Function(MitmLineView) __);
}


/// Adds pattern-matching-related methods to [MitmLineView].
extension MitmLineViewPatterns on MitmLineView {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MitmUrlRewriteView value)?  urlRewrite,TResult Function( MitmHeaderRewriteView value)?  headerRewrite,TResult Function( MitmBodyRewriteView value)?  bodyRewrite,TResult Function( MitmMapLocalView value)?  mapLocal,TResult Function( MitmScriptView value)?  script,TResult Function( MitmHostsView value)?  hosts,TResult Function( MitmSourcesView value)?  sources,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MitmUrlRewriteView() when urlRewrite != null:
return urlRewrite(_that);case MitmHeaderRewriteView() when headerRewrite != null:
return headerRewrite(_that);case MitmBodyRewriteView() when bodyRewrite != null:
return bodyRewrite(_that);case MitmMapLocalView() when mapLocal != null:
return mapLocal(_that);case MitmScriptView() when script != null:
return script(_that);case MitmHostsView() when hosts != null:
return hosts(_that);case MitmSourcesView() when sources != null:
return sources(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MitmUrlRewriteView value)  urlRewrite,required TResult Function( MitmHeaderRewriteView value)  headerRewrite,required TResult Function( MitmBodyRewriteView value)  bodyRewrite,required TResult Function( MitmMapLocalView value)  mapLocal,required TResult Function( MitmScriptView value)  script,required TResult Function( MitmHostsView value)  hosts,required TResult Function( MitmSourcesView value)  sources,}){
final _that = this;
switch (_that) {
case MitmUrlRewriteView():
return urlRewrite(_that);case MitmHeaderRewriteView():
return headerRewrite(_that);case MitmBodyRewriteView():
return bodyRewrite(_that);case MitmMapLocalView():
return mapLocal(_that);case MitmScriptView():
return script(_that);case MitmHostsView():
return hosts(_that);case MitmSourcesView():
return sources(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MitmUrlRewriteView value)?  urlRewrite,TResult? Function( MitmHeaderRewriteView value)?  headerRewrite,TResult? Function( MitmBodyRewriteView value)?  bodyRewrite,TResult? Function( MitmMapLocalView value)?  mapLocal,TResult? Function( MitmScriptView value)?  script,TResult? Function( MitmHostsView value)?  hosts,TResult? Function( MitmSourcesView value)?  sources,}){
final _that = this;
switch (_that) {
case MitmUrlRewriteView() when urlRewrite != null:
return urlRewrite(_that);case MitmHeaderRewriteView() when headerRewrite != null:
return headerRewrite(_that);case MitmBodyRewriteView() when bodyRewrite != null:
return bodyRewrite(_that);case MitmMapLocalView() when mapLocal != null:
return mapLocal(_that);case MitmScriptView() when script != null:
return script(_that);case MitmHostsView() when hosts != null:
return hosts(_that);case MitmSourcesView() when sources != null:
return sources(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String pattern,  String action,  String? replacement,  String? requestHead)?  urlRewrite,TResult Function( String phase,  String pattern,  String? requestHead,  String? responseHead,  String action,  String? name,  String? value,  String? regex,  String? replacement)?  headerRewrite,TResult Function( String phase,  String pattern,  String? requestHead,  String? responseHead,  List<MitmBodyReplacement> replacements,  String? jq)?  bodyRewrite,TResult Function( String pattern,  String? requestHead,  String dataType,  String data,  int? status,  List<MitmHeader> headers,  String contentType)?  mapLocal,TResult Function( String name,  String kind,  String path,  String? pattern,  String? cronexp,  String? event,  bool requiresBody,  int? timeoutMs)?  script,TResult Function( List<MitmHostEntry> entries)?  hosts,TResult Function( List<MitmSourceEntry> entries)?  sources,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MitmUrlRewriteView() when urlRewrite != null:
return urlRewrite(_that.pattern,_that.action,_that.replacement,_that.requestHead);case MitmHeaderRewriteView() when headerRewrite != null:
return headerRewrite(_that.phase,_that.pattern,_that.requestHead,_that.responseHead,_that.action,_that.name,_that.value,_that.regex,_that.replacement);case MitmBodyRewriteView() when bodyRewrite != null:
return bodyRewrite(_that.phase,_that.pattern,_that.requestHead,_that.responseHead,_that.replacements,_that.jq);case MitmMapLocalView() when mapLocal != null:
return mapLocal(_that.pattern,_that.requestHead,_that.dataType,_that.data,_that.status,_that.headers,_that.contentType);case MitmScriptView() when script != null:
return script(_that.name,_that.kind,_that.path,_that.pattern,_that.cronexp,_that.event,_that.requiresBody,_that.timeoutMs);case MitmHostsView() when hosts != null:
return hosts(_that.entries);case MitmSourcesView() when sources != null:
return sources(_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String pattern,  String action,  String? replacement,  String? requestHead)  urlRewrite,required TResult Function( String phase,  String pattern,  String? requestHead,  String? responseHead,  String action,  String? name,  String? value,  String? regex,  String? replacement)  headerRewrite,required TResult Function( String phase,  String pattern,  String? requestHead,  String? responseHead,  List<MitmBodyReplacement> replacements,  String? jq)  bodyRewrite,required TResult Function( String pattern,  String? requestHead,  String dataType,  String data,  int? status,  List<MitmHeader> headers,  String contentType)  mapLocal,required TResult Function( String name,  String kind,  String path,  String? pattern,  String? cronexp,  String? event,  bool requiresBody,  int? timeoutMs)  script,required TResult Function( List<MitmHostEntry> entries)  hosts,required TResult Function( List<MitmSourceEntry> entries)  sources,}) {final _that = this;
switch (_that) {
case MitmUrlRewriteView():
return urlRewrite(_that.pattern,_that.action,_that.replacement,_that.requestHead);case MitmHeaderRewriteView():
return headerRewrite(_that.phase,_that.pattern,_that.requestHead,_that.responseHead,_that.action,_that.name,_that.value,_that.regex,_that.replacement);case MitmBodyRewriteView():
return bodyRewrite(_that.phase,_that.pattern,_that.requestHead,_that.responseHead,_that.replacements,_that.jq);case MitmMapLocalView():
return mapLocal(_that.pattern,_that.requestHead,_that.dataType,_that.data,_that.status,_that.headers,_that.contentType);case MitmScriptView():
return script(_that.name,_that.kind,_that.path,_that.pattern,_that.cronexp,_that.event,_that.requiresBody,_that.timeoutMs);case MitmHostsView():
return hosts(_that.entries);case MitmSourcesView():
return sources(_that.entries);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String pattern,  String action,  String? replacement,  String? requestHead)?  urlRewrite,TResult? Function( String phase,  String pattern,  String? requestHead,  String? responseHead,  String action,  String? name,  String? value,  String? regex,  String? replacement)?  headerRewrite,TResult? Function( String phase,  String pattern,  String? requestHead,  String? responseHead,  List<MitmBodyReplacement> replacements,  String? jq)?  bodyRewrite,TResult? Function( String pattern,  String? requestHead,  String dataType,  String data,  int? status,  List<MitmHeader> headers,  String contentType)?  mapLocal,TResult? Function( String name,  String kind,  String path,  String? pattern,  String? cronexp,  String? event,  bool requiresBody,  int? timeoutMs)?  script,TResult? Function( List<MitmHostEntry> entries)?  hosts,TResult? Function( List<MitmSourceEntry> entries)?  sources,}) {final _that = this;
switch (_that) {
case MitmUrlRewriteView() when urlRewrite != null:
return urlRewrite(_that.pattern,_that.action,_that.replacement,_that.requestHead);case MitmHeaderRewriteView() when headerRewrite != null:
return headerRewrite(_that.phase,_that.pattern,_that.requestHead,_that.responseHead,_that.action,_that.name,_that.value,_that.regex,_that.replacement);case MitmBodyRewriteView() when bodyRewrite != null:
return bodyRewrite(_that.phase,_that.pattern,_that.requestHead,_that.responseHead,_that.replacements,_that.jq);case MitmMapLocalView() when mapLocal != null:
return mapLocal(_that.pattern,_that.requestHead,_that.dataType,_that.data,_that.status,_that.headers,_that.contentType);case MitmScriptView() when script != null:
return script(_that.name,_that.kind,_that.path,_that.pattern,_that.cronexp,_that.event,_that.requiresBody,_that.timeoutMs);case MitmHostsView() when hosts != null:
return hosts(_that.entries);case MitmSourcesView() when sources != null:
return sources(_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class MitmUrlRewriteView implements MitmLineView {
  const MitmUrlRewriteView({required this.pattern, required this.action, this.replacement, this.requestHead,  String? $type}): $type = $type ?? 'urlRewrite';
  factory MitmUrlRewriteView.fromJson(Map<String, dynamic> json) => _$MitmUrlRewriteViewFromJson(json);

 final  String pattern;
 final  String action;
 final  String? replacement;
 final  String? requestHead;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmUrlRewriteViewCopyWith<MitmUrlRewriteView> get copyWith => _$MitmUrlRewriteViewCopyWithImpl<MitmUrlRewriteView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmUrlRewriteViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmUrlRewriteView&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.action, action) || other.action == action)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.requestHead, requestHead) || other.requestHead == requestHead));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pattern,action,replacement,requestHead);
}

@override
String toString() {
    return 'MitmLineView.urlRewrite(pattern: $pattern, action: $action, replacement: $replacement, requestHead: $requestHead)';
}


}

/// @nodoc
abstract mixin class $MitmUrlRewriteViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmUrlRewriteViewCopyWith(MitmUrlRewriteView value, $Res Function(MitmUrlRewriteView) _then) = _$MitmUrlRewriteViewCopyWithImpl;
@useResult
$Res call({
 String pattern, String action, String? replacement, String? requestHead
});




}
/// @nodoc
class _$MitmUrlRewriteViewCopyWithImpl<$Res>
    implements $MitmUrlRewriteViewCopyWith<$Res> {
  _$MitmUrlRewriteViewCopyWithImpl(this._self, this._then);

  final MitmUrlRewriteView _self;
  final $Res Function(MitmUrlRewriteView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pattern = null,Object? action = null,Object? replacement = freezed,Object? requestHead = freezed,}) {
  return _then(MitmUrlRewriteView(
pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String?,requestHead: freezed == requestHead ? _self.requestHead : requestHead // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MitmHeaderRewriteView implements MitmLineView {
  const MitmHeaderRewriteView({required this.phase, required this.pattern, this.requestHead, this.responseHead, required this.action, this.name, this.value, this.regex, this.replacement,  String? $type}): $type = $type ?? 'headerRewrite';
  factory MitmHeaderRewriteView.fromJson(Map<String, dynamic> json) => _$MitmHeaderRewriteViewFromJson(json);

 final  String phase;
 final  String pattern;
 final  String? requestHead;
 final  String? responseHead;
 final  String action;
 final  String? name;
 final  String? value;
 final  String? regex;
 final  String? replacement;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmHeaderRewriteViewCopyWith<MitmHeaderRewriteView> get copyWith => _$MitmHeaderRewriteViewCopyWithImpl<MitmHeaderRewriteView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmHeaderRewriteViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmHeaderRewriteView&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.requestHead, requestHead) || other.requestHead == requestHead)&&(identical(other.responseHead, responseHead) || other.responseHead == responseHead)&&(identical(other.action, action) || other.action == action)&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.regex, regex) || other.regex == regex)&&(identical(other.replacement, replacement) || other.replacement == replacement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,phase,pattern,requestHead,responseHead,action,name,value,regex,replacement);
}

@override
String toString() {
    return 'MitmLineView.headerRewrite(phase: $phase, pattern: $pattern, requestHead: $requestHead, responseHead: $responseHead, action: $action, name: $name, value: $value, regex: $regex, replacement: $replacement)';
}


}

/// @nodoc
abstract mixin class $MitmHeaderRewriteViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmHeaderRewriteViewCopyWith(MitmHeaderRewriteView value, $Res Function(MitmHeaderRewriteView) _then) = _$MitmHeaderRewriteViewCopyWithImpl;
@useResult
$Res call({
 String phase, String pattern, String? requestHead, String? responseHead, String action, String? name, String? value, String? regex, String? replacement
});




}
/// @nodoc
class _$MitmHeaderRewriteViewCopyWithImpl<$Res>
    implements $MitmHeaderRewriteViewCopyWith<$Res> {
  _$MitmHeaderRewriteViewCopyWithImpl(this._self, this._then);

  final MitmHeaderRewriteView _self;
  final $Res Function(MitmHeaderRewriteView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? pattern = null,Object? requestHead = freezed,Object? responseHead = freezed,Object? action = null,Object? name = freezed,Object? value = freezed,Object? regex = freezed,Object? replacement = freezed,}) {
  return _then(MitmHeaderRewriteView(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,requestHead: freezed == requestHead ? _self.requestHead : requestHead // ignore: cast_nullable_to_non_nullable
as String?,responseHead: freezed == responseHead ? _self.responseHead : responseHead // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,regex: freezed == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String?,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MitmBodyRewriteView implements MitmLineView {
  const MitmBodyRewriteView({required this.phase, required this.pattern, this.requestHead, this.responseHead,  List<MitmBodyReplacement> replacements = const [], this.jq,  String? $type}): _replacements = replacements,$type = $type ?? 'bodyRewrite';
  factory MitmBodyRewriteView.fromJson(Map<String, dynamic> json) => _$MitmBodyRewriteViewFromJson(json);

 final  String phase;
 final  String pattern;
 final  String? requestHead;
 final  String? responseHead;
 final  List<MitmBodyReplacement> _replacements;
@JsonKey() List<MitmBodyReplacement> get replacements {
  if (_replacements is EqualUnmodifiableListView) return _replacements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_replacements);
}

 final  String? jq;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmBodyRewriteViewCopyWith<MitmBodyRewriteView> get copyWith => _$MitmBodyRewriteViewCopyWithImpl<MitmBodyRewriteView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmBodyRewriteViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmBodyRewriteView&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.requestHead, requestHead) || other.requestHead == requestHead)&&(identical(other.responseHead, responseHead) || other.responseHead == responseHead)&&const DeepCollectionEquality().equals(other.replacements, _replacements)&&(identical(other.jq, jq) || other.jq == jq));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,phase,pattern,requestHead,responseHead,const DeepCollectionEquality().hash(_replacements),jq);
}

@override
String toString() {
    return 'MitmLineView.bodyRewrite(phase: $phase, pattern: $pattern, requestHead: $requestHead, responseHead: $responseHead, replacements: $replacements, jq: $jq)';
}


}

/// @nodoc
abstract mixin class $MitmBodyRewriteViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmBodyRewriteViewCopyWith(MitmBodyRewriteView value, $Res Function(MitmBodyRewriteView) _then) = _$MitmBodyRewriteViewCopyWithImpl;
@useResult
$Res call({
 String phase, String pattern, String? requestHead, String? responseHead, List<MitmBodyReplacement> replacements, String? jq
});




}
/// @nodoc
class _$MitmBodyRewriteViewCopyWithImpl<$Res>
    implements $MitmBodyRewriteViewCopyWith<$Res> {
  _$MitmBodyRewriteViewCopyWithImpl(this._self, this._then);

  final MitmBodyRewriteView _self;
  final $Res Function(MitmBodyRewriteView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? pattern = null,Object? requestHead = freezed,Object? responseHead = freezed,Object? replacements = null,Object? jq = freezed,}) {
  return _then(MitmBodyRewriteView(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,requestHead: freezed == requestHead ? _self.requestHead : requestHead // ignore: cast_nullable_to_non_nullable
as String?,responseHead: freezed == responseHead ? _self.responseHead : responseHead // ignore: cast_nullable_to_non_nullable
as String?,replacements: null == replacements ? _self._replacements : replacements // ignore: cast_nullable_to_non_nullable
as List<MitmBodyReplacement>,jq: freezed == jq ? _self.jq : jq // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MitmMapLocalView implements MitmLineView {
  const MitmMapLocalView({required this.pattern, this.requestHead, required this.dataType, this.data = '', this.status,  List<MitmHeader> headers = const [], this.contentType = '',  String? $type}): _headers = headers,$type = $type ?? 'mapLocal';
  factory MitmMapLocalView.fromJson(Map<String, dynamic> json) => _$MitmMapLocalViewFromJson(json);

 final  String pattern;
 final  String? requestHead;
 final  String dataType;
@JsonKey() final  String data;
 final  int? status;
 final  List<MitmHeader> _headers;
@JsonKey() List<MitmHeader> get headers {
  if (_headers is EqualUnmodifiableListView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headers);
}

@JsonKey() final  String contentType;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmMapLocalViewCopyWith<MitmMapLocalView> get copyWith => _$MitmMapLocalViewCopyWithImpl<MitmMapLocalView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmMapLocalViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmMapLocalView&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.requestHead, requestHead) || other.requestHead == requestHead)&&(identical(other.dataType, dataType) || other.dataType == dataType)&&(identical(other.data, data) || other.data == data)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.contentType, contentType) || other.contentType == contentType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,pattern,requestHead,dataType,data,status,const DeepCollectionEquality().hash(_headers),contentType);
}

@override
String toString() {
    return 'MitmLineView.mapLocal(pattern: $pattern, requestHead: $requestHead, dataType: $dataType, data: $data, status: $status, headers: $headers, contentType: $contentType)';
}


}

/// @nodoc
abstract mixin class $MitmMapLocalViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmMapLocalViewCopyWith(MitmMapLocalView value, $Res Function(MitmMapLocalView) _then) = _$MitmMapLocalViewCopyWithImpl;
@useResult
$Res call({
 String pattern, String? requestHead, String dataType, String data, int? status, List<MitmHeader> headers, String contentType
});




}
/// @nodoc
class _$MitmMapLocalViewCopyWithImpl<$Res>
    implements $MitmMapLocalViewCopyWith<$Res> {
  _$MitmMapLocalViewCopyWithImpl(this._self, this._then);

  final MitmMapLocalView _self;
  final $Res Function(MitmMapLocalView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? pattern = null,Object? requestHead = freezed,Object? dataType = null,Object? data = null,Object? status = freezed,Object? headers = null,Object? contentType = null,}) {
  return _then(MitmMapLocalView(
pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,requestHead: freezed == requestHead ? _self.requestHead : requestHead // ignore: cast_nullable_to_non_nullable
as String?,dataType: null == dataType ? _self.dataType : dataType // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int?,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as List<MitmHeader>,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MitmScriptView implements MitmLineView {
  const MitmScriptView({required this.name, required this.kind, this.path = '', this.pattern, this.cronexp, this.event, this.requiresBody = false, this.timeoutMs,  String? $type}): $type = $type ?? 'script';
  factory MitmScriptView.fromJson(Map<String, dynamic> json) => _$MitmScriptViewFromJson(json);

 final  String name;
 final  String kind;
@JsonKey() final  String path;
 final  String? pattern;
 final  String? cronexp;
 final  String? event;
@JsonKey() final  bool requiresBody;
 final  int? timeoutMs;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmScriptViewCopyWith<MitmScriptView> get copyWith => _$MitmScriptViewCopyWithImpl<MitmScriptView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmScriptViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmScriptView&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.path, path) || other.path == path)&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.cronexp, cronexp) || other.cronexp == cronexp)&&(identical(other.event, event) || other.event == event)&&(identical(other.requiresBody, requiresBody) || other.requiresBody == requiresBody)&&(identical(other.timeoutMs, timeoutMs) || other.timeoutMs == timeoutMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,kind,path,pattern,cronexp,event,requiresBody,timeoutMs);
}

@override
String toString() {
    return 'MitmLineView.script(name: $name, kind: $kind, path: $path, pattern: $pattern, cronexp: $cronexp, event: $event, requiresBody: $requiresBody, timeoutMs: $timeoutMs)';
}


}

/// @nodoc
abstract mixin class $MitmScriptViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmScriptViewCopyWith(MitmScriptView value, $Res Function(MitmScriptView) _then) = _$MitmScriptViewCopyWithImpl;
@useResult
$Res call({
 String name, String kind, String path, String? pattern, String? cronexp, String? event, bool requiresBody, int? timeoutMs
});




}
/// @nodoc
class _$MitmScriptViewCopyWithImpl<$Res>
    implements $MitmScriptViewCopyWith<$Res> {
  _$MitmScriptViewCopyWithImpl(this._self, this._then);

  final MitmScriptView _self;
  final $Res Function(MitmScriptView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? kind = null,Object? path = null,Object? pattern = freezed,Object? cronexp = freezed,Object? event = freezed,Object? requiresBody = null,Object? timeoutMs = freezed,}) {
  return _then(MitmScriptView(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,cronexp: freezed == cronexp ? _self.cronexp : cronexp // ignore: cast_nullable_to_non_nullable
as String?,event: freezed == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String?,requiresBody: null == requiresBody ? _self.requiresBody : requiresBody // ignore: cast_nullable_to_non_nullable
as bool,timeoutMs: freezed == timeoutMs ? _self.timeoutMs : timeoutMs // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MitmHostsView implements MitmLineView {
  const MitmHostsView({ List<MitmHostEntry> entries = const [],  String? $type}): _entries = entries,$type = $type ?? 'hosts';
  factory MitmHostsView.fromJson(Map<String, dynamic> json) => _$MitmHostsViewFromJson(json);

 final  List<MitmHostEntry> _entries;
@JsonKey() List<MitmHostEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmHostsViewCopyWith<MitmHostsView> get copyWith => _$MitmHostsViewCopyWithImpl<MitmHostsView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmHostsViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmHostsView&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'MitmLineView.hosts(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $MitmHostsViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmHostsViewCopyWith(MitmHostsView value, $Res Function(MitmHostsView) _then) = _$MitmHostsViewCopyWithImpl;
@useResult
$Res call({
 List<MitmHostEntry> entries
});




}
/// @nodoc
class _$MitmHostsViewCopyWithImpl<$Res>
    implements $MitmHostsViewCopyWith<$Res> {
  _$MitmHostsViewCopyWithImpl(this._self, this._then);

  final MitmHostsView _self;
  final $Res Function(MitmHostsView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(MitmHostsView(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<MitmHostEntry>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class MitmSourcesView implements MitmLineView {
  const MitmSourcesView({ List<MitmSourceEntry> entries = const [],  String? $type}): _entries = entries,$type = $type ?? 'sources';
  factory MitmSourcesView.fromJson(Map<String, dynamic> json) => _$MitmSourcesViewFromJson(json);

 final  List<MitmSourceEntry> _entries;
@JsonKey() List<MitmSourceEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmSourcesViewCopyWith<MitmSourcesView> get copyWith => _$MitmSourcesViewCopyWithImpl<MitmSourcesView>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmSourcesViewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmSourcesView&&const DeepCollectionEquality().equals(other.entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'MitmLineView.sources(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $MitmSourcesViewCopyWith<$Res> implements $MitmLineViewCopyWith<$Res> {
  factory $MitmSourcesViewCopyWith(MitmSourcesView value, $Res Function(MitmSourcesView) _then) = _$MitmSourcesViewCopyWithImpl;
@useResult
$Res call({
 List<MitmSourceEntry> entries
});




}
/// @nodoc
class _$MitmSourcesViewCopyWithImpl<$Res>
    implements $MitmSourcesViewCopyWith<$Res> {
  _$MitmSourcesViewCopyWithImpl(this._self, this._then);

  final MitmSourcesView _self;
  final $Res Function(MitmSourcesView) _then;

/// Create a copy of MitmLineView
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(MitmSourcesView(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<MitmSourceEntry>,
  ));
}


}


/// @nodoc
mixin _$MitmBodyReplacement {

 String get regex; String get replacement;
/// Create a copy of MitmBodyReplacement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmBodyReplacementCopyWith<MitmBodyReplacement> get copyWith => _$MitmBodyReplacementCopyWithImpl<MitmBodyReplacement>(this as MitmBodyReplacement, _$identity);

  /// Serializes this MitmBodyReplacement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmBodyReplacement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmBodyReplacement&&(identical(other.regex, _this.regex) || other.regex == _this.regex)&&(identical(other.replacement, _this.replacement) || other.replacement == _this.replacement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmBodyReplacement;
  return Object.hash(runtimeType,_this.regex,_this.replacement);
}

@override
String toString() {
  final _this = this as MitmBodyReplacement;
  return 'MitmBodyReplacement(regex: ${_this.regex}, replacement: ${_this.replacement})';
}


}

/// @nodoc
abstract mixin class $MitmBodyReplacementCopyWith<$Res>  {
  factory $MitmBodyReplacementCopyWith(MitmBodyReplacement value, $Res Function(MitmBodyReplacement) _then) = _$MitmBodyReplacementCopyWithImpl;
@useResult
$Res call({
 String regex, String replacement
});




}
/// @nodoc
class _$MitmBodyReplacementCopyWithImpl<$Res>
    implements $MitmBodyReplacementCopyWith<$Res> {
  _$MitmBodyReplacementCopyWithImpl(this._self, this._then);

  final MitmBodyReplacement _self;
  final $Res Function(MitmBodyReplacement) _then;

/// Create a copy of MitmBodyReplacement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? regex = null,Object? replacement = null,}) {
  return _then(MitmBodyReplacement(
regex: null == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String,replacement: null == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmBodyReplacement].
extension MitmBodyReplacementPatterns on MitmBodyReplacement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmBodyReplacement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmBodyReplacement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmBodyReplacement value)  $default,){
final _that = this;
switch (_that) {
case _MitmBodyReplacement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmBodyReplacement value)?  $default,){
final _that = this;
switch (_that) {
case _MitmBodyReplacement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String regex,  String replacement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmBodyReplacement() when $default != null:
return $default(_that.regex,_that.replacement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String regex,  String replacement)  $default,) {final _that = this;
switch (_that) {
case _MitmBodyReplacement():
return $default(_that.regex,_that.replacement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String regex,  String replacement)?  $default,) {final _that = this;
switch (_that) {
case _MitmBodyReplacement() when $default != null:
return $default(_that.regex,_that.replacement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmBodyReplacement implements MitmBodyReplacement {
  const _MitmBodyReplacement({required this.regex, required this.replacement});
  factory _MitmBodyReplacement.fromJson(Map<String, dynamic> json) => _$MitmBodyReplacementFromJson(json);

@override final  String regex;
@override final  String replacement;

/// Create a copy of MitmBodyReplacement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmBodyReplacementCopyWith<_MitmBodyReplacement> get copyWith => __$MitmBodyReplacementCopyWithImpl<_MitmBodyReplacement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmBodyReplacementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmBodyReplacement&&(identical(other.regex, regex) || other.regex == regex)&&(identical(other.replacement, replacement) || other.replacement == replacement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,regex,replacement);
}

@override
String toString() {
    return 'MitmBodyReplacement(regex: $regex, replacement: $replacement)';
}


}

/// @nodoc
abstract mixin class _$MitmBodyReplacementCopyWith<$Res> implements $MitmBodyReplacementCopyWith<$Res> {
  factory _$MitmBodyReplacementCopyWith(_MitmBodyReplacement value, $Res Function(_MitmBodyReplacement) _then) = __$MitmBodyReplacementCopyWithImpl;
@override @useResult
$Res call({
 String regex, String replacement
});




}
/// @nodoc
class __$MitmBodyReplacementCopyWithImpl<$Res>
    implements _$MitmBodyReplacementCopyWith<$Res> {
  __$MitmBodyReplacementCopyWithImpl(this._self, this._then);

  final _MitmBodyReplacement _self;
  final $Res Function(_MitmBodyReplacement) _then;

/// Create a copy of MitmBodyReplacement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? regex = null,Object? replacement = null,}) {
  return _then(_MitmBodyReplacement(
regex: null == regex ? _self.regex : regex // ignore: cast_nullable_to_non_nullable
as String,replacement: null == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MitmHeader {

 String get name; String get value;
/// Create a copy of MitmHeader
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmHeaderCopyWith<MitmHeader> get copyWith => _$MitmHeaderCopyWithImpl<MitmHeader>(this as MitmHeader, _$identity);

  /// Serializes this MitmHeader to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmHeader;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmHeader&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.value, _this.value) || other.value == _this.value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmHeader;
  return Object.hash(runtimeType,_this.name,_this.value);
}

@override
String toString() {
  final _this = this as MitmHeader;
  return 'MitmHeader(name: ${_this.name}, value: ${_this.value})';
}


}

/// @nodoc
abstract mixin class $MitmHeaderCopyWith<$Res>  {
  factory $MitmHeaderCopyWith(MitmHeader value, $Res Function(MitmHeader) _then) = _$MitmHeaderCopyWithImpl;
@useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class _$MitmHeaderCopyWithImpl<$Res>
    implements $MitmHeaderCopyWith<$Res> {
  _$MitmHeaderCopyWithImpl(this._self, this._then);

  final MitmHeader _self;
  final $Res Function(MitmHeader) _then;

/// Create a copy of MitmHeader
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? value = null,}) {
  return _then(MitmHeader(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmHeader].
extension MitmHeaderPatterns on MitmHeader {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmHeader value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmHeader() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmHeader value)  $default,){
final _that = this;
switch (_that) {
case _MitmHeader():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmHeader value)?  $default,){
final _that = this;
switch (_that) {
case _MitmHeader() when $default != null:
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
case _MitmHeader() when $default != null:
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
case _MitmHeader():
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
case _MitmHeader() when $default != null:
return $default(_that.name,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmHeader implements MitmHeader {
  const _MitmHeader({required this.name, required this.value});
  factory _MitmHeader.fromJson(Map<String, dynamic> json) => _$MitmHeaderFromJson(json);

@override final  String name;
@override final  String value;

/// Create a copy of MitmHeader
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmHeaderCopyWith<_MitmHeader> get copyWith => __$MitmHeaderCopyWithImpl<_MitmHeader>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmHeaderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmHeader&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,value);
}

@override
String toString() {
    return 'MitmHeader(name: $name, value: $value)';
}


}

/// @nodoc
abstract mixin class _$MitmHeaderCopyWith<$Res> implements $MitmHeaderCopyWith<$Res> {
  factory _$MitmHeaderCopyWith(_MitmHeader value, $Res Function(_MitmHeader) _then) = __$MitmHeaderCopyWithImpl;
@override @useResult
$Res call({
 String name, String value
});




}
/// @nodoc
class __$MitmHeaderCopyWithImpl<$Res>
    implements _$MitmHeaderCopyWith<$Res> {
  __$MitmHeaderCopyWithImpl(this._self, this._then);

  final _MitmHeader _self;
  final $Res Function(_MitmHeader) _then;

/// Create a copy of MitmHeader
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,}) {
  return _then(_MitmHeader(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MitmHostEntry {

 String get host; int? get port; bool get exclude;
/// Create a copy of MitmHostEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmHostEntryCopyWith<MitmHostEntry> get copyWith => _$MitmHostEntryCopyWithImpl<MitmHostEntry>(this as MitmHostEntry, _$identity);

  /// Serializes this MitmHostEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmHostEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmHostEntry&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.exclude, _this.exclude) || other.exclude == _this.exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmHostEntry;
  return Object.hash(runtimeType,_this.host,_this.port,_this.exclude);
}

@override
String toString() {
  final _this = this as MitmHostEntry;
  return 'MitmHostEntry(host: ${_this.host}, port: ${_this.port}, exclude: ${_this.exclude})';
}


}

/// @nodoc
abstract mixin class $MitmHostEntryCopyWith<$Res>  {
  factory $MitmHostEntryCopyWith(MitmHostEntry value, $Res Function(MitmHostEntry) _then) = _$MitmHostEntryCopyWithImpl;
@useResult
$Res call({
 String host, int? port, bool exclude
});




}
/// @nodoc
class _$MitmHostEntryCopyWithImpl<$Res>
    implements $MitmHostEntryCopyWith<$Res> {
  _$MitmHostEntryCopyWithImpl(this._self, this._then);

  final MitmHostEntry _self;
  final $Res Function(MitmHostEntry) _then;

/// Create a copy of MitmHostEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? port = freezed,Object? exclude = null,}) {
  return _then(MitmHostEntry(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmHostEntry].
extension MitmHostEntryPatterns on MitmHostEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmHostEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmHostEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmHostEntry value)  $default,){
final _that = this;
switch (_that) {
case _MitmHostEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmHostEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MitmHostEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String host,  int? port,  bool exclude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmHostEntry() when $default != null:
return $default(_that.host,_that.port,_that.exclude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String host,  int? port,  bool exclude)  $default,) {final _that = this;
switch (_that) {
case _MitmHostEntry():
return $default(_that.host,_that.port,_that.exclude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String host,  int? port,  bool exclude)?  $default,) {final _that = this;
switch (_that) {
case _MitmHostEntry() when $default != null:
return $default(_that.host,_that.port,_that.exclude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmHostEntry implements MitmHostEntry {
  const _MitmHostEntry({required this.host, this.port, this.exclude = false});
  factory _MitmHostEntry.fromJson(Map<String, dynamic> json) => _$MitmHostEntryFromJson(json);

@override final  String host;
@override final  int? port;
@override@JsonKey() final  bool exclude;

/// Create a copy of MitmHostEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmHostEntryCopyWith<_MitmHostEntry> get copyWith => __$MitmHostEntryCopyWithImpl<_MitmHostEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmHostEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmHostEntry&&(identical(other.host, host) || other.host == host)&&(identical(other.port, port) || other.port == port)&&(identical(other.exclude, exclude) || other.exclude == exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,host,port,exclude);
}

@override
String toString() {
    return 'MitmHostEntry(host: $host, port: $port, exclude: $exclude)';
}


}

/// @nodoc
abstract mixin class _$MitmHostEntryCopyWith<$Res> implements $MitmHostEntryCopyWith<$Res> {
  factory _$MitmHostEntryCopyWith(_MitmHostEntry value, $Res Function(_MitmHostEntry) _then) = __$MitmHostEntryCopyWithImpl;
@override @useResult
$Res call({
 String host, int? port, bool exclude
});




}
/// @nodoc
class __$MitmHostEntryCopyWithImpl<$Res>
    implements _$MitmHostEntryCopyWith<$Res> {
  __$MitmHostEntryCopyWithImpl(this._self, this._then);

  final _MitmHostEntry _self;
  final $Res Function(_MitmHostEntry) _then;

/// Create a copy of MitmHostEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? port = freezed,Object? exclude = null,}) {
  return _then(_MitmHostEntry(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,port: freezed == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int?,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MitmSourceEntry {

 String get network; bool get exclude;
/// Create a copy of MitmSourceEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmSourceEntryCopyWith<MitmSourceEntry> get copyWith => _$MitmSourceEntryCopyWithImpl<MitmSourceEntry>(this as MitmSourceEntry, _$identity);

  /// Serializes this MitmSourceEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmSourceEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmSourceEntry&&(identical(other.network, _this.network) || other.network == _this.network)&&(identical(other.exclude, _this.exclude) || other.exclude == _this.exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmSourceEntry;
  return Object.hash(runtimeType,_this.network,_this.exclude);
}

@override
String toString() {
  final _this = this as MitmSourceEntry;
  return 'MitmSourceEntry(network: ${_this.network}, exclude: ${_this.exclude})';
}


}

/// @nodoc
abstract mixin class $MitmSourceEntryCopyWith<$Res>  {
  factory $MitmSourceEntryCopyWith(MitmSourceEntry value, $Res Function(MitmSourceEntry) _then) = _$MitmSourceEntryCopyWithImpl;
@useResult
$Res call({
 String network, bool exclude
});




}
/// @nodoc
class _$MitmSourceEntryCopyWithImpl<$Res>
    implements $MitmSourceEntryCopyWith<$Res> {
  _$MitmSourceEntryCopyWithImpl(this._self, this._then);

  final MitmSourceEntry _self;
  final $Res Function(MitmSourceEntry) _then;

/// Create a copy of MitmSourceEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? network = null,Object? exclude = null,}) {
  return _then(MitmSourceEntry(
network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmSourceEntry].
extension MitmSourceEntryPatterns on MitmSourceEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmSourceEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmSourceEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmSourceEntry value)  $default,){
final _that = this;
switch (_that) {
case _MitmSourceEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmSourceEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MitmSourceEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String network,  bool exclude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmSourceEntry() when $default != null:
return $default(_that.network,_that.exclude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String network,  bool exclude)  $default,) {final _that = this;
switch (_that) {
case _MitmSourceEntry():
return $default(_that.network,_that.exclude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String network,  bool exclude)?  $default,) {final _that = this;
switch (_that) {
case _MitmSourceEntry() when $default != null:
return $default(_that.network,_that.exclude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmSourceEntry implements MitmSourceEntry {
  const _MitmSourceEntry({required this.network, this.exclude = false});
  factory _MitmSourceEntry.fromJson(Map<String, dynamic> json) => _$MitmSourceEntryFromJson(json);

@override final  String network;
@override@JsonKey() final  bool exclude;

/// Create a copy of MitmSourceEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmSourceEntryCopyWith<_MitmSourceEntry> get copyWith => __$MitmSourceEntryCopyWithImpl<_MitmSourceEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmSourceEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmSourceEntry&&(identical(other.network, network) || other.network == network)&&(identical(other.exclude, exclude) || other.exclude == exclude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,network,exclude);
}

@override
String toString() {
    return 'MitmSourceEntry(network: $network, exclude: $exclude)';
}


}

/// @nodoc
abstract mixin class _$MitmSourceEntryCopyWith<$Res> implements $MitmSourceEntryCopyWith<$Res> {
  factory _$MitmSourceEntryCopyWith(_MitmSourceEntry value, $Res Function(_MitmSourceEntry) _then) = __$MitmSourceEntryCopyWithImpl;
@override @useResult
$Res call({
 String network, bool exclude
});




}
/// @nodoc
class __$MitmSourceEntryCopyWithImpl<$Res>
    implements _$MitmSourceEntryCopyWith<$Res> {
  __$MitmSourceEntryCopyWithImpl(this._self, this._then);

  final _MitmSourceEntry _self;
  final $Res Function(_MitmSourceEntry) _then;

/// Create a copy of MitmSourceEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? network = null,Object? exclude = null,}) {
  return _then(_MitmSourceEntry(
network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,exclude: null == exclude ? _self.exclude : exclude // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MitmExchangeSummary {

 int get id; DateTime get start; bool get pending; int get duration; String get method; String get url; int get status;@JsonKey(name: 'request-size') int get requestSize;@JsonKey(name: 'response-size') int get responseSize; String get error; String get host; String get path;@JsonKey(name: 'content-type') String get contentType;@JsonKey(name: 'status-class') String get statusClass; String get kind; bool get rewritten;@JsonKey(name: 'action-kinds') List<String> get actionKinds;/// `reject`, `redirect`, `map-local`, `script`, or empty for the server.
 String get answer;@JsonKey(name: 'connection-id') int? get connectionId; MitmApp? get app;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmExchangeSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.requestSize, _this.requestSize) || other.requestSize == _this.requestSize)&&(identical(other.responseSize, _this.responseSize) || other.responseSize == _this.responseSize)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.host, _this.host) || other.host == _this.host)&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.contentType, _this.contentType) || other.contentType == _this.contentType)&&(identical(other.statusClass, _this.statusClass) || other.statusClass == _this.statusClass)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.rewritten, _this.rewritten) || other.rewritten == _this.rewritten)&&const DeepCollectionEquality().equals(other.actionKinds, _this.actionKinds)&&(identical(other.answer, _this.answer) || other.answer == _this.answer)&&(identical(other.connectionId, _this.connectionId) || other.connectionId == _this.connectionId)&&(identical(other.app, _this.app) || other.app == _this.app));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmExchangeSummary;
  return Object.hashAll([runtimeType,_this.id,_this.start,_this.pending,_this.duration,_this.method,_this.url,_this.status,_this.requestSize,_this.responseSize,_this.error,_this.host,_this.path,_this.contentType,_this.statusClass,_this.kind,_this.rewritten,const DeepCollectionEquality().hash(_this.actionKinds),_this.answer,_this.connectionId,_this.app]);
}

@override
String toString() {
  final _this = this as MitmExchangeSummary;
  return 'MitmExchangeSummary(id: ${_this.id}, start: ${_this.start}, pending: ${_this.pending}, duration: ${_this.duration}, method: ${_this.method}, url: ${_this.url}, status: ${_this.status}, requestSize: ${_this.requestSize}, responseSize: ${_this.responseSize}, error: ${_this.error}, host: ${_this.host}, path: ${_this.path}, contentType: ${_this.contentType}, statusClass: ${_this.statusClass}, kind: ${_this.kind}, rewritten: ${_this.rewritten}, actionKinds: ${_this.actionKinds}, answer: ${_this.answer}, connectionId: ${_this.connectionId}, app: ${_this.app})';
}


}

/// @nodoc
abstract mixin class $MitmExchangeSummaryCopyWith<$Res>  {
  factory $MitmExchangeSummaryCopyWith(MitmExchangeSummary value, $Res Function(MitmExchangeSummary) _then) = _$MitmExchangeSummaryCopyWithImpl;
@useResult
$Res call({
 int id, DateTime start, bool pending, int duration, String method, String url, int status,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error, String host, String path,@JsonKey(name: 'content-type') String contentType,@JsonKey(name: 'status-class') String statusClass, String kind, bool rewritten,@JsonKey(name: 'action-kinds') List<String> actionKinds, String answer,@JsonKey(name: 'connection-id') int? connectionId, MitmApp? app
});


$MitmAppCopyWith<$Res>? get app;

}
/// @nodoc
class _$MitmExchangeSummaryCopyWithImpl<$Res>
    implements $MitmExchangeSummaryCopyWith<$Res> {
  _$MitmExchangeSummaryCopyWithImpl(this._self, this._then);

  final MitmExchangeSummary _self;
  final $Res Function(MitmExchangeSummary) _then;

/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? method = null,Object? url = null,Object? status = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,Object? host = null,Object? path = null,Object? contentType = null,Object? statusClass = null,Object? kind = null,Object? rewritten = null,Object? actionKinds = null,Object? answer = null,Object? connectionId = freezed,Object? app = freezed,}) {
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
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,statusClass: null == statusClass ? _self.statusClass : statusClass // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,rewritten: null == rewritten ? _self.rewritten : rewritten // ignore: cast_nullable_to_non_nullable
as bool,actionKinds: null == actionKinds ? _self.actionKinds : actionKinds // ignore: cast_nullable_to_non_nullable
as List<String>,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as int?,app: freezed == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as MitmApp?,
  ));
}
/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MitmAppCopyWith<$Res>? get app {
    if (_self.app == null) {
    return null;
  }

  return $MitmAppCopyWith<$Res>(_self.app!, (value) {
    return _then(_self.copyWith(app: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  String method,  String url,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String host,  String path, @JsonKey(name: 'content-type')  String contentType, @JsonKey(name: 'status-class')  String statusClass,  String kind,  bool rewritten, @JsonKey(name: 'action-kinds')  List<String> actionKinds,  String answer, @JsonKey(name: 'connection-id')  int? connectionId,  MitmApp? app)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmExchangeSummary() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.method,_that.url,_that.status,_that.requestSize,_that.responseSize,_that.error,_that.host,_that.path,_that.contentType,_that.statusClass,_that.kind,_that.rewritten,_that.actionKinds,_that.answer,_that.connectionId,_that.app);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  String method,  String url,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String host,  String path, @JsonKey(name: 'content-type')  String contentType, @JsonKey(name: 'status-class')  String statusClass,  String kind,  bool rewritten, @JsonKey(name: 'action-kinds')  List<String> actionKinds,  String answer, @JsonKey(name: 'connection-id')  int? connectionId,  MitmApp? app)  $default,) {final _that = this;
switch (_that) {
case _MitmExchangeSummary():
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.method,_that.url,_that.status,_that.requestSize,_that.responseSize,_that.error,_that.host,_that.path,_that.contentType,_that.statusClass,_that.kind,_that.rewritten,_that.actionKinds,_that.answer,_that.connectionId,_that.app);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime start,  bool pending,  int duration,  String method,  String url,  int status, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String host,  String path, @JsonKey(name: 'content-type')  String contentType, @JsonKey(name: 'status-class')  String statusClass,  String kind,  bool rewritten, @JsonKey(name: 'action-kinds')  List<String> actionKinds,  String answer, @JsonKey(name: 'connection-id')  int? connectionId,  MitmApp? app)?  $default,) {final _that = this;
switch (_that) {
case _MitmExchangeSummary() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.method,_that.url,_that.status,_that.requestSize,_that.responseSize,_that.error,_that.host,_that.path,_that.contentType,_that.statusClass,_that.kind,_that.rewritten,_that.actionKinds,_that.answer,_that.connectionId,_that.app);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmExchangeSummary implements MitmExchangeSummary {
  const _MitmExchangeSummary({required this.id, required this.start, this.pending = false, this.duration = 0, this.method = '', this.url = '', this.status = 0, @JsonKey(name: 'request-size') this.requestSize = 0, @JsonKey(name: 'response-size') this.responseSize = 0, this.error = '', this.host = '', this.path = '', @JsonKey(name: 'content-type') this.contentType = '', @JsonKey(name: 'status-class') this.statusClass = '', this.kind = '', this.rewritten = false, @JsonKey(name: 'action-kinds')  List<String> actionKinds = const [], this.answer = '', @JsonKey(name: 'connection-id') this.connectionId, this.app}): _actionKinds = actionKinds;
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
@override@JsonKey() final  String host;
@override@JsonKey() final  String path;
@override@JsonKey(name: 'content-type') final  String contentType;
@override@JsonKey(name: 'status-class') final  String statusClass;
@override@JsonKey() final  String kind;
@override@JsonKey() final  bool rewritten;
 final  List<String> _actionKinds;
@override@JsonKey(name: 'action-kinds') List<String> get actionKinds {
  if (_actionKinds is EqualUnmodifiableListView) return _actionKinds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actionKinds);
}

/// `reject`, `redirect`, `map-local`, `script`, or empty for the server.
@override@JsonKey() final  String answer;
@override@JsonKey(name: 'connection-id') final  int? connectionId;
@override final  MitmApp? app;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmExchangeSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.start, start) || other.start == start)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&(identical(other.status, status) || other.status == status)&&(identical(other.requestSize, requestSize) || other.requestSize == requestSize)&&(identical(other.responseSize, responseSize) || other.responseSize == responseSize)&&(identical(other.error, error) || other.error == error)&&(identical(other.host, host) || other.host == host)&&(identical(other.path, path) || other.path == path)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.statusClass, statusClass) || other.statusClass == statusClass)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.rewritten, rewritten) || other.rewritten == rewritten)&&const DeepCollectionEquality().equals(other.actionKinds, _actionKinds)&&(identical(other.answer, answer) || other.answer == answer)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&(identical(other.app, app) || other.app == app));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,start,pending,duration,method,url,status,requestSize,responseSize,error,host,path,contentType,statusClass,kind,rewritten,const DeepCollectionEquality().hash(_actionKinds),answer,connectionId,app]);
}

@override
String toString() {
    return 'MitmExchangeSummary(id: $id, start: $start, pending: $pending, duration: $duration, method: $method, url: $url, status: $status, requestSize: $requestSize, responseSize: $responseSize, error: $error, host: $host, path: $path, contentType: $contentType, statusClass: $statusClass, kind: $kind, rewritten: $rewritten, actionKinds: $actionKinds, answer: $answer, connectionId: $connectionId, app: $app)';
}


}

/// @nodoc
abstract mixin class _$MitmExchangeSummaryCopyWith<$Res> implements $MitmExchangeSummaryCopyWith<$Res> {
  factory _$MitmExchangeSummaryCopyWith(_MitmExchangeSummary value, $Res Function(_MitmExchangeSummary) _then) = __$MitmExchangeSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime start, bool pending, int duration, String method, String url, int status,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error, String host, String path,@JsonKey(name: 'content-type') String contentType,@JsonKey(name: 'status-class') String statusClass, String kind, bool rewritten,@JsonKey(name: 'action-kinds') List<String> actionKinds, String answer,@JsonKey(name: 'connection-id') int? connectionId, MitmApp? app
});


@override $MitmAppCopyWith<$Res>? get app;

}
/// @nodoc
class __$MitmExchangeSummaryCopyWithImpl<$Res>
    implements _$MitmExchangeSummaryCopyWith<$Res> {
  __$MitmExchangeSummaryCopyWithImpl(this._self, this._then);

  final _MitmExchangeSummary _self;
  final $Res Function(_MitmExchangeSummary) _then;

/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? method = null,Object? url = null,Object? status = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,Object? host = null,Object? path = null,Object? contentType = null,Object? statusClass = null,Object? kind = null,Object? rewritten = null,Object? actionKinds = null,Object? answer = null,Object? connectionId = freezed,Object? app = freezed,}) {
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
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,statusClass: null == statusClass ? _self.statusClass : statusClass // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,rewritten: null == rewritten ? _self.rewritten : rewritten // ignore: cast_nullable_to_non_nullable
as bool,actionKinds: null == actionKinds ? _self._actionKinds : actionKinds // ignore: cast_nullable_to_non_nullable
as List<String>,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as String,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as int?,app: freezed == app ? _self.app : app // ignore: cast_nullable_to_non_nullable
as MitmApp?,
  ));
}

/// Create a copy of MitmExchangeSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MitmAppCopyWith<$Res>? get app {
    if (_self.app == null) {
    return null;
  }

  return $MitmAppCopyWith<$Res>(_self.app!, (value) {
    return _then(_self.copyWith(app: value));
  });
}
}


/// @nodoc
mixin _$MitmApp {

 String get process;@JsonKey(name: 'process-path') String get processPath; int? get uid;
/// Create a copy of MitmApp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmAppCopyWith<MitmApp> get copyWith => _$MitmAppCopyWithImpl<MitmApp>(this as MitmApp, _$identity);

  /// Serializes this MitmApp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmApp;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmApp&&(identical(other.process, _this.process) || other.process == _this.process)&&(identical(other.processPath, _this.processPath) || other.processPath == _this.processPath)&&(identical(other.uid, _this.uid) || other.uid == _this.uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmApp;
  return Object.hash(runtimeType,_this.process,_this.processPath,_this.uid);
}

@override
String toString() {
  final _this = this as MitmApp;
  return 'MitmApp(process: ${_this.process}, processPath: ${_this.processPath}, uid: ${_this.uid})';
}


}

/// @nodoc
abstract mixin class $MitmAppCopyWith<$Res>  {
  factory $MitmAppCopyWith(MitmApp value, $Res Function(MitmApp) _then) = _$MitmAppCopyWithImpl;
@useResult
$Res call({
 String process,@JsonKey(name: 'process-path') String processPath, int? uid
});




}
/// @nodoc
class _$MitmAppCopyWithImpl<$Res>
    implements $MitmAppCopyWith<$Res> {
  _$MitmAppCopyWithImpl(this._self, this._then);

  final MitmApp _self;
  final $Res Function(MitmApp) _then;

/// Create a copy of MitmApp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? process = null,Object? processPath = null,Object? uid = freezed,}) {
  return _then(MitmApp(
process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,processPath: null == processPath ? _self.processPath : processPath // ignore: cast_nullable_to_non_nullable
as String,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmApp].
extension MitmAppPatterns on MitmApp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmApp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmApp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmApp value)  $default,){
final _that = this;
switch (_that) {
case _MitmApp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmApp value)?  $default,){
final _that = this;
switch (_that) {
case _MitmApp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String process, @JsonKey(name: 'process-path')  String processPath,  int? uid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmApp() when $default != null:
return $default(_that.process,_that.processPath,_that.uid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String process, @JsonKey(name: 'process-path')  String processPath,  int? uid)  $default,) {final _that = this;
switch (_that) {
case _MitmApp():
return $default(_that.process,_that.processPath,_that.uid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String process, @JsonKey(name: 'process-path')  String processPath,  int? uid)?  $default,) {final _that = this;
switch (_that) {
case _MitmApp() when $default != null:
return $default(_that.process,_that.processPath,_that.uid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmApp implements MitmApp {
  const _MitmApp({this.process = '', @JsonKey(name: 'process-path') this.processPath = '', this.uid});
  factory _MitmApp.fromJson(Map<String, dynamic> json) => _$MitmAppFromJson(json);

@override@JsonKey() final  String process;
@override@JsonKey(name: 'process-path') final  String processPath;
@override final  int? uid;

/// Create a copy of MitmApp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmAppCopyWith<_MitmApp> get copyWith => __$MitmAppCopyWithImpl<_MitmApp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmAppToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmApp&&(identical(other.process, process) || other.process == process)&&(identical(other.processPath, processPath) || other.processPath == processPath)&&(identical(other.uid, uid) || other.uid == uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,process,processPath,uid);
}

@override
String toString() {
    return 'MitmApp(process: $process, processPath: $processPath, uid: $uid)';
}


}

/// @nodoc
abstract mixin class _$MitmAppCopyWith<$Res> implements $MitmAppCopyWith<$Res> {
  factory _$MitmAppCopyWith(_MitmApp value, $Res Function(_MitmApp) _then) = __$MitmAppCopyWithImpl;
@override @useResult
$Res call({
 String process,@JsonKey(name: 'process-path') String processPath, int? uid
});




}
/// @nodoc
class __$MitmAppCopyWithImpl<$Res>
    implements _$MitmAppCopyWith<$Res> {
  __$MitmAppCopyWithImpl(this._self, this._then);

  final _MitmApp _self;
  final $Res Function(_MitmApp) _then;

/// Create a copy of MitmApp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? process = null,Object? processPath = null,Object? uid = freezed,}) {
  return _then(_MitmApp(
process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,processPath: null == processPath ? _self.processPath : processPath // ignore: cast_nullable_to_non_nullable
as String,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$MitmQueryPage {

 bool get capturing; DateTime? get since; int get version; int get oldest; int get held; int get matched; List<MitmExchangeSummary> get exchanges; int? get next; List<int> get unmatched;
/// Create a copy of MitmQueryPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmQueryPageCopyWith<MitmQueryPage> get copyWith => _$MitmQueryPageCopyWithImpl<MitmQueryPage>(this as MitmQueryPage, _$identity);

  /// Serializes this MitmQueryPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmQueryPage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmQueryPage&&(identical(other.capturing, _this.capturing) || other.capturing == _this.capturing)&&(identical(other.since, _this.since) || other.since == _this.since)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.oldest, _this.oldest) || other.oldest == _this.oldest)&&(identical(other.held, _this.held) || other.held == _this.held)&&(identical(other.matched, _this.matched) || other.matched == _this.matched)&&const DeepCollectionEquality().equals(other.exchanges, _this.exchanges)&&(identical(other.next, _this.next) || other.next == _this.next)&&const DeepCollectionEquality().equals(other.unmatched, _this.unmatched));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmQueryPage;
  return Object.hash(runtimeType,_this.capturing,_this.since,_this.version,_this.oldest,_this.held,_this.matched,const DeepCollectionEquality().hash(_this.exchanges),_this.next,const DeepCollectionEquality().hash(_this.unmatched));
}

@override
String toString() {
  final _this = this as MitmQueryPage;
  return 'MitmQueryPage(capturing: ${_this.capturing}, since: ${_this.since}, version: ${_this.version}, oldest: ${_this.oldest}, held: ${_this.held}, matched: ${_this.matched}, exchanges: ${_this.exchanges}, next: ${_this.next}, unmatched: ${_this.unmatched})';
}


}

/// @nodoc
abstract mixin class $MitmQueryPageCopyWith<$Res>  {
  factory $MitmQueryPageCopyWith(MitmQueryPage value, $Res Function(MitmQueryPage) _then) = _$MitmQueryPageCopyWithImpl;
@useResult
$Res call({
 bool capturing, DateTime? since, int version, int oldest, int held, int matched, List<MitmExchangeSummary> exchanges, int? next, List<int> unmatched
});




}
/// @nodoc
class _$MitmQueryPageCopyWithImpl<$Res>
    implements $MitmQueryPageCopyWith<$Res> {
  _$MitmQueryPageCopyWithImpl(this._self, this._then);

  final MitmQueryPage _self;
  final $Res Function(MitmQueryPage) _then;

/// Create a copy of MitmQueryPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? capturing = null,Object? since = freezed,Object? version = null,Object? oldest = null,Object? held = null,Object? matched = null,Object? exchanges = null,Object? next = freezed,Object? unmatched = null,}) {
  return _then(MitmQueryPage(
capturing: null == capturing ? _self.capturing : capturing // ignore: cast_nullable_to_non_nullable
as bool,since: freezed == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,oldest: null == oldest ? _self.oldest : oldest // ignore: cast_nullable_to_non_nullable
as int,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,exchanges: null == exchanges ? _self.exchanges : exchanges // ignore: cast_nullable_to_non_nullable
as List<MitmExchangeSummary>,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as int?,unmatched: null == unmatched ? _self.unmatched : unmatched // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmQueryPage].
extension MitmQueryPagePatterns on MitmQueryPage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmQueryPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmQueryPage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmQueryPage value)  $default,){
final _that = this;
switch (_that) {
case _MitmQueryPage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmQueryPage value)?  $default,){
final _that = this;
switch (_that) {
case _MitmQueryPage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool capturing,  DateTime? since,  int version,  int oldest,  int held,  int matched,  List<MitmExchangeSummary> exchanges,  int? next,  List<int> unmatched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmQueryPage() when $default != null:
return $default(_that.capturing,_that.since,_that.version,_that.oldest,_that.held,_that.matched,_that.exchanges,_that.next,_that.unmatched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool capturing,  DateTime? since,  int version,  int oldest,  int held,  int matched,  List<MitmExchangeSummary> exchanges,  int? next,  List<int> unmatched)  $default,) {final _that = this;
switch (_that) {
case _MitmQueryPage():
return $default(_that.capturing,_that.since,_that.version,_that.oldest,_that.held,_that.matched,_that.exchanges,_that.next,_that.unmatched);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool capturing,  DateTime? since,  int version,  int oldest,  int held,  int matched,  List<MitmExchangeSummary> exchanges,  int? next,  List<int> unmatched)?  $default,) {final _that = this;
switch (_that) {
case _MitmQueryPage() when $default != null:
return $default(_that.capturing,_that.since,_that.version,_that.oldest,_that.held,_that.matched,_that.exchanges,_that.next,_that.unmatched);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmQueryPage implements MitmQueryPage {
  const _MitmQueryPage({this.capturing = false, this.since, this.version = 0, this.oldest = 0, this.held = 0, this.matched = 0,  List<MitmExchangeSummary> exchanges = const [], this.next,  List<int> unmatched = const []}): _exchanges = exchanges,_unmatched = unmatched;
  factory _MitmQueryPage.fromJson(Map<String, dynamic> json) => _$MitmQueryPageFromJson(json);

@override@JsonKey() final  bool capturing;
@override final  DateTime? since;
@override@JsonKey() final  int version;
@override@JsonKey() final  int oldest;
@override@JsonKey() final  int held;
@override@JsonKey() final  int matched;
 final  List<MitmExchangeSummary> _exchanges;
@override@JsonKey() List<MitmExchangeSummary> get exchanges {
  if (_exchanges is EqualUnmodifiableListView) return _exchanges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exchanges);
}

@override final  int? next;
 final  List<int> _unmatched;
@override@JsonKey() List<int> get unmatched {
  if (_unmatched is EqualUnmodifiableListView) return _unmatched;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unmatched);
}


/// Create a copy of MitmQueryPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmQueryPageCopyWith<_MitmQueryPage> get copyWith => __$MitmQueryPageCopyWithImpl<_MitmQueryPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmQueryPageToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmQueryPage&&(identical(other.capturing, capturing) || other.capturing == capturing)&&(identical(other.since, since) || other.since == since)&&(identical(other.version, version) || other.version == version)&&(identical(other.oldest, oldest) || other.oldest == oldest)&&(identical(other.held, held) || other.held == held)&&(identical(other.matched, matched) || other.matched == matched)&&const DeepCollectionEquality().equals(other.exchanges, _exchanges)&&(identical(other.next, next) || other.next == next)&&const DeepCollectionEquality().equals(other.unmatched, _unmatched));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,capturing,since,version,oldest,held,matched,const DeepCollectionEquality().hash(_exchanges),next,const DeepCollectionEquality().hash(_unmatched));
}

@override
String toString() {
    return 'MitmQueryPage(capturing: $capturing, since: $since, version: $version, oldest: $oldest, held: $held, matched: $matched, exchanges: $exchanges, next: $next, unmatched: $unmatched)';
}


}

/// @nodoc
abstract mixin class _$MitmQueryPageCopyWith<$Res> implements $MitmQueryPageCopyWith<$Res> {
  factory _$MitmQueryPageCopyWith(_MitmQueryPage value, $Res Function(_MitmQueryPage) _then) = __$MitmQueryPageCopyWithImpl;
@override @useResult
$Res call({
 bool capturing, DateTime? since, int version, int oldest, int held, int matched, List<MitmExchangeSummary> exchanges, int? next, List<int> unmatched
});




}
/// @nodoc
class __$MitmQueryPageCopyWithImpl<$Res>
    implements _$MitmQueryPageCopyWith<$Res> {
  __$MitmQueryPageCopyWithImpl(this._self, this._then);

  final _MitmQueryPage _self;
  final $Res Function(_MitmQueryPage) _then;

/// Create a copy of MitmQueryPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? capturing = null,Object? since = freezed,Object? version = null,Object? oldest = null,Object? held = null,Object? matched = null,Object? exchanges = null,Object? next = freezed,Object? unmatched = null,}) {
  return _then(_MitmQueryPage(
capturing: null == capturing ? _self.capturing : capturing // ignore: cast_nullable_to_non_nullable
as bool,since: freezed == since ? _self.since : since // ignore: cast_nullable_to_non_nullable
as DateTime?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,oldest: null == oldest ? _self.oldest : oldest // ignore: cast_nullable_to_non_nullable
as int,held: null == held ? _self.held : held // ignore: cast_nullable_to_non_nullable
as int,matched: null == matched ? _self.matched : matched // ignore: cast_nullable_to_non_nullable
as int,exchanges: null == exchanges ? _self._exchanges : exchanges // ignore: cast_nullable_to_non_nullable
as List<MitmExchangeSummary>,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as int?,unmatched: null == unmatched ? _self._unmatched : unmatched // ignore: cast_nullable_to_non_nullable
as List<int>,
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

 String get kind; String get phase; String get detail; String get module;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmAction&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.phase, _this.phase) || other.phase == _this.phase)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.module, _this.module) || other.module == _this.module));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmAction;
  return Object.hash(runtimeType,_this.kind,_this.phase,_this.detail,_this.module);
}

@override
String toString() {
  final _this = this as MitmAction;
  return 'MitmAction(kind: ${_this.kind}, phase: ${_this.phase}, detail: ${_this.detail}, module: ${_this.module})';
}


}

/// @nodoc
abstract mixin class $MitmActionCopyWith<$Res>  {
  factory $MitmActionCopyWith(MitmAction value, $Res Function(MitmAction) _then) = _$MitmActionCopyWithImpl;
@useResult
$Res call({
 String kind, String phase, String detail, String module
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
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? phase = null,Object? detail = null,Object? module = null,}) {
  return _then(MitmAction(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  String phase,  String detail,  String module)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmAction() when $default != null:
return $default(_that.kind,_that.phase,_that.detail,_that.module);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  String phase,  String detail,  String module)  $default,) {final _that = this;
switch (_that) {
case _MitmAction():
return $default(_that.kind,_that.phase,_that.detail,_that.module);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  String phase,  String detail,  String module)?  $default,) {final _that = this;
switch (_that) {
case _MitmAction() when $default != null:
return $default(_that.kind,_that.phase,_that.detail,_that.module);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmAction implements MitmAction {
  const _MitmAction({required this.kind, this.phase = '', this.detail = '', this.module = ''});
  factory _MitmAction.fromJson(Map<String, dynamic> json) => _$MitmActionFromJson(json);

@override final  String kind;
@override@JsonKey() final  String phase;
@override@JsonKey() final  String detail;
@override@JsonKey() final  String module;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmAction&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.module, module) || other.module == module));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,kind,phase,detail,module);
}

@override
String toString() {
    return 'MitmAction(kind: $kind, phase: $phase, detail: $detail, module: $module)';
}


}

/// @nodoc
abstract mixin class _$MitmActionCopyWith<$Res> implements $MitmActionCopyWith<$Res> {
  factory _$MitmActionCopyWith(_MitmAction value, $Res Function(_MitmAction) _then) = __$MitmActionCopyWithImpl;
@override @useResult
$Res call({
 String kind, String phase, String detail, String module
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
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? phase = null,Object? detail = null,Object? module = null,}) {
  return _then(_MitmAction(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as String,detail: null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String,module: null == module ? _self.module : module // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MitmRoute {

 String get rule;@JsonKey(name: 'rule-payload') String get rulePayload; List<String> get chains;
/// Create a copy of MitmRoute
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MitmRouteCopyWith<MitmRoute> get copyWith => _$MitmRouteCopyWithImpl<MitmRoute>(this as MitmRoute, _$identity);

  /// Serializes this MitmRoute to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MitmRoute;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmRoute&&(identical(other.rule, _this.rule) || other.rule == _this.rule)&&(identical(other.rulePayload, _this.rulePayload) || other.rulePayload == _this.rulePayload)&&const DeepCollectionEquality().equals(other.chains, _this.chains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmRoute;
  return Object.hash(runtimeType,_this.rule,_this.rulePayload,const DeepCollectionEquality().hash(_this.chains));
}

@override
String toString() {
  final _this = this as MitmRoute;
  return 'MitmRoute(rule: ${_this.rule}, rulePayload: ${_this.rulePayload}, chains: ${_this.chains})';
}


}

/// @nodoc
abstract mixin class $MitmRouteCopyWith<$Res>  {
  factory $MitmRouteCopyWith(MitmRoute value, $Res Function(MitmRoute) _then) = _$MitmRouteCopyWithImpl;
@useResult
$Res call({
 String rule,@JsonKey(name: 'rule-payload') String rulePayload, List<String> chains
});




}
/// @nodoc
class _$MitmRouteCopyWithImpl<$Res>
    implements $MitmRouteCopyWith<$Res> {
  _$MitmRouteCopyWithImpl(this._self, this._then);

  final MitmRoute _self;
  final $Res Function(MitmRoute) _then;

/// Create a copy of MitmRoute
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rule = null,Object? rulePayload = null,Object? chains = null,}) {
  return _then(MitmRoute(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MitmRoute].
extension MitmRoutePatterns on MitmRoute {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MitmRoute value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MitmRoute() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MitmRoute value)  $default,){
final _that = this;
switch (_that) {
case _MitmRoute():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MitmRoute value)?  $default,){
final _that = this;
switch (_that) {
case _MitmRoute() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rule, @JsonKey(name: 'rule-payload')  String rulePayload,  List<String> chains)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmRoute() when $default != null:
return $default(_that.rule,_that.rulePayload,_that.chains);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rule, @JsonKey(name: 'rule-payload')  String rulePayload,  List<String> chains)  $default,) {final _that = this;
switch (_that) {
case _MitmRoute():
return $default(_that.rule,_that.rulePayload,_that.chains);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rule, @JsonKey(name: 'rule-payload')  String rulePayload,  List<String> chains)?  $default,) {final _that = this;
switch (_that) {
case _MitmRoute() when $default != null:
return $default(_that.rule,_that.rulePayload,_that.chains);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmRoute implements MitmRoute {
  const _MitmRoute({this.rule = '', @JsonKey(name: 'rule-payload') this.rulePayload = '',  List<String> chains = const []}): _chains = chains;
  factory _MitmRoute.fromJson(Map<String, dynamic> json) => _$MitmRouteFromJson(json);

@override@JsonKey() final  String rule;
@override@JsonKey(name: 'rule-payload') final  String rulePayload;
 final  List<String> _chains;
@override@JsonKey() List<String> get chains {
  if (_chains is EqualUnmodifiableListView) return _chains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chains);
}


/// Create a copy of MitmRoute
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MitmRouteCopyWith<_MitmRoute> get copyWith => __$MitmRouteCopyWithImpl<_MitmRoute>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MitmRouteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmRoute&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.rulePayload, rulePayload) || other.rulePayload == rulePayload)&&const DeepCollectionEquality().equals(other.chains, _chains));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rule,rulePayload,const DeepCollectionEquality().hash(_chains));
}

@override
String toString() {
    return 'MitmRoute(rule: $rule, rulePayload: $rulePayload, chains: $chains)';
}


}

/// @nodoc
abstract mixin class _$MitmRouteCopyWith<$Res> implements $MitmRouteCopyWith<$Res> {
  factory _$MitmRouteCopyWith(_MitmRoute value, $Res Function(_MitmRoute) _then) = __$MitmRouteCopyWithImpl;
@override @useResult
$Res call({
 String rule,@JsonKey(name: 'rule-payload') String rulePayload, List<String> chains
});




}
/// @nodoc
class __$MitmRouteCopyWithImpl<$Res>
    implements _$MitmRouteCopyWith<$Res> {
  __$MitmRouteCopyWithImpl(this._self, this._then);

  final _MitmRoute _self;
  final $Res Function(_MitmRoute) _then;

/// Create a copy of MitmRoute
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rule = null,Object? rulePayload = null,Object? chains = null,}) {
  return _then(_MitmRoute(
rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$MitmExchange {

 int get id; DateTime get start; bool get pending; int get duration; int get ttfb; String get method; String get url;@JsonKey(name: 'original-url') String get originalUrl; String get proto; int get status; String get reason;@JsonKey(name: 'request-size') int get requestSize;@JsonKey(name: 'response-size') int get responseSize; String get error; String get connection;@JsonKey(name: 'connection-id') int? get connectionId;@JsonKey(name: 'request-header') Map<String, List<String>> get requestHeader;@JsonKey(name: 'response-header') Map<String, List<String>> get responseHeader; List<MitmAction> get actions; MitmRoute? get route;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MitmExchange&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.pending, _this.pending) || other.pending == _this.pending)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.ttfb, _this.ttfb) || other.ttfb == _this.ttfb)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.originalUrl, _this.originalUrl) || other.originalUrl == _this.originalUrl)&&(identical(other.proto, _this.proto) || other.proto == _this.proto)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.requestSize, _this.requestSize) || other.requestSize == _this.requestSize)&&(identical(other.responseSize, _this.responseSize) || other.responseSize == _this.responseSize)&&(identical(other.error, _this.error) || other.error == _this.error)&&(identical(other.connection, _this.connection) || other.connection == _this.connection)&&(identical(other.connectionId, _this.connectionId) || other.connectionId == _this.connectionId)&&const DeepCollectionEquality().equals(other.requestHeader, _this.requestHeader)&&const DeepCollectionEquality().equals(other.responseHeader, _this.responseHeader)&&const DeepCollectionEquality().equals(other.actions, _this.actions)&&(identical(other.route, _this.route) || other.route == _this.route));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MitmExchange;
  return Object.hashAll([runtimeType,_this.id,_this.start,_this.pending,_this.duration,_this.ttfb,_this.method,_this.url,_this.originalUrl,_this.proto,_this.status,_this.reason,_this.requestSize,_this.responseSize,_this.error,_this.connection,_this.connectionId,const DeepCollectionEquality().hash(_this.requestHeader),const DeepCollectionEquality().hash(_this.responseHeader),const DeepCollectionEquality().hash(_this.actions),_this.route]);
}

@override
String toString() {
  final _this = this as MitmExchange;
  return 'MitmExchange(id: ${_this.id}, start: ${_this.start}, pending: ${_this.pending}, duration: ${_this.duration}, ttfb: ${_this.ttfb}, method: ${_this.method}, url: ${_this.url}, originalUrl: ${_this.originalUrl}, proto: ${_this.proto}, status: ${_this.status}, reason: ${_this.reason}, requestSize: ${_this.requestSize}, responseSize: ${_this.responseSize}, error: ${_this.error}, connection: ${_this.connection}, connectionId: ${_this.connectionId}, requestHeader: ${_this.requestHeader}, responseHeader: ${_this.responseHeader}, actions: ${_this.actions}, route: ${_this.route})';
}


}

/// @nodoc
abstract mixin class $MitmExchangeCopyWith<$Res>  {
  factory $MitmExchangeCopyWith(MitmExchange value, $Res Function(MitmExchange) _then) = _$MitmExchangeCopyWithImpl;
@useResult
$Res call({
 int id, DateTime start, bool pending, int duration, int ttfb, String method, String url,@JsonKey(name: 'original-url') String originalUrl, String proto, int status, String reason,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error, String connection,@JsonKey(name: 'connection-id') int? connectionId,@JsonKey(name: 'request-header') Map<String, List<String>> requestHeader,@JsonKey(name: 'response-header') Map<String, List<String>> responseHeader, List<MitmAction> actions, MitmRoute? route
});


$MitmRouteCopyWith<$Res>? get route;

}
/// @nodoc
class _$MitmExchangeCopyWithImpl<$Res>
    implements $MitmExchangeCopyWith<$Res> {
  _$MitmExchangeCopyWithImpl(this._self, this._then);

  final MitmExchange _self;
  final $Res Function(MitmExchange) _then;

/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? ttfb = null,Object? method = null,Object? url = null,Object? originalUrl = null,Object? proto = null,Object? status = null,Object? reason = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,Object? connection = null,Object? connectionId = freezed,Object? requestHeader = null,Object? responseHeader = null,Object? actions = null,Object? route = freezed,}) {
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
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,requestSize: null == requestSize ? _self.requestSize : requestSize // ignore: cast_nullable_to_non_nullable
as int,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as String,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as int?,requestHeader: null == requestHeader ? _self.requestHeader : requestHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,responseHeader: null == responseHeader ? _self.responseHeader : responseHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<MitmAction>,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as MitmRoute?,
  ));
}
/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MitmRouteCopyWith<$Res>? get route {
    if (_self.route == null) {
    return null;
  }

  return $MitmRouteCopyWith<$Res>(_self.route!, (value) {
    return _then(_self.copyWith(route: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  int ttfb,  String method,  String url, @JsonKey(name: 'original-url')  String originalUrl,  String proto,  int status,  String reason, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String connection, @JsonKey(name: 'connection-id')  int? connectionId, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader,  List<MitmAction> actions,  MitmRoute? route)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MitmExchange() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.ttfb,_that.method,_that.url,_that.originalUrl,_that.proto,_that.status,_that.reason,_that.requestSize,_that.responseSize,_that.error,_that.connection,_that.connectionId,_that.requestHeader,_that.responseHeader,_that.actions,_that.route);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DateTime start,  bool pending,  int duration,  int ttfb,  String method,  String url, @JsonKey(name: 'original-url')  String originalUrl,  String proto,  int status,  String reason, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String connection, @JsonKey(name: 'connection-id')  int? connectionId, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader,  List<MitmAction> actions,  MitmRoute? route)  $default,) {final _that = this;
switch (_that) {
case _MitmExchange():
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.ttfb,_that.method,_that.url,_that.originalUrl,_that.proto,_that.status,_that.reason,_that.requestSize,_that.responseSize,_that.error,_that.connection,_that.connectionId,_that.requestHeader,_that.responseHeader,_that.actions,_that.route);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DateTime start,  bool pending,  int duration,  int ttfb,  String method,  String url, @JsonKey(name: 'original-url')  String originalUrl,  String proto,  int status,  String reason, @JsonKey(name: 'request-size')  int requestSize, @JsonKey(name: 'response-size')  int responseSize,  String error,  String connection, @JsonKey(name: 'connection-id')  int? connectionId, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader,  List<MitmAction> actions,  MitmRoute? route)?  $default,) {final _that = this;
switch (_that) {
case _MitmExchange() when $default != null:
return $default(_that.id,_that.start,_that.pending,_that.duration,_that.ttfb,_that.method,_that.url,_that.originalUrl,_that.proto,_that.status,_that.reason,_that.requestSize,_that.responseSize,_that.error,_that.connection,_that.connectionId,_that.requestHeader,_that.responseHeader,_that.actions,_that.route);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MitmExchange implements MitmExchange {
  const _MitmExchange({required this.id, required this.start, this.pending = false, this.duration = 0, this.ttfb = 0, this.method = '', this.url = '', @JsonKey(name: 'original-url') this.originalUrl = '', this.proto = '', this.status = 0, this.reason = '', @JsonKey(name: 'request-size') this.requestSize = 0, @JsonKey(name: 'response-size') this.responseSize = 0, this.error = '', this.connection = '', @JsonKey(name: 'connection-id') this.connectionId, @JsonKey(name: 'request-header')  Map<String, List<String>> requestHeader = const {}, @JsonKey(name: 'response-header')  Map<String, List<String>> responseHeader = const {},  List<MitmAction> actions = const [], this.route}): _requestHeader = requestHeader,_responseHeader = responseHeader,_actions = actions;
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
@override@JsonKey() final  String reason;
@override@JsonKey(name: 'request-size') final  int requestSize;
@override@JsonKey(name: 'response-size') final  int responseSize;
@override@JsonKey() final  String error;
@override@JsonKey() final  String connection;
@override@JsonKey(name: 'connection-id') final  int? connectionId;
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

@override final  MitmRoute? route;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MitmExchange&&(identical(other.id, id) || other.id == id)&&(identical(other.start, start) || other.start == start)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.ttfb, ttfb) || other.ttfb == ttfb)&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&(identical(other.originalUrl, originalUrl) || other.originalUrl == originalUrl)&&(identical(other.proto, proto) || other.proto == proto)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.requestSize, requestSize) || other.requestSize == requestSize)&&(identical(other.responseSize, responseSize) || other.responseSize == responseSize)&&(identical(other.error, error) || other.error == error)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.connectionId, connectionId) || other.connectionId == connectionId)&&const DeepCollectionEquality().equals(other.requestHeader, _requestHeader)&&const DeepCollectionEquality().equals(other.responseHeader, _responseHeader)&&const DeepCollectionEquality().equals(other.actions, _actions)&&(identical(other.route, route) || other.route == route));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,start,pending,duration,ttfb,method,url,originalUrl,proto,status,reason,requestSize,responseSize,error,connection,connectionId,const DeepCollectionEquality().hash(_requestHeader),const DeepCollectionEquality().hash(_responseHeader),const DeepCollectionEquality().hash(_actions),route]);
}

@override
String toString() {
    return 'MitmExchange(id: $id, start: $start, pending: $pending, duration: $duration, ttfb: $ttfb, method: $method, url: $url, originalUrl: $originalUrl, proto: $proto, status: $status, reason: $reason, requestSize: $requestSize, responseSize: $responseSize, error: $error, connection: $connection, connectionId: $connectionId, requestHeader: $requestHeader, responseHeader: $responseHeader, actions: $actions, route: $route)';
}


}

/// @nodoc
abstract mixin class _$MitmExchangeCopyWith<$Res> implements $MitmExchangeCopyWith<$Res> {
  factory _$MitmExchangeCopyWith(_MitmExchange value, $Res Function(_MitmExchange) _then) = __$MitmExchangeCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime start, bool pending, int duration, int ttfb, String method, String url,@JsonKey(name: 'original-url') String originalUrl, String proto, int status, String reason,@JsonKey(name: 'request-size') int requestSize,@JsonKey(name: 'response-size') int responseSize, String error, String connection,@JsonKey(name: 'connection-id') int? connectionId,@JsonKey(name: 'request-header') Map<String, List<String>> requestHeader,@JsonKey(name: 'response-header') Map<String, List<String>> responseHeader, List<MitmAction> actions, MitmRoute? route
});


@override $MitmRouteCopyWith<$Res>? get route;

}
/// @nodoc
class __$MitmExchangeCopyWithImpl<$Res>
    implements _$MitmExchangeCopyWith<$Res> {
  __$MitmExchangeCopyWithImpl(this._self, this._then);

  final _MitmExchange _self;
  final $Res Function(_MitmExchange) _then;

/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? start = null,Object? pending = null,Object? duration = null,Object? ttfb = null,Object? method = null,Object? url = null,Object? originalUrl = null,Object? proto = null,Object? status = null,Object? reason = null,Object? requestSize = null,Object? responseSize = null,Object? error = null,Object? connection = null,Object? connectionId = freezed,Object? requestHeader = null,Object? responseHeader = null,Object? actions = null,Object? route = freezed,}) {
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
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,requestSize: null == requestSize ? _self.requestSize : requestSize // ignore: cast_nullable_to_non_nullable
as int,responseSize: null == responseSize ? _self.responseSize : responseSize // ignore: cast_nullable_to_non_nullable
as int,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as String,connectionId: freezed == connectionId ? _self.connectionId : connectionId // ignore: cast_nullable_to_non_nullable
as int?,requestHeader: null == requestHeader ? _self._requestHeader : requestHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,responseHeader: null == responseHeader ? _self._responseHeader : responseHeader // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<MitmAction>,route: freezed == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as MitmRoute?,
  ));
}

/// Create a copy of MitmExchange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MitmRouteCopyWith<$Res>? get route {
    if (_self.route == null) {
    return null;
  }

  return $MitmRouteCopyWith<$Res>(_self.route!, (value) {
    return _then(_self.copyWith(route: value));
  });
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

 bool get enable; int get port; bool get ipv6; bool get dnsHijacking; AccessControlProps get accessControlProps; bool get allowBypass; bool get systemProxy; List<String> get bypassDomain; List<String> get routeAddress; int get mtu; String get congestionController;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnOptions&&(identical(other.enable, _this.enable) || other.enable == _this.enable)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.ipv6, _this.ipv6) || other.ipv6 == _this.ipv6)&&(identical(other.dnsHijacking, _this.dnsHijacking) || other.dnsHijacking == _this.dnsHijacking)&&(identical(other.accessControlProps, _this.accessControlProps) || other.accessControlProps == _this.accessControlProps)&&(identical(other.allowBypass, _this.allowBypass) || other.allowBypass == _this.allowBypass)&&(identical(other.systemProxy, _this.systemProxy) || other.systemProxy == _this.systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _this.bypassDomain)&&const DeepCollectionEquality().equals(other.routeAddress, _this.routeAddress)&&(identical(other.mtu, _this.mtu) || other.mtu == _this.mtu)&&(identical(other.congestionController, _this.congestionController) || other.congestionController == _this.congestionController));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VpnOptions;
  return Object.hash(runtimeType,_this.enable,_this.port,_this.ipv6,_this.dnsHijacking,_this.accessControlProps,_this.allowBypass,_this.systemProxy,const DeepCollectionEquality().hash(_this.bypassDomain),const DeepCollectionEquality().hash(_this.routeAddress),_this.mtu,_this.congestionController);
}

@override
String toString() {
  final _this = this as VpnOptions;
  return 'VpnOptions(enable: ${_this.enable}, port: ${_this.port}, ipv6: ${_this.ipv6}, dnsHijacking: ${_this.dnsHijacking}, accessControlProps: ${_this.accessControlProps}, allowBypass: ${_this.allowBypass}, systemProxy: ${_this.systemProxy}, bypassDomain: ${_this.bypassDomain}, routeAddress: ${_this.routeAddress}, mtu: ${_this.mtu}, congestionController: ${_this.congestionController})';
}


}

/// @nodoc
abstract mixin class $VpnOptionsCopyWith<$Res>  {
  factory $VpnOptionsCopyWith(VpnOptions value, $Res Function(VpnOptions) _then) = _$VpnOptionsCopyWithImpl;
@useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, List<String> routeAddress, int mtu, String congestionController
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
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? routeAddress = null,Object? mtu = null,Object? congestionController = null,}) {
  return _then(VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self.routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  List<String> routeAddress,  int mtu,  String congestionController)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.routeAddress,_that.mtu,_that.congestionController);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  List<String> routeAddress,  int mtu,  String congestionController)  $default,) {final _that = this;
switch (_that) {
case _VpnOptions():
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.routeAddress,_that.mtu,_that.congestionController);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  int port,  bool ipv6,  bool dnsHijacking,  AccessControlProps accessControlProps,  bool allowBypass,  bool systemProxy,  List<String> bypassDomain,  List<String> routeAddress,  int mtu,  String congestionController)?  $default,) {final _that = this;
switch (_that) {
case _VpnOptions() when $default != null:
return $default(_that.enable,_that.port,_that.ipv6,_that.dnsHijacking,_that.accessControlProps,_that.allowBypass,_that.systemProxy,_that.bypassDomain,_that.routeAddress,_that.mtu,_that.congestionController);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VpnOptions implements VpnOptions {
  const _VpnOptions({required this.enable, required this.port, required this.ipv6, required this.dnsHijacking, required this.accessControlProps, required this.allowBypass, required this.systemProxy, required  List<String> bypassDomain,  List<String> routeAddress = const [], this.mtu = 0, this.congestionController = ''}): _bypassDomain = bypassDomain,_routeAddress = routeAddress;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnOptions&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.port, port) || other.port == port)&&(identical(other.ipv6, ipv6) || other.ipv6 == ipv6)&&(identical(other.dnsHijacking, dnsHijacking) || other.dnsHijacking == dnsHijacking)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps)&&(identical(other.allowBypass, allowBypass) || other.allowBypass == allowBypass)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, _bypassDomain)&&const DeepCollectionEquality().equals(other.routeAddress, _routeAddress)&&(identical(other.mtu, mtu) || other.mtu == mtu)&&(identical(other.congestionController, congestionController) || other.congestionController == congestionController));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enable,port,ipv6,dnsHijacking,accessControlProps,allowBypass,systemProxy,const DeepCollectionEquality().hash(_bypassDomain),const DeepCollectionEquality().hash(_routeAddress),mtu,congestionController);
}

@override
String toString() {
    return 'VpnOptions(enable: $enable, port: $port, ipv6: $ipv6, dnsHijacking: $dnsHijacking, accessControlProps: $accessControlProps, allowBypass: $allowBypass, systemProxy: $systemProxy, bypassDomain: $bypassDomain, routeAddress: $routeAddress, mtu: $mtu, congestionController: $congestionController)';
}


}

/// @nodoc
abstract mixin class _$VpnOptionsCopyWith<$Res> implements $VpnOptionsCopyWith<$Res> {
  factory _$VpnOptionsCopyWith(_VpnOptions value, $Res Function(_VpnOptions) _then) = __$VpnOptionsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, int port, bool ipv6, bool dnsHijacking, AccessControlProps accessControlProps, bool allowBypass, bool systemProxy, List<String> bypassDomain, List<String> routeAddress, int mtu, String congestionController
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
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? port = null,Object? ipv6 = null,Object? dnsHijacking = null,Object? accessControlProps = null,Object? allowBypass = null,Object? systemProxy = null,Object? bypassDomain = null,Object? routeAddress = null,Object? mtu = null,Object? congestionController = null,}) {
  return _then(_VpnOptions(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,ipv6: null == ipv6 ? _self.ipv6 : ipv6 // ignore: cast_nullable_to_non_nullable
as bool,dnsHijacking: null == dnsHijacking ? _self.dnsHijacking : dnsHijacking // ignore: cast_nullable_to_non_nullable
as bool,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,allowBypass: null == allowBypass ? _self.allowBypass : allowBypass // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,routeAddress: null == routeAddress ? _self._routeAddress : routeAddress // ignore: cast_nullable_to_non_nullable
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
mixin _$RouteSnapshot {

 int get coreEpoch; int get routeVersion; bool get running;
/// Create a copy of RouteSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteSnapshotCopyWith<RouteSnapshot> get copyWith => _$RouteSnapshotCopyWithImpl<RouteSnapshot>(this as RouteSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RouteSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteSnapshot&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.routeVersion, _this.routeVersion) || other.routeVersion == _this.routeVersion)&&(identical(other.running, _this.running) || other.running == _this.running));
}


@override
int get hashCode {
  final _this = this as RouteSnapshot;
  return Object.hash(runtimeType,_this.coreEpoch,_this.routeVersion,_this.running);
}

@override
String toString() {
  final _this = this as RouteSnapshot;
  return 'RouteSnapshot(coreEpoch: ${_this.coreEpoch}, routeVersion: ${_this.routeVersion}, running: ${_this.running})';
}


}

/// @nodoc
abstract mixin class $RouteSnapshotCopyWith<$Res>  {
  factory $RouteSnapshotCopyWith(RouteSnapshot value, $Res Function(RouteSnapshot) _then) = _$RouteSnapshotCopyWithImpl;
@useResult
$Res call({
 int coreEpoch, int routeVersion, bool running
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
@pragma('vm:prefer-inline') @override $Res call({Object? coreEpoch = null,Object? routeVersion = null,Object? running = null,}) {
  return _then(RouteSnapshot(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int coreEpoch,  int routeVersion,  bool running)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
return $default(_that.coreEpoch,_that.routeVersion,_that.running);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int coreEpoch,  int routeVersion,  bool running)  $default,) {final _that = this;
switch (_that) {
case _RouteSnapshot():
return $default(_that.coreEpoch,_that.routeVersion,_that.running);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int coreEpoch,  int routeVersion,  bool running)?  $default,) {final _that = this;
switch (_that) {
case _RouteSnapshot() when $default != null:
return $default(_that.coreEpoch,_that.routeVersion,_that.running);case _:
  return null;

}
}

}

/// @nodoc


class _RouteSnapshot implements RouteSnapshot {
  const _RouteSnapshot({this.coreEpoch = 0, this.routeVersion = 0, this.running = false});
  

@override@JsonKey() final  int coreEpoch;
@override@JsonKey() final  int routeVersion;
@override@JsonKey() final  bool running;

/// Create a copy of RouteSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteSnapshotCopyWith<_RouteSnapshot> get copyWith => __$RouteSnapshotCopyWithImpl<_RouteSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteSnapshot&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.routeVersion, routeVersion) || other.routeVersion == routeVersion)&&(identical(other.running, running) || other.running == running));
}


@override
int get hashCode {
    return Object.hash(runtimeType,coreEpoch,routeVersion,running);
}

@override
String toString() {
    return 'RouteSnapshot(coreEpoch: $coreEpoch, routeVersion: $routeVersion, running: $running)';
}


}

/// @nodoc
abstract mixin class _$RouteSnapshotCopyWith<$Res> implements $RouteSnapshotCopyWith<$Res> {
  factory _$RouteSnapshotCopyWith(_RouteSnapshot value, $Res Function(_RouteSnapshot) _then) = __$RouteSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int coreEpoch, int routeVersion, bool running
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
@override @pragma('vm:prefer-inline') $Res call({Object? coreEpoch = null,Object? routeVersion = null,Object? running = null,}) {
  return _then(_RouteSnapshot(
coreEpoch: null == coreEpoch ? _self.coreEpoch : coreEpoch // ignore: cast_nullable_to_non_nullable
as int,routeVersion: null == routeVersion ? _self.routeVersion : routeVersion // ignore: cast_nullable_to_non_nullable
as int,running: null == running ? _self.running : running // ignore: cast_nullable_to_non_nullable
as bool,
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

 String get name; String get status; String get region; String get ip; int get delay; List<String> get chains;@JsonKey(name: 'checked-at') int get checkedAt;@JsonKey(name: 'core-epoch') int get coreEpoch;@JsonKey(name: 'route-version') int get routeVersion; List<RouteHit> get hits;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceCheckItem&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.delay, _this.delay) || other.delay == _this.delay)&&const DeepCollectionEquality().equals(other.chains, _this.chains)&&(identical(other.checkedAt, _this.checkedAt) || other.checkedAt == _this.checkedAt)&&(identical(other.coreEpoch, _this.coreEpoch) || other.coreEpoch == _this.coreEpoch)&&(identical(other.routeVersion, _this.routeVersion) || other.routeVersion == _this.routeVersion)&&const DeepCollectionEquality().equals(other.hits, _this.hits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ServiceCheckItem;
  return Object.hash(runtimeType,_this.name,_this.status,_this.region,_this.ip,_this.delay,const DeepCollectionEquality().hash(_this.chains),_this.checkedAt,_this.coreEpoch,_this.routeVersion,const DeepCollectionEquality().hash(_this.hits));
}

@override
String toString() {
  final _this = this as ServiceCheckItem;
  return 'ServiceCheckItem(name: ${_this.name}, status: ${_this.status}, region: ${_this.region}, ip: ${_this.ip}, delay: ${_this.delay}, chains: ${_this.chains}, checkedAt: ${_this.checkedAt}, coreEpoch: ${_this.coreEpoch}, routeVersion: ${_this.routeVersion}, hits: ${_this.hits})';
}


}

/// @nodoc
abstract mixin class $ServiceCheckItemCopyWith<$Res>  {
  factory $ServiceCheckItemCopyWith(ServiceCheckItem value, $Res Function(ServiceCheckItem) _then) = _$ServiceCheckItemCopyWithImpl;
@useResult
$Res call({
 String name, String status, String region, String ip, int delay, List<String> chains,@JsonKey(name: 'checked-at') int checkedAt,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<RouteHit> hits
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
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? status = null,Object? region = null,Object? ip = null,Object? delay = null,Object? chains = null,Object? checkedAt = null,Object? coreEpoch = null,Object? routeVersion = null,Object? hits = null,}) {
  return _then(ServiceCheckItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String status,  String region,  String ip,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
return $default(_that.name,_that.status,_that.region,_that.ip,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.routeVersion,_that.hits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String status,  String region,  String ip,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits)  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckItem():
return $default(_that.name,_that.status,_that.region,_that.ip,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.routeVersion,_that.hits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String status,  String region,  String ip,  int delay,  List<String> chains, @JsonKey(name: 'checked-at')  int checkedAt, @JsonKey(name: 'core-epoch')  int coreEpoch, @JsonKey(name: 'route-version')  int routeVersion,  List<RouteHit> hits)?  $default,) {final _that = this;
switch (_that) {
case _ServiceCheckItem() when $default != null:
return $default(_that.name,_that.status,_that.region,_that.ip,_that.delay,_that.chains,_that.checkedAt,_that.coreEpoch,_that.routeVersion,_that.hits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceCheckItem implements ServiceCheckItem {
  const _ServiceCheckItem({this.name = '', this.status = '', this.region = '', this.ip = '', this.delay = 0,  List<String> chains = const [], @JsonKey(name: 'checked-at') this.checkedAt = 0, @JsonKey(name: 'core-epoch') this.coreEpoch = 0, @JsonKey(name: 'route-version') this.routeVersion = 0,  List<RouteHit> hits = const []}): _chains = chains,_hits = hits;
  factory _ServiceCheckItem.fromJson(Map<String, dynamic> json) => _$ServiceCheckItemFromJson(json);

@override@JsonKey() final  String name;
@override@JsonKey() final  String status;
@override@JsonKey() final  String region;
@override@JsonKey() final  String ip;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceCheckItem&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status)&&(identical(other.region, region) || other.region == region)&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.delay, delay) || other.delay == delay)&&const DeepCollectionEquality().equals(other.chains, _chains)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt)&&(identical(other.coreEpoch, coreEpoch) || other.coreEpoch == coreEpoch)&&(identical(other.routeVersion, routeVersion) || other.routeVersion == routeVersion)&&const DeepCollectionEquality().equals(other.hits, _hits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,status,region,ip,delay,const DeepCollectionEquality().hash(_chains),checkedAt,coreEpoch,routeVersion,const DeepCollectionEquality().hash(_hits));
}

@override
String toString() {
    return 'ServiceCheckItem(name: $name, status: $status, region: $region, ip: $ip, delay: $delay, chains: $chains, checkedAt: $checkedAt, coreEpoch: $coreEpoch, routeVersion: $routeVersion, hits: $hits)';
}


}

/// @nodoc
abstract mixin class _$ServiceCheckItemCopyWith<$Res> implements $ServiceCheckItemCopyWith<$Res> {
  factory _$ServiceCheckItemCopyWith(_ServiceCheckItem value, $Res Function(_ServiceCheckItem) _then) = __$ServiceCheckItemCopyWithImpl;
@override @useResult
$Res call({
 String name, String status, String region, String ip, int delay, List<String> chains,@JsonKey(name: 'checked-at') int checkedAt,@JsonKey(name: 'core-epoch') int coreEpoch,@JsonKey(name: 'route-version') int routeVersion, List<RouteHit> hits
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
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? status = null,Object? region = null,Object? ip = null,Object? delay = null,Object? chains = null,Object? checkedAt = null,Object? coreEpoch = null,Object? routeVersion = null,Object? hits = null,}) {
  return _then(_ServiceCheckItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
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

// dart format on

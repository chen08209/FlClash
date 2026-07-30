// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../tailscale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TailscaleProps {

 bool get enable; bool get bypassTraffic; List<TailscaleProxy> get proxies;
/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TailscalePropsCopyWith<TailscaleProps> get copyWith => _$TailscalePropsCopyWithImpl<TailscaleProps>(this as TailscaleProps, _$identity);

  /// Serializes this TailscaleProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TailscaleProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.bypassTraffic, bypassTraffic) || other.bypassTraffic == bypassTraffic)&&const DeepCollectionEquality().equals(other.proxies, proxies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,bypassTraffic,const DeepCollectionEquality().hash(proxies));

@override
String toString() {
  return 'TailscaleProps(enable: $enable, bypassTraffic: $bypassTraffic, proxies: $proxies)';
}


}

/// @nodoc
abstract mixin class $TailscalePropsCopyWith<$Res>  {
  factory $TailscalePropsCopyWith(TailscaleProps value, $Res Function(TailscaleProps) _then) = _$TailscalePropsCopyWithImpl;
@useResult
$Res call({
 bool enable, bool bypassTraffic, List<TailscaleProxy> proxies
});




}
/// @nodoc
class _$TailscalePropsCopyWithImpl<$Res>
    implements $TailscalePropsCopyWith<$Res> {
  _$TailscalePropsCopyWithImpl(this._self, this._then);

  final TailscaleProps _self;
  final $Res Function(TailscaleProps) _then;

/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? bypassTraffic = null,Object? proxies = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,bypassTraffic: null == bypassTraffic ? _self.bypassTraffic : bypassTraffic // ignore: cast_nullable_to_non_nullable
as bool,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<TailscaleProxy>,
  ));
}

}


/// Adds pattern-matching-related methods to [TailscaleProps].
extension TailscalePropsPatterns on TailscaleProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TailscaleProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TailscaleProps value)  $default,){
final _that = this;
switch (_that) {
case _TailscaleProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TailscaleProps value)?  $default,){
final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  bool bypassTraffic,  List<TailscaleProxy> proxies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
return $default(_that.enable,_that.bypassTraffic,_that.proxies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  bool bypassTraffic,  List<TailscaleProxy> proxies)  $default,) {final _that = this;
switch (_that) {
case _TailscaleProps():
return $default(_that.enable,_that.bypassTraffic,_that.proxies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  bool bypassTraffic,  List<TailscaleProxy> proxies)?  $default,) {final _that = this;
switch (_that) {
case _TailscaleProps() when $default != null:
return $default(_that.enable,_that.bypassTraffic,_that.proxies);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TailscaleProps implements TailscaleProps {
  const _TailscaleProps({this.enable = false, this.bypassTraffic = false, final  List<TailscaleProxy> proxies = const []}): _proxies = proxies;
  factory _TailscaleProps.fromJson(Map<String, dynamic> json) => _$TailscalePropsFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  bool bypassTraffic;
 final  List<TailscaleProxy> _proxies;
@override@JsonKey() List<TailscaleProxy> get proxies {
  if (_proxies is EqualUnmodifiableListView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxies);
}


/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TailscalePropsCopyWith<_TailscaleProps> get copyWith => __$TailscalePropsCopyWithImpl<_TailscaleProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TailscalePropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TailscaleProps&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.bypassTraffic, bypassTraffic) || other.bypassTraffic == bypassTraffic)&&const DeepCollectionEquality().equals(other._proxies, _proxies));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,bypassTraffic,const DeepCollectionEquality().hash(_proxies));

@override
String toString() {
  return 'TailscaleProps(enable: $enable, bypassTraffic: $bypassTraffic, proxies: $proxies)';
}


}

/// @nodoc
abstract mixin class _$TailscalePropsCopyWith<$Res> implements $TailscalePropsCopyWith<$Res> {
  factory _$TailscalePropsCopyWith(_TailscaleProps value, $Res Function(_TailscaleProps) _then) = __$TailscalePropsCopyWithImpl;
@override @useResult
$Res call({
 bool enable, bool bypassTraffic, List<TailscaleProxy> proxies
});




}
/// @nodoc
class __$TailscalePropsCopyWithImpl<$Res>
    implements _$TailscalePropsCopyWith<$Res> {
  __$TailscalePropsCopyWithImpl(this._self, this._then);

  final _TailscaleProps _self;
  final $Res Function(_TailscaleProps) _then;

/// Create a copy of TailscaleProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? bypassTraffic = null,Object? proxies = null,}) {
  return _then(_TailscaleProps(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,bypassTraffic: null == bypassTraffic ? _self.bypassTraffic : bypassTraffic // ignore: cast_nullable_to_non_nullable
as bool,proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<TailscaleProxy>,
  ));
}


}


/// @nodoc
mixin _$TailscaleProxy {

 String get name; String get authKey; String get hostname; String get controlUrl; String get stateDir; bool get ephemeral; bool get udp; bool get acceptRoutes; String get exitNode; bool get exitNodeAllowLanAccess; List<String> get routes;
/// Create a copy of TailscaleProxy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TailscaleProxyCopyWith<TailscaleProxy> get copyWith => _$TailscaleProxyCopyWithImpl<TailscaleProxy>(this as TailscaleProxy, _$identity);

  /// Serializes this TailscaleProxy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TailscaleProxy&&(identical(other.name, name) || other.name == name)&&(identical(other.authKey, authKey) || other.authKey == authKey)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.controlUrl, controlUrl) || other.controlUrl == controlUrl)&&(identical(other.stateDir, stateDir) || other.stateDir == stateDir)&&(identical(other.ephemeral, ephemeral) || other.ephemeral == ephemeral)&&(identical(other.udp, udp) || other.udp == udp)&&(identical(other.acceptRoutes, acceptRoutes) || other.acceptRoutes == acceptRoutes)&&(identical(other.exitNode, exitNode) || other.exitNode == exitNode)&&(identical(other.exitNodeAllowLanAccess, exitNodeAllowLanAccess) || other.exitNodeAllowLanAccess == exitNodeAllowLanAccess)&&const DeepCollectionEquality().equals(other.routes, routes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,authKey,hostname,controlUrl,stateDir,ephemeral,udp,acceptRoutes,exitNode,exitNodeAllowLanAccess,const DeepCollectionEquality().hash(routes));

@override
String toString() {
  return 'TailscaleProxy(name: $name, authKey: $authKey, hostname: $hostname, controlUrl: $controlUrl, stateDir: $stateDir, ephemeral: $ephemeral, udp: $udp, acceptRoutes: $acceptRoutes, exitNode: $exitNode, exitNodeAllowLanAccess: $exitNodeAllowLanAccess, routes: $routes)';
}


}

/// @nodoc
abstract mixin class $TailscaleProxyCopyWith<$Res>  {
  factory $TailscaleProxyCopyWith(TailscaleProxy value, $Res Function(TailscaleProxy) _then) = _$TailscaleProxyCopyWithImpl;
@useResult
$Res call({
 String name, String authKey, String hostname, String controlUrl, String stateDir, bool ephemeral, bool udp, bool acceptRoutes, String exitNode, bool exitNodeAllowLanAccess, List<String> routes
});




}
/// @nodoc
class _$TailscaleProxyCopyWithImpl<$Res>
    implements $TailscaleProxyCopyWith<$Res> {
  _$TailscaleProxyCopyWithImpl(this._self, this._then);

  final TailscaleProxy _self;
  final $Res Function(TailscaleProxy) _then;

/// Create a copy of TailscaleProxy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? authKey = null,Object? hostname = null,Object? controlUrl = null,Object? stateDir = null,Object? ephemeral = null,Object? udp = null,Object? acceptRoutes = null,Object? exitNode = null,Object? exitNodeAllowLanAccess = null,Object? routes = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,authKey: null == authKey ? _self.authKey : authKey // ignore: cast_nullable_to_non_nullable
as String,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,controlUrl: null == controlUrl ? _self.controlUrl : controlUrl // ignore: cast_nullable_to_non_nullable
as String,stateDir: null == stateDir ? _self.stateDir : stateDir // ignore: cast_nullable_to_non_nullable
as String,ephemeral: null == ephemeral ? _self.ephemeral : ephemeral // ignore: cast_nullable_to_non_nullable
as bool,udp: null == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool,acceptRoutes: null == acceptRoutes ? _self.acceptRoutes : acceptRoutes // ignore: cast_nullable_to_non_nullable
as bool,exitNode: null == exitNode ? _self.exitNode : exitNode // ignore: cast_nullable_to_non_nullable
as String,exitNodeAllowLanAccess: null == exitNodeAllowLanAccess ? _self.exitNodeAllowLanAccess : exitNodeAllowLanAccess // ignore: cast_nullable_to_non_nullable
as bool,routes: null == routes ? _self.routes : routes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TailscaleProxy].
extension TailscaleProxyPatterns on TailscaleProxy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TailscaleProxy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TailscaleProxy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TailscaleProxy value)  $default,){
final _that = this;
switch (_that) {
case _TailscaleProxy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TailscaleProxy value)?  $default,){
final _that = this;
switch (_that) {
case _TailscaleProxy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String authKey,  String hostname,  String controlUrl,  String stateDir,  bool ephemeral,  bool udp,  bool acceptRoutes,  String exitNode,  bool exitNodeAllowLanAccess,  List<String> routes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TailscaleProxy() when $default != null:
return $default(_that.name,_that.authKey,_that.hostname,_that.controlUrl,_that.stateDir,_that.ephemeral,_that.udp,_that.acceptRoutes,_that.exitNode,_that.exitNodeAllowLanAccess,_that.routes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String authKey,  String hostname,  String controlUrl,  String stateDir,  bool ephemeral,  bool udp,  bool acceptRoutes,  String exitNode,  bool exitNodeAllowLanAccess,  List<String> routes)  $default,) {final _that = this;
switch (_that) {
case _TailscaleProxy():
return $default(_that.name,_that.authKey,_that.hostname,_that.controlUrl,_that.stateDir,_that.ephemeral,_that.udp,_that.acceptRoutes,_that.exitNode,_that.exitNodeAllowLanAccess,_that.routes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String authKey,  String hostname,  String controlUrl,  String stateDir,  bool ephemeral,  bool udp,  bool acceptRoutes,  String exitNode,  bool exitNodeAllowLanAccess,  List<String> routes)?  $default,) {final _that = this;
switch (_that) {
case _TailscaleProxy() when $default != null:
return $default(_that.name,_that.authKey,_that.hostname,_that.controlUrl,_that.stateDir,_that.ephemeral,_that.udp,_that.acceptRoutes,_that.exitNode,_that.exitNodeAllowLanAccess,_that.routes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TailscaleProxy implements TailscaleProxy {
  const _TailscaleProxy({required this.name, this.authKey = '', this.hostname = '', this.controlUrl = '', this.stateDir = '', this.ephemeral = false, this.udp = false, this.acceptRoutes = false, this.exitNode = '', this.exitNodeAllowLanAccess = false, final  List<String> routes = const []}): _routes = routes;
  factory _TailscaleProxy.fromJson(Map<String, dynamic> json) => _$TailscaleProxyFromJson(json);

@override final  String name;
@override@JsonKey() final  String authKey;
@override@JsonKey() final  String hostname;
@override@JsonKey() final  String controlUrl;
@override@JsonKey() final  String stateDir;
@override@JsonKey() final  bool ephemeral;
@override@JsonKey() final  bool udp;
@override@JsonKey() final  bool acceptRoutes;
@override@JsonKey() final  String exitNode;
@override@JsonKey() final  bool exitNodeAllowLanAccess;
 final  List<String> _routes;
@override@JsonKey() List<String> get routes {
  if (_routes is EqualUnmodifiableListView) return _routes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routes);
}


/// Create a copy of TailscaleProxy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TailscaleProxyCopyWith<_TailscaleProxy> get copyWith => __$TailscaleProxyCopyWithImpl<_TailscaleProxy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TailscaleProxyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TailscaleProxy&&(identical(other.name, name) || other.name == name)&&(identical(other.authKey, authKey) || other.authKey == authKey)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.controlUrl, controlUrl) || other.controlUrl == controlUrl)&&(identical(other.stateDir, stateDir) || other.stateDir == stateDir)&&(identical(other.ephemeral, ephemeral) || other.ephemeral == ephemeral)&&(identical(other.udp, udp) || other.udp == udp)&&(identical(other.acceptRoutes, acceptRoutes) || other.acceptRoutes == acceptRoutes)&&(identical(other.exitNode, exitNode) || other.exitNode == exitNode)&&(identical(other.exitNodeAllowLanAccess, exitNodeAllowLanAccess) || other.exitNodeAllowLanAccess == exitNodeAllowLanAccess)&&const DeepCollectionEquality().equals(other._routes, _routes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,authKey,hostname,controlUrl,stateDir,ephemeral,udp,acceptRoutes,exitNode,exitNodeAllowLanAccess,const DeepCollectionEquality().hash(_routes));

@override
String toString() {
  return 'TailscaleProxy(name: $name, authKey: $authKey, hostname: $hostname, controlUrl: $controlUrl, stateDir: $stateDir, ephemeral: $ephemeral, udp: $udp, acceptRoutes: $acceptRoutes, exitNode: $exitNode, exitNodeAllowLanAccess: $exitNodeAllowLanAccess, routes: $routes)';
}


}

/// @nodoc
abstract mixin class _$TailscaleProxyCopyWith<$Res> implements $TailscaleProxyCopyWith<$Res> {
  factory _$TailscaleProxyCopyWith(_TailscaleProxy value, $Res Function(_TailscaleProxy) _then) = __$TailscaleProxyCopyWithImpl;
@override @useResult
$Res call({
 String name, String authKey, String hostname, String controlUrl, String stateDir, bool ephemeral, bool udp, bool acceptRoutes, String exitNode, bool exitNodeAllowLanAccess, List<String> routes
});




}
/// @nodoc
class __$TailscaleProxyCopyWithImpl<$Res>
    implements _$TailscaleProxyCopyWith<$Res> {
  __$TailscaleProxyCopyWithImpl(this._self, this._then);

  final _TailscaleProxy _self;
  final $Res Function(_TailscaleProxy) _then;

/// Create a copy of TailscaleProxy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? authKey = null,Object? hostname = null,Object? controlUrl = null,Object? stateDir = null,Object? ephemeral = null,Object? udp = null,Object? acceptRoutes = null,Object? exitNode = null,Object? exitNodeAllowLanAccess = null,Object? routes = null,}) {
  return _then(_TailscaleProxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,authKey: null == authKey ? _self.authKey : authKey // ignore: cast_nullable_to_non_nullable
as String,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,controlUrl: null == controlUrl ? _self.controlUrl : controlUrl // ignore: cast_nullable_to_non_nullable
as String,stateDir: null == stateDir ? _self.stateDir : stateDir // ignore: cast_nullable_to_non_nullable
as String,ephemeral: null == ephemeral ? _self.ephemeral : ephemeral // ignore: cast_nullable_to_non_nullable
as bool,udp: null == udp ? _self.udp : udp // ignore: cast_nullable_to_non_nullable
as bool,acceptRoutes: null == acceptRoutes ? _self.acceptRoutes : acceptRoutes // ignore: cast_nullable_to_non_nullable
as bool,exitNode: null == exitNode ? _self.exitNode : exitNode // ignore: cast_nullable_to_non_nullable
as String,exitNodeAllowLanAccess: null == exitNodeAllowLanAccess ? _self.exitNodeAllowLanAccess : exitNodeAllowLanAccess // ignore: cast_nullable_to_non_nullable
as bool,routes: null == routes ? _self._routes : routes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

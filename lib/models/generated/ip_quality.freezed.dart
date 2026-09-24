// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../ip_quality.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IpQuality {

 String get ip; IpQualitySource get source; IpType get type; String? get organization; int? get asn; bool get isProxy; bool get isVpn; bool get isTor; bool get isAbuser;
/// Create a copy of IpQuality
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpQualityCopyWith<IpQuality> get copyWith => _$IpQualityCopyWithImpl<IpQuality>(this as IpQuality, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IpQuality;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpQuality&&(identical(other.ip, _this.ip) || other.ip == _this.ip)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.organization, _this.organization) || other.organization == _this.organization)&&(identical(other.asn, _this.asn) || other.asn == _this.asn)&&(identical(other.isProxy, _this.isProxy) || other.isProxy == _this.isProxy)&&(identical(other.isVpn, _this.isVpn) || other.isVpn == _this.isVpn)&&(identical(other.isTor, _this.isTor) || other.isTor == _this.isTor)&&(identical(other.isAbuser, _this.isAbuser) || other.isAbuser == _this.isAbuser));
}


@override
int get hashCode {
  final _this = this as IpQuality;
  return Object.hash(runtimeType,_this.ip,_this.source,_this.type,_this.organization,_this.asn,_this.isProxy,_this.isVpn,_this.isTor,_this.isAbuser);
}

@override
String toString() {
  final _this = this as IpQuality;
  return 'IpQuality(ip: ${_this.ip}, source: ${_this.source}, type: ${_this.type}, organization: ${_this.organization}, asn: ${_this.asn}, isProxy: ${_this.isProxy}, isVpn: ${_this.isVpn}, isTor: ${_this.isTor}, isAbuser: ${_this.isAbuser})';
}


}

/// @nodoc
abstract mixin class $IpQualityCopyWith<$Res>  {
  factory $IpQualityCopyWith(IpQuality value, $Res Function(IpQuality) _then) = _$IpQualityCopyWithImpl;
@useResult
$Res call({
 String ip, IpQualitySource source, IpType type, String? organization, int? asn, bool isProxy, bool isVpn, bool isTor, bool isAbuser
});




}
/// @nodoc
class _$IpQualityCopyWithImpl<$Res>
    implements $IpQualityCopyWith<$Res> {
  _$IpQualityCopyWithImpl(this._self, this._then);

  final IpQuality _self;
  final $Res Function(IpQuality) _then;

/// Create a copy of IpQuality
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? source = null,Object? type = null,Object? organization = freezed,Object? asn = freezed,Object? isProxy = null,Object? isVpn = null,Object? isTor = null,Object? isAbuser = null,}) {
  return _then(IpQuality(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as IpQualitySource,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IpType,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,asn: freezed == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as int?,isProxy: null == isProxy ? _self.isProxy : isProxy // ignore: cast_nullable_to_non_nullable
as bool,isVpn: null == isVpn ? _self.isVpn : isVpn // ignore: cast_nullable_to_non_nullable
as bool,isTor: null == isTor ? _self.isTor : isTor // ignore: cast_nullable_to_non_nullable
as bool,isAbuser: null == isAbuser ? _self.isAbuser : isAbuser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [IpQuality].
extension IpQualityPatterns on IpQuality {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpQuality value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpQuality() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpQuality value)  $default,){
final _that = this;
switch (_that) {
case _IpQuality():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpQuality value)?  $default,){
final _that = this;
switch (_that) {
case _IpQuality() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  IpQualitySource source,  IpType type,  String? organization,  int? asn,  bool isProxy,  bool isVpn,  bool isTor,  bool isAbuser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpQuality() when $default != null:
return $default(_that.ip,_that.source,_that.type,_that.organization,_that.asn,_that.isProxy,_that.isVpn,_that.isTor,_that.isAbuser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  IpQualitySource source,  IpType type,  String? organization,  int? asn,  bool isProxy,  bool isVpn,  bool isTor,  bool isAbuser)  $default,) {final _that = this;
switch (_that) {
case _IpQuality():
return $default(_that.ip,_that.source,_that.type,_that.organization,_that.asn,_that.isProxy,_that.isVpn,_that.isTor,_that.isAbuser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  IpQualitySource source,  IpType type,  String? organization,  int? asn,  bool isProxy,  bool isVpn,  bool isTor,  bool isAbuser)?  $default,) {final _that = this;
switch (_that) {
case _IpQuality() when $default != null:
return $default(_that.ip,_that.source,_that.type,_that.organization,_that.asn,_that.isProxy,_that.isVpn,_that.isTor,_that.isAbuser);case _:
  return null;

}
}

}

/// @nodoc


class _IpQuality implements IpQuality {
  const _IpQuality({required this.ip, required this.source, required this.type, this.organization, this.asn, this.isProxy = false, this.isVpn = false, this.isTor = false, this.isAbuser = false});
  

@override final  String ip;
@override final  IpQualitySource source;
@override final  IpType type;
@override final  String? organization;
@override final  int? asn;
@override@JsonKey() final  bool isProxy;
@override@JsonKey() final  bool isVpn;
@override@JsonKey() final  bool isTor;
@override@JsonKey() final  bool isAbuser;

/// Create a copy of IpQuality
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpQualityCopyWith<_IpQuality> get copyWith => __$IpQualityCopyWithImpl<_IpQuality>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpQuality&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.source, source) || other.source == source)&&(identical(other.type, type) || other.type == type)&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.asn, asn) || other.asn == asn)&&(identical(other.isProxy, isProxy) || other.isProxy == isProxy)&&(identical(other.isVpn, isVpn) || other.isVpn == isVpn)&&(identical(other.isTor, isTor) || other.isTor == isTor)&&(identical(other.isAbuser, isAbuser) || other.isAbuser == isAbuser));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ip,source,type,organization,asn,isProxy,isVpn,isTor,isAbuser);
}

@override
String toString() {
    return 'IpQuality(ip: $ip, source: $source, type: $type, organization: $organization, asn: $asn, isProxy: $isProxy, isVpn: $isVpn, isTor: $isTor, isAbuser: $isAbuser)';
}


}

/// @nodoc
abstract mixin class _$IpQualityCopyWith<$Res> implements $IpQualityCopyWith<$Res> {
  factory _$IpQualityCopyWith(_IpQuality value, $Res Function(_IpQuality) _then) = __$IpQualityCopyWithImpl;
@override @useResult
$Res call({
 String ip, IpQualitySource source, IpType type, String? organization, int? asn, bool isProxy, bool isVpn, bool isTor, bool isAbuser
});




}
/// @nodoc
class __$IpQualityCopyWithImpl<$Res>
    implements _$IpQualityCopyWith<$Res> {
  __$IpQualityCopyWithImpl(this._self, this._then);

  final _IpQuality _self;
  final $Res Function(_IpQuality) _then;

/// Create a copy of IpQuality
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? source = null,Object? type = null,Object? organization = freezed,Object? asn = freezed,Object? isProxy = null,Object? isVpn = null,Object? isTor = null,Object? isAbuser = null,}) {
  return _then(_IpQuality(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as IpQualitySource,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as IpType,organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,asn: freezed == asn ? _self.asn : asn // ignore: cast_nullable_to_non_nullable
as int?,isProxy: null == isProxy ? _self.isProxy : isProxy // ignore: cast_nullable_to_non_nullable
as bool,isVpn: null == isVpn ? _self.isVpn : isVpn // ignore: cast_nullable_to_non_nullable
as bool,isTor: null == isTor ? _self.isTor : isTor // ignore: cast_nullable_to_non_nullable
as bool,isAbuser: null == isAbuser ? _self.isAbuser : isAbuser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionInfo {

 int get upload; int get download; int get total; int get expire;
/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith => _$SubscriptionInfoCopyWithImpl<SubscriptionInfo>(this as SubscriptionInfo, _$identity);

  /// Serializes this SubscriptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,upload,download,total,expire);

@override
String toString() {
  return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class $SubscriptionInfoCopyWith<$Res>  {
  factory $SubscriptionInfoCopyWith(SubscriptionInfo value, $Res Function(SubscriptionInfo) _then) = _$SubscriptionInfoCopyWithImpl;
@useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final SubscriptionInfo _self;
  final $Res Function(SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
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


/// Adds pattern-matching-related methods to [SubscriptionInfo].
extension SubscriptionInfoPatterns on SubscriptionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int upload,  int download,  int total,  int expire)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int upload,  int download,  int total,  int expire)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionInfo() when $default != null:
return $default(_that.upload,_that.download,_that.total,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionInfo implements SubscriptionInfo {
  const _SubscriptionInfo({this.upload = 0, this.download = 0, this.total = 0, this.expire = 0});
  factory _SubscriptionInfo.fromJson(Map<String, dynamic> json) => _$SubscriptionInfoFromJson(json);

@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override@JsonKey() final  int total;
@override@JsonKey() final  int expire;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionInfoCopyWith<_SubscriptionInfo> get copyWith => __$SubscriptionInfoCopyWithImpl<_SubscriptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionInfo&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.total, total) || other.total == total)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,upload,download,total,expire);

@override
String toString() {
  return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionInfoCopyWith<$Res> implements $SubscriptionInfoCopyWith<$Res> {
  factory _$SubscriptionInfoCopyWith(_SubscriptionInfo value, $Res Function(_SubscriptionInfo) _then) = __$SubscriptionInfoCopyWithImpl;
@override @useResult
$Res call({
 int upload, int download, int total, int expire
});




}
/// @nodoc
class __$SubscriptionInfoCopyWithImpl<$Res>
    implements _$SubscriptionInfoCopyWith<$Res> {
  __$SubscriptionInfoCopyWithImpl(this._self, this._then);

  final _SubscriptionInfo _self;
  final $Res Function(_SubscriptionInfo) _then;

/// Create a copy of SubscriptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? upload = null,Object? download = null,Object? total = null,Object? expire = null,}) {
  return _then(_SubscriptionInfo(
upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Profile {

 String get id; String? get label; String? get currentGroupName; String get url; DateTime? get lastUpdateDate; Duration get autoUpdateDuration; SubscriptionInfo? get subscriptionInfo; bool get autoUpdate; Map<String, String> get selectedMap; Set<String> get unfoldSet; OverrideData get overrideData; Overwrite get overwrite;@JsonKey(includeToJson: false, includeFromJson: false) bool get isUpdating;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap)&&const DeepCollectionEquality().equals(other.unfoldSet, unfoldSet)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData)&&(identical(other.overwrite, overwrite) || other.overwrite == overwrite)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,currentGroupName,url,lastUpdateDate,autoUpdateDuration,subscriptionInfo,autoUpdate,const DeepCollectionEquality().hash(selectedMap),const DeepCollectionEquality().hash(unfoldSet),overrideData,overwrite,isUpdating);

@override
String toString() {
  return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, overrideData: $overrideData, overwrite: $overwrite, isUpdating: $isUpdating)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String? label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, OverrideData overrideData, Overwrite overwrite,@JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating
});


$SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;$OverrideDataCopyWith<$Res> get overrideData;$OverwriteCopyWith<$Res> get overwrite;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overrideData = null,Object? overwrite = null,Object? isUpdating = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self.unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,overrideData: null == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as Overwrite,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Profile
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
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res> get overrideData {
  
  return $OverrideDataCopyWith<$Res>(_self.overrideData, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverwriteCopyWith<$Res> get overwrite {
  
  return $OverwriteCopyWith<$Res>(_self.overwrite, (value) {
    return _then(_self.copyWith(overwrite: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  OverrideData overrideData,  Overwrite overwrite, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.overwrite,_that.isUpdating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  OverrideData overrideData,  Overwrite overwrite, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.overwrite,_that.isUpdating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  String? currentGroupName,  String url,  DateTime? lastUpdateDate,  Duration autoUpdateDuration,  SubscriptionInfo? subscriptionInfo,  bool autoUpdate,  Map<String, String> selectedMap,  Set<String> unfoldSet,  OverrideData overrideData,  Overwrite overwrite, @JsonKey(includeToJson: false, includeFromJson: false)  bool isUpdating)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.label,_that.currentGroupName,_that.url,_that.lastUpdateDate,_that.autoUpdateDuration,_that.subscriptionInfo,_that.autoUpdate,_that.selectedMap,_that.unfoldSet,_that.overrideData,_that.overwrite,_that.isUpdating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, this.label, this.currentGroupName, this.url = '', this.lastUpdateDate, required this.autoUpdateDuration, this.subscriptionInfo, this.autoUpdate = true, final  Map<String, String> selectedMap = const {}, final  Set<String> unfoldSet = const {}, this.overrideData = const OverrideData(), this.overwrite = const Overwrite(), @JsonKey(includeToJson: false, includeFromJson: false) this.isUpdating = false}): _selectedMap = selectedMap,_unfoldSet = unfoldSet;
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String? label;
@override final  String? currentGroupName;
@override@JsonKey() final  String url;
@override final  DateTime? lastUpdateDate;
@override final  Duration autoUpdateDuration;
@override final  SubscriptionInfo? subscriptionInfo;
@override@JsonKey() final  bool autoUpdate;
 final  Map<String, String> _selectedMap;
@override@JsonKey() Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

 final  Set<String> _unfoldSet;
@override@JsonKey() Set<String> get unfoldSet {
  if (_unfoldSet is EqualUnmodifiableSetView) return _unfoldSet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unfoldSet);
}

@override@JsonKey() final  OverrideData overrideData;
@override@JsonKey() final  Overwrite overwrite;
@override@JsonKey(includeToJson: false, includeFromJson: false) final  bool isUpdating;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.url, url) || other.url == url)&&(identical(other.lastUpdateDate, lastUpdateDate) || other.lastUpdateDate == lastUpdateDate)&&(identical(other.autoUpdateDuration, autoUpdateDuration) || other.autoUpdateDuration == autoUpdateDuration)&&(identical(other.subscriptionInfo, subscriptionInfo) || other.subscriptionInfo == subscriptionInfo)&&(identical(other.autoUpdate, autoUpdate) || other.autoUpdate == autoUpdate)&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap)&&const DeepCollectionEquality().equals(other._unfoldSet, _unfoldSet)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData)&&(identical(other.overwrite, overwrite) || other.overwrite == overwrite)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,currentGroupName,url,lastUpdateDate,autoUpdateDuration,subscriptionInfo,autoUpdate,const DeepCollectionEquality().hash(_selectedMap),const DeepCollectionEquality().hash(_unfoldSet),overrideData,overwrite,isUpdating);

@override
String toString() {
  return 'Profile(id: $id, label: $label, currentGroupName: $currentGroupName, url: $url, lastUpdateDate: $lastUpdateDate, autoUpdateDuration: $autoUpdateDuration, subscriptionInfo: $subscriptionInfo, autoUpdate: $autoUpdate, selectedMap: $selectedMap, unfoldSet: $unfoldSet, overrideData: $overrideData, overwrite: $overwrite, isUpdating: $isUpdating)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, String? currentGroupName, String url, DateTime? lastUpdateDate, Duration autoUpdateDuration, SubscriptionInfo? subscriptionInfo, bool autoUpdate, Map<String, String> selectedMap, Set<String> unfoldSet, OverrideData overrideData, Overwrite overwrite,@JsonKey(includeToJson: false, includeFromJson: false) bool isUpdating
});


@override $SubscriptionInfoCopyWith<$Res>? get subscriptionInfo;@override $OverrideDataCopyWith<$Res> get overrideData;@override $OverwriteCopyWith<$Res> get overwrite;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? currentGroupName = freezed,Object? url = null,Object? lastUpdateDate = freezed,Object? autoUpdateDuration = null,Object? subscriptionInfo = freezed,Object? autoUpdate = null,Object? selectedMap = null,Object? unfoldSet = null,Object? overrideData = null,Object? overwrite = null,Object? isUpdating = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,lastUpdateDate: freezed == lastUpdateDate ? _self.lastUpdateDate : lastUpdateDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoUpdateDuration: null == autoUpdateDuration ? _self.autoUpdateDuration : autoUpdateDuration // ignore: cast_nullable_to_non_nullable
as Duration,subscriptionInfo: freezed == subscriptionInfo ? _self.subscriptionInfo : subscriptionInfo // ignore: cast_nullable_to_non_nullable
as SubscriptionInfo?,autoUpdate: null == autoUpdate ? _self.autoUpdate : autoUpdate // ignore: cast_nullable_to_non_nullable
as bool,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,unfoldSet: null == unfoldSet ? _self._unfoldSet : unfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,overrideData: null == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData,overwrite: null == overwrite ? _self.overwrite : overwrite // ignore: cast_nullable_to_non_nullable
as Overwrite,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Profile
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
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res> get overrideData {
  
  return $OverrideDataCopyWith<$Res>(_self.overrideData, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverwriteCopyWith<$Res> get overwrite {
  
  return $OverwriteCopyWith<$Res>(_self.overwrite, (value) {
    return _then(_self.copyWith(overwrite: value));
  });
}
}


/// @nodoc
mixin _$Overwrite {

 OverwriteType get type; StandardOverwrite get standardOverwrite; ScriptOverwrite get scriptOverwrite;
/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverwriteCopyWith<Overwrite> get copyWith => _$OverwriteCopyWithImpl<Overwrite>(this as Overwrite, _$identity);

  /// Serializes this Overwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Overwrite&&(identical(other.type, type) || other.type == type)&&(identical(other.standardOverwrite, standardOverwrite) || other.standardOverwrite == standardOverwrite)&&(identical(other.scriptOverwrite, scriptOverwrite) || other.scriptOverwrite == scriptOverwrite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,standardOverwrite,scriptOverwrite);

@override
String toString() {
  return 'Overwrite(type: $type, standardOverwrite: $standardOverwrite, scriptOverwrite: $scriptOverwrite)';
}


}

/// @nodoc
abstract mixin class $OverwriteCopyWith<$Res>  {
  factory $OverwriteCopyWith(Overwrite value, $Res Function(Overwrite) _then) = _$OverwriteCopyWithImpl;
@useResult
$Res call({
 OverwriteType type, StandardOverwrite standardOverwrite, ScriptOverwrite scriptOverwrite
});


$StandardOverwriteCopyWith<$Res> get standardOverwrite;$ScriptOverwriteCopyWith<$Res> get scriptOverwrite;

}
/// @nodoc
class _$OverwriteCopyWithImpl<$Res>
    implements $OverwriteCopyWith<$Res> {
  _$OverwriteCopyWithImpl(this._self, this._then);

  final Overwrite _self;
  final $Res Function(Overwrite) _then;

/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? standardOverwrite = null,Object? scriptOverwrite = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OverwriteType,standardOverwrite: null == standardOverwrite ? _self.standardOverwrite : standardOverwrite // ignore: cast_nullable_to_non_nullable
as StandardOverwrite,scriptOverwrite: null == scriptOverwrite ? _self.scriptOverwrite : scriptOverwrite // ignore: cast_nullable_to_non_nullable
as ScriptOverwrite,
  ));
}
/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StandardOverwriteCopyWith<$Res> get standardOverwrite {
  
  return $StandardOverwriteCopyWith<$Res>(_self.standardOverwrite, (value) {
    return _then(_self.copyWith(standardOverwrite: value));
  });
}/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptOverwriteCopyWith<$Res> get scriptOverwrite {
  
  return $ScriptOverwriteCopyWith<$Res>(_self.scriptOverwrite, (value) {
    return _then(_self.copyWith(scriptOverwrite: value));
  });
}
}


/// Adds pattern-matching-related methods to [Overwrite].
extension OverwritePatterns on Overwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Overwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Overwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Overwrite value)  $default,){
final _that = this;
switch (_that) {
case _Overwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Overwrite value)?  $default,){
final _that = this;
switch (_that) {
case _Overwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OverwriteType type,  StandardOverwrite standardOverwrite,  ScriptOverwrite scriptOverwrite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Overwrite() when $default != null:
return $default(_that.type,_that.standardOverwrite,_that.scriptOverwrite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OverwriteType type,  StandardOverwrite standardOverwrite,  ScriptOverwrite scriptOverwrite)  $default,) {final _that = this;
switch (_that) {
case _Overwrite():
return $default(_that.type,_that.standardOverwrite,_that.scriptOverwrite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OverwriteType type,  StandardOverwrite standardOverwrite,  ScriptOverwrite scriptOverwrite)?  $default,) {final _that = this;
switch (_that) {
case _Overwrite() when $default != null:
return $default(_that.type,_that.standardOverwrite,_that.scriptOverwrite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Overwrite implements Overwrite {
  const _Overwrite({this.type = OverwriteType.standard, this.standardOverwrite = const StandardOverwrite(), this.scriptOverwrite = const ScriptOverwrite()});
  factory _Overwrite.fromJson(Map<String, dynamic> json) => _$OverwriteFromJson(json);

@override@JsonKey() final  OverwriteType type;
@override@JsonKey() final  StandardOverwrite standardOverwrite;
@override@JsonKey() final  ScriptOverwrite scriptOverwrite;

/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverwriteCopyWith<_Overwrite> get copyWith => __$OverwriteCopyWithImpl<_Overwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Overwrite&&(identical(other.type, type) || other.type == type)&&(identical(other.standardOverwrite, standardOverwrite) || other.standardOverwrite == standardOverwrite)&&(identical(other.scriptOverwrite, scriptOverwrite) || other.scriptOverwrite == scriptOverwrite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,standardOverwrite,scriptOverwrite);

@override
String toString() {
  return 'Overwrite(type: $type, standardOverwrite: $standardOverwrite, scriptOverwrite: $scriptOverwrite)';
}


}

/// @nodoc
abstract mixin class _$OverwriteCopyWith<$Res> implements $OverwriteCopyWith<$Res> {
  factory _$OverwriteCopyWith(_Overwrite value, $Res Function(_Overwrite) _then) = __$OverwriteCopyWithImpl;
@override @useResult
$Res call({
 OverwriteType type, StandardOverwrite standardOverwrite, ScriptOverwrite scriptOverwrite
});


@override $StandardOverwriteCopyWith<$Res> get standardOverwrite;@override $ScriptOverwriteCopyWith<$Res> get scriptOverwrite;

}
/// @nodoc
class __$OverwriteCopyWithImpl<$Res>
    implements _$OverwriteCopyWith<$Res> {
  __$OverwriteCopyWithImpl(this._self, this._then);

  final _Overwrite _self;
  final $Res Function(_Overwrite) _then;

/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? standardOverwrite = null,Object? scriptOverwrite = null,}) {
  return _then(_Overwrite(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OverwriteType,standardOverwrite: null == standardOverwrite ? _self.standardOverwrite : standardOverwrite // ignore: cast_nullable_to_non_nullable
as StandardOverwrite,scriptOverwrite: null == scriptOverwrite ? _self.scriptOverwrite : scriptOverwrite // ignore: cast_nullable_to_non_nullable
as ScriptOverwrite,
  ));
}

/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StandardOverwriteCopyWith<$Res> get standardOverwrite {
  
  return $StandardOverwriteCopyWith<$Res>(_self.standardOverwrite, (value) {
    return _then(_self.copyWith(standardOverwrite: value));
  });
}/// Create a copy of Overwrite
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptOverwriteCopyWith<$Res> get scriptOverwrite {
  
  return $ScriptOverwriteCopyWith<$Res>(_self.scriptOverwrite, (value) {
    return _then(_self.copyWith(scriptOverwrite: value));
  });
}
}


/// @nodoc
mixin _$StandardOverwrite {

 List<Rule> get addedRules; List<String> get disabledRuleIds;
/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StandardOverwriteCopyWith<StandardOverwrite> get copyWith => _$StandardOverwriteCopyWithImpl<StandardOverwrite>(this as StandardOverwrite, _$identity);

  /// Serializes this StandardOverwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StandardOverwrite&&const DeepCollectionEquality().equals(other.addedRules, addedRules)&&const DeepCollectionEquality().equals(other.disabledRuleIds, disabledRuleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(addedRules),const DeepCollectionEquality().hash(disabledRuleIds));

@override
String toString() {
  return 'StandardOverwrite(addedRules: $addedRules, disabledRuleIds: $disabledRuleIds)';
}


}

/// @nodoc
abstract mixin class $StandardOverwriteCopyWith<$Res>  {
  factory $StandardOverwriteCopyWith(StandardOverwrite value, $Res Function(StandardOverwrite) _then) = _$StandardOverwriteCopyWithImpl;
@useResult
$Res call({
 List<Rule> addedRules, List<String> disabledRuleIds
});




}
/// @nodoc
class _$StandardOverwriteCopyWithImpl<$Res>
    implements $StandardOverwriteCopyWith<$Res> {
  _$StandardOverwriteCopyWithImpl(this._self, this._then);

  final StandardOverwrite _self;
  final $Res Function(StandardOverwrite) _then;

/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? addedRules = null,Object? disabledRuleIds = null,}) {
  return _then(_self.copyWith(
addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,disabledRuleIds: null == disabledRuleIds ? _self.disabledRuleIds : disabledRuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [StandardOverwrite].
extension StandardOverwritePatterns on StandardOverwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StandardOverwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StandardOverwrite value)  $default,){
final _that = this;
switch (_that) {
case _StandardOverwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StandardOverwrite value)?  $default,){
final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Rule> addedRules,  List<String> disabledRuleIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
return $default(_that.addedRules,_that.disabledRuleIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Rule> addedRules,  List<String> disabledRuleIds)  $default,) {final _that = this;
switch (_that) {
case _StandardOverwrite():
return $default(_that.addedRules,_that.disabledRuleIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Rule> addedRules,  List<String> disabledRuleIds)?  $default,) {final _that = this;
switch (_that) {
case _StandardOverwrite() when $default != null:
return $default(_that.addedRules,_that.disabledRuleIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StandardOverwrite implements StandardOverwrite {
  const _StandardOverwrite({final  List<Rule> addedRules = const [], final  List<String> disabledRuleIds = const []}): _addedRules = addedRules,_disabledRuleIds = disabledRuleIds;
  factory _StandardOverwrite.fromJson(Map<String, dynamic> json) => _$StandardOverwriteFromJson(json);

 final  List<Rule> _addedRules;
@override@JsonKey() List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

 final  List<String> _disabledRuleIds;
@override@JsonKey() List<String> get disabledRuleIds {
  if (_disabledRuleIds is EqualUnmodifiableListView) return _disabledRuleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_disabledRuleIds);
}


/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StandardOverwriteCopyWith<_StandardOverwrite> get copyWith => __$StandardOverwriteCopyWithImpl<_StandardOverwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StandardOverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StandardOverwrite&&const DeepCollectionEquality().equals(other._addedRules, _addedRules)&&const DeepCollectionEquality().equals(other._disabledRuleIds, _disabledRuleIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_addedRules),const DeepCollectionEquality().hash(_disabledRuleIds));

@override
String toString() {
  return 'StandardOverwrite(addedRules: $addedRules, disabledRuleIds: $disabledRuleIds)';
}


}

/// @nodoc
abstract mixin class _$StandardOverwriteCopyWith<$Res> implements $StandardOverwriteCopyWith<$Res> {
  factory _$StandardOverwriteCopyWith(_StandardOverwrite value, $Res Function(_StandardOverwrite) _then) = __$StandardOverwriteCopyWithImpl;
@override @useResult
$Res call({
 List<Rule> addedRules, List<String> disabledRuleIds
});




}
/// @nodoc
class __$StandardOverwriteCopyWithImpl<$Res>
    implements _$StandardOverwriteCopyWith<$Res> {
  __$StandardOverwriteCopyWithImpl(this._self, this._then);

  final _StandardOverwrite _self;
  final $Res Function(_StandardOverwrite) _then;

/// Create a copy of StandardOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? addedRules = null,Object? disabledRuleIds = null,}) {
  return _then(_StandardOverwrite(
addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,disabledRuleIds: null == disabledRuleIds ? _self._disabledRuleIds : disabledRuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$ScriptOverwrite {

 String? get scriptId;
/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptOverwriteCopyWith<ScriptOverwrite> get copyWith => _$ScriptOverwriteCopyWithImpl<ScriptOverwrite>(this as ScriptOverwrite, _$identity);

  /// Serializes this ScriptOverwrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptOverwrite&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scriptId);

@override
String toString() {
  return 'ScriptOverwrite(scriptId: $scriptId)';
}


}

/// @nodoc
abstract mixin class $ScriptOverwriteCopyWith<$Res>  {
  factory $ScriptOverwriteCopyWith(ScriptOverwrite value, $Res Function(ScriptOverwrite) _then) = _$ScriptOverwriteCopyWithImpl;
@useResult
$Res call({
 String? scriptId
});




}
/// @nodoc
class _$ScriptOverwriteCopyWithImpl<$Res>
    implements $ScriptOverwriteCopyWith<$Res> {
  _$ScriptOverwriteCopyWithImpl(this._self, this._then);

  final ScriptOverwrite _self;
  final $Res Function(ScriptOverwrite) _then;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scriptId = freezed,}) {
  return _then(_self.copyWith(
scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptOverwrite].
extension ScriptOverwritePatterns on ScriptOverwrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptOverwrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptOverwrite value)  $default,){
final _that = this;
switch (_that) {
case _ScriptOverwrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptOverwrite value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? scriptId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
return $default(_that.scriptId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? scriptId)  $default,) {final _that = this;
switch (_that) {
case _ScriptOverwrite():
return $default(_that.scriptId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? scriptId)?  $default,) {final _that = this;
switch (_that) {
case _ScriptOverwrite() when $default != null:
return $default(_that.scriptId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptOverwrite implements ScriptOverwrite {
  const _ScriptOverwrite({this.scriptId});
  factory _ScriptOverwrite.fromJson(Map<String, dynamic> json) => _$ScriptOverwriteFromJson(json);

@override final  String? scriptId;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptOverwriteCopyWith<_ScriptOverwrite> get copyWith => __$ScriptOverwriteCopyWithImpl<_ScriptOverwrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptOverwriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptOverwrite&&(identical(other.scriptId, scriptId) || other.scriptId == scriptId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,scriptId);

@override
String toString() {
  return 'ScriptOverwrite(scriptId: $scriptId)';
}


}

/// @nodoc
abstract mixin class _$ScriptOverwriteCopyWith<$Res> implements $ScriptOverwriteCopyWith<$Res> {
  factory _$ScriptOverwriteCopyWith(_ScriptOverwrite value, $Res Function(_ScriptOverwrite) _then) = __$ScriptOverwriteCopyWithImpl;
@override @useResult
$Res call({
 String? scriptId
});




}
/// @nodoc
class __$ScriptOverwriteCopyWithImpl<$Res>
    implements _$ScriptOverwriteCopyWith<$Res> {
  __$ScriptOverwriteCopyWithImpl(this._self, this._then);

  final _ScriptOverwrite _self;
  final $Res Function(_ScriptOverwrite) _then;

/// Create a copy of ScriptOverwrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scriptId = freezed,}) {
  return _then(_ScriptOverwrite(
scriptId: freezed == scriptId ? _self.scriptId : scriptId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OverrideData {

 bool get enable; OverrideRule get rule;
/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<OverrideData> get copyWith => _$OverrideDataCopyWithImpl<OverrideData>(this as OverrideData, _$identity);

  /// Serializes this OverrideData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverrideData&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.rule, rule) || other.rule == rule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,rule);

@override
String toString() {
  return 'OverrideData(enable: $enable, rule: $rule)';
}


}

/// @nodoc
abstract mixin class $OverrideDataCopyWith<$Res>  {
  factory $OverrideDataCopyWith(OverrideData value, $Res Function(OverrideData) _then) = _$OverrideDataCopyWithImpl;
@useResult
$Res call({
 bool enable, OverrideRule rule
});


$OverrideRuleCopyWith<$Res> get rule;

}
/// @nodoc
class _$OverrideDataCopyWithImpl<$Res>
    implements $OverrideDataCopyWith<$Res> {
  _$OverrideDataCopyWithImpl(this._self, this._then);

  final OverrideData _self;
  final $Res Function(OverrideData) _then;

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enable = null,Object? rule = null,}) {
  return _then(_self.copyWith(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as OverrideRule,
  ));
}
/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideRuleCopyWith<$Res> get rule {
  
  return $OverrideRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}


/// Adds pattern-matching-related methods to [OverrideData].
extension OverrideDataPatterns on OverrideData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverrideData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverrideData value)  $default,){
final _that = this;
switch (_that) {
case _OverrideData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverrideData value)?  $default,){
final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enable,  OverrideRule rule)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
return $default(_that.enable,_that.rule);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enable,  OverrideRule rule)  $default,) {final _that = this;
switch (_that) {
case _OverrideData():
return $default(_that.enable,_that.rule);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enable,  OverrideRule rule)?  $default,) {final _that = this;
switch (_that) {
case _OverrideData() when $default != null:
return $default(_that.enable,_that.rule);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverrideData implements OverrideData {
  const _OverrideData({this.enable = false, this.rule = const OverrideRule()});
  factory _OverrideData.fromJson(Map<String, dynamic> json) => _$OverrideDataFromJson(json);

@override@JsonKey() final  bool enable;
@override@JsonKey() final  OverrideRule rule;

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverrideDataCopyWith<_OverrideData> get copyWith => __$OverrideDataCopyWithImpl<_OverrideData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverrideDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverrideData&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.rule, rule) || other.rule == rule));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enable,rule);

@override
String toString() {
  return 'OverrideData(enable: $enable, rule: $rule)';
}


}

/// @nodoc
abstract mixin class _$OverrideDataCopyWith<$Res> implements $OverrideDataCopyWith<$Res> {
  factory _$OverrideDataCopyWith(_OverrideData value, $Res Function(_OverrideData) _then) = __$OverrideDataCopyWithImpl;
@override @useResult
$Res call({
 bool enable, OverrideRule rule
});


@override $OverrideRuleCopyWith<$Res> get rule;

}
/// @nodoc
class __$OverrideDataCopyWithImpl<$Res>
    implements _$OverrideDataCopyWith<$Res> {
  __$OverrideDataCopyWithImpl(this._self, this._then);

  final _OverrideData _self;
  final $Res Function(_OverrideData) _then;

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enable = null,Object? rule = null,}) {
  return _then(_OverrideData(
enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as bool,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as OverrideRule,
  ));
}

/// Create a copy of OverrideData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideRuleCopyWith<$Res> get rule {
  
  return $OverrideRuleCopyWith<$Res>(_self.rule, (value) {
    return _then(_self.copyWith(rule: value));
  });
}
}


/// @nodoc
mixin _$OverrideRule {

 OverrideRuleType get type; List<Rule> get overrideRules; List<Rule> get addedRules;
/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverrideRuleCopyWith<OverrideRule> get copyWith => _$OverrideRuleCopyWithImpl<OverrideRule>(this as OverrideRule, _$identity);

  /// Serializes this OverrideRule to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverrideRule&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.overrideRules, overrideRules)&&const DeepCollectionEquality().equals(other.addedRules, addedRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(overrideRules),const DeepCollectionEquality().hash(addedRules));

@override
String toString() {
  return 'OverrideRule(type: $type, overrideRules: $overrideRules, addedRules: $addedRules)';
}


}

/// @nodoc
abstract mixin class $OverrideRuleCopyWith<$Res>  {
  factory $OverrideRuleCopyWith(OverrideRule value, $Res Function(OverrideRule) _then) = _$OverrideRuleCopyWithImpl;
@useResult
$Res call({
 OverrideRuleType type, List<Rule> overrideRules, List<Rule> addedRules
});




}
/// @nodoc
class _$OverrideRuleCopyWithImpl<$Res>
    implements $OverrideRuleCopyWith<$Res> {
  _$OverrideRuleCopyWithImpl(this._self, this._then);

  final OverrideRule _self;
  final $Res Function(OverrideRule) _then;

/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? overrideRules = null,Object? addedRules = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OverrideRuleType,overrideRules: null == overrideRules ? _self.overrideRules : overrideRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}

}


/// Adds pattern-matching-related methods to [OverrideRule].
extension OverrideRulePatterns on OverrideRule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverrideRule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverrideRule value)  $default,){
final _that = this;
switch (_that) {
case _OverrideRule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverrideRule value)?  $default,){
final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OverrideRuleType type,  List<Rule> overrideRules,  List<Rule> addedRules)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
return $default(_that.type,_that.overrideRules,_that.addedRules);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OverrideRuleType type,  List<Rule> overrideRules,  List<Rule> addedRules)  $default,) {final _that = this;
switch (_that) {
case _OverrideRule():
return $default(_that.type,_that.overrideRules,_that.addedRules);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OverrideRuleType type,  List<Rule> overrideRules,  List<Rule> addedRules)?  $default,) {final _that = this;
switch (_that) {
case _OverrideRule() when $default != null:
return $default(_that.type,_that.overrideRules,_that.addedRules);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverrideRule implements OverrideRule {
  const _OverrideRule({this.type = OverrideRuleType.added, final  List<Rule> overrideRules = const [], final  List<Rule> addedRules = const []}): _overrideRules = overrideRules,_addedRules = addedRules;
  factory _OverrideRule.fromJson(Map<String, dynamic> json) => _$OverrideRuleFromJson(json);

@override@JsonKey() final  OverrideRuleType type;
 final  List<Rule> _overrideRules;
@override@JsonKey() List<Rule> get overrideRules {
  if (_overrideRules is EqualUnmodifiableListView) return _overrideRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_overrideRules);
}

 final  List<Rule> _addedRules;
@override@JsonKey() List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}


/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverrideRuleCopyWith<_OverrideRule> get copyWith => __$OverrideRuleCopyWithImpl<_OverrideRule>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverrideRuleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverrideRule&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._overrideRules, _overrideRules)&&const DeepCollectionEquality().equals(other._addedRules, _addedRules));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_overrideRules),const DeepCollectionEquality().hash(_addedRules));

@override
String toString() {
  return 'OverrideRule(type: $type, overrideRules: $overrideRules, addedRules: $addedRules)';
}


}

/// @nodoc
abstract mixin class _$OverrideRuleCopyWith<$Res> implements $OverrideRuleCopyWith<$Res> {
  factory _$OverrideRuleCopyWith(_OverrideRule value, $Res Function(_OverrideRule) _then) = __$OverrideRuleCopyWithImpl;
@override @useResult
$Res call({
 OverrideRuleType type, List<Rule> overrideRules, List<Rule> addedRules
});




}
/// @nodoc
class __$OverrideRuleCopyWithImpl<$Res>
    implements _$OverrideRuleCopyWith<$Res> {
  __$OverrideRuleCopyWithImpl(this._self, this._then);

  final _OverrideRule _self;
  final $Res Function(_OverrideRule) _then;

/// Create a copy of OverrideRule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? overrideRules = null,Object? addedRules = null,}) {
  return _then(_OverrideRule(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OverrideRuleType,overrideRules: null == overrideRules ? _self._overrideRules : overrideRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../common.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationItem {

 Icon get icon; PageLabel get label; String? get description; WidgetBuilder get builder; bool get keep; String? get path; List<NavigationItemMode> get modes;
/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationItemCopyWith<NavigationItem> get copyWith => _$NavigationItemCopyWithImpl<NavigationItem>(this as NavigationItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationItem&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.builder, builder) || other.builder == builder)&&(identical(other.keep, keep) || other.keep == keep)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other.modes, modes));
}


@override
int get hashCode => Object.hash(runtimeType,icon,label,description,builder,keep,path,const DeepCollectionEquality().hash(modes));

@override
String toString() {
  return 'NavigationItem(icon: $icon, label: $label, description: $description, builder: $builder, keep: $keep, path: $path, modes: $modes)';
}


}

/// @nodoc
abstract mixin class $NavigationItemCopyWith<$Res>  {
  factory $NavigationItemCopyWith(NavigationItem value, $Res Function(NavigationItem) _then) = _$NavigationItemCopyWithImpl;
@useResult
$Res call({
 Icon icon, PageLabel label, String? description, WidgetBuilder builder, bool keep, String? path, List<NavigationItemMode> modes
});




}
/// @nodoc
class _$NavigationItemCopyWithImpl<$Res>
    implements $NavigationItemCopyWith<$Res> {
  _$NavigationItemCopyWithImpl(this._self, this._then);

  final NavigationItem _self;
  final $Res Function(NavigationItem) _then;

/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? label = null,Object? description = freezed,Object? builder = null,Object? keep = null,Object? path = freezed,Object? modes = null,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as Icon,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as PageLabel,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,builder: null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as WidgetBuilder,keep: null == keep ? _self.keep : keep // ignore: cast_nullable_to_non_nullable
as bool,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self.modes : modes // ignore: cast_nullable_to_non_nullable
as List<NavigationItemMode>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationItem].
extension NavigationItemPatterns on NavigationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationItem value)  $default,){
final _that = this;
switch (_that) {
case _NavigationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Icon icon,  PageLabel label,  String? description,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
return $default(_that.icon,_that.label,_that.description,_that.builder,_that.keep,_that.path,_that.modes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Icon icon,  PageLabel label,  String? description,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)  $default,) {final _that = this;
switch (_that) {
case _NavigationItem():
return $default(_that.icon,_that.label,_that.description,_that.builder,_that.keep,_that.path,_that.modes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Icon icon,  PageLabel label,  String? description,  WidgetBuilder builder,  bool keep,  String? path,  List<NavigationItemMode> modes)?  $default,) {final _that = this;
switch (_that) {
case _NavigationItem() when $default != null:
return $default(_that.icon,_that.label,_that.description,_that.builder,_that.keep,_that.path,_that.modes);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationItem implements NavigationItem {
  const _NavigationItem({required this.icon, required this.label, this.description, required this.builder, this.keep = true, this.path, final  List<NavigationItemMode> modes = const [NavigationItemMode.mobile, NavigationItemMode.desktop]}): _modes = modes;
  

@override final  Icon icon;
@override final  PageLabel label;
@override final  String? description;
@override final  WidgetBuilder builder;
@override@JsonKey() final  bool keep;
@override final  String? path;
 final  List<NavigationItemMode> _modes;
@override@JsonKey() List<NavigationItemMode> get modes {
  if (_modes is EqualUnmodifiableListView) return _modes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modes);
}


/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationItemCopyWith<_NavigationItem> get copyWith => __$NavigationItemCopyWithImpl<_NavigationItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationItem&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.builder, builder) || other.builder == builder)&&(identical(other.keep, keep) || other.keep == keep)&&(identical(other.path, path) || other.path == path)&&const DeepCollectionEquality().equals(other._modes, _modes));
}


@override
int get hashCode => Object.hash(runtimeType,icon,label,description,builder,keep,path,const DeepCollectionEquality().hash(_modes));

@override
String toString() {
  return 'NavigationItem(icon: $icon, label: $label, description: $description, builder: $builder, keep: $keep, path: $path, modes: $modes)';
}


}

/// @nodoc
abstract mixin class _$NavigationItemCopyWith<$Res> implements $NavigationItemCopyWith<$Res> {
  factory _$NavigationItemCopyWith(_NavigationItem value, $Res Function(_NavigationItem) _then) = __$NavigationItemCopyWithImpl;
@override @useResult
$Res call({
 Icon icon, PageLabel label, String? description, WidgetBuilder builder, bool keep, String? path, List<NavigationItemMode> modes
});




}
/// @nodoc
class __$NavigationItemCopyWithImpl<$Res>
    implements _$NavigationItemCopyWith<$Res> {
  __$NavigationItemCopyWithImpl(this._self, this._then);

  final _NavigationItem _self;
  final $Res Function(_NavigationItem) _then;

/// Create a copy of NavigationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? label = null,Object? description = freezed,Object? builder = null,Object? keep = null,Object? path = freezed,Object? modes = null,}) {
  return _then(_NavigationItem(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as Icon,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as PageLabel,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,builder: null == builder ? _self.builder : builder // ignore: cast_nullable_to_non_nullable
as WidgetBuilder,keep: null == keep ? _self.keep : keep // ignore: cast_nullable_to_non_nullable
as bool,path: freezed == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String?,modes: null == modes ? _self._modes : modes // ignore: cast_nullable_to_non_nullable
as List<NavigationItemMode>,
  ));
}


}


/// @nodoc
mixin _$Package {

 String get packageName; String get label; bool get system; bool get internet; int get lastUpdateTime;
/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageCopyWith<Package> get copyWith => _$PackageCopyWithImpl<Package>(this as Package, _$identity);

  /// Serializes this Package to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Package&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.label, label) || other.label == label)&&(identical(other.system, system) || other.system == system)&&(identical(other.internet, internet) || other.internet == internet)&&(identical(other.lastUpdateTime, lastUpdateTime) || other.lastUpdateTime == lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,label,system,internet,lastUpdateTime);

@override
String toString() {
  return 'Package(packageName: $packageName, label: $label, system: $system, internet: $internet, lastUpdateTime: $lastUpdateTime)';
}


}

/// @nodoc
abstract mixin class $PackageCopyWith<$Res>  {
  factory $PackageCopyWith(Package value, $Res Function(Package) _then) = _$PackageCopyWithImpl;
@useResult
$Res call({
 String packageName, String label, bool system, bool internet, int lastUpdateTime
});




}
/// @nodoc
class _$PackageCopyWithImpl<$Res>
    implements $PackageCopyWith<$Res> {
  _$PackageCopyWithImpl(this._self, this._then);

  final Package _self;
  final $Res Function(Package) _then;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packageName = null,Object? label = null,Object? system = null,Object? internet = null,Object? lastUpdateTime = null,}) {
  return _then(_self.copyWith(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,internet: null == internet ? _self.internet : internet // ignore: cast_nullable_to_non_nullable
as bool,lastUpdateTime: null == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Package].
extension PackagePatterns on Package {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Package value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Package() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Package value)  $default,){
final _that = this;
switch (_that) {
case _Package():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Package value)?  $default,){
final _that = this;
switch (_that) {
case _Package() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packageName,  String label,  bool system,  bool internet,  int lastUpdateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Package() when $default != null:
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packageName,  String label,  bool system,  bool internet,  int lastUpdateTime)  $default,) {final _that = this;
switch (_that) {
case _Package():
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.lastUpdateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packageName,  String label,  bool system,  bool internet,  int lastUpdateTime)?  $default,) {final _that = this;
switch (_that) {
case _Package() when $default != null:
return $default(_that.packageName,_that.label,_that.system,_that.internet,_that.lastUpdateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Package implements Package {
  const _Package({required this.packageName, required this.label, required this.system, required this.internet, required this.lastUpdateTime});
  factory _Package.fromJson(Map<String, dynamic> json) => _$PackageFromJson(json);

@override final  String packageName;
@override final  String label;
@override final  bool system;
@override final  bool internet;
@override final  int lastUpdateTime;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageCopyWith<_Package> get copyWith => __$PackageCopyWithImpl<_Package>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Package&&(identical(other.packageName, packageName) || other.packageName == packageName)&&(identical(other.label, label) || other.label == label)&&(identical(other.system, system) || other.system == system)&&(identical(other.internet, internet) || other.internet == internet)&&(identical(other.lastUpdateTime, lastUpdateTime) || other.lastUpdateTime == lastUpdateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packageName,label,system,internet,lastUpdateTime);

@override
String toString() {
  return 'Package(packageName: $packageName, label: $label, system: $system, internet: $internet, lastUpdateTime: $lastUpdateTime)';
}


}

/// @nodoc
abstract mixin class _$PackageCopyWith<$Res> implements $PackageCopyWith<$Res> {
  factory _$PackageCopyWith(_Package value, $Res Function(_Package) _then) = __$PackageCopyWithImpl;
@override @useResult
$Res call({
 String packageName, String label, bool system, bool internet, int lastUpdateTime
});




}
/// @nodoc
class __$PackageCopyWithImpl<$Res>
    implements _$PackageCopyWith<$Res> {
  __$PackageCopyWithImpl(this._self, this._then);

  final _Package _self;
  final $Res Function(_Package) _then;

/// Create a copy of Package
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packageName = null,Object? label = null,Object? system = null,Object? internet = null,Object? lastUpdateTime = null,}) {
  return _then(_Package(
packageName: null == packageName ? _self.packageName : packageName // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,internet: null == internet ? _self.internet : internet // ignore: cast_nullable_to_non_nullable
as bool,lastUpdateTime: null == lastUpdateTime ? _self.lastUpdateTime : lastUpdateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Metadata {

 int get uid; String get network; String get sourceIP; String get sourcePort; String get destinationIP; String get destinationPort; String get host; DnsMode? get dnsMode; String get process; String get processPath; String get remoteDestination; List<String> get sourceGeoIP; List<String> get destinationGeoIP; String get destinationIPASN; String get sourceIPASN; String get specialRules; String get specialProxy;
/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetadataCopyWith<Metadata> get copyWith => _$MetadataCopyWithImpl<Metadata>(this as Metadata, _$identity);

  /// Serializes this Metadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Metadata&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.network, network) || other.network == network)&&(identical(other.sourceIP, sourceIP) || other.sourceIP == sourceIP)&&(identical(other.sourcePort, sourcePort) || other.sourcePort == sourcePort)&&(identical(other.destinationIP, destinationIP) || other.destinationIP == destinationIP)&&(identical(other.destinationPort, destinationPort) || other.destinationPort == destinationPort)&&(identical(other.host, host) || other.host == host)&&(identical(other.dnsMode, dnsMode) || other.dnsMode == dnsMode)&&(identical(other.process, process) || other.process == process)&&(identical(other.processPath, processPath) || other.processPath == processPath)&&(identical(other.remoteDestination, remoteDestination) || other.remoteDestination == remoteDestination)&&const DeepCollectionEquality().equals(other.sourceGeoIP, sourceGeoIP)&&const DeepCollectionEquality().equals(other.destinationGeoIP, destinationGeoIP)&&(identical(other.destinationIPASN, destinationIPASN) || other.destinationIPASN == destinationIPASN)&&(identical(other.sourceIPASN, sourceIPASN) || other.sourceIPASN == sourceIPASN)&&(identical(other.specialRules, specialRules) || other.specialRules == specialRules)&&(identical(other.specialProxy, specialProxy) || other.specialProxy == specialProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,network,sourceIP,sourcePort,destinationIP,destinationPort,host,dnsMode,process,processPath,remoteDestination,const DeepCollectionEquality().hash(sourceGeoIP),const DeepCollectionEquality().hash(destinationGeoIP),destinationIPASN,sourceIPASN,specialRules,specialProxy);

@override
String toString() {
  return 'Metadata(uid: $uid, network: $network, sourceIP: $sourceIP, sourcePort: $sourcePort, destinationIP: $destinationIP, destinationPort: $destinationPort, host: $host, dnsMode: $dnsMode, process: $process, processPath: $processPath, remoteDestination: $remoteDestination, sourceGeoIP: $sourceGeoIP, destinationGeoIP: $destinationGeoIP, destinationIPASN: $destinationIPASN, sourceIPASN: $sourceIPASN, specialRules: $specialRules, specialProxy: $specialProxy)';
}


}

/// @nodoc
abstract mixin class $MetadataCopyWith<$Res>  {
  factory $MetadataCopyWith(Metadata value, $Res Function(Metadata) _then) = _$MetadataCopyWithImpl;
@useResult
$Res call({
 int uid, String network, String sourceIP, String sourcePort, String destinationIP, String destinationPort, String host, DnsMode? dnsMode, String process, String processPath, String remoteDestination, List<String> sourceGeoIP, List<String> destinationGeoIP, String destinationIPASN, String sourceIPASN, String specialRules, String specialProxy
});




}
/// @nodoc
class _$MetadataCopyWithImpl<$Res>
    implements $MetadataCopyWith<$Res> {
  _$MetadataCopyWithImpl(this._self, this._then);

  final Metadata _self;
  final $Res Function(Metadata) _then;

/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? network = null,Object? sourceIP = null,Object? sourcePort = null,Object? destinationIP = null,Object? destinationPort = null,Object? host = null,Object? dnsMode = freezed,Object? process = null,Object? processPath = null,Object? remoteDestination = null,Object? sourceGeoIP = null,Object? destinationGeoIP = null,Object? destinationIPASN = null,Object? sourceIPASN = null,Object? specialRules = null,Object? specialProxy = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,sourceIP: null == sourceIP ? _self.sourceIP : sourceIP // ignore: cast_nullable_to_non_nullable
as String,sourcePort: null == sourcePort ? _self.sourcePort : sourcePort // ignore: cast_nullable_to_non_nullable
as String,destinationIP: null == destinationIP ? _self.destinationIP : destinationIP // ignore: cast_nullable_to_non_nullable
as String,destinationPort: null == destinationPort ? _self.destinationPort : destinationPort // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,dnsMode: freezed == dnsMode ? _self.dnsMode : dnsMode // ignore: cast_nullable_to_non_nullable
as DnsMode?,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,processPath: null == processPath ? _self.processPath : processPath // ignore: cast_nullable_to_non_nullable
as String,remoteDestination: null == remoteDestination ? _self.remoteDestination : remoteDestination // ignore: cast_nullable_to_non_nullable
as String,sourceGeoIP: null == sourceGeoIP ? _self.sourceGeoIP : sourceGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationGeoIP: null == destinationGeoIP ? _self.destinationGeoIP : destinationGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationIPASN: null == destinationIPASN ? _self.destinationIPASN : destinationIPASN // ignore: cast_nullable_to_non_nullable
as String,sourceIPASN: null == sourceIPASN ? _self.sourceIPASN : sourceIPASN // ignore: cast_nullable_to_non_nullable
as String,specialRules: null == specialRules ? _self.specialRules : specialRules // ignore: cast_nullable_to_non_nullable
as String,specialProxy: null == specialProxy ? _self.specialProxy : specialProxy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Metadata].
extension MetadataPatterns on Metadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Metadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Metadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Metadata value)  $default,){
final _that = this;
switch (_that) {
case _Metadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Metadata value)?  $default,){
final _that = this;
switch (_that) {
case _Metadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int uid,  String network,  String sourceIP,  String sourcePort,  String destinationIP,  String destinationPort,  String host,  DnsMode? dnsMode,  String process,  String processPath,  String remoteDestination,  List<String> sourceGeoIP,  List<String> destinationGeoIP,  String destinationIPASN,  String sourceIPASN,  String specialRules,  String specialProxy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Metadata() when $default != null:
return $default(_that.uid,_that.network,_that.sourceIP,_that.sourcePort,_that.destinationIP,_that.destinationPort,_that.host,_that.dnsMode,_that.process,_that.processPath,_that.remoteDestination,_that.sourceGeoIP,_that.destinationGeoIP,_that.destinationIPASN,_that.sourceIPASN,_that.specialRules,_that.specialProxy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int uid,  String network,  String sourceIP,  String sourcePort,  String destinationIP,  String destinationPort,  String host,  DnsMode? dnsMode,  String process,  String processPath,  String remoteDestination,  List<String> sourceGeoIP,  List<String> destinationGeoIP,  String destinationIPASN,  String sourceIPASN,  String specialRules,  String specialProxy)  $default,) {final _that = this;
switch (_that) {
case _Metadata():
return $default(_that.uid,_that.network,_that.sourceIP,_that.sourcePort,_that.destinationIP,_that.destinationPort,_that.host,_that.dnsMode,_that.process,_that.processPath,_that.remoteDestination,_that.sourceGeoIP,_that.destinationGeoIP,_that.destinationIPASN,_that.sourceIPASN,_that.specialRules,_that.specialProxy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int uid,  String network,  String sourceIP,  String sourcePort,  String destinationIP,  String destinationPort,  String host,  DnsMode? dnsMode,  String process,  String processPath,  String remoteDestination,  List<String> sourceGeoIP,  List<String> destinationGeoIP,  String destinationIPASN,  String sourceIPASN,  String specialRules,  String specialProxy)?  $default,) {final _that = this;
switch (_that) {
case _Metadata() when $default != null:
return $default(_that.uid,_that.network,_that.sourceIP,_that.sourcePort,_that.destinationIP,_that.destinationPort,_that.host,_that.dnsMode,_that.process,_that.processPath,_that.remoteDestination,_that.sourceGeoIP,_that.destinationGeoIP,_that.destinationIPASN,_that.sourceIPASN,_that.specialRules,_that.specialProxy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Metadata implements Metadata {
  const _Metadata({this.uid = 0, this.network = '', this.sourceIP = '', this.sourcePort = '', this.destinationIP = '', this.destinationPort = '', this.host = '', this.dnsMode, this.process = '', this.processPath = '', this.remoteDestination = '', final  List<String> sourceGeoIP = const [], final  List<String> destinationGeoIP = const [], this.destinationIPASN = '', this.sourceIPASN = '', this.specialRules = '', this.specialProxy = ''}): _sourceGeoIP = sourceGeoIP,_destinationGeoIP = destinationGeoIP;
  factory _Metadata.fromJson(Map<String, dynamic> json) => _$MetadataFromJson(json);

@override@JsonKey() final  int uid;
@override@JsonKey() final  String network;
@override@JsonKey() final  String sourceIP;
@override@JsonKey() final  String sourcePort;
@override@JsonKey() final  String destinationIP;
@override@JsonKey() final  String destinationPort;
@override@JsonKey() final  String host;
@override final  DnsMode? dnsMode;
@override@JsonKey() final  String process;
@override@JsonKey() final  String processPath;
@override@JsonKey() final  String remoteDestination;
 final  List<String> _sourceGeoIP;
@override@JsonKey() List<String> get sourceGeoIP {
  if (_sourceGeoIP is EqualUnmodifiableListView) return _sourceGeoIP;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceGeoIP);
}

 final  List<String> _destinationGeoIP;
@override@JsonKey() List<String> get destinationGeoIP {
  if (_destinationGeoIP is EqualUnmodifiableListView) return _destinationGeoIP;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_destinationGeoIP);
}

@override@JsonKey() final  String destinationIPASN;
@override@JsonKey() final  String sourceIPASN;
@override@JsonKey() final  String specialRules;
@override@JsonKey() final  String specialProxy;

/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetadataCopyWith<_Metadata> get copyWith => __$MetadataCopyWithImpl<_Metadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Metadata&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.network, network) || other.network == network)&&(identical(other.sourceIP, sourceIP) || other.sourceIP == sourceIP)&&(identical(other.sourcePort, sourcePort) || other.sourcePort == sourcePort)&&(identical(other.destinationIP, destinationIP) || other.destinationIP == destinationIP)&&(identical(other.destinationPort, destinationPort) || other.destinationPort == destinationPort)&&(identical(other.host, host) || other.host == host)&&(identical(other.dnsMode, dnsMode) || other.dnsMode == dnsMode)&&(identical(other.process, process) || other.process == process)&&(identical(other.processPath, processPath) || other.processPath == processPath)&&(identical(other.remoteDestination, remoteDestination) || other.remoteDestination == remoteDestination)&&const DeepCollectionEquality().equals(other._sourceGeoIP, _sourceGeoIP)&&const DeepCollectionEquality().equals(other._destinationGeoIP, _destinationGeoIP)&&(identical(other.destinationIPASN, destinationIPASN) || other.destinationIPASN == destinationIPASN)&&(identical(other.sourceIPASN, sourceIPASN) || other.sourceIPASN == sourceIPASN)&&(identical(other.specialRules, specialRules) || other.specialRules == specialRules)&&(identical(other.specialProxy, specialProxy) || other.specialProxy == specialProxy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,network,sourceIP,sourcePort,destinationIP,destinationPort,host,dnsMode,process,processPath,remoteDestination,const DeepCollectionEquality().hash(_sourceGeoIP),const DeepCollectionEquality().hash(_destinationGeoIP),destinationIPASN,sourceIPASN,specialRules,specialProxy);

@override
String toString() {
  return 'Metadata(uid: $uid, network: $network, sourceIP: $sourceIP, sourcePort: $sourcePort, destinationIP: $destinationIP, destinationPort: $destinationPort, host: $host, dnsMode: $dnsMode, process: $process, processPath: $processPath, remoteDestination: $remoteDestination, sourceGeoIP: $sourceGeoIP, destinationGeoIP: $destinationGeoIP, destinationIPASN: $destinationIPASN, sourceIPASN: $sourceIPASN, specialRules: $specialRules, specialProxy: $specialProxy)';
}


}

/// @nodoc
abstract mixin class _$MetadataCopyWith<$Res> implements $MetadataCopyWith<$Res> {
  factory _$MetadataCopyWith(_Metadata value, $Res Function(_Metadata) _then) = __$MetadataCopyWithImpl;
@override @useResult
$Res call({
 int uid, String network, String sourceIP, String sourcePort, String destinationIP, String destinationPort, String host, DnsMode? dnsMode, String process, String processPath, String remoteDestination, List<String> sourceGeoIP, List<String> destinationGeoIP, String destinationIPASN, String sourceIPASN, String specialRules, String specialProxy
});




}
/// @nodoc
class __$MetadataCopyWithImpl<$Res>
    implements _$MetadataCopyWith<$Res> {
  __$MetadataCopyWithImpl(this._self, this._then);

  final _Metadata _self;
  final $Res Function(_Metadata) _then;

/// Create a copy of Metadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? network = null,Object? sourceIP = null,Object? sourcePort = null,Object? destinationIP = null,Object? destinationPort = null,Object? host = null,Object? dnsMode = freezed,Object? process = null,Object? processPath = null,Object? remoteDestination = null,Object? sourceGeoIP = null,Object? destinationGeoIP = null,Object? destinationIPASN = null,Object? sourceIPASN = null,Object? specialRules = null,Object? specialProxy = null,}) {
  return _then(_Metadata(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as int,network: null == network ? _self.network : network // ignore: cast_nullable_to_non_nullable
as String,sourceIP: null == sourceIP ? _self.sourceIP : sourceIP // ignore: cast_nullable_to_non_nullable
as String,sourcePort: null == sourcePort ? _self.sourcePort : sourcePort // ignore: cast_nullable_to_non_nullable
as String,destinationIP: null == destinationIP ? _self.destinationIP : destinationIP // ignore: cast_nullable_to_non_nullable
as String,destinationPort: null == destinationPort ? _self.destinationPort : destinationPort // ignore: cast_nullable_to_non_nullable
as String,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,dnsMode: freezed == dnsMode ? _self.dnsMode : dnsMode // ignore: cast_nullable_to_non_nullable
as DnsMode?,process: null == process ? _self.process : process // ignore: cast_nullable_to_non_nullable
as String,processPath: null == processPath ? _self.processPath : processPath // ignore: cast_nullable_to_non_nullable
as String,remoteDestination: null == remoteDestination ? _self.remoteDestination : remoteDestination // ignore: cast_nullable_to_non_nullable
as String,sourceGeoIP: null == sourceGeoIP ? _self._sourceGeoIP : sourceGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationGeoIP: null == destinationGeoIP ? _self._destinationGeoIP : destinationGeoIP // ignore: cast_nullable_to_non_nullable
as List<String>,destinationIPASN: null == destinationIPASN ? _self.destinationIPASN : destinationIPASN // ignore: cast_nullable_to_non_nullable
as String,sourceIPASN: null == sourceIPASN ? _self.sourceIPASN : sourceIPASN // ignore: cast_nullable_to_non_nullable
as String,specialRules: null == specialRules ? _self.specialRules : specialRules // ignore: cast_nullable_to_non_nullable
as String,specialProxy: null == specialProxy ? _self.specialProxy : specialProxy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TrackerInfo {

 String get id; int get upload; int get download; DateTime get start; Metadata get metadata; List<String> get chains; String get rule; String get rulePayload; int? get downloadSpeed; int? get uploadSpeed;
/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerInfoCopyWith<TrackerInfo> get copyWith => _$TrackerInfoCopyWithImpl<TrackerInfo>(this as TrackerInfo, _$identity);

  /// Serializes this TrackerInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.start, start) || other.start == start)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&const DeepCollectionEquality().equals(other.chains, chains)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.rulePayload, rulePayload) || other.rulePayload == rulePayload)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.uploadSpeed, uploadSpeed) || other.uploadSpeed == uploadSpeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,upload,download,start,metadata,const DeepCollectionEquality().hash(chains),rule,rulePayload,downloadSpeed,uploadSpeed);

@override
String toString() {
  return 'TrackerInfo(id: $id, upload: $upload, download: $download, start: $start, metadata: $metadata, chains: $chains, rule: $rule, rulePayload: $rulePayload, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed)';
}


}

/// @nodoc
abstract mixin class $TrackerInfoCopyWith<$Res>  {
  factory $TrackerInfoCopyWith(TrackerInfo value, $Res Function(TrackerInfo) _then) = _$TrackerInfoCopyWithImpl;
@useResult
$Res call({
 String id, int upload, int download, DateTime start, Metadata metadata, List<String> chains, String rule, String rulePayload, int? downloadSpeed, int? uploadSpeed
});


$MetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class _$TrackerInfoCopyWithImpl<$Res>
    implements $TrackerInfoCopyWith<$Res> {
  _$TrackerInfoCopyWithImpl(this._self, this._then);

  final TrackerInfo _self;
  final $Res Function(TrackerInfo) _then;

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? upload = null,Object? download = null,Object? start = null,Object? metadata = null,Object? chains = null,Object? rule = null,Object? rulePayload = null,Object? downloadSpeed = freezed,Object? uploadSpeed = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Metadata,chains: null == chains ? _self.chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,downloadSpeed: freezed == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as int?,uploadSpeed: freezed == uploadSpeed ? _self.uploadSpeed : uploadSpeed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataCopyWith<$Res> get metadata {
  
  return $MetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrackerInfo].
extension TrackerInfoPatterns on TrackerInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerInfo value)  $default,){
final _that = this;
switch (_that) {
case _TrackerInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int upload,  int download,  DateTime start,  Metadata metadata,  List<String> chains,  String rule,  String rulePayload,  int? downloadSpeed,  int? uploadSpeed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
return $default(_that.id,_that.upload,_that.download,_that.start,_that.metadata,_that.chains,_that.rule,_that.rulePayload,_that.downloadSpeed,_that.uploadSpeed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int upload,  int download,  DateTime start,  Metadata metadata,  List<String> chains,  String rule,  String rulePayload,  int? downloadSpeed,  int? uploadSpeed)  $default,) {final _that = this;
switch (_that) {
case _TrackerInfo():
return $default(_that.id,_that.upload,_that.download,_that.start,_that.metadata,_that.chains,_that.rule,_that.rulePayload,_that.downloadSpeed,_that.uploadSpeed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int upload,  int download,  DateTime start,  Metadata metadata,  List<String> chains,  String rule,  String rulePayload,  int? downloadSpeed,  int? uploadSpeed)?  $default,) {final _that = this;
switch (_that) {
case _TrackerInfo() when $default != null:
return $default(_that.id,_that.upload,_that.download,_that.start,_that.metadata,_that.chains,_that.rule,_that.rulePayload,_that.downloadSpeed,_that.uploadSpeed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackerInfo implements TrackerInfo {
  const _TrackerInfo({required this.id, this.upload = 0, this.download = 0, required this.start, required this.metadata, required final  List<String> chains, required this.rule, required this.rulePayload, this.downloadSpeed, this.uploadSpeed}): _chains = chains;
  factory _TrackerInfo.fromJson(Map<String, dynamic> json) => _$TrackerInfoFromJson(json);

@override final  String id;
@override@JsonKey() final  int upload;
@override@JsonKey() final  int download;
@override final  DateTime start;
@override final  Metadata metadata;
 final  List<String> _chains;
@override List<String> get chains {
  if (_chains is EqualUnmodifiableListView) return _chains;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chains);
}

@override final  String rule;
@override final  String rulePayload;
@override final  int? downloadSpeed;
@override final  int? uploadSpeed;

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerInfoCopyWith<_TrackerInfo> get copyWith => __$TrackerInfoCopyWithImpl<_TrackerInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackerInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.start, start) || other.start == start)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&const DeepCollectionEquality().equals(other._chains, _chains)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.rulePayload, rulePayload) || other.rulePayload == rulePayload)&&(identical(other.downloadSpeed, downloadSpeed) || other.downloadSpeed == downloadSpeed)&&(identical(other.uploadSpeed, uploadSpeed) || other.uploadSpeed == uploadSpeed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,upload,download,start,metadata,const DeepCollectionEquality().hash(_chains),rule,rulePayload,downloadSpeed,uploadSpeed);

@override
String toString() {
  return 'TrackerInfo(id: $id, upload: $upload, download: $download, start: $start, metadata: $metadata, chains: $chains, rule: $rule, rulePayload: $rulePayload, downloadSpeed: $downloadSpeed, uploadSpeed: $uploadSpeed)';
}


}

/// @nodoc
abstract mixin class _$TrackerInfoCopyWith<$Res> implements $TrackerInfoCopyWith<$Res> {
  factory _$TrackerInfoCopyWith(_TrackerInfo value, $Res Function(_TrackerInfo) _then) = __$TrackerInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, int upload, int download, DateTime start, Metadata metadata, List<String> chains, String rule, String rulePayload, int? downloadSpeed, int? uploadSpeed
});


@override $MetadataCopyWith<$Res> get metadata;

}
/// @nodoc
class __$TrackerInfoCopyWithImpl<$Res>
    implements _$TrackerInfoCopyWith<$Res> {
  __$TrackerInfoCopyWithImpl(this._self, this._then);

  final _TrackerInfo _self;
  final $Res Function(_TrackerInfo) _then;

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? upload = null,Object? download = null,Object? start = null,Object? metadata = null,Object? chains = null,Object? rule = null,Object? rulePayload = null,Object? downloadSpeed = freezed,Object? uploadSpeed = freezed,}) {
  return _then(_TrackerInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Metadata,chains: null == chains ? _self._chains : chains // ignore: cast_nullable_to_non_nullable
as List<String>,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,rulePayload: null == rulePayload ? _self.rulePayload : rulePayload // ignore: cast_nullable_to_non_nullable
as String,downloadSpeed: freezed == downloadSpeed ? _self.downloadSpeed : downloadSpeed // ignore: cast_nullable_to_non_nullable
as int?,uploadSpeed: freezed == uploadSpeed ? _self.uploadSpeed : uploadSpeed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TrackerInfo
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetadataCopyWith<$Res> get metadata {
  
  return $MetadataCopyWith<$Res>(_self.metadata, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$Log {

// @JsonKey(fromJson: _logId) required String id,
@JsonKey(name: 'LogLevel') LogLevel get logLevel;@JsonKey(name: 'Payload') String get payload;@JsonKey(fromJson: _logDateTime) String get dateTime;
/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogCopyWith<Log> get copyWith => _$LogCopyWithImpl<Log>(this as Log, _$identity);

  /// Serializes this Log to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Log&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logLevel,payload,dateTime);

@override
String toString() {
  return 'Log(logLevel: $logLevel, payload: $payload, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class $LogCopyWith<$Res>  {
  factory $LogCopyWith(Log value, $Res Function(Log) _then) = _$LogCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'LogLevel') LogLevel logLevel,@JsonKey(name: 'Payload') String payload,@JsonKey(fromJson: _logDateTime) String dateTime
});




}
/// @nodoc
class _$LogCopyWithImpl<$Res>
    implements $LogCopyWith<$Res> {
  _$LogCopyWithImpl(this._self, this._then);

  final Log _self;
  final $Res Function(Log) _then;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logLevel = null,Object? payload = null,Object? dateTime = null,}) {
  return _then(_self.copyWith(
logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Log].
extension LogPatterns on Log {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Log value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Log() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Log value)  $default,){
final _that = this;
switch (_that) {
case _Log():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Log value)?  $default,){
final _that = this;
switch (_that) {
case _Log() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logDateTime)  String dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Log() when $default != null:
return $default(_that.logLevel,_that.payload,_that.dateTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logDateTime)  String dateTime)  $default,) {final _that = this;
switch (_that) {
case _Log():
return $default(_that.logLevel,_that.payload,_that.dateTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'LogLevel')  LogLevel logLevel, @JsonKey(name: 'Payload')  String payload, @JsonKey(fromJson: _logDateTime)  String dateTime)?  $default,) {final _that = this;
switch (_that) {
case _Log() when $default != null:
return $default(_that.logLevel,_that.payload,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Log implements Log {
  const _Log({@JsonKey(name: 'LogLevel') this.logLevel = LogLevel.info, @JsonKey(name: 'Payload') this.payload = '', @JsonKey(fromJson: _logDateTime) required this.dateTime});
  factory _Log.fromJson(Map<String, dynamic> json) => _$LogFromJson(json);

// @JsonKey(fromJson: _logId) required String id,
@override@JsonKey(name: 'LogLevel') final  LogLevel logLevel;
@override@JsonKey(name: 'Payload') final  String payload;
@override@JsonKey(fromJson: _logDateTime) final  String dateTime;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogCopyWith<_Log> get copyWith => __$LogCopyWithImpl<_Log>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Log&&(identical(other.logLevel, logLevel) || other.logLevel == logLevel)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logLevel,payload,dateTime);

@override
String toString() {
  return 'Log(logLevel: $logLevel, payload: $payload, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$LogCopyWith<$Res> implements $LogCopyWith<$Res> {
  factory _$LogCopyWith(_Log value, $Res Function(_Log) _then) = __$LogCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'LogLevel') LogLevel logLevel,@JsonKey(name: 'Payload') String payload,@JsonKey(fromJson: _logDateTime) String dateTime
});




}
/// @nodoc
class __$LogCopyWithImpl<$Res>
    implements _$LogCopyWith<$Res> {
  __$LogCopyWithImpl(this._self, this._then);

  final _Log _self;
  final $Res Function(_Log) _then;

/// Create a copy of Log
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logLevel = null,Object? payload = null,Object? dateTime = null,}) {
  return _then(_Log(
logLevel: null == logLevel ? _self.logLevel : logLevel // ignore: cast_nullable_to_non_nullable
as LogLevel,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LogsState {

 List<Log> get logs; List<String> get keywords; String get query; bool get autoScrollToEnd;
/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogsStateCopyWith<LogsState> get copyWith => _$LogsStateCopyWithImpl<LogsState>(this as LogsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogsState&&const DeepCollectionEquality().equals(other.logs, logs)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(logs),const DeepCollectionEquality().hash(keywords),query,autoScrollToEnd);

@override
String toString() {
  return 'LogsState(logs: $logs, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class $LogsStateCopyWith<$Res>  {
  factory $LogsStateCopyWith(LogsState value, $Res Function(LogsState) _then) = _$LogsStateCopyWithImpl;
@useResult
$Res call({
 List<Log> logs, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class _$LogsStateCopyWithImpl<$Res>
    implements $LogsStateCopyWith<$Res> {
  _$LogsStateCopyWithImpl(this._self, this._then);

  final LogsState _self;
  final $Res Function(LogsState) _then;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logs = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_self.copyWith(
logs: null == logs ? _self.logs : logs // ignore: cast_nullable_to_non_nullable
as List<Log>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LogsState].
extension LogsStatePatterns on LogsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogsState value)  $default,){
final _that = this;
switch (_that) {
case _LogsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogsState value)?  $default,){
final _that = this;
switch (_that) {
case _LogsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogsState() when $default != null:
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)  $default,) {final _that = this;
switch (_that) {
case _LogsState():
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Log> logs,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,) {final _that = this;
switch (_that) {
case _LogsState() when $default != null:
return $default(_that.logs,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
  return null;

}
}

}

/// @nodoc


class _LogsState implements LogsState {
  const _LogsState({final  List<Log> logs = const [], final  List<String> keywords = const [], this.query = '', this.autoScrollToEnd = true}): _logs = logs,_keywords = keywords;
  

 final  List<Log> _logs;
@override@JsonKey() List<Log> get logs {
  if (_logs is EqualUnmodifiableListView) return _logs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logs);
}

 final  List<String> _keywords;
@override@JsonKey() List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  bool autoScrollToEnd;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogsStateCopyWith<_LogsState> get copyWith => __$LogsStateCopyWithImpl<_LogsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogsState&&const DeepCollectionEquality().equals(other._logs, _logs)&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_logs),const DeepCollectionEquality().hash(_keywords),query,autoScrollToEnd);

@override
String toString() {
  return 'LogsState(logs: $logs, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class _$LogsStateCopyWith<$Res> implements $LogsStateCopyWith<$Res> {
  factory _$LogsStateCopyWith(_LogsState value, $Res Function(_LogsState) _then) = __$LogsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Log> logs, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class __$LogsStateCopyWithImpl<$Res>
    implements _$LogsStateCopyWith<$Res> {
  __$LogsStateCopyWithImpl(this._self, this._then);

  final _LogsState _self;
  final $Res Function(_LogsState) _then;

/// Create a copy of LogsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logs = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_LogsState(
logs: null == logs ? _self._logs : logs // ignore: cast_nullable_to_non_nullable
as List<Log>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$TrackerInfosState {

 List<TrackerInfo> get trackerInfos; List<String> get keywords; String get query; bool get autoScrollToEnd;
/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackerInfosStateCopyWith<TrackerInfosState> get copyWith => _$TrackerInfosStateCopyWithImpl<TrackerInfosState>(this as TrackerInfosState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackerInfosState&&const DeepCollectionEquality().equals(other.trackerInfos, trackerInfos)&&const DeepCollectionEquality().equals(other.keywords, keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(trackerInfos),const DeepCollectionEquality().hash(keywords),query,autoScrollToEnd);

@override
String toString() {
  return 'TrackerInfosState(trackerInfos: $trackerInfos, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class $TrackerInfosStateCopyWith<$Res>  {
  factory $TrackerInfosStateCopyWith(TrackerInfosState value, $Res Function(TrackerInfosState) _then) = _$TrackerInfosStateCopyWithImpl;
@useResult
$Res call({
 List<TrackerInfo> trackerInfos, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class _$TrackerInfosStateCopyWithImpl<$Res>
    implements $TrackerInfosStateCopyWith<$Res> {
  _$TrackerInfosStateCopyWithImpl(this._self, this._then);

  final TrackerInfosState _self;
  final $Res Function(TrackerInfosState) _then;

/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trackerInfos = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_self.copyWith(
trackerInfos: null == trackerInfos ? _self.trackerInfos : trackerInfos // ignore: cast_nullable_to_non_nullable
as List<TrackerInfo>,keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackerInfosState].
extension TrackerInfosStatePatterns on TrackerInfosState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackerInfosState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackerInfosState value)  $default,){
final _that = this;
switch (_that) {
case _TrackerInfosState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackerInfosState value)?  $default,){
final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrackerInfo> trackerInfos,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
return $default(_that.trackerInfos,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrackerInfo> trackerInfos,  List<String> keywords,  String query,  bool autoScrollToEnd)  $default,) {final _that = this;
switch (_that) {
case _TrackerInfosState():
return $default(_that.trackerInfos,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrackerInfo> trackerInfos,  List<String> keywords,  String query,  bool autoScrollToEnd)?  $default,) {final _that = this;
switch (_that) {
case _TrackerInfosState() when $default != null:
return $default(_that.trackerInfos,_that.keywords,_that.query,_that.autoScrollToEnd);case _:
  return null;

}
}

}

/// @nodoc


class _TrackerInfosState implements TrackerInfosState {
  const _TrackerInfosState({final  List<TrackerInfo> trackerInfos = const [], final  List<String> keywords = const [], this.query = '', this.autoScrollToEnd = true}): _trackerInfos = trackerInfos,_keywords = keywords;
  

 final  List<TrackerInfo> _trackerInfos;
@override@JsonKey() List<TrackerInfo> get trackerInfos {
  if (_trackerInfos is EqualUnmodifiableListView) return _trackerInfos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trackerInfos);
}

 final  List<String> _keywords;
@override@JsonKey() List<String> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
}

@override@JsonKey() final  String query;
@override@JsonKey() final  bool autoScrollToEnd;

/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackerInfosStateCopyWith<_TrackerInfosState> get copyWith => __$TrackerInfosStateCopyWithImpl<_TrackerInfosState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackerInfosState&&const DeepCollectionEquality().equals(other._trackerInfos, _trackerInfos)&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&(identical(other.query, query) || other.query == query)&&(identical(other.autoScrollToEnd, autoScrollToEnd) || other.autoScrollToEnd == autoScrollToEnd));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_trackerInfos),const DeepCollectionEquality().hash(_keywords),query,autoScrollToEnd);

@override
String toString() {
  return 'TrackerInfosState(trackerInfos: $trackerInfos, keywords: $keywords, query: $query, autoScrollToEnd: $autoScrollToEnd)';
}


}

/// @nodoc
abstract mixin class _$TrackerInfosStateCopyWith<$Res> implements $TrackerInfosStateCopyWith<$Res> {
  factory _$TrackerInfosStateCopyWith(_TrackerInfosState value, $Res Function(_TrackerInfosState) _then) = __$TrackerInfosStateCopyWithImpl;
@override @useResult
$Res call({
 List<TrackerInfo> trackerInfos, List<String> keywords, String query, bool autoScrollToEnd
});




}
/// @nodoc
class __$TrackerInfosStateCopyWithImpl<$Res>
    implements _$TrackerInfosStateCopyWith<$Res> {
  __$TrackerInfosStateCopyWithImpl(this._self, this._then);

  final _TrackerInfosState _self;
  final $Res Function(_TrackerInfosState) _then;

/// Create a copy of TrackerInfosState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trackerInfos = null,Object? keywords = null,Object? query = null,Object? autoScrollToEnd = null,}) {
  return _then(_TrackerInfosState(
trackerInfos: null == trackerInfos ? _self._trackerInfos : trackerInfos // ignore: cast_nullable_to_non_nullable
as List<TrackerInfo>,keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<String>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,autoScrollToEnd: null == autoScrollToEnd ? _self.autoScrollToEnd : autoScrollToEnd // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$DAV {

 String get uri; String get user; String get password; String get fileName;
/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DAVCopyWith<DAV> get copyWith => _$DAVCopyWithImpl<DAV>(this as DAV, _$identity);

  /// Serializes this DAV to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DAV&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.user, user) || other.user == user)&&(identical(other.password, password) || other.password == password)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,user,password,fileName);

@override
String toString() {
  return 'DAV(uri: $uri, user: $user, password: $password, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class $DAVCopyWith<$Res>  {
  factory $DAVCopyWith(DAV value, $Res Function(DAV) _then) = _$DAVCopyWithImpl;
@useResult
$Res call({
 String uri, String user, String password, String fileName
});




}
/// @nodoc
class _$DAVCopyWithImpl<$Res>
    implements $DAVCopyWith<$Res> {
  _$DAVCopyWithImpl(this._self, this._then);

  final DAV _self;
  final $Res Function(DAV) _then;

/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uri = null,Object? user = null,Object? password = null,Object? fileName = null,}) {
  return _then(_self.copyWith(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DAV].
extension DAVPatterns on DAV {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DAV value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DAV() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DAV value)  $default,){
final _that = this;
switch (_that) {
case _DAV():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DAV value)?  $default,){
final _that = this;
switch (_that) {
case _DAV() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uri,  String user,  String password,  String fileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DAV() when $default != null:
return $default(_that.uri,_that.user,_that.password,_that.fileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uri,  String user,  String password,  String fileName)  $default,) {final _that = this;
switch (_that) {
case _DAV():
return $default(_that.uri,_that.user,_that.password,_that.fileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uri,  String user,  String password,  String fileName)?  $default,) {final _that = this;
switch (_that) {
case _DAV() when $default != null:
return $default(_that.uri,_that.user,_that.password,_that.fileName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DAV implements DAV {
  const _DAV({required this.uri, required this.user, required this.password, this.fileName = defaultDavFileName});
  factory _DAV.fromJson(Map<String, dynamic> json) => _$DAVFromJson(json);

@override final  String uri;
@override final  String user;
@override final  String password;
@override@JsonKey() final  String fileName;

/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DAVCopyWith<_DAV> get copyWith => __$DAVCopyWithImpl<_DAV>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DAVToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DAV&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.user, user) || other.user == user)&&(identical(other.password, password) || other.password == password)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uri,user,password,fileName);

@override
String toString() {
  return 'DAV(uri: $uri, user: $user, password: $password, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$DAVCopyWith<$Res> implements $DAVCopyWith<$Res> {
  factory _$DAVCopyWith(_DAV value, $Res Function(_DAV) _then) = __$DAVCopyWithImpl;
@override @useResult
$Res call({
 String uri, String user, String password, String fileName
});




}
/// @nodoc
class __$DAVCopyWithImpl<$Res>
    implements _$DAVCopyWith<$Res> {
  __$DAVCopyWithImpl(this._self, this._then);

  final _DAV _self;
  final $Res Function(_DAV) _then;

/// Create a copy of DAV
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uri = null,Object? user = null,Object? password = null,Object? fileName = null,}) {
  return _then(_DAV(
uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$FileInfo {

 int get size; DateTime get lastModified;
/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileInfoCopyWith<FileInfo> get copyWith => _$FileInfoCopyWithImpl<FileInfo>(this as FileInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileInfo&&(identical(other.size, size) || other.size == size)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}


@override
int get hashCode => Object.hash(runtimeType,size,lastModified);

@override
String toString() {
  return 'FileInfo(size: $size, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class $FileInfoCopyWith<$Res>  {
  factory $FileInfoCopyWith(FileInfo value, $Res Function(FileInfo) _then) = _$FileInfoCopyWithImpl;
@useResult
$Res call({
 int size, DateTime lastModified
});




}
/// @nodoc
class _$FileInfoCopyWithImpl<$Res>
    implements $FileInfoCopyWith<$Res> {
  _$FileInfoCopyWithImpl(this._self, this._then);

  final FileInfo _self;
  final $Res Function(FileInfo) _then;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? size = null,Object? lastModified = null,}) {
  return _then(_self.copyWith(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FileInfo].
extension FileInfoPatterns on FileInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FileInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FileInfo value)  $default,){
final _that = this;
switch (_that) {
case _FileInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FileInfo value)?  $default,){
final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int size,  DateTime lastModified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
return $default(_that.size,_that.lastModified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int size,  DateTime lastModified)  $default,) {final _that = this;
switch (_that) {
case _FileInfo():
return $default(_that.size,_that.lastModified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int size,  DateTime lastModified)?  $default,) {final _that = this;
switch (_that) {
case _FileInfo() when $default != null:
return $default(_that.size,_that.lastModified);case _:
  return null;

}
}

}

/// @nodoc


class _FileInfo implements FileInfo {
  const _FileInfo({required this.size, required this.lastModified});
  

@override final  int size;
@override final  DateTime lastModified;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileInfoCopyWith<_FileInfo> get copyWith => __$FileInfoCopyWithImpl<_FileInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileInfo&&(identical(other.size, size) || other.size == size)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified));
}


@override
int get hashCode => Object.hash(runtimeType,size,lastModified);

@override
String toString() {
  return 'FileInfo(size: $size, lastModified: $lastModified)';
}


}

/// @nodoc
abstract mixin class _$FileInfoCopyWith<$Res> implements $FileInfoCopyWith<$Res> {
  factory _$FileInfoCopyWith(_FileInfo value, $Res Function(_FileInfo) _then) = __$FileInfoCopyWithImpl;
@override @useResult
$Res call({
 int size, DateTime lastModified
});




}
/// @nodoc
class __$FileInfoCopyWithImpl<$Res>
    implements _$FileInfoCopyWith<$Res> {
  __$FileInfoCopyWithImpl(this._self, this._then);

  final _FileInfo _self;
  final $Res Function(_FileInfo) _then;

/// Create a copy of FileInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? size = null,Object? lastModified = null,}) {
  return _then(_FileInfo(
size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,lastModified: null == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$VersionInfo {

 String get clashName; String get version;
/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VersionInfoCopyWith<VersionInfo> get copyWith => _$VersionInfoCopyWithImpl<VersionInfo>(this as VersionInfo, _$identity);

  /// Serializes this VersionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VersionInfo&&(identical(other.clashName, clashName) || other.clashName == clashName)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clashName,version);

@override
String toString() {
  return 'VersionInfo(clashName: $clashName, version: $version)';
}


}

/// @nodoc
abstract mixin class $VersionInfoCopyWith<$Res>  {
  factory $VersionInfoCopyWith(VersionInfo value, $Res Function(VersionInfo) _then) = _$VersionInfoCopyWithImpl;
@useResult
$Res call({
 String clashName, String version
});




}
/// @nodoc
class _$VersionInfoCopyWithImpl<$Res>
    implements $VersionInfoCopyWith<$Res> {
  _$VersionInfoCopyWithImpl(this._self, this._then);

  final VersionInfo _self;
  final $Res Function(VersionInfo) _then;

/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clashName = null,Object? version = null,}) {
  return _then(_self.copyWith(
clashName: null == clashName ? _self.clashName : clashName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VersionInfo].
extension VersionInfoPatterns on VersionInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VersionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VersionInfo value)  $default,){
final _that = this;
switch (_that) {
case _VersionInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VersionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String clashName,  String version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
return $default(_that.clashName,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String clashName,  String version)  $default,) {final _that = this;
switch (_that) {
case _VersionInfo():
return $default(_that.clashName,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String clashName,  String version)?  $default,) {final _that = this;
switch (_that) {
case _VersionInfo() when $default != null:
return $default(_that.clashName,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VersionInfo implements VersionInfo {
  const _VersionInfo({this.clashName = '', this.version = ''});
  factory _VersionInfo.fromJson(Map<String, dynamic> json) => _$VersionInfoFromJson(json);

@override@JsonKey() final  String clashName;
@override@JsonKey() final  String version;

/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VersionInfoCopyWith<_VersionInfo> get copyWith => __$VersionInfoCopyWithImpl<_VersionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VersionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VersionInfo&&(identical(other.clashName, clashName) || other.clashName == clashName)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clashName,version);

@override
String toString() {
  return 'VersionInfo(clashName: $clashName, version: $version)';
}


}

/// @nodoc
abstract mixin class _$VersionInfoCopyWith<$Res> implements $VersionInfoCopyWith<$Res> {
  factory _$VersionInfoCopyWith(_VersionInfo value, $Res Function(_VersionInfo) _then) = __$VersionInfoCopyWithImpl;
@override @useResult
$Res call({
 String clashName, String version
});




}
/// @nodoc
class __$VersionInfoCopyWithImpl<$Res>
    implements _$VersionInfoCopyWith<$Res> {
  __$VersionInfoCopyWithImpl(this._self, this._then);

  final _VersionInfo _self;
  final $Res Function(_VersionInfo) _then;

/// Create a copy of VersionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clashName = null,Object? version = null,}) {
  return _then(_VersionInfo(
clashName: null == clashName ? _self.clashName : clashName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Traffic {

 num get up; num get down;
/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficCopyWith<Traffic> get copyWith => _$TrafficCopyWithImpl<Traffic>(this as Traffic, _$identity);

  /// Serializes this Traffic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Traffic&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,up,down);

@override
String toString() {
  return 'Traffic(up: $up, down: $down)';
}


}

/// @nodoc
abstract mixin class $TrafficCopyWith<$Res>  {
  factory $TrafficCopyWith(Traffic value, $Res Function(Traffic) _then) = _$TrafficCopyWithImpl;
@useResult
$Res call({
 num up, num down
});




}
/// @nodoc
class _$TrafficCopyWithImpl<$Res>
    implements $TrafficCopyWith<$Res> {
  _$TrafficCopyWithImpl(this._self, this._then);

  final Traffic _self;
  final $Res Function(Traffic) _then;

/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? up = null,Object? down = null,}) {
  return _then(_self.copyWith(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as num,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [Traffic].
extension TrafficPatterns on Traffic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Traffic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Traffic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Traffic value)  $default,){
final _that = this;
switch (_that) {
case _Traffic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Traffic value)?  $default,){
final _that = this;
switch (_that) {
case _Traffic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num up,  num down)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Traffic() when $default != null:
return $default(_that.up,_that.down);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num up,  num down)  $default,) {final _that = this;
switch (_that) {
case _Traffic():
return $default(_that.up,_that.down);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num up,  num down)?  $default,) {final _that = this;
switch (_that) {
case _Traffic() when $default != null:
return $default(_that.up,_that.down);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Traffic implements Traffic {
  const _Traffic({this.up = 0, this.down = 0});
  factory _Traffic.fromJson(Map<String, dynamic> json) => _$TrafficFromJson(json);

@override@JsonKey() final  num up;
@override@JsonKey() final  num down;

/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficCopyWith<_Traffic> get copyWith => __$TrafficCopyWithImpl<_Traffic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrafficToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Traffic&&(identical(other.up, up) || other.up == up)&&(identical(other.down, down) || other.down == down));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,up,down);

@override
String toString() {
  return 'Traffic(up: $up, down: $down)';
}


}

/// @nodoc
abstract mixin class _$TrafficCopyWith<$Res> implements $TrafficCopyWith<$Res> {
  factory _$TrafficCopyWith(_Traffic value, $Res Function(_Traffic) _then) = __$TrafficCopyWithImpl;
@override @useResult
$Res call({
 num up, num down
});




}
/// @nodoc
class __$TrafficCopyWithImpl<$Res>
    implements _$TrafficCopyWith<$Res> {
  __$TrafficCopyWithImpl(this._self, this._then);

  final _Traffic _self;
  final $Res Function(_Traffic) _then;

/// Create a copy of Traffic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? up = null,Object? down = null,}) {
  return _then(_Traffic(
up: null == up ? _self.up : up // ignore: cast_nullable_to_non_nullable
as num,down: null == down ? _self.down : down // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

/// @nodoc
mixin _$TrafficShow {

 String get value; String get unit;
/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrafficShowCopyWith<TrafficShow> get copyWith => _$TrafficShowCopyWithImpl<TrafficShow>(this as TrafficShow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrafficShow&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode => Object.hash(runtimeType,value,unit);

@override
String toString() {
  return 'TrafficShow(value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class $TrafficShowCopyWith<$Res>  {
  factory $TrafficShowCopyWith(TrafficShow value, $Res Function(TrafficShow) _then) = _$TrafficShowCopyWithImpl;
@useResult
$Res call({
 String value, String unit
});




}
/// @nodoc
class _$TrafficShowCopyWithImpl<$Res>
    implements $TrafficShowCopyWith<$Res> {
  _$TrafficShowCopyWithImpl(this._self, this._then);

  final TrafficShow _self;
  final $Res Function(TrafficShow) _then;

/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? unit = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrafficShow].
extension TrafficShowPatterns on TrafficShow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrafficShow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrafficShow value)  $default,){
final _that = this;
switch (_that) {
case _TrafficShow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrafficShow value)?  $default,){
final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
return $default(_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String unit)  $default,) {final _that = this;
switch (_that) {
case _TrafficShow():
return $default(_that.value,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String unit)?  $default,) {final _that = this;
switch (_that) {
case _TrafficShow() when $default != null:
return $default(_that.value,_that.unit);case _:
  return null;

}
}

}

/// @nodoc


class _TrafficShow implements TrafficShow {
  const _TrafficShow({required this.value, required this.unit});
  

@override final  String value;
@override final  String unit;

/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrafficShowCopyWith<_TrafficShow> get copyWith => __$TrafficShowCopyWithImpl<_TrafficShow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrafficShow&&(identical(other.value, value) || other.value == value)&&(identical(other.unit, unit) || other.unit == unit));
}


@override
int get hashCode => Object.hash(runtimeType,value,unit);

@override
String toString() {
  return 'TrafficShow(value: $value, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$TrafficShowCopyWith<$Res> implements $TrafficShowCopyWith<$Res> {
  factory _$TrafficShowCopyWith(_TrafficShow value, $Res Function(_TrafficShow) _then) = __$TrafficShowCopyWithImpl;
@override @useResult
$Res call({
 String value, String unit
});




}
/// @nodoc
class __$TrafficShowCopyWithImpl<$Res>
    implements _$TrafficShowCopyWith<$Res> {
  __$TrafficShowCopyWithImpl(this._self, this._then);

  final _TrafficShow _self;
  final $Res Function(_TrafficShow) _then;

/// Create a copy of TrafficShow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? unit = null,}) {
  return _then(_TrafficShow(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Proxy {

 String get name; String get type; String? get now;
/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyCopyWith<Proxy> get copyWith => _$ProxyCopyWithImpl<Proxy>(this as Proxy, _$identity);

  /// Serializes this Proxy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proxy&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.now, now) || other.now == now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,now);

@override
String toString() {
  return 'Proxy(name: $name, type: $type, now: $now)';
}


}

/// @nodoc
abstract mixin class $ProxyCopyWith<$Res>  {
  factory $ProxyCopyWith(Proxy value, $Res Function(Proxy) _then) = _$ProxyCopyWithImpl;
@useResult
$Res call({
 String name, String type, String? now
});




}
/// @nodoc
class _$ProxyCopyWithImpl<$Res>
    implements $ProxyCopyWith<$Res> {
  _$ProxyCopyWithImpl(this._self, this._then);

  final Proxy _self;
  final $Res Function(Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? now = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Proxy].
extension ProxyPatterns on Proxy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Proxy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Proxy value)  $default,){
final _that = this;
switch (_that) {
case _Proxy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Proxy value)?  $default,){
final _that = this;
switch (_that) {
case _Proxy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String type,  String? now)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String type,  String? now)  $default,) {final _that = this;
switch (_that) {
case _Proxy():
return $default(_that.name,_that.type,_that.now);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String type,  String? now)?  $default,) {final _that = this;
switch (_that) {
case _Proxy() when $default != null:
return $default(_that.name,_that.type,_that.now);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Proxy implements Proxy {
  const _Proxy({required this.name, required this.type, this.now});
  factory _Proxy.fromJson(Map<String, dynamic> json) => _$ProxyFromJson(json);

@override final  String name;
@override final  String type;
@override final  String? now;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyCopyWith<_Proxy> get copyWith => __$ProxyCopyWithImpl<_Proxy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProxyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Proxy&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.now, now) || other.now == now));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,now);

@override
String toString() {
  return 'Proxy(name: $name, type: $type, now: $now)';
}


}

/// @nodoc
abstract mixin class _$ProxyCopyWith<$Res> implements $ProxyCopyWith<$Res> {
  factory _$ProxyCopyWith(_Proxy value, $Res Function(_Proxy) _then) = __$ProxyCopyWithImpl;
@override @useResult
$Res call({
 String name, String type, String? now
});




}
/// @nodoc
class __$ProxyCopyWithImpl<$Res>
    implements _$ProxyCopyWith<$Res> {
  __$ProxyCopyWithImpl(this._self, this._then);

  final _Proxy _self;
  final $Res Function(_Proxy) _then;

/// Create a copy of Proxy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? now = freezed,}) {
  return _then(_Proxy(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Group {

 GroupType get type; List<Proxy> get all; String? get now; bool? get hidden; String? get testUrl; String get icon; String get name;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.all, all)&&(identical(other.now, now) || other.now == now)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(all),now,hidden,testUrl,icon,name);

@override
String toString() {
  return 'Group(type: $type, all: $all, now: $now, hidden: $hidden, testUrl: $testUrl, icon: $icon, name: $name)';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 GroupType type, List<Proxy> all, String? now, bool? hidden, String? testUrl, String icon, String name
});




}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? all = null,Object? now = freezed,Object? hidden = freezed,Object? testUrl = freezed,Object? icon = null,Object? name = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,all: null == all ? _self.all : all // ignore: cast_nullable_to_non_nullable
as List<Proxy>,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GroupType type,  List<Proxy> all,  String? now,  bool? hidden,  String? testUrl,  String icon,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.type,_that.all,_that.now,_that.hidden,_that.testUrl,_that.icon,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Group implements Group {
  const _Group({required this.type, final  List<Proxy> all = const [], this.now, this.hidden, this.testUrl, this.icon = '', required this.name}): _all = all;
  factory _Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

@override final  GroupType type;
 final  List<Proxy> _all;
@override@JsonKey() List<Proxy> get all {
  if (_all is EqualUnmodifiableListView) return _all;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_all);
}

@override final  String? now;
@override final  bool? hidden;
@override final  String? testUrl;
@override@JsonKey() final  String icon;
@override final  String name;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._all, _all)&&(identical(other.now, now) || other.now == now)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_all),now,hidden,testUrl,icon,name);

@override
String toString() {
  return 'Group(type: $type, all: $all, now: $now, hidden: $hidden, testUrl: $testUrl, icon: $icon, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 GroupType type, List<Proxy> all, String? now, bool? hidden, String? testUrl, String icon, String name
});




}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? all = null,Object? now = freezed,Object? hidden = freezed,Object? testUrl = freezed,Object? icon = null,Object? name = null,}) {
  return _then(_Group(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as GroupType,all: null == all ? _self._all : all // ignore: cast_nullable_to_non_nullable
as List<Proxy>,now: freezed == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as String?,hidden: freezed == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool?,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ColorSchemes {

 ColorScheme? get lightColorScheme; ColorScheme? get darkColorScheme;
/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorSchemesCopyWith<ColorSchemes> get copyWith => _$ColorSchemesCopyWithImpl<ColorSchemes>(this as ColorSchemes, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorSchemes&&(identical(other.lightColorScheme, lightColorScheme) || other.lightColorScheme == lightColorScheme)&&(identical(other.darkColorScheme, darkColorScheme) || other.darkColorScheme == darkColorScheme));
}


@override
int get hashCode => Object.hash(runtimeType,lightColorScheme,darkColorScheme);

@override
String toString() {
  return 'ColorSchemes(lightColorScheme: $lightColorScheme, darkColorScheme: $darkColorScheme)';
}


}

/// @nodoc
abstract mixin class $ColorSchemesCopyWith<$Res>  {
  factory $ColorSchemesCopyWith(ColorSchemes value, $Res Function(ColorSchemes) _then) = _$ColorSchemesCopyWithImpl;
@useResult
$Res call({
 ColorScheme? lightColorScheme, ColorScheme? darkColorScheme
});




}
/// @nodoc
class _$ColorSchemesCopyWithImpl<$Res>
    implements $ColorSchemesCopyWith<$Res> {
  _$ColorSchemesCopyWithImpl(this._self, this._then);

  final ColorSchemes _self;
  final $Res Function(ColorSchemes) _then;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lightColorScheme = freezed,Object? darkColorScheme = freezed,}) {
  return _then(_self.copyWith(
lightColorScheme: freezed == lightColorScheme ? _self.lightColorScheme : lightColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,darkColorScheme: freezed == darkColorScheme ? _self.darkColorScheme : darkColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorSchemes].
extension ColorSchemesPatterns on ColorSchemes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorSchemes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorSchemes value)  $default,){
final _that = this;
switch (_that) {
case _ColorSchemes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorSchemes value)?  $default,){
final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)  $default,) {final _that = this;
switch (_that) {
case _ColorSchemes():
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ColorScheme? lightColorScheme,  ColorScheme? darkColorScheme)?  $default,) {final _that = this;
switch (_that) {
case _ColorSchemes() when $default != null:
return $default(_that.lightColorScheme,_that.darkColorScheme);case _:
  return null;

}
}

}

/// @nodoc


class _ColorSchemes implements ColorSchemes {
  const _ColorSchemes({this.lightColorScheme, this.darkColorScheme});
  

@override final  ColorScheme? lightColorScheme;
@override final  ColorScheme? darkColorScheme;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorSchemesCopyWith<_ColorSchemes> get copyWith => __$ColorSchemesCopyWithImpl<_ColorSchemes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorSchemes&&(identical(other.lightColorScheme, lightColorScheme) || other.lightColorScheme == lightColorScheme)&&(identical(other.darkColorScheme, darkColorScheme) || other.darkColorScheme == darkColorScheme));
}


@override
int get hashCode => Object.hash(runtimeType,lightColorScheme,darkColorScheme);

@override
String toString() {
  return 'ColorSchemes(lightColorScheme: $lightColorScheme, darkColorScheme: $darkColorScheme)';
}


}

/// @nodoc
abstract mixin class _$ColorSchemesCopyWith<$Res> implements $ColorSchemesCopyWith<$Res> {
  factory _$ColorSchemesCopyWith(_ColorSchemes value, $Res Function(_ColorSchemes) _then) = __$ColorSchemesCopyWithImpl;
@override @useResult
$Res call({
 ColorScheme? lightColorScheme, ColorScheme? darkColorScheme
});




}
/// @nodoc
class __$ColorSchemesCopyWithImpl<$Res>
    implements _$ColorSchemesCopyWith<$Res> {
  __$ColorSchemesCopyWithImpl(this._self, this._then);

  final _ColorSchemes _self;
  final $Res Function(_ColorSchemes) _then;

/// Create a copy of ColorSchemes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lightColorScheme = freezed,Object? darkColorScheme = freezed,}) {
  return _then(_ColorSchemes(
lightColorScheme: freezed == lightColorScheme ? _self.lightColorScheme : lightColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,darkColorScheme: freezed == darkColorScheme ? _self.darkColorScheme : darkColorScheme // ignore: cast_nullable_to_non_nullable
as ColorScheme?,
  ));
}


}

/// @nodoc
mixin _$IpInfo {

 String get ip; String get countryCode;
/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IpInfoCopyWith<IpInfo> get copyWith => _$IpInfoCopyWithImpl<IpInfo>(this as IpInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IpInfo&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}


@override
int get hashCode => Object.hash(runtimeType,ip,countryCode);

@override
String toString() {
  return 'IpInfo(ip: $ip, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class $IpInfoCopyWith<$Res>  {
  factory $IpInfoCopyWith(IpInfo value, $Res Function(IpInfo) _then) = _$IpInfoCopyWithImpl;
@useResult
$Res call({
 String ip, String countryCode
});




}
/// @nodoc
class _$IpInfoCopyWithImpl<$Res>
    implements $IpInfoCopyWith<$Res> {
  _$IpInfoCopyWithImpl(this._self, this._then);

  final IpInfo _self;
  final $Res Function(IpInfo) _then;

/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ip = null,Object? countryCode = null,}) {
  return _then(_self.copyWith(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [IpInfo].
extension IpInfoPatterns on IpInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IpInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IpInfo value)  $default,){
final _that = this;
switch (_that) {
case _IpInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IpInfo value)?  $default,){
final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ip,  String countryCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
return $default(_that.ip,_that.countryCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ip,  String countryCode)  $default,) {final _that = this;
switch (_that) {
case _IpInfo():
return $default(_that.ip,_that.countryCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ip,  String countryCode)?  $default,) {final _that = this;
switch (_that) {
case _IpInfo() when $default != null:
return $default(_that.ip,_that.countryCode);case _:
  return null;

}
}

}

/// @nodoc


class _IpInfo implements IpInfo {
  const _IpInfo({required this.ip, required this.countryCode});
  

@override final  String ip;
@override final  String countryCode;

/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IpInfoCopyWith<_IpInfo> get copyWith => __$IpInfoCopyWithImpl<_IpInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IpInfo&&(identical(other.ip, ip) || other.ip == ip)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode));
}


@override
int get hashCode => Object.hash(runtimeType,ip,countryCode);

@override
String toString() {
  return 'IpInfo(ip: $ip, countryCode: $countryCode)';
}


}

/// @nodoc
abstract mixin class _$IpInfoCopyWith<$Res> implements $IpInfoCopyWith<$Res> {
  factory _$IpInfoCopyWith(_IpInfo value, $Res Function(_IpInfo) _then) = __$IpInfoCopyWithImpl;
@override @useResult
$Res call({
 String ip, String countryCode
});




}
/// @nodoc
class __$IpInfoCopyWithImpl<$Res>
    implements _$IpInfoCopyWith<$Res> {
  __$IpInfoCopyWithImpl(this._self, this._then);

  final _IpInfo _self;
  final $Res Function(_IpInfo) _then;

/// Create a copy of IpInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ip = null,Object? countryCode = null,}) {
  return _then(_IpInfo(
ip: null == ip ? _self.ip : ip // ignore: cast_nullable_to_non_nullable
as String,countryCode: null == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$HotKeyAction {

 HotAction get action; int? get key; Set<KeyboardModifier> get modifiers;
/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotKeyActionCopyWith<HotKeyAction> get copyWith => _$HotKeyActionCopyWithImpl<HotKeyAction>(this as HotKeyAction, _$identity);

  /// Serializes this HotKeyAction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotKeyAction&&(identical(other.action, action) || other.action == action)&&(identical(other.key, key) || other.key == key)&&const DeepCollectionEquality().equals(other.modifiers, modifiers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,key,const DeepCollectionEquality().hash(modifiers));

@override
String toString() {
  return 'HotKeyAction(action: $action, key: $key, modifiers: $modifiers)';
}


}

/// @nodoc
abstract mixin class $HotKeyActionCopyWith<$Res>  {
  factory $HotKeyActionCopyWith(HotKeyAction value, $Res Function(HotKeyAction) _then) = _$HotKeyActionCopyWithImpl;
@useResult
$Res call({
 HotAction action, int? key, Set<KeyboardModifier> modifiers
});




}
/// @nodoc
class _$HotKeyActionCopyWithImpl<$Res>
    implements $HotKeyActionCopyWith<$Res> {
  _$HotKeyActionCopyWithImpl(this._self, this._then);

  final HotKeyAction _self;
  final $Res Function(HotKeyAction) _then;

/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? action = null,Object? key = freezed,Object? modifiers = null,}) {
  return _then(_self.copyWith(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotAction,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as int?,modifiers: null == modifiers ? _self.modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as Set<KeyboardModifier>,
  ));
}

}


/// Adds pattern-matching-related methods to [HotKeyAction].
extension HotKeyActionPatterns on HotKeyAction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotKeyAction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotKeyAction value)  $default,){
final _that = this;
switch (_that) {
case _HotKeyAction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotKeyAction value)?  $default,){
final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
return $default(_that.action,_that.key,_that.modifiers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)  $default,) {final _that = this;
switch (_that) {
case _HotKeyAction():
return $default(_that.action,_that.key,_that.modifiers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HotAction action,  int? key,  Set<KeyboardModifier> modifiers)?  $default,) {final _that = this;
switch (_that) {
case _HotKeyAction() when $default != null:
return $default(_that.action,_that.key,_that.modifiers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HotKeyAction implements HotKeyAction {
  const _HotKeyAction({required this.action, this.key, final  Set<KeyboardModifier> modifiers = const {}}): _modifiers = modifiers;
  factory _HotKeyAction.fromJson(Map<String, dynamic> json) => _$HotKeyActionFromJson(json);

@override final  HotAction action;
@override final  int? key;
 final  Set<KeyboardModifier> _modifiers;
@override@JsonKey() Set<KeyboardModifier> get modifiers {
  if (_modifiers is EqualUnmodifiableSetView) return _modifiers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_modifiers);
}


/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotKeyActionCopyWith<_HotKeyAction> get copyWith => __$HotKeyActionCopyWithImpl<_HotKeyAction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HotKeyActionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotKeyAction&&(identical(other.action, action) || other.action == action)&&(identical(other.key, key) || other.key == key)&&const DeepCollectionEquality().equals(other._modifiers, _modifiers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action,key,const DeepCollectionEquality().hash(_modifiers));

@override
String toString() {
  return 'HotKeyAction(action: $action, key: $key, modifiers: $modifiers)';
}


}

/// @nodoc
abstract mixin class _$HotKeyActionCopyWith<$Res> implements $HotKeyActionCopyWith<$Res> {
  factory _$HotKeyActionCopyWith(_HotKeyAction value, $Res Function(_HotKeyAction) _then) = __$HotKeyActionCopyWithImpl;
@override @useResult
$Res call({
 HotAction action, int? key, Set<KeyboardModifier> modifiers
});




}
/// @nodoc
class __$HotKeyActionCopyWithImpl<$Res>
    implements _$HotKeyActionCopyWith<$Res> {
  __$HotKeyActionCopyWithImpl(this._self, this._then);

  final _HotKeyAction _self;
  final $Res Function(_HotKeyAction) _then;

/// Create a copy of HotKeyAction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? action = null,Object? key = freezed,Object? modifiers = null,}) {
  return _then(_HotKeyAction(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as HotAction,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as int?,modifiers: null == modifiers ? _self._modifiers : modifiers // ignore: cast_nullable_to_non_nullable
as Set<KeyboardModifier>,
  ));
}


}

/// @nodoc
mixin _$Field {

 String get label; String get value; Validator? get validator;
/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldCopyWith<Field> get copyWith => _$FieldCopyWithImpl<Field>(this as Field, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Field&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.validator, validator) || other.validator == validator));
}


@override
int get hashCode => Object.hash(runtimeType,label,value,validator);

@override
String toString() {
  return 'Field(label: $label, value: $value, validator: $validator)';
}


}

/// @nodoc
abstract mixin class $FieldCopyWith<$Res>  {
  factory $FieldCopyWith(Field value, $Res Function(Field) _then) = _$FieldCopyWithImpl;
@useResult
$Res call({
 String label, String value, Validator? validator
});




}
/// @nodoc
class _$FieldCopyWithImpl<$Res>
    implements $FieldCopyWith<$Res> {
  _$FieldCopyWithImpl(this._self, this._then);

  final Field _self;
  final $Res Function(Field) _then;

/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,Object? validator = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,validator: freezed == validator ? _self.validator : validator // ignore: cast_nullable_to_non_nullable
as Validator?,
  ));
}

}


/// Adds pattern-matching-related methods to [Field].
extension FieldPatterns on Field {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Field value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Field() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Field value)  $default,){
final _that = this;
switch (_that) {
case _Field():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Field value)?  $default,){
final _that = this;
switch (_that) {
case _Field() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value,  Validator? validator)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Field() when $default != null:
return $default(_that.label,_that.value,_that.validator);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value,  Validator? validator)  $default,) {final _that = this;
switch (_that) {
case _Field():
return $default(_that.label,_that.value,_that.validator);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value,  Validator? validator)?  $default,) {final _that = this;
switch (_that) {
case _Field() when $default != null:
return $default(_that.label,_that.value,_that.validator);case _:
  return null;

}
}

}

/// @nodoc


class _Field implements Field {
  const _Field({required this.label, required this.value, this.validator});
  

@override final  String label;
@override final  String value;
@override final  Validator? validator;

/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldCopyWith<_Field> get copyWith => __$FieldCopyWithImpl<_Field>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Field&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.validator, validator) || other.validator == validator));
}


@override
int get hashCode => Object.hash(runtimeType,label,value,validator);

@override
String toString() {
  return 'Field(label: $label, value: $value, validator: $validator)';
}


}

/// @nodoc
abstract mixin class _$FieldCopyWith<$Res> implements $FieldCopyWith<$Res> {
  factory _$FieldCopyWith(_Field value, $Res Function(_Field) _then) = __$FieldCopyWithImpl;
@override @useResult
$Res call({
 String label, String value, Validator? validator
});




}
/// @nodoc
class __$FieldCopyWithImpl<$Res>
    implements _$FieldCopyWith<$Res> {
  __$FieldCopyWithImpl(this._self, this._then);

  final _Field _self;
  final $Res Function(_Field) _then;

/// Create a copy of Field
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,Object? validator = freezed,}) {
  return _then(_Field(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,validator: freezed == validator ? _self.validator : validator // ignore: cast_nullable_to_non_nullable
as Validator?,
  ));
}


}


/// @nodoc
mixin _$AndroidState {

 String get currentProfileName; String get stopText; bool get onlyStatisticsProxy; bool get crashlytics;
/// Create a copy of AndroidState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AndroidStateCopyWith<AndroidState> get copyWith => _$AndroidStateCopyWithImpl<AndroidState>(this as AndroidState, _$identity);

  /// Serializes this AndroidState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AndroidState&&(identical(other.currentProfileName, currentProfileName) || other.currentProfileName == currentProfileName)&&(identical(other.stopText, stopText) || other.stopText == stopText)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentProfileName,stopText,onlyStatisticsProxy,crashlytics);

@override
String toString() {
  return 'AndroidState(currentProfileName: $currentProfileName, stopText: $stopText, onlyStatisticsProxy: $onlyStatisticsProxy, crashlytics: $crashlytics)';
}


}

/// @nodoc
abstract mixin class $AndroidStateCopyWith<$Res>  {
  factory $AndroidStateCopyWith(AndroidState value, $Res Function(AndroidState) _then) = _$AndroidStateCopyWithImpl;
@useResult
$Res call({
 String currentProfileName, String stopText, bool onlyStatisticsProxy, bool crashlytics
});




}
/// @nodoc
class _$AndroidStateCopyWithImpl<$Res>
    implements $AndroidStateCopyWith<$Res> {
  _$AndroidStateCopyWithImpl(this._self, this._then);

  final AndroidState _self;
  final $Res Function(AndroidState) _then;

/// Create a copy of AndroidState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentProfileName = null,Object? stopText = null,Object? onlyStatisticsProxy = null,Object? crashlytics = null,}) {
  return _then(_self.copyWith(
currentProfileName: null == currentProfileName ? _self.currentProfileName : currentProfileName // ignore: cast_nullable_to_non_nullable
as String,stopText: null == stopText ? _self.stopText : stopText // ignore: cast_nullable_to_non_nullable
as String,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AndroidState].
extension AndroidStatePatterns on AndroidState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AndroidState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AndroidState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AndroidState value)  $default,){
final _that = this;
switch (_that) {
case _AndroidState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AndroidState value)?  $default,){
final _that = this;
switch (_that) {
case _AndroidState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentProfileName,  String stopText,  bool onlyStatisticsProxy,  bool crashlytics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AndroidState() when $default != null:
return $default(_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy,_that.crashlytics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentProfileName,  String stopText,  bool onlyStatisticsProxy,  bool crashlytics)  $default,) {final _that = this;
switch (_that) {
case _AndroidState():
return $default(_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy,_that.crashlytics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentProfileName,  String stopText,  bool onlyStatisticsProxy,  bool crashlytics)?  $default,) {final _that = this;
switch (_that) {
case _AndroidState() when $default != null:
return $default(_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy,_that.crashlytics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AndroidState implements AndroidState {
  const _AndroidState({required this.currentProfileName, required this.stopText, required this.onlyStatisticsProxy, required this.crashlytics});
  factory _AndroidState.fromJson(Map<String, dynamic> json) => _$AndroidStateFromJson(json);

@override final  String currentProfileName;
@override final  String stopText;
@override final  bool onlyStatisticsProxy;
@override final  bool crashlytics;

/// Create a copy of AndroidState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AndroidStateCopyWith<_AndroidState> get copyWith => __$AndroidStateCopyWithImpl<_AndroidState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AndroidStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AndroidState&&(identical(other.currentProfileName, currentProfileName) || other.currentProfileName == currentProfileName)&&(identical(other.stopText, stopText) || other.stopText == stopText)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentProfileName,stopText,onlyStatisticsProxy,crashlytics);

@override
String toString() {
  return 'AndroidState(currentProfileName: $currentProfileName, stopText: $stopText, onlyStatisticsProxy: $onlyStatisticsProxy, crashlytics: $crashlytics)';
}


}

/// @nodoc
abstract mixin class _$AndroidStateCopyWith<$Res> implements $AndroidStateCopyWith<$Res> {
  factory _$AndroidStateCopyWith(_AndroidState value, $Res Function(_AndroidState) _then) = __$AndroidStateCopyWithImpl;
@override @useResult
$Res call({
 String currentProfileName, String stopText, bool onlyStatisticsProxy, bool crashlytics
});




}
/// @nodoc
class __$AndroidStateCopyWithImpl<$Res>
    implements _$AndroidStateCopyWith<$Res> {
  __$AndroidStateCopyWithImpl(this._self, this._then);

  final _AndroidState _self;
  final $Res Function(_AndroidState) _then;

/// Create a copy of AndroidState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentProfileName = null,Object? stopText = null,Object? onlyStatisticsProxy = null,Object? crashlytics = null,}) {
  return _then(_AndroidState(
currentProfileName: null == currentProfileName ? _self.currentProfileName : currentProfileName // ignore: cast_nullable_to_non_nullable
as String,stopText: null == stopText ? _self.stopText : stopText // ignore: cast_nullable_to_non_nullable
as String,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$Result<T> {

 T? get data; ResultType get type; String get message;
/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultCopyWith<T, Result<T>> get copyWith => _$ResultCopyWithImpl<T, Result<T>>(this as Result<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,message);

@override
String toString() {
  return 'Result<$T>(data: $data, type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class $ResultCopyWith<T,$Res>  {
  factory $ResultCopyWith(Result<T> value, $Res Function(Result<T>) _then) = _$ResultCopyWithImpl;
@useResult
$Res call({
 T? data, ResultType type, String message
});




}
/// @nodoc
class _$ResultCopyWithImpl<T,$Res>
    implements $ResultCopyWith<T, $Res> {
  _$ResultCopyWithImpl(this._self, this._then);

  final Result<T> _self;
  final $Res Function(Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? type = null,Object? message = null,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Result<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Result<T> value)  $default,){
final _that = this;
switch (_that) {
case _Result():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Result<T> value)?  $default,){
final _that = this;
switch (_that) {
case _Result() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T? data,  ResultType type,  String message)  $default,) {final _that = this;
switch (_that) {
case _Result():
return $default(_that.data,_that.type,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T? data,  ResultType type,  String message)?  $default,) {final _that = this;
switch (_that) {
case _Result() when $default != null:
return $default(_that.data,_that.type,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Result<T> implements Result<T> {
  const _Result({required this.data, required this.type, required this.message});
  

@override final  T? data;
@override final  ResultType type;
@override final  String message;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultCopyWith<T, _Result<T>> get copyWith => __$ResultCopyWithImpl<T, _Result<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Result<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.type, type) || other.type == type)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),type,message);

@override
String toString() {
  return 'Result<$T>(data: $data, type: $type, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ResultCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory _$ResultCopyWith(_Result<T> value, $Res Function(_Result<T>) _then) = __$ResultCopyWithImpl;
@override @useResult
$Res call({
 T? data, ResultType type, String message
});




}
/// @nodoc
class __$ResultCopyWithImpl<T,$Res>
    implements _$ResultCopyWith<T, $Res> {
  __$ResultCopyWithImpl(this._self, this._then);

  final _Result<T> _self;
  final $Res Function(_Result<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? type = null,Object? message = null,}) {
  return _then(_Result<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ResultType,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Script {

 String get id; String get label; String get content;
/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptCopyWith<Script> get copyWith => _$ScriptCopyWithImpl<Script>(this as Script, _$identity);

  /// Serializes this Script to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Script&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,content);

@override
String toString() {
  return 'Script(id: $id, label: $label, content: $content)';
}


}

/// @nodoc
abstract mixin class $ScriptCopyWith<$Res>  {
  factory $ScriptCopyWith(Script value, $Res Function(Script) _then) = _$ScriptCopyWithImpl;
@useResult
$Res call({
 String id, String label, String content
});




}
/// @nodoc
class _$ScriptCopyWithImpl<$Res>
    implements $ScriptCopyWith<$Res> {
  _$ScriptCopyWithImpl(this._self, this._then);

  final Script _self;
  final $Res Function(Script) _then;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? content = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Script].
extension ScriptPatterns on Script {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Script value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Script() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Script value)  $default,){
final _that = this;
switch (_that) {
case _Script():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Script value)?  $default,){
final _that = this;
switch (_that) {
case _Script() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that.id,_that.label,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String content)  $default,) {final _that = this;
switch (_that) {
case _Script():
return $default(_that.id,_that.label,_that.content);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String content)?  $default,) {final _that = this;
switch (_that) {
case _Script() when $default != null:
return $default(_that.id,_that.label,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Script implements Script {
  const _Script({required this.id, required this.label, required this.content});
  factory _Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);

@override final  String id;
@override final  String label;
@override final  String content;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptCopyWith<_Script> get copyWith => __$ScriptCopyWithImpl<_Script>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Script&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,content);

@override
String toString() {
  return 'Script(id: $id, label: $label, content: $content)';
}


}

/// @nodoc
abstract mixin class _$ScriptCopyWith<$Res> implements $ScriptCopyWith<$Res> {
  factory _$ScriptCopyWith(_Script value, $Res Function(_Script) _then) = __$ScriptCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String content
});




}
/// @nodoc
class __$ScriptCopyWithImpl<$Res>
    implements _$ScriptCopyWith<$Res> {
  __$ScriptCopyWithImpl(this._self, this._then);

  final _Script _self;
  final $Res Function(_Script) _then;

/// Create a copy of Script
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? content = null,}) {
  return _then(_Script(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$DelayState {

 int get delay; bool get group;
/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DelayStateCopyWith<DelayState> get copyWith => _$DelayStateCopyWithImpl<DelayState>(this as DelayState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DelayState&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.group, group) || other.group == group));
}


@override
int get hashCode => Object.hash(runtimeType,delay,group);

@override
String toString() {
  return 'DelayState(delay: $delay, group: $group)';
}


}

/// @nodoc
abstract mixin class $DelayStateCopyWith<$Res>  {
  factory $DelayStateCopyWith(DelayState value, $Res Function(DelayState) _then) = _$DelayStateCopyWithImpl;
@useResult
$Res call({
 int delay, bool group
});




}
/// @nodoc
class _$DelayStateCopyWithImpl<$Res>
    implements $DelayStateCopyWith<$Res> {
  _$DelayStateCopyWithImpl(this._self, this._then);

  final DelayState _self;
  final $Res Function(DelayState) _then;

/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? delay = null,Object? group = null,}) {
  return _then(_self.copyWith(
delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [DelayState].
extension DelayStatePatterns on DelayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DelayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DelayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DelayState value)  $default,){
final _that = this;
switch (_that) {
case _DelayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DelayState value)?  $default,){
final _that = this;
switch (_that) {
case _DelayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int delay,  bool group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DelayState() when $default != null:
return $default(_that.delay,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int delay,  bool group)  $default,) {final _that = this;
switch (_that) {
case _DelayState():
return $default(_that.delay,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int delay,  bool group)?  $default,) {final _that = this;
switch (_that) {
case _DelayState() when $default != null:
return $default(_that.delay,_that.group);case _:
  return null;

}
}

}

/// @nodoc


class _DelayState implements DelayState {
  const _DelayState({required this.delay, required this.group});
  

@override final  int delay;
@override final  bool group;

/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DelayStateCopyWith<_DelayState> get copyWith => __$DelayStateCopyWithImpl<_DelayState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DelayState&&(identical(other.delay, delay) || other.delay == delay)&&(identical(other.group, group) || other.group == group));
}


@override
int get hashCode => Object.hash(runtimeType,delay,group);

@override
String toString() {
  return 'DelayState(delay: $delay, group: $group)';
}


}

/// @nodoc
abstract mixin class _$DelayStateCopyWith<$Res> implements $DelayStateCopyWith<$Res> {
  factory _$DelayStateCopyWith(_DelayState value, $Res Function(_DelayState) _then) = __$DelayStateCopyWithImpl;
@override @useResult
$Res call({
 int delay, bool group
});




}
/// @nodoc
class __$DelayStateCopyWithImpl<$Res>
    implements _$DelayStateCopyWith<$Res> {
  __$DelayStateCopyWithImpl(this._self, this._then);

  final _DelayState _self;
  final $Res Function(_DelayState) _then;

/// Create a copy of DelayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? delay = null,Object? group = null,}) {
  return _then(_DelayState(
delay: null == delay ? _self.delay : delay // ignore: cast_nullable_to_non_nullable
as int,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

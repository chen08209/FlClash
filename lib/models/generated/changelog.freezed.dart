// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../changelog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChangelogEntry {

 String get id; String? get scope; String get text;
/// Create a copy of ChangelogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogEntryCopyWith<ChangelogEntry> get copyWith => _$ChangelogEntryCopyWithImpl<ChangelogEntry>(this as ChangelogEntry, _$identity);

  /// Serializes this ChangelogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scope,text);

@override
String toString() {
  return 'ChangelogEntry(id: $id, scope: $scope, text: $text)';
}


}

/// @nodoc
abstract mixin class $ChangelogEntryCopyWith<$Res>  {
  factory $ChangelogEntryCopyWith(ChangelogEntry value, $Res Function(ChangelogEntry) _then) = _$ChangelogEntryCopyWithImpl;
@useResult
$Res call({
 String id, String? scope, String text
});




}
/// @nodoc
class _$ChangelogEntryCopyWithImpl<$Res>
    implements $ChangelogEntryCopyWith<$Res> {
  _$ChangelogEntryCopyWithImpl(this._self, this._then);

  final ChangelogEntry _self;
  final $Res Function(ChangelogEntry) _then;

/// Create a copy of ChangelogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scope = freezed,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogEntry].
extension ChangelogEntryPatterns on ChangelogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogEntry value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? scope,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogEntry() when $default != null:
return $default(_that.id,_that.scope,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? scope,  String text)  $default,) {final _that = this;
switch (_that) {
case _ChangelogEntry():
return $default(_that.id,_that.scope,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? scope,  String text)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogEntry() when $default != null:
return $default(_that.id,_that.scope,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangelogEntry implements ChangelogEntry {
  const _ChangelogEntry({required this.id, this.scope, this.text = ''});
  factory _ChangelogEntry.fromJson(Map<String, dynamic> json) => _$ChangelogEntryFromJson(json);

@override final  String id;
@override final  String? scope;
@override@JsonKey() final  String text;

/// Create a copy of ChangelogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogEntryCopyWith<_ChangelogEntry> get copyWith => __$ChangelogEntryCopyWithImpl<_ChangelogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,scope,text);

@override
String toString() {
  return 'ChangelogEntry(id: $id, scope: $scope, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ChangelogEntryCopyWith<$Res> implements $ChangelogEntryCopyWith<$Res> {
  factory _$ChangelogEntryCopyWith(_ChangelogEntry value, $Res Function(_ChangelogEntry) _then) = __$ChangelogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? scope, String text
});




}
/// @nodoc
class __$ChangelogEntryCopyWithImpl<$Res>
    implements _$ChangelogEntryCopyWith<$Res> {
  __$ChangelogEntryCopyWithImpl(this._self, this._then);

  final _ChangelogEntry _self;
  final $Res Function(_ChangelogEntry) _then;

/// Create a copy of ChangelogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scope = freezed,Object? text = null,}) {
  return _then(_ChangelogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: freezed == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ChangelogGroup {

@JsonKey(unknownEnumValue: ChangelogType.unknown) ChangelogType get type; List<ChangelogEntry> get entries;
/// Create a copy of ChangelogGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogGroupCopyWith<ChangelogGroup> get copyWith => _$ChangelogGroupCopyWithImpl<ChangelogGroup>(this as ChangelogGroup, _$identity);

  /// Serializes this ChangelogGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogGroup&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.entries, entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'ChangelogGroup(type: $type, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $ChangelogGroupCopyWith<$Res>  {
  factory $ChangelogGroupCopyWith(ChangelogGroup value, $Res Function(ChangelogGroup) _then) = _$ChangelogGroupCopyWithImpl;
@useResult
$Res call({
@JsonKey(unknownEnumValue: ChangelogType.unknown) ChangelogType type, List<ChangelogEntry> entries
});




}
/// @nodoc
class _$ChangelogGroupCopyWithImpl<$Res>
    implements $ChangelogGroupCopyWith<$Res> {
  _$ChangelogGroupCopyWithImpl(this._self, this._then);

  final ChangelogGroup _self;
  final $Res Function(ChangelogGroup) _then;

/// Create a copy of ChangelogGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? entries = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChangelogType,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ChangelogEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogGroup].
extension ChangelogGroupPatterns on ChangelogGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogGroup value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ChangelogType.unknown)  ChangelogType type,  List<ChangelogEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogGroup() when $default != null:
return $default(_that.type,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(unknownEnumValue: ChangelogType.unknown)  ChangelogType type,  List<ChangelogEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _ChangelogGroup():
return $default(_that.type,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(unknownEnumValue: ChangelogType.unknown)  ChangelogType type,  List<ChangelogEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogGroup() when $default != null:
return $default(_that.type,_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangelogGroup implements ChangelogGroup {
  const _ChangelogGroup({@JsonKey(unknownEnumValue: ChangelogType.unknown) this.type = ChangelogType.unknown, final  List<ChangelogEntry> entries = const []}): _entries = entries;
  factory _ChangelogGroup.fromJson(Map<String, dynamic> json) => _$ChangelogGroupFromJson(json);

@override@JsonKey(unknownEnumValue: ChangelogType.unknown) final  ChangelogType type;
 final  List<ChangelogEntry> _entries;
@override@JsonKey() List<ChangelogEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of ChangelogGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogGroupCopyWith<_ChangelogGroup> get copyWith => __$ChangelogGroupCopyWithImpl<_ChangelogGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogGroup&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'ChangelogGroup(type: $type, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$ChangelogGroupCopyWith<$Res> implements $ChangelogGroupCopyWith<$Res> {
  factory _$ChangelogGroupCopyWith(_ChangelogGroup value, $Res Function(_ChangelogGroup) _then) = __$ChangelogGroupCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(unknownEnumValue: ChangelogType.unknown) ChangelogType type, List<ChangelogEntry> entries
});




}
/// @nodoc
class __$ChangelogGroupCopyWithImpl<$Res>
    implements _$ChangelogGroupCopyWith<$Res> {
  __$ChangelogGroupCopyWithImpl(this._self, this._then);

  final _ChangelogGroup _self;
  final $Res Function(_ChangelogGroup) _then;

/// Create a copy of ChangelogGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? entries = null,}) {
  return _then(_ChangelogGroup(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChangelogType,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ChangelogEntry>,
  ));
}


}


/// @nodoc
mixin _$ChangelogVersion {

 String get version; String get tag; String get date; bool get prerelease; List<ChangelogGroup> get groups;
/// Create a copy of ChangelogVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogVersionCopyWith<ChangelogVersion> get copyWith => _$ChangelogVersionCopyWithImpl<ChangelogVersion>(this as ChangelogVersion, _$identity);

  /// Serializes this ChangelogVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangelogVersion&&(identical(other.version, version) || other.version == version)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.date, date) || other.date == date)&&(identical(other.prerelease, prerelease) || other.prerelease == prerelease)&&const DeepCollectionEquality().equals(other.groups, groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,tag,date,prerelease,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'ChangelogVersion(version: $version, tag: $tag, date: $date, prerelease: $prerelease, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $ChangelogVersionCopyWith<$Res>  {
  factory $ChangelogVersionCopyWith(ChangelogVersion value, $Res Function(ChangelogVersion) _then) = _$ChangelogVersionCopyWithImpl;
@useResult
$Res call({
 String version, String tag, String date, bool prerelease, List<ChangelogGroup> groups
});




}
/// @nodoc
class _$ChangelogVersionCopyWithImpl<$Res>
    implements $ChangelogVersionCopyWith<$Res> {
  _$ChangelogVersionCopyWithImpl(this._self, this._then);

  final ChangelogVersion _self;
  final $Res Function(ChangelogVersion) _then;

/// Create a copy of ChangelogVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? tag = null,Object? date = null,Object? prerelease = null,Object? groups = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,prerelease: null == prerelease ? _self.prerelease : prerelease // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<ChangelogGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChangelogVersion].
extension ChangelogVersionPatterns on ChangelogVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangelogVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangelogVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangelogVersion value)  $default,){
final _that = this;
switch (_that) {
case _ChangelogVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangelogVersion value)?  $default,){
final _that = this;
switch (_that) {
case _ChangelogVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String tag,  String date,  bool prerelease,  List<ChangelogGroup> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangelogVersion() when $default != null:
return $default(_that.version,_that.tag,_that.date,_that.prerelease,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String tag,  String date,  bool prerelease,  List<ChangelogGroup> groups)  $default,) {final _that = this;
switch (_that) {
case _ChangelogVersion():
return $default(_that.version,_that.tag,_that.date,_that.prerelease,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String tag,  String date,  bool prerelease,  List<ChangelogGroup> groups)?  $default,) {final _that = this;
switch (_that) {
case _ChangelogVersion() when $default != null:
return $default(_that.version,_that.tag,_that.date,_that.prerelease,_that.groups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChangelogVersion implements ChangelogVersion {
  const _ChangelogVersion({required this.version, required this.tag, this.date = '', this.prerelease = false, final  List<ChangelogGroup> groups = const []}): _groups = groups;
  factory _ChangelogVersion.fromJson(Map<String, dynamic> json) => _$ChangelogVersionFromJson(json);

@override final  String version;
@override final  String tag;
@override@JsonKey() final  String date;
@override@JsonKey() final  bool prerelease;
 final  List<ChangelogGroup> _groups;
@override@JsonKey() List<ChangelogGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of ChangelogVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogVersionCopyWith<_ChangelogVersion> get copyWith => __$ChangelogVersionCopyWithImpl<_ChangelogVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogVersionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangelogVersion&&(identical(other.version, version) || other.version == version)&&(identical(other.tag, tag) || other.tag == tag)&&(identical(other.date, date) || other.date == date)&&(identical(other.prerelease, prerelease) || other.prerelease == prerelease)&&const DeepCollectionEquality().equals(other._groups, _groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,tag,date,prerelease,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'ChangelogVersion(version: $version, tag: $tag, date: $date, prerelease: $prerelease, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$ChangelogVersionCopyWith<$Res> implements $ChangelogVersionCopyWith<$Res> {
  factory _$ChangelogVersionCopyWith(_ChangelogVersion value, $Res Function(_ChangelogVersion) _then) = __$ChangelogVersionCopyWithImpl;
@override @useResult
$Res call({
 String version, String tag, String date, bool prerelease, List<ChangelogGroup> groups
});




}
/// @nodoc
class __$ChangelogVersionCopyWithImpl<$Res>
    implements _$ChangelogVersionCopyWith<$Res> {
  __$ChangelogVersionCopyWithImpl(this._self, this._then);

  final _ChangelogVersion _self;
  final $Res Function(_ChangelogVersion) _then;

/// Create a copy of ChangelogVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? tag = null,Object? date = null,Object? prerelease = null,Object? groups = null,}) {
  return _then(_ChangelogVersion(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,tag: null == tag ? _self.tag : tag // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,prerelease: null == prerelease ? _self.prerelease : prerelease // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<ChangelogGroup>,
  ));
}


}


/// @nodoc
mixin _$Changelog {

 int get schemaVersion; List<ChangelogVersion> get versions;
/// Create a copy of Changelog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangelogCopyWith<Changelog> get copyWith => _$ChangelogCopyWithImpl<Changelog>(this as Changelog, _$identity);

  /// Serializes this Changelog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Changelog&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other.versions, versions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(versions));

@override
String toString() {
  return 'Changelog(schemaVersion: $schemaVersion, versions: $versions)';
}


}

/// @nodoc
abstract mixin class $ChangelogCopyWith<$Res>  {
  factory $ChangelogCopyWith(Changelog value, $Res Function(Changelog) _then) = _$ChangelogCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, List<ChangelogVersion> versions
});




}
/// @nodoc
class _$ChangelogCopyWithImpl<$Res>
    implements $ChangelogCopyWith<$Res> {
  _$ChangelogCopyWithImpl(this._self, this._then);

  final Changelog _self;
  final $Res Function(Changelog) _then;

/// Create a copy of Changelog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? versions = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,versions: null == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as List<ChangelogVersion>,
  ));
}

}


/// Adds pattern-matching-related methods to [Changelog].
extension ChangelogPatterns on Changelog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Changelog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Changelog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Changelog value)  $default,){
final _that = this;
switch (_that) {
case _Changelog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Changelog value)?  $default,){
final _that = this;
switch (_that) {
case _Changelog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  List<ChangelogVersion> versions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Changelog() when $default != null:
return $default(_that.schemaVersion,_that.versions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  List<ChangelogVersion> versions)  $default,) {final _that = this;
switch (_that) {
case _Changelog():
return $default(_that.schemaVersion,_that.versions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  List<ChangelogVersion> versions)?  $default,) {final _that = this;
switch (_that) {
case _Changelog() when $default != null:
return $default(_that.schemaVersion,_that.versions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Changelog implements Changelog {
  const _Changelog({this.schemaVersion = 0, final  List<ChangelogVersion> versions = const []}): _versions = versions;
  factory _Changelog.fromJson(Map<String, dynamic> json) => _$ChangelogFromJson(json);

@override@JsonKey() final  int schemaVersion;
 final  List<ChangelogVersion> _versions;
@override@JsonKey() List<ChangelogVersion> get versions {
  if (_versions is EqualUnmodifiableListView) return _versions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_versions);
}


/// Create a copy of Changelog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangelogCopyWith<_Changelog> get copyWith => __$ChangelogCopyWithImpl<_Changelog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChangelogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Changelog&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other._versions, _versions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(_versions));

@override
String toString() {
  return 'Changelog(schemaVersion: $schemaVersion, versions: $versions)';
}


}

/// @nodoc
abstract mixin class _$ChangelogCopyWith<$Res> implements $ChangelogCopyWith<$Res> {
  factory _$ChangelogCopyWith(_Changelog value, $Res Function(_Changelog) _then) = __$ChangelogCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, List<ChangelogVersion> versions
});




}
/// @nodoc
class __$ChangelogCopyWithImpl<$Res>
    implements _$ChangelogCopyWith<$Res> {
  __$ChangelogCopyWithImpl(this._self, this._then);

  final _Changelog _self;
  final $Res Function(_Changelog) _then;

/// Create a copy of Changelog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? versions = null,}) {
  return _then(_Changelog(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,versions: null == versions ? _self._versions : versions // ignore: cast_nullable_to_non_nullable
as List<ChangelogVersion>,
  ));
}


}

// dart format on

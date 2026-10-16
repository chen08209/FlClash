// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IconButtonData implements DiagnosticableTreeMixin {

 Glyph get glyph; VoidCallback? get onPressed; String? get tooltip; bool get isLoading;/// Non-null makes the button a toggle that shows this state.
 bool? get isSelected;
/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IconButtonDataCopyWith<IconButtonData> get copyWith => _$IconButtonDataCopyWithImpl<IconButtonData>(this as IconButtonData, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as IconButtonData;
  properties
    ..add(DiagnosticsProperty('type', 'IconButtonData'))
    ..add(DiagnosticsProperty('glyph', _this.glyph))..add(DiagnosticsProperty('onPressed', _this.onPressed))..add(DiagnosticsProperty('tooltip', _this.tooltip))..add(DiagnosticsProperty('isLoading', _this.isLoading))..add(DiagnosticsProperty('isSelected', _this.isSelected));
}

@override
bool operator ==(Object other) {
  final _this = this as IconButtonData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IconButtonData&&(identical(other.glyph, _this.glyph) || other.glyph == _this.glyph)&&(identical(other.onPressed, _this.onPressed) || other.onPressed == _this.onPressed)&&(identical(other.tooltip, _this.tooltip) || other.tooltip == _this.tooltip)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isSelected, _this.isSelected) || other.isSelected == _this.isSelected));
}


@override
int get hashCode {
  final _this = this as IconButtonData;
  return Object.hash(runtimeType,_this.glyph,_this.onPressed,_this.tooltip,_this.isLoading,_this.isSelected);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as IconButtonData;
  return 'IconButtonData(glyph: ${_this.glyph}, onPressed: ${_this.onPressed}, tooltip: ${_this.tooltip}, isLoading: ${_this.isLoading}, isSelected: ${_this.isSelected})';
}


}

/// @nodoc
abstract mixin class $IconButtonDataCopyWith<$Res>  {
  factory $IconButtonDataCopyWith(IconButtonData value, $Res Function(IconButtonData) _then) = _$IconButtonDataCopyWithImpl;
@useResult
$Res call({
 Glyph glyph, VoidCallback? onPressed, String? tooltip, bool isLoading, bool? isSelected
});




}
/// @nodoc
class _$IconButtonDataCopyWithImpl<$Res>
    implements $IconButtonDataCopyWith<$Res> {
  _$IconButtonDataCopyWithImpl(this._self, this._then);

  final IconButtonData _self;
  final $Res Function(IconButtonData) _then;

/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? glyph = null,Object? onPressed = freezed,Object? tooltip = freezed,Object? isLoading = null,Object? isSelected = freezed,}) {
  return _then(IconButtonData(
glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as Glyph,onPressed: freezed == onPressed ? _self.onPressed : onPressed // ignore: cast_nullable_to_non_nullable
as VoidCallback?,tooltip: freezed == tooltip ? _self.tooltip : tooltip // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSelected: freezed == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [IconButtonData].
extension IconButtonDataPatterns on IconButtonData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IconButtonData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IconButtonData value)  $default,){
final _that = this;
switch (_that) {
case _IconButtonData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IconButtonData value)?  $default,){
final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Glyph glyph,  VoidCallback? onPressed,  String? tooltip,  bool isLoading,  bool? isSelected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
return $default(_that.glyph,_that.onPressed,_that.tooltip,_that.isLoading,_that.isSelected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Glyph glyph,  VoidCallback? onPressed,  String? tooltip,  bool isLoading,  bool? isSelected)  $default,) {final _that = this;
switch (_that) {
case _IconButtonData():
return $default(_that.glyph,_that.onPressed,_that.tooltip,_that.isLoading,_that.isSelected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Glyph glyph,  VoidCallback? onPressed,  String? tooltip,  bool isLoading,  bool? isSelected)?  $default,) {final _that = this;
switch (_that) {
case _IconButtonData() when $default != null:
return $default(_that.glyph,_that.onPressed,_that.tooltip,_that.isLoading,_that.isSelected);case _:
  return null;

}
}

}

/// @nodoc


class _IconButtonData with DiagnosticableTreeMixin implements IconButtonData {
  const _IconButtonData({required this.glyph, required this.onPressed, this.tooltip, this.isLoading = false, this.isSelected});
  

@override final  Glyph glyph;
@override final  VoidCallback? onPressed;
@override final  String? tooltip;
@override@JsonKey() final  bool isLoading;
/// Non-null makes the button a toggle that shows this state.
@override final  bool? isSelected;

/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IconButtonDataCopyWith<_IconButtonData> get copyWith => __$IconButtonDataCopyWithImpl<_IconButtonData>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'IconButtonData'))
    ..add(DiagnosticsProperty('glyph', glyph))..add(DiagnosticsProperty('onPressed', onPressed))..add(DiagnosticsProperty('tooltip', tooltip))..add(DiagnosticsProperty('isLoading', isLoading))..add(DiagnosticsProperty('isSelected', isSelected));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IconButtonData&&(identical(other.glyph, glyph) || other.glyph == glyph)&&(identical(other.onPressed, onPressed) || other.onPressed == onPressed)&&(identical(other.tooltip, tooltip) || other.tooltip == tooltip)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSelected, isSelected) || other.isSelected == isSelected));
}


@override
int get hashCode {
    return Object.hash(runtimeType,glyph,onPressed,tooltip,isLoading,isSelected);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'IconButtonData(glyph: $glyph, onPressed: $onPressed, tooltip: $tooltip, isLoading: $isLoading, isSelected: $isSelected)';
}


}

/// @nodoc
abstract mixin class _$IconButtonDataCopyWith<$Res> implements $IconButtonDataCopyWith<$Res> {
  factory _$IconButtonDataCopyWith(_IconButtonData value, $Res Function(_IconButtonData) _then) = __$IconButtonDataCopyWithImpl;
@override @useResult
$Res call({
 Glyph glyph, VoidCallback? onPressed, String? tooltip, bool isLoading, bool? isSelected
});




}
/// @nodoc
class __$IconButtonDataCopyWithImpl<$Res>
    implements _$IconButtonDataCopyWith<$Res> {
  __$IconButtonDataCopyWithImpl(this._self, this._then);

  final _IconButtonData _self;
  final $Res Function(_IconButtonData) _then;

/// Create a copy of IconButtonData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? glyph = null,Object? onPressed = freezed,Object? tooltip = freezed,Object? isLoading = null,Object? isSelected = freezed,}) {
  return _then(_IconButtonData(
glyph: null == glyph ? _self.glyph : glyph // ignore: cast_nullable_to_non_nullable
as Glyph,onPressed: freezed == onPressed ? _self.onPressed : onPressed // ignore: cast_nullable_to_non_nullable
as VoidCallback?,tooltip: freezed == tooltip ? _self.tooltip : tooltip // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSelected: freezed == isSelected ? _self.isSelected : isSelected // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$AppBarState implements DiagnosticableTreeMixin {

 AppBarSearchState? get searchState;
/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarStateCopyWith<AppBarState> get copyWith => _$AppBarStateCopyWithImpl<AppBarState>(this as AppBarState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as AppBarState;
  properties
    ..add(DiagnosticsProperty('type', 'AppBarState'))
    ..add(DiagnosticsProperty('searchState', _this.searchState));
}

@override
bool operator ==(Object other) {
  final _this = this as AppBarState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarState&&(identical(other.searchState, _this.searchState) || other.searchState == _this.searchState));
}


@override
int get hashCode {
  final _this = this as AppBarState;
  return Object.hash(runtimeType,_this.searchState);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as AppBarState;
  return 'AppBarState(searchState: ${_this.searchState})';
}


}

/// @nodoc
abstract mixin class $AppBarStateCopyWith<$Res>  {
  factory $AppBarStateCopyWith(AppBarState value, $Res Function(AppBarState) _then) = _$AppBarStateCopyWithImpl;
@useResult
$Res call({
 AppBarSearchState? searchState
});


$AppBarSearchStateCopyWith<$Res>? get searchState;

}
/// @nodoc
class _$AppBarStateCopyWithImpl<$Res>
    implements $AppBarStateCopyWith<$Res> {
  _$AppBarStateCopyWithImpl(this._self, this._then);

  final AppBarState _self;
  final $Res Function(AppBarState) _then;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchState = freezed,}) {
  return _then(AppBarState(
searchState: freezed == searchState ? _self.searchState : searchState // ignore: cast_nullable_to_non_nullable
as AppBarSearchState?,
  ));
}
/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<$Res>? get searchState {
    if (_self.searchState == null) {
    return null;
  }

  return $AppBarSearchStateCopyWith<$Res>(_self.searchState!, (value) {
    return _then(_self.copyWith(searchState: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppBarState].
extension AppBarStatePatterns on AppBarState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBarState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBarState value)  $default,){
final _that = this;
switch (_that) {
case _AppBarState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBarState value)?  $default,){
final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppBarSearchState? searchState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
return $default(_that.searchState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppBarSearchState? searchState)  $default,) {final _that = this;
switch (_that) {
case _AppBarState():
return $default(_that.searchState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppBarSearchState? searchState)?  $default,) {final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
return $default(_that.searchState);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarState with DiagnosticableTreeMixin implements AppBarState {
  const _AppBarState({this.searchState});
  

@override final  AppBarSearchState? searchState;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarStateCopyWith<_AppBarState> get copyWith => __$AppBarStateCopyWithImpl<_AppBarState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'AppBarState'))
    ..add(DiagnosticsProperty('searchState', searchState));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarState&&(identical(other.searchState, searchState) || other.searchState == searchState));
}


@override
int get hashCode {
    return Object.hash(runtimeType,searchState);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'AppBarState(searchState: $searchState)';
}


}

/// @nodoc
abstract mixin class _$AppBarStateCopyWith<$Res> implements $AppBarStateCopyWith<$Res> {
  factory _$AppBarStateCopyWith(_AppBarState value, $Res Function(_AppBarState) _then) = __$AppBarStateCopyWithImpl;
@override @useResult
$Res call({
 AppBarSearchState? searchState
});


@override $AppBarSearchStateCopyWith<$Res>? get searchState;

}
/// @nodoc
class __$AppBarStateCopyWithImpl<$Res>
    implements _$AppBarStateCopyWith<$Res> {
  __$AppBarStateCopyWithImpl(this._self, this._then);

  final _AppBarState _self;
  final $Res Function(_AppBarState) _then;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchState = freezed,}) {
  return _then(_AppBarState(
searchState: freezed == searchState ? _self.searchState : searchState // ignore: cast_nullable_to_non_nullable
as AppBarSearchState?,
  ));
}

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<$Res>? get searchState {
    if (_self.searchState == null) {
    return null;
  }

  return $AppBarSearchStateCopyWith<$Res>(_self.searchState!, (value) {
    return _then(_self.copyWith(searchState: value));
  });
}
}

/// @nodoc
mixin _$AppBarSearchState implements DiagnosticableTreeMixin {

 dynamic Function(String) get onSearch; String? get query;
/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<AppBarSearchState> get copyWith => _$AppBarSearchStateCopyWithImpl<AppBarSearchState>(this as AppBarSearchState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  final _this = this as AppBarSearchState;
  properties
    ..add(DiagnosticsProperty('type', 'AppBarSearchState'))
    ..add(DiagnosticsProperty('onSearch', _this.onSearch))..add(DiagnosticsProperty('query', _this.query));
}

@override
bool operator ==(Object other) {
  final _this = this as AppBarSearchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarSearchState&&(identical(other.onSearch, _this.onSearch) || other.onSearch == _this.onSearch)&&(identical(other.query, _this.query) || other.query == _this.query));
}


@override
int get hashCode {
  final _this = this as AppBarSearchState;
  return Object.hash(runtimeType,_this.onSearch,_this.query);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  final _this = this as AppBarSearchState;
  return 'AppBarSearchState(onSearch: ${_this.onSearch}, query: ${_this.query})';
}


}

/// @nodoc
abstract mixin class $AppBarSearchStateCopyWith<$Res>  {
  factory $AppBarSearchStateCopyWith(AppBarSearchState value, $Res Function(AppBarSearchState) _then) = _$AppBarSearchStateCopyWithImpl;
@useResult
$Res call({
 dynamic Function(String) onSearch, String? query
});




}
/// @nodoc
class _$AppBarSearchStateCopyWithImpl<$Res>
    implements $AppBarSearchStateCopyWith<$Res> {
  _$AppBarSearchStateCopyWithImpl(this._self, this._then);

  final AppBarSearchState _self;
  final $Res Function(AppBarSearchState) _then;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onSearch = null,Object? query = freezed,}) {
  return _then(AppBarSearchState(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as dynamic Function(String),query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppBarSearchState].
extension AppBarSearchStatePatterns on AppBarSearchState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBarSearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBarSearchState value)  $default,){
final _that = this;
switch (_that) {
case _AppBarSearchState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBarSearchState value)?  $default,){
final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( dynamic Function(String) onSearch,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( dynamic Function(String) onSearch,  String? query)  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState():
return $default(_that.onSearch,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( dynamic Function(String) onSearch,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarSearchState with DiagnosticableTreeMixin implements AppBarSearchState {
  const _AppBarSearchState({required this.onSearch, this.query = null});
  

@override final  dynamic Function(String) onSearch;
@override@JsonKey() final  String? query;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarSearchStateCopyWith<_AppBarSearchState> get copyWith => __$AppBarSearchStateCopyWithImpl<_AppBarSearchState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
    ..add(DiagnosticsProperty('type', 'AppBarSearchState'))
    ..add(DiagnosticsProperty('onSearch', onSearch))..add(DiagnosticsProperty('query', query));
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,onSearch,query);
}

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
    return 'AppBarSearchState(onSearch: $onSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class _$AppBarSearchStateCopyWith<$Res> implements $AppBarSearchStateCopyWith<$Res> {
  factory _$AppBarSearchStateCopyWith(_AppBarSearchState value, $Res Function(_AppBarSearchState) _then) = __$AppBarSearchStateCopyWithImpl;
@override @useResult
$Res call({
 dynamic Function(String) onSearch, String? query
});




}
/// @nodoc
class __$AppBarSearchStateCopyWithImpl<$Res>
    implements _$AppBarSearchStateCopyWith<$Res> {
  __$AppBarSearchStateCopyWithImpl(this._self, this._then);

  final _AppBarSearchState _self;
  final $Res Function(_AppBarSearchState) _then;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onSearch = null,Object? query = freezed,}) {
  return _then(_AppBarSearchState(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as dynamic Function(String),query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

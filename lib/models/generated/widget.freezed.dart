// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../widget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivateState {

 bool get active;
/// Create a copy of ActivateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivateStateCopyWith<ActivateState> get copyWith => _$ActivateStateCopyWithImpl<ActivateState>(this as ActivateState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivateState&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,active);

@override
String toString() {
  return 'ActivateState(active: $active)';
}


}

/// @nodoc
abstract mixin class $ActivateStateCopyWith<$Res>  {
  factory $ActivateStateCopyWith(ActivateState value, $Res Function(ActivateState) _then) = _$ActivateStateCopyWithImpl;
@useResult
$Res call({
 bool active
});




}
/// @nodoc
class _$ActivateStateCopyWithImpl<$Res>
    implements $ActivateStateCopyWith<$Res> {
  _$ActivateStateCopyWithImpl(this._self, this._then);

  final ActivateState _self;
  final $Res Function(ActivateState) _then;

/// Create a copy of ActivateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? active = null,}) {
  return _then(_self.copyWith(
active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ActivateState].
extension ActivateStatePatterns on ActivateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivateState value)  $default,){
final _that = this;
switch (_that) {
case _ActivateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivateState value)?  $default,){
final _that = this;
switch (_that) {
case _ActivateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivateState() when $default != null:
return $default(_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool active)  $default,) {final _that = this;
switch (_that) {
case _ActivateState():
return $default(_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool active)?  $default,) {final _that = this;
switch (_that) {
case _ActivateState() when $default != null:
return $default(_that.active);case _:
  return null;

}
}

}

/// @nodoc


class _ActivateState implements ActivateState {
  const _ActivateState({required this.active});
  

@override final  bool active;

/// Create a copy of ActivateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivateStateCopyWith<_ActivateState> get copyWith => __$ActivateStateCopyWithImpl<_ActivateState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivateState&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,active);

@override
String toString() {
  return 'ActivateState(active: $active)';
}


}

/// @nodoc
abstract mixin class _$ActivateStateCopyWith<$Res> implements $ActivateStateCopyWith<$Res> {
  factory _$ActivateStateCopyWith(_ActivateState value, $Res Function(_ActivateState) _then) = __$ActivateStateCopyWithImpl;
@override @useResult
$Res call({
 bool active
});




}
/// @nodoc
class __$ActivateStateCopyWithImpl<$Res>
    implements _$ActivateStateCopyWith<$Res> {
  __$ActivateStateCopyWithImpl(this._self, this._then);

  final _ActivateState _self;
  final $Res Function(_ActivateState) _then;

/// Create a copy of ActivateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? active = null,}) {
  return _then(_ActivateState(
active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$CommonMessage {

 String get id; String get text; Duration get duration;
/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommonMessageCopyWith<CommonMessage> get copyWith => _$CommonMessageCopyWithImpl<CommonMessage>(this as CommonMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommonMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,duration);

@override
String toString() {
  return 'CommonMessage(id: $id, text: $text, duration: $duration)';
}


}

/// @nodoc
abstract mixin class $CommonMessageCopyWith<$Res>  {
  factory $CommonMessageCopyWith(CommonMessage value, $Res Function(CommonMessage) _then) = _$CommonMessageCopyWithImpl;
@useResult
$Res call({
 String id, String text, Duration duration
});




}
/// @nodoc
class _$CommonMessageCopyWithImpl<$Res>
    implements $CommonMessageCopyWith<$Res> {
  _$CommonMessageCopyWithImpl(this._self, this._then);

  final CommonMessage _self;
  final $Res Function(CommonMessage) _then;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? duration = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [CommonMessage].
extension CommonMessagePatterns on CommonMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommonMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommonMessage value)  $default,){
final _that = this;
switch (_that) {
case _CommonMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommonMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  Duration duration)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
return $default(_that.id,_that.text,_that.duration);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  Duration duration)  $default,) {final _that = this;
switch (_that) {
case _CommonMessage():
return $default(_that.id,_that.text,_that.duration);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  Duration duration)?  $default,) {final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
return $default(_that.id,_that.text,_that.duration);case _:
  return null;

}
}

}

/// @nodoc


class _CommonMessage implements CommonMessage {
  const _CommonMessage({required this.id, required this.text, this.duration = const Duration(seconds: 3)});
  

@override final  String id;
@override final  String text;
@override@JsonKey() final  Duration duration;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommonMessageCopyWith<_CommonMessage> get copyWith => __$CommonMessageCopyWithImpl<_CommonMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommonMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,duration);

@override
String toString() {
  return 'CommonMessage(id: $id, text: $text, duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$CommonMessageCopyWith<$Res> implements $CommonMessageCopyWith<$Res> {
  factory _$CommonMessageCopyWith(_CommonMessage value, $Res Function(_CommonMessage) _then) = __$CommonMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, Duration duration
});




}
/// @nodoc
class __$CommonMessageCopyWithImpl<$Res>
    implements _$CommonMessageCopyWith<$Res> {
  __$CommonMessageCopyWithImpl(this._self, this._then);

  final _CommonMessage _self;
  final $Res Function(_CommonMessage) _then;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? duration = null,}) {
  return _then(_CommonMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc
mixin _$AppBarState {

 List<Widget> get actions; AppBarSearchState? get searchState; AppBarEditState? get editState;
/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarStateCopyWith<AppBarState> get copyWith => _$AppBarStateCopyWithImpl<AppBarState>(this as AppBarState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarState&&const DeepCollectionEquality().equals(other.actions, actions)&&(identical(other.searchState, searchState) || other.searchState == searchState)&&(identical(other.editState, editState) || other.editState == editState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(actions),searchState,editState);

@override
String toString() {
  return 'AppBarState(actions: $actions, searchState: $searchState, editState: $editState)';
}


}

/// @nodoc
abstract mixin class $AppBarStateCopyWith<$Res>  {
  factory $AppBarStateCopyWith(AppBarState value, $Res Function(AppBarState) _then) = _$AppBarStateCopyWithImpl;
@useResult
$Res call({
 List<Widget> actions, AppBarSearchState? searchState, AppBarEditState? editState
});


$AppBarSearchStateCopyWith<$Res>? get searchState;$AppBarEditStateCopyWith<$Res>? get editState;

}
/// @nodoc
class _$AppBarStateCopyWithImpl<$Res>
    implements $AppBarStateCopyWith<$Res> {
  _$AppBarStateCopyWithImpl(this._self, this._then);

  final AppBarState _self;
  final $Res Function(AppBarState) _then;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actions = null,Object? searchState = freezed,Object? editState = freezed,}) {
  return _then(_self.copyWith(
actions: null == actions ? _self.actions : actions // ignore: cast_nullable_to_non_nullable
as List<Widget>,searchState: freezed == searchState ? _self.searchState : searchState // ignore: cast_nullable_to_non_nullable
as AppBarSearchState?,editState: freezed == editState ? _self.editState : editState // ignore: cast_nullable_to_non_nullable
as AppBarEditState?,
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
}/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarEditStateCopyWith<$Res>? get editState {
    if (_self.editState == null) {
    return null;
  }

  return $AppBarEditStateCopyWith<$Res>(_self.editState!, (value) {
    return _then(_self.copyWith(editState: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Widget> actions,  AppBarSearchState? searchState,  AppBarEditState? editState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
return $default(_that.actions,_that.searchState,_that.editState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Widget> actions,  AppBarSearchState? searchState,  AppBarEditState? editState)  $default,) {final _that = this;
switch (_that) {
case _AppBarState():
return $default(_that.actions,_that.searchState,_that.editState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Widget> actions,  AppBarSearchState? searchState,  AppBarEditState? editState)?  $default,) {final _that = this;
switch (_that) {
case _AppBarState() when $default != null:
return $default(_that.actions,_that.searchState,_that.editState);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarState implements AppBarState {
  const _AppBarState({final  List<Widget> actions = const [], this.searchState, this.editState}): _actions = actions;
  

 final  List<Widget> _actions;
@override@JsonKey() List<Widget> get actions {
  if (_actions is EqualUnmodifiableListView) return _actions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actions);
}

@override final  AppBarSearchState? searchState;
@override final  AppBarEditState? editState;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarStateCopyWith<_AppBarState> get copyWith => __$AppBarStateCopyWithImpl<_AppBarState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarState&&const DeepCollectionEquality().equals(other._actions, _actions)&&(identical(other.searchState, searchState) || other.searchState == searchState)&&(identical(other.editState, editState) || other.editState == editState));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_actions),searchState,editState);

@override
String toString() {
  return 'AppBarState(actions: $actions, searchState: $searchState, editState: $editState)';
}


}

/// @nodoc
abstract mixin class _$AppBarStateCopyWith<$Res> implements $AppBarStateCopyWith<$Res> {
  factory _$AppBarStateCopyWith(_AppBarState value, $Res Function(_AppBarState) _then) = __$AppBarStateCopyWithImpl;
@override @useResult
$Res call({
 List<Widget> actions, AppBarSearchState? searchState, AppBarEditState? editState
});


@override $AppBarSearchStateCopyWith<$Res>? get searchState;@override $AppBarEditStateCopyWith<$Res>? get editState;

}
/// @nodoc
class __$AppBarStateCopyWithImpl<$Res>
    implements _$AppBarStateCopyWith<$Res> {
  __$AppBarStateCopyWithImpl(this._self, this._then);

  final _AppBarState _self;
  final $Res Function(_AppBarState) _then;

/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actions = null,Object? searchState = freezed,Object? editState = freezed,}) {
  return _then(_AppBarState(
actions: null == actions ? _self._actions : actions // ignore: cast_nullable_to_non_nullable
as List<Widget>,searchState: freezed == searchState ? _self.searchState : searchState // ignore: cast_nullable_to_non_nullable
as AppBarSearchState?,editState: freezed == editState ? _self.editState : editState // ignore: cast_nullable_to_non_nullable
as AppBarEditState?,
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
}/// Create a copy of AppBarState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppBarEditStateCopyWith<$Res>? get editState {
    if (_self.editState == null) {
    return null;
  }

  return $AppBarEditStateCopyWith<$Res>(_self.editState!, (value) {
    return _then(_self.copyWith(editState: value));
  });
}
}

/// @nodoc
mixin _$AppBarSearchState {

  Function(String) get onSearch; String? get query;
/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<AppBarSearchState> get copyWith => _$AppBarSearchStateCopyWithImpl<AppBarSearchState>(this as AppBarSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,onSearch,query);

@override
String toString() {
  return 'AppBarSearchState(onSearch: $onSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class $AppBarSearchStateCopyWith<$Res>  {
  factory $AppBarSearchStateCopyWith(AppBarSearchState value, $Res Function(AppBarSearchState) _then) = _$AppBarSearchStateCopyWithImpl;
@useResult
$Res call({
  Function(String) onSearch, String? query
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
  return _then(_self.copyWith(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as  Function(String),query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(  Function(String) onSearch,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(  Function(String) onSearch,  String? query)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(  Function(String) onSearch,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarSearchState implements AppBarSearchState {
  const _AppBarSearchState({required this.onSearch, this.query = null});
  

@override final   Function(String) onSearch;
@override@JsonKey() final  String? query;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarSearchStateCopyWith<_AppBarSearchState> get copyWith => __$AppBarSearchStateCopyWithImpl<_AppBarSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,onSearch,query);

@override
String toString() {
  return 'AppBarSearchState(onSearch: $onSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class _$AppBarSearchStateCopyWith<$Res> implements $AppBarSearchStateCopyWith<$Res> {
  factory _$AppBarSearchStateCopyWith(_AppBarSearchState value, $Res Function(_AppBarSearchState) _then) = __$AppBarSearchStateCopyWithImpl;
@override @useResult
$Res call({
  Function(String) onSearch, String? query
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
as  Function(String),query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AppBarEditState {

 int get editCount;  Function() get onExit;
/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarEditStateCopyWith<AppBarEditState> get copyWith => _$AppBarEditStateCopyWithImpl<AppBarEditState>(this as AppBarEditState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarEditState&&(identical(other.editCount, editCount) || other.editCount == editCount)&&(identical(other.onExit, onExit) || other.onExit == onExit));
}


@override
int get hashCode => Object.hash(runtimeType,editCount,onExit);

@override
String toString() {
  return 'AppBarEditState(editCount: $editCount, onExit: $onExit)';
}


}

/// @nodoc
abstract mixin class $AppBarEditStateCopyWith<$Res>  {
  factory $AppBarEditStateCopyWith(AppBarEditState value, $Res Function(AppBarEditState) _then) = _$AppBarEditStateCopyWithImpl;
@useResult
$Res call({
 int editCount,  Function() onExit
});




}
/// @nodoc
class _$AppBarEditStateCopyWithImpl<$Res>
    implements $AppBarEditStateCopyWith<$Res> {
  _$AppBarEditStateCopyWithImpl(this._self, this._then);

  final AppBarEditState _self;
  final $Res Function(AppBarEditState) _then;

/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? editCount = null,Object? onExit = null,}) {
  return _then(_self.copyWith(
editCount: null == editCount ? _self.editCount : editCount // ignore: cast_nullable_to_non_nullable
as int,onExit: null == onExit ? _self.onExit : onExit // ignore: cast_nullable_to_non_nullable
as  Function(),
  ));
}

}


/// Adds pattern-matching-related methods to [AppBarEditState].
extension AppBarEditStatePatterns on AppBarEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppBarEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppBarEditState value)  $default,){
final _that = this;
switch (_that) {
case _AppBarEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppBarEditState value)?  $default,){
final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int editCount,   Function() onExit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
return $default(_that.editCount,_that.onExit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int editCount,   Function() onExit)  $default,) {final _that = this;
switch (_that) {
case _AppBarEditState():
return $default(_that.editCount,_that.onExit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int editCount,   Function() onExit)?  $default,) {final _that = this;
switch (_that) {
case _AppBarEditState() when $default != null:
return $default(_that.editCount,_that.onExit);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarEditState implements AppBarEditState {
  const _AppBarEditState({this.editCount = 0, required this.onExit});
  

@override@JsonKey() final  int editCount;
@override final   Function() onExit;

/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarEditStateCopyWith<_AppBarEditState> get copyWith => __$AppBarEditStateCopyWithImpl<_AppBarEditState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarEditState&&(identical(other.editCount, editCount) || other.editCount == editCount)&&(identical(other.onExit, onExit) || other.onExit == onExit));
}


@override
int get hashCode => Object.hash(runtimeType,editCount,onExit);

@override
String toString() {
  return 'AppBarEditState(editCount: $editCount, onExit: $onExit)';
}


}

/// @nodoc
abstract mixin class _$AppBarEditStateCopyWith<$Res> implements $AppBarEditStateCopyWith<$Res> {
  factory _$AppBarEditStateCopyWith(_AppBarEditState value, $Res Function(_AppBarEditState) _then) = __$AppBarEditStateCopyWithImpl;
@override @useResult
$Res call({
 int editCount,  Function() onExit
});




}
/// @nodoc
class __$AppBarEditStateCopyWithImpl<$Res>
    implements _$AppBarEditStateCopyWith<$Res> {
  __$AppBarEditStateCopyWithImpl(this._self, this._then);

  final _AppBarEditState _self;
  final $Res Function(_AppBarEditState) _then;

/// Create a copy of AppBarEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? editCount = null,Object? onExit = null,}) {
  return _then(_AppBarEditState(
editCount: null == editCount ? _self.editCount : editCount // ignore: cast_nullable_to_non_nullable
as int,onExit: null == onExit ? _self.onExit : onExit // ignore: cast_nullable_to_non_nullable
as  Function(),
  ));
}


}

// dart format on

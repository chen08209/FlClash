// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SelectValue<T> {

 T get value;
/// Create a copy of SelectValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectValueCopyWith<T, SelectValue<T>> get copyWith => _$SelectValueCopyWithImpl<T, SelectValue<T>>(this as SelectValue<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectValue<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'SelectValue<$T>(value: $value)';
}


}

/// @nodoc
abstract mixin class $SelectValueCopyWith<T,$Res>  {
  factory $SelectValueCopyWith(SelectValue<T> value, $Res Function(SelectValue<T>) _then) = _$SelectValueCopyWithImpl;
@useResult
$Res call({
 T value
});




}
/// @nodoc
class _$SelectValueCopyWithImpl<T,$Res>
    implements $SelectValueCopyWith<T, $Res> {
  _$SelectValueCopyWithImpl(this._self, this._then);

  final SelectValue<T> _self;
  final $Res Function(SelectValue<T>) _then;

/// Create a copy of SelectValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = freezed,}) {
  return _then(_self.copyWith(
value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectValue].
extension SelectValuePatterns<T> on SelectValue<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectValue<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectValue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectValue<T> value)  $default,){
final _that = this;
switch (_that) {
case _SelectValue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectValue<T> value)?  $default,){
final _that = this;
switch (_that) {
case _SelectValue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectValue() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T value)  $default,) {final _that = this;
switch (_that) {
case _SelectValue():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T value)?  $default,) {final _that = this;
switch (_that) {
case _SelectValue() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _SelectValue<T> implements SelectValue<T> {
  const _SelectValue(this.value);
  

@override final  T value;

/// Create a copy of SelectValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectValueCopyWith<T, _SelectValue<T>> get copyWith => __$SelectValueCopyWithImpl<T, _SelectValue<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectValue<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'SelectValue<$T>(value: $value)';
}


}

/// @nodoc
abstract mixin class _$SelectValueCopyWith<T,$Res> implements $SelectValueCopyWith<T, $Res> {
  factory _$SelectValueCopyWith(_SelectValue<T> value, $Res Function(_SelectValue<T>) _then) = __$SelectValueCopyWithImpl;
@override @useResult
$Res call({
 T value
});




}
/// @nodoc
class __$SelectValueCopyWithImpl<T,$Res>
    implements _$SelectValueCopyWith<T, $Res> {
  __$SelectValueCopyWithImpl(this._self, this._then);

  final _SelectValue<T> _self;
  final $Res Function(_SelectValue<T>) _then;

/// Create a copy of SelectValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(_SelectValue<T>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

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
mixin _$InitState {

 Config get config; List<Profile> get profiles;
/// Create a copy of InitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InitStateCopyWith<InitState> get copyWith => _$InitStateCopyWithImpl<InitState>(this as InitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitState&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other.profiles, profiles));
}


@override
int get hashCode => Object.hash(runtimeType,config,const DeepCollectionEquality().hash(profiles));

@override
String toString() {
  return 'InitState(config: $config, profiles: $profiles)';
}


}

/// @nodoc
abstract mixin class $InitStateCopyWith<$Res>  {
  factory $InitStateCopyWith(InitState value, $Res Function(InitState) _then) = _$InitStateCopyWithImpl;
@useResult
$Res call({
 Config config, List<Profile> profiles
});


$ConfigCopyWith<$Res> get config;

}
/// @nodoc
class _$InitStateCopyWithImpl<$Res>
    implements $InitStateCopyWith<$Res> {
  _$InitStateCopyWithImpl(this._self, this._then);

  final InitState _self;
  final $Res Function(InitState) _then;

/// Create a copy of InitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? config = null,Object? profiles = null,}) {
  return _then(_self.copyWith(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Config,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,
  ));
}
/// Create a copy of InitState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigCopyWith<$Res> get config {
  
  return $ConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [InitState].
extension InitStatePatterns on InitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InitState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InitState value)  $default,){
final _that = this;
switch (_that) {
case _InitState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InitState value)?  $default,){
final _that = this;
switch (_that) {
case _InitState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Config config,  List<Profile> profiles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitState() when $default != null:
return $default(_that.config,_that.profiles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Config config,  List<Profile> profiles)  $default,) {final _that = this;
switch (_that) {
case _InitState():
return $default(_that.config,_that.profiles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Config config,  List<Profile> profiles)?  $default,) {final _that = this;
switch (_that) {
case _InitState() when $default != null:
return $default(_that.config,_that.profiles);case _:
  return null;

}
}

}

/// @nodoc


class _InitState implements InitState {
  const _InitState({required this.config, required final  List<Profile> profiles}): _profiles = profiles;
  

@override final  Config config;
 final  List<Profile> _profiles;
@override List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}


/// Create a copy of InitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitStateCopyWith<_InitState> get copyWith => __$InitStateCopyWithImpl<_InitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitState&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other._profiles, _profiles));
}


@override
int get hashCode => Object.hash(runtimeType,config,const DeepCollectionEquality().hash(_profiles));

@override
String toString() {
  return 'InitState(config: $config, profiles: $profiles)';
}


}

/// @nodoc
abstract mixin class _$InitStateCopyWith<$Res> implements $InitStateCopyWith<$Res> {
  factory _$InitStateCopyWith(_InitState value, $Res Function(_InitState) _then) = __$InitStateCopyWithImpl;
@override @useResult
$Res call({
 Config config, List<Profile> profiles
});


@override $ConfigCopyWith<$Res> get config;

}
/// @nodoc
class __$InitStateCopyWithImpl<$Res>
    implements _$InitStateCopyWith<$Res> {
  __$InitStateCopyWithImpl(this._self, this._then);

  final _InitState _self;
  final $Res Function(_InitState) _then;

/// Create a copy of InitState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? config = null,Object? profiles = null,}) {
  return _then(_InitState(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Config,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,
  ));
}

/// Create a copy of InitState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigCopyWith<$Res> get config {
  
  return $ConfigCopyWith<$Res>(_self.config, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

/// @nodoc
mixin _$CommonMessage {

 String get id; String get text; MessageLevel get level; Duration get duration; MessageActionState? get actionState;
/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommonMessageCopyWith<CommonMessage> get copyWith => _$CommonMessageCopyWithImpl<CommonMessage>(this as CommonMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommonMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.level, level) || other.level == level)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.actionState, actionState) || other.actionState == actionState));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,level,duration,actionState);

@override
String toString() {
  return 'CommonMessage(id: $id, text: $text, level: $level, duration: $duration, actionState: $actionState)';
}


}

/// @nodoc
abstract mixin class $CommonMessageCopyWith<$Res>  {
  factory $CommonMessageCopyWith(CommonMessage value, $Res Function(CommonMessage) _then) = _$CommonMessageCopyWithImpl;
@useResult
$Res call({
 String id, String text, MessageLevel level, Duration duration, MessageActionState? actionState
});


$MessageActionStateCopyWith<$Res>? get actionState;

}
/// @nodoc
class _$CommonMessageCopyWithImpl<$Res>
    implements $CommonMessageCopyWith<$Res> {
  _$CommonMessageCopyWithImpl(this._self, this._then);

  final CommonMessage _self;
  final $Res Function(CommonMessage) _then;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? level = null,Object? duration = null,Object? actionState = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as MessageLevel,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,actionState: freezed == actionState ? _self.actionState : actionState // ignore: cast_nullable_to_non_nullable
as MessageActionState?,
  ));
}
/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageActionStateCopyWith<$Res>? get actionState {
    if (_self.actionState == null) {
    return null;
  }

  return $MessageActionStateCopyWith<$Res>(_self.actionState!, (value) {
    return _then(_self.copyWith(actionState: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  MessageLevel level,  Duration duration,  MessageActionState? actionState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
return $default(_that.id,_that.text,_that.level,_that.duration,_that.actionState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  MessageLevel level,  Duration duration,  MessageActionState? actionState)  $default,) {final _that = this;
switch (_that) {
case _CommonMessage():
return $default(_that.id,_that.text,_that.level,_that.duration,_that.actionState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  MessageLevel level,  Duration duration,  MessageActionState? actionState)?  $default,) {final _that = this;
switch (_that) {
case _CommonMessage() when $default != null:
return $default(_that.id,_that.text,_that.level,_that.duration,_that.actionState);case _:
  return null;

}
}

}

/// @nodoc


class _CommonMessage implements CommonMessage {
  const _CommonMessage({required this.id, required this.text, this.level = MessageLevel.info, this.duration = const Duration(seconds: 3), this.actionState});
  

@override final  String id;
@override final  String text;
@override@JsonKey() final  MessageLevel level;
@override@JsonKey() final  Duration duration;
@override final  MessageActionState? actionState;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommonMessageCopyWith<_CommonMessage> get copyWith => __$CommonMessageCopyWithImpl<_CommonMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommonMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.level, level) || other.level == level)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.actionState, actionState) || other.actionState == actionState));
}


@override
int get hashCode => Object.hash(runtimeType,id,text,level,duration,actionState);

@override
String toString() {
  return 'CommonMessage(id: $id, text: $text, level: $level, duration: $duration, actionState: $actionState)';
}


}

/// @nodoc
abstract mixin class _$CommonMessageCopyWith<$Res> implements $CommonMessageCopyWith<$Res> {
  factory _$CommonMessageCopyWith(_CommonMessage value, $Res Function(_CommonMessage) _then) = __$CommonMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, MessageLevel level, Duration duration, MessageActionState? actionState
});


@override $MessageActionStateCopyWith<$Res>? get actionState;

}
/// @nodoc
class __$CommonMessageCopyWithImpl<$Res>
    implements _$CommonMessageCopyWith<$Res> {
  __$CommonMessageCopyWithImpl(this._self, this._then);

  final _CommonMessage _self;
  final $Res Function(_CommonMessage) _then;

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? level = null,Object? duration = null,Object? actionState = freezed,}) {
  return _then(_CommonMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as MessageLevel,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,actionState: freezed == actionState ? _self.actionState : actionState // ignore: cast_nullable_to_non_nullable
as MessageActionState?,
  ));
}

/// Create a copy of CommonMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageActionStateCopyWith<$Res>? get actionState {
    if (_self.actionState == null) {
    return null;
  }

  return $MessageActionStateCopyWith<$Res>(_self.actionState!, (value) {
    return _then(_self.copyWith(actionState: value));
  });
}
}

/// @nodoc
mixin _$MessageActionState {

 String get actionText; VoidCallback get action;
/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageActionStateCopyWith<MessageActionState> get copyWith => _$MessageActionStateCopyWithImpl<MessageActionState>(this as MessageActionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageActionState&&(identical(other.actionText, actionText) || other.actionText == actionText)&&(identical(other.action, action) || other.action == action));
}


@override
int get hashCode => Object.hash(runtimeType,actionText,action);

@override
String toString() {
  return 'MessageActionState(actionText: $actionText, action: $action)';
}


}

/// @nodoc
abstract mixin class $MessageActionStateCopyWith<$Res>  {
  factory $MessageActionStateCopyWith(MessageActionState value, $Res Function(MessageActionState) _then) = _$MessageActionStateCopyWithImpl;
@useResult
$Res call({
 String actionText, VoidCallback action
});




}
/// @nodoc
class _$MessageActionStateCopyWithImpl<$Res>
    implements $MessageActionStateCopyWith<$Res> {
  _$MessageActionStateCopyWithImpl(this._self, this._then);

  final MessageActionState _self;
  final $Res Function(MessageActionState) _then;

/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actionText = null,Object? action = null,}) {
  return _then(_self.copyWith(
actionText: null == actionText ? _self.actionText : actionText // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as VoidCallback,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageActionState].
extension MessageActionStatePatterns on MessageActionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageActionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageActionState value)  $default,){
final _that = this;
switch (_that) {
case _MessageActionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageActionState value)?  $default,){
final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actionText,  VoidCallback action)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
return $default(_that.actionText,_that.action);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actionText,  VoidCallback action)  $default,) {final _that = this;
switch (_that) {
case _MessageActionState():
return $default(_that.actionText,_that.action);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actionText,  VoidCallback action)?  $default,) {final _that = this;
switch (_that) {
case _MessageActionState() when $default != null:
return $default(_that.actionText,_that.action);case _:
  return null;

}
}

}

/// @nodoc


class _MessageActionState implements MessageActionState {
  const _MessageActionState({required this.actionText, required this.action});
  

@override final  String actionText;
@override final  VoidCallback action;

/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageActionStateCopyWith<_MessageActionState> get copyWith => __$MessageActionStateCopyWithImpl<_MessageActionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageActionState&&(identical(other.actionText, actionText) || other.actionText == actionText)&&(identical(other.action, action) || other.action == action));
}


@override
int get hashCode => Object.hash(runtimeType,actionText,action);

@override
String toString() {
  return 'MessageActionState(actionText: $actionText, action: $action)';
}


}

/// @nodoc
abstract mixin class _$MessageActionStateCopyWith<$Res> implements $MessageActionStateCopyWith<$Res> {
  factory _$MessageActionStateCopyWith(_MessageActionState value, $Res Function(_MessageActionState) _then) = __$MessageActionStateCopyWithImpl;
@override @useResult
$Res call({
 String actionText, VoidCallback action
});




}
/// @nodoc
class __$MessageActionStateCopyWithImpl<$Res>
    implements _$MessageActionStateCopyWith<$Res> {
  __$MessageActionStateCopyWithImpl(this._self, this._then);

  final _MessageActionState _self;
  final $Res Function(_MessageActionState) _then;

/// Create a copy of MessageActionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actionText = null,Object? action = null,}) {
  return _then(_MessageActionState(
actionText: null == actionText ? _self.actionText : actionText // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as VoidCallback,
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

  Function(String) get onSearch; bool get autoAddSearch; String? get query;
/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppBarSearchStateCopyWith<AppBarSearchState> get copyWith => _$AppBarSearchStateCopyWithImpl<AppBarSearchState>(this as AppBarSearchState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.autoAddSearch, autoAddSearch) || other.autoAddSearch == autoAddSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,onSearch,autoAddSearch,query);

@override
String toString() {
  return 'AppBarSearchState(onSearch: $onSearch, autoAddSearch: $autoAddSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class $AppBarSearchStateCopyWith<$Res>  {
  factory $AppBarSearchStateCopyWith(AppBarSearchState value, $Res Function(AppBarSearchState) _then) = _$AppBarSearchStateCopyWithImpl;
@useResult
$Res call({
  Function(String) onSearch, bool autoAddSearch, String? query
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
@pragma('vm:prefer-inline') @override $Res call({Object? onSearch = null,Object? autoAddSearch = null,Object? query = freezed,}) {
  return _then(_self.copyWith(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as  Function(String),autoAddSearch: null == autoAddSearch ? _self.autoAddSearch : autoAddSearch // ignore: cast_nullable_to_non_nullable
as bool,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(  Function(String) onSearch,  bool autoAddSearch,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.autoAddSearch,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(  Function(String) onSearch,  bool autoAddSearch,  String? query)  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState():
return $default(_that.onSearch,_that.autoAddSearch,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(  Function(String) onSearch,  bool autoAddSearch,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _AppBarSearchState() when $default != null:
return $default(_that.onSearch,_that.autoAddSearch,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _AppBarSearchState implements AppBarSearchState {
  const _AppBarSearchState({required this.onSearch, this.autoAddSearch = true, this.query = null});
  

@override final   Function(String) onSearch;
@override@JsonKey() final  bool autoAddSearch;
@override@JsonKey() final  String? query;

/// Create a copy of AppBarSearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppBarSearchStateCopyWith<_AppBarSearchState> get copyWith => __$AppBarSearchStateCopyWithImpl<_AppBarSearchState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppBarSearchState&&(identical(other.onSearch, onSearch) || other.onSearch == onSearch)&&(identical(other.autoAddSearch, autoAddSearch) || other.autoAddSearch == autoAddSearch)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,onSearch,autoAddSearch,query);

@override
String toString() {
  return 'AppBarSearchState(onSearch: $onSearch, autoAddSearch: $autoAddSearch, query: $query)';
}


}

/// @nodoc
abstract mixin class _$AppBarSearchStateCopyWith<$Res> implements $AppBarSearchStateCopyWith<$Res> {
  factory _$AppBarSearchStateCopyWith(_AppBarSearchState value, $Res Function(_AppBarSearchState) _then) = __$AppBarSearchStateCopyWithImpl;
@override @useResult
$Res call({
  Function(String) onSearch, bool autoAddSearch, String? query
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
@override @pragma('vm:prefer-inline') $Res call({Object? onSearch = null,Object? autoAddSearch = null,Object? query = freezed,}) {
  return _then(_AppBarSearchState(
onSearch: null == onSearch ? _self.onSearch : onSearch // ignore: cast_nullable_to_non_nullable
as  Function(String),autoAddSearch: null == autoAddSearch ? _self.autoAddSearch : autoAddSearch // ignore: cast_nullable_to_non_nullable
as bool,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
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

/// @nodoc
mixin _$StartButtonState {

 bool get isPreload; bool get hasProfile;
/// Create a copy of StartButtonState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartButtonStateCopyWith<StartButtonState> get copyWith => _$StartButtonStateCopyWithImpl<StartButtonState>(this as StartButtonState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartButtonState&&(identical(other.isPreload, isPreload) || other.isPreload == isPreload)&&(identical(other.hasProfile, hasProfile) || other.hasProfile == hasProfile));
}


@override
int get hashCode => Object.hash(runtimeType,isPreload,hasProfile);

@override
String toString() {
  return 'StartButtonState(isPreload: $isPreload, hasProfile: $hasProfile)';
}


}

/// @nodoc
abstract mixin class $StartButtonStateCopyWith<$Res>  {
  factory $StartButtonStateCopyWith(StartButtonState value, $Res Function(StartButtonState) _then) = _$StartButtonStateCopyWithImpl;
@useResult
$Res call({
 bool isPreload, bool hasProfile
});




}
/// @nodoc
class _$StartButtonStateCopyWithImpl<$Res>
    implements $StartButtonStateCopyWith<$Res> {
  _$StartButtonStateCopyWithImpl(this._self, this._then);

  final StartButtonState _self;
  final $Res Function(StartButtonState) _then;

/// Create a copy of StartButtonState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPreload = null,Object? hasProfile = null,}) {
  return _then(_self.copyWith(
isPreload: null == isPreload ? _self.isPreload : isPreload // ignore: cast_nullable_to_non_nullable
as bool,hasProfile: null == hasProfile ? _self.hasProfile : hasProfile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StartButtonState].
extension StartButtonStatePatterns on StartButtonState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartButtonState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartButtonState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartButtonState value)  $default,){
final _that = this;
switch (_that) {
case _StartButtonState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartButtonState value)?  $default,){
final _that = this;
switch (_that) {
case _StartButtonState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPreload,  bool hasProfile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartButtonState() when $default != null:
return $default(_that.isPreload,_that.hasProfile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPreload,  bool hasProfile)  $default,) {final _that = this;
switch (_that) {
case _StartButtonState():
return $default(_that.isPreload,_that.hasProfile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPreload,  bool hasProfile)?  $default,) {final _that = this;
switch (_that) {
case _StartButtonState() when $default != null:
return $default(_that.isPreload,_that.hasProfile);case _:
  return null;

}
}

}

/// @nodoc


class _StartButtonState implements StartButtonState {
  const _StartButtonState({required this.isPreload, required this.hasProfile});
  

@override final  bool isPreload;
@override final  bool hasProfile;

/// Create a copy of StartButtonState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartButtonStateCopyWith<_StartButtonState> get copyWith => __$StartButtonStateCopyWithImpl<_StartButtonState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartButtonState&&(identical(other.isPreload, isPreload) || other.isPreload == isPreload)&&(identical(other.hasProfile, hasProfile) || other.hasProfile == hasProfile));
}


@override
int get hashCode => Object.hash(runtimeType,isPreload,hasProfile);

@override
String toString() {
  return 'StartButtonState(isPreload: $isPreload, hasProfile: $hasProfile)';
}


}

/// @nodoc
abstract mixin class _$StartButtonStateCopyWith<$Res> implements $StartButtonStateCopyWith<$Res> {
  factory _$StartButtonStateCopyWith(_StartButtonState value, $Res Function(_StartButtonState) _then) = __$StartButtonStateCopyWithImpl;
@override @useResult
$Res call({
 bool isPreload, bool hasProfile
});




}
/// @nodoc
class __$StartButtonStateCopyWithImpl<$Res>
    implements _$StartButtonStateCopyWith<$Res> {
  __$StartButtonStateCopyWithImpl(this._self, this._then);

  final _StartButtonState _self;
  final $Res Function(_StartButtonState) _then;

/// Create a copy of StartButtonState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPreload = null,Object? hasProfile = null,}) {
  return _then(_StartButtonState(
isPreload: null == isPreload ? _self.isPreload : isPreload // ignore: cast_nullable_to_non_nullable
as bool,hasProfile: null == hasProfile ? _self.hasProfile : hasProfile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ProfilesState {

 List<Profile> get profiles; int? get currentProfileId;
/// Create a copy of ProfilesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfilesStateCopyWith<ProfilesState> get copyWith => _$ProfilesStateCopyWithImpl<ProfilesState>(this as ProfilesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfilesState&&const DeepCollectionEquality().equals(other.profiles, profiles)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(profiles),currentProfileId);

@override
String toString() {
  return 'ProfilesState(profiles: $profiles, currentProfileId: $currentProfileId)';
}


}

/// @nodoc
abstract mixin class $ProfilesStateCopyWith<$Res>  {
  factory $ProfilesStateCopyWith(ProfilesState value, $Res Function(ProfilesState) _then) = _$ProfilesStateCopyWithImpl;
@useResult
$Res call({
 List<Profile> profiles, int? currentProfileId
});




}
/// @nodoc
class _$ProfilesStateCopyWithImpl<$Res>
    implements $ProfilesStateCopyWith<$Res> {
  _$ProfilesStateCopyWithImpl(this._self, this._then);

  final ProfilesState _self;
  final $Res Function(ProfilesState) _then;

/// Create a copy of ProfilesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profiles = null,Object? currentProfileId = freezed,}) {
  return _then(_self.copyWith(
profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfilesState].
extension ProfilesStatePatterns on ProfilesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfilesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfilesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfilesState value)  $default,){
final _that = this;
switch (_that) {
case _ProfilesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfilesState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfilesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Profile> profiles,  int? currentProfileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfilesState() when $default != null:
return $default(_that.profiles,_that.currentProfileId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Profile> profiles,  int? currentProfileId)  $default,) {final _that = this;
switch (_that) {
case _ProfilesState():
return $default(_that.profiles,_that.currentProfileId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Profile> profiles,  int? currentProfileId)?  $default,) {final _that = this;
switch (_that) {
case _ProfilesState() when $default != null:
return $default(_that.profiles,_that.currentProfileId);case _:
  return null;

}
}

}

/// @nodoc


class _ProfilesState implements ProfilesState {
  const _ProfilesState({required final  List<Profile> profiles, required this.currentProfileId}): _profiles = profiles;
  

 final  List<Profile> _profiles;
@override List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

@override final  int? currentProfileId;

/// Create a copy of ProfilesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilesStateCopyWith<_ProfilesState> get copyWith => __$ProfilesStateCopyWithImpl<_ProfilesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilesState&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_profiles),currentProfileId);

@override
String toString() {
  return 'ProfilesState(profiles: $profiles, currentProfileId: $currentProfileId)';
}


}

/// @nodoc
abstract mixin class _$ProfilesStateCopyWith<$Res> implements $ProfilesStateCopyWith<$Res> {
  factory _$ProfilesStateCopyWith(_ProfilesState value, $Res Function(_ProfilesState) _then) = __$ProfilesStateCopyWithImpl;
@override @useResult
$Res call({
 List<Profile> profiles, int? currentProfileId
});




}
/// @nodoc
class __$ProfilesStateCopyWithImpl<$Res>
    implements _$ProfilesStateCopyWith<$Res> {
  __$ProfilesStateCopyWithImpl(this._self, this._then);

  final _ProfilesState _self;
  final $Res Function(_ProfilesState) _then;

/// Create a copy of ProfilesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profiles = null,Object? currentProfileId = freezed,}) {
  return _then(_ProfilesState(
profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$NetworkDetectionState {

 bool get isLoading; IpInfo? get ipInfo;
/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkDetectionStateCopyWith<NetworkDetectionState> get copyWith => _$NetworkDetectionStateCopyWithImpl<NetworkDetectionState>(this as NetworkDetectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkDetectionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ipInfo, ipInfo) || other.ipInfo == ipInfo));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,ipInfo);

@override
String toString() {
  return 'NetworkDetectionState(isLoading: $isLoading, ipInfo: $ipInfo)';
}


}

/// @nodoc
abstract mixin class $NetworkDetectionStateCopyWith<$Res>  {
  factory $NetworkDetectionStateCopyWith(NetworkDetectionState value, $Res Function(NetworkDetectionState) _then) = _$NetworkDetectionStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, IpInfo? ipInfo
});


$IpInfoCopyWith<$Res>? get ipInfo;

}
/// @nodoc
class _$NetworkDetectionStateCopyWithImpl<$Res>
    implements $NetworkDetectionStateCopyWith<$Res> {
  _$NetworkDetectionStateCopyWithImpl(this._self, this._then);

  final NetworkDetectionState _self;
  final $Res Function(NetworkDetectionState) _then;

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? ipInfo = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ipInfo: freezed == ipInfo ? _self.ipInfo : ipInfo // ignore: cast_nullable_to_non_nullable
as IpInfo?,
  ));
}
/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpInfoCopyWith<$Res>? get ipInfo {
    if (_self.ipInfo == null) {
    return null;
  }

  return $IpInfoCopyWith<$Res>(_self.ipInfo!, (value) {
    return _then(_self.copyWith(ipInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [NetworkDetectionState].
extension NetworkDetectionStatePatterns on NetworkDetectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NetworkDetectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NetworkDetectionState value)  $default,){
final _that = this;
switch (_that) {
case _NetworkDetectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NetworkDetectionState value)?  $default,){
final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  IpInfo? ipInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
return $default(_that.isLoading,_that.ipInfo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  IpInfo? ipInfo)  $default,) {final _that = this;
switch (_that) {
case _NetworkDetectionState():
return $default(_that.isLoading,_that.ipInfo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  IpInfo? ipInfo)?  $default,) {final _that = this;
switch (_that) {
case _NetworkDetectionState() when $default != null:
return $default(_that.isLoading,_that.ipInfo);case _:
  return null;

}
}

}

/// @nodoc


class _NetworkDetectionState implements NetworkDetectionState {
  const _NetworkDetectionState({required this.isLoading, required this.ipInfo});
  

@override final  bool isLoading;
@override final  IpInfo? ipInfo;

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkDetectionStateCopyWith<_NetworkDetectionState> get copyWith => __$NetworkDetectionStateCopyWithImpl<_NetworkDetectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NetworkDetectionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.ipInfo, ipInfo) || other.ipInfo == ipInfo));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,ipInfo);

@override
String toString() {
  return 'NetworkDetectionState(isLoading: $isLoading, ipInfo: $ipInfo)';
}


}

/// @nodoc
abstract mixin class _$NetworkDetectionStateCopyWith<$Res> implements $NetworkDetectionStateCopyWith<$Res> {
  factory _$NetworkDetectionStateCopyWith(_NetworkDetectionState value, $Res Function(_NetworkDetectionState) _then) = __$NetworkDetectionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, IpInfo? ipInfo
});


@override $IpInfoCopyWith<$Res>? get ipInfo;

}
/// @nodoc
class __$NetworkDetectionStateCopyWithImpl<$Res>
    implements _$NetworkDetectionStateCopyWith<$Res> {
  __$NetworkDetectionStateCopyWithImpl(this._self, this._then);

  final _NetworkDetectionState _self;
  final $Res Function(_NetworkDetectionState) _then;

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? ipInfo = freezed,}) {
  return _then(_NetworkDetectionState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,ipInfo: freezed == ipInfo ? _self.ipInfo : ipInfo // ignore: cast_nullable_to_non_nullable
as IpInfo?,
  ));
}

/// Create a copy of NetworkDetectionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IpInfoCopyWith<$Res>? get ipInfo {
    if (_self.ipInfo == null) {
    return null;
  }

  return $IpInfoCopyWith<$Res>(_self.ipInfo!, (value) {
    return _then(_self.copyWith(ipInfo: value));
  });
}
}

/// @nodoc
mixin _$TrayState {

 Mode get mode; int get port; bool get autoLaunch; bool get systemProxy; bool get tunEnable; bool get isStart; List<Group> get groups; Map<String, String> get selectedMap; bool get showTrayTitle;
/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrayStateCopyWith<TrayState> get copyWith => _$TrayStateCopyWithImpl<TrayState>(this as TrayState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrayState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.port, port) || other.port == port)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.tunEnable, tunEnable) || other.tunEnable == tunEnable)&&(identical(other.isStart, isStart) || other.isStart == isStart)&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mode,port,autoLaunch,systemProxy,tunEnable,isStart,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(selectedMap),showTrayTitle);

@override
String toString() {
  return 'TrayState(mode: $mode, port: $port, autoLaunch: $autoLaunch, systemProxy: $systemProxy, tunEnable: $tunEnable, isStart: $isStart, groups: $groups, selectedMap: $selectedMap, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class $TrayStateCopyWith<$Res>  {
  factory $TrayStateCopyWith(TrayState value, $Res Function(TrayState) _then) = _$TrayStateCopyWithImpl;
@useResult
$Res call({
 Mode mode, int port, bool autoLaunch, bool systemProxy, bool tunEnable, bool isStart, List<Group> groups, Map<String, String> selectedMap, bool showTrayTitle
});




}
/// @nodoc
class _$TrayStateCopyWithImpl<$Res>
    implements $TrayStateCopyWith<$Res> {
  _$TrayStateCopyWithImpl(this._self, this._then);

  final TrayState _self;
  final $Res Function(TrayState) _then;

/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? port = null,Object? autoLaunch = null,Object? systemProxy = null,Object? tunEnable = null,Object? isStart = null,Object? groups = null,Object? selectedMap = null,Object? showTrayTitle = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,tunEnable: null == tunEnable ? _self.tunEnable : tunEnable // ignore: cast_nullable_to_non_nullable
as bool,isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TrayState].
extension TrayStatePatterns on TrayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrayState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrayState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrayState value)  $default,){
final _that = this;
switch (_that) {
case _TrayState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrayState value)?  $default,){
final _that = this;
switch (_that) {
case _TrayState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrayState() when $default != null:
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)  $default,) {final _that = this;
switch (_that) {
case _TrayState():
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)?  $default,) {final _that = this;
switch (_that) {
case _TrayState() when $default != null:
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
  return null;

}
}

}

/// @nodoc


class _TrayState implements TrayState {
  const _TrayState({required this.mode, required this.port, required this.autoLaunch, required this.systemProxy, required this.tunEnable, required this.isStart, required final  List<Group> groups, required final  Map<String, String> selectedMap, required this.showTrayTitle}): _groups = groups,_selectedMap = selectedMap;
  

@override final  Mode mode;
@override final  int port;
@override final  bool autoLaunch;
@override final  bool systemProxy;
@override final  bool tunEnable;
@override final  bool isStart;
 final  List<Group> _groups;
@override List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  Map<String, String> _selectedMap;
@override Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override final  bool showTrayTitle;

/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrayStateCopyWith<_TrayState> get copyWith => __$TrayStateCopyWithImpl<_TrayState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrayState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.port, port) || other.port == port)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.tunEnable, tunEnable) || other.tunEnable == tunEnable)&&(identical(other.isStart, isStart) || other.isStart == isStart)&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mode,port,autoLaunch,systemProxy,tunEnable,isStart,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_selectedMap),showTrayTitle);

@override
String toString() {
  return 'TrayState(mode: $mode, port: $port, autoLaunch: $autoLaunch, systemProxy: $systemProxy, tunEnable: $tunEnable, isStart: $isStart, groups: $groups, selectedMap: $selectedMap, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class _$TrayStateCopyWith<$Res> implements $TrayStateCopyWith<$Res> {
  factory _$TrayStateCopyWith(_TrayState value, $Res Function(_TrayState) _then) = __$TrayStateCopyWithImpl;
@override @useResult
$Res call({
 Mode mode, int port, bool autoLaunch, bool systemProxy, bool tunEnable, bool isStart, List<Group> groups, Map<String, String> selectedMap, bool showTrayTitle
});




}
/// @nodoc
class __$TrayStateCopyWithImpl<$Res>
    implements _$TrayStateCopyWith<$Res> {
  __$TrayStateCopyWithImpl(this._self, this._then);

  final _TrayState _self;
  final $Res Function(_TrayState) _then;

/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? port = null,Object? autoLaunch = null,Object? systemProxy = null,Object? tunEnable = null,Object? isStart = null,Object? groups = null,Object? selectedMap = null,Object? showTrayTitle = null,}) {
  return _then(_TrayState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,tunEnable: null == tunEnable ? _self.tunEnable : tunEnable // ignore: cast_nullable_to_non_nullable
as bool,isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$TrayTitleState {

 Traffic get traffic; bool get showTrayTitle;
/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrayTitleStateCopyWith<TrayTitleState> get copyWith => _$TrayTitleStateCopyWithImpl<TrayTitleState>(this as TrayTitleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrayTitleState&&(identical(other.traffic, traffic) || other.traffic == traffic)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,traffic,showTrayTitle);

@override
String toString() {
  return 'TrayTitleState(traffic: $traffic, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class $TrayTitleStateCopyWith<$Res>  {
  factory $TrayTitleStateCopyWith(TrayTitleState value, $Res Function(TrayTitleState) _then) = _$TrayTitleStateCopyWithImpl;
@useResult
$Res call({
 Traffic traffic, bool showTrayTitle
});


$TrafficCopyWith<$Res> get traffic;

}
/// @nodoc
class _$TrayTitleStateCopyWithImpl<$Res>
    implements $TrayTitleStateCopyWith<$Res> {
  _$TrayTitleStateCopyWithImpl(this._self, this._then);

  final TrayTitleState _self;
  final $Res Function(TrayTitleState) _then;

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? traffic = null,Object? showTrayTitle = null,}) {
  return _then(_self.copyWith(
traffic: null == traffic ? _self.traffic : traffic // ignore: cast_nullable_to_non_nullable
as Traffic,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrafficCopyWith<$Res> get traffic {
  
  return $TrafficCopyWith<$Res>(_self.traffic, (value) {
    return _then(_self.copyWith(traffic: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrayTitleState].
extension TrayTitleStatePatterns on TrayTitleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrayTitleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrayTitleState value)  $default,){
final _that = this;
switch (_that) {
case _TrayTitleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrayTitleState value)?  $default,){
final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Traffic traffic,  bool showTrayTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
return $default(_that.traffic,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Traffic traffic,  bool showTrayTitle)  $default,) {final _that = this;
switch (_that) {
case _TrayTitleState():
return $default(_that.traffic,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Traffic traffic,  bool showTrayTitle)?  $default,) {final _that = this;
switch (_that) {
case _TrayTitleState() when $default != null:
return $default(_that.traffic,_that.showTrayTitle);case _:
  return null;

}
}

}

/// @nodoc


class _TrayTitleState implements TrayTitleState {
  const _TrayTitleState({required this.traffic, required this.showTrayTitle});
  

@override final  Traffic traffic;
@override final  bool showTrayTitle;

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrayTitleStateCopyWith<_TrayTitleState> get copyWith => __$TrayTitleStateCopyWithImpl<_TrayTitleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrayTitleState&&(identical(other.traffic, traffic) || other.traffic == traffic)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,traffic,showTrayTitle);

@override
String toString() {
  return 'TrayTitleState(traffic: $traffic, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class _$TrayTitleStateCopyWith<$Res> implements $TrayTitleStateCopyWith<$Res> {
  factory _$TrayTitleStateCopyWith(_TrayTitleState value, $Res Function(_TrayTitleState) _then) = __$TrayTitleStateCopyWithImpl;
@override @useResult
$Res call({
 Traffic traffic, bool showTrayTitle
});


@override $TrafficCopyWith<$Res> get traffic;

}
/// @nodoc
class __$TrayTitleStateCopyWithImpl<$Res>
    implements _$TrayTitleStateCopyWith<$Res> {
  __$TrayTitleStateCopyWithImpl(this._self, this._then);

  final _TrayTitleState _self;
  final $Res Function(_TrayTitleState) _then;

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? traffic = null,Object? showTrayTitle = null,}) {
  return _then(_TrayTitleState(
traffic: null == traffic ? _self.traffic : traffic // ignore: cast_nullable_to_non_nullable
as Traffic,showTrayTitle: null == showTrayTitle ? _self.showTrayTitle : showTrayTitle // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TrayTitleState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrafficCopyWith<$Res> get traffic {
  
  return $TrafficCopyWith<$Res>(_self.traffic, (value) {
    return _then(_self.copyWith(traffic: value));
  });
}
}

/// @nodoc
mixin _$NavigationState {

 PageLabel get pageLabel; List<NavigationItem> get navigationItems; ViewMode get viewMode; String? get locale; int get currentIndex;
/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationStateCopyWith<NavigationState> get copyWith => _$NavigationStateCopyWithImpl<NavigationState>(this as NavigationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationState&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&const DeepCollectionEquality().equals(other.navigationItems, navigationItems)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,pageLabel,const DeepCollectionEquality().hash(navigationItems),viewMode,locale,currentIndex);

@override
String toString() {
  return 'NavigationState(pageLabel: $pageLabel, navigationItems: $navigationItems, viewMode: $viewMode, locale: $locale, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class $NavigationStateCopyWith<$Res>  {
  factory $NavigationStateCopyWith(NavigationState value, $Res Function(NavigationState) _then) = _$NavigationStateCopyWithImpl;
@useResult
$Res call({
 PageLabel pageLabel, List<NavigationItem> navigationItems, ViewMode viewMode, String? locale, int currentIndex
});




}
/// @nodoc
class _$NavigationStateCopyWithImpl<$Res>
    implements $NavigationStateCopyWith<$Res> {
  _$NavigationStateCopyWithImpl(this._self, this._then);

  final NavigationState _self;
  final $Res Function(NavigationState) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageLabel = null,Object? navigationItems = null,Object? viewMode = null,Object? locale = freezed,Object? currentIndex = null,}) {
  return _then(_self.copyWith(
pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,navigationItems: null == navigationItems ? _self.navigationItems : navigationItems // ignore: cast_nullable_to_non_nullable
as List<NavigationItem>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ViewMode,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationState].
extension NavigationStatePatterns on NavigationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationState value)  $default,){
final _that = this;
switch (_that) {
case _NavigationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationState value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PageLabel pageLabel,  List<NavigationItem> navigationItems,  ViewMode viewMode,  String? locale,  int currentIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that.pageLabel,_that.navigationItems,_that.viewMode,_that.locale,_that.currentIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PageLabel pageLabel,  List<NavigationItem> navigationItems,  ViewMode viewMode,  String? locale,  int currentIndex)  $default,) {final _that = this;
switch (_that) {
case _NavigationState():
return $default(_that.pageLabel,_that.navigationItems,_that.viewMode,_that.locale,_that.currentIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PageLabel pageLabel,  List<NavigationItem> navigationItems,  ViewMode viewMode,  String? locale,  int currentIndex)?  $default,) {final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that.pageLabel,_that.navigationItems,_that.viewMode,_that.locale,_that.currentIndex);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationState implements NavigationState {
  const _NavigationState({required this.pageLabel, required final  List<NavigationItem> navigationItems, required this.viewMode, required this.locale, required this.currentIndex}): _navigationItems = navigationItems;
  

@override final  PageLabel pageLabel;
 final  List<NavigationItem> _navigationItems;
@override List<NavigationItem> get navigationItems {
  if (_navigationItems is EqualUnmodifiableListView) return _navigationItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_navigationItems);
}

@override final  ViewMode viewMode;
@override final  String? locale;
@override final  int currentIndex;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationStateCopyWith<_NavigationState> get copyWith => __$NavigationStateCopyWithImpl<_NavigationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationState&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&const DeepCollectionEquality().equals(other._navigationItems, _navigationItems)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,pageLabel,const DeepCollectionEquality().hash(_navigationItems),viewMode,locale,currentIndex);

@override
String toString() {
  return 'NavigationState(pageLabel: $pageLabel, navigationItems: $navigationItems, viewMode: $viewMode, locale: $locale, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$NavigationStateCopyWith<$Res> implements $NavigationStateCopyWith<$Res> {
  factory _$NavigationStateCopyWith(_NavigationState value, $Res Function(_NavigationState) _then) = __$NavigationStateCopyWithImpl;
@override @useResult
$Res call({
 PageLabel pageLabel, List<NavigationItem> navigationItems, ViewMode viewMode, String? locale, int currentIndex
});




}
/// @nodoc
class __$NavigationStateCopyWithImpl<$Res>
    implements _$NavigationStateCopyWith<$Res> {
  __$NavigationStateCopyWithImpl(this._self, this._then);

  final _NavigationState _self;
  final $Res Function(_NavigationState) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageLabel = null,Object? navigationItems = null,Object? viewMode = null,Object? locale = freezed,Object? currentIndex = null,}) {
  return _then(_NavigationState(
pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,navigationItems: null == navigationItems ? _self._navigationItems : navigationItems // ignore: cast_nullable_to_non_nullable
as List<NavigationItem>,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ViewMode,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GroupsState {

 List<Group> get value;
/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupsStateCopyWith<GroupsState> get copyWith => _$GroupsStateCopyWithImpl<GroupsState>(this as GroupsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupsState&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'GroupsState(value: $value)';
}


}

/// @nodoc
abstract mixin class $GroupsStateCopyWith<$Res>  {
  factory $GroupsStateCopyWith(GroupsState value, $Res Function(GroupsState) _then) = _$GroupsStateCopyWithImpl;
@useResult
$Res call({
 List<Group> value
});




}
/// @nodoc
class _$GroupsStateCopyWithImpl<$Res>
    implements $GroupsStateCopyWith<$Res> {
  _$GroupsStateCopyWithImpl(this._self, this._then);

  final GroupsState _self;
  final $Res Function(GroupsState) _then;

/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as List<Group>,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupsState].
extension GroupsStatePatterns on GroupsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupsState value)  $default,){
final _that = this;
switch (_that) {
case _GroupsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupsState value)?  $default,){
final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Group> value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Group> value)  $default,) {final _that = this;
switch (_that) {
case _GroupsState():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Group> value)?  $default,) {final _that = this;
switch (_that) {
case _GroupsState() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _GroupsState implements GroupsState {
  const _GroupsState({required final  List<Group> value}): _value = value;
  

 final  List<Group> _value;
@override List<Group> get value {
  if (_value is EqualUnmodifiableListView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_value);
}


/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupsStateCopyWith<_GroupsState> get copyWith => __$GroupsStateCopyWithImpl<_GroupsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupsState&&const DeepCollectionEquality().equals(other._value, _value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'GroupsState(value: $value)';
}


}

/// @nodoc
abstract mixin class _$GroupsStateCopyWith<$Res> implements $GroupsStateCopyWith<$Res> {
  factory _$GroupsStateCopyWith(_GroupsState value, $Res Function(_GroupsState) _then) = __$GroupsStateCopyWithImpl;
@override @useResult
$Res call({
 List<Group> value
});




}
/// @nodoc
class __$GroupsStateCopyWithImpl<$Res>
    implements _$GroupsStateCopyWith<$Res> {
  __$GroupsStateCopyWithImpl(this._self, this._then);

  final _GroupsState _self;
  final $Res Function(_GroupsState) _then;

/// Create a copy of GroupsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_GroupsState(
value: null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as List<Group>,
  ));
}


}

/// @nodoc
mixin _$NavigationItemsState {

 List<NavigationItem> get value;
/// Create a copy of NavigationItemsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationItemsStateCopyWith<NavigationItemsState> get copyWith => _$NavigationItemsStateCopyWithImpl<NavigationItemsState>(this as NavigationItemsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationItemsState&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'NavigationItemsState(value: $value)';
}


}

/// @nodoc
abstract mixin class $NavigationItemsStateCopyWith<$Res>  {
  factory $NavigationItemsStateCopyWith(NavigationItemsState value, $Res Function(NavigationItemsState) _then) = _$NavigationItemsStateCopyWithImpl;
@useResult
$Res call({
 List<NavigationItem> value
});




}
/// @nodoc
class _$NavigationItemsStateCopyWithImpl<$Res>
    implements $NavigationItemsStateCopyWith<$Res> {
  _$NavigationItemsStateCopyWithImpl(this._self, this._then);

  final NavigationItemsState _self;
  final $Res Function(NavigationItemsState) _then;

/// Create a copy of NavigationItemsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as List<NavigationItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationItemsState].
extension NavigationItemsStatePatterns on NavigationItemsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationItemsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationItemsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationItemsState value)  $default,){
final _that = this;
switch (_that) {
case _NavigationItemsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationItemsState value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationItemsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NavigationItem> value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationItemsState() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NavigationItem> value)  $default,) {final _that = this;
switch (_that) {
case _NavigationItemsState():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NavigationItem> value)?  $default,) {final _that = this;
switch (_that) {
case _NavigationItemsState() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationItemsState implements NavigationItemsState {
  const _NavigationItemsState({required final  List<NavigationItem> value}): _value = value;
  

 final  List<NavigationItem> _value;
@override List<NavigationItem> get value {
  if (_value is EqualUnmodifiableListView) return _value;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_value);
}


/// Create a copy of NavigationItemsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationItemsStateCopyWith<_NavigationItemsState> get copyWith => __$NavigationItemsStateCopyWithImpl<_NavigationItemsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationItemsState&&const DeepCollectionEquality().equals(other._value, _value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_value));

@override
String toString() {
  return 'NavigationItemsState(value: $value)';
}


}

/// @nodoc
abstract mixin class _$NavigationItemsStateCopyWith<$Res> implements $NavigationItemsStateCopyWith<$Res> {
  factory _$NavigationItemsStateCopyWith(_NavigationItemsState value, $Res Function(_NavigationItemsState) _then) = __$NavigationItemsStateCopyWithImpl;
@override @useResult
$Res call({
 List<NavigationItem> value
});




}
/// @nodoc
class __$NavigationItemsStateCopyWithImpl<$Res>
    implements _$NavigationItemsStateCopyWith<$Res> {
  __$NavigationItemsStateCopyWithImpl(this._self, this._then);

  final _NavigationItemsState _self;
  final $Res Function(_NavigationItemsState) _then;

/// Create a copy of NavigationItemsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_NavigationItemsState(
value: null == value ? _self._value : value // ignore: cast_nullable_to_non_nullable
as List<NavigationItem>,
  ));
}


}

/// @nodoc
mixin _$ProxiesListState {

 List<Group> get groups; Set<String> get currentUnfoldSet; ProxyCardType get proxyCardType;
/// Create a copy of ProxiesListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesListStateCopyWith<ProxiesListState> get copyWith => _$ProxiesListStateCopyWithImpl<ProxiesListState>(this as ProxiesListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesListState&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.currentUnfoldSet, currentUnfoldSet)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(currentUnfoldSet),proxyCardType);

@override
String toString() {
  return 'ProxiesListState(groups: $groups, currentUnfoldSet: $currentUnfoldSet, proxyCardType: $proxyCardType)';
}


}

/// @nodoc
abstract mixin class $ProxiesListStateCopyWith<$Res>  {
  factory $ProxiesListStateCopyWith(ProxiesListState value, $Res Function(ProxiesListState) _then) = _$ProxiesListStateCopyWithImpl;
@useResult
$Res call({
 List<Group> groups, Set<String> currentUnfoldSet, ProxyCardType proxyCardType
});




}
/// @nodoc
class _$ProxiesListStateCopyWithImpl<$Res>
    implements $ProxiesListStateCopyWith<$Res> {
  _$ProxiesListStateCopyWithImpl(this._self, this._then);

  final ProxiesListState _self;
  final $Res Function(ProxiesListState) _then;

/// Create a copy of ProxiesListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? currentUnfoldSet = null,Object? proxyCardType = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentUnfoldSet: null == currentUnfoldSet ? _self.currentUnfoldSet : currentUnfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesListState].
extension ProxiesListStatePatterns on ProxiesListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesListState value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesListState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Group> groups,  Set<String> currentUnfoldSet,  ProxyCardType proxyCardType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesListState() when $default != null:
return $default(_that.groups,_that.currentUnfoldSet,_that.proxyCardType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Group> groups,  Set<String> currentUnfoldSet,  ProxyCardType proxyCardType)  $default,) {final _that = this;
switch (_that) {
case _ProxiesListState():
return $default(_that.groups,_that.currentUnfoldSet,_that.proxyCardType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Group> groups,  Set<String> currentUnfoldSet,  ProxyCardType proxyCardType)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesListState() when $default != null:
return $default(_that.groups,_that.currentUnfoldSet,_that.proxyCardType);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesListState implements ProxiesListState {
  const _ProxiesListState({required final  List<Group> groups, required final  Set<String> currentUnfoldSet, required this.proxyCardType}): _groups = groups,_currentUnfoldSet = currentUnfoldSet;
  

 final  List<Group> _groups;
@override List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  Set<String> _currentUnfoldSet;
@override Set<String> get currentUnfoldSet {
  if (_currentUnfoldSet is EqualUnmodifiableSetView) return _currentUnfoldSet;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_currentUnfoldSet);
}

@override final  ProxyCardType proxyCardType;

/// Create a copy of ProxiesListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesListStateCopyWith<_ProxiesListState> get copyWith => __$ProxiesListStateCopyWithImpl<_ProxiesListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesListState&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._currentUnfoldSet, _currentUnfoldSet)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_currentUnfoldSet),proxyCardType);

@override
String toString() {
  return 'ProxiesListState(groups: $groups, currentUnfoldSet: $currentUnfoldSet, proxyCardType: $proxyCardType)';
}


}

/// @nodoc
abstract mixin class _$ProxiesListStateCopyWith<$Res> implements $ProxiesListStateCopyWith<$Res> {
  factory _$ProxiesListStateCopyWith(_ProxiesListState value, $Res Function(_ProxiesListState) _then) = __$ProxiesListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Group> groups, Set<String> currentUnfoldSet, ProxyCardType proxyCardType
});




}
/// @nodoc
class __$ProxiesListStateCopyWithImpl<$Res>
    implements _$ProxiesListStateCopyWith<$Res> {
  __$ProxiesListStateCopyWithImpl(this._self, this._then);

  final _ProxiesListState _self;
  final $Res Function(_ProxiesListState) _then;

/// Create a copy of ProxiesListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? currentUnfoldSet = null,Object? proxyCardType = null,}) {
  return _then(_ProxiesListState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentUnfoldSet: null == currentUnfoldSet ? _self._currentUnfoldSet : currentUnfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,
  ));
}


}

/// @nodoc
mixin _$ProxiesTabState {

 List<Group> get groups; String? get currentGroupName; ProxyCardType get proxyCardType;
/// Create a copy of ProxiesTabState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesTabStateCopyWith<ProxiesTabState> get copyWith => _$ProxiesTabStateCopyWithImpl<ProxiesTabState>(this as ProxiesTabState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesTabState&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),currentGroupName,proxyCardType);

@override
String toString() {
  return 'ProxiesTabState(groups: $groups, currentGroupName: $currentGroupName, proxyCardType: $proxyCardType)';
}


}

/// @nodoc
abstract mixin class $ProxiesTabStateCopyWith<$Res>  {
  factory $ProxiesTabStateCopyWith(ProxiesTabState value, $Res Function(ProxiesTabState) _then) = _$ProxiesTabStateCopyWithImpl;
@useResult
$Res call({
 List<Group> groups, String? currentGroupName, ProxyCardType proxyCardType
});




}
/// @nodoc
class _$ProxiesTabStateCopyWithImpl<$Res>
    implements $ProxiesTabStateCopyWith<$Res> {
  _$ProxiesTabStateCopyWithImpl(this._self, this._then);

  final ProxiesTabState _self;
  final $Res Function(ProxiesTabState) _then;

/// Create a copy of ProxiesTabState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? currentGroupName = freezed,Object? proxyCardType = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesTabState].
extension ProxiesTabStatePatterns on ProxiesTabState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesTabState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesTabState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesTabState value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesTabState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesTabState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesTabState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Group> groups,  String? currentGroupName,  ProxyCardType proxyCardType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesTabState() when $default != null:
return $default(_that.groups,_that.currentGroupName,_that.proxyCardType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Group> groups,  String? currentGroupName,  ProxyCardType proxyCardType)  $default,) {final _that = this;
switch (_that) {
case _ProxiesTabState():
return $default(_that.groups,_that.currentGroupName,_that.proxyCardType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Group> groups,  String? currentGroupName,  ProxyCardType proxyCardType)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesTabState() when $default != null:
return $default(_that.groups,_that.currentGroupName,_that.proxyCardType);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesTabState implements ProxiesTabState {
  const _ProxiesTabState({required final  List<Group> groups, required this.currentGroupName, required this.proxyCardType}): _groups = groups;
  

 final  List<Group> _groups;
@override List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override final  String? currentGroupName;
@override final  ProxyCardType proxyCardType;

/// Create a copy of ProxiesTabState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesTabStateCopyWith<_ProxiesTabState> get copyWith => __$ProxiesTabStateCopyWithImpl<_ProxiesTabState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesTabState&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),currentGroupName,proxyCardType);

@override
String toString() {
  return 'ProxiesTabState(groups: $groups, currentGroupName: $currentGroupName, proxyCardType: $proxyCardType)';
}


}

/// @nodoc
abstract mixin class _$ProxiesTabStateCopyWith<$Res> implements $ProxiesTabStateCopyWith<$Res> {
  factory _$ProxiesTabStateCopyWith(_ProxiesTabState value, $Res Function(_ProxiesTabState) _then) = __$ProxiesTabStateCopyWithImpl;
@override @useResult
$Res call({
 List<Group> groups, String? currentGroupName, ProxyCardType proxyCardType
});




}
/// @nodoc
class __$ProxiesTabStateCopyWithImpl<$Res>
    implements _$ProxiesTabStateCopyWith<$Res> {
  __$ProxiesTabStateCopyWithImpl(this._self, this._then);

  final _ProxiesTabState _self;
  final $Res Function(_ProxiesTabState) _then;

/// Create a copy of ProxiesTabState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? currentGroupName = freezed,Object? proxyCardType = null,}) {
  return _then(_ProxiesTabState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,
  ));
}


}

/// @nodoc
mixin _$ProxiesTabControllerState {

 List<String> get groupNames; String? get currentGroupName;
/// Create a copy of ProxiesTabControllerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesTabControllerStateCopyWith<ProxiesTabControllerState> get copyWith => _$ProxiesTabControllerStateCopyWithImpl<ProxiesTabControllerState>(this as ProxiesTabControllerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesTabControllerState&&const DeepCollectionEquality().equals(other.groupNames, groupNames)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groupNames),currentGroupName);

@override
String toString() {
  return 'ProxiesTabControllerState(groupNames: $groupNames, currentGroupName: $currentGroupName)';
}


}

/// @nodoc
abstract mixin class $ProxiesTabControllerStateCopyWith<$Res>  {
  factory $ProxiesTabControllerStateCopyWith(ProxiesTabControllerState value, $Res Function(ProxiesTabControllerState) _then) = _$ProxiesTabControllerStateCopyWithImpl;
@useResult
$Res call({
 List<String> groupNames, String? currentGroupName
});




}
/// @nodoc
class _$ProxiesTabControllerStateCopyWithImpl<$Res>
    implements $ProxiesTabControllerStateCopyWith<$Res> {
  _$ProxiesTabControllerStateCopyWithImpl(this._self, this._then);

  final ProxiesTabControllerState _self;
  final $Res Function(ProxiesTabControllerState) _then;

/// Create a copy of ProxiesTabControllerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupNames = null,Object? currentGroupName = freezed,}) {
  return _then(_self.copyWith(
groupNames: null == groupNames ? _self.groupNames : groupNames // ignore: cast_nullable_to_non_nullable
as List<String>,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesTabControllerState].
extension ProxiesTabControllerStatePatterns on ProxiesTabControllerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesTabControllerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesTabControllerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesTabControllerState value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesTabControllerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesTabControllerState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesTabControllerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> groupNames,  String? currentGroupName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesTabControllerState() when $default != null:
return $default(_that.groupNames,_that.currentGroupName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> groupNames,  String? currentGroupName)  $default,) {final _that = this;
switch (_that) {
case _ProxiesTabControllerState():
return $default(_that.groupNames,_that.currentGroupName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> groupNames,  String? currentGroupName)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesTabControllerState() when $default != null:
return $default(_that.groupNames,_that.currentGroupName);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesTabControllerState implements ProxiesTabControllerState {
  const _ProxiesTabControllerState({required final  List<String> groupNames, required this.currentGroupName}): _groupNames = groupNames;
  

 final  List<String> _groupNames;
@override List<String> get groupNames {
  if (_groupNames is EqualUnmodifiableListView) return _groupNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupNames);
}

@override final  String? currentGroupName;

/// Create a copy of ProxiesTabControllerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesTabControllerStateCopyWith<_ProxiesTabControllerState> get copyWith => __$ProxiesTabControllerStateCopyWithImpl<_ProxiesTabControllerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesTabControllerState&&const DeepCollectionEquality().equals(other._groupNames, _groupNames)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groupNames),currentGroupName);

@override
String toString() {
  return 'ProxiesTabControllerState(groupNames: $groupNames, currentGroupName: $currentGroupName)';
}


}

/// @nodoc
abstract mixin class _$ProxiesTabControllerStateCopyWith<$Res> implements $ProxiesTabControllerStateCopyWith<$Res> {
  factory _$ProxiesTabControllerStateCopyWith(_ProxiesTabControllerState value, $Res Function(_ProxiesTabControllerState) _then) = __$ProxiesTabControllerStateCopyWithImpl;
@override @useResult
$Res call({
 List<String> groupNames, String? currentGroupName
});




}
/// @nodoc
class __$ProxiesTabControllerStateCopyWithImpl<$Res>
    implements _$ProxiesTabControllerStateCopyWith<$Res> {
  __$ProxiesTabControllerStateCopyWithImpl(this._self, this._then);

  final _ProxiesTabControllerState _self;
  final $Res Function(_ProxiesTabControllerState) _then;

/// Create a copy of ProxiesTabControllerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupNames = null,Object? currentGroupName = freezed,}) {
  return _then(_ProxiesTabControllerState(
groupNames: null == groupNames ? _self._groupNames : groupNames // ignore: cast_nullable_to_non_nullable
as List<String>,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$ProxyGroupSelectorState {

 String? get testUrl; ProxiesSortType get proxiesSortType; ProxyCardType get proxyCardType; num get sortNum; GroupType get groupType; List<Proxy> get proxies;
/// Create a copy of ProxyGroupSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyGroupSelectorStateCopyWith<ProxyGroupSelectorState> get copyWith => _$ProxyGroupSelectorStateCopyWithImpl<ProxyGroupSelectorState>(this as ProxyGroupSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyGroupSelectorState&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.proxiesSortType, proxiesSortType) || other.proxiesSortType == proxiesSortType)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.sortNum, sortNum) || other.sortNum == sortNum)&&(identical(other.groupType, groupType) || other.groupType == groupType)&&const DeepCollectionEquality().equals(other.proxies, proxies));
}


@override
int get hashCode => Object.hash(runtimeType,testUrl,proxiesSortType,proxyCardType,sortNum,groupType,const DeepCollectionEquality().hash(proxies));

@override
String toString() {
  return 'ProxyGroupSelectorState(testUrl: $testUrl, proxiesSortType: $proxiesSortType, proxyCardType: $proxyCardType, sortNum: $sortNum, groupType: $groupType, proxies: $proxies)';
}


}

/// @nodoc
abstract mixin class $ProxyGroupSelectorStateCopyWith<$Res>  {
  factory $ProxyGroupSelectorStateCopyWith(ProxyGroupSelectorState value, $Res Function(ProxyGroupSelectorState) _then) = _$ProxyGroupSelectorStateCopyWithImpl;
@useResult
$Res call({
 String? testUrl, ProxiesSortType proxiesSortType, ProxyCardType proxyCardType, num sortNum, GroupType groupType, List<Proxy> proxies
});




}
/// @nodoc
class _$ProxyGroupSelectorStateCopyWithImpl<$Res>
    implements $ProxyGroupSelectorStateCopyWith<$Res> {
  _$ProxyGroupSelectorStateCopyWithImpl(this._self, this._then);

  final ProxyGroupSelectorState _self;
  final $Res Function(ProxyGroupSelectorState) _then;

/// Create a copy of ProxyGroupSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? testUrl = freezed,Object? proxiesSortType = null,Object? proxyCardType = null,Object? sortNum = null,Object? groupType = null,Object? proxies = null,}) {
  return _then(_self.copyWith(
testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,proxiesSortType: null == proxiesSortType ? _self.proxiesSortType : proxiesSortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,sortNum: null == sortNum ? _self.sortNum : sortNum // ignore: cast_nullable_to_non_nullable
as num,groupType: null == groupType ? _self.groupType : groupType // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyGroupSelectorState].
extension ProxyGroupSelectorStatePatterns on ProxyGroupSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyGroupSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyGroupSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyGroupSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _ProxyGroupSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyGroupSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyGroupSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? testUrl,  ProxiesSortType proxiesSortType,  ProxyCardType proxyCardType,  num sortNum,  GroupType groupType,  List<Proxy> proxies)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyGroupSelectorState() when $default != null:
return $default(_that.testUrl,_that.proxiesSortType,_that.proxyCardType,_that.sortNum,_that.groupType,_that.proxies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? testUrl,  ProxiesSortType proxiesSortType,  ProxyCardType proxyCardType,  num sortNum,  GroupType groupType,  List<Proxy> proxies)  $default,) {final _that = this;
switch (_that) {
case _ProxyGroupSelectorState():
return $default(_that.testUrl,_that.proxiesSortType,_that.proxyCardType,_that.sortNum,_that.groupType,_that.proxies);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? testUrl,  ProxiesSortType proxiesSortType,  ProxyCardType proxyCardType,  num sortNum,  GroupType groupType,  List<Proxy> proxies)?  $default,) {final _that = this;
switch (_that) {
case _ProxyGroupSelectorState() when $default != null:
return $default(_that.testUrl,_that.proxiesSortType,_that.proxyCardType,_that.sortNum,_that.groupType,_that.proxies);case _:
  return null;

}
}

}

/// @nodoc


class _ProxyGroupSelectorState implements ProxyGroupSelectorState {
  const _ProxyGroupSelectorState({required this.testUrl, required this.proxiesSortType, required this.proxyCardType, required this.sortNum, required this.groupType, required final  List<Proxy> proxies}): _proxies = proxies;
  

@override final  String? testUrl;
@override final  ProxiesSortType proxiesSortType;
@override final  ProxyCardType proxyCardType;
@override final  num sortNum;
@override final  GroupType groupType;
 final  List<Proxy> _proxies;
@override List<Proxy> get proxies {
  if (_proxies is EqualUnmodifiableListView) return _proxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxies);
}


/// Create a copy of ProxyGroupSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyGroupSelectorStateCopyWith<_ProxyGroupSelectorState> get copyWith => __$ProxyGroupSelectorStateCopyWithImpl<_ProxyGroupSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyGroupSelectorState&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.proxiesSortType, proxiesSortType) || other.proxiesSortType == proxiesSortType)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.sortNum, sortNum) || other.sortNum == sortNum)&&(identical(other.groupType, groupType) || other.groupType == groupType)&&const DeepCollectionEquality().equals(other._proxies, _proxies));
}


@override
int get hashCode => Object.hash(runtimeType,testUrl,proxiesSortType,proxyCardType,sortNum,groupType,const DeepCollectionEquality().hash(_proxies));

@override
String toString() {
  return 'ProxyGroupSelectorState(testUrl: $testUrl, proxiesSortType: $proxiesSortType, proxyCardType: $proxyCardType, sortNum: $sortNum, groupType: $groupType, proxies: $proxies)';
}


}

/// @nodoc
abstract mixin class _$ProxyGroupSelectorStateCopyWith<$Res> implements $ProxyGroupSelectorStateCopyWith<$Res> {
  factory _$ProxyGroupSelectorStateCopyWith(_ProxyGroupSelectorState value, $Res Function(_ProxyGroupSelectorState) _then) = __$ProxyGroupSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 String? testUrl, ProxiesSortType proxiesSortType, ProxyCardType proxyCardType, num sortNum, GroupType groupType, List<Proxy> proxies
});




}
/// @nodoc
class __$ProxyGroupSelectorStateCopyWithImpl<$Res>
    implements _$ProxyGroupSelectorStateCopyWith<$Res> {
  __$ProxyGroupSelectorStateCopyWithImpl(this._self, this._then);

  final _ProxyGroupSelectorState _self;
  final $Res Function(_ProxyGroupSelectorState) _then;

/// Create a copy of ProxyGroupSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? testUrl = freezed,Object? proxiesSortType = null,Object? proxyCardType = null,Object? sortNum = null,Object? groupType = null,Object? proxies = null,}) {
  return _then(_ProxyGroupSelectorState(
testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,proxiesSortType: null == proxiesSortType ? _self.proxiesSortType : proxiesSortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,sortNum: null == sortNum ? _self.sortNum : sortNum // ignore: cast_nullable_to_non_nullable
as num,groupType: null == groupType ? _self.groupType : groupType // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,
  ));
}


}

/// @nodoc
mixin _$MoreToolsSelectorState {

 List<NavigationItem> get navigationItems;
/// Create a copy of MoreToolsSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoreToolsSelectorStateCopyWith<MoreToolsSelectorState> get copyWith => _$MoreToolsSelectorStateCopyWithImpl<MoreToolsSelectorState>(this as MoreToolsSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoreToolsSelectorState&&const DeepCollectionEquality().equals(other.navigationItems, navigationItems));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(navigationItems));

@override
String toString() {
  return 'MoreToolsSelectorState(navigationItems: $navigationItems)';
}


}

/// @nodoc
abstract mixin class $MoreToolsSelectorStateCopyWith<$Res>  {
  factory $MoreToolsSelectorStateCopyWith(MoreToolsSelectorState value, $Res Function(MoreToolsSelectorState) _then) = _$MoreToolsSelectorStateCopyWithImpl;
@useResult
$Res call({
 List<NavigationItem> navigationItems
});




}
/// @nodoc
class _$MoreToolsSelectorStateCopyWithImpl<$Res>
    implements $MoreToolsSelectorStateCopyWith<$Res> {
  _$MoreToolsSelectorStateCopyWithImpl(this._self, this._then);

  final MoreToolsSelectorState _self;
  final $Res Function(MoreToolsSelectorState) _then;

/// Create a copy of MoreToolsSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? navigationItems = null,}) {
  return _then(_self.copyWith(
navigationItems: null == navigationItems ? _self.navigationItems : navigationItems // ignore: cast_nullable_to_non_nullable
as List<NavigationItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [MoreToolsSelectorState].
extension MoreToolsSelectorStatePatterns on MoreToolsSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoreToolsSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoreToolsSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoreToolsSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _MoreToolsSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoreToolsSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _MoreToolsSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NavigationItem> navigationItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoreToolsSelectorState() when $default != null:
return $default(_that.navigationItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NavigationItem> navigationItems)  $default,) {final _that = this;
switch (_that) {
case _MoreToolsSelectorState():
return $default(_that.navigationItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NavigationItem> navigationItems)?  $default,) {final _that = this;
switch (_that) {
case _MoreToolsSelectorState() when $default != null:
return $default(_that.navigationItems);case _:
  return null;

}
}

}

/// @nodoc


class _MoreToolsSelectorState implements MoreToolsSelectorState {
  const _MoreToolsSelectorState({required final  List<NavigationItem> navigationItems}): _navigationItems = navigationItems;
  

 final  List<NavigationItem> _navigationItems;
@override List<NavigationItem> get navigationItems {
  if (_navigationItems is EqualUnmodifiableListView) return _navigationItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_navigationItems);
}


/// Create a copy of MoreToolsSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoreToolsSelectorStateCopyWith<_MoreToolsSelectorState> get copyWith => __$MoreToolsSelectorStateCopyWithImpl<_MoreToolsSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoreToolsSelectorState&&const DeepCollectionEquality().equals(other._navigationItems, _navigationItems));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_navigationItems));

@override
String toString() {
  return 'MoreToolsSelectorState(navigationItems: $navigationItems)';
}


}

/// @nodoc
abstract mixin class _$MoreToolsSelectorStateCopyWith<$Res> implements $MoreToolsSelectorStateCopyWith<$Res> {
  factory _$MoreToolsSelectorStateCopyWith(_MoreToolsSelectorState value, $Res Function(_MoreToolsSelectorState) _then) = __$MoreToolsSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 List<NavigationItem> navigationItems
});




}
/// @nodoc
class __$MoreToolsSelectorStateCopyWithImpl<$Res>
    implements _$MoreToolsSelectorStateCopyWith<$Res> {
  __$MoreToolsSelectorStateCopyWithImpl(this._self, this._then);

  final _MoreToolsSelectorState _self;
  final $Res Function(_MoreToolsSelectorState) _then;

/// Create a copy of MoreToolsSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? navigationItems = null,}) {
  return _then(_MoreToolsSelectorState(
navigationItems: null == navigationItems ? _self._navigationItems : navigationItems // ignore: cast_nullable_to_non_nullable
as List<NavigationItem>,
  ));
}


}

/// @nodoc
mixin _$PackageListSelectorState {

 List<Package> get packages; AccessControlProps get accessControlProps;
/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageListSelectorStateCopyWith<PackageListSelectorState> get copyWith => _$PackageListSelectorStateCopyWithImpl<PackageListSelectorState>(this as PackageListSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageListSelectorState&&const DeepCollectionEquality().equals(other.packages, packages)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(packages),accessControlProps);

@override
String toString() {
  return 'PackageListSelectorState(packages: $packages, accessControlProps: $accessControlProps)';
}


}

/// @nodoc
abstract mixin class $PackageListSelectorStateCopyWith<$Res>  {
  factory $PackageListSelectorStateCopyWith(PackageListSelectorState value, $Res Function(PackageListSelectorState) _then) = _$PackageListSelectorStateCopyWithImpl;
@useResult
$Res call({
 List<Package> packages, AccessControlProps accessControlProps
});


$AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class _$PackageListSelectorStateCopyWithImpl<$Res>
    implements $PackageListSelectorStateCopyWith<$Res> {
  _$PackageListSelectorStateCopyWithImpl(this._self, this._then);

  final PackageListSelectorState _self;
  final $Res Function(PackageListSelectorState) _then;

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packages = null,Object? accessControlProps = null,}) {
  return _then(_self.copyWith(
packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<Package>,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,
  ));
}
/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlPropsCopyWith<$Res> get accessControlProps {
  
  return $AccessControlPropsCopyWith<$Res>(_self.accessControlProps, (value) {
    return _then(_self.copyWith(accessControlProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [PackageListSelectorState].
extension PackageListSelectorStatePatterns on PackageListSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageListSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageListSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageListSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _PackageListSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageListSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _PackageListSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Package> packages,  AccessControlProps accessControlProps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageListSelectorState() when $default != null:
return $default(_that.packages,_that.accessControlProps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Package> packages,  AccessControlProps accessControlProps)  $default,) {final _that = this;
switch (_that) {
case _PackageListSelectorState():
return $default(_that.packages,_that.accessControlProps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Package> packages,  AccessControlProps accessControlProps)?  $default,) {final _that = this;
switch (_that) {
case _PackageListSelectorState() when $default != null:
return $default(_that.packages,_that.accessControlProps);case _:
  return null;

}
}

}

/// @nodoc


class _PackageListSelectorState implements PackageListSelectorState {
  const _PackageListSelectorState({required final  List<Package> packages, required this.accessControlProps}): _packages = packages;
  

 final  List<Package> _packages;
@override List<Package> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

@override final  AccessControlProps accessControlProps;

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageListSelectorStateCopyWith<_PackageListSelectorState> get copyWith => __$PackageListSelectorStateCopyWithImpl<_PackageListSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageListSelectorState&&const DeepCollectionEquality().equals(other._packages, _packages)&&(identical(other.accessControlProps, accessControlProps) || other.accessControlProps == accessControlProps));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_packages),accessControlProps);

@override
String toString() {
  return 'PackageListSelectorState(packages: $packages, accessControlProps: $accessControlProps)';
}


}

/// @nodoc
abstract mixin class _$PackageListSelectorStateCopyWith<$Res> implements $PackageListSelectorStateCopyWith<$Res> {
  factory _$PackageListSelectorStateCopyWith(_PackageListSelectorState value, $Res Function(_PackageListSelectorState) _then) = __$PackageListSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 List<Package> packages, AccessControlProps accessControlProps
});


@override $AccessControlPropsCopyWith<$Res> get accessControlProps;

}
/// @nodoc
class __$PackageListSelectorStateCopyWithImpl<$Res>
    implements _$PackageListSelectorStateCopyWith<$Res> {
  __$PackageListSelectorStateCopyWithImpl(this._self, this._then);

  final _PackageListSelectorState _self;
  final $Res Function(_PackageListSelectorState) _then;

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packages = null,Object? accessControlProps = null,}) {
  return _then(_PackageListSelectorState(
packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<Package>,accessControlProps: null == accessControlProps ? _self.accessControlProps : accessControlProps // ignore: cast_nullable_to_non_nullable
as AccessControlProps,
  ));
}

/// Create a copy of PackageListSelectorState
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
mixin _$ProxiesListHeaderSelectorState {

 double get offset; int get currentIndex;
/// Create a copy of ProxiesListHeaderSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesListHeaderSelectorStateCopyWith<ProxiesListHeaderSelectorState> get copyWith => _$ProxiesListHeaderSelectorStateCopyWithImpl<ProxiesListHeaderSelectorState>(this as ProxiesListHeaderSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesListHeaderSelectorState&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,offset,currentIndex);

@override
String toString() {
  return 'ProxiesListHeaderSelectorState(offset: $offset, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class $ProxiesListHeaderSelectorStateCopyWith<$Res>  {
  factory $ProxiesListHeaderSelectorStateCopyWith(ProxiesListHeaderSelectorState value, $Res Function(ProxiesListHeaderSelectorState) _then) = _$ProxiesListHeaderSelectorStateCopyWithImpl;
@useResult
$Res call({
 double offset, int currentIndex
});




}
/// @nodoc
class _$ProxiesListHeaderSelectorStateCopyWithImpl<$Res>
    implements $ProxiesListHeaderSelectorStateCopyWith<$Res> {
  _$ProxiesListHeaderSelectorStateCopyWithImpl(this._self, this._then);

  final ProxiesListHeaderSelectorState _self;
  final $Res Function(ProxiesListHeaderSelectorState) _then;

/// Create a copy of ProxiesListHeaderSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? offset = null,Object? currentIndex = null,}) {
  return _then(_self.copyWith(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesListHeaderSelectorState].
extension ProxiesListHeaderSelectorStatePatterns on ProxiesListHeaderSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesListHeaderSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesListHeaderSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesListHeaderSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesListHeaderSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesListHeaderSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesListHeaderSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double offset,  int currentIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesListHeaderSelectorState() when $default != null:
return $default(_that.offset,_that.currentIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double offset,  int currentIndex)  $default,) {final _that = this;
switch (_that) {
case _ProxiesListHeaderSelectorState():
return $default(_that.offset,_that.currentIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double offset,  int currentIndex)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesListHeaderSelectorState() when $default != null:
return $default(_that.offset,_that.currentIndex);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesListHeaderSelectorState implements ProxiesListHeaderSelectorState {
  const _ProxiesListHeaderSelectorState({required this.offset, required this.currentIndex});
  

@override final  double offset;
@override final  int currentIndex;

/// Create a copy of ProxiesListHeaderSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesListHeaderSelectorStateCopyWith<_ProxiesListHeaderSelectorState> get copyWith => __$ProxiesListHeaderSelectorStateCopyWithImpl<_ProxiesListHeaderSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesListHeaderSelectorState&&(identical(other.offset, offset) || other.offset == offset)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,offset,currentIndex);

@override
String toString() {
  return 'ProxiesListHeaderSelectorState(offset: $offset, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$ProxiesListHeaderSelectorStateCopyWith<$Res> implements $ProxiesListHeaderSelectorStateCopyWith<$Res> {
  factory _$ProxiesListHeaderSelectorStateCopyWith(_ProxiesListHeaderSelectorState value, $Res Function(_ProxiesListHeaderSelectorState) _then) = __$ProxiesListHeaderSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 double offset, int currentIndex
});




}
/// @nodoc
class __$ProxiesListHeaderSelectorStateCopyWithImpl<$Res>
    implements _$ProxiesListHeaderSelectorStateCopyWith<$Res> {
  __$ProxiesListHeaderSelectorStateCopyWithImpl(this._self, this._then);

  final _ProxiesListHeaderSelectorState _self;
  final $Res Function(_ProxiesListHeaderSelectorState) _then;

/// Create a copy of ProxiesListHeaderSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? offset = null,Object? currentIndex = null,}) {
  return _then(_ProxiesListHeaderSelectorState(
offset: null == offset ? _self.offset : offset // ignore: cast_nullable_to_non_nullable
as double,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ProxiesActionsState {

 PageLabel get pageLabel; ProxiesType get type; bool get hasProviders;
/// Create a copy of ProxiesActionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesActionsStateCopyWith<ProxiesActionsState> get copyWith => _$ProxiesActionsStateCopyWithImpl<ProxiesActionsState>(this as ProxiesActionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesActionsState&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasProviders, hasProviders) || other.hasProviders == hasProviders));
}


@override
int get hashCode => Object.hash(runtimeType,pageLabel,type,hasProviders);

@override
String toString() {
  return 'ProxiesActionsState(pageLabel: $pageLabel, type: $type, hasProviders: $hasProviders)';
}


}

/// @nodoc
abstract mixin class $ProxiesActionsStateCopyWith<$Res>  {
  factory $ProxiesActionsStateCopyWith(ProxiesActionsState value, $Res Function(ProxiesActionsState) _then) = _$ProxiesActionsStateCopyWithImpl;
@useResult
$Res call({
 PageLabel pageLabel, ProxiesType type, bool hasProviders
});




}
/// @nodoc
class _$ProxiesActionsStateCopyWithImpl<$Res>
    implements $ProxiesActionsStateCopyWith<$Res> {
  _$ProxiesActionsStateCopyWithImpl(this._self, this._then);

  final ProxiesActionsState _self;
  final $Res Function(ProxiesActionsState) _then;

/// Create a copy of ProxiesActionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageLabel = null,Object? type = null,Object? hasProviders = null,}) {
  return _then(_self.copyWith(
pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,hasProviders: null == hasProviders ? _self.hasProviders : hasProviders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxiesActionsState].
extension ProxiesActionsStatePatterns on ProxiesActionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxiesActionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxiesActionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxiesActionsState value)  $default,){
final _that = this;
switch (_that) {
case _ProxiesActionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxiesActionsState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxiesActionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PageLabel pageLabel,  ProxiesType type,  bool hasProviders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesActionsState() when $default != null:
return $default(_that.pageLabel,_that.type,_that.hasProviders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PageLabel pageLabel,  ProxiesType type,  bool hasProviders)  $default,) {final _that = this;
switch (_that) {
case _ProxiesActionsState():
return $default(_that.pageLabel,_that.type,_that.hasProviders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PageLabel pageLabel,  ProxiesType type,  bool hasProviders)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesActionsState() when $default != null:
return $default(_that.pageLabel,_that.type,_that.hasProviders);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesActionsState implements ProxiesActionsState {
  const _ProxiesActionsState({required this.pageLabel, required this.type, required this.hasProviders});
  

@override final  PageLabel pageLabel;
@override final  ProxiesType type;
@override final  bool hasProviders;

/// Create a copy of ProxiesActionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesActionsStateCopyWith<_ProxiesActionsState> get copyWith => __$ProxiesActionsStateCopyWithImpl<_ProxiesActionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesActionsState&&(identical(other.pageLabel, pageLabel) || other.pageLabel == pageLabel)&&(identical(other.type, type) || other.type == type)&&(identical(other.hasProviders, hasProviders) || other.hasProviders == hasProviders));
}


@override
int get hashCode => Object.hash(runtimeType,pageLabel,type,hasProviders);

@override
String toString() {
  return 'ProxiesActionsState(pageLabel: $pageLabel, type: $type, hasProviders: $hasProviders)';
}


}

/// @nodoc
abstract mixin class _$ProxiesActionsStateCopyWith<$Res> implements $ProxiesActionsStateCopyWith<$Res> {
  factory _$ProxiesActionsStateCopyWith(_ProxiesActionsState value, $Res Function(_ProxiesActionsState) _then) = __$ProxiesActionsStateCopyWithImpl;
@override @useResult
$Res call({
 PageLabel pageLabel, ProxiesType type, bool hasProviders
});




}
/// @nodoc
class __$ProxiesActionsStateCopyWithImpl<$Res>
    implements _$ProxiesActionsStateCopyWith<$Res> {
  __$ProxiesActionsStateCopyWithImpl(this._self, this._then);

  final _ProxiesActionsState _self;
  final $Res Function(_ProxiesActionsState) _then;

/// Create a copy of ProxiesActionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageLabel = null,Object? type = null,Object? hasProviders = null,}) {
  return _then(_ProxiesActionsState(
pageLabel: null == pageLabel ? _self.pageLabel : pageLabel // ignore: cast_nullable_to_non_nullable
as PageLabel,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProxiesType,hasProviders: null == hasProviders ? _self.hasProviders : hasProviders // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ProxyState {

 bool get isStart; bool get systemProxy; List<String> get bassDomain; int get port;
/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyStateCopyWith<ProxyState> get copyWith => _$ProxyStateCopyWithImpl<ProxyState>(this as ProxyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyState&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bassDomain, bassDomain)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,isStart,systemProxy,const DeepCollectionEquality().hash(bassDomain),port);

@override
String toString() {
  return 'ProxyState(isStart: $isStart, systemProxy: $systemProxy, bassDomain: $bassDomain, port: $port)';
}


}

/// @nodoc
abstract mixin class $ProxyStateCopyWith<$Res>  {
  factory $ProxyStateCopyWith(ProxyState value, $Res Function(ProxyState) _then) = _$ProxyStateCopyWithImpl;
@useResult
$Res call({
 bool isStart, bool systemProxy, List<String> bassDomain, int port
});




}
/// @nodoc
class _$ProxyStateCopyWithImpl<$Res>
    implements $ProxyStateCopyWith<$Res> {
  _$ProxyStateCopyWithImpl(this._self, this._then);

  final ProxyState _self;
  final $Res Function(ProxyState) _then;

/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isStart = null,Object? systemProxy = null,Object? bassDomain = null,Object? port = null,}) {
  return _then(_self.copyWith(
isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bassDomain: null == bassDomain ? _self.bassDomain : bassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProxyState].
extension ProxyStatePatterns on ProxyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProxyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProxyState value)  $default,){
final _that = this;
switch (_that) {
case _ProxyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProxyState value)?  $default,){
final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isStart,  bool systemProxy,  List<String> bassDomain,  int port)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
return $default(_that.isStart,_that.systemProxy,_that.bassDomain,_that.port);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isStart,  bool systemProxy,  List<String> bassDomain,  int port)  $default,) {final _that = this;
switch (_that) {
case _ProxyState():
return $default(_that.isStart,_that.systemProxy,_that.bassDomain,_that.port);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isStart,  bool systemProxy,  List<String> bassDomain,  int port)?  $default,) {final _that = this;
switch (_that) {
case _ProxyState() when $default != null:
return $default(_that.isStart,_that.systemProxy,_that.bassDomain,_that.port);case _:
  return null;

}
}

}

/// @nodoc


class _ProxyState implements ProxyState {
  const _ProxyState({required this.isStart, required this.systemProxy, required final  List<String> bassDomain, required this.port}): _bassDomain = bassDomain;
  

@override final  bool isStart;
@override final  bool systemProxy;
 final  List<String> _bassDomain;
@override List<String> get bassDomain {
  if (_bassDomain is EqualUnmodifiableListView) return _bassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bassDomain);
}

@override final  int port;

/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyStateCopyWith<_ProxyState> get copyWith => __$ProxyStateCopyWithImpl<_ProxyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyState&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other._bassDomain, _bassDomain)&&(identical(other.port, port) || other.port == port));
}


@override
int get hashCode => Object.hash(runtimeType,isStart,systemProxy,const DeepCollectionEquality().hash(_bassDomain),port);

@override
String toString() {
  return 'ProxyState(isStart: $isStart, systemProxy: $systemProxy, bassDomain: $bassDomain, port: $port)';
}


}

/// @nodoc
abstract mixin class _$ProxyStateCopyWith<$Res> implements $ProxyStateCopyWith<$Res> {
  factory _$ProxyStateCopyWith(_ProxyState value, $Res Function(_ProxyState) _then) = __$ProxyStateCopyWithImpl;
@override @useResult
$Res call({
 bool isStart, bool systemProxy, List<String> bassDomain, int port
});




}
/// @nodoc
class __$ProxyStateCopyWithImpl<$Res>
    implements _$ProxyStateCopyWith<$Res> {
  __$ProxyStateCopyWithImpl(this._self, this._then);

  final _ProxyState _self;
  final $Res Function(_ProxyState) _then;

/// Create a copy of ProxyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isStart = null,Object? systemProxy = null,Object? bassDomain = null,Object? port = null,}) {
  return _then(_ProxyState(
isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bassDomain: null == bassDomain ? _self._bassDomain : bassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ThemeColorsSelectorState {

 int? get primaryColor; List<int> get primaryColors; DynamicSchemeVariant get schemeVariant; bool get isDefault;
/// Create a copy of ThemeColorsSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeColorsSelectorStateCopyWith<ThemeColorsSelectorState> get copyWith => _$ThemeColorsSelectorStateCopyWithImpl<ThemeColorsSelectorState>(this as ThemeColorsSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeColorsSelectorState&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other.primaryColors, primaryColors)&&(identical(other.schemeVariant, schemeVariant) || other.schemeVariant == schemeVariant)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}


@override
int get hashCode => Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(primaryColors),schemeVariant,isDefault);

@override
String toString() {
  return 'ThemeColorsSelectorState(primaryColor: $primaryColor, primaryColors: $primaryColors, schemeVariant: $schemeVariant, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $ThemeColorsSelectorStateCopyWith<$Res>  {
  factory $ThemeColorsSelectorStateCopyWith(ThemeColorsSelectorState value, $Res Function(ThemeColorsSelectorState) _then) = _$ThemeColorsSelectorStateCopyWithImpl;
@useResult
$Res call({
 int? primaryColor, List<int> primaryColors, DynamicSchemeVariant schemeVariant, bool isDefault
});




}
/// @nodoc
class _$ThemeColorsSelectorStateCopyWithImpl<$Res>
    implements $ThemeColorsSelectorStateCopyWith<$Res> {
  _$ThemeColorsSelectorStateCopyWithImpl(this._self, this._then);

  final ThemeColorsSelectorState _self;
  final $Res Function(ThemeColorsSelectorState) _then;

/// Create a copy of ThemeColorsSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? schemeVariant = null,Object? isDefault = null,}) {
  return _then(_self.copyWith(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self.primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeColorsSelectorState].
extension ThemeColorsSelectorStatePatterns on ThemeColorsSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeColorsSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeColorsSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeColorsSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _ThemeColorsSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeColorsSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeColorsSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  DynamicSchemeVariant schemeVariant,  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeColorsSelectorState() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.schemeVariant,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? primaryColor,  List<int> primaryColors,  DynamicSchemeVariant schemeVariant,  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _ThemeColorsSelectorState():
return $default(_that.primaryColor,_that.primaryColors,_that.schemeVariant,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? primaryColor,  List<int> primaryColors,  DynamicSchemeVariant schemeVariant,  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _ThemeColorsSelectorState() when $default != null:
return $default(_that.primaryColor,_that.primaryColors,_that.schemeVariant,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc


class _ThemeColorsSelectorState implements ThemeColorsSelectorState {
  const _ThemeColorsSelectorState({required this.primaryColor, required final  List<int> primaryColors, required this.schemeVariant, required this.isDefault}): _primaryColors = primaryColors;
  

@override final  int? primaryColor;
 final  List<int> _primaryColors;
@override List<int> get primaryColors {
  if (_primaryColors is EqualUnmodifiableListView) return _primaryColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_primaryColors);
}

@override final  DynamicSchemeVariant schemeVariant;
@override final  bool isDefault;

/// Create a copy of ThemeColorsSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeColorsSelectorStateCopyWith<_ThemeColorsSelectorState> get copyWith => __$ThemeColorsSelectorStateCopyWithImpl<_ThemeColorsSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeColorsSelectorState&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&const DeepCollectionEquality().equals(other._primaryColors, _primaryColors)&&(identical(other.schemeVariant, schemeVariant) || other.schemeVariant == schemeVariant)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}


@override
int get hashCode => Object.hash(runtimeType,primaryColor,const DeepCollectionEquality().hash(_primaryColors),schemeVariant,isDefault);

@override
String toString() {
  return 'ThemeColorsSelectorState(primaryColor: $primaryColor, primaryColors: $primaryColors, schemeVariant: $schemeVariant, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$ThemeColorsSelectorStateCopyWith<$Res> implements $ThemeColorsSelectorStateCopyWith<$Res> {
  factory _$ThemeColorsSelectorStateCopyWith(_ThemeColorsSelectorState value, $Res Function(_ThemeColorsSelectorState) _then) = __$ThemeColorsSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 int? primaryColor, List<int> primaryColors, DynamicSchemeVariant schemeVariant, bool isDefault
});




}
/// @nodoc
class __$ThemeColorsSelectorStateCopyWithImpl<$Res>
    implements _$ThemeColorsSelectorStateCopyWith<$Res> {
  __$ThemeColorsSelectorStateCopyWithImpl(this._self, this._then);

  final _ThemeColorsSelectorState _self;
  final $Res Function(_ThemeColorsSelectorState) _then;

/// Create a copy of ThemeColorsSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primaryColor = freezed,Object? primaryColors = null,Object? schemeVariant = null,Object? isDefault = null,}) {
  return _then(_ThemeColorsSelectorState(
primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as int?,primaryColors: null == primaryColors ? _self._primaryColors : primaryColors // ignore: cast_nullable_to_non_nullable
as List<int>,schemeVariant: null == schemeVariant ? _self.schemeVariant : schemeVariant // ignore: cast_nullable_to_non_nullable
as DynamicSchemeVariant,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SystemProxySelectorState {

 bool get systemProxy; List<String> get bypassDomain;
/// Create a copy of SystemProxySelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemProxySelectorStateCopyWith<SystemProxySelectorState> get copyWith => _$SystemProxySelectorStateCopyWithImpl<SystemProxySelectorState>(this as SystemProxySelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemProxySelectorState&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other.bypassDomain, bypassDomain));
}


@override
int get hashCode => Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(bypassDomain));

@override
String toString() {
  return 'SystemProxySelectorState(systemProxy: $systemProxy, bypassDomain: $bypassDomain)';
}


}

/// @nodoc
abstract mixin class $SystemProxySelectorStateCopyWith<$Res>  {
  factory $SystemProxySelectorStateCopyWith(SystemProxySelectorState value, $Res Function(SystemProxySelectorState) _then) = _$SystemProxySelectorStateCopyWithImpl;
@useResult
$Res call({
 bool systemProxy, List<String> bypassDomain
});




}
/// @nodoc
class _$SystemProxySelectorStateCopyWithImpl<$Res>
    implements $SystemProxySelectorStateCopyWith<$Res> {
  _$SystemProxySelectorStateCopyWithImpl(this._self, this._then);

  final SystemProxySelectorState _self;
  final $Res Function(SystemProxySelectorState) _then;

/// Create a copy of SystemProxySelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? systemProxy = null,Object? bypassDomain = null,}) {
  return _then(_self.copyWith(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self.bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemProxySelectorState].
extension SystemProxySelectorStatePatterns on SystemProxySelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemProxySelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemProxySelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemProxySelectorState value)  $default,){
final _that = this;
switch (_that) {
case _SystemProxySelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemProxySelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _SystemProxySelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemProxySelectorState() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool systemProxy,  List<String> bypassDomain)  $default,) {final _that = this;
switch (_that) {
case _SystemProxySelectorState():
return $default(_that.systemProxy,_that.bypassDomain);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool systemProxy,  List<String> bypassDomain)?  $default,) {final _that = this;
switch (_that) {
case _SystemProxySelectorState() when $default != null:
return $default(_that.systemProxy,_that.bypassDomain);case _:
  return null;

}
}

}

/// @nodoc


class _SystemProxySelectorState implements SystemProxySelectorState {
  const _SystemProxySelectorState({required this.systemProxy, required final  List<String> bypassDomain}): _bypassDomain = bypassDomain;
  

@override final  bool systemProxy;
 final  List<String> _bypassDomain;
@override List<String> get bypassDomain {
  if (_bypassDomain is EqualUnmodifiableListView) return _bypassDomain;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bypassDomain);
}


/// Create a copy of SystemProxySelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemProxySelectorStateCopyWith<_SystemProxySelectorState> get copyWith => __$SystemProxySelectorStateCopyWithImpl<_SystemProxySelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemProxySelectorState&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&const DeepCollectionEquality().equals(other._bypassDomain, _bypassDomain));
}


@override
int get hashCode => Object.hash(runtimeType,systemProxy,const DeepCollectionEquality().hash(_bypassDomain));

@override
String toString() {
  return 'SystemProxySelectorState(systemProxy: $systemProxy, bypassDomain: $bypassDomain)';
}


}

/// @nodoc
abstract mixin class _$SystemProxySelectorStateCopyWith<$Res> implements $SystemProxySelectorStateCopyWith<$Res> {
  factory _$SystemProxySelectorStateCopyWith(_SystemProxySelectorState value, $Res Function(_SystemProxySelectorState) _then) = __$SystemProxySelectorStateCopyWithImpl;
@override @useResult
$Res call({
 bool systemProxy, List<String> bypassDomain
});




}
/// @nodoc
class __$SystemProxySelectorStateCopyWithImpl<$Res>
    implements _$SystemProxySelectorStateCopyWith<$Res> {
  __$SystemProxySelectorStateCopyWithImpl(this._self, this._then);

  final _SystemProxySelectorState _self;
  final $Res Function(_SystemProxySelectorState) _then;

/// Create a copy of SystemProxySelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? systemProxy = null,Object? bypassDomain = null,}) {
  return _then(_SystemProxySelectorState(
systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,bypassDomain: null == bypassDomain ? _self._bypassDomain : bypassDomain // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
mixin _$CurrentProfileSelectorState {

 String get label; Map<String, String> get selectedMap;
/// Create a copy of CurrentProfileSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrentProfileSelectorStateCopyWith<CurrentProfileSelectorState> get copyWith => _$CurrentProfileSelectorStateCopyWithImpl<CurrentProfileSelectorState>(this as CurrentProfileSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrentProfileSelectorState&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap));
}


@override
int get hashCode => Object.hash(runtimeType,label,const DeepCollectionEquality().hash(selectedMap));

@override
String toString() {
  return 'CurrentProfileSelectorState(label: $label, selectedMap: $selectedMap)';
}


}

/// @nodoc
abstract mixin class $CurrentProfileSelectorStateCopyWith<$Res>  {
  factory $CurrentProfileSelectorStateCopyWith(CurrentProfileSelectorState value, $Res Function(CurrentProfileSelectorState) _then) = _$CurrentProfileSelectorStateCopyWithImpl;
@useResult
$Res call({
 String label, Map<String, String> selectedMap
});




}
/// @nodoc
class _$CurrentProfileSelectorStateCopyWithImpl<$Res>
    implements $CurrentProfileSelectorStateCopyWith<$Res> {
  _$CurrentProfileSelectorStateCopyWithImpl(this._self, this._then);

  final CurrentProfileSelectorState _self;
  final $Res Function(CurrentProfileSelectorState) _then;

/// Create a copy of CurrentProfileSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? selectedMap = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CurrentProfileSelectorState].
extension CurrentProfileSelectorStatePatterns on CurrentProfileSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrentProfileSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrentProfileSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrentProfileSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _CurrentProfileSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrentProfileSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _CurrentProfileSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  Map<String, String> selectedMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrentProfileSelectorState() when $default != null:
return $default(_that.label,_that.selectedMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  Map<String, String> selectedMap)  $default,) {final _that = this;
switch (_that) {
case _CurrentProfileSelectorState():
return $default(_that.label,_that.selectedMap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  Map<String, String> selectedMap)?  $default,) {final _that = this;
switch (_that) {
case _CurrentProfileSelectorState() when $default != null:
return $default(_that.label,_that.selectedMap);case _:
  return null;

}
}

}

/// @nodoc


class _CurrentProfileSelectorState implements CurrentProfileSelectorState {
  const _CurrentProfileSelectorState({required this.label, required final  Map<String, String> selectedMap}): _selectedMap = selectedMap;
  

@override final  String label;
 final  Map<String, String> _selectedMap;
@override Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}


/// Create a copy of CurrentProfileSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrentProfileSelectorStateCopyWith<_CurrentProfileSelectorState> get copyWith => __$CurrentProfileSelectorStateCopyWithImpl<_CurrentProfileSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrentProfileSelectorState&&(identical(other.label, label) || other.label == label)&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap));
}


@override
int get hashCode => Object.hash(runtimeType,label,const DeepCollectionEquality().hash(_selectedMap));

@override
String toString() {
  return 'CurrentProfileSelectorState(label: $label, selectedMap: $selectedMap)';
}


}

/// @nodoc
abstract mixin class _$CurrentProfileSelectorStateCopyWith<$Res> implements $CurrentProfileSelectorStateCopyWith<$Res> {
  factory _$CurrentProfileSelectorStateCopyWith(_CurrentProfileSelectorState value, $Res Function(_CurrentProfileSelectorState) _then) = __$CurrentProfileSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 String label, Map<String, String> selectedMap
});




}
/// @nodoc
class __$CurrentProfileSelectorStateCopyWithImpl<$Res>
    implements _$CurrentProfileSelectorStateCopyWith<$Res> {
  __$CurrentProfileSelectorStateCopyWithImpl(this._self, this._then);

  final _CurrentProfileSelectorState _self;
  final $Res Function(_CurrentProfileSelectorState) _then;

/// Create a copy of CurrentProfileSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? selectedMap = null,}) {
  return _then(_CurrentProfileSelectorState(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$DashboardState {

 List<DashboardWidget> get dashboardWidgets;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&const DeepCollectionEquality().equals(other.dashboardWidgets, dashboardWidgets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dashboardWidgets));

@override
String toString() {
  return 'DashboardState(dashboardWidgets: $dashboardWidgets)';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 List<DashboardWidget> dashboardWidgets
});




}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dashboardWidgets = null,}) {
  return _then(_self.copyWith(
dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DashboardWidget> dashboardWidgets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.dashboardWidgets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DashboardWidget> dashboardWidgets)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.dashboardWidgets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DashboardWidget> dashboardWidgets)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.dashboardWidgets);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({required final  List<DashboardWidget> dashboardWidgets}): _dashboardWidgets = dashboardWidgets;
  

 final  List<DashboardWidget> _dashboardWidgets;
@override List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}


/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&const DeepCollectionEquality().equals(other._dashboardWidgets, _dashboardWidgets));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dashboardWidgets));

@override
String toString() {
  return 'DashboardState(dashboardWidgets: $dashboardWidgets)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 List<DashboardWidget> dashboardWidgets
});




}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dashboardWidgets = null,}) {
  return _then(_DashboardState(
dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,
  ));
}


}

/// @nodoc
mixin _$SelectedProxyState {

 String get proxyName; bool get group; String? get testUrl;
/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SelectedProxyStateCopyWith<SelectedProxyState> get copyWith => _$SelectedProxyStateCopyWithImpl<SelectedProxyState>(this as SelectedProxyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SelectedProxyState&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&(identical(other.group, group) || other.group == group)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}


@override
int get hashCode => Object.hash(runtimeType,proxyName,group,testUrl);

@override
String toString() {
  return 'SelectedProxyState(proxyName: $proxyName, group: $group, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class $SelectedProxyStateCopyWith<$Res>  {
  factory $SelectedProxyStateCopyWith(SelectedProxyState value, $Res Function(SelectedProxyState) _then) = _$SelectedProxyStateCopyWithImpl;
@useResult
$Res call({
 String proxyName, bool group, String? testUrl
});




}
/// @nodoc
class _$SelectedProxyStateCopyWithImpl<$Res>
    implements $SelectedProxyStateCopyWith<$Res> {
  _$SelectedProxyStateCopyWithImpl(this._self, this._then);

  final SelectedProxyState _self;
  final $Res Function(SelectedProxyState) _then;

/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxyName = null,Object? group = null,Object? testUrl = freezed,}) {
  return _then(_self.copyWith(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SelectedProxyState].
extension SelectedProxyStatePatterns on SelectedProxyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SelectedProxyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SelectedProxyState value)  $default,){
final _that = this;
switch (_that) {
case _SelectedProxyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SelectedProxyState value)?  $default,){
final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String proxyName,  bool group,  String? testUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
return $default(_that.proxyName,_that.group,_that.testUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String proxyName,  bool group,  String? testUrl)  $default,) {final _that = this;
switch (_that) {
case _SelectedProxyState():
return $default(_that.proxyName,_that.group,_that.testUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String proxyName,  bool group,  String? testUrl)?  $default,) {final _that = this;
switch (_that) {
case _SelectedProxyState() when $default != null:
return $default(_that.proxyName,_that.group,_that.testUrl);case _:
  return null;

}
}

}

/// @nodoc


class _SelectedProxyState implements SelectedProxyState {
  const _SelectedProxyState({required this.proxyName, this.group = false, this.testUrl});
  

@override final  String proxyName;
@override@JsonKey() final  bool group;
@override final  String? testUrl;

/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SelectedProxyStateCopyWith<_SelectedProxyState> get copyWith => __$SelectedProxyStateCopyWithImpl<_SelectedProxyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SelectedProxyState&&(identical(other.proxyName, proxyName) || other.proxyName == proxyName)&&(identical(other.group, group) || other.group == group)&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl));
}


@override
int get hashCode => Object.hash(runtimeType,proxyName,group,testUrl);

@override
String toString() {
  return 'SelectedProxyState(proxyName: $proxyName, group: $group, testUrl: $testUrl)';
}


}

/// @nodoc
abstract mixin class _$SelectedProxyStateCopyWith<$Res> implements $SelectedProxyStateCopyWith<$Res> {
  factory _$SelectedProxyStateCopyWith(_SelectedProxyState value, $Res Function(_SelectedProxyState) _then) = __$SelectedProxyStateCopyWithImpl;
@override @useResult
$Res call({
 String proxyName, bool group, String? testUrl
});




}
/// @nodoc
class __$SelectedProxyStateCopyWithImpl<$Res>
    implements _$SelectedProxyStateCopyWith<$Res> {
  __$SelectedProxyStateCopyWithImpl(this._self, this._then);

  final _SelectedProxyState _self;
  final $Res Function(_SelectedProxyState) _then;

/// Create a copy of SelectedProxyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxyName = null,Object? group = null,Object? testUrl = freezed,}) {
  return _then(_SelectedProxyState(
proxyName: null == proxyName ? _self.proxyName : proxyName // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as bool,testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$VpnState {

 TunStack get stack; VpnProps get vpnProps;
/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VpnStateCopyWith<VpnState> get copyWith => _$VpnStateCopyWithImpl<VpnState>(this as VpnState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VpnState&&(identical(other.stack, stack) || other.stack == stack)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps));
}


@override
int get hashCode => Object.hash(runtimeType,stack,vpnProps);

@override
String toString() {
  return 'VpnState(stack: $stack, vpnProps: $vpnProps)';
}


}

/// @nodoc
abstract mixin class $VpnStateCopyWith<$Res>  {
  factory $VpnStateCopyWith(VpnState value, $Res Function(VpnState) _then) = _$VpnStateCopyWithImpl;
@useResult
$Res call({
 TunStack stack, VpnProps vpnProps
});


$VpnPropsCopyWith<$Res> get vpnProps;

}
/// @nodoc
class _$VpnStateCopyWithImpl<$Res>
    implements $VpnStateCopyWith<$Res> {
  _$VpnStateCopyWithImpl(this._self, this._then);

  final VpnState _self;
  final $Res Function(VpnState) _then;

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stack = null,Object? vpnProps = null,}) {
  return _then(_self.copyWith(
stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,
  ));
}
/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}
}


/// Adds pattern-matching-related methods to [VpnState].
extension VpnStatePatterns on VpnState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VpnState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VpnState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VpnState value)  $default,){
final _that = this;
switch (_that) {
case _VpnState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VpnState value)?  $default,){
final _that = this;
switch (_that) {
case _VpnState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TunStack stack,  VpnProps vpnProps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VpnState() when $default != null:
return $default(_that.stack,_that.vpnProps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TunStack stack,  VpnProps vpnProps)  $default,) {final _that = this;
switch (_that) {
case _VpnState():
return $default(_that.stack,_that.vpnProps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TunStack stack,  VpnProps vpnProps)?  $default,) {final _that = this;
switch (_that) {
case _VpnState() when $default != null:
return $default(_that.stack,_that.vpnProps);case _:
  return null;

}
}

}

/// @nodoc


class _VpnState implements VpnState {
  const _VpnState({required this.stack, required this.vpnProps});
  

@override final  TunStack stack;
@override final  VpnProps vpnProps;

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VpnStateCopyWith<_VpnState> get copyWith => __$VpnStateCopyWithImpl<_VpnState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VpnState&&(identical(other.stack, stack) || other.stack == stack)&&(identical(other.vpnProps, vpnProps) || other.vpnProps == vpnProps));
}


@override
int get hashCode => Object.hash(runtimeType,stack,vpnProps);

@override
String toString() {
  return 'VpnState(stack: $stack, vpnProps: $vpnProps)';
}


}

/// @nodoc
abstract mixin class _$VpnStateCopyWith<$Res> implements $VpnStateCopyWith<$Res> {
  factory _$VpnStateCopyWith(_VpnState value, $Res Function(_VpnState) _then) = __$VpnStateCopyWithImpl;
@override @useResult
$Res call({
 TunStack stack, VpnProps vpnProps
});


@override $VpnPropsCopyWith<$Res> get vpnProps;

}
/// @nodoc
class __$VpnStateCopyWithImpl<$Res>
    implements _$VpnStateCopyWith<$Res> {
  __$VpnStateCopyWithImpl(this._self, this._then);

  final _VpnState _self;
  final $Res Function(_VpnState) _then;

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stack = null,Object? vpnProps = null,}) {
  return _then(_VpnState(
stack: null == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as TunStack,vpnProps: null == vpnProps ? _self.vpnProps : vpnProps // ignore: cast_nullable_to_non_nullable
as VpnProps,
  ));
}

/// Create a copy of VpnState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnPropsCopyWith<$Res> get vpnProps {
  
  return $VpnPropsCopyWith<$Res>(_self.vpnProps, (value) {
    return _then(_self.copyWith(vpnProps: value));
  });
}
}


/// @nodoc
mixin _$SharedState {

 SetupParams? get setupParams; VpnOptions? get vpnOptions; String get stopTip; String get startTip; String get currentProfileName; String get stopText; bool get onlyStatisticsProxy; bool get crashlytics;
/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedStateCopyWith<SharedState> get copyWith => _$SharedStateCopyWithImpl<SharedState>(this as SharedState, _$identity);

  /// Serializes this SharedState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedState&&(identical(other.setupParams, setupParams) || other.setupParams == setupParams)&&(identical(other.vpnOptions, vpnOptions) || other.vpnOptions == vpnOptions)&&(identical(other.stopTip, stopTip) || other.stopTip == stopTip)&&(identical(other.startTip, startTip) || other.startTip == startTip)&&(identical(other.currentProfileName, currentProfileName) || other.currentProfileName == currentProfileName)&&(identical(other.stopText, stopText) || other.stopText == stopText)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setupParams,vpnOptions,stopTip,startTip,currentProfileName,stopText,onlyStatisticsProxy,crashlytics);

@override
String toString() {
  return 'SharedState(setupParams: $setupParams, vpnOptions: $vpnOptions, stopTip: $stopTip, startTip: $startTip, currentProfileName: $currentProfileName, stopText: $stopText, onlyStatisticsProxy: $onlyStatisticsProxy, crashlytics: $crashlytics)';
}


}

/// @nodoc
abstract mixin class $SharedStateCopyWith<$Res>  {
  factory $SharedStateCopyWith(SharedState value, $Res Function(SharedState) _then) = _$SharedStateCopyWithImpl;
@useResult
$Res call({
 SetupParams? setupParams, VpnOptions? vpnOptions, String stopTip, String startTip, String currentProfileName, String stopText, bool onlyStatisticsProxy, bool crashlytics
});


$SetupParamsCopyWith<$Res>? get setupParams;$VpnOptionsCopyWith<$Res>? get vpnOptions;

}
/// @nodoc
class _$SharedStateCopyWithImpl<$Res>
    implements $SharedStateCopyWith<$Res> {
  _$SharedStateCopyWithImpl(this._self, this._then);

  final SharedState _self;
  final $Res Function(SharedState) _then;

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? setupParams = freezed,Object? vpnOptions = freezed,Object? stopTip = null,Object? startTip = null,Object? currentProfileName = null,Object? stopText = null,Object? onlyStatisticsProxy = null,Object? crashlytics = null,}) {
  return _then(_self.copyWith(
setupParams: freezed == setupParams ? _self.setupParams : setupParams // ignore: cast_nullable_to_non_nullable
as SetupParams?,vpnOptions: freezed == vpnOptions ? _self.vpnOptions : vpnOptions // ignore: cast_nullable_to_non_nullable
as VpnOptions?,stopTip: null == stopTip ? _self.stopTip : stopTip // ignore: cast_nullable_to_non_nullable
as String,startTip: null == startTip ? _self.startTip : startTip // ignore: cast_nullable_to_non_nullable
as String,currentProfileName: null == currentProfileName ? _self.currentProfileName : currentProfileName // ignore: cast_nullable_to_non_nullable
as String,stopText: null == stopText ? _self.stopText : stopText // ignore: cast_nullable_to_non_nullable
as String,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SetupParamsCopyWith<$Res>? get setupParams {
    if (_self.setupParams == null) {
    return null;
  }

  return $SetupParamsCopyWith<$Res>(_self.setupParams!, (value) {
    return _then(_self.copyWith(setupParams: value));
  });
}/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<$Res>? get vpnOptions {
    if (_self.vpnOptions == null) {
    return null;
  }

  return $VpnOptionsCopyWith<$Res>(_self.vpnOptions!, (value) {
    return _then(_self.copyWith(vpnOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [SharedState].
extension SharedStatePatterns on SharedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedState value)  $default,){
final _that = this;
switch (_that) {
case _SharedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedState value)?  $default,){
final _that = this;
switch (_that) {
case _SharedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SetupParams? setupParams,  VpnOptions? vpnOptions,  String stopTip,  String startTip,  String currentProfileName,  String stopText,  bool onlyStatisticsProxy,  bool crashlytics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedState() when $default != null:
return $default(_that.setupParams,_that.vpnOptions,_that.stopTip,_that.startTip,_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy,_that.crashlytics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SetupParams? setupParams,  VpnOptions? vpnOptions,  String stopTip,  String startTip,  String currentProfileName,  String stopText,  bool onlyStatisticsProxy,  bool crashlytics)  $default,) {final _that = this;
switch (_that) {
case _SharedState():
return $default(_that.setupParams,_that.vpnOptions,_that.stopTip,_that.startTip,_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy,_that.crashlytics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SetupParams? setupParams,  VpnOptions? vpnOptions,  String stopTip,  String startTip,  String currentProfileName,  String stopText,  bool onlyStatisticsProxy,  bool crashlytics)?  $default,) {final _that = this;
switch (_that) {
case _SharedState() when $default != null:
return $default(_that.setupParams,_that.vpnOptions,_that.stopTip,_that.startTip,_that.currentProfileName,_that.stopText,_that.onlyStatisticsProxy,_that.crashlytics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SharedState implements SharedState {
  const _SharedState({this.setupParams, this.vpnOptions, required this.stopTip, required this.startTip, required this.currentProfileName, required this.stopText, required this.onlyStatisticsProxy, required this.crashlytics});
  factory _SharedState.fromJson(Map<String, dynamic> json) => _$SharedStateFromJson(json);

@override final  SetupParams? setupParams;
@override final  VpnOptions? vpnOptions;
@override final  String stopTip;
@override final  String startTip;
@override final  String currentProfileName;
@override final  String stopText;
@override final  bool onlyStatisticsProxy;
@override final  bool crashlytics;

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedStateCopyWith<_SharedState> get copyWith => __$SharedStateCopyWithImpl<_SharedState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SharedStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedState&&(identical(other.setupParams, setupParams) || other.setupParams == setupParams)&&(identical(other.vpnOptions, vpnOptions) || other.vpnOptions == vpnOptions)&&(identical(other.stopTip, stopTip) || other.stopTip == stopTip)&&(identical(other.startTip, startTip) || other.startTip == startTip)&&(identical(other.currentProfileName, currentProfileName) || other.currentProfileName == currentProfileName)&&(identical(other.stopText, stopText) || other.stopText == stopText)&&(identical(other.onlyStatisticsProxy, onlyStatisticsProxy) || other.onlyStatisticsProxy == onlyStatisticsProxy)&&(identical(other.crashlytics, crashlytics) || other.crashlytics == crashlytics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,setupParams,vpnOptions,stopTip,startTip,currentProfileName,stopText,onlyStatisticsProxy,crashlytics);

@override
String toString() {
  return 'SharedState(setupParams: $setupParams, vpnOptions: $vpnOptions, stopTip: $stopTip, startTip: $startTip, currentProfileName: $currentProfileName, stopText: $stopText, onlyStatisticsProxy: $onlyStatisticsProxy, crashlytics: $crashlytics)';
}


}

/// @nodoc
abstract mixin class _$SharedStateCopyWith<$Res> implements $SharedStateCopyWith<$Res> {
  factory _$SharedStateCopyWith(_SharedState value, $Res Function(_SharedState) _then) = __$SharedStateCopyWithImpl;
@override @useResult
$Res call({
 SetupParams? setupParams, VpnOptions? vpnOptions, String stopTip, String startTip, String currentProfileName, String stopText, bool onlyStatisticsProxy, bool crashlytics
});


@override $SetupParamsCopyWith<$Res>? get setupParams;@override $VpnOptionsCopyWith<$Res>? get vpnOptions;

}
/// @nodoc
class __$SharedStateCopyWithImpl<$Res>
    implements _$SharedStateCopyWith<$Res> {
  __$SharedStateCopyWithImpl(this._self, this._then);

  final _SharedState _self;
  final $Res Function(_SharedState) _then;

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? setupParams = freezed,Object? vpnOptions = freezed,Object? stopTip = null,Object? startTip = null,Object? currentProfileName = null,Object? stopText = null,Object? onlyStatisticsProxy = null,Object? crashlytics = null,}) {
  return _then(_SharedState(
setupParams: freezed == setupParams ? _self.setupParams : setupParams // ignore: cast_nullable_to_non_nullable
as SetupParams?,vpnOptions: freezed == vpnOptions ? _self.vpnOptions : vpnOptions // ignore: cast_nullable_to_non_nullable
as VpnOptions?,stopTip: null == stopTip ? _self.stopTip : stopTip // ignore: cast_nullable_to_non_nullable
as String,startTip: null == startTip ? _self.startTip : startTip // ignore: cast_nullable_to_non_nullable
as String,currentProfileName: null == currentProfileName ? _self.currentProfileName : currentProfileName // ignore: cast_nullable_to_non_nullable
as String,stopText: null == stopText ? _self.stopText : stopText // ignore: cast_nullable_to_non_nullable
as String,onlyStatisticsProxy: null == onlyStatisticsProxy ? _self.onlyStatisticsProxy : onlyStatisticsProxy // ignore: cast_nullable_to_non_nullable
as bool,crashlytics: null == crashlytics ? _self.crashlytics : crashlytics // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SetupParamsCopyWith<$Res>? get setupParams {
    if (_self.setupParams == null) {
    return null;
  }

  return $SetupParamsCopyWith<$Res>(_self.setupParams!, (value) {
    return _then(_self.copyWith(setupParams: value));
  });
}/// Create a copy of SharedState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VpnOptionsCopyWith<$Res>? get vpnOptions {
    if (_self.vpnOptions == null) {
    return null;
  }

  return $VpnOptionsCopyWith<$Res>(_self.vpnOptions!, (value) {
    return _then(_self.copyWith(vpnOptions: value));
  });
}
}

/// @nodoc
mixin _$ComputeGroupsState {

 ProxiesData get proxiesData; ProxiesSortType get sortType; DelayMap get delayMap; Map<String, String> get selectedMap; String get defaultTestUrl;
/// Create a copy of ComputeGroupsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComputeGroupsStateCopyWith<ComputeGroupsState> get copyWith => _$ComputeGroupsStateCopyWithImpl<ComputeGroupsState>(this as ComputeGroupsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComputeGroupsState&&(identical(other.proxiesData, proxiesData) || other.proxiesData == proxiesData)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&const DeepCollectionEquality().equals(other.delayMap, delayMap)&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap)&&(identical(other.defaultTestUrl, defaultTestUrl) || other.defaultTestUrl == defaultTestUrl));
}


@override
int get hashCode => Object.hash(runtimeType,proxiesData,sortType,const DeepCollectionEquality().hash(delayMap),const DeepCollectionEquality().hash(selectedMap),defaultTestUrl);

@override
String toString() {
  return 'ComputeGroupsState(proxiesData: $proxiesData, sortType: $sortType, delayMap: $delayMap, selectedMap: $selectedMap, defaultTestUrl: $defaultTestUrl)';
}


}

/// @nodoc
abstract mixin class $ComputeGroupsStateCopyWith<$Res>  {
  factory $ComputeGroupsStateCopyWith(ComputeGroupsState value, $Res Function(ComputeGroupsState) _then) = _$ComputeGroupsStateCopyWithImpl;
@useResult
$Res call({
 ProxiesData proxiesData, ProxiesSortType sortType, DelayMap delayMap, Map<String, String> selectedMap, String defaultTestUrl
});


$ProxiesDataCopyWith<$Res> get proxiesData;

}
/// @nodoc
class _$ComputeGroupsStateCopyWithImpl<$Res>
    implements $ComputeGroupsStateCopyWith<$Res> {
  _$ComputeGroupsStateCopyWithImpl(this._self, this._then);

  final ComputeGroupsState _self;
  final $Res Function(ComputeGroupsState) _then;

/// Create a copy of ComputeGroupsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? proxiesData = null,Object? sortType = null,Object? delayMap = null,Object? selectedMap = null,Object? defaultTestUrl = null,}) {
  return _then(_self.copyWith(
proxiesData: null == proxiesData ? _self.proxiesData : proxiesData // ignore: cast_nullable_to_non_nullable
as ProxiesData,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,delayMap: null == delayMap ? _self.delayMap : delayMap // ignore: cast_nullable_to_non_nullable
as DelayMap,selectedMap: null == selectedMap ? _self.selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,defaultTestUrl: null == defaultTestUrl ? _self.defaultTestUrl : defaultTestUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ComputeGroupsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesDataCopyWith<$Res> get proxiesData {
  
  return $ProxiesDataCopyWith<$Res>(_self.proxiesData, (value) {
    return _then(_self.copyWith(proxiesData: value));
  });
}
}


/// Adds pattern-matching-related methods to [ComputeGroupsState].
extension ComputeGroupsStatePatterns on ComputeGroupsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComputeGroupsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComputeGroupsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComputeGroupsState value)  $default,){
final _that = this;
switch (_that) {
case _ComputeGroupsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComputeGroupsState value)?  $default,){
final _that = this;
switch (_that) {
case _ComputeGroupsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ProxiesData proxiesData,  ProxiesSortType sortType,  DelayMap delayMap,  Map<String, String> selectedMap,  String defaultTestUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComputeGroupsState() when $default != null:
return $default(_that.proxiesData,_that.sortType,_that.delayMap,_that.selectedMap,_that.defaultTestUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ProxiesData proxiesData,  ProxiesSortType sortType,  DelayMap delayMap,  Map<String, String> selectedMap,  String defaultTestUrl)  $default,) {final _that = this;
switch (_that) {
case _ComputeGroupsState():
return $default(_that.proxiesData,_that.sortType,_that.delayMap,_that.selectedMap,_that.defaultTestUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ProxiesData proxiesData,  ProxiesSortType sortType,  DelayMap delayMap,  Map<String, String> selectedMap,  String defaultTestUrl)?  $default,) {final _that = this;
switch (_that) {
case _ComputeGroupsState() when $default != null:
return $default(_that.proxiesData,_that.sortType,_that.delayMap,_that.selectedMap,_that.defaultTestUrl);case _:
  return null;

}
}

}

/// @nodoc


class _ComputeGroupsState implements ComputeGroupsState {
  const _ComputeGroupsState({required this.proxiesData, required this.sortType, required final  DelayMap delayMap, required final  Map<String, String> selectedMap, required this.defaultTestUrl}): _delayMap = delayMap,_selectedMap = selectedMap;
  

@override final  ProxiesData proxiesData;
@override final  ProxiesSortType sortType;
 final  DelayMap _delayMap;
@override DelayMap get delayMap {
  if (_delayMap is EqualUnmodifiableMapView) return _delayMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_delayMap);
}

 final  Map<String, String> _selectedMap;
@override Map<String, String> get selectedMap {
  if (_selectedMap is EqualUnmodifiableMapView) return _selectedMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedMap);
}

@override final  String defaultTestUrl;

/// Create a copy of ComputeGroupsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComputeGroupsStateCopyWith<_ComputeGroupsState> get copyWith => __$ComputeGroupsStateCopyWithImpl<_ComputeGroupsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComputeGroupsState&&(identical(other.proxiesData, proxiesData) || other.proxiesData == proxiesData)&&(identical(other.sortType, sortType) || other.sortType == sortType)&&const DeepCollectionEquality().equals(other._delayMap, _delayMap)&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap)&&(identical(other.defaultTestUrl, defaultTestUrl) || other.defaultTestUrl == defaultTestUrl));
}


@override
int get hashCode => Object.hash(runtimeType,proxiesData,sortType,const DeepCollectionEquality().hash(_delayMap),const DeepCollectionEquality().hash(_selectedMap),defaultTestUrl);

@override
String toString() {
  return 'ComputeGroupsState(proxiesData: $proxiesData, sortType: $sortType, delayMap: $delayMap, selectedMap: $selectedMap, defaultTestUrl: $defaultTestUrl)';
}


}

/// @nodoc
abstract mixin class _$ComputeGroupsStateCopyWith<$Res> implements $ComputeGroupsStateCopyWith<$Res> {
  factory _$ComputeGroupsStateCopyWith(_ComputeGroupsState value, $Res Function(_ComputeGroupsState) _then) = __$ComputeGroupsStateCopyWithImpl;
@override @useResult
$Res call({
 ProxiesData proxiesData, ProxiesSortType sortType, DelayMap delayMap, Map<String, String> selectedMap, String defaultTestUrl
});


@override $ProxiesDataCopyWith<$Res> get proxiesData;

}
/// @nodoc
class __$ComputeGroupsStateCopyWithImpl<$Res>
    implements _$ComputeGroupsStateCopyWith<$Res> {
  __$ComputeGroupsStateCopyWithImpl(this._self, this._then);

  final _ComputeGroupsState _self;
  final $Res Function(_ComputeGroupsState) _then;

/// Create a copy of ComputeGroupsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? proxiesData = null,Object? sortType = null,Object? delayMap = null,Object? selectedMap = null,Object? defaultTestUrl = null,}) {
  return _then(_ComputeGroupsState(
proxiesData: null == proxiesData ? _self.proxiesData : proxiesData // ignore: cast_nullable_to_non_nullable
as ProxiesData,sortType: null == sortType ? _self.sortType : sortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,delayMap: null == delayMap ? _self._delayMap : delayMap // ignore: cast_nullable_to_non_nullable
as DelayMap,selectedMap: null == selectedMap ? _self._selectedMap : selectedMap // ignore: cast_nullable_to_non_nullable
as Map<String, String>,defaultTestUrl: null == defaultTestUrl ? _self.defaultTestUrl : defaultTestUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ComputeGroupsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProxiesDataCopyWith<$Res> get proxiesData {
  
  return $ProxiesDataCopyWith<$Res>(_self.proxiesData, (value) {
    return _then(_self.copyWith(proxiesData: value));
  });
}
}

/// @nodoc
mixin _$MakeRealProfileState {

 String get profilesPath; int get profileId; Map<String, dynamic> get rawConfig; PatchClashConfig get realPatchConfig; bool get overrideDns; bool get appendSystemDns; List<ProxyGroup> get proxyGroups; List<Rule> get rules; List<Rule> get addedRules; String get defaultUA; List<TailscaleProxy> get tailscaleProxies; List<String> get tailscaleRules; List<String> get tailscaleFakeIpFilters;
/// Create a copy of MakeRealProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MakeRealProfileStateCopyWith<MakeRealProfileState> get copyWith => _$MakeRealProfileStateCopyWithImpl<MakeRealProfileState>(this as MakeRealProfileState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MakeRealProfileState&&(identical(other.profilesPath, profilesPath) || other.profilesPath == profilesPath)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&const DeepCollectionEquality().equals(other.rawConfig, rawConfig)&&(identical(other.realPatchConfig, realPatchConfig) || other.realPatchConfig == realPatchConfig)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.appendSystemDns, appendSystemDns) || other.appendSystemDns == appendSystemDns)&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.addedRules, addedRules)&&(identical(other.defaultUA, defaultUA) || other.defaultUA == defaultUA)&&const DeepCollectionEquality().equals(other.tailscaleProxies, tailscaleProxies)&&const DeepCollectionEquality().equals(other.tailscaleRules, tailscaleRules)&&const DeepCollectionEquality().equals(other.tailscaleFakeIpFilters, tailscaleFakeIpFilters));
}


@override
int get hashCode => Object.hash(runtimeType,profilesPath,profileId,const DeepCollectionEquality().hash(rawConfig),realPatchConfig,overrideDns,appendSystemDns,const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(addedRules),defaultUA,const DeepCollectionEquality().hash(tailscaleProxies),const DeepCollectionEquality().hash(tailscaleRules),const DeepCollectionEquality().hash(tailscaleFakeIpFilters));

@override
String toString() {
  return 'MakeRealProfileState(profilesPath: $profilesPath, profileId: $profileId, rawConfig: $rawConfig, realPatchConfig: $realPatchConfig, overrideDns: $overrideDns, appendSystemDns: $appendSystemDns, proxyGroups: $proxyGroups, rules: $rules, addedRules: $addedRules, defaultUA: $defaultUA, tailscaleProxies: $tailscaleProxies, tailscaleRules: $tailscaleRules, tailscaleFakeIpFilters: $tailscaleFakeIpFilters)';
}


}

/// @nodoc
abstract mixin class $MakeRealProfileStateCopyWith<$Res>  {
  factory $MakeRealProfileStateCopyWith(MakeRealProfileState value, $Res Function(MakeRealProfileState) _then) = _$MakeRealProfileStateCopyWithImpl;
@useResult
$Res call({
 String profilesPath, int profileId, Map<String, dynamic> rawConfig, PatchClashConfig realPatchConfig, bool overrideDns, bool appendSystemDns, List<ProxyGroup> proxyGroups, List<Rule> rules, List<Rule> addedRules, String defaultUA, List<TailscaleProxy> tailscaleProxies, List<String> tailscaleRules, List<String> tailscaleFakeIpFilters
});


$PatchClashConfigCopyWith<$Res> get realPatchConfig;

}
/// @nodoc
class _$MakeRealProfileStateCopyWithImpl<$Res>
    implements $MakeRealProfileStateCopyWith<$Res> {
  _$MakeRealProfileStateCopyWithImpl(this._self, this._then);

  final MakeRealProfileState _self;
  final $Res Function(MakeRealProfileState) _then;

/// Create a copy of MakeRealProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profilesPath = null,Object? profileId = null,Object? rawConfig = null,Object? realPatchConfig = null,Object? overrideDns = null,Object? appendSystemDns = null,Object? proxyGroups = null,Object? rules = null,Object? addedRules = null,Object? defaultUA = null,Object? tailscaleProxies = null,Object? tailscaleRules = null,Object? tailscaleFakeIpFilters = null,}) {
  return _then(_self.copyWith(
profilesPath: null == profilesPath ? _self.profilesPath : profilesPath // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int,rawConfig: null == rawConfig ? _self.rawConfig : rawConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,realPatchConfig: null == realPatchConfig ? _self.realPatchConfig : realPatchConfig // ignore: cast_nullable_to_non_nullable
as PatchClashConfig,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,defaultUA: null == defaultUA ? _self.defaultUA : defaultUA // ignore: cast_nullable_to_non_nullable
as String,tailscaleProxies: null == tailscaleProxies ? _self.tailscaleProxies : tailscaleProxies // ignore: cast_nullable_to_non_nullable
as List<TailscaleProxy>,tailscaleRules: null == tailscaleRules ? _self.tailscaleRules : tailscaleRules // ignore: cast_nullable_to_non_nullable
as List<String>,tailscaleFakeIpFilters: null == tailscaleFakeIpFilters ? _self.tailscaleFakeIpFilters : tailscaleFakeIpFilters // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of MakeRealProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<$Res> get realPatchConfig {
  
  return $PatchClashConfigCopyWith<$Res>(_self.realPatchConfig, (value) {
    return _then(_self.copyWith(realPatchConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [MakeRealProfileState].
extension MakeRealProfileStatePatterns on MakeRealProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MakeRealProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MakeRealProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MakeRealProfileState value)  $default,){
final _that = this;
switch (_that) {
case _MakeRealProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MakeRealProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _MakeRealProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String profilesPath,  int profileId,  Map<String, dynamic> rawConfig,  PatchClashConfig realPatchConfig,  bool overrideDns,  bool appendSystemDns,  List<ProxyGroup> proxyGroups,  List<Rule> rules,  List<Rule> addedRules,  String defaultUA,  List<TailscaleProxy> tailscaleProxies,  List<String> tailscaleRules,  List<String> tailscaleFakeIpFilters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MakeRealProfileState() when $default != null:
return $default(_that.profilesPath,_that.profileId,_that.rawConfig,_that.realPatchConfig,_that.overrideDns,_that.appendSystemDns,_that.proxyGroups,_that.rules,_that.addedRules,_that.defaultUA,_that.tailscaleProxies,_that.tailscaleRules,_that.tailscaleFakeIpFilters);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String profilesPath,  int profileId,  Map<String, dynamic> rawConfig,  PatchClashConfig realPatchConfig,  bool overrideDns,  bool appendSystemDns,  List<ProxyGroup> proxyGroups,  List<Rule> rules,  List<Rule> addedRules,  String defaultUA,  List<TailscaleProxy> tailscaleProxies,  List<String> tailscaleRules,  List<String> tailscaleFakeIpFilters)  $default,) {final _that = this;
switch (_that) {
case _MakeRealProfileState():
return $default(_that.profilesPath,_that.profileId,_that.rawConfig,_that.realPatchConfig,_that.overrideDns,_that.appendSystemDns,_that.proxyGroups,_that.rules,_that.addedRules,_that.defaultUA,_that.tailscaleProxies,_that.tailscaleRules,_that.tailscaleFakeIpFilters);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String profilesPath,  int profileId,  Map<String, dynamic> rawConfig,  PatchClashConfig realPatchConfig,  bool overrideDns,  bool appendSystemDns,  List<ProxyGroup> proxyGroups,  List<Rule> rules,  List<Rule> addedRules,  String defaultUA,  List<TailscaleProxy> tailscaleProxies,  List<String> tailscaleRules,  List<String> tailscaleFakeIpFilters)?  $default,) {final _that = this;
switch (_that) {
case _MakeRealProfileState() when $default != null:
return $default(_that.profilesPath,_that.profileId,_that.rawConfig,_that.realPatchConfig,_that.overrideDns,_that.appendSystemDns,_that.proxyGroups,_that.rules,_that.addedRules,_that.defaultUA,_that.tailscaleProxies,_that.tailscaleRules,_that.tailscaleFakeIpFilters);case _:
  return null;

}
}

}

/// @nodoc


class _MakeRealProfileState implements MakeRealProfileState {
  const _MakeRealProfileState({required this.profilesPath, required this.profileId, required final  Map<String, dynamic> rawConfig, required this.realPatchConfig, required this.overrideDns, required this.appendSystemDns, required final  List<ProxyGroup> proxyGroups, required final  List<Rule> rules, required final  List<Rule> addedRules, required this.defaultUA, final  List<TailscaleProxy> tailscaleProxies = const [], final  List<String> tailscaleRules = const [], final  List<String> tailscaleFakeIpFilters = const []}): _rawConfig = rawConfig,_proxyGroups = proxyGroups,_rules = rules,_addedRules = addedRules,_tailscaleProxies = tailscaleProxies,_tailscaleRules = tailscaleRules,_tailscaleFakeIpFilters = tailscaleFakeIpFilters;
  

@override final  String profilesPath;
@override final  int profileId;
 final  Map<String, dynamic> _rawConfig;
@override Map<String, dynamic> get rawConfig {
  if (_rawConfig is EqualUnmodifiableMapView) return _rawConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawConfig);
}

@override final  PatchClashConfig realPatchConfig;
@override final  bool overrideDns;
@override final  bool appendSystemDns;
 final  List<ProxyGroup> _proxyGroups;
@override List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<Rule> _rules;
@override List<Rule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<Rule> _addedRules;
@override List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

@override final  String defaultUA;
 final  List<TailscaleProxy> _tailscaleProxies;
@override@JsonKey() List<TailscaleProxy> get tailscaleProxies {
  if (_tailscaleProxies is EqualUnmodifiableListView) return _tailscaleProxies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tailscaleProxies);
}

 final  List<String> _tailscaleRules;
@override@JsonKey() List<String> get tailscaleRules {
  if (_tailscaleRules is EqualUnmodifiableListView) return _tailscaleRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tailscaleRules);
}

 final  List<String> _tailscaleFakeIpFilters;
@override@JsonKey() List<String> get tailscaleFakeIpFilters {
  if (_tailscaleFakeIpFilters is EqualUnmodifiableListView) return _tailscaleFakeIpFilters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tailscaleFakeIpFilters);
}


/// Create a copy of MakeRealProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MakeRealProfileStateCopyWith<_MakeRealProfileState> get copyWith => __$MakeRealProfileStateCopyWithImpl<_MakeRealProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MakeRealProfileState&&(identical(other.profilesPath, profilesPath) || other.profilesPath == profilesPath)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&const DeepCollectionEquality().equals(other._rawConfig, _rawConfig)&&(identical(other.realPatchConfig, realPatchConfig) || other.realPatchConfig == realPatchConfig)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.appendSystemDns, appendSystemDns) || other.appendSystemDns == appendSystemDns)&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._addedRules, _addedRules)&&(identical(other.defaultUA, defaultUA) || other.defaultUA == defaultUA)&&const DeepCollectionEquality().equals(other._tailscaleProxies, _tailscaleProxies)&&const DeepCollectionEquality().equals(other._tailscaleRules, _tailscaleRules)&&const DeepCollectionEquality().equals(other._tailscaleFakeIpFilters, _tailscaleFakeIpFilters));
}


@override
int get hashCode => Object.hash(runtimeType,profilesPath,profileId,const DeepCollectionEquality().hash(_rawConfig),realPatchConfig,overrideDns,appendSystemDns,const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_addedRules),defaultUA,const DeepCollectionEquality().hash(_tailscaleProxies),const DeepCollectionEquality().hash(_tailscaleRules),const DeepCollectionEquality().hash(_tailscaleFakeIpFilters));

@override
String toString() {
  return 'MakeRealProfileState(profilesPath: $profilesPath, profileId: $profileId, rawConfig: $rawConfig, realPatchConfig: $realPatchConfig, overrideDns: $overrideDns, appendSystemDns: $appendSystemDns, proxyGroups: $proxyGroups, rules: $rules, addedRules: $addedRules, defaultUA: $defaultUA, tailscaleProxies: $tailscaleProxies, tailscaleRules: $tailscaleRules, tailscaleFakeIpFilters: $tailscaleFakeIpFilters)';
}


}

/// @nodoc
abstract mixin class _$MakeRealProfileStateCopyWith<$Res> implements $MakeRealProfileStateCopyWith<$Res> {
  factory _$MakeRealProfileStateCopyWith(_MakeRealProfileState value, $Res Function(_MakeRealProfileState) _then) = __$MakeRealProfileStateCopyWithImpl;
@override @useResult
$Res call({
 String profilesPath, int profileId, Map<String, dynamic> rawConfig, PatchClashConfig realPatchConfig, bool overrideDns, bool appendSystemDns, List<ProxyGroup> proxyGroups, List<Rule> rules, List<Rule> addedRules, String defaultUA, List<TailscaleProxy> tailscaleProxies, List<String> tailscaleRules, List<String> tailscaleFakeIpFilters
});


@override $PatchClashConfigCopyWith<$Res> get realPatchConfig;

}
/// @nodoc
class __$MakeRealProfileStateCopyWithImpl<$Res>
    implements _$MakeRealProfileStateCopyWith<$Res> {
  __$MakeRealProfileStateCopyWithImpl(this._self, this._then);

  final _MakeRealProfileState _self;
  final $Res Function(_MakeRealProfileState) _then;

/// Create a copy of MakeRealProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profilesPath = null,Object? profileId = null,Object? rawConfig = null,Object? realPatchConfig = null,Object? overrideDns = null,Object? appendSystemDns = null,Object? proxyGroups = null,Object? rules = null,Object? addedRules = null,Object? defaultUA = null,Object? tailscaleProxies = null,Object? tailscaleRules = null,Object? tailscaleFakeIpFilters = null,}) {
  return _then(_MakeRealProfileState(
profilesPath: null == profilesPath ? _self.profilesPath : profilesPath // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int,rawConfig: null == rawConfig ? _self._rawConfig : rawConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,realPatchConfig: null == realPatchConfig ? _self.realPatchConfig : realPatchConfig // ignore: cast_nullable_to_non_nullable
as PatchClashConfig,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,appendSystemDns: null == appendSystemDns ? _self.appendSystemDns : appendSystemDns // ignore: cast_nullable_to_non_nullable
as bool,proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,defaultUA: null == defaultUA ? _self.defaultUA : defaultUA // ignore: cast_nullable_to_non_nullable
as String,tailscaleProxies: null == tailscaleProxies ? _self._tailscaleProxies : tailscaleProxies // ignore: cast_nullable_to_non_nullable
as List<TailscaleProxy>,tailscaleRules: null == tailscaleRules ? _self._tailscaleRules : tailscaleRules // ignore: cast_nullable_to_non_nullable
as List<String>,tailscaleFakeIpFilters: null == tailscaleFakeIpFilters ? _self._tailscaleFakeIpFilters : tailscaleFakeIpFilters // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of MakeRealProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PatchClashConfigCopyWith<$Res> get realPatchConfig {
  
  return $PatchClashConfigCopyWith<$Res>(_self.realPatchConfig, (value) {
    return _then(_self.copyWith(realPatchConfig: value));
  });
}
}

/// @nodoc
mixin _$MigrationData {

 Map<String, Object?>? get configMap; List<Rule> get rules; List<Script> get scripts; List<Profile> get profiles; List<ProfileRuleLink> get links; List<ProxyGroup> get proxyGroups;
/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MigrationDataCopyWith<MigrationData> get copyWith => _$MigrationDataCopyWithImpl<MigrationData>(this as MigrationData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MigrationData&&const DeepCollectionEquality().equals(other.configMap, configMap)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.scripts, scripts)&&const DeepCollectionEquality().equals(other.profiles, profiles)&&const DeepCollectionEquality().equals(other.links, links)&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(configMap),const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(scripts),const DeepCollectionEquality().hash(profiles),const DeepCollectionEquality().hash(links),const DeepCollectionEquality().hash(proxyGroups));

@override
String toString() {
  return 'MigrationData(configMap: $configMap, rules: $rules, scripts: $scripts, profiles: $profiles, links: $links, proxyGroups: $proxyGroups)';
}


}

/// @nodoc
abstract mixin class $MigrationDataCopyWith<$Res>  {
  factory $MigrationDataCopyWith(MigrationData value, $Res Function(MigrationData) _then) = _$MigrationDataCopyWithImpl;
@useResult
$Res call({
 Map<String, Object?>? configMap, List<Rule> rules, List<Script> scripts, List<Profile> profiles, List<ProfileRuleLink> links, List<ProxyGroup> proxyGroups
});




}
/// @nodoc
class _$MigrationDataCopyWithImpl<$Res>
    implements $MigrationDataCopyWith<$Res> {
  _$MigrationDataCopyWithImpl(this._self, this._then);

  final MigrationData _self;
  final $Res Function(MigrationData) _then;

/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? configMap = freezed,Object? rules = null,Object? scripts = null,Object? profiles = null,Object? links = null,Object? proxyGroups = null,}) {
  return _then(_self.copyWith(
configMap: freezed == configMap ? _self.configMap : configMap // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,scripts: null == scripts ? _self.scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileRuleLink>,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [MigrationData].
extension MigrationDataPatterns on MigrationData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MigrationData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MigrationData value)  $default,){
final _that = this;
switch (_that) {
case _MigrationData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MigrationData value)?  $default,){
final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, Object?>? configMap,  List<Rule> rules,  List<Script> scripts,  List<Profile> profiles,  List<ProfileRuleLink> links,  List<ProxyGroup> proxyGroups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
return $default(_that.configMap,_that.rules,_that.scripts,_that.profiles,_that.links,_that.proxyGroups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, Object?>? configMap,  List<Rule> rules,  List<Script> scripts,  List<Profile> profiles,  List<ProfileRuleLink> links,  List<ProxyGroup> proxyGroups)  $default,) {final _that = this;
switch (_that) {
case _MigrationData():
return $default(_that.configMap,_that.rules,_that.scripts,_that.profiles,_that.links,_that.proxyGroups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, Object?>? configMap,  List<Rule> rules,  List<Script> scripts,  List<Profile> profiles,  List<ProfileRuleLink> links,  List<ProxyGroup> proxyGroups)?  $default,) {final _that = this;
switch (_that) {
case _MigrationData() when $default != null:
return $default(_that.configMap,_that.rules,_that.scripts,_that.profiles,_that.links,_that.proxyGroups);case _:
  return null;

}
}

}

/// @nodoc


class _MigrationData implements MigrationData {
  const _MigrationData({final  Map<String, Object?>? configMap, final  List<Rule> rules = const [], final  List<Script> scripts = const [], final  List<Profile> profiles = const [], final  List<ProfileRuleLink> links = const [], final  List<ProxyGroup> proxyGroups = const []}): _configMap = configMap,_rules = rules,_scripts = scripts,_profiles = profiles,_links = links,_proxyGroups = proxyGroups;
  

 final  Map<String, Object?>? _configMap;
@override Map<String, Object?>? get configMap {
  final value = _configMap;
  if (value == null) return null;
  if (_configMap is EqualUnmodifiableMapView) return _configMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<Rule> _rules;
@override@JsonKey() List<Rule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<Script> _scripts;
@override@JsonKey() List<Script> get scripts {
  if (_scripts is EqualUnmodifiableListView) return _scripts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scripts);
}

 final  List<Profile> _profiles;
@override@JsonKey() List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

 final  List<ProfileRuleLink> _links;
@override@JsonKey() List<ProfileRuleLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

 final  List<ProxyGroup> _proxyGroups;
@override@JsonKey() List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}


/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MigrationDataCopyWith<_MigrationData> get copyWith => __$MigrationDataCopyWithImpl<_MigrationData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MigrationData&&const DeepCollectionEquality().equals(other._configMap, _configMap)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._scripts, _scripts)&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&const DeepCollectionEquality().equals(other._links, _links)&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_configMap),const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_scripts),const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_links),const DeepCollectionEquality().hash(_proxyGroups));

@override
String toString() {
  return 'MigrationData(configMap: $configMap, rules: $rules, scripts: $scripts, profiles: $profiles, links: $links, proxyGroups: $proxyGroups)';
}


}

/// @nodoc
abstract mixin class _$MigrationDataCopyWith<$Res> implements $MigrationDataCopyWith<$Res> {
  factory _$MigrationDataCopyWith(_MigrationData value, $Res Function(_MigrationData) _then) = __$MigrationDataCopyWithImpl;
@override @useResult
$Res call({
 Map<String, Object?>? configMap, List<Rule> rules, List<Script> scripts, List<Profile> profiles, List<ProfileRuleLink> links, List<ProxyGroup> proxyGroups
});




}
/// @nodoc
class __$MigrationDataCopyWithImpl<$Res>
    implements _$MigrationDataCopyWith<$Res> {
  __$MigrationDataCopyWithImpl(this._self, this._then);

  final _MigrationData _self;
  final $Res Function(_MigrationData) _then;

/// Create a copy of MigrationData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? configMap = freezed,Object? rules = null,Object? scripts = null,Object? profiles = null,Object? links = null,Object? proxyGroups = null,}) {
  return _then(_MigrationData(
configMap: freezed == configMap ? _self._configMap : configMap // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,scripts: null == scripts ? _self._scripts : scripts // ignore: cast_nullable_to_non_nullable
as List<Script>,profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileRuleLink>,proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,
  ));
}


}

/// @nodoc
mixin _$SetupState {

 int? get profileId; int? get profileLastUpdateDate; OverwriteType get overwriteType; List<Rule> get rules; List<ProxyGroup> get proxyGroups; List<Rule> get addedRules; Script? get script; bool get overrideDns; Dns get dns;
/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupStateCopyWith<SetupState> get copyWith => _$SetupStateCopyWithImpl<SetupState>(this as SetupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupState&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileLastUpdateDate, profileLastUpdateDate) || other.profileLastUpdateDate == profileLastUpdateDate)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&const DeepCollectionEquality().equals(other.rules, rules)&&const DeepCollectionEquality().equals(other.proxyGroups, proxyGroups)&&const DeepCollectionEquality().equals(other.addedRules, addedRules)&&(identical(other.script, script) || other.script == script)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dns, dns) || other.dns == dns));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,profileLastUpdateDate,overwriteType,const DeepCollectionEquality().hash(rules),const DeepCollectionEquality().hash(proxyGroups),const DeepCollectionEquality().hash(addedRules),script,overrideDns,dns);

@override
String toString() {
  return 'SetupState(profileId: $profileId, profileLastUpdateDate: $profileLastUpdateDate, overwriteType: $overwriteType, rules: $rules, proxyGroups: $proxyGroups, addedRules: $addedRules, script: $script, overrideDns: $overrideDns, dns: $dns)';
}


}

/// @nodoc
abstract mixin class $SetupStateCopyWith<$Res>  {
  factory $SetupStateCopyWith(SetupState value, $Res Function(SetupState) _then) = _$SetupStateCopyWithImpl;
@useResult
$Res call({
 int? profileId, int? profileLastUpdateDate, OverwriteType overwriteType, List<Rule> rules, List<ProxyGroup> proxyGroups, List<Rule> addedRules, Script? script, bool overrideDns, Dns dns
});


$ScriptCopyWith<$Res>? get script;$DnsCopyWith<$Res> get dns;

}
/// @nodoc
class _$SetupStateCopyWithImpl<$Res>
    implements $SetupStateCopyWith<$Res> {
  _$SetupStateCopyWithImpl(this._self, this._then);

  final SetupState _self;
  final $Res Function(SetupState) _then;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? profileLastUpdateDate = freezed,Object? overwriteType = null,Object? rules = null,Object? proxyGroups = null,Object? addedRules = null,Object? script = freezed,Object? overrideDns = null,Object? dns = null,}) {
  return _then(_self.copyWith(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileLastUpdateDate: freezed == profileLastUpdateDate ? _self.profileLastUpdateDate : profileLastUpdateDate // ignore: cast_nullable_to_non_nullable
as int?,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,rules: null == rules ? _self.rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,proxyGroups: null == proxyGroups ? _self.proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as Script?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,
  ));
}
/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptCopyWith<$Res>? get script {
    if (_self.script == null) {
    return null;
  }

  return $ScriptCopyWith<$Res>(_self.script!, (value) {
    return _then(_self.copyWith(script: value));
  });
}/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}
}


/// Adds pattern-matching-related methods to [SetupState].
extension SetupStatePatterns on SetupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SetupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SetupState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SetupState value)  $default,){
final _that = this;
switch (_that) {
case _SetupState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SetupState value)?  $default,){
final _that = this;
switch (_that) {
case _SetupState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> rules,  List<ProxyGroup> proxyGroups,  List<Rule> addedRules,  Script? script,  bool overrideDns,  Dns dns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupState() when $default != null:
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.rules,_that.proxyGroups,_that.addedRules,_that.script,_that.overrideDns,_that.dns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> rules,  List<ProxyGroup> proxyGroups,  List<Rule> addedRules,  Script? script,  bool overrideDns,  Dns dns)  $default,) {final _that = this;
switch (_that) {
case _SetupState():
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.rules,_that.proxyGroups,_that.addedRules,_that.script,_that.overrideDns,_that.dns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> rules,  List<ProxyGroup> proxyGroups,  List<Rule> addedRules,  Script? script,  bool overrideDns,  Dns dns)?  $default,) {final _that = this;
switch (_that) {
case _SetupState() when $default != null:
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.rules,_that.proxyGroups,_that.addedRules,_that.script,_that.overrideDns,_that.dns);case _:
  return null;

}
}

}

/// @nodoc


class _SetupState implements SetupState {
  const _SetupState({required this.profileId, required this.profileLastUpdateDate, required this.overwriteType, required final  List<Rule> rules, required final  List<ProxyGroup> proxyGroups, required final  List<Rule> addedRules, required this.script, required this.overrideDns, required this.dns}): _rules = rules,_proxyGroups = proxyGroups,_addedRules = addedRules;
  

@override final  int? profileId;
@override final  int? profileLastUpdateDate;
@override final  OverwriteType overwriteType;
 final  List<Rule> _rules;
@override List<Rule> get rules {
  if (_rules is EqualUnmodifiableListView) return _rules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rules);
}

 final  List<ProxyGroup> _proxyGroups;
@override List<ProxyGroup> get proxyGroups {
  if (_proxyGroups is EqualUnmodifiableListView) return _proxyGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_proxyGroups);
}

 final  List<Rule> _addedRules;
@override List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

@override final  Script? script;
@override final  bool overrideDns;
@override final  Dns dns;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupStateCopyWith<_SetupState> get copyWith => __$SetupStateCopyWithImpl<_SetupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupState&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileLastUpdateDate, profileLastUpdateDate) || other.profileLastUpdateDate == profileLastUpdateDate)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&const DeepCollectionEquality().equals(other._rules, _rules)&&const DeepCollectionEquality().equals(other._proxyGroups, _proxyGroups)&&const DeepCollectionEquality().equals(other._addedRules, _addedRules)&&(identical(other.script, script) || other.script == script)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dns, dns) || other.dns == dns));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,profileLastUpdateDate,overwriteType,const DeepCollectionEquality().hash(_rules),const DeepCollectionEquality().hash(_proxyGroups),const DeepCollectionEquality().hash(_addedRules),script,overrideDns,dns);

@override
String toString() {
  return 'SetupState(profileId: $profileId, profileLastUpdateDate: $profileLastUpdateDate, overwriteType: $overwriteType, rules: $rules, proxyGroups: $proxyGroups, addedRules: $addedRules, script: $script, overrideDns: $overrideDns, dns: $dns)';
}


}

/// @nodoc
abstract mixin class _$SetupStateCopyWith<$Res> implements $SetupStateCopyWith<$Res> {
  factory _$SetupStateCopyWith(_SetupState value, $Res Function(_SetupState) _then) = __$SetupStateCopyWithImpl;
@override @useResult
$Res call({
 int? profileId, int? profileLastUpdateDate, OverwriteType overwriteType, List<Rule> rules, List<ProxyGroup> proxyGroups, List<Rule> addedRules, Script? script, bool overrideDns, Dns dns
});


@override $ScriptCopyWith<$Res>? get script;@override $DnsCopyWith<$Res> get dns;

}
/// @nodoc
class __$SetupStateCopyWithImpl<$Res>
    implements _$SetupStateCopyWith<$Res> {
  __$SetupStateCopyWithImpl(this._self, this._then);

  final _SetupState _self;
  final $Res Function(_SetupState) _then;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? profileLastUpdateDate = freezed,Object? overwriteType = null,Object? rules = null,Object? proxyGroups = null,Object? addedRules = null,Object? script = freezed,Object? overrideDns = null,Object? dns = null,}) {
  return _then(_SetupState(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as int?,profileLastUpdateDate: freezed == profileLastUpdateDate ? _self.profileLastUpdateDate : profileLastUpdateDate // ignore: cast_nullable_to_non_nullable
as int?,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,rules: null == rules ? _self._rules : rules // ignore: cast_nullable_to_non_nullable
as List<Rule>,proxyGroups: null == proxyGroups ? _self._proxyGroups : proxyGroups // ignore: cast_nullable_to_non_nullable
as List<ProxyGroup>,addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,script: freezed == script ? _self.script : script // ignore: cast_nullable_to_non_nullable
as Script?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,
  ));
}

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScriptCopyWith<$Res>? get script {
    if (_self.script == null) {
    return null;
  }

  return $ScriptCopyWith<$Res>(_self.script!, (value) {
    return _then(_self.copyWith(script: value));
  });
}/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DnsCopyWith<$Res> get dns {
  
  return $DnsCopyWith<$Res>(_self.dns, (value) {
    return _then(_self.copyWith(dns: value));
  });
}
}

// dart format on

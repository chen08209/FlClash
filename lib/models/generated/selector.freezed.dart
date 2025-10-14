// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../selector.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VM2<A,B> {

 A get a; B get b;
/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VM2CopyWith<A, B, VM2<A, B>> get copyWith => _$VM2CopyWithImpl<A, B, VM2<A, B>>(this as VM2<A, B>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VM2<A, B>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b));

@override
String toString() {
  return 'VM2<$A, $B>(a: $a, b: $b)';
}


}

/// @nodoc
abstract mixin class $VM2CopyWith<A,B,$Res>  {
  factory $VM2CopyWith(VM2<A, B> value, $Res Function(VM2<A, B>) _then) = _$VM2CopyWithImpl;
@useResult
$Res call({
 A a, B b
});




}
/// @nodoc
class _$VM2CopyWithImpl<A,B,$Res>
    implements $VM2CopyWith<A, B, $Res> {
  _$VM2CopyWithImpl(this._self, this._then);

  final VM2<A, B> _self;
  final $Res Function(VM2<A, B>) _then;

/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = freezed,Object? b = freezed,}) {
  return _then(_self.copyWith(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,
  ));
}

}


/// Adds pattern-matching-related methods to [VM2].
extension VM2Patterns<A,B> on VM2<A, B> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VM2<A, B> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VM2() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VM2<A, B> value)  $default,){
final _that = this;
switch (_that) {
case _VM2():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VM2<A, B> value)?  $default,){
final _that = this;
switch (_that) {
case _VM2() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( A a,  B b)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VM2() when $default != null:
return $default(_that.a,_that.b);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( A a,  B b)  $default,) {final _that = this;
switch (_that) {
case _VM2():
return $default(_that.a,_that.b);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( A a,  B b)?  $default,) {final _that = this;
switch (_that) {
case _VM2() when $default != null:
return $default(_that.a,_that.b);case _:
  return null;

}
}

}

/// @nodoc


class _VM2<A,B> implements VM2<A, B> {
  const _VM2({required this.a, required this.b});
  

@override final  A a;
@override final  B b;

/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VM2CopyWith<A, B, _VM2<A, B>> get copyWith => __$VM2CopyWithImpl<A, B, _VM2<A, B>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VM2<A, B>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b));

@override
String toString() {
  return 'VM2<$A, $B>(a: $a, b: $b)';
}


}

/// @nodoc
abstract mixin class _$VM2CopyWith<A,B,$Res> implements $VM2CopyWith<A, B, $Res> {
  factory _$VM2CopyWith(_VM2<A, B> value, $Res Function(_VM2<A, B>) _then) = __$VM2CopyWithImpl;
@override @useResult
$Res call({
 A a, B b
});




}
/// @nodoc
class __$VM2CopyWithImpl<A,B,$Res>
    implements _$VM2CopyWith<A, B, $Res> {
  __$VM2CopyWithImpl(this._self, this._then);

  final _VM2<A, B> _self;
  final $Res Function(_VM2<A, B>) _then;

/// Create a copy of VM2
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = freezed,Object? b = freezed,}) {
  return _then(_VM2<A, B>(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,
  ));
}


}

/// @nodoc
mixin _$VM3<A,B,C> {

 A get a; B get b; C get c;
/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VM3CopyWith<A, B, C, VM3<A, B, C>> get copyWith => _$VM3CopyWithImpl<A, B, C, VM3<A, B, C>>(this as VM3<A, B, C>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VM3<A, B, C>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c));

@override
String toString() {
  return 'VM3<$A, $B, $C>(a: $a, b: $b, c: $c)';
}


}

/// @nodoc
abstract mixin class $VM3CopyWith<A,B,C,$Res>  {
  factory $VM3CopyWith(VM3<A, B, C> value, $Res Function(VM3<A, B, C>) _then) = _$VM3CopyWithImpl;
@useResult
$Res call({
 A a, B b, C c
});




}
/// @nodoc
class _$VM3CopyWithImpl<A,B,C,$Res>
    implements $VM3CopyWith<A, B, C, $Res> {
  _$VM3CopyWithImpl(this._self, this._then);

  final VM3<A, B, C> _self;
  final $Res Function(VM3<A, B, C>) _then;

/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,}) {
  return _then(_self.copyWith(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,
  ));
}

}


/// Adds pattern-matching-related methods to [VM3].
extension VM3Patterns<A,B,C> on VM3<A, B, C> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VM3<A, B, C> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VM3() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VM3<A, B, C> value)  $default,){
final _that = this;
switch (_that) {
case _VM3():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VM3<A, B, C> value)?  $default,){
final _that = this;
switch (_that) {
case _VM3() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( A a,  B b,  C c)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VM3() when $default != null:
return $default(_that.a,_that.b,_that.c);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( A a,  B b,  C c)  $default,) {final _that = this;
switch (_that) {
case _VM3():
return $default(_that.a,_that.b,_that.c);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( A a,  B b,  C c)?  $default,) {final _that = this;
switch (_that) {
case _VM3() when $default != null:
return $default(_that.a,_that.b,_that.c);case _:
  return null;

}
}

}

/// @nodoc


class _VM3<A,B,C> implements VM3<A, B, C> {
  const _VM3({required this.a, required this.b, required this.c});
  

@override final  A a;
@override final  B b;
@override final  C c;

/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VM3CopyWith<A, B, C, _VM3<A, B, C>> get copyWith => __$VM3CopyWithImpl<A, B, C, _VM3<A, B, C>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VM3<A, B, C>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c));

@override
String toString() {
  return 'VM3<$A, $B, $C>(a: $a, b: $b, c: $c)';
}


}

/// @nodoc
abstract mixin class _$VM3CopyWith<A,B,C,$Res> implements $VM3CopyWith<A, B, C, $Res> {
  factory _$VM3CopyWith(_VM3<A, B, C> value, $Res Function(_VM3<A, B, C>) _then) = __$VM3CopyWithImpl;
@override @useResult
$Res call({
 A a, B b, C c
});




}
/// @nodoc
class __$VM3CopyWithImpl<A,B,C,$Res>
    implements _$VM3CopyWith<A, B, C, $Res> {
  __$VM3CopyWithImpl(this._self, this._then);

  final _VM3<A, B, C> _self;
  final $Res Function(_VM3<A, B, C>) _then;

/// Create a copy of VM3
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,}) {
  return _then(_VM3<A, B, C>(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,
  ));
}


}

/// @nodoc
mixin _$VM4<A,B,C,D> {

 A get a; B get b; C get c; D get d;
/// Create a copy of VM4
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VM4CopyWith<A, B, C, D, VM4<A, B, C, D>> get copyWith => _$VM4CopyWithImpl<A, B, C, D, VM4<A, B, C, D>>(this as VM4<A, B, C, D>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VM4<A, B, C, D>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c)&&const DeepCollectionEquality().equals(other.d, d));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c),const DeepCollectionEquality().hash(d));

@override
String toString() {
  return 'VM4<$A, $B, $C, $D>(a: $a, b: $b, c: $c, d: $d)';
}


}

/// @nodoc
abstract mixin class $VM4CopyWith<A,B,C,D,$Res>  {
  factory $VM4CopyWith(VM4<A, B, C, D> value, $Res Function(VM4<A, B, C, D>) _then) = _$VM4CopyWithImpl;
@useResult
$Res call({
 A a, B b, C c, D d
});




}
/// @nodoc
class _$VM4CopyWithImpl<A,B,C,D,$Res>
    implements $VM4CopyWith<A, B, C, D, $Res> {
  _$VM4CopyWithImpl(this._self, this._then);

  final VM4<A, B, C, D> _self;
  final $Res Function(VM4<A, B, C, D>) _then;

/// Create a copy of VM4
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,Object? d = freezed,}) {
  return _then(_self.copyWith(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,d: freezed == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as D,
  ));
}

}


/// Adds pattern-matching-related methods to [VM4].
extension VM4Patterns<A,B,C,D> on VM4<A, B, C, D> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VM4<A, B, C, D> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VM4() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VM4<A, B, C, D> value)  $default,){
final _that = this;
switch (_that) {
case _VM4():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VM4<A, B, C, D> value)?  $default,){
final _that = this;
switch (_that) {
case _VM4() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( A a,  B b,  C c,  D d)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VM4() when $default != null:
return $default(_that.a,_that.b,_that.c,_that.d);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( A a,  B b,  C c,  D d)  $default,) {final _that = this;
switch (_that) {
case _VM4():
return $default(_that.a,_that.b,_that.c,_that.d);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( A a,  B b,  C c,  D d)?  $default,) {final _that = this;
switch (_that) {
case _VM4() when $default != null:
return $default(_that.a,_that.b,_that.c,_that.d);case _:
  return null;

}
}

}

/// @nodoc


class _VM4<A,B,C,D> implements VM4<A, B, C, D> {
  const _VM4(this.a, this.b, this.c, this.d);
  

@override final  A a;
@override final  B b;
@override final  C c;
@override final  D d;

/// Create a copy of VM4
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VM4CopyWith<A, B, C, D, _VM4<A, B, C, D>> get copyWith => __$VM4CopyWithImpl<A, B, C, D, _VM4<A, B, C, D>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VM4<A, B, C, D>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c)&&const DeepCollectionEquality().equals(other.d, d));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c),const DeepCollectionEquality().hash(d));

@override
String toString() {
  return 'VM4<$A, $B, $C, $D>(a: $a, b: $b, c: $c, d: $d)';
}


}

/// @nodoc
abstract mixin class _$VM4CopyWith<A,B,C,D,$Res> implements $VM4CopyWith<A, B, C, D, $Res> {
  factory _$VM4CopyWith(_VM4<A, B, C, D> value, $Res Function(_VM4<A, B, C, D>) _then) = __$VM4CopyWithImpl;
@override @useResult
$Res call({
 A a, B b, C c, D d
});




}
/// @nodoc
class __$VM4CopyWithImpl<A,B,C,D,$Res>
    implements _$VM4CopyWith<A, B, C, D, $Res> {
  __$VM4CopyWithImpl(this._self, this._then);

  final _VM4<A, B, C, D> _self;
  final $Res Function(_VM4<A, B, C, D>) _then;

/// Create a copy of VM4
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,Object? d = freezed,}) {
  return _then(_VM4<A, B, C, D>(
freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,freezed == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as D,
  ));
}


}

/// @nodoc
mixin _$VM5<A,B,C,D,E> {

 A get a; B get b; C get c; D get d; E get e;
/// Create a copy of VM5
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VM5CopyWith<A, B, C, D, E, VM5<A, B, C, D, E>> get copyWith => _$VM5CopyWithImpl<A, B, C, D, E, VM5<A, B, C, D, E>>(this as VM5<A, B, C, D, E>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VM5<A, B, C, D, E>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c)&&const DeepCollectionEquality().equals(other.d, d)&&const DeepCollectionEquality().equals(other.e, e));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c),const DeepCollectionEquality().hash(d),const DeepCollectionEquality().hash(e));

@override
String toString() {
  return 'VM5<$A, $B, $C, $D, $E>(a: $a, b: $b, c: $c, d: $d, e: $e)';
}


}

/// @nodoc
abstract mixin class $VM5CopyWith<A,B,C,D,E,$Res>  {
  factory $VM5CopyWith(VM5<A, B, C, D, E> value, $Res Function(VM5<A, B, C, D, E>) _then) = _$VM5CopyWithImpl;
@useResult
$Res call({
 A a, B b, C c, D d, E e
});




}
/// @nodoc
class _$VM5CopyWithImpl<A,B,C,D,E,$Res>
    implements $VM5CopyWith<A, B, C, D, E, $Res> {
  _$VM5CopyWithImpl(this._self, this._then);

  final VM5<A, B, C, D, E> _self;
  final $Res Function(VM5<A, B, C, D, E>) _then;

/// Create a copy of VM5
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,Object? d = freezed,Object? e = freezed,}) {
  return _then(_self.copyWith(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,d: freezed == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as D,e: freezed == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as E,
  ));
}

}


/// Adds pattern-matching-related methods to [VM5].
extension VM5Patterns<A,B,C,D,E> on VM5<A, B, C, D, E> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VM5<A, B, C, D, E> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VM5() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VM5<A, B, C, D, E> value)  $default,){
final _that = this;
switch (_that) {
case _VM5():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VM5<A, B, C, D, E> value)?  $default,){
final _that = this;
switch (_that) {
case _VM5() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( A a,  B b,  C c,  D d,  E e)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VM5() when $default != null:
return $default(_that.a,_that.b,_that.c,_that.d,_that.e);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( A a,  B b,  C c,  D d,  E e)  $default,) {final _that = this;
switch (_that) {
case _VM5():
return $default(_that.a,_that.b,_that.c,_that.d,_that.e);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( A a,  B b,  C c,  D d,  E e)?  $default,) {final _that = this;
switch (_that) {
case _VM5() when $default != null:
return $default(_that.a,_that.b,_that.c,_that.d,_that.e);case _:
  return null;

}
}

}

/// @nodoc


class _VM5<A,B,C,D,E> implements VM5<A, B, C, D, E> {
  const _VM5({required this.a, required this.b, required this.c, required this.d, required this.e});
  

@override final  A a;
@override final  B b;
@override final  C c;
@override final  D d;
@override final  E e;

/// Create a copy of VM5
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VM5CopyWith<A, B, C, D, E, _VM5<A, B, C, D, E>> get copyWith => __$VM5CopyWithImpl<A, B, C, D, E, _VM5<A, B, C, D, E>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VM5<A, B, C, D, E>&&const DeepCollectionEquality().equals(other.a, a)&&const DeepCollectionEquality().equals(other.b, b)&&const DeepCollectionEquality().equals(other.c, c)&&const DeepCollectionEquality().equals(other.d, d)&&const DeepCollectionEquality().equals(other.e, e));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(a),const DeepCollectionEquality().hash(b),const DeepCollectionEquality().hash(c),const DeepCollectionEquality().hash(d),const DeepCollectionEquality().hash(e));

@override
String toString() {
  return 'VM5<$A, $B, $C, $D, $E>(a: $a, b: $b, c: $c, d: $d, e: $e)';
}


}

/// @nodoc
abstract mixin class _$VM5CopyWith<A,B,C,D,E,$Res> implements $VM5CopyWith<A, B, C, D, E, $Res> {
  factory _$VM5CopyWith(_VM5<A, B, C, D, E> value, $Res Function(_VM5<A, B, C, D, E>) _then) = __$VM5CopyWithImpl;
@override @useResult
$Res call({
 A a, B b, C c, D d, E e
});




}
/// @nodoc
class __$VM5CopyWithImpl<A,B,C,D,E,$Res>
    implements _$VM5CopyWith<A, B, C, D, E, $Res> {
  __$VM5CopyWithImpl(this._self, this._then);

  final _VM5<A, B, C, D, E> _self;
  final $Res Function(_VM5<A, B, C, D, E>) _then;

/// Create a copy of VM5
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? a = freezed,Object? b = freezed,Object? c = freezed,Object? d = freezed,Object? e = freezed,}) {
  return _then(_VM5<A, B, C, D, E>(
a: freezed == a ? _self.a : a // ignore: cast_nullable_to_non_nullable
as A,b: freezed == b ? _self.b : b // ignore: cast_nullable_to_non_nullable
as B,c: freezed == c ? _self.c : c // ignore: cast_nullable_to_non_nullable
as C,d: freezed == d ? _self.d : d // ignore: cast_nullable_to_non_nullable
as D,e: freezed == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as E,
  ));
}


}

/// @nodoc
mixin _$StartButtonSelectorState {

 bool get isInit; bool get hasProfile;
/// Create a copy of StartButtonSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartButtonSelectorStateCopyWith<StartButtonSelectorState> get copyWith => _$StartButtonSelectorStateCopyWithImpl<StartButtonSelectorState>(this as StartButtonSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartButtonSelectorState&&(identical(other.isInit, isInit) || other.isInit == isInit)&&(identical(other.hasProfile, hasProfile) || other.hasProfile == hasProfile));
}


@override
int get hashCode => Object.hash(runtimeType,isInit,hasProfile);

@override
String toString() {
  return 'StartButtonSelectorState(isInit: $isInit, hasProfile: $hasProfile)';
}


}

/// @nodoc
abstract mixin class $StartButtonSelectorStateCopyWith<$Res>  {
  factory $StartButtonSelectorStateCopyWith(StartButtonSelectorState value, $Res Function(StartButtonSelectorState) _then) = _$StartButtonSelectorStateCopyWithImpl;
@useResult
$Res call({
 bool isInit, bool hasProfile
});




}
/// @nodoc
class _$StartButtonSelectorStateCopyWithImpl<$Res>
    implements $StartButtonSelectorStateCopyWith<$Res> {
  _$StartButtonSelectorStateCopyWithImpl(this._self, this._then);

  final StartButtonSelectorState _self;
  final $Res Function(StartButtonSelectorState) _then;

/// Create a copy of StartButtonSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isInit = null,Object? hasProfile = null,}) {
  return _then(_self.copyWith(
isInit: null == isInit ? _self.isInit : isInit // ignore: cast_nullable_to_non_nullable
as bool,hasProfile: null == hasProfile ? _self.hasProfile : hasProfile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StartButtonSelectorState].
extension StartButtonSelectorStatePatterns on StartButtonSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StartButtonSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StartButtonSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StartButtonSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _StartButtonSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StartButtonSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _StartButtonSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isInit,  bool hasProfile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StartButtonSelectorState() when $default != null:
return $default(_that.isInit,_that.hasProfile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isInit,  bool hasProfile)  $default,) {final _that = this;
switch (_that) {
case _StartButtonSelectorState():
return $default(_that.isInit,_that.hasProfile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isInit,  bool hasProfile)?  $default,) {final _that = this;
switch (_that) {
case _StartButtonSelectorState() when $default != null:
return $default(_that.isInit,_that.hasProfile);case _:
  return null;

}
}

}

/// @nodoc


class _StartButtonSelectorState implements StartButtonSelectorState {
  const _StartButtonSelectorState({required this.isInit, required this.hasProfile});
  

@override final  bool isInit;
@override final  bool hasProfile;

/// Create a copy of StartButtonSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StartButtonSelectorStateCopyWith<_StartButtonSelectorState> get copyWith => __$StartButtonSelectorStateCopyWithImpl<_StartButtonSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StartButtonSelectorState&&(identical(other.isInit, isInit) || other.isInit == isInit)&&(identical(other.hasProfile, hasProfile) || other.hasProfile == hasProfile));
}


@override
int get hashCode => Object.hash(runtimeType,isInit,hasProfile);

@override
String toString() {
  return 'StartButtonSelectorState(isInit: $isInit, hasProfile: $hasProfile)';
}


}

/// @nodoc
abstract mixin class _$StartButtonSelectorStateCopyWith<$Res> implements $StartButtonSelectorStateCopyWith<$Res> {
  factory _$StartButtonSelectorStateCopyWith(_StartButtonSelectorState value, $Res Function(_StartButtonSelectorState) _then) = __$StartButtonSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 bool isInit, bool hasProfile
});




}
/// @nodoc
class __$StartButtonSelectorStateCopyWithImpl<$Res>
    implements _$StartButtonSelectorStateCopyWith<$Res> {
  __$StartButtonSelectorStateCopyWithImpl(this._self, this._then);

  final _StartButtonSelectorState _self;
  final $Res Function(_StartButtonSelectorState) _then;

/// Create a copy of StartButtonSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isInit = null,Object? hasProfile = null,}) {
  return _then(_StartButtonSelectorState(
isInit: null == isInit ? _self.isInit : isInit // ignore: cast_nullable_to_non_nullable
as bool,hasProfile: null == hasProfile ? _self.hasProfile : hasProfile // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ProfilesSelectorState {

 List<Profile> get profiles; String? get currentProfileId; int get columns;
/// Create a copy of ProfilesSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfilesSelectorStateCopyWith<ProfilesSelectorState> get copyWith => _$ProfilesSelectorStateCopyWithImpl<ProfilesSelectorState>(this as ProfilesSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfilesSelectorState&&const DeepCollectionEquality().equals(other.profiles, profiles)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(profiles),currentProfileId,columns);

@override
String toString() {
  return 'ProfilesSelectorState(profiles: $profiles, currentProfileId: $currentProfileId, columns: $columns)';
}


}

/// @nodoc
abstract mixin class $ProfilesSelectorStateCopyWith<$Res>  {
  factory $ProfilesSelectorStateCopyWith(ProfilesSelectorState value, $Res Function(ProfilesSelectorState) _then) = _$ProfilesSelectorStateCopyWithImpl;
@useResult
$Res call({
 List<Profile> profiles, String? currentProfileId, int columns
});




}
/// @nodoc
class _$ProfilesSelectorStateCopyWithImpl<$Res>
    implements $ProfilesSelectorStateCopyWith<$Res> {
  _$ProfilesSelectorStateCopyWithImpl(this._self, this._then);

  final ProfilesSelectorState _self;
  final $Res Function(ProfilesSelectorState) _then;

/// Create a copy of ProfilesSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profiles = null,Object? currentProfileId = freezed,Object? columns = null,}) {
  return _then(_self.copyWith(
profiles: null == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as String?,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfilesSelectorState].
extension ProfilesSelectorStatePatterns on ProfilesSelectorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfilesSelectorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfilesSelectorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfilesSelectorState value)  $default,){
final _that = this;
switch (_that) {
case _ProfilesSelectorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfilesSelectorState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfilesSelectorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Profile> profiles,  String? currentProfileId,  int columns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfilesSelectorState() when $default != null:
return $default(_that.profiles,_that.currentProfileId,_that.columns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Profile> profiles,  String? currentProfileId,  int columns)  $default,) {final _that = this;
switch (_that) {
case _ProfilesSelectorState():
return $default(_that.profiles,_that.currentProfileId,_that.columns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Profile> profiles,  String? currentProfileId,  int columns)?  $default,) {final _that = this;
switch (_that) {
case _ProfilesSelectorState() when $default != null:
return $default(_that.profiles,_that.currentProfileId,_that.columns);case _:
  return null;

}
}

}

/// @nodoc


class _ProfilesSelectorState implements ProfilesSelectorState {
  const _ProfilesSelectorState({required final  List<Profile> profiles, required this.currentProfileId, required this.columns}): _profiles = profiles;
  

 final  List<Profile> _profiles;
@override List<Profile> get profiles {
  if (_profiles is EqualUnmodifiableListView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profiles);
}

@override final  String? currentProfileId;
@override final  int columns;

/// Create a copy of ProfilesSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfilesSelectorStateCopyWith<_ProfilesSelectorState> get copyWith => __$ProfilesSelectorStateCopyWithImpl<_ProfilesSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfilesSelectorState&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&(identical(other.currentProfileId, currentProfileId) || other.currentProfileId == currentProfileId)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_profiles),currentProfileId,columns);

@override
String toString() {
  return 'ProfilesSelectorState(profiles: $profiles, currentProfileId: $currentProfileId, columns: $columns)';
}


}

/// @nodoc
abstract mixin class _$ProfilesSelectorStateCopyWith<$Res> implements $ProfilesSelectorStateCopyWith<$Res> {
  factory _$ProfilesSelectorStateCopyWith(_ProfilesSelectorState value, $Res Function(_ProfilesSelectorState) _then) = __$ProfilesSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 List<Profile> profiles, String? currentProfileId, int columns
});




}
/// @nodoc
class __$ProfilesSelectorStateCopyWithImpl<$Res>
    implements _$ProfilesSelectorStateCopyWith<$Res> {
  __$ProfilesSelectorStateCopyWithImpl(this._self, this._then);

  final _ProfilesSelectorState _self;
  final $Res Function(_ProfilesSelectorState) _then;

/// Create a copy of ProfilesSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profiles = null,Object? currentProfileId = freezed,Object? columns = null,}) {
  return _then(_ProfilesSelectorState(
profiles: null == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as List<Profile>,currentProfileId: freezed == currentProfileId ? _self.currentProfileId : currentProfileId // ignore: cast_nullable_to_non_nullable
as String?,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
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

 Mode get mode; int get port; bool get autoLaunch; bool get systemProxy; bool get tunEnable; bool get isStart; String? get locale; Brightness? get brightness; List<Group> get groups; Map<String, String> get selectedMap; bool get showTrayTitle;
/// Create a copy of TrayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrayStateCopyWith<TrayState> get copyWith => _$TrayStateCopyWithImpl<TrayState>(this as TrayState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrayState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.port, port) || other.port == port)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.tunEnable, tunEnable) || other.tunEnable == tunEnable)&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.selectedMap, selectedMap)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mode,port,autoLaunch,systemProxy,tunEnable,isStart,locale,brightness,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(selectedMap),showTrayTitle);

@override
String toString() {
  return 'TrayState(mode: $mode, port: $port, autoLaunch: $autoLaunch, systemProxy: $systemProxy, tunEnable: $tunEnable, isStart: $isStart, locale: $locale, brightness: $brightness, groups: $groups, selectedMap: $selectedMap, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class $TrayStateCopyWith<$Res>  {
  factory $TrayStateCopyWith(TrayState value, $Res Function(TrayState) _then) = _$TrayStateCopyWithImpl;
@useResult
$Res call({
 Mode mode, int port, bool autoLaunch, bool systemProxy, bool tunEnable, bool isStart, String? locale, Brightness? brightness, List<Group> groups, Map<String, String> selectedMap, bool showTrayTitle
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
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? port = null,Object? autoLaunch = null,Object? systemProxy = null,Object? tunEnable = null,Object? isStart = null,Object? locale = freezed,Object? brightness = freezed,Object? groups = null,Object? selectedMap = null,Object? showTrayTitle = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,tunEnable: null == tunEnable ? _self.tunEnable : tunEnable // ignore: cast_nullable_to_non_nullable
as bool,isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness?,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  String? locale,  Brightness? brightness,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrayState() when $default != null:
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.locale,_that.brightness,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  String? locale,  Brightness? brightness,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)  $default,) {final _that = this;
switch (_that) {
case _TrayState():
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.locale,_that.brightness,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Mode mode,  int port,  bool autoLaunch,  bool systemProxy,  bool tunEnable,  bool isStart,  String? locale,  Brightness? brightness,  List<Group> groups,  Map<String, String> selectedMap,  bool showTrayTitle)?  $default,) {final _that = this;
switch (_that) {
case _TrayState() when $default != null:
return $default(_that.mode,_that.port,_that.autoLaunch,_that.systemProxy,_that.tunEnable,_that.isStart,_that.locale,_that.brightness,_that.groups,_that.selectedMap,_that.showTrayTitle);case _:
  return null;

}
}

}

/// @nodoc


class _TrayState implements TrayState {
  const _TrayState({required this.mode, required this.port, required this.autoLaunch, required this.systemProxy, required this.tunEnable, required this.isStart, required this.locale, required this.brightness, required final  List<Group> groups, required final  Map<String, String> selectedMap, required this.showTrayTitle}): _groups = groups,_selectedMap = selectedMap;
  

@override final  Mode mode;
@override final  int port;
@override final  bool autoLaunch;
@override final  bool systemProxy;
@override final  bool tunEnable;
@override final  bool isStart;
@override final  String? locale;
@override final  Brightness? brightness;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrayState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.port, port) || other.port == port)&&(identical(other.autoLaunch, autoLaunch) || other.autoLaunch == autoLaunch)&&(identical(other.systemProxy, systemProxy) || other.systemProxy == systemProxy)&&(identical(other.tunEnable, tunEnable) || other.tunEnable == tunEnable)&&(identical(other.isStart, isStart) || other.isStart == isStart)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.brightness, brightness) || other.brightness == brightness)&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._selectedMap, _selectedMap)&&(identical(other.showTrayTitle, showTrayTitle) || other.showTrayTitle == showTrayTitle));
}


@override
int get hashCode => Object.hash(runtimeType,mode,port,autoLaunch,systemProxy,tunEnable,isStart,locale,brightness,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_selectedMap),showTrayTitle);

@override
String toString() {
  return 'TrayState(mode: $mode, port: $port, autoLaunch: $autoLaunch, systemProxy: $systemProxy, tunEnable: $tunEnable, isStart: $isStart, locale: $locale, brightness: $brightness, groups: $groups, selectedMap: $selectedMap, showTrayTitle: $showTrayTitle)';
}


}

/// @nodoc
abstract mixin class _$TrayStateCopyWith<$Res> implements $TrayStateCopyWith<$Res> {
  factory _$TrayStateCopyWith(_TrayState value, $Res Function(_TrayState) _then) = __$TrayStateCopyWithImpl;
@override @useResult
$Res call({
 Mode mode, int port, bool autoLaunch, bool systemProxy, bool tunEnable, bool isStart, String? locale, Brightness? brightness, List<Group> groups, Map<String, String> selectedMap, bool showTrayTitle
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
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? port = null,Object? autoLaunch = null,Object? systemProxy = null,Object? tunEnable = null,Object? isStart = null,Object? locale = freezed,Object? brightness = freezed,Object? groups = null,Object? selectedMap = null,Object? showTrayTitle = null,}) {
  return _then(_TrayState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as Mode,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,autoLaunch: null == autoLaunch ? _self.autoLaunch : autoLaunch // ignore: cast_nullable_to_non_nullable
as bool,systemProxy: null == systemProxy ? _self.systemProxy : systemProxy // ignore: cast_nullable_to_non_nullable
as bool,tunEnable: null == tunEnable ? _self.tunEnable : tunEnable // ignore: cast_nullable_to_non_nullable
as bool,isStart: null == isStart ? _self.isStart : isStart // ignore: cast_nullable_to_non_nullable
as bool,locale: freezed == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String?,brightness: freezed == brightness ? _self.brightness : brightness // ignore: cast_nullable_to_non_nullable
as Brightness?,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
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

 List<Group> get groups; Set<String> get currentUnfoldSet; ProxyCardType get proxyCardType; int get columns;
/// Create a copy of ProxiesListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesListStateCopyWith<ProxiesListState> get copyWith => _$ProxiesListStateCopyWithImpl<ProxiesListState>(this as ProxiesListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesListState&&const DeepCollectionEquality().equals(other.groups, groups)&&const DeepCollectionEquality().equals(other.currentUnfoldSet, currentUnfoldSet)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),const DeepCollectionEquality().hash(currentUnfoldSet),proxyCardType,columns);

@override
String toString() {
  return 'ProxiesListState(groups: $groups, currentUnfoldSet: $currentUnfoldSet, proxyCardType: $proxyCardType, columns: $columns)';
}


}

/// @nodoc
abstract mixin class $ProxiesListStateCopyWith<$Res>  {
  factory $ProxiesListStateCopyWith(ProxiesListState value, $Res Function(ProxiesListState) _then) = _$ProxiesListStateCopyWithImpl;
@useResult
$Res call({
 List<Group> groups, Set<String> currentUnfoldSet, ProxyCardType proxyCardType, int columns
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
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? currentUnfoldSet = null,Object? proxyCardType = null,Object? columns = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentUnfoldSet: null == currentUnfoldSet ? _self.currentUnfoldSet : currentUnfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Group> groups,  Set<String> currentUnfoldSet,  ProxyCardType proxyCardType,  int columns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesListState() when $default != null:
return $default(_that.groups,_that.currentUnfoldSet,_that.proxyCardType,_that.columns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Group> groups,  Set<String> currentUnfoldSet,  ProxyCardType proxyCardType,  int columns)  $default,) {final _that = this;
switch (_that) {
case _ProxiesListState():
return $default(_that.groups,_that.currentUnfoldSet,_that.proxyCardType,_that.columns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Group> groups,  Set<String> currentUnfoldSet,  ProxyCardType proxyCardType,  int columns)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesListState() when $default != null:
return $default(_that.groups,_that.currentUnfoldSet,_that.proxyCardType,_that.columns);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesListState implements ProxiesListState {
  const _ProxiesListState({required final  List<Group> groups, required final  Set<String> currentUnfoldSet, required this.proxyCardType, required this.columns}): _groups = groups,_currentUnfoldSet = currentUnfoldSet;
  

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
@override final  int columns;

/// Create a copy of ProxiesListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesListStateCopyWith<_ProxiesListState> get copyWith => __$ProxiesListStateCopyWithImpl<_ProxiesListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesListState&&const DeepCollectionEquality().equals(other._groups, _groups)&&const DeepCollectionEquality().equals(other._currentUnfoldSet, _currentUnfoldSet)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_currentUnfoldSet),proxyCardType,columns);

@override
String toString() {
  return 'ProxiesListState(groups: $groups, currentUnfoldSet: $currentUnfoldSet, proxyCardType: $proxyCardType, columns: $columns)';
}


}

/// @nodoc
abstract mixin class _$ProxiesListStateCopyWith<$Res> implements $ProxiesListStateCopyWith<$Res> {
  factory _$ProxiesListStateCopyWith(_ProxiesListState value, $Res Function(_ProxiesListState) _then) = __$ProxiesListStateCopyWithImpl;
@override @useResult
$Res call({
 List<Group> groups, Set<String> currentUnfoldSet, ProxyCardType proxyCardType, int columns
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
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? currentUnfoldSet = null,Object? proxyCardType = null,Object? columns = null,}) {
  return _then(_ProxiesListState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentUnfoldSet: null == currentUnfoldSet ? _self._currentUnfoldSet : currentUnfoldSet // ignore: cast_nullable_to_non_nullable
as Set<String>,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ProxiesTabState {

 List<Group> get groups; String? get currentGroupName; ProxyCardType get proxyCardType; int get columns;
/// Create a copy of ProxiesTabState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxiesTabStateCopyWith<ProxiesTabState> get copyWith => _$ProxiesTabStateCopyWithImpl<ProxiesTabState>(this as ProxiesTabState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxiesTabState&&const DeepCollectionEquality().equals(other.groups, groups)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(groups),currentGroupName,proxyCardType,columns);

@override
String toString() {
  return 'ProxiesTabState(groups: $groups, currentGroupName: $currentGroupName, proxyCardType: $proxyCardType, columns: $columns)';
}


}

/// @nodoc
abstract mixin class $ProxiesTabStateCopyWith<$Res>  {
  factory $ProxiesTabStateCopyWith(ProxiesTabState value, $Res Function(ProxiesTabState) _then) = _$ProxiesTabStateCopyWithImpl;
@useResult
$Res call({
 List<Group> groups, String? currentGroupName, ProxyCardType proxyCardType, int columns
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
@pragma('vm:prefer-inline') @override $Res call({Object? groups = null,Object? currentGroupName = freezed,Object? proxyCardType = null,Object? columns = null,}) {
  return _then(_self.copyWith(
groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Group> groups,  String? currentGroupName,  ProxyCardType proxyCardType,  int columns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxiesTabState() when $default != null:
return $default(_that.groups,_that.currentGroupName,_that.proxyCardType,_that.columns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Group> groups,  String? currentGroupName,  ProxyCardType proxyCardType,  int columns)  $default,) {final _that = this;
switch (_that) {
case _ProxiesTabState():
return $default(_that.groups,_that.currentGroupName,_that.proxyCardType,_that.columns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Group> groups,  String? currentGroupName,  ProxyCardType proxyCardType,  int columns)?  $default,) {final _that = this;
switch (_that) {
case _ProxiesTabState() when $default != null:
return $default(_that.groups,_that.currentGroupName,_that.proxyCardType,_that.columns);case _:
  return null;

}
}

}

/// @nodoc


class _ProxiesTabState implements ProxiesTabState {
  const _ProxiesTabState({required final  List<Group> groups, required this.currentGroupName, required this.proxyCardType, required this.columns}): _groups = groups;
  

 final  List<Group> _groups;
@override List<Group> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

@override final  String? currentGroupName;
@override final  ProxyCardType proxyCardType;
@override final  int columns;

/// Create a copy of ProxiesTabState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxiesTabStateCopyWith<_ProxiesTabState> get copyWith => __$ProxiesTabStateCopyWithImpl<_ProxiesTabState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxiesTabState&&const DeepCollectionEquality().equals(other._groups, _groups)&&(identical(other.currentGroupName, currentGroupName) || other.currentGroupName == currentGroupName)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_groups),currentGroupName,proxyCardType,columns);

@override
String toString() {
  return 'ProxiesTabState(groups: $groups, currentGroupName: $currentGroupName, proxyCardType: $proxyCardType, columns: $columns)';
}


}

/// @nodoc
abstract mixin class _$ProxiesTabStateCopyWith<$Res> implements $ProxiesTabStateCopyWith<$Res> {
  factory _$ProxiesTabStateCopyWith(_ProxiesTabState value, $Res Function(_ProxiesTabState) _then) = __$ProxiesTabStateCopyWithImpl;
@override @useResult
$Res call({
 List<Group> groups, String? currentGroupName, ProxyCardType proxyCardType, int columns
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
@override @pragma('vm:prefer-inline') $Res call({Object? groups = null,Object? currentGroupName = freezed,Object? proxyCardType = null,Object? columns = null,}) {
  return _then(_ProxiesTabState(
groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<Group>,currentGroupName: freezed == currentGroupName ? _self.currentGroupName : currentGroupName // ignore: cast_nullable_to_non_nullable
as String?,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ProxyGroupSelectorState {

 String? get testUrl; ProxiesSortType get proxiesSortType; ProxyCardType get proxyCardType; num get sortNum; GroupType get groupType; List<Proxy> get proxies; int get columns;
/// Create a copy of ProxyGroupSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProxyGroupSelectorStateCopyWith<ProxyGroupSelectorState> get copyWith => _$ProxyGroupSelectorStateCopyWithImpl<ProxyGroupSelectorState>(this as ProxyGroupSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProxyGroupSelectorState&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.proxiesSortType, proxiesSortType) || other.proxiesSortType == proxiesSortType)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.sortNum, sortNum) || other.sortNum == sortNum)&&(identical(other.groupType, groupType) || other.groupType == groupType)&&const DeepCollectionEquality().equals(other.proxies, proxies)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,testUrl,proxiesSortType,proxyCardType,sortNum,groupType,const DeepCollectionEquality().hash(proxies),columns);

@override
String toString() {
  return 'ProxyGroupSelectorState(testUrl: $testUrl, proxiesSortType: $proxiesSortType, proxyCardType: $proxyCardType, sortNum: $sortNum, groupType: $groupType, proxies: $proxies, columns: $columns)';
}


}

/// @nodoc
abstract mixin class $ProxyGroupSelectorStateCopyWith<$Res>  {
  factory $ProxyGroupSelectorStateCopyWith(ProxyGroupSelectorState value, $Res Function(ProxyGroupSelectorState) _then) = _$ProxyGroupSelectorStateCopyWithImpl;
@useResult
$Res call({
 String? testUrl, ProxiesSortType proxiesSortType, ProxyCardType proxyCardType, num sortNum, GroupType groupType, List<Proxy> proxies, int columns
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
@pragma('vm:prefer-inline') @override $Res call({Object? testUrl = freezed,Object? proxiesSortType = null,Object? proxyCardType = null,Object? sortNum = null,Object? groupType = null,Object? proxies = null,Object? columns = null,}) {
  return _then(_self.copyWith(
testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,proxiesSortType: null == proxiesSortType ? _self.proxiesSortType : proxiesSortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,sortNum: null == sortNum ? _self.sortNum : sortNum // ignore: cast_nullable_to_non_nullable
as num,groupType: null == groupType ? _self.groupType : groupType // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: null == proxies ? _self.proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? testUrl,  ProxiesSortType proxiesSortType,  ProxyCardType proxyCardType,  num sortNum,  GroupType groupType,  List<Proxy> proxies,  int columns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProxyGroupSelectorState() when $default != null:
return $default(_that.testUrl,_that.proxiesSortType,_that.proxyCardType,_that.sortNum,_that.groupType,_that.proxies,_that.columns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? testUrl,  ProxiesSortType proxiesSortType,  ProxyCardType proxyCardType,  num sortNum,  GroupType groupType,  List<Proxy> proxies,  int columns)  $default,) {final _that = this;
switch (_that) {
case _ProxyGroupSelectorState():
return $default(_that.testUrl,_that.proxiesSortType,_that.proxyCardType,_that.sortNum,_that.groupType,_that.proxies,_that.columns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? testUrl,  ProxiesSortType proxiesSortType,  ProxyCardType proxyCardType,  num sortNum,  GroupType groupType,  List<Proxy> proxies,  int columns)?  $default,) {final _that = this;
switch (_that) {
case _ProxyGroupSelectorState() when $default != null:
return $default(_that.testUrl,_that.proxiesSortType,_that.proxyCardType,_that.sortNum,_that.groupType,_that.proxies,_that.columns);case _:
  return null;

}
}

}

/// @nodoc


class _ProxyGroupSelectorState implements ProxyGroupSelectorState {
  const _ProxyGroupSelectorState({required this.testUrl, required this.proxiesSortType, required this.proxyCardType, required this.sortNum, required this.groupType, required final  List<Proxy> proxies, required this.columns}): _proxies = proxies;
  

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

@override final  int columns;

/// Create a copy of ProxyGroupSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProxyGroupSelectorStateCopyWith<_ProxyGroupSelectorState> get copyWith => __$ProxyGroupSelectorStateCopyWithImpl<_ProxyGroupSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProxyGroupSelectorState&&(identical(other.testUrl, testUrl) || other.testUrl == testUrl)&&(identical(other.proxiesSortType, proxiesSortType) || other.proxiesSortType == proxiesSortType)&&(identical(other.proxyCardType, proxyCardType) || other.proxyCardType == proxyCardType)&&(identical(other.sortNum, sortNum) || other.sortNum == sortNum)&&(identical(other.groupType, groupType) || other.groupType == groupType)&&const DeepCollectionEquality().equals(other._proxies, _proxies)&&(identical(other.columns, columns) || other.columns == columns));
}


@override
int get hashCode => Object.hash(runtimeType,testUrl,proxiesSortType,proxyCardType,sortNum,groupType,const DeepCollectionEquality().hash(_proxies),columns);

@override
String toString() {
  return 'ProxyGroupSelectorState(testUrl: $testUrl, proxiesSortType: $proxiesSortType, proxyCardType: $proxyCardType, sortNum: $sortNum, groupType: $groupType, proxies: $proxies, columns: $columns)';
}


}

/// @nodoc
abstract mixin class _$ProxyGroupSelectorStateCopyWith<$Res> implements $ProxyGroupSelectorStateCopyWith<$Res> {
  factory _$ProxyGroupSelectorStateCopyWith(_ProxyGroupSelectorState value, $Res Function(_ProxyGroupSelectorState) _then) = __$ProxyGroupSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 String? testUrl, ProxiesSortType proxiesSortType, ProxyCardType proxyCardType, num sortNum, GroupType groupType, List<Proxy> proxies, int columns
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
@override @pragma('vm:prefer-inline') $Res call({Object? testUrl = freezed,Object? proxiesSortType = null,Object? proxyCardType = null,Object? sortNum = null,Object? groupType = null,Object? proxies = null,Object? columns = null,}) {
  return _then(_ProxyGroupSelectorState(
testUrl: freezed == testUrl ? _self.testUrl : testUrl // ignore: cast_nullable_to_non_nullable
as String?,proxiesSortType: null == proxiesSortType ? _self.proxiesSortType : proxiesSortType // ignore: cast_nullable_to_non_nullable
as ProxiesSortType,proxyCardType: null == proxyCardType ? _self.proxyCardType : proxyCardType // ignore: cast_nullable_to_non_nullable
as ProxyCardType,sortNum: null == sortNum ? _self.sortNum : sortNum // ignore: cast_nullable_to_non_nullable
as num,groupType: null == groupType ? _self.groupType : groupType // ignore: cast_nullable_to_non_nullable
as GroupType,proxies: null == proxies ? _self._proxies : proxies // ignore: cast_nullable_to_non_nullable
as List<Proxy>,columns: null == columns ? _self.columns : columns // ignore: cast_nullable_to_non_nullable
as int,
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

 List<Package> get packages; AccessControl get accessControl;
/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageListSelectorStateCopyWith<PackageListSelectorState> get copyWith => _$PackageListSelectorStateCopyWithImpl<PackageListSelectorState>(this as PackageListSelectorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageListSelectorState&&const DeepCollectionEquality().equals(other.packages, packages)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(packages),accessControl);

@override
String toString() {
  return 'PackageListSelectorState(packages: $packages, accessControl: $accessControl)';
}


}

/// @nodoc
abstract mixin class $PackageListSelectorStateCopyWith<$Res>  {
  factory $PackageListSelectorStateCopyWith(PackageListSelectorState value, $Res Function(PackageListSelectorState) _then) = _$PackageListSelectorStateCopyWithImpl;
@useResult
$Res call({
 List<Package> packages, AccessControl accessControl
});


$AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class _$PackageListSelectorStateCopyWithImpl<$Res>
    implements $PackageListSelectorStateCopyWith<$Res> {
  _$PackageListSelectorStateCopyWithImpl(this._self, this._then);

  final PackageListSelectorState _self;
  final $Res Function(PackageListSelectorState) _then;

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packages = null,Object? accessControl = null,}) {
  return _then(_self.copyWith(
packages: null == packages ? _self.packages : packages // ignore: cast_nullable_to_non_nullable
as List<Package>,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,
  ));
}
/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Package> packages,  AccessControl accessControl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageListSelectorState() when $default != null:
return $default(_that.packages,_that.accessControl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Package> packages,  AccessControl accessControl)  $default,) {final _that = this;
switch (_that) {
case _PackageListSelectorState():
return $default(_that.packages,_that.accessControl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Package> packages,  AccessControl accessControl)?  $default,) {final _that = this;
switch (_that) {
case _PackageListSelectorState() when $default != null:
return $default(_that.packages,_that.accessControl);case _:
  return null;

}
}

}

/// @nodoc


class _PackageListSelectorState implements PackageListSelectorState {
  const _PackageListSelectorState({required final  List<Package> packages, required this.accessControl}): _packages = packages;
  

 final  List<Package> _packages;
@override List<Package> get packages {
  if (_packages is EqualUnmodifiableListView) return _packages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_packages);
}

@override final  AccessControl accessControl;

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageListSelectorStateCopyWith<_PackageListSelectorState> get copyWith => __$PackageListSelectorStateCopyWithImpl<_PackageListSelectorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageListSelectorState&&const DeepCollectionEquality().equals(other._packages, _packages)&&(identical(other.accessControl, accessControl) || other.accessControl == accessControl));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_packages),accessControl);

@override
String toString() {
  return 'PackageListSelectorState(packages: $packages, accessControl: $accessControl)';
}


}

/// @nodoc
abstract mixin class _$PackageListSelectorStateCopyWith<$Res> implements $PackageListSelectorStateCopyWith<$Res> {
  factory _$PackageListSelectorStateCopyWith(_PackageListSelectorState value, $Res Function(_PackageListSelectorState) _then) = __$PackageListSelectorStateCopyWithImpl;
@override @useResult
$Res call({
 List<Package> packages, AccessControl accessControl
});


@override $AccessControlCopyWith<$Res> get accessControl;

}
/// @nodoc
class __$PackageListSelectorStateCopyWithImpl<$Res>
    implements _$PackageListSelectorStateCopyWith<$Res> {
  __$PackageListSelectorStateCopyWithImpl(this._self, this._then);

  final _PackageListSelectorState _self;
  final $Res Function(_PackageListSelectorState) _then;

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packages = null,Object? accessControl = null,}) {
  return _then(_PackageListSelectorState(
packages: null == packages ? _self._packages : packages // ignore: cast_nullable_to_non_nullable
as List<Package>,accessControl: null == accessControl ? _self.accessControl : accessControl // ignore: cast_nullable_to_non_nullable
as AccessControl,
  ));
}

/// Create a copy of PackageListSelectorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccessControlCopyWith<$Res> get accessControl {
  
  return $AccessControlCopyWith<$Res>(_self.accessControl, (value) {
    return _then(_self.copyWith(accessControl: value));
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
mixin _$ClashConfigState {

 bool get overrideDns; ClashConfig get clashConfig; OverrideData get overrideData; RouteMode get routeMode;
/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClashConfigStateCopyWith<ClashConfigState> get copyWith => _$ClashConfigStateCopyWithImpl<ClashConfigState>(this as ClashConfigState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClashConfigState&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.clashConfig, clashConfig) || other.clashConfig == clashConfig)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData)&&(identical(other.routeMode, routeMode) || other.routeMode == routeMode));
}


@override
int get hashCode => Object.hash(runtimeType,overrideDns,clashConfig,overrideData,routeMode);

@override
String toString() {
  return 'ClashConfigState(overrideDns: $overrideDns, clashConfig: $clashConfig, overrideData: $overrideData, routeMode: $routeMode)';
}


}

/// @nodoc
abstract mixin class $ClashConfigStateCopyWith<$Res>  {
  factory $ClashConfigStateCopyWith(ClashConfigState value, $Res Function(ClashConfigState) _then) = _$ClashConfigStateCopyWithImpl;
@useResult
$Res call({
 bool overrideDns, ClashConfig clashConfig, OverrideData overrideData, RouteMode routeMode
});


$ClashConfigCopyWith<$Res> get clashConfig;$OverrideDataCopyWith<$Res> get overrideData;

}
/// @nodoc
class _$ClashConfigStateCopyWithImpl<$Res>
    implements $ClashConfigStateCopyWith<$Res> {
  _$ClashConfigStateCopyWithImpl(this._self, this._then);

  final ClashConfigState _self;
  final $Res Function(ClashConfigState) _then;

/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? overrideDns = null,Object? clashConfig = null,Object? overrideData = null,Object? routeMode = null,}) {
  return _then(_self.copyWith(
overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,clashConfig: null == clashConfig ? _self.clashConfig : clashConfig // ignore: cast_nullable_to_non_nullable
as ClashConfig,overrideData: null == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData,routeMode: null == routeMode ? _self.routeMode : routeMode // ignore: cast_nullable_to_non_nullable
as RouteMode,
  ));
}
/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<$Res> get clashConfig {
  
  return $ClashConfigCopyWith<$Res>(_self.clashConfig, (value) {
    return _then(_self.copyWith(clashConfig: value));
  });
}/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res> get overrideData {
  
  return $OverrideDataCopyWith<$Res>(_self.overrideData, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClashConfigState].
extension ClashConfigStatePatterns on ClashConfigState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClashConfigState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClashConfigState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClashConfigState value)  $default,){
final _that = this;
switch (_that) {
case _ClashConfigState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClashConfigState value)?  $default,){
final _that = this;
switch (_that) {
case _ClashConfigState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool overrideDns,  ClashConfig clashConfig,  OverrideData overrideData,  RouteMode routeMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClashConfigState() when $default != null:
return $default(_that.overrideDns,_that.clashConfig,_that.overrideData,_that.routeMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool overrideDns,  ClashConfig clashConfig,  OverrideData overrideData,  RouteMode routeMode)  $default,) {final _that = this;
switch (_that) {
case _ClashConfigState():
return $default(_that.overrideDns,_that.clashConfig,_that.overrideData,_that.routeMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool overrideDns,  ClashConfig clashConfig,  OverrideData overrideData,  RouteMode routeMode)?  $default,) {final _that = this;
switch (_that) {
case _ClashConfigState() when $default != null:
return $default(_that.overrideDns,_that.clashConfig,_that.overrideData,_that.routeMode);case _:
  return null;

}
}

}

/// @nodoc


class _ClashConfigState implements ClashConfigState {
  const _ClashConfigState({required this.overrideDns, required this.clashConfig, required this.overrideData, required this.routeMode});
  

@override final  bool overrideDns;
@override final  ClashConfig clashConfig;
@override final  OverrideData overrideData;
@override final  RouteMode routeMode;

/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClashConfigStateCopyWith<_ClashConfigState> get copyWith => __$ClashConfigStateCopyWithImpl<_ClashConfigState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClashConfigState&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.clashConfig, clashConfig) || other.clashConfig == clashConfig)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData)&&(identical(other.routeMode, routeMode) || other.routeMode == routeMode));
}


@override
int get hashCode => Object.hash(runtimeType,overrideDns,clashConfig,overrideData,routeMode);

@override
String toString() {
  return 'ClashConfigState(overrideDns: $overrideDns, clashConfig: $clashConfig, overrideData: $overrideData, routeMode: $routeMode)';
}


}

/// @nodoc
abstract mixin class _$ClashConfigStateCopyWith<$Res> implements $ClashConfigStateCopyWith<$Res> {
  factory _$ClashConfigStateCopyWith(_ClashConfigState value, $Res Function(_ClashConfigState) _then) = __$ClashConfigStateCopyWithImpl;
@override @useResult
$Res call({
 bool overrideDns, ClashConfig clashConfig, OverrideData overrideData, RouteMode routeMode
});


@override $ClashConfigCopyWith<$Res> get clashConfig;@override $OverrideDataCopyWith<$Res> get overrideData;

}
/// @nodoc
class __$ClashConfigStateCopyWithImpl<$Res>
    implements _$ClashConfigStateCopyWith<$Res> {
  __$ClashConfigStateCopyWithImpl(this._self, this._then);

  final _ClashConfigState _self;
  final $Res Function(_ClashConfigState) _then;

/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? overrideDns = null,Object? clashConfig = null,Object? overrideData = null,Object? routeMode = null,}) {
  return _then(_ClashConfigState(
overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,clashConfig: null == clashConfig ? _self.clashConfig : clashConfig // ignore: cast_nullable_to_non_nullable
as ClashConfig,overrideData: null == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData,routeMode: null == routeMode ? _self.routeMode : routeMode // ignore: cast_nullable_to_non_nullable
as RouteMode,
  ));
}

/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigCopyWith<$Res> get clashConfig {
  
  return $ClashConfigCopyWith<$Res>(_self.clashConfig, (value) {
    return _then(_self.copyWith(clashConfig: value));
  });
}/// Create a copy of ClashConfigState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res> get overrideData {
  
  return $OverrideDataCopyWith<$Res>(_self.overrideData, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}
}

/// @nodoc
mixin _$DashboardState {

 List<DashboardWidget> get dashboardWidgets; double get contentWidth;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&const DeepCollectionEquality().equals(other.dashboardWidgets, dashboardWidgets)&&(identical(other.contentWidth, contentWidth) || other.contentWidth == contentWidth));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dashboardWidgets),contentWidth);

@override
String toString() {
  return 'DashboardState(dashboardWidgets: $dashboardWidgets, contentWidth: $contentWidth)';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 List<DashboardWidget> dashboardWidgets, double contentWidth
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
@pragma('vm:prefer-inline') @override $Res call({Object? dashboardWidgets = null,Object? contentWidth = null,}) {
  return _then(_self.copyWith(
dashboardWidgets: null == dashboardWidgets ? _self.dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,contentWidth: null == contentWidth ? _self.contentWidth : contentWidth // ignore: cast_nullable_to_non_nullable
as double,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<DashboardWidget> dashboardWidgets,  double contentWidth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.dashboardWidgets,_that.contentWidth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<DashboardWidget> dashboardWidgets,  double contentWidth)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.dashboardWidgets,_that.contentWidth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<DashboardWidget> dashboardWidgets,  double contentWidth)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.dashboardWidgets,_that.contentWidth);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({required final  List<DashboardWidget> dashboardWidgets, required this.contentWidth}): _dashboardWidgets = dashboardWidgets;
  

 final  List<DashboardWidget> _dashboardWidgets;
@override List<DashboardWidget> get dashboardWidgets {
  if (_dashboardWidgets is EqualUnmodifiableListView) return _dashboardWidgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dashboardWidgets);
}

@override final  double contentWidth;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&const DeepCollectionEquality().equals(other._dashboardWidgets, _dashboardWidgets)&&(identical(other.contentWidth, contentWidth) || other.contentWidth == contentWidth));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dashboardWidgets),contentWidth);

@override
String toString() {
  return 'DashboardState(dashboardWidgets: $dashboardWidgets, contentWidth: $contentWidth)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 List<DashboardWidget> dashboardWidgets, double contentWidth
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
@override @pragma('vm:prefer-inline') $Res call({Object? dashboardWidgets = null,Object? contentWidth = null,}) {
  return _then(_DashboardState(
dashboardWidgets: null == dashboardWidgets ? _self._dashboardWidgets : dashboardWidgets // ignore: cast_nullable_to_non_nullable
as List<DashboardWidget>,contentWidth: null == contentWidth ? _self.contentWidth : contentWidth // ignore: cast_nullable_to_non_nullable
as double,
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
mixin _$ProfileOverrideModel {

 ClashConfigSnippet get snippet; Set<String> get selectedRules; OverrideData? get overrideData;
/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileOverrideModelCopyWith<ProfileOverrideModel> get copyWith => _$ProfileOverrideModelCopyWithImpl<ProfileOverrideModel>(this as ProfileOverrideModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileOverrideModel&&(identical(other.snippet, snippet) || other.snippet == snippet)&&const DeepCollectionEquality().equals(other.selectedRules, selectedRules)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData));
}


@override
int get hashCode => Object.hash(runtimeType,snippet,const DeepCollectionEquality().hash(selectedRules),overrideData);

@override
String toString() {
  return 'ProfileOverrideModel(snippet: $snippet, selectedRules: $selectedRules, overrideData: $overrideData)';
}


}

/// @nodoc
abstract mixin class $ProfileOverrideModelCopyWith<$Res>  {
  factory $ProfileOverrideModelCopyWith(ProfileOverrideModel value, $Res Function(ProfileOverrideModel) _then) = _$ProfileOverrideModelCopyWithImpl;
@useResult
$Res call({
 ClashConfigSnippet snippet, Set<String> selectedRules, OverrideData? overrideData
});


$ClashConfigSnippetCopyWith<$Res> get snippet;$OverrideDataCopyWith<$Res>? get overrideData;

}
/// @nodoc
class _$ProfileOverrideModelCopyWithImpl<$Res>
    implements $ProfileOverrideModelCopyWith<$Res> {
  _$ProfileOverrideModelCopyWithImpl(this._self, this._then);

  final ProfileOverrideModel _self;
  final $Res Function(ProfileOverrideModel) _then;

/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? snippet = null,Object? selectedRules = null,Object? overrideData = freezed,}) {
  return _then(_self.copyWith(
snippet: null == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as ClashConfigSnippet,selectedRules: null == selectedRules ? _self.selectedRules : selectedRules // ignore: cast_nullable_to_non_nullable
as Set<String>,overrideData: freezed == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData?,
  ));
}
/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigSnippetCopyWith<$Res> get snippet {
  
  return $ClashConfigSnippetCopyWith<$Res>(_self.snippet, (value) {
    return _then(_self.copyWith(snippet: value));
  });
}/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res>? get overrideData {
    if (_self.overrideData == null) {
    return null;
  }

  return $OverrideDataCopyWith<$Res>(_self.overrideData!, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProfileOverrideModel].
extension ProfileOverrideModelPatterns on ProfileOverrideModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileOverrideModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileOverrideModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileOverrideModel value)  $default,){
final _that = this;
switch (_that) {
case _ProfileOverrideModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileOverrideModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileOverrideModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ClashConfigSnippet snippet,  Set<String> selectedRules,  OverrideData? overrideData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileOverrideModel() when $default != null:
return $default(_that.snippet,_that.selectedRules,_that.overrideData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ClashConfigSnippet snippet,  Set<String> selectedRules,  OverrideData? overrideData)  $default,) {final _that = this;
switch (_that) {
case _ProfileOverrideModel():
return $default(_that.snippet,_that.selectedRules,_that.overrideData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ClashConfigSnippet snippet,  Set<String> selectedRules,  OverrideData? overrideData)?  $default,) {final _that = this;
switch (_that) {
case _ProfileOverrideModel() when $default != null:
return $default(_that.snippet,_that.selectedRules,_that.overrideData);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileOverrideModel implements ProfileOverrideModel {
  const _ProfileOverrideModel({this.snippet = const ClashConfigSnippet(), final  Set<String> selectedRules = const {}, this.overrideData}): _selectedRules = selectedRules;
  

@override@JsonKey() final  ClashConfigSnippet snippet;
 final  Set<String> _selectedRules;
@override@JsonKey() Set<String> get selectedRules {
  if (_selectedRules is EqualUnmodifiableSetView) return _selectedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedRules);
}

@override final  OverrideData? overrideData;

/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileOverrideModelCopyWith<_ProfileOverrideModel> get copyWith => __$ProfileOverrideModelCopyWithImpl<_ProfileOverrideModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileOverrideModel&&(identical(other.snippet, snippet) || other.snippet == snippet)&&const DeepCollectionEquality().equals(other._selectedRules, _selectedRules)&&(identical(other.overrideData, overrideData) || other.overrideData == overrideData));
}


@override
int get hashCode => Object.hash(runtimeType,snippet,const DeepCollectionEquality().hash(_selectedRules),overrideData);

@override
String toString() {
  return 'ProfileOverrideModel(snippet: $snippet, selectedRules: $selectedRules, overrideData: $overrideData)';
}


}

/// @nodoc
abstract mixin class _$ProfileOverrideModelCopyWith<$Res> implements $ProfileOverrideModelCopyWith<$Res> {
  factory _$ProfileOverrideModelCopyWith(_ProfileOverrideModel value, $Res Function(_ProfileOverrideModel) _then) = __$ProfileOverrideModelCopyWithImpl;
@override @useResult
$Res call({
 ClashConfigSnippet snippet, Set<String> selectedRules, OverrideData? overrideData
});


@override $ClashConfigSnippetCopyWith<$Res> get snippet;@override $OverrideDataCopyWith<$Res>? get overrideData;

}
/// @nodoc
class __$ProfileOverrideModelCopyWithImpl<$Res>
    implements _$ProfileOverrideModelCopyWith<$Res> {
  __$ProfileOverrideModelCopyWithImpl(this._self, this._then);

  final _ProfileOverrideModel _self;
  final $Res Function(_ProfileOverrideModel) _then;

/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? snippet = null,Object? selectedRules = null,Object? overrideData = freezed,}) {
  return _then(_ProfileOverrideModel(
snippet: null == snippet ? _self.snippet : snippet // ignore: cast_nullable_to_non_nullable
as ClashConfigSnippet,selectedRules: null == selectedRules ? _self._selectedRules : selectedRules // ignore: cast_nullable_to_non_nullable
as Set<String>,overrideData: freezed == overrideData ? _self.overrideData : overrideData // ignore: cast_nullable_to_non_nullable
as OverrideData?,
  ));
}

/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClashConfigSnippetCopyWith<$Res> get snippet {
  
  return $ClashConfigSnippetCopyWith<$Res>(_self.snippet, (value) {
    return _then(_self.copyWith(snippet: value));
  });
}/// Create a copy of ProfileOverrideModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OverrideDataCopyWith<$Res>? get overrideData {
    if (_self.overrideData == null) {
    return null;
  }

  return $OverrideDataCopyWith<$Res>(_self.overrideData!, (value) {
    return _then(_self.copyWith(overrideData: value));
  });
}
}

/// @nodoc
mixin _$SetupState {

 String? get profileId; int? get profileLastUpdateDate; OverwriteType get overwriteType; List<Rule> get addedRules; String? get scriptContent; bool get overrideDns; Dns get dns;
/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetupStateCopyWith<SetupState> get copyWith => _$SetupStateCopyWithImpl<SetupState>(this as SetupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetupState&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileLastUpdateDate, profileLastUpdateDate) || other.profileLastUpdateDate == profileLastUpdateDate)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&const DeepCollectionEquality().equals(other.addedRules, addedRules)&&(identical(other.scriptContent, scriptContent) || other.scriptContent == scriptContent)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dns, dns) || other.dns == dns));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,profileLastUpdateDate,overwriteType,const DeepCollectionEquality().hash(addedRules),scriptContent,overrideDns,dns);

@override
String toString() {
  return 'SetupState(profileId: $profileId, profileLastUpdateDate: $profileLastUpdateDate, overwriteType: $overwriteType, addedRules: $addedRules, scriptContent: $scriptContent, overrideDns: $overrideDns, dns: $dns)';
}


}

/// @nodoc
abstract mixin class $SetupStateCopyWith<$Res>  {
  factory $SetupStateCopyWith(SetupState value, $Res Function(SetupState) _then) = _$SetupStateCopyWithImpl;
@useResult
$Res call({
 String? profileId, int? profileLastUpdateDate, OverwriteType overwriteType, List<Rule> addedRules, String? scriptContent, bool overrideDns, Dns dns
});


$DnsCopyWith<$Res> get dns;

}
/// @nodoc
class _$SetupStateCopyWithImpl<$Res>
    implements $SetupStateCopyWith<$Res> {
  _$SetupStateCopyWithImpl(this._self, this._then);

  final SetupState _self;
  final $Res Function(SetupState) _then;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profileId = freezed,Object? profileLastUpdateDate = freezed,Object? overwriteType = null,Object? addedRules = null,Object? scriptContent = freezed,Object? overrideDns = null,Object? dns = null,}) {
  return _then(_self.copyWith(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,profileLastUpdateDate: freezed == profileLastUpdateDate ? _self.profileLastUpdateDate : profileLastUpdateDate // ignore: cast_nullable_to_non_nullable
as int?,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,addedRules: null == addedRules ? _self.addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,scriptContent: freezed == scriptContent ? _self.scriptContent : scriptContent // ignore: cast_nullable_to_non_nullable
as String?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,
  ));
}
/// Create a copy of SetupState
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> addedRules,  String? scriptContent,  bool overrideDns,  Dns dns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SetupState() when $default != null:
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.addedRules,_that.scriptContent,_that.overrideDns,_that.dns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> addedRules,  String? scriptContent,  bool overrideDns,  Dns dns)  $default,) {final _that = this;
switch (_that) {
case _SetupState():
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.addedRules,_that.scriptContent,_that.overrideDns,_that.dns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? profileId,  int? profileLastUpdateDate,  OverwriteType overwriteType,  List<Rule> addedRules,  String? scriptContent,  bool overrideDns,  Dns dns)?  $default,) {final _that = this;
switch (_that) {
case _SetupState() when $default != null:
return $default(_that.profileId,_that.profileLastUpdateDate,_that.overwriteType,_that.addedRules,_that.scriptContent,_that.overrideDns,_that.dns);case _:
  return null;

}
}

}

/// @nodoc


class _SetupState implements SetupState {
  const _SetupState({required this.profileId, required this.profileLastUpdateDate, required this.overwriteType, required final  List<Rule> addedRules, required this.scriptContent, required this.overrideDns, required this.dns}): _addedRules = addedRules;
  

@override final  String? profileId;
@override final  int? profileLastUpdateDate;
@override final  OverwriteType overwriteType;
 final  List<Rule> _addedRules;
@override List<Rule> get addedRules {
  if (_addedRules is EqualUnmodifiableListView) return _addedRules;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addedRules);
}

@override final  String? scriptContent;
@override final  bool overrideDns;
@override final  Dns dns;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetupStateCopyWith<_SetupState> get copyWith => __$SetupStateCopyWithImpl<_SetupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetupState&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.profileLastUpdateDate, profileLastUpdateDate) || other.profileLastUpdateDate == profileLastUpdateDate)&&(identical(other.overwriteType, overwriteType) || other.overwriteType == overwriteType)&&const DeepCollectionEquality().equals(other._addedRules, _addedRules)&&(identical(other.scriptContent, scriptContent) || other.scriptContent == scriptContent)&&(identical(other.overrideDns, overrideDns) || other.overrideDns == overrideDns)&&(identical(other.dns, dns) || other.dns == dns));
}


@override
int get hashCode => Object.hash(runtimeType,profileId,profileLastUpdateDate,overwriteType,const DeepCollectionEquality().hash(_addedRules),scriptContent,overrideDns,dns);

@override
String toString() {
  return 'SetupState(profileId: $profileId, profileLastUpdateDate: $profileLastUpdateDate, overwriteType: $overwriteType, addedRules: $addedRules, scriptContent: $scriptContent, overrideDns: $overrideDns, dns: $dns)';
}


}

/// @nodoc
abstract mixin class _$SetupStateCopyWith<$Res> implements $SetupStateCopyWith<$Res> {
  factory _$SetupStateCopyWith(_SetupState value, $Res Function(_SetupState) _then) = __$SetupStateCopyWithImpl;
@override @useResult
$Res call({
 String? profileId, int? profileLastUpdateDate, OverwriteType overwriteType, List<Rule> addedRules, String? scriptContent, bool overrideDns, Dns dns
});


@override $DnsCopyWith<$Res> get dns;

}
/// @nodoc
class __$SetupStateCopyWithImpl<$Res>
    implements _$SetupStateCopyWith<$Res> {
  __$SetupStateCopyWithImpl(this._self, this._then);

  final _SetupState _self;
  final $Res Function(_SetupState) _then;

/// Create a copy of SetupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profileId = freezed,Object? profileLastUpdateDate = freezed,Object? overwriteType = null,Object? addedRules = null,Object? scriptContent = freezed,Object? overrideDns = null,Object? dns = null,}) {
  return _then(_SetupState(
profileId: freezed == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String?,profileLastUpdateDate: freezed == profileLastUpdateDate ? _self.profileLastUpdateDate : profileLastUpdateDate // ignore: cast_nullable_to_non_nullable
as int?,overwriteType: null == overwriteType ? _self.overwriteType : overwriteType // ignore: cast_nullable_to_non_nullable
as OverwriteType,addedRules: null == addedRules ? _self._addedRules : addedRules // ignore: cast_nullable_to_non_nullable
as List<Rule>,scriptContent: freezed == scriptContent ? _self.scriptContent : scriptContent // ignore: cast_nullable_to_non_nullable
as String?,overrideDns: null == overrideDns ? _self.overrideDns : overrideDns // ignore: cast_nullable_to_non_nullable
as bool,dns: null == dns ? _self.dns : dns // ignore: cast_nullable_to_non_nullable
as Dns,
  ));
}

/// Create a copy of SetupState
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

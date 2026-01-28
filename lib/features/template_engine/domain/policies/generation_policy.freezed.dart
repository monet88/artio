// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generation_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GenerationEligibility {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? remainingCredits) allowed,
    required TResult Function(String reason) denied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? remainingCredits)? allowed,
    TResult? Function(String reason)? denied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? remainingCredits)? allowed,
    TResult Function(String reason)? denied,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Allowed value) allowed,
    required TResult Function(_Denied value) denied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Allowed value)? allowed,
    TResult? Function(_Denied value)? denied,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Allowed value)? allowed,
    TResult Function(_Denied value)? denied,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenerationEligibilityCopyWith<$Res> {
  factory $GenerationEligibilityCopyWith(
    GenerationEligibility value,
    $Res Function(GenerationEligibility) then,
  ) = _$GenerationEligibilityCopyWithImpl<$Res, GenerationEligibility>;
}

/// @nodoc
class _$GenerationEligibilityCopyWithImpl<
  $Res,
  $Val extends GenerationEligibility
>
    implements $GenerationEligibilityCopyWith<$Res> {
  _$GenerationEligibilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AllowedImplCopyWith<$Res> {
  factory _$$AllowedImplCopyWith(
    _$AllowedImpl value,
    $Res Function(_$AllowedImpl) then,
  ) = __$$AllowedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int? remainingCredits});
}

/// @nodoc
class __$$AllowedImplCopyWithImpl<$Res>
    extends _$GenerationEligibilityCopyWithImpl<$Res, _$AllowedImpl>
    implements _$$AllowedImplCopyWith<$Res> {
  __$$AllowedImplCopyWithImpl(
    _$AllowedImpl _value,
    $Res Function(_$AllowedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? remainingCredits = freezed}) {
    return _then(
      _$AllowedImpl(
        remainingCredits: freezed == remainingCredits
            ? _value.remainingCredits
            : remainingCredits // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$AllowedImpl extends _Allowed {
  const _$AllowedImpl({this.remainingCredits}) : super._();

  @override
  final int? remainingCredits;

  @override
  String toString() {
    return 'GenerationEligibility.allowed(remainingCredits: $remainingCredits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllowedImpl &&
            (identical(other.remainingCredits, remainingCredits) ||
                other.remainingCredits == remainingCredits));
  }

  @override
  int get hashCode => Object.hash(runtimeType, remainingCredits);

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllowedImplCopyWith<_$AllowedImpl> get copyWith =>
      __$$AllowedImplCopyWithImpl<_$AllowedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? remainingCredits) allowed,
    required TResult Function(String reason) denied,
  }) {
    return allowed(remainingCredits);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? remainingCredits)? allowed,
    TResult? Function(String reason)? denied,
  }) {
    return allowed?.call(remainingCredits);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? remainingCredits)? allowed,
    TResult Function(String reason)? denied,
    required TResult orElse(),
  }) {
    if (allowed != null) {
      return allowed(remainingCredits);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Allowed value) allowed,
    required TResult Function(_Denied value) denied,
  }) {
    return allowed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Allowed value)? allowed,
    TResult? Function(_Denied value)? denied,
  }) {
    return allowed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Allowed value)? allowed,
    TResult Function(_Denied value)? denied,
    required TResult orElse(),
  }) {
    if (allowed != null) {
      return allowed(this);
    }
    return orElse();
  }
}

abstract class _Allowed extends GenerationEligibility {
  const factory _Allowed({final int? remainingCredits}) = _$AllowedImpl;
  const _Allowed._() : super._();

  int? get remainingCredits;

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllowedImplCopyWith<_$AllowedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DeniedImplCopyWith<$Res> {
  factory _$$DeniedImplCopyWith(
    _$DeniedImpl value,
    $Res Function(_$DeniedImpl) then,
  ) = __$$DeniedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String reason});
}

/// @nodoc
class __$$DeniedImplCopyWithImpl<$Res>
    extends _$GenerationEligibilityCopyWithImpl<$Res, _$DeniedImpl>
    implements _$$DeniedImplCopyWith<$Res> {
  __$$DeniedImplCopyWithImpl(
    _$DeniedImpl _value,
    $Res Function(_$DeniedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? reason = null}) {
    return _then(
      _$DeniedImpl(
        reason: null == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DeniedImpl extends _Denied {
  const _$DeniedImpl({required this.reason}) : super._();

  @override
  final String reason;

  @override
  String toString() {
    return 'GenerationEligibility.denied(reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeniedImpl &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @override
  int get hashCode => Object.hash(runtimeType, reason);

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeniedImplCopyWith<_$DeniedImpl> get copyWith =>
      __$$DeniedImplCopyWithImpl<_$DeniedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int? remainingCredits) allowed,
    required TResult Function(String reason) denied,
  }) {
    return denied(reason);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int? remainingCredits)? allowed,
    TResult? Function(String reason)? denied,
  }) {
    return denied?.call(reason);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int? remainingCredits)? allowed,
    TResult Function(String reason)? denied,
    required TResult orElse(),
  }) {
    if (denied != null) {
      return denied(reason);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Allowed value) allowed,
    required TResult Function(_Denied value) denied,
  }) {
    return denied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Allowed value)? allowed,
    TResult? Function(_Denied value)? denied,
  }) {
    return denied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Allowed value)? allowed,
    TResult Function(_Denied value)? denied,
    required TResult orElse(),
  }) {
    if (denied != null) {
      return denied(this);
    }
    return orElse();
  }
}

abstract class _Denied extends GenerationEligibility {
  const factory _Denied({required final String reason}) = _$DeniedImpl;
  const _Denied._() : super._();

  String get reason;

  /// Create a copy of GenerationEligibility
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeniedImplCopyWith<_$DeniedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

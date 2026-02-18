// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreditBalance _$CreditBalanceFromJson(Map<String, dynamic> json) {
  return _CreditBalance.fromJson(json);
}

/// @nodoc
mixin _$CreditBalance {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  int get balance => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CreditBalance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditBalanceCopyWith<CreditBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditBalanceCopyWith<$Res> {
  factory $CreditBalanceCopyWith(
    CreditBalance value,
    $Res Function(CreditBalance) then,
  ) = _$CreditBalanceCopyWithImpl<$Res, CreditBalance>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    int balance,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class _$CreditBalanceCopyWithImpl<$Res, $Val extends CreditBalance>
    implements $CreditBalanceCopyWith<$Res> {
  _$CreditBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? balance = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as int,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditBalanceImplCopyWith<$Res>
    implements $CreditBalanceCopyWith<$Res> {
  factory _$$CreditBalanceImplCopyWith(
    _$CreditBalanceImpl value,
    $Res Function(_$CreditBalanceImpl) then,
  ) = __$$CreditBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    int balance,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
  });
}

/// @nodoc
class __$$CreditBalanceImplCopyWithImpl<$Res>
    extends _$CreditBalanceCopyWithImpl<$Res, _$CreditBalanceImpl>
    implements _$$CreditBalanceImplCopyWith<$Res> {
  __$$CreditBalanceImplCopyWithImpl(
    _$CreditBalanceImpl _value,
    $Res Function(_$CreditBalanceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? balance = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CreditBalanceImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as int,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditBalanceImpl implements _CreditBalance {
  const _$CreditBalanceImpl({
    @JsonKey(name: 'user_id') required this.userId,
    required this.balance,
    @JsonKey(name: 'updated_at') required this.updatedAt,
  });

  factory _$CreditBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditBalanceImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final int balance;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CreditBalance(userId: $userId, balance: $balance, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditBalanceImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, balance, updatedAt);

  /// Create a copy of CreditBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditBalanceImplCopyWith<_$CreditBalanceImpl> get copyWith =>
      __$$CreditBalanceImplCopyWithImpl<_$CreditBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditBalanceImplToJson(this);
  }
}

abstract class _CreditBalance implements CreditBalance {
  const factory _CreditBalance({
    @JsonKey(name: 'user_id') required final String userId,
    required final int balance,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
  }) = _$CreditBalanceImpl;

  factory _CreditBalance.fromJson(Map<String, dynamic> json) =
      _$CreditBalanceImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  int get balance;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of CreditBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditBalanceImplCopyWith<_$CreditBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

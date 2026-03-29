// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdminUserModel _$AdminUserModelFromJson(Map<String, dynamic> json) {
  return _AdminUserModel.fromJson(json);
}

/// @nodoc
mixin _$AdminUserModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String? get displayName => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_premium')
  bool get isPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_tier')
  String? get subscriptionTier => throw _privateConstructorUsedError;
  @JsonKey(name: 'credit_balance')
  int get creditBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_banned')
  bool get isBanned => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AdminUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminUserModelCopyWith<AdminUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminUserModelCopyWith<$Res> {
  factory $AdminUserModelCopyWith(
    AdminUserModel value,
    $Res Function(AdminUserModel) then,
  ) = _$AdminUserModelCopyWithImpl<$Res, AdminUserModel>;
  @useResult
  $Res call({
    String id,
    String email,
    @JsonKey(name: 'display_name') String? displayName,
    String role,
    @JsonKey(name: 'is_premium') bool isPremium,
    @JsonKey(name: 'subscription_tier') String? subscriptionTier,
    @JsonKey(name: 'credit_balance') int creditBalance,
    @JsonKey(name: 'is_banned') bool isBanned,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$AdminUserModelCopyWithImpl<$Res, $Val extends AdminUserModel>
    implements $AdminUserModelCopyWith<$Res> {
  _$AdminUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? role = null,
    Object? isPremium = null,
    Object? subscriptionTier = freezed,
    Object? creditBalance = null,
    Object? isBanned = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            subscriptionTier: freezed == subscriptionTier
                ? _value.subscriptionTier
                : subscriptionTier // ignore: cast_nullable_to_non_nullable
                      as String?,
            creditBalance: null == creditBalance
                ? _value.creditBalance
                : creditBalance // ignore: cast_nullable_to_non_nullable
                      as int,
            isBanned: null == isBanned
                ? _value.isBanned
                : isBanned // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdminUserModelImplCopyWith<$Res>
    implements $AdminUserModelCopyWith<$Res> {
  factory _$$AdminUserModelImplCopyWith(
    _$AdminUserModelImpl value,
    $Res Function(_$AdminUserModelImpl) then,
  ) = __$$AdminUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    @JsonKey(name: 'display_name') String? displayName,
    String role,
    @JsonKey(name: 'is_premium') bool isPremium,
    @JsonKey(name: 'subscription_tier') String? subscriptionTier,
    @JsonKey(name: 'credit_balance') int creditBalance,
    @JsonKey(name: 'is_banned') bool isBanned,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$AdminUserModelImplCopyWithImpl<$Res>
    extends _$AdminUserModelCopyWithImpl<$Res, _$AdminUserModelImpl>
    implements _$$AdminUserModelImplCopyWith<$Res> {
  __$$AdminUserModelImplCopyWithImpl(
    _$AdminUserModelImpl _value,
    $Res Function(_$AdminUserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? role = null,
    Object? isPremium = null,
    Object? subscriptionTier = freezed,
    Object? creditBalance = null,
    Object? isBanned = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$AdminUserModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        subscriptionTier: freezed == subscriptionTier
            ? _value.subscriptionTier
            : subscriptionTier // ignore: cast_nullable_to_non_nullable
                  as String?,
        creditBalance: null == creditBalance
            ? _value.creditBalance
            : creditBalance // ignore: cast_nullable_to_non_nullable
                  as int,
        isBanned: null == isBanned
            ? _value.isBanned
            : isBanned // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdminUserModelImpl extends _AdminUserModel {
  const _$AdminUserModelImpl({
    required this.id,
    required this.email,
    @JsonKey(name: 'display_name') this.displayName,
    this.role = 'user',
    @JsonKey(name: 'is_premium') this.isPremium = false,
    @JsonKey(name: 'subscription_tier') this.subscriptionTier,
    @JsonKey(name: 'credit_balance') this.creditBalance = 0,
    @JsonKey(name: 'is_banned') this.isBanned = false,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : super._();

  factory _$AdminUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdminUserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  @JsonKey(name: 'display_name')
  final String? displayName;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @override
  @JsonKey(name: 'subscription_tier')
  final String? subscriptionTier;
  @override
  @JsonKey(name: 'credit_balance')
  final int creditBalance;
  @override
  @JsonKey(name: 'is_banned')
  final bool isBanned;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AdminUserModel(id: $id, email: $email, displayName: $displayName, role: $role, isPremium: $isPremium, subscriptionTier: $subscriptionTier, creditBalance: $creditBalance, isBanned: $isBanned, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminUserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.subscriptionTier, subscriptionTier) ||
                other.subscriptionTier == subscriptionTier) &&
            (identical(other.creditBalance, creditBalance) ||
                other.creditBalance == creditBalance) &&
            (identical(other.isBanned, isBanned) ||
                other.isBanned == isBanned) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    displayName,
    role,
    isPremium,
    subscriptionTier,
    creditBalance,
    isBanned,
    createdAt,
    updatedAt,
  );

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminUserModelImplCopyWith<_$AdminUserModelImpl> get copyWith =>
      __$$AdminUserModelImplCopyWithImpl<_$AdminUserModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AdminUserModelImplToJson(this);
  }
}

abstract class _AdminUserModel extends AdminUserModel {
  const factory _AdminUserModel({
    required final String id,
    required final String email,
    @JsonKey(name: 'display_name') final String? displayName,
    final String role,
    @JsonKey(name: 'is_premium') final bool isPremium,
    @JsonKey(name: 'subscription_tier') final String? subscriptionTier,
    @JsonKey(name: 'credit_balance') final int creditBalance,
    @JsonKey(name: 'is_banned') final bool isBanned,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$AdminUserModelImpl;
  const _AdminUserModel._() : super._();

  factory _AdminUserModel.fromJson(Map<String, dynamic> json) =
      _$AdminUserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  @JsonKey(name: 'display_name')
  String? get displayName;
  @override
  String get role;
  @override
  @JsonKey(name: 'is_premium')
  bool get isPremium;
  @override
  @JsonKey(name: 'subscription_tier')
  String? get subscriptionTier;
  @override
  @JsonKey(name: 'credit_balance')
  int get creditBalance;
  @override
  @JsonKey(name: 'is_banned')
  bool get isBanned;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of AdminUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminUserModelImplCopyWith<_$AdminUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

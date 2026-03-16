// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubscriptionPackage {
  /// Store product identifier (e.g., 'artio_pro_monthly').
  String get identifier => throw _privateConstructorUsedError;

  /// Localized price string (e.g., '$9.99/month').
  String get priceString => throw _privateConstructorUsedError;

  /// Raw numeric price in the user's currency (e.g., 9.99).
  /// Used for computing savings percentages across billing periods.
  double get price => throw _privateConstructorUsedError;

  /// The native SDK package object (cast back in the data layer).
  Object get nativePackage => throw _privateConstructorUsedError;

  /// Localized introductory/trial price string, e.g. "Free for 3 days".
  /// Null if no trial is offered for this package.
  String? get introductoryPriceString => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionPackageCopyWith<SubscriptionPackage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionPackageCopyWith<$Res> {
  factory $SubscriptionPackageCopyWith(
    SubscriptionPackage value,
    $Res Function(SubscriptionPackage) then,
  ) = _$SubscriptionPackageCopyWithImpl<$Res, SubscriptionPackage>;
  @useResult
  $Res call({
    String identifier,
    String priceString,
    double price,
    Object nativePackage,
    String? introductoryPriceString,
  });
}

/// @nodoc
class _$SubscriptionPackageCopyWithImpl<$Res, $Val extends SubscriptionPackage>
    implements $SubscriptionPackageCopyWith<$Res> {
  _$SubscriptionPackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? priceString = null,
    Object? price = null,
    Object? nativePackage = null,
    Object? introductoryPriceString = freezed,
  }) {
    return _then(
      _value.copyWith(
            identifier: null == identifier
                ? _value.identifier
                : identifier // ignore: cast_nullable_to_non_nullable
                      as String,
            priceString: null == priceString
                ? _value.priceString
                : priceString // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            nativePackage: null == nativePackage
                ? _value.nativePackage
                : nativePackage,
            introductoryPriceString: freezed == introductoryPriceString
                ? _value.introductoryPriceString
                : introductoryPriceString // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionPackageImplCopyWith<$Res>
    implements $SubscriptionPackageCopyWith<$Res> {
  factory _$$SubscriptionPackageImplCopyWith(
    _$SubscriptionPackageImpl value,
    $Res Function(_$SubscriptionPackageImpl) then,
  ) = __$$SubscriptionPackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String identifier,
    String priceString,
    double price,
    Object nativePackage,
    String? introductoryPriceString,
  });
}

/// @nodoc
class __$$SubscriptionPackageImplCopyWithImpl<$Res>
    extends _$SubscriptionPackageCopyWithImpl<$Res, _$SubscriptionPackageImpl>
    implements _$$SubscriptionPackageImplCopyWith<$Res> {
  __$$SubscriptionPackageImplCopyWithImpl(
    _$SubscriptionPackageImpl _value,
    $Res Function(_$SubscriptionPackageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? priceString = null,
    Object? price = null,
    Object? nativePackage = null,
    Object? introductoryPriceString = freezed,
  }) {
    return _then(
      _$SubscriptionPackageImpl(
        identifier: null == identifier
            ? _value.identifier
            : identifier // ignore: cast_nullable_to_non_nullable
                  as String,
        priceString: null == priceString
            ? _value.priceString
            : priceString // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        nativePackage: null == nativePackage
            ? _value.nativePackage
            : nativePackage,
        introductoryPriceString: freezed == introductoryPriceString
            ? _value.introductoryPriceString
            : introductoryPriceString // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$SubscriptionPackageImpl implements _SubscriptionPackage {
  const _$SubscriptionPackageImpl({
    required this.identifier,
    required this.priceString,
    required this.price,
    required this.nativePackage,
    this.introductoryPriceString,
  });

  /// Store product identifier (e.g., 'artio_pro_monthly').
  @override
  final String identifier;

  /// Localized price string (e.g., '$9.99/month').
  @override
  final String priceString;

  /// Raw numeric price in the user's currency (e.g., 9.99).
  /// Used for computing savings percentages across billing periods.
  @override
  final double price;

  /// The native SDK package object (cast back in the data layer).
  @override
  final Object nativePackage;

  /// Localized introductory/trial price string, e.g. "Free for 3 days".
  /// Null if no trial is offered for this package.
  @override
  final String? introductoryPriceString;

  @override
  String toString() {
    return 'SubscriptionPackage(identifier: $identifier, priceString: $priceString, price: $price, nativePackage: $nativePackage, introductoryPriceString: $introductoryPriceString)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionPackageImpl &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.priceString, priceString) ||
                other.priceString == priceString) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality().equals(
              other.nativePackage,
              nativePackage,
            ) &&
            (identical(
                  other.introductoryPriceString,
                  introductoryPriceString,
                ) ||
                other.introductoryPriceString == introductoryPriceString));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    identifier,
    priceString,
    price,
    const DeepCollectionEquality().hash(nativePackage),
    introductoryPriceString,
  );

  /// Create a copy of SubscriptionPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionPackageImplCopyWith<_$SubscriptionPackageImpl> get copyWith =>
      __$$SubscriptionPackageImplCopyWithImpl<_$SubscriptionPackageImpl>(
        this,
        _$identity,
      );
}

abstract class _SubscriptionPackage implements SubscriptionPackage {
  const factory _SubscriptionPackage({
    required final String identifier,
    required final String priceString,
    required final double price,
    required final Object nativePackage,
    final String? introductoryPriceString,
  }) = _$SubscriptionPackageImpl;

  /// Store product identifier (e.g., 'artio_pro_monthly').
  @override
  String get identifier;

  /// Localized price string (e.g., '$9.99/month').
  @override
  String get priceString;

  /// Raw numeric price in the user's currency (e.g., 9.99).
  /// Used for computing savings percentages across billing periods.
  @override
  double get price;

  /// The native SDK package object (cast back in the data layer).
  @override
  Object get nativePackage;

  /// Localized introductory/trial price string, e.g. "Free for 3 days".
  /// Null if no trial is offered for this package.
  @override
  String? get introductoryPriceString;

  /// Create a copy of SubscriptionPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionPackageImplCopyWith<_$SubscriptionPackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

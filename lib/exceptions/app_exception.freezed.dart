// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppException {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppExceptionCopyWith<AppException> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppExceptionCopyWith<$Res> {
  factory $AppExceptionCopyWith(
    AppException value,
    $Res Function(AppException) then,
  ) = _$AppExceptionCopyWithImpl<$Res, AppException>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppExceptionCopyWithImpl<$Res, $Val extends AppException>
    implements $AppExceptionCopyWith<$Res> {
  _$AppExceptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$NetworkExceptionImplCopyWith(
    _$NetworkExceptionImpl value,
    $Res Function(_$NetworkExceptionImpl) then,
  ) = __$$NetworkExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode});
}

/// @nodoc
class __$$NetworkExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$NetworkExceptionImpl>
    implements _$$NetworkExceptionImplCopyWith<$Res> {
  __$$NetworkExceptionImplCopyWithImpl(
    _$NetworkExceptionImpl _value,
    $Res Function(_$NetworkExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? statusCode = freezed}) {
    return _then(
      _$NetworkExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        statusCode: freezed == statusCode
            ? _value.statusCode
            : statusCode // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$NetworkExceptionImpl implements NetworkException {
  const _$NetworkExceptionImpl({required this.message, this.statusCode});

  @override
  final String message;
  @override
  final int? statusCode;

  @override
  String toString() {
    return 'AppException.network(message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      __$$NetworkExceptionImplCopyWithImpl<_$NetworkExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return network(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return network?.call(message, statusCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkException implements AppException {
  const factory NetworkException({
    required final String message,
    final int? statusCode,
  }) = _$NetworkExceptionImpl;

  @override
  String get message;
  int? get statusCode;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkExceptionImplCopyWith<_$NetworkExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$AuthExceptionImplCopyWith(
    _$AuthExceptionImpl value,
    $Res Function(_$AuthExceptionImpl) then,
  ) = __$$AuthExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$AuthExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$AuthExceptionImpl>
    implements _$$AuthExceptionImplCopyWith<$Res> {
  __$$AuthExceptionImplCopyWithImpl(
    _$AuthExceptionImpl _value,
    $Res Function(_$AuthExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$AuthExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$AuthExceptionImpl implements AuthException {
  const _$AuthExceptionImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'AppException.auth(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthExceptionImplCopyWith<_$AuthExceptionImpl> get copyWith =>
      __$$AuthExceptionImplCopyWithImpl<_$AuthExceptionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return auth(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return auth?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) {
    return auth(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return auth?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (auth != null) {
      return auth(this);
    }
    return orElse();
  }
}

abstract class AuthException implements AppException {
  const factory AuthException({
    required final String message,
    final String? code,
  }) = _$AuthExceptionImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthExceptionImplCopyWith<_$AuthExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StorageExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$StorageExceptionImplCopyWith(
    _$StorageExceptionImpl value,
    $Res Function(_$StorageExceptionImpl) then,
  ) = __$$StorageExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$StorageExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$StorageExceptionImpl>
    implements _$$StorageExceptionImplCopyWith<$Res> {
  __$$StorageExceptionImplCopyWithImpl(
    _$StorageExceptionImpl _value,
    $Res Function(_$StorageExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$StorageExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$StorageExceptionImpl implements StorageException {
  const _$StorageExceptionImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AppException.storage(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageExceptionImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageExceptionImplCopyWith<_$StorageExceptionImpl> get copyWith =>
      __$$StorageExceptionImplCopyWithImpl<_$StorageExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return storage(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return storage?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) {
    return storage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return storage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(this);
    }
    return orElse();
  }
}

abstract class StorageException implements AppException {
  const factory StorageException({required final String message}) =
      _$StorageExceptionImpl;

  @override
  String get message;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageExceptionImplCopyWith<_$StorageExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PaymentExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$PaymentExceptionImplCopyWith(
    _$PaymentExceptionImpl value,
    $Res Function(_$PaymentExceptionImpl) then,
  ) = __$$PaymentExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? code});
}

/// @nodoc
class __$$PaymentExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$PaymentExceptionImpl>
    implements _$$PaymentExceptionImplCopyWith<$Res> {
  __$$PaymentExceptionImplCopyWithImpl(
    _$PaymentExceptionImpl _value,
    $Res Function(_$PaymentExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? code = freezed}) {
    return _then(
      _$PaymentExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        code: freezed == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$PaymentExceptionImpl implements PaymentException {
  const _$PaymentExceptionImpl({required this.message, this.code});

  @override
  final String message;
  @override
  final String? code;

  @override
  String toString() {
    return 'AppException.payment(message: $message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentExceptionImplCopyWith<_$PaymentExceptionImpl> get copyWith =>
      __$$PaymentExceptionImplCopyWithImpl<_$PaymentExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return payment(message, code);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return payment?.call(message, code);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (payment != null) {
      return payment(message, code);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) {
    return payment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return payment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (payment != null) {
      return payment(this);
    }
    return orElse();
  }
}

abstract class PaymentException implements AppException {
  const factory PaymentException({
    required final String message,
    final String? code,
  }) = _$PaymentExceptionImpl;

  @override
  String get message;
  String? get code;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentExceptionImplCopyWith<_$PaymentExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GenerationExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$GenerationExceptionImplCopyWith(
    _$GenerationExceptionImpl value,
    $Res Function(_$GenerationExceptionImpl) then,
  ) = __$$GenerationExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? jobId});
}

/// @nodoc
class __$$GenerationExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$GenerationExceptionImpl>
    implements _$$GenerationExceptionImplCopyWith<$Res> {
  __$$GenerationExceptionImplCopyWithImpl(
    _$GenerationExceptionImpl _value,
    $Res Function(_$GenerationExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? jobId = freezed}) {
    return _then(
      _$GenerationExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        jobId: freezed == jobId
            ? _value.jobId
            : jobId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$GenerationExceptionImpl implements GenerationException {
  const _$GenerationExceptionImpl({required this.message, this.jobId});

  @override
  final String message;
  @override
  final String? jobId;

  @override
  String toString() {
    return 'AppException.generation(message: $message, jobId: $jobId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenerationExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.jobId, jobId) || other.jobId == jobId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, jobId);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenerationExceptionImplCopyWith<_$GenerationExceptionImpl> get copyWith =>
      __$$GenerationExceptionImplCopyWithImpl<_$GenerationExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return generation(message, jobId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return generation?.call(message, jobId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (generation != null) {
      return generation(message, jobId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) {
    return generation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return generation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (generation != null) {
      return generation(this);
    }
    return orElse();
  }
}

abstract class GenerationException implements AppException {
  const factory GenerationException({
    required final String message,
    final String? jobId,
  }) = _$GenerationExceptionImpl;

  @override
  String get message;
  String? get jobId;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenerationExceptionImplCopyWith<_$GenerationExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownExceptionImplCopyWith<$Res>
    implements $AppExceptionCopyWith<$Res> {
  factory _$$UnknownExceptionImplCopyWith(
    _$UnknownExceptionImpl value,
    $Res Function(_$UnknownExceptionImpl) then,
  ) = __$$UnknownExceptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? originalError});
}

/// @nodoc
class __$$UnknownExceptionImplCopyWithImpl<$Res>
    extends _$AppExceptionCopyWithImpl<$Res, _$UnknownExceptionImpl>
    implements _$$UnknownExceptionImplCopyWith<$Res> {
  __$$UnknownExceptionImplCopyWithImpl(
    _$UnknownExceptionImpl _value,
    $Res Function(_$UnknownExceptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? originalError = freezed}) {
    return _then(
      _$UnknownExceptionImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        originalError: freezed == originalError
            ? _value.originalError
            : originalError,
      ),
    );
  }
}

/// @nodoc

class _$UnknownExceptionImpl implements UnknownException {
  const _$UnknownExceptionImpl({required this.message, this.originalError});

  @override
  final String message;
  @override
  final Object? originalError;

  @override
  String toString() {
    return 'AppException.unknown(message: $message, originalError: $originalError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownExceptionImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(
              other.originalError,
              originalError,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(originalError),
  );

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      __$$UnknownExceptionImplCopyWithImpl<_$UnknownExceptionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, int? statusCode) network,
    required TResult Function(String message, String? code) auth,
    required TResult Function(String message) storage,
    required TResult Function(String message, String? code) payment,
    required TResult Function(String message, String? jobId) generation,
    required TResult Function(String message, Object? originalError) unknown,
  }) {
    return unknown(message, originalError);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode)? network,
    TResult? Function(String message, String? code)? auth,
    TResult? Function(String message)? storage,
    TResult? Function(String message, String? code)? payment,
    TResult? Function(String message, String? jobId)? generation,
    TResult? Function(String message, Object? originalError)? unknown,
  }) {
    return unknown?.call(message, originalError);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode)? network,
    TResult Function(String message, String? code)? auth,
    TResult Function(String message)? storage,
    TResult Function(String message, String? code)? payment,
    TResult Function(String message, String? jobId)? generation,
    TResult Function(String message, Object? originalError)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, originalError);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkException value) network,
    required TResult Function(AuthException value) auth,
    required TResult Function(StorageException value) storage,
    required TResult Function(PaymentException value) payment,
    required TResult Function(GenerationException value) generation,
    required TResult Function(UnknownException value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkException value)? network,
    TResult? Function(AuthException value)? auth,
    TResult? Function(StorageException value)? storage,
    TResult? Function(PaymentException value)? payment,
    TResult? Function(GenerationException value)? generation,
    TResult? Function(UnknownException value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkException value)? network,
    TResult Function(AuthException value)? auth,
    TResult Function(StorageException value)? storage,
    TResult Function(PaymentException value)? payment,
    TResult Function(GenerationException value)? generation,
    TResult Function(UnknownException value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownException implements AppException {
  const factory UnknownException({
    required final String message,
    final Object? originalError,
  }) = _$UnknownExceptionImpl;

  @override
  String get message;
  Object? get originalError;

  /// Create a copy of AppException
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownExceptionImplCopyWith<_$UnknownExceptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.network({
    required String message,
    int? statusCode,
  }) = NetworkException;

  const factory AppException.auth({
    required String message,
    String? code,
  }) = AuthException;

  const factory AppException.storage({
    required String message,
  }) = StorageException;

  const factory AppException.payment({
    required String message,
    String? code,
  }) = PaymentException;

  const factory AppException.generation({
    required String message,
    String? jobId,
  }) = GenerationException;

  const factory AppException.unknown({
    required String message,
    Object? originalError,
  }) = UnknownException;
}

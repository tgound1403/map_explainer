import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:geolocator/geolocator.dart';

/// Helper để chuyển đổi các loại errors thành AppError
class ErrorConverter {
  /// Chuyển đổi exception thành AppError
  static AppError fromException(dynamic exception, [StackTrace? stackTrace]) {
    final errorString = exception.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('failed host lookup')) {
      return AppError.network(
        message: exception.toString(),
        code: 'NETWORK_ERROR',
      );
    }

    if (errorString.contains('timeout')) {
      return AppError.network(
        message: exception.toString(),
        code: 'TIMEOUT',
      );
    }

    // Location errors
    if (exception is LocationServiceDisabledException) {
      return AppError.location(
        message: 'Location service is disabled',
        code: 'LOCATION_DISABLED',
      );
    }

    if (exception is PermissionDeniedException) {
      return AppError.location(
        message: 'Location permission denied',
        code: 'PERMISSION_DENIED',
      );
    }

    if (errorString.contains('location') ||
        errorString.contains('permission') ||
        errorString.contains('geolocator')) {
      return AppError.location(
        message: exception.toString(),
        code: 'LOCATION_ERROR',
      );
    }

    // API errors
    if (errorString.contains('api') ||
        errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return AppError.api(
        message: exception.toString(),
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return AppError.api(
        message: exception.toString(),
        code: 'NOT_FOUND',
        statusCode: 404,
      );
    }

    if (errorString.contains('500') ||
        errorString.contains('server') ||
        errorString.contains('internal')) {
      return AppError.api(
        message: exception.toString(),
        code: 'SERVER_ERROR',
        statusCode: 500,
      );
    }

    // Cache errors
    if (errorString.contains('cache') || errorString.contains('hive')) {
      return AppError.cache(
        message: exception.toString(),
      );
    }

    // Unknown error
    return AppError.unknown(
      message: exception.toString(),
      originalError: exception,
    );
  }
}
